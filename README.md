# TheRealDeal

TheRealDeal ist ein lokaler Lern-Vault für Lernfeld 1. Die Startseite zeigt den
Folder Tree und den navigierbaren Core-Graphen. Das Doom Scroll Quiz ist aktuell
ein bewusst fachfreier UI-Dummy.

## Lokal ansehen

Die Seite funktioniert direkt per Doppelklick auf `index.html`. In diesem Fall
verwendet sie die eingebettete Kopie der fünf Datendateien.

Für die vollständige Prüfung der aktiven JSON-Dateien empfiehlt sich ein lokaler
HTTP-Server:

```bash
python3 -m http.server 8000
```

Danach im Browser öffnen:

```text
http://localhost:8000/
```

Die Navigation zur Quiz-Seite und zurück erfolgt über relative Pfade und
funktioniert deshalb lokal und unter GitHub Pages.

## Aktive Datendateien

- `Lernfelder.json`: Lernfelder und Kompetenzen
- `Themen.json`: Themencluster und Themen
- `Cores.json`: globale, gleichwertige Core-Identitäten, Fachfarben, fachliche
  Einordnungen und Quellenbelege
- `Core-Ausprägungen.json`: LF-Kontext, Tiefengrad und Quellenbezüge
- `Quellen.json`: normalisierter Quellenkatalog

Alle Cores werden im Vault gleichwertig dargestellt. Das aktive Datenmodell
kennt keine Trennung in Kern- und Ergänzungs-Cores.

Der Ordner `Archiv/` bleibt zur Nachvollziehbarkeit im Projekt, wird aber vom
Pages-Workflow ausdrücklich nicht in die öffentliche Website übernommen.
PlantUML- und PNG-Dateien werden ebenfalls nicht veröffentlicht.

## Später über GitHub Pages veröffentlichen

1. Für `TheRealDeal` ein eigenes Git-Repository anlegen oder den Ordner als
   eigenständiges Repository auf GitHub übertragen.
2. Den Standardbranch `main` verwenden.
3. In GitHub unter **Settings → Pages → Build and deployment** als Quelle
   **GitHub Actions** auswählen.
4. Die Dateien auf `main` pushen oder den Workflow
   **TheRealDeal über GitHub Pages bereitstellen** manuell starten.
5. Nach erfolgreichem Lauf ist die von GitHub angezeigte Pages-Adresse auch vom
   Smartphone erreichbar.

Der Workflow veröffentlicht ausschließlich die beiden HTML-Seiten, die fünf
aktiven JSON-Dateien und `.nojekyll`. Er enthält keine Zugangsdaten und nimmt
keine Änderungen an Remotes oder Repository-Einstellungen vor.
