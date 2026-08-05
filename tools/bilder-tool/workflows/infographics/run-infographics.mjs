import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import {
  assertImageCapableMode,
  browserInfo,
  insertPrompt,
  navigateTo,
  saveLatestImage,
  sleep,
  stopActiveResponse,
  submitPrompt,
  waitForNewImage
} from "../../core/devtools.mjs";
import {
  assertCleanPrompts,
  buildAgendaJobs,
  existingCount,
  nextMissingJob,
  parseArgs,
  targetExists
} from "./agenda-jobs.mjs";

const now = () => performance.now();

function existingPngFiles(root) {
  const files = [];
  const visit = (dir) => {
    let entries = [];
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      const item = path.join(dir, entry.name);
      if (entry.isDirectory()) visit(item);
      else if (entry.isFile() && entry.name.toLowerCase().endsWith(".png")) files.push(item);
    }
  };
  visit(root);
  return files;
}

function writeImageFile(result, { duplicateRoot }) {
  fs.mkdirSync(path.dirname(result.target), { recursive: true });
  if (targetExists(result.target)) {
    throw new Error(`Ziel existiert bereits, überschreibe nicht: ${result.target}`);
  }
  const hash = crypto.createHash("sha256").update(result.buffer).digest("hex");
  const duplicate = existingPngFiles(duplicateRoot)
    .find((file) => {
      const existing = fs.readFileSync(file);
      return crypto.createHash("sha256").update(existing).digest("hex") === hash;
    });
  if (duplicate) {
    throw new Error(`Bildduplikat erkannt: ${path.basename(result.target)} entspricht ${path.relative(duplicateRoot, duplicate)}`);
  }
  fs.writeFileSync(result.target, result.buffer);
}

async function saveLateImageIfPresent(job, before, { port, duplicateRoot }) {
  const late = await browserInfo({ port });
  const beforeSources = new Set((before.imageSources || []).filter(Boolean));
  const source = (late.imageSources || []).find((src) => src && !beforeSources.has(src)) || "";
  if (!source) return false;

  let image;
  try {
    image = await saveLatestImage(job.target, { port, source });
  } catch (error) {
    const message = String(error.message || error);
    if (message.includes("fetch-failed") || message.includes("403")) {
      console.log(`[${job.id}] verspätetes Bild nicht abrufbar, Retry läuft weiter: ${message}`);
      return false;
    }
    throw error;
  }
  try {
    writeImageFile(image, { duplicateRoot });
  } catch (error) {
    if (String(error.message || "").includes("Bildduplikat erkannt")) {
      console.log(`[${job.id}] verspätetes Duplikat verworfen: ${error.message}`);
      return false;
    }
    throw error;
  }
  console.log(`[${job.id}] verspätet gespeichert (${image.bytes} Bytes): ${job.target}`);
  return true;
}

async function waitForIdle({ port, label, timeoutMs = 180000 }) {
  let elapsed = 0;
  const pollMs = 5000;
  while (elapsed < timeoutMs) {
    const info = await browserInfo({ port });
    if (!info.busy) return;
    console.log(`[warte] ${label}: ChatGPT verarbeitet noch`);
    await sleep(pollMs);
    elapsed += pollMs;
  }
  const result = await stopActiveResponse({ port });
  if (result.stopped) {
    console.log(`[warte] ${label}: hängende Antwort gestoppt`);
    await sleep(3000);
  }
}

