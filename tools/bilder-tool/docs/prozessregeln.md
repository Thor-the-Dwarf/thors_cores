# Prozessregeln

## Infografiken

1. Trockenlauf ausführen.
2. Prüfen: Gesamtzahl, nächster fehlender Job, kein `Tag*` im Prompt.
3. ChatGPT-Modus prüfen: nicht `Sofort`, nicht `Pro`.
4. Ein Testbild mit `--once` erzeugen.
5. Sichtprobe abwarten, dann erst die Serie laufen lassen.
6. Vorhandene Bilder niemals überschreiben, außer Thor verlangt es ausdrücklich.

## Verbotene Umwege

- keine lokale Bildgenerierung für Kursinfografiken
- keine Python-/HTML-/Canvas-Ersatzbilder
- keine nachträgliche Bildbearbeitung
- keine Experimente am stabilen Infografik-Workflow, wenn nur ein neuer Bildtyp gebraucht wird

## HTML-Kontextbilder

HTML-Kontextbilder sind eine eigene Workflow-Klasse.

Vorgehen:

1. HTML-Datei analysieren.
2. Bildstellen und Stilvorschläge erzeugen.
3. Vorschläge Thor zeigen.
4. Erst danach passende Web-Bildprompts erzeugen.

Mögliche Stile:

- realistische Szene
- technische Zeichnung
- saubere Skizze
- didaktische Konzeptgrafik
- fachliche Illustration

Diese Stilentscheidung wird pro Bildstelle aus dem Lernkontext abgeleitet, nicht pauschal.
