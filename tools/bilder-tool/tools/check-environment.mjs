const port = Number(process.argv[2] || 9222);

if (typeof fetch !== "function" || typeof WebSocket !== "function") {
  throw new Error(`Node.js ${process.version} stellt fetch/WebSocket nicht vollständig bereit. Bitte eine aktuelle LTS-Version installieren.`);
}

const response = await fetch(`http://127.0.0.1:${port}/json/list`).catch((error) => {
  throw new Error(`Chrome DevTools ist auf Port ${port} nicht erreichbar: ${error.message}`);
});
if (!response.ok) {
  throw new Error(`Chrome DevTools antwortet auf Port ${port} mit HTTP ${response.status}.`);
}

const pages = await response.json();
const chatPage = pages.find((entry) => entry.type === "page" && entry.url.includes("chatgpt.com"));
if (!chatPage) {
  throw new Error(`DevTools läuft auf Port ${port}, aber es ist kein ChatGPT-Tab geöffnet.`);
}

console.log(JSON.stringify({
  ok: true,
  node: process.version,
  port,
  chatUrl: chatPage.url,
  title: chatPage.title
}, null, 2));
