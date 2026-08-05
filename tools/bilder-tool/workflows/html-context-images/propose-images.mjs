import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import { filenameText, parseArgs } from "../infographics/agenda-jobs.mjs";

function stripTags(value) {
  return value
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, "\"")
    .replace(/&#39;/g, "'")
    .replace(/\s+/g, " ")
    .trim();
}

function extractBlocks(html) {
  const blocks = [];
  const pattern = /<(h1|h2|h3|section|article|figure|div|li)\b[^>]*>([\s\S]*?)<\/\1>/gi;
  let match;
  while ((match = pattern.exec(html))) {
    const tag = match[1].toLowerCase();
    const text = stripTags(match[2]);
    if (text.length < 35) continue;
    blocks.push({ tag, text: text.slice(0, 700) });
  }
  return blocks;
}

function extractDokutorialPages(html) {
  const match = html.match(/const\s+pages\s*=\s*(\[[\s\S]*?\]);\s*\n\s*const\s+state\s*=/);
  if (!match) return [];
  const sandbox = {};
  vm.createContext(sandbox);
  vm.runInContext(`pages = ${match[1]};`, sandbox, { timeout: 1000 });
  return Array.isArray(sandbox.pages) ? sandbox.pages : [];
}

function chooseStyle(text) {
  const lower = text.toLowerCase();
  if (/(datenbank|sql|server|netzwerk|schnittstelle|api|uml|klassendiagramm|prozess|architektur)/.test(lower)) {
    return "technische Zeichnung";
  }
  if (/(kunde|support|gespräch|auftraggeber|arbeitsplatz|alltag|team|benutzer|übergabe)/.test(lower)) {
    return "realistische Szene";
  }
  if (/(idee|planung|reflexion|vergleich|entscheidung|risiko|qualität)/.test(lower)) {
    return "didaktische Konzeptgrafik";
  }
  if (/(skizze|entwurf|wireframe|mockup|prototyp)/.test(lower)) {
    return "saubere Skizze";
  }
  return "fachliche Illustration";
}

function promptFor(block, index) {
  const style = chooseStyle(block.text);
  const title = block.text.split(/[.!?]/)[0].slice(0, 90);
  return {
    id: String(index + 1).padStart(2, "0"),
    title,
    style,
    filename: `${String(index + 1).padStart(2, "0")}_${filenameText(title)}.png`,
    prompt: [
      `Erstelle ein passendes 16:9-Bild, 1920×1080.`,
      `Stil: ${style}.`,
      `Thema: ${title}`,
      `Kontext: ${block.text}`,
      "Das Bild soll den Lerninhalt sichtbar machen und ohne lange Textflächen funktionieren."
    ].join("\n")
  };
}

function promptForDokutorialPage(page, index) {
  const situation = Array.isArray(page.situation) ? page.situation.join(" ") : "";
  const goal = Array.isArray(page.goal) ? page.goal.join(" ") : "";
  const context = `${situation} ${goal}`.trim();
  const style = chooseStyle(`${page.title} ${context}`);
  return {
    id: String(index + 1).padStart(2, "0"),
    title: page.title,
    placement: "linke Spalte, oberhalb oder zwischen Situation/Zielbild-Text",
    style,
    filename: `${String(index + 1).padStart(2, "0")}_${filenameText(page.title)}.png`,
    prompt: [
      "Erstelle ein passendes 16:9-Bild, 1920×1080.",
      `Stil: ${style}.`,
      `Thema: ${page.title}`,
      `Situation: ${situation}`,
      `Zielbild: ${goal}`,
      "Das Bild soll die Situation und das fachliche Ziel ohne lange Textflächen sichtbar machen."
    ].join("\n")
  };
}

function deduplicate(proposals) {
  const seen = new Set();
  return proposals.filter((proposal) => {
    const key = proposal.title.toLowerCase().replace(/[^a-z0-9äöüß]+/gi, " ").trim();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function main() {
  const args = parseArgs(process.argv);
  if (!args.html) {
    throw new Error("Usage: node propose-images.mjs --html uebung.html [--out proposals.json]");
  }

  const htmlPath = args.html;
  const html = fs.readFileSync(htmlPath, "utf8");
  const pages = extractDokutorialPages(html);
  const proposals = pages.length
    ? pages.map(promptForDokutorialPage).slice(0, Number(args.limit || 40))
    : deduplicate(extractBlocks(html).map(promptFor)).slice(0, Number(args.limit || 40));

  const payload = {
    source: path.resolve(htmlPath),
    mode: pages.length ? "dokutorial-pages" : "generic-html",
    count: proposals.length,
    proposals
  };

  if (args.out) {
    fs.mkdirSync(path.dirname(args.out), { recursive: true });
    fs.writeFileSync(args.out, JSON.stringify(payload, null, 2), "utf8");
  }
  console.log(JSON.stringify(payload, null, 2));
}

main();
