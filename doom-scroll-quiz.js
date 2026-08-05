(() => {
  "use strict";

  const daten = window.DOOM_SCHOOL_QUIZ_DATEN;
  const feed = document.querySelector("#feed");
  const kartenSpur = document.querySelector("#karten-spur");
  const fortschritt = document.querySelector("#fortschritt");
  const punktestand = document.querySelector("#punktestand");
  const poolInfo = document.querySelector("#pool-info");
  const quellenInfo = document.querySelector("#quellen-info");
  const vorherige = document.querySelector("#vorherige");
  const prüfen = document.querySelector("#prüfen");
  const nächste = document.querySelector("#nächste");

  if (!daten?.tasks?.length) {
    poolInfo.textContent = "Quiz-Pool nicht verfügbar";
    kartenSpur.innerHTML = '<section class="quiz-karte"><div class="aufgabe"><h1>Die Übungen konnten nicht geladen werden.</h1><p class="hinweis">Bitte öffne die Seite erneut über den lokalen Webserver.</p></div></section>';
    [vorherige, prüfen, nächste].forEach(button => button.disabled = true);
    return;
  }

  const quellen = new Map(daten.sources.map(source => [source.id, source]));
  const antworten = new Map();
  const ausgewählteThemen = new Set(new URLSearchParams(location.search).getAll("thema"));
  const typNamen = {
    choice: "Auswahl",
    match: "Zuordnung",
    cloze: "Lückentext",
    order: "Reihenfolge"
  };
  let aktiv = 0;
  let richtigeAntworten = 0;
  let zug = null;

  function mischen(liste) {
    const kopie = [...liste];
    for (let index = kopie.length - 1; index > 0; index -= 1) {
      const tauschIndex = Math.floor(Math.random() * (index + 1));
      [kopie[index], kopie[tauschIndex]] = [kopie[tauschIndex], kopie[index]];
    }
    return kopie;
  }

  function optionNormalisieren(option, index, taskId) {
    return Array.isArray(option)
      ? { id: `${taskId}.o${index}`, text: option[0], correct: Boolean(option[1]), feedback: option[2] || "" }
      : { id: `${taskId}.o${index}`, text: option.text, correct: Boolean(option.correct), feedback: option.feedback || option.explain || "" };
  }

  function zeileNormalisieren(row, index, taskId) {
    return Array.isArray(row)
      ? { id: `${taskId}.r${index}`, label: row[0], correct: row[1], feedback: row[2] || "" }
      : { id: `${taskId}.r${index}`, label: row.label || row.prompt || "", correct: row.correct || row.answer || "", feedback: row.feedback || row.explain || "" };
  }

  function aufgabeNormalisieren(task) {
    const normalisiert = { ...task };
    if (task.kind === "choice") {
      normalisiert.options = mischen(task.options.map((option, index) => optionNormalisieren(option, index, task.id)));
    } else if (task.kind === "match") {
      normalisiert.rows = task.rows.map((row, index) => zeileNormalisieren(row, index, task.id));
      normalisiert.choices = mischen(task.choices || normalisiert.rows.map(row => row.correct));
    } else if (task.kind === "cloze") {
      let blankIndex = 0;
      normalisiert.parts = task.parts.map(part => {
        if (!Array.isArray(part)) return part;
        return { id: `${task.id}.c${blankIndex++}`, correct: part[0], feedback: part[1] || "" };
      });
      const lösungen = normalisiert.parts.filter(part => typeof part !== "string").map(part => part.correct);
      normalisiert.words = mischen([...new Set([...(task.words || []), ...lösungen])]);
    } else if (task.kind === "order") {
      const reihenfolge = task.correctOrder || task.items.map((_, index) => index);
      const positionen = new Map(reihenfolge.map((quellIndex, position) => [quellIndex, position + 1]));
      normalisiert.items = mischen(task.items.map((item, index) => ({
        id: `${task.id}.i${index}`,
        text: Array.isArray(item) ? item[0] : (typeof item === "object" ? item.text : item),
        feedback: Array.isArray(item) ? (item[1] || "") : (typeof item === "object" ? (item.feedback || item.explain || "") : ""),
        correctPos: positionen.get(index)
      })));
    }
    return normalisiert;
  }

  const gefilterteAufgaben = ausgewählteThemen.size
    ? daten.tasks.filter(task => task.themaIds.some(themaId => ausgewählteThemen.has(themaId)))
    : daten.tasks;
  const filterFallback = ausgewählteThemen.size > 0 && gefilterteAufgaben.length === 0;
  const basisAufgaben = filterFallback ? daten.tasks : gefilterteAufgaben;
  let aufgaben = mischen(basisAufgaben).map(aufgabeNormalisieren);

  function antwortFür(task) {
    if (!antworten.has(task.id)) {
      const grundzustand = task.kind === "choice"
        ? { selected: new Set(), checked: false, correct: false }
        : task.kind === "order"
          ? { order: task.items.map(item => item.id), checked: false, correct: false }
          : { values: {}, checked: false, correct: false };
      antworten.set(task.id, grundzustand);
    }
    return antworten.get(task.id);
  }

  function element(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
  }

  function auswahlRendern(task, answer) {
    const container = element("div", "antworten");
    container.setAttribute("aria-label", task.type === "single" ? "Eine Antwort auswählen" : "Alle richtigen Antworten auswählen");
    task.options.forEach(option => {
      const button = element("button", "antwort");
      button.type = "button";
      button.disabled = answer.checked;
      button.setAttribute("aria-pressed", String(answer.selected.has(option.id)));
      if (answer.selected.has(option.id)) button.classList.add("ausgewählt");
      if (answer.checked && option.correct) button.classList.add("richtig");
      if (answer.checked && answer.selected.has(option.id) && !option.correct) button.classList.add("falsch");
      button.append(element("span", "marke"), element("span", "antwort-text", option.text));
      button.addEventListener("click", () => {
        if (task.type === "single") answer.selected.clear();
        if (answer.selected.has(option.id) && task.type !== "single") answer.selected.delete(option.id);
        else answer.selected.add(option.id);
        karteRendern();
      });
      container.append(button);
    });
    return container;
  }

  function auswahlErstellen(choices, value, label, disabled, onChange) {
    const select = element("select");
    select.setAttribute("aria-label", label);
    select.disabled = disabled;
    const placeholder = element("option", "", "Bitte auswählen");
    placeholder.value = "";
    select.append(placeholder);
    choices.forEach(choice => {
      const option = element("option", "", choice);
      option.value = choice;
      option.selected = choice === value;
      select.append(option);
    });
    select.addEventListener("change", () => onChange(select.value));
    return select;
  }

  function zuordnungRendern(task, answer) {
    const container = element("div", "zuordnungsliste");
    task.rows.forEach(row => {
      const zeile = element("div", "zuordnungszeile");
      if (answer.checked) zeile.classList.add(answer.values[row.id] === row.correct ? "richtig" : "falsch");
      zeile.append(
        element("strong", "", row.label),
        auswahlErstellen(task.choices, answer.values[row.id], `${row.label} zuordnen`, answer.checked, value => {
          answer.values[row.id] = value;
          prüfenStatusAktualisieren();
        })
      );
      container.append(zeile);
    });
    return container;
  }

  function lückentextRendern(task, answer) {
    const container = element("div", "lückentext");
    const satz = element("div", "lückentext-satz");
    task.parts.forEach(part => {
      if (typeof part === "string") {
        satz.append(document.createTextNode(part));
        return;
      }
      const select = auswahlErstellen(task.words, answer.values[part.id], "Lücke ergänzen", answer.checked, value => {
        answer.values[part.id] = value;
        prüfenStatusAktualisieren();
      });
      if (answer.checked) select.classList.add(answer.values[part.id] === part.correct ? "richtig" : "falsch");
      satz.append(select);
    });
    container.append(satz);
    return container;
  }

  function reihenfolgeRendern(task, answer) {
    const container = element("div", "sortierliste");
    const items = answer.order.map(id => task.items.find(item => item.id === id));
    items.forEach((item, index) => {
      const zeile = element("div", "sortierzeile");
      if (answer.checked) zeile.classList.add(item.correctPos === index + 1 ? "richtig" : "falsch");
      const hoch = element("button", "", "↑");
      const runter = element("button", "", "↓");
      hoch.type = runter.type = "button";
      hoch.disabled = answer.checked || index === 0;
      runter.disabled = answer.checked || index === items.length - 1;
      hoch.setAttribute("aria-label", `${item.text} nach oben`);
      runter.setAttribute("aria-label", `${item.text} nach unten`);
      hoch.addEventListener("click", () => reihenfolgeVerschieben(answer, index, index - 1));
      runter.addEventListener("click", () => reihenfolgeVerschieben(answer, index, index + 1));
      zeile.append(element("span", "griff", "⋮⋮"), element("strong", "", item.text), hoch, runter);
      container.append(zeile);
    });
    return container;
  }

  function reihenfolgeVerschieben(answer, von, zu) {
    [answer.order[von], answer.order[zu]] = [answer.order[zu], answer.order[von]];
    karteRendern();
  }

  function feedbackText(task, answer) {
    if (!answer.checked) return "";
    if (answer.correct) return "Richtig beantwortet. Stark – weiter zur nächsten Aufgabe.";
    const feedback = [];
    if (task.kind === "choice") {
      task.options.filter(option => option.correct || answer.selected.has(option.id)).forEach(option => {
        if (option.feedback) feedback.push(option.feedback);
      });
    } else if (task.kind === "match") {
      task.rows.filter(row => answer.values[row.id] !== row.correct).forEach(row => {
        feedback.push(`${row.label}: ${row.correct}. ${row.feedback}`.trim());
      });
    } else if (task.kind === "cloze") {
      task.parts.filter(part => typeof part !== "string" && answer.values[part.id] !== part.correct).forEach(part => {
        feedback.push(`Musterlösung: ${part.correct}. ${part.feedback}`.trim());
      });
    } else {
      feedback.push("Die farblich markierten Positionen zeigen dir, welche Schritte bereits richtig stehen.");
    }
    return `Noch nicht ganz. ${feedback.slice(0, 3).join(" ")}`;
  }

  function karteRendern() {
    const task = aufgaben[aktiv];
    const answer = antwortFür(task);
    const karte = element("section", "quiz-karte");
    const aufgabe = element("div", "aufgabe");
    const tag = element("div", "tag", `${typNamen[task.kind] || task.kind} · ${task.tag || task.sourceTitle}`);
    const frage = element("h1", "", task.question);
    const hinweisText = task.kind === "choice"
      ? (task.type === "single" ? "Wähle genau eine Antwort." : "Wähle alle richtigen Antworten.")
      : task.kind === "match"
        ? "Ordne jeder Aussage den passenden Begriff zu."
        : task.kind === "cloze"
          ? "Ergänze alle Lücken mit den passenden Begriffen."
          : "Bringe die Bausteine mit den Pfeilen in die richtige Reihenfolge.";
    const hinweis = element("p", "hinweis", hinweisText);
    const eingabe = task.kind === "choice"
      ? auswahlRendern(task, answer)
      : task.kind === "match"
        ? zuordnungRendern(task, answer)
        : task.kind === "cloze"
          ? lückentextRendern(task, answer)
          : reihenfolgeRendern(task, answer);
    const feedback = element("div", `leerstand${answer.checked ? (answer.correct ? " erfolg" : " fehler") : ""}`, feedbackText(task, answer));
    feedback.setAttribute("role", "status");
    const source = quellen.get(task.sourceId);
    const quelle = element("div", "quelle", `Quelle: ${source?.provider || "Träger"} · ${task.sourceTitle}`);
    aufgabe.append(tag, frage, hinweis, eingabe, feedback, quelle);
    karte.append(aufgabe);
    kartenSpur.replaceChildren(karte);
    prüfen.textContent = answer.checked ? (aktiv === aufgaben.length - 1 ? "Neu mischen" : "Nächste Aufgabe") : "Prüfen";
    vorherige.disabled = aktiv === 0;
    nächste.disabled = aktiv === aufgaben.length - 1;
    fortschritt.textContent = `${aktiv + 1} / ${aufgaben.length.toLocaleString("de-DE")}`;
    punktestand.textContent = `${richtigeAntworten} richtig`;
    prüfenStatusAktualisieren();
  }

  function vollständig(task, answer) {
    if (task.kind === "choice") return answer.selected.size > 0;
    if (task.kind === "match") return task.rows.every(row => answer.values[row.id]);
    if (task.kind === "cloze") return task.parts.filter(part => typeof part !== "string").every(part => answer.values[part.id]);
    return true;
  }

  function prüfenStatusAktualisieren() {
    const task = aufgaben[aktiv];
    const answer = antwortFür(task);
    prüfen.disabled = !answer.checked && !vollständig(task, answer);
  }

  function bewerten(task, answer) {
    if (task.kind === "choice") {
      return task.options.every(option => answer.selected.has(option.id) === option.correct);
    }
    if (task.kind === "match") return task.rows.every(row => answer.values[row.id] === row.correct);
    if (task.kind === "cloze") return task.parts.filter(part => typeof part !== "string").every(part => answer.values[part.id] === part.correct);
    return answer.order.every((id, index) => task.items.find(item => item.id === id).correctPos === index + 1);
  }

  function karteAnzeigen(index, fokus = false) {
    aktiv = Math.max(0, Math.min(aufgaben.length - 1, index));
    karteRendern();
    if (fokus) prüfen.focus({ preventScroll: true });
  }

  function neuMischen() {
    aufgaben = mischen(basisAufgaben).map(aufgabeNormalisieren);
    antworten.clear();
    richtigeAntworten = 0;
    karteAnzeigen(0, true);
  }

  prüfen.addEventListener("click", () => {
    const task = aufgaben[aktiv];
    const answer = antwortFür(task);
    if (answer.checked) {
      if (aktiv === aufgaben.length - 1) neuMischen();
      else karteAnzeigen(aktiv + 1, true);
      return;
    }
    if (!vollständig(task, answer)) return;
    answer.correct = bewerten(task, answer);
    answer.checked = true;
    if (answer.correct) richtigeAntworten += 1;
    karteRendern();
  });

  vorherige.addEventListener("click", () => karteAnzeigen(aktiv - 1, true));
  nächste.addEventListener("click", () => karteAnzeigen(aktiv + 1, true));

  feed.addEventListener("pointerdown", event => {
    if (!event.isPrimary || event.button !== 0 || event.target.closest("button, input, label, select, textarea")) return;
    zug = { id: event.pointerId, x: event.clientX, y: event.clientY };
  });
  feed.addEventListener("pointerup", event => {
    if (!zug || zug.id !== event.pointerId) return;
    const deltaX = event.clientX - zug.x;
    const deltaY = event.clientY - zug.y;
    zug = null;
    if (Math.abs(deltaX) < 80 || Math.abs(deltaX) <= Math.abs(deltaY)) return;
    karteAnzeigen(aktiv + (deltaX < 0 ? 1 : -1));
  });
  feed.addEventListener("pointercancel", () => zug = null);

  document.addEventListener("keydown", event => {
    if (event.defaultPrevented || event.altKey || event.ctrlKey || event.metaKey || event.target.matches("input, textarea, select")) return;
    if (event.key === "ArrowLeft" && !vorherige.disabled) karteAnzeigen(aktiv - 1, true);
    else if (event.key === "ArrowRight" && !nächste.disabled) karteAnzeigen(aktiv + 1, true);
  });

  poolInfo.textContent = `${aufgaben.length.toLocaleString("de-DE")} Aufgaben im Quiz`;
  quellenInfo.textContent = filterFallback
    ? `Keine direkte Themenzuordnung gefunden · Gesamtpool aus ${daten.sourceFileCount} Übungen`
    : ausgewählteThemen.size
      ? `${ausgewählteThemen.size} ${ausgewählteThemen.size === 1 ? "gewähltes Thema" : "gewählte Themen"} · ${daten.sourceFileCount} Übungen durchsucht`
      : `${daten.sourceFileCount} aktive Übungen · zufällig gemischt`;
  karteAnzeigen(0);
})();
