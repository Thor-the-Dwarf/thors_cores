const DEFAULT_PORT = 9222;
const now = () => performance.now();

export const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

export async function getChatPage({ port = DEFAULT_PORT } = {}) {
  const pages = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
  const chatPages = pages.filter((entry) => entry.type === "page" && entry.url.includes("chatgpt.com"));
  const freshPage = chatPages.find((entry) => /^https:\/\/chatgpt\.com\/?(?:[?#].*)?$/.test(entry.url));
  const page = freshPage || chatPages[0] || pages.find((entry) => entry.type === "page");
  if (!page) throw new Error("Kein ChatGPT-Tab über DevTools gefunden.");
  return page;
}

export async function withDevTools(fn, { port = DEFAULT_PORT } = {}) {
  const page = await getChatPage({ port });
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  let nextId = 1;
  const pending = new Map();

  ws.onmessage = (event) => {
    const message = JSON.parse(event.data);
    if (!message.id || !pending.has(message.id)) return;
    const { resolve, reject } = pending.get(message.id);
    pending.delete(message.id);
    message.error ? reject(new Error(JSON.stringify(message.error))) : resolve(message.result);
  };

  await new Promise((resolve, reject) => {
    ws.onopen = resolve;
    ws.onerror = reject;
  });

  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    const timeoutMs = Math.max(45000, Number(params.timeout || 0) + 5000);
    const timer = setTimeout(() => {
      pending.delete(id);
      reject(new Error(`DevTools-Timeout bei ${method}`));
    }, timeoutMs);
    pending.set(id, {
      resolve: (value) => {
        clearTimeout(timer);
        resolve(value);
      },
      reject: (error) => {
        clearTimeout(timer);
        reject(error);
      }
    });
    ws.send(JSON.stringify({ id, method, params }));
  });

  try {
    await send("Runtime.enable");
    return await fn(send, page);
  } finally {
    ws.close();
  }
}

export async function evaluate(expression, { timeout = 30000, port = DEFAULT_PORT } = {}) {
  return withDevTools(async (send) => {
    const result = await send("Runtime.evaluate", {
      expression,
      awaitPromise: true,
      returnByValue: true,
      timeout
    });
    if (result.exceptionDetails) throw new Error(JSON.stringify(result.exceptionDetails));
    return result.result?.value;
  }, { port });
}

export async function navigateTo(url, options = {}) {
  return withDevTools(async (send) => {
    await send("Page.enable");
    await send("Page.navigate", { url });
    return { ok: true, url };
  }, options);
}

export async function browserInfo(options = {}) {
  const value = await evaluate(`(() => {
    const isCourseImage = (img) => {
      const src = img.currentSrc || img.src || "";
      const rect = img.getBoundingClientRect();
      return (src.includes("/backend-api/estuary/content") && rect.width >= 300 && rect.height >= 150)
        || (img.naturalWidth >= 1200 && img.naturalHeight >= 700);
    };
    const turnSections = Array.from(document.querySelectorAll("section[data-testid^='conversation-turn-']"));
    const latestUserIndex = turnSections.findLastIndex((section) =>
      section.querySelector("[data-testid='collapsible-user-message-root'], [data-message-author-role='user']")
    );
    const scope = latestUserIndex >= 0 ? turnSections.slice(latestUserIndex + 1) : [];
    const scopedImages = scope.flatMap((section) => Array.from(section.querySelectorAll("img"))).filter(isCourseImage);
    const images = latestUserIndex >= 0 ? scopedImages : Array.from(document.images).filter(isCourseImage);
    const latestAfterUser = scope.at(-1);
    const latestAssistantEmpty = !!latestAfterUser
      && !latestAfterUser.querySelector("[data-message-author-role='user'], [data-testid='collapsible-user-message-root']")
      && !latestAfterUser.querySelector("img")
      && !(latestAfterUser.innerText || "").trim();
    const latestText = latestAfterUser?.innerText || "";
    const latestAssistantError = /Bild.*Fehler|nicht generieren|konnte das Bild|send.*request again|sende die Anfrage/i.test(latestText);
    const latestAssistantTextOnly = !!latestAfterUser
      && !latestAfterUser.querySelector("[data-message-author-role='user'], [data-testid='collapsible-user-message-root']")
      && !latestAfterUser.querySelector("img")
      && /^(Thought for|Nachgedacht)/i.test(latestText.trim());
    const latestAssistantNeedsTopic = !!latestAfterUser
      && !latestAfterUser.querySelector("[data-message-author-role='user'], [data-testid='collapsible-user-message-root']")
      && !latestAfterUser.querySelector("img")
      && /Bitte\\s+n(?:enne|enn)|Thema(?: der Infografik)?/i.test(latestText.trim());
    const latestAssistantFileOnly = !!latestAfterUser
      && !latestAfterUser.querySelector("[data-message-author-role='user'], [data-testid='collapsible-user-message-root']")
      && !latestAfterUser.querySelector("img")
      && /Tool uploaded file/i.test(latestText);
    const busy = !!document.querySelector("#composer-submit-button[data-testid='stop-button'], [data-testid='stop-button']");
    const latest = images.at(-1);
    const buttons = Array.from(document.querySelectorAll("button"))
      .map((button) => (button.innerText || button.textContent || "").trim())
      .filter(Boolean);
    const text = document.body.innerText || "";
    return JSON.stringify({
      url: location.href,
      title: document.title,
      composer: Array.from(document.querySelectorAll("#prompt-textarea[contenteditable='true'], [role='textbox'][contenteditable='true'], textarea"))
        .some((editor) => {
          const rect = editor.getBoundingClientRect();
          const style = getComputedStyle(editor);
          return rect.width > 0 && rect.height > 0 && style.display !== "none" && style.visibility !== "hidden";
      }),
      imageCount: images.length,
      latestSrc: (latest?.currentSrc || latest?.src || "").slice(0, 240),
      imageSources: Array.from(new Set(images.map((image) => image.currentSrc || image.src).filter(Boolean))),
      busy,
      latestAssistantEmpty,
      latestAssistantError,
      latestAssistantTextOnly,
      latestAssistantNeedsTopic,
      latestAssistantFileOnly,
      mode: buttons.find((label) => /^(Sofort|Mittel|Hoch|Extra hoch|Pro)$/.test(label)) || "",
      errorCount: (text.match(/Bild-Tool ein Fehler|Bild konnte nicht erstellt werden|nicht generieren|sende die Anfrage einfach noch einmal|send the request again/gi) || []).length
    });
  })()`, options);
  return JSON.parse(value);
}

export function assertImageCapableMode(info) {
  if (info.mode === "Sofort") {
    throw new Error("Abbruch: ChatGPT steht auf Sofort. Für Kursbilder auf Hoch stellen.");
  }
  if (info.mode === "Pro") {
    throw new Error("Abbruch: ChatGPT steht auf Pro. Pro ist für diese Bildproduktion nicht zuverlässig bildfähig.");
  }
}

export async function insertPrompt(prompt, options = {}) {
  return withDevTools(async (send) => {
    await send("Runtime.evaluate", {
      expression: `(() => {
        const text = document.body.innerText || "";
        const blocker = Array.from(document.querySelectorAll("button[aria-label='Schließen']"))
          .find((button) => {
            const rect = button.getBoundingClientRect();
            return rect.width > 0 && rect.height > 0
              && /Kurze Nachfrage|Wie wäre es mit einer Pause/i.test(text);
          });
        if (blocker) blocker.click();
      })()`,
      awaitPromise: true,
      returnByValue: true,
      timeout: 30000
    });
    await sleep(500);
    const value = await send("Runtime.evaluate", {
      expression: `(() => {
    const editors = Array.from(document.querySelectorAll("#prompt-textarea[contenteditable='true'], [role='textbox'][contenteditable='true'], textarea"));
    const editor = editors.find((item) => {
      const rect = item.getBoundingClientRect();
      const style = getComputedStyle(item);
      return rect.width > 0 && rect.height > 0 && style.display !== "none" && style.visibility !== "hidden" && !item.disabled && !item.readOnly;
    }) || editors[0];
    if (!editor) return JSON.stringify({ ok: false, stage: "composer-not-found" });
    editor.focus();
    if (editor.tagName === "TEXTAREA") editor.select();
    else {
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(editor);
      selection.removeAllRanges();
      selection.addRange(range);
    }
    return JSON.stringify({ ok: true, stage: "editor-focused" });
  })()`,
      awaitPromise: true,
      returnByValue: true,
      timeout: 30000
    });
    if (value.exceptionDetails) throw new Error(JSON.stringify(value.exceptionDetails));
    const result = JSON.parse(value.result?.value);
    if (!result.ok) throw new Error(value.result?.value);
    await send("Input.dispatchKeyEvent", { type: "keyDown", key: "a", code: "KeyA", windowsVirtualKeyCode: 65, nativeVirtualKeyCode: 65, modifiers: 4 });
    await send("Input.dispatchKeyEvent", { type: "keyUp", key: "a", code: "KeyA", windowsVirtualKeyCode: 65, nativeVirtualKeyCode: 65, modifiers: 4 });
    await send("Input.insertText", { text: prompt });
    let preview = null;
    for (let i = 0; i < 10; i++) {
      await sleep(250);
      const previewValue = await send("Runtime.evaluate", {
        expression: `(() => {
          const editors = Array.from(document.querySelectorAll("#prompt-textarea[contenteditable='true'], [role='textbox'][contenteditable='true'], textarea"));
          const editor = editors.find((item) => {
            const rect = item.getBoundingClientRect();
            const style = getComputedStyle(item);
            return rect.width > 0 && rect.height > 0
              && style.display !== "none"
              && style.visibility !== "hidden"
              && !item.disabled
              && !item.readOnly;
          }) || editors[0];
          return JSON.stringify({
            ok: true,
            preview: (editor?.innerText || editor?.value || editor?.textContent || "").replace(/\\s+/g, " ").trim().slice(0, 260),
            disabled: document.querySelector("#composer-submit-button, [data-testid='send-button']")?.disabled ?? null
          });
        })()`,
        awaitPromise: true,
        returnByValue: true,
        timeout: 30000
      });
      preview = JSON.parse(previewValue.result?.value);
    }
    return preview;
  }, options);
}

export async function submitPrompt(options = {}) {
  const value = await evaluate(`(async () => {
    const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
    const findSubmitButton = () => {
      const buttons = Array.from(document.querySelectorAll("button"));
      return buttons.find((button) => {
        const label = [
          button.id,
          button.getAttribute("data-testid"),
          button.getAttribute("aria-label"),
          button.innerText || button.textContent || "",
          button.className || ""
        ].filter(Boolean).join(" ");
        return !button.disabled
          && /(composer-submit-button|send-button|senden|send|submit)/i.test(label)
          && !/(voice|diktat)/i.test(label);
      });
    };
    let button = null;
    for (let i = 0; i < 24; i++) {
      button = findSubmitButton();
      if (button) break;
      await sleep(250);
    }
    if (!button) return JSON.stringify({ ok: false, stage: "submit-not-found" });
    button.click();
    return JSON.stringify({ ok: true, label: (button.getAttribute("aria-label") || button.getAttribute("data-testid") || button.id || button.className || "").toString().slice(0, 120) });
  })()`, options);
  const result = JSON.parse(value);
  if (!result.ok) throw new Error(value);
  return result;
}

export async function stopActiveResponse(options = {}) {
  const value = await evaluate(`(() => {
    const button = document.querySelector("#composer-submit-button[data-testid='stop-button'], [data-testid='stop-button']");
    if (!button) return JSON.stringify({ ok: true, stopped: false });
    button.click();
    return JSON.stringify({ ok: true, stopped: true });
  })()`, options);
  return JSON.parse(value);
}

export async function waitForNewImage(before, {
  label = "Bild",
  timeoutMs = 12 * 60 * 1000,
  pollMs = 5000,
  settleMs = 8000,
  options = {}
} = {}) {
  let elapsed = 0;
  let lastLog = -30000;
  const beforeSources = new Set((before.imageSources || []).filter(Boolean));

  while (elapsed < timeoutMs) {
    await sleep(pollMs);
    elapsed += pollMs;
    const info = await browserInfo(options);
    const newSrc = (info.imageSources || []).find((src) => src && !beforeSources.has(src));
    const changed = newSrc;

    if (changed) {
      await sleep(settleMs);
      const settled = await browserInfo(options);
      settled.newImageSrc = (settled.imageSources || []).find((src) => src && !beforeSources.has(src)) || newSrc || "";
      return settled;
    }

    if (info.errorCount > before.errorCount) {
      throw new Error(`${label}: Bild-Tool-Fehler, Retry nötig.`);
    }
    if (info.latestAssistantError) {
      throw new Error(`${label}: Bild-Tool-Fehler im aktuellen Antwortblock, Retry nötig.`);
    }
    if (!info.busy && info.latestAssistantTextOnly && elapsed > 120000) {
      throw new Error(`${label}: Antwort ohne Bild, Retry nötig.`);
    }
    if (!info.busy && info.latestAssistantNeedsTopic && elapsed > 15000) {
      throw new Error(`${label}: Thema kam nicht im ChatGPT-Prompt an, Retry nötig.`);
    }
    if (!info.busy && info.latestAssistantFileOnly && elapsed > 240000) {
      throw new Error(`${label}: Datei-Hinweis ohne sichtbares Bild, Retry nötig.`);
    }
    if (!info.busy && info.latestAssistantEmpty && elapsed > 180000) {
      throw new Error(`${label}: leere Antwort ohne Bild, Retry nötig.`);
    }

    if (elapsed - lastLog >= 30000) {
      console.log(`[warte] ${label}: ${Math.round(elapsed / 1000)}s, Bilder=${info.imageCount}`);
      lastLog = elapsed;
    }
  }

  throw new Error(`${label}: kein neues Bild innerhalb des Zeitlimits.`);
}

export async function saveLatestImage(target, options = {}) {
  const source = options.source || "";
  const value = await evaluate(`(() => {
    const isCourseImage = (img) => {
      const src = img.currentSrc || img.src || "";
      const rect = img.getBoundingClientRect();
      return (src.includes("/backend-api/estuary/content") && rect.width >= 300 && rect.height >= 150)
        || (img.naturalWidth >= 1200 && img.naturalHeight >= 700);
    };
    const source = ${JSON.stringify(source)};
    const allImages = Array.from(document.images).filter(isCourseImage);
    const turnSections = Array.from(document.querySelectorAll("section[data-testid^='conversation-turn-']"));
    const latestUserIndex = turnSections.findLastIndex((section) =>
      section.querySelector("[data-testid='collapsible-user-message-root'], [data-message-author-role='user']")
    );
    const scope = latestUserIndex >= 0 ? turnSections.slice(latestUserIndex + 1) : [];
    const scopedImages = scope.flatMap((section) => Array.from(section.querySelectorAll("img"))).filter(isCourseImage);
    const images = source ? allImages : (scopedImages.length ? scopedImages : allImages);
    const image = source
      ? images.find((img) => (img.currentSrc || img.src) === source) || images.at(-1)
      : images.at(-1);
    if (!image) return JSON.stringify({ ok: false, stage: "image-not-found" });
    return JSON.stringify({
      ok: true,
      src: image.currentSrc || image.src,
      width: image.naturalWidth || Math.round(image.getBoundingClientRect().width),
      height: image.naturalHeight || Math.round(image.getBoundingClientRect().height)
    });
  })()`, options);
  const result = JSON.parse(value);
  if (!result.ok) throw new Error(value);

  let buffer;
  const response = await fetch(result.src).catch(() => null);
  if (response?.ok) {
    buffer = Buffer.from(await response.arrayBuffer());
  } else {
    const dataValue = await evaluate(`(async () => {
      const isCourseImage = (img) => {
        const src = img.currentSrc || img.src || "";
        const rect = img.getBoundingClientRect();
        return (src.includes("/backend-api/estuary/content") && rect.width >= 300 && rect.height >= 150)
          || (img.naturalWidth >= 1200 && img.naturalHeight >= 700);
      };
      const images = Array.from(document.images)
        .filter(isCourseImage);
      const source = ${JSON.stringify(source)};
      const image = source
        ? images.find((img) => (img.currentSrc || img.src) === source) || images.at(-1)
        : images.at(-1);
      if (!image) return JSON.stringify({ ok: false, stage: "image-not-found" });
      const response = await fetch(image.currentSrc || image.src, { credentials: "include" });
      if (!response.ok) return JSON.stringify({ ok: false, stage: "fetch-failed", status: response.status });
      const bytes = new Uint8Array(await response.arrayBuffer());
      let binary = "";
      for (let i = 0; i < bytes.length; i += 0x8000) {
        binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
      }
      return JSON.stringify({ ok: true, data: btoa(binary), bytes: bytes.length });
    })()`, { ...options, timeout: 120000 });
    const dataResult = JSON.parse(dataValue);
    if (!dataResult.ok) throw new Error(dataValue);
    buffer = Buffer.from(dataResult.data, "base64");
  }

  if (buffer.length < 50000) throw new Error(`Bildabruf zu klein: ${buffer.length} Bytes`);
  return { buffer, width: result.width, height: result.height, bytes: buffer.length, target };
}
