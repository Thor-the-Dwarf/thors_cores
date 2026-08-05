# Aktives Lern-Vault-Datenmodell

Die Laufzeitdaten sind nach dem Schema `3.0.0` auf fünf getrennt gepflegte Dateien verteilt:

- `Lernfelder.json`: Lernfelder und zugehörige Kompetenzen
- `Themen.json`: stabile Themencluster und Themen mit Elternreferenzen
- `Cores.json`: globale Core-Identitäten, Inhalte und gewichtete Kategorien
- `Core-Ausprägungen.json`: Einordnung eines globalen Cores in Lernfeld, Kompetenz, Themencluster und Thema einschließlich Tiefengrad
- `Quellen.json`: zentraler Quellenkatalog

`Themen.json` enthält zusätzlich die rückblickende Prüfungsanalyse des
IT-Berufe-Podcasts. Jeder Eintrag ist entweder genau einem vorhandenen Thema
als `lerninhalt_ref` oder einem beziehungsweise mehreren konkreten
Arbeitsergebnissen als `artefakt_refs` zugeordnet. Diese Markierung verändert
weder die offizielle Lernfeldstruktur noch die Gleichwertigkeit der Cores.

Ein Core ist ein eigenständiges, benanntes und didaktisch sinnvolles fachliches Konzept. Seine globale Identität wird über `id` und `identity_key` stabil gehalten. Die `Core-Ausprägung` trägt den konkreten Lernkontext und den Tiefengrad `Grundlage`, `Vertiefung` oder `Spezialisierung`.

- `Grundlage`: gemeinsamer Unterricht im ersten Ausbildungsjahr, LF1 bis LF5
- `Vertiefung`: gemeinsamer Unterricht im zweiten Ausbildungsjahr, LF6 bis LF9
- `Spezialisierung`: fachrichtungsspezifischer Unterricht im dritten Ausbildungsjahr, LF10a bis LF12d

Wiederkehrende Begriffe werden als globale Core-Identität wiederverwendet und erhalten pro Lernfeld eine eigene `Core-Ausprägung`. Das betrifft insbesondere das in LF11b und LF11d identische Kompetenzprofil zur Sicherheit vernetzter Systeme. Fachrichtungsspezifische Projektausprägungen in LF12a bis LF12d bleiben dagegen getrennte Identitäten, wenn Gegenstand, Ergebnis oder Abnahmekontext fachlich verschieden ist.

Die Kategorien sind `IT` = Blau, `BWL` = Gelb und `Recht` = Rot. Gewichtete Anteile erzeugen Mischfarben; ihre Summe beträgt je Core `1`.

Die sichtbare Vault folgt ausschließlich der fachlichen Hierarchie:
`Lernfeld → Kompetenzbereich → Themencluster → Thema → Core-Ausprägung`.
Zwischen Cores werden keine sichtbaren Themencliquen erzeugt. Die
Themenzuordnung über `thema_ref` bleibt für Folder Tree, Fokus und Quiz-Auswahl
erhalten.

Die Detailtiefe aller Lernfelder orientiert sich proportional an den amtlichen
KMK-Zeitrichtwerten und an der Ausarbeitungstiefe von LF1. Pro Unterrichtsstunde
werden `1,375` Themen und `5,375` kontextuelle Core-Ausprägungen abgebildet:
40 Stunden entsprechen 55 Themen und 215 Core-Ausprägungen, 80 Stunden 110 und
430 sowie 120 Stunden 165 und 645. Zusätzliche Zeit wird über fachbezogene
Analyse-, Anwendungs-, Entscheidungs-, Umsetzungs-, Prüfungs- und
Reflexionskontexte modelliert. Dabei werden vorhandene atomare
Core-Identitäten im neuen Lernkontext wiederverwendet; Artefakte bleiben von
Lerninhalten getrennt.

Aktueller validierter Umfang:

- 21 Lernfeldvarianten: LF1 bis LF9 sowie LF10 bis LF12 in vier Fachrichtungen
- 84 Kompetenzbereiche
- 175 Themencluster
- 2365 Themen ohne leere Endknoten
- 723 globale Cores und 9245 Core-Ausprägungen
- 23 auflösbare Quellen
- 236 ausgewertete Prüfungsthemen: 213 Lerninhalte und 23 Artefaktzuordnungen
- keine Status-, Kern- oder Ergänzungsfelder

Die Hierarchie ist in allen Lernfeldern vollständig belegt:

```text
Lernfeld
└── Kompetenzbereich
    └── Themencluster
        └── Thema
            └── Core-Ausprägung → globale Core-Identität
```

Das maschinenlesbare `Core-Änderungsinventar.json` nennt für jede neue Identität
alle Positionen über `lernfeld_ref`, `kompetenz_ref`,
`themencluster_ref` und `thema_ref`.

`index.html` lädt die fünf Dateien gemeinsam. Beim direkten Öffnen als `file://` verwendet die Seite einen in sich identischen eingebetteten Split-Datenstand, da Browser lokale JSON-Anfragen häufig blockieren.

Die Vault stellt Cores als einfache farbige Punkte ohne Piktogramme dar. In den
Einstellungen lassen sich die sichtbaren Ebenen `Lernfelder`,
`Kompetenzen`, `Themencluster` und `Themen` unabhängig ein- und ausblenden. Diese Anzeigeoptionen
verändern weder die Daten noch die Positionen der übrigen Knoten und werden nur
lokal im Browser gespeichert.

Die räumliche Vault-Fläche wird aus der aktuellen Knotenmenge dynamisch
berechnet. Lernfelder verteilen sich auf einer organischen Spirale statt in
einem festen Rechteck. Für einzelne Knoten existiert keine harte Weltkante;
Zoom und Verschieben orientieren sich an den tatsächlichen Graphgrenzen.
