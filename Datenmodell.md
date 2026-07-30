# Aktives Lern-Vault-Datenmodell

Die Laufzeitdaten sind nach dem Schema `3.0.0` auf fünf getrennt gepflegte Dateien verteilt:

- `Lernfelder.json`: Lernfelder und zugehörige Kompetenzen
- `Themen.json`: stabile Themencluster und Themen mit Elternreferenzen
- `Cores.json`: globale Core-Identitäten, Inhalte und gewichtete Kategorien
- `Core-Ausprägungen.json`: Einordnung eines globalen Cores in Lernfeld, Kompetenz, Themencluster und Thema einschließlich Tiefengrad
- `Quellen.json`: zentraler Quellenkatalog

Ein Core ist ein eigenständiges, benanntes und didaktisch sinnvolles fachliches Konzept. Seine globale Identität wird über `id` und `identity_key` stabil gehalten. Die `Core-Ausprägung` trägt den konkreten Lernkontext und den Tiefengrad `Grundlage`, `Vertiefung` oder `Spezialisierung`.

- `Grundlage`: gemeinsamer Unterricht im ersten Ausbildungsjahr, LF1 bis LF5
- `Vertiefung`: gemeinsamer Unterricht im zweiten Ausbildungsjahr, LF6 bis LF9
- `Spezialisierung`: fachrichtungsspezifischer Unterricht im dritten Ausbildungsjahr, LF10a bis LF12d

Wiederkehrende Begriffe werden als globale Core-Identität wiederverwendet und erhalten pro Lernfeld eine eigene `Core-Ausprägung`. Das betrifft insbesondere das in LF11b und LF11d identische Kompetenzprofil zur Sicherheit vernetzter Systeme. Fachrichtungsspezifische Projektausprägungen in LF12a bis LF12d bleiben dagegen getrennte Identitäten, wenn Gegenstand, Ergebnis oder Abnahmekontext fachlich verschieden ist.

Die Kategorien sind `IT` = Blau, `BWL` = Gelb und `Recht` = Rot. Gewichtete Anteile erzeugen Mischfarben; ihre Summe beträgt je Core `1`.

Vault-Verbindungen werden nicht als beliebige Kanten gespeichert. Sichtbare Core-Ausprägungen mit derselben `thema_ref` werden zur Laufzeit paarweise verbunden.

Aktueller validierter Umfang:

- 21 Lernfeldvarianten: LF1 bis LF9 sowie LF10 bis LF12 in vier Fachrichtungen
- 84 Kompetenzbereiche
- 175 Themencluster
- 375 Themen ohne leere Endknoten
- 723 globale Cores und 856 Core-Ausprägungen
- 22 auflösbare Quellen
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
