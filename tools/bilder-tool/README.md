# Bilder-Tool im Projekt

Diese Windows-taugliche Toolkopie steuert einen bereits geöffneten und angemeldeten ChatGPT-Tab über die lokale Chrome-DevTools-Schnittstelle. Sie erzeugt keine Bilder lokal und umgeht den ChatGPT-Browser nicht. Der interne Quellworkflow bleibt unverändert.

## Enthalten

- `core/devtools.mjs`: Browserkern für Tab-Erkennung, Prompt, Versand, Bild-Erkennung und unverändertes Speichern des Rohbilds
- `workflows/infographics/`: stabiler Agenda-Infografik-Workflow samt Argumentparser
- `workflows/html-context-images/propose-images.mjs`: vorhandener, rein lokaler Vorschlagslauf für Bildstellen in HTML-Dateien; erzeugt keine Bilder
- `docs/prozessregeln.md`: verbindliche Prozess- und Sicherheitsregeln
- `bilder-tool.cmd`: Windows-Start für Chrome, Prüfung, Trockenlauf, Einzelbild und Serie

Nicht übernommen wurden Archive, Bilder, Cachedateien, erzeugte Vorschlags-JSONs und der koordinatenabhängige Diagnosehelfer des Masters.

## Voraussetzungen auf dem Windows-PC

1. Lese- und Schreibzugriff auf dieses Projekt sowie die gewünschten Zielordner über dieselbe SMB-Freigabe; für robuste Windows-Pfade die Freigabe am besten als Netzlaufwerk verbinden.
2. Eine aktuelle Node.js-LTS-Version. Das Tool benötigt die globalen Web-APIs `fetch` und `WebSocket`; empfohlen ist Node.js 24 LTS oder neuer.
3. Google Chrome. Seit Chrome 136 funktioniert `--remote-debugging-port` nicht mehr mit dem Standardprofil; deshalb startet das Skript ein separates lokales Profil unter `%LocalAppData%\Thors-Cores-Bilder-Tool\ChromeProfile`.
4. Im separaten Chrome-Profil bei ChatGPT anmelden und den gewünschten Chat öffnen. Login, Cookies und Profildaten bleiben lokal auf dem Windows-PC und werden nicht im Projekt gespeichert.
5. Node.js, Chrome und der ChatGPT-Tab müssen auf demselben Windows-PC laufen. Der Windows-PC benötigt außerdem Internetzugriff auf ChatGPT sowie Netzwerkzugriff auf Agenda und Quellordner. Der DevTools-Port bleibt lokal auf `127.0.0.1`; er soll nicht im Netzwerk freigegeben werden. Die Windows-Kopie steuert keinen Chrome-Tab auf dem Mac.

Das Projekt enthält keine Zugangsdaten, Tokens oder Passwörter und installiert keine Pakete.

## Windows-Schnellstart

Eingabeaufforderung im Ordner `tools\bilder-tool` öffnen. Das Skript funktioniert auch von einer UNC-Freigabe, weil es den Toolordner mit `pushd` temporär als Laufwerk einbindet.

### 1. Chrome mit lokalem DevTools-Profil starten

```bat
bilder-tool.cmd start-chrome
```

Danach im geöffneten Chrome-Fenster bei ChatGPT anmelden und den vorgesehenen Chat öffnen. Für einen abweichenden Port beispielsweise `bilder-tool.cmd start-chrome 9333` verwenden.

### 2. Umgebung prüfen

```bat
bilder-tool.cmd check
```

Die Prüfung führt Node-Syntaxchecks aus und liest anschließend nur die lokale DevTools-Tabliste. Sie setzt keinen Prompt ein und schreibt kein Bild.

### 3. Trockenlauf

```bat
bilder-tool.cmd dry-run "Z:\Kurs\Agenda.md" "Z:\Kurs\_sources"
```

Der Trockenlauf liest die Agenda, baut die Jobliste und meldet `total`, `done`, `remaining` und `next`. Er verbindet sich nicht mit ChatGPT und schreibt keine Datei.

### 4. Genau ein Testbild

```bat
bilder-tool.cmd once "Z:\Kurs\Agenda.md" "Z:\Kurs\_sources" "https://chatgpt.com/c/CHAT-ID"
```

Vorher den Modus im ChatGPT-Tab prüfen: `Sofort` und `Pro` werden vom Runner abgebrochen. Das Bild wird nur gespeichert, wenn die Zieldatei noch nicht existiert; Duplikate im Quellordner werden abgewiesen.

### 5. Serie nach Sichtprüfung

```bat
bilder-tool.cmd run "Z:\Kurs\Agenda.md" "Z:\Kurs\_sources" "https://chatgpt.com/c/CHAT-ID"
```

Den Serienlauf erst nach Sichtprüfung des Einzelbildes starten. Vorhandene Dateien werden übersprungen und nicht überschrieben.

### HTML-Bildvorschläge ohne Bildproduktion

```bat
bilder-tool.cmd propose-html "Z:\Kurs\uebung.html" "Z:\Kurs\bildvorschlaege.json"
```

Dieser vorhandene Nebenworkflow analysiert HTML und schreibt nur Vorschläge. Er steuert Chrome nicht und produziert keine Bilder.

## Unterstützte Agendaformate und Ausgabe

Der Runner kennt genau die im Master vorhandenen Agendaformate:

- Kursagenda mit Überschriften `## Tag N – Titel`, darunter `### Abschnitt` und Listenpunkte. Ausgabe: `<source-root>\TagNN\Presi_Bilder\01\...png`.
- Tagesagenda, deren Datei in einem Ordner `Tag N` liegt, mit `## Abschnitt N – Titel` und darunter `### Thema`. Ausgabe: neben der Agenda unter `Presi_Bilder\NN\...png`.

Prompts mit `Tag`-Text werden aus Sicherheitsgründen abgebrochen.

## Bekannte Grenze: keine Core-Infografiken

Im untersuchten Master ist kein Core-Infografikformat und kein Adapter für die Core-/Vault-Daten von Thors Cores vorhanden. Der Runner versteht ausschließlich die beiden Agenda-Strukturen oben. Diese Kopie ergänzt deshalb keinen neuen Core-Workflow und liest oder ändert keine App-, Vault- oder Core-Daten.

## Direkter Node-Aufruf

Die Skripte können bei Bedarf ohne `.cmd` gestartet werden:

```bat
node workflows\infographics\run-infographics.mjs --agenda "Z:\Kurs\Agenda.md" --source-root "Z:\Kurs\_sources" --dry-run
```

Weitere optionale Runner-Argumente aus dem Master bleiben verfügbar, darunter `--port`, `--skip`, `--keep-going`, `--fresh-every`, `--image-timeout-ms`, `--idle-before-prompt-timeout-ms` und `--idle-after-save-timeout-ms`.

## Sicherheitsregeln

Die vollständigen Regeln stehen in `docs\prozessregeln.md`. Wesentlich sind: zuerst Trockenlauf, dann genau ein Testbild, Sichtprüfung, erst danach Serie; keine lokalen Ersatzbilder und keine Überschreibung vorhandener Bilder.

## Referenzen

- Chrome DevTools: <https://developer.chrome.com/docs/devtools/agents/get-started/configuration>
- Chrome-Änderung ab Version 136: <https://developer.chrome.com/blog/remote-debugging-port?hl=de>
- Node.js: <https://nodejs.org/en/download>