async function runJob(job, { port, duplicateRoot, retries = 3, imageTimeoutMs = 12 * 60 * 1000, idleBeforePromptTimeoutMs = 180000, idleAfterSaveTimeoutMs = 120000 }) {
  const firstContentLine = job.prompt
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)[1] || "";

  for (let attempt = 1; attempt <= retries; attempt++) {
    await waitForIdle({ port, label: job.id, timeoutMs: idleBeforePromptTimeoutMs });
    const before = await browserInfo({ port });
    assertImageCapableMode(before);

    console.log(`[${job.id}] Prompt einsetzen (${before.mode || "Modus unbekannt"}): ${job.title}${attempt > 1 ? ` (Retry ${attempt})` : ""}`);
    const inserted = await insertPrompt(job.prompt, { port });
    if (firstContentLine && !inserted.preview.includes(firstContentLine.slice(0, 80))) {
      throw new Error(`${job.id}: Prompt unvollständig im Editor, nicht abgeschickt.`);
    }
    await sleep(500);
    await submitPrompt({ port });
    console.log(`[${job.id}] abgeschickt`);

    try {
      const info = await waitForNewImage(before, { label: job.id, timeoutMs: imageTimeoutMs, options: { port } });
      const image = await saveLatestImage(job.target, { port, source: info.newImageSrc });
      writeImageFile(image, { duplicateRoot });
      console.log(`[${job.id}] gespeichert (${image.bytes} Bytes): ${job.target}`);
      await waitForIdle({ port, label: job.id, timeoutMs: idleAfterSaveTimeoutMs });
      return;
    } catch (error) {
      console.log(`[${job.id}] ${error.message}`);
      await sleep(8000);
      if (await saveLateImageIfPresent(job, before, { port, duplicateRoot })) return;
      if (attempt >= retries) throw error;
      await sleep(12000 + Math.floor(Math.random() * 8000));
      if (await saveLateImageIfPresent(job, before, { port, duplicateRoot })) return;
    }
  }
}

async function main() {
  const args = parseArgs(process.argv);
  if (!args.agenda || !args["source-root"]) {
    throw new Error("Usage: node run-infographics.mjs --agenda Agenda.md --source-root _sources --chat-url https://chatgpt.com/c/... [--once] [--dry-run] [--port 9222]");
  }

  const port = Number(args.port || 9222);
  const agendaPath = path.resolve(args.agenda);
  const sourceRoot = path.resolve(args["source-root"]);
  const jobs = buildAgendaJobs({ agendaPath, sourceRoot });
  assertCleanPrompts(jobs);

  if (args["dry-run"]) {
    const done = existingCount(jobs);
    console.log(JSON.stringify({
      total: jobs.length,
      done,
      remaining: jobs.length - done,
      next: nextMissingJob(jobs) || null
    }, null, 2));
    return;
  }

  if (args["chat-url"]) {
    const info = await browserInfo({ port });
    if (info.url !== args["chat-url"]) {
      await navigateTo(args["chat-url"], { port });
      await sleep(3000);
    }
  }

  const total = jobs.length;
  const freshEvery = Number(args["fresh-every"] || 0);
  const imageTimeoutMs = Number(args["image-timeout-ms"] || 12 * 60 * 1000);
  const idleBeforePromptTimeoutMs = Number(args["idle-before-prompt-timeout-ms"] || 180000);
  const idleAfterSaveTimeoutMs = Number(args["idle-after-save-timeout-ms"] || 120000);
  let generatedSinceFresh = 0;
  const skipped = new Set(String(args.skip || "").split(",").map((item) => item.trim()).filter(Boolean));
  for (const job of jobs) {
    if (skipped.has(job.id)) {
      console.log(`[${job.id}] temporär übersprungen`);
      continue;
    }
    if (targetExists(job.target)) {
      console.log(`[${job.id}] vorhanden, überspringe`);
      continue;
    }
    if (freshEvery > 0 && generatedSinceFresh >= freshEvery) {
      console.log(`[chat] frischer Chat nach ${generatedSinceFresh} Bildern`);
      await navigateTo("https://chatgpt.com/", { port });
      await sleep(5000);
      generatedSinceFresh = 0;
    }
    try {
      await runJob(job, { port, duplicateRoot: sourceRoot, imageTimeoutMs, idleBeforePromptTimeoutMs, idleAfterSaveTimeoutMs });
      generatedSinceFresh++;
    } catch (error) {
      if (!args["keep-going"]) throw error;
      if (String(error.message || "").includes("Kein ChatGPT-Tab")) throw error;
      console.log(`[${job.id}] nach Retries offen gelassen: ${error.message}`);
      if (freshEvery > 0) {
        console.log("[chat] frischer Chat nach offenem Slot");
        try {
          await navigateTo("https://chatgpt.com/", { port });
          await sleep(5000);
        } catch (freshError) {
          console.log(`[chat] frischer Chat fehlgeschlagen: ${freshError.message}`);
        }
        generatedSinceFresh = 0;
      }
      continue;
    }
    const done = existingCount(jobs);
    console.log(`[stand] ${done}/${total} Bilder gespeichert`);
    if (args.once) break;
    await sleep(2000 + Math.floor(Math.random() * 9000));
  }

  console.log("Fertig.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
