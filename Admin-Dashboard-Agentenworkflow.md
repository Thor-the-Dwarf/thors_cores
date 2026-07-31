# Lokale Aufgabennachweise

Für alle delegierten Aufgaben gibt es genau einen lokalen Nachweis-Wurzelordner:

```text
_erledigteToDos/
```

Der Ordner ist über `.gitignore` vollständig von Git ausgeschlossen. Seine Inhalte bleiben ausschließlich im lokalen Checkout.

## Ordner pro gestarteter Aufgabe

Beim Start einer Aufgabe legt der ausführende Agent einen eigenen Unterordner an. Dessen führende Archiv-ID ist der tatsächliche Startzeitpunkt mit Sekunden in einer eindeutig chronologisch sortierbaren und dateisicheren Form. Hinter einem doppelten Unterstrich folgt ein dateisicherer Titel-Slug zur visuellen Wiedererkennung:

```text
YYYY-MM-DD_HH-mm-ss__<titel-slug>
```

Beispiel für „To Do und Doing zusammenführen“, gestartet am 31. Juli 2026 um 09:05:17 Uhr:

```text
_erledigteToDos/2026-07-31_09-05-17__to-do-und-doing-zusammenfuehren/
```

Der Zeitstempel vor `__` bleibt die Identität und Sortierbasis des Archivs. Der Titel-Slug dient nur der Lesbarkeit. Dafür wird der Titel kleingeschrieben, Leerraum und Satzzeichen werden durch einzelne Bindestriche ersetzt und nur im technischen Slug werden `ä`, `ö`, `ü` und `ß` bei Bedarf zu `ae`, `oe`, `ue` und `ss` normalisiert.

Die sichtbare Kommunikationsbezeichnung wie „To Do 1“ wird in `task-note.txt` festgehalten, ist aber kein Bestandteil der Archiv-ID. Lokalisierte oder mehrdeutige Datumsformen wie `31.07.26` werden nicht in Ordnernamen verwendet.

## Mindestinhalt

```text
_erledigteToDos/2026-07-31_09-05-17__to-do-und-doing-zusammenfuehren/
├── task-note.txt
├── evidence.json
├── 00-ausgangszustand.png
└── 10-ergebnis.png
```

- `task-note.txt` nennt das zugewiesene To Do, Ziel und Grenzen. Während der Arbeit werden wichtige Entscheidungen ergänzt. Vor der Übergabe enthält die Datei Ergebnis, Prüfung und verbleibende Hinweise.
- `evidence.json` ist der kleine, explizite Bildindex für das Dashboard. Er liegt immer neben `task-note.txt` und enthält ausschließlich die Dateinamen und sichtbaren Beschriftungen der Nachweisbilder in diesem Aufgabenordner.
- `00-ausgangszustand.png` dokumentiert den Zustand vor der Änderung, sofern ein Vorherzustand relevant ist.
- Weitere Arbeits- oder Ergebnisscreenshots werden im selben Aufgabenordner gespeichert. Aussagekräftige, aufsteigend sortierbare Namen sind erwünscht.
- Mindestens ein Ergebnisscreenshot wird vor Abschluss oder Übergabe gespeichert.

Beispiel für `evidence.json`:

```json
{
  "schema_version": "1.0.0",
  "auftrag": "T-009",
  "bilder": [
    {
      "datei": "00-ausgangszustand.png",
      "label": "Ausgangszustand"
    },
    {
      "datei": "10-ergebnis.png",
      "label": "Geprüftes Ergebnis"
    }
  ]
}
```

Das Dashboard leitet den Aufgabenordner aus dem Startzeitpunkt und dem dateisicheren Titel-Slug ab. Falls ein bestehender Aufgabenordner davon abweicht, kann der Auftrag in `Admin-Dashboard-Aufträge.json` optional ein eindeutiges Feld `"nachweisordner": "YYYY-MM-DD_HH-mm-ss__titel-slug"` erhalten. Ohne erreichbaren Ordner oder gültigen Bildindex zeigt das Dashboard „Noch keine Nachweise“.

## Verbindlicher Ablauf

1. Agentenregeln und das zugewiesene To Do im Dashboard lesen.
2. Tatsächlichen Startzeitpunkt mit Sekunden festhalten, einen dateisicheren Titel-Slug bilden und den Aufgabenordner nach dem obigen Schema anlegen.
3. Die Kommunikationsbezeichnung und das zugewiesene To Do in `task-note.txt` festhalten, `evidence.json` anlegen sowie bei relevantem Vorherzustand den Ausgangsscreenshot speichern und im Bildindex eintragen.
4. Aufgabe durchführen, Nachweise im selben Ordner ergänzen und jeden sichtbaren Screenshot mit Dateiname und Beschriftung in `evidence.json` aufnehmen.
5. Ergebnis prüfen, Ergebnisscreenshot im Bildindex ergänzen und Abschluss beziehungsweise Übergabe in `task-note.txt` dokumentieren.
6. Erst danach die Aufgabe übergeben oder die Unterhaltung beenden.
