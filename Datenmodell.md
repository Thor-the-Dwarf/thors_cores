# Aktives Lern-Vault-Datenmodell

Die Laufzeitdaten sind nach dem Schema `3.0.0` auf fünf getrennt gepflegte Dateien verteilt:

- `Lernfelder.json`: Lernfelder und zugehörige Kompetenzen
- `Themen.json`: stabile Themencluster und Themen mit Elternreferenzen
- `Cores.json`: globale Core-Identitäten, Inhalte und gewichtete Kategorien
- `Core-Ausprägungen.json`: Einordnung eines globalen Cores in Lernfeld, Kompetenz, Themencluster und Thema einschließlich Tiefengrad
- `Quellen.json`: zentraler Quellenkatalog

Ein Core ist ein eigenständiges, benanntes und didaktisch sinnvolles fachliches Konzept. Seine globale Identität wird über `id` und `identity_key` stabil gehalten. Die `Core-Ausprägung` trägt den konkreten Lernkontext und den Tiefengrad `Grundlage`, `Vertiefung` oder `Spezialisierung`. Der aktuelle Lernfeld-1-Bestand verwendet durchgehend `Grundlage`.

Die Kategorien sind `IT` = Blau, `BWL` = Gelb und `Recht` = Rot. Gewichtete Anteile erzeugen Mischfarben; ihre Summe beträgt je Core `1`.

Vault-Verbindungen werden nicht als beliebige Kanten gespeichert. Sichtbare Core-Ausprägungen mit derselben `thema_ref` werden zur Laufzeit paarweise verbunden.

Aktueller validierter Umfang:

- 1 Lernfeld
- 4 Kompetenzen
- 11 Themencluster
- 33 Themen ohne leere Endknoten
- 117 globale Cores und 117 Core-Ausprägungen
- 8 auflösbare Quellen
- 157 abgeleitete Themenverbindungen

`index.html` lädt die fünf Dateien gemeinsam. Beim direkten Öffnen als `file://` verwendet die Seite einen in sich identischen eingebetteten Split-Datenstand, da Browser lokale JSON-Anfragen häufig blockieren.
