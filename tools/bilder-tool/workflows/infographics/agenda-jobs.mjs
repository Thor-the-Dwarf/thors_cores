import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export function filenameText(value) {
  return value
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/ß/g, "ss")
    .replace(/[^A-Za-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .replace(/_+/g, "_")
    .slice(0, 100);
}

export function cleanPromptText(value) {
  return value
    .replace(/^Tag\s*\d+\s*[-–—:]?\s*/i, "")
    .replace(/\bTag\s*\d+\b/gi, "")
    .replace(/\bTag\b/gi, "")
    .replace(/[\u0000-\u001F\u007F]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function sectionBullets(sectionBody) {
  return [...sectionBody.matchAll(/^(?:-\s+|\d+\.\s+)(.+)$/gm)].map((match) => cleanPromptText(match[1]));
}

function titleFromDayAgenda(text, agendaPath) {
  const folderDay = path.basename(path.dirname(agendaPath)).match(/^Tag\s*(\d+)$/i)?.[1];
  const heading = text.match(/^#\s+(.+)$/m)?.[1] || "";
  const dayNumber = (folderDay || heading.match(/\bTag\s*(\d+)\b/i)?.[1] || "00").padStart(2, "0");
  const dayTitle = cleanPromptText(heading)
    .replace(/^Agenda\s*[-–—:]?\s*/i, "")
    .trim();
  return { dayNumber, dayTitle };
}

function buildSectionAgendaJobs({ agendaPath }) {
  const text = fs.readFileSync(agendaPath, "utf8");
  const { dayNumber, dayTitle } = titleFromDayAgenda(text, agendaPath);
  const dayDir = path.dirname(agendaPath);
  const sectionMatches = [...text.matchAll(/^## Abschnitt\s+(\d+)\s*[-–—]\s*(.+)$/gm)];
  const jobs = [];

  for (let sectionIndex = 0; sectionIndex < sectionMatches.length; sectionIndex++) {
    const section = sectionMatches[sectionIndex];
    const presiNumber = String(section[1]).padStart(2, "0");
    const sectionTitle = cleanPromptText(section[2]);
    const sectionStart = section.index + section[0].length;
    const sectionEnd = sectionMatches[sectionIndex + 1]?.index ?? text.length;
    const sectionBody = text.slice(sectionStart, sectionEnd).trim();
    const goal = sectionBody.match(/^Ziel:\s*(.+)$/m)?.[1];
    const topicMatches = [...sectionBody.matchAll(/^###\s+(.+)$/gm)];
    const targetDir = path.join(dayDir, "Presi_Bilder", presiNumber);
    const overviewLines = [dayTitle, sectionTitle];
    if (goal) overviewLines.push(`Ziel: ${cleanPromptText(goal)}`);

    for (let topicIndex = 0; topicIndex < topicMatches.length; topicIndex++) {
      const topic = topicMatches[topicIndex];
      const topicTitle = cleanPromptText(topic[1]);
      const topicStart = topic.index + topic[0].length;
      const topicEnd = topicMatches[topicIndex + 1]?.index ?? sectionBody.length;
      const bullets = sectionBullets(sectionBody.slice(topicStart, topicEnd));
      overviewLines.push("", topicTitle, ...bullets.map((bullet) => `- ${bullet}`));
    }

    jobs.push({
      id: `${dayNumber}_${presiNumber}_00`,
      title: sectionTitle,
      prompt: `Erstelle eine Infografik im 16:9-Format, 1920×1080 zu diesen Themen:\n${overviewLines.join("\n").trim()}`,
      target: path.join(targetDir, `${dayNumber}_${presiNumber}_00_${filenameText(sectionTitle)}.png`)
    });

    for (let topicIndex = 0; topicIndex < topicMatches.length; topicIndex++) {
      const topic = topicMatches[topicIndex];
      const topicNumber = String(topicIndex + 1).padStart(2, "0");
      const topicTitle = cleanPromptText(topic[1]);
      const topicStart = topic.index + topic[0].length;
      const topicEnd = topicMatches[topicIndex + 1]?.index ?? sectionBody.length;
      const bullets = sectionBullets(sectionBody.slice(topicStart, topicEnd));

      jobs.push({
        id: `${dayNumber}_${presiNumber}_${topicNumber}`,
        title: topicTitle,
        prompt: `Erstelle eine Infografik im 16:9-Format, 1920×1080 zu diesen Themen:\n${[dayTitle, sectionTitle, topicTitle, ...bullets.map((bullet) => `- ${bullet}`)].join("\n")}`,
        target: path.join(targetDir, `${dayNumber}_${presiNumber}_${topicNumber}_${filenameText(topicTitle)}.png`)
      });
    }
  }

  return jobs;
}

export function buildAgendaJobs({ agendaPath, sourceRoot }) {
  const text = fs.readFileSync(agendaPath, "utf8");
  const dayMatches = [...text.matchAll(/^## Tag\s*(\d+)\s*[-–—]\s*(.+)$/gm)];
  if (!dayMatches.length) return buildSectionAgendaJobs({ agendaPath });
  const jobs = [];

  for (let dayIndex = 0; dayIndex < dayMatches.length; dayIndex++) {
    const day = dayMatches[dayIndex];
    const dayNumber = day[1].padStart(2, "0");
    const dayTitle = cleanPromptText(day[2]);
    const dayStart = day.index + day[0].length;
    const dayEnd = dayMatches[dayIndex + 1]?.index ?? text.length;
    const dayBody = text.slice(dayStart, dayEnd).trim();
    const sectionMatches = [...dayBody.matchAll(/^###\s+(.+)$/gm)];
    const targetDir = path.join(sourceRoot, `Tag${dayNumber}`, "Presi_Bilder", "01");

    const overviewLines = [dayTitle];
    const goal = dayBody.match(/^Ziel:\s*(.+)$/m)?.[1];
    if (goal) overviewLines.push(`Ziel: ${cleanPromptText(goal)}`);

    for (let sectionIndex = 0; sectionIndex < sectionMatches.length; sectionIndex++) {
      const section = sectionMatches[sectionIndex];
      const sectionTitle = cleanPromptText(section[1]);
      const sectionStart = section.index + section[0].length;
      const sectionEnd = sectionMatches[sectionIndex + 1]?.index ?? dayBody.length;
      const bullets = sectionBullets(dayBody.slice(sectionStart, sectionEnd));
      overviewLines.push("", sectionTitle, ...bullets.map((bullet) => `- ${bullet}`));
    }

    jobs.push({
      id: `${dayNumber}_00_00`,
      title: dayTitle,
      prompt: `Erstelle eine Infografik im 16:9-Format, 1920×1080 zu diesen Themen:\n${overviewLines.join("\n").trim()}`,
      target: path.join(targetDir, `${dayNumber}_00_00_${filenameText(dayTitle)}.png`)
    });

    for (let sectionIndex = 0; sectionIndex < sectionMatches.length; sectionIndex++) {
      const section = sectionMatches[sectionIndex];
      const sectionNumber = String(sectionIndex + 1).padStart(2, "0");
      const sectionTitle = cleanPromptText(section[1]);
      const sectionStart = section.index + section[0].length;
      const sectionEnd = sectionMatches[sectionIndex + 1]?.index ?? dayBody.length;
      const bullets = sectionBullets(dayBody.slice(sectionStart, sectionEnd));

      jobs.push({
        id: `${dayNumber}_${sectionNumber}_00`,
        title: sectionTitle,
        prompt: `Erstelle eine Infografik im 16:9-Format, 1920×1080 zu diesen Themen:\n${[sectionTitle, ...bullets.map((bullet) => `- ${bullet}`)].join("\n")}`,
        target: path.join(targetDir, `${dayNumber}_${sectionNumber}_00_${filenameText(sectionTitle)}.png`)
      });

      for (let bulletIndex = 0; bulletIndex < bullets.length; bulletIndex++) {
        const bullet = bullets[bulletIndex];
        const bulletNumber = String(bulletIndex + 1).padStart(2, "0");
        jobs.push({
          id: `${dayNumber}_${sectionNumber}_${bulletNumber}`,
          title: bullet,
          prompt: `Erstelle eine Infografik im 16:9-Format, 1920×1080 zu diesen Themen:\n${[dayTitle, sectionTitle, bullet].join("\n")}`,
          target: path.join(targetDir, `${dayNumber}_${sectionNumber}_${bulletNumber}_${filenameText(bullet)}.png`)
        });
      }
    }
  }

  return jobs;
}

export function assertCleanPrompts(jobs) {
  const bad = jobs.filter((job) => /\bTag\s*\d*\b/i.test(job.prompt));
  if (bad.length) {
    throw new Error(`Prompts enthalten Tag-Text: ${bad.map((job) => job.id).join(", ")}`);
  }
}

export function targetExists(target) {
  try {
    fs.lstatSync(target);
    return true;
  } catch {}

  const dir = path.dirname(target);
  try {
    const wanted = path.basename(target).normalize("NFC");
    return fs.readdirSync(dir).some((name) => name.normalize("NFC") === wanted);
  } catch {
    return false;
  }
}

export function existingCount(jobs) {
  return jobs.filter((job) => targetExists(job.target)).length;
}

export function nextMissingJob(jobs) {
  return jobs.find((job) => !targetExists(job.target));
}

export function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    const item = argv[i];
    if (!item.startsWith("--")) continue;
    const key = item.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith("--")) {
      args[key] = true;
    } else {
      args[key] = next;
      i++;
    }
  }
  return args;
}

if (typeof process !== "undefined" && process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1])) {
  const args = parseArgs(process.argv);
  if (!args.agenda || !args["source-root"]) {
    throw new Error("Usage: node agenda-jobs.mjs --agenda Agenda.md --source-root _sources [--next]");
  }
  const jobs = buildAgendaJobs({
    agendaPath: path.resolve(args.agenda),
    sourceRoot: path.resolve(args["source-root"])
  });
  assertCleanPrompts(jobs);
  const payload = args.next ? nextMissingJob(jobs) : jobs;
  console.log(JSON.stringify(payload, null, 2));
}
