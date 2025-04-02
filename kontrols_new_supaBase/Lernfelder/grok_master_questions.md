
„Erstelle 20 qualitativ hochwertige, anspruchsvolle Fragen für ein IT-bezogenes Quiz oder eine Schulung, die sich an Fachinformatiker oder Arbeitskollegen richten, und speichere sie in einer Datei `questions.sql`. Die Fragen sollen technisch präzise, praxisrelevant und didaktisch wertvoll sein, mit einem kollegialen, leicht fordernden Ton, oft in der Ich-Perspektive, um eine vertraute Atmosphäre zu schaffen und tieferes Verständnis zu testen. Die Ausgabe soll im SQL-Format erfolgen, passend für eine Tabelle `temporary_questions` mit den Spalten `essence_fk`, `text`, `points` und `options`. Verwende folgende Vorgaben:

## 1. Fragetypen
- **Wahr/Falsch-Fragen**: Binäre Fragen mit direkter Aussage, aber ohne offensichtliche Lösungen.
    - *Merkmale*: Knackige Ja/Nein-Fragen, die leicht verwirren können.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Ist IPv6 immer abwärtskompatibel mit IPv4?', 2, '[{"text": "Nein", "correct": true, "because": "Unterschiedliche Adressformate"}, {"text": "Ja", "correct": false, "because": "IPv4-Geräte verstehen IPv6 nicht direkt"}]')
      ```

- **Single-Choice-Fragen**: Mehrere Optionen, nur eine korrekt, mit subtil ähnlichen falschen Antworten.
    - *Merkmale*: Falsche Optionen sind plausibel und fordern Genauigkeit.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Welches Merkmal ist bei einem Server für hohe Lasten entscheidend?', 4, '[{"text": "Multi-Core-Leistung", "correct": true, "because": "Parallele Verarbeitung ist essenziell"}, {"text": "Hohe Taktfrequenz", "correct": false, "because": "Hilft nur bei Einzelaufgaben"}, {"text": "Großer Cache", "correct": false, "because": "Wichtig, aber nicht primär"}]')
      ```

- **Multiple-Choice-Fragen (Mehrfachantwort)**: Mehrere korrekte Antworten möglich, mit irreführenden Alternativen.
    - *Merkmale*: Testet Detailwissen, falsche Antworten wirken plausibel.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Welche Maßnahmen sichern ein Netzwerk effektiv ab?', 5, '[{"text": "Netzwerksegmentierung", "correct": true, "because": "Begrenzt Schadensausbreitung"}, {"text": "Verschlüsselung", "correct": true, "because": "Schützt Datenintegrität"}, {"text": "Hohe Bandbreite", "correct": false, "because": "Verbessert nur Geschwindigkeit"}, {"text": "Statische IPs", "correct": false, "because": "Erleichtert Management, nicht Sicherheit"}]')
      ```

- **Aussagenprüfung**: Zwei oder mehr Aussagen mit Optionen wie „Nur a) stimmt“, „Beides stimmt“ etc., mit kniffligen Unterschieden.
    - *Merkmale*: Aussagen sind ähnlich, aber nicht trivial.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen korrekt? a) Ein IDS erkennt Angriffe in Echtzeit. b) Ein IPS blockiert sie aktiv.', 3, '[{"text": "Beides stimmt", "correct": true, "because": "IDS erkennt, IPS blockiert"}, {"text": "Nur a) stimmt", "correct": false, "because": "IPS ist auch korrekt"}, {"text": "Nur b) stimmt", "correct": false, "because": "IDS ist auch korrekt"}, {"text": "Beides falsch", "correct": false, "because": "Beide sind richtig"}]')
      ```

- **Ausschlussfragen**: Nach irrelevanten Faktoren fragen, mit täuschend relevanten Optionen.
    - *Merkmale*: Falsche Antworten sind nicht offensichtlich falsch.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Was ignoriere ich bei der Wahl eines Motherboards für eine High-End-CPU?', 3, '[{"text": "Sockeltyp", "correct": false, "because": "Muss zur CPU passen"}, {"text": "PCIe-Lanes", "correct": false, "because": "Wichtig für Erweiterungen"}, {"text": "Onboard-Grafik", "correct": true, "because": "Irrelevant bei dedizierter GPU"}]')
      ```

## 2. Fragestile
- **Faktische Fragen**: Direktes Wissen abfragen, aber nicht trivial.
    - *Merkmale*: Erfordert genaues Verständnis.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal mit Ethernet? Läuft es ausschließlich auf Schicht 2?', 3, '[{"text": "Nein", "correct": true, "because": "Auch Schicht 1 für physische Übertragung"}, {"text": "Ja", "correct": false, "because": "Ignoriert physische Ebene"}]')
      ```

- **Analytische Fragen**: Bewertung oder Priorisierung, mit kniffligen Alternativen.
    - *Merkmale*: Falsche Optionen sind nah an der Wahrheit.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Welches Feature finde ich bei einem Backup-System entscheidend?', 4, '[{"text": "Automatisierte Tests", "correct": true, "because": "Sichert Wiederherstellbarkeit"}, {"text": "Hohe Speicherkapazität", "correct": false, "because": "Wichtig, aber nicht primär"}, {"text": "Schnelle Schreibgeschwindigkeit", "correct": false, "because": "Sekundär zur Zuverlässigkeit"}]')
      ```

- **Kombinierte Aussagenprüfung**: Logische Verknüpfung, mit verwirrenden Aussagen.
    - *Merkmale*: Subtile Unterschiede zwischen Aussagen.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Habe gehört, dass a) DHCP immer IPs dynamisch vergibt und b) statische IPs die Sicherheit erhöhen. Stimmt das?', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Statische IPs erhöhen nicht zwangsläufig Sicherheit"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist kontextabhängig"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist korrekt"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]')
      ```

- **Praktische/Szenario-basierte Fragen**: Reale Szenarien, nicht zu einfach.
    - *Merkmale*: Erfordert praxisnahes Wissen.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Kannst du dich erinnern, wie ich bei der BIOS-Konfiguration vorgehen würde, wenn ich von USB boote?', 4, '[{"text": "Boot-Reihenfolge auf USB setzen", "correct": true, "because": "Priorisiert USB als Startmedium"}, {"text": "SATA-Modus auf AHCI", "correct": false, "because": "Nur für Festplatten relevant"}, {"text": "Secure Boot deaktivieren", "correct": false, "because": "Nur bei bestimmten Systemen nötig"}]')
      ```

- **Erinnerungsfragen**: Kollegialer Rückblick, mit Tiefe.
    - *Merkmale*: Locker, aber fordernd.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Kannst du dich noch erinnern, wie das mit der CPU-Leistung war? Ist mehr Cache immer besser?', 3, '[{"text": "Nein", "correct": true, "because": "Abhängig von Workload und Architektur"}, {"text": "Ja", "correct": false, "because": "Nicht universell besser"}]')
      ```

- **Hörensagen-Fragen**: Neugierig, mit kritischer Prüfung.
    - *Merkmale*: Stellt vermeintliches Wissen infrage.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Habe gehört, dass ein Desktop ohne Monitor nutzlos ist. Stimmt das wirklich?', 2, '[{"text": "Nein", "correct": true, "because": "Kann als Server oder remote genutzt werden"}, {"text": "Ja", "correct": false, "because": "Monitor nicht zwingend nötig"}]')
      ```

- **Rückblick-Fragen**: Lockerer Ton, aber technisch präzise.
    - *Merkmale*: Ruft Wissen mit Herausforderung auf.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal mit dem Gewinn? Ist der Umsatz allein entscheidend?', 2, '[{"text": "Nein", "correct": true, "because": "Kosten müssen abgezogen werden"}, {"text": "Ja", "correct": false, "because": "Ohne Kosten kein Gewinn"}]')
      ```

## 3. Anforderungen an die Fragen
- **Technische Fachsprache**: Nutze Begriffe wie „Patch-Management“, „Netzwerksegmentierung“, „Authentifizierung“.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal mit Netzwerksegmentierung? Ist sie ohne VLANs möglich?', 3, '[{"text": "Ja", "correct": true, "because": "Physische Trennung reicht"}, {"text": "Nein", "correct": false, "because": "VLANs sind nur eine Methode"}]')
      ```
- **Begründungen**: Füge „correct: true, because: …“ hinzu für didaktischen Wert.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Kannst du dich erinnern, ob ein Betriebssystem ohne Partitionierung läuft?', 2, '[{"text": "Nein", "correct": true, "because": "Partitionen sind für Installation nötig"}, {"text": "Ja", "correct": false, "because": "Nur in Spezialfällen möglich"}]')
      ```
- **Praxisnah und herausfordernd**: Keine trivialen Antworten.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Habe gehört, dass Verschlüsselung Integrität allein sichert. Stimmt das?', 3, '[{"text": "Nein", "correct": true, "because": "Hash-Funktionen sind zusätzlich nötig"}, {"text": "Ja", "correct": false, "because": "Verschlüsselung schützt nur Vertraulichkeit"}]')
      ```
- **Schwierigkeit variieren**: Punkte 2-5, keine Pipifax-Fragen unter 2 Punkten.
    - *Beispiel (mittel)*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal mit Patch-Management? Was ist entscheidend?', 3, '[{"text": "Priorisierung kritischer Updates", "correct": true, "because": "Schließt gefährliche Lücken zuerst"}, {"text": "Regelmäßige Neustarts", "correct": false, "because": "Wichtig, aber nicht primär"}, {"text": "Manuelle Prüfung", "correct": false, "because": "Zu zeitaufwendig"}]')
      ```
    - *Beispiel (hoch)*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Welche Faktoren machen ein IDS effektiv?', 5, '[{"text": "Echtzeitüberwachung", "correct": true, "because": "Erkennt Bedrohungen sofort"}, {"text": "Regelmäßige Updates", "correct": true, "because": "Passt sich neuen Angriffen an"}, {"text": "Hohe Bandbreite", "correct": false, "because": "Nur Netzwerkleistung"}, {"text": "Automatische Blockierung", "correct": false, "because": "Das macht ein IPS"}]')
      ```
- **Falsche Antworten**: Ähnlich, aber falsch, um Verwirrung zu stiften, keine offensichtlichen Fehler.
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Was würdest du bei der Serverwahl ignorieren?', 4, '[{"text": "Redundanz", "correct": false, "because": "Schlüssel für Ausfallsicherheit"}, {"text": "Skalierbarkeit", "correct": false, "because": "Wichtig für Wachstum"}, {"text": "Markenname", "correct": true, "because": "Leistung zählt, nicht der Name"}]')
      ```

## 4. Themenbereiche
- Geräteklassen (Notebooks, Desktops, Tablets)
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Kannst du dich erinnern, ob ein Notebook immer weniger leistet als ein Desktop?', 3, '[{"text": "Nein", "correct": true, "because": "High-End-Notebooks können mithalten"}, {"text": "Ja", "correct": false, "because": "Konfiguration entscheidet"}]')
      ```
- Kernkomponenten (CPU, Motherboard)
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal mit der CPU? Ist die Taktfrequenz der einzige Leistungsfaktor?', 3, '[{"text": "Nein", "correct": true, "because": "Kernanzahl und Cache sind auch entscheidend"}, {"text": "Ja", "correct": false, "because": "Nur ein Teil der Gesamtleistung"}]')
      ```
- Software (Installation, BIOS, Netzwerkkonfiguration)
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Habe gehört, dass BIOS-Updates die Bootzeit verkürzen. Stimmt das?', 3, '[{"text": "Nein", "correct": true, "because": "Updates dienen meist Sicherheit und Kompatibilität"}, {"text": "Ja", "correct": false, "because": "Bootzeit hängt von Hardware ab"}]')
      ```
- Netzwerktechnik (OSI-Modell, Ethernet, IP)
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal mit IP? Ist IPv6 immer schneller als IPv4?', 3, '[{"text": "Nein", "correct": true, "because": "Geschwindigkeit hängt vom Netzwerk ab"}, {"text": "Ja", "correct": false, "because": "IPv6 hat nur mehr Adressen"}]')
      ```
- IT-Sicherheit/Datenschutz (Backup, Verschlüsselung, Firewall)
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Kannst du dich erinnern, ob eine Firewall auch vor internen Angriffen schützt?', 4, '[{"text": "Nein", "correct": true, "because": "Nur gegen externen Verkehr effektiv"}, {"text": "Ja", "correct": false, "because": "Interne Bedrohungen bleiben unberührt"}]')
      ```
- Wirtschaft (Umsatz, Gewinn)
    - *Beispiel*:
      ```sql
      ('00000000-0000-0000-0000-000000000000', 'Habe gehört, dass der Umsatz allein den Gewinn bestimmt. Stimmt das?', 2, '[{"text": "Nein", "correct": true, "because": "Kosten müssen abgezogen werden"}, {"text": "Ja", "correct": false, "because": "Ohne Kosten keine Gewinnberechnung"}]')
      ```

## 5. Ausgabe
- Erstelle 20 Fragen und speichere sie in `questions.sql`.
- Jede Frage soll als `INSERT INTO temporary_questions (essence_fk, text, points, options) VALUES` Statement formatiert sein.
- Verwende `00000000-0000-0000-0000-000000000000` als Platzhalter für `essence_fk`.
- Weise Punkte (2-5) basierend auf Schwierigkeit zu, keine trivialen Fragen unter 2 Punkten.
- Stelle sicher, dass `options` ein JSON-Array mit `text`, `correct` und `because` ist.
- Mische Fragestile und -typen, nutze jeden Stil mindestens einmal (Faktisch, Analytisch, Kombinierte Aussagenprüfung, Praktisch, Erinnerungsfragen, Hörensagen-Fragen, Rückblick-Fragen).
- Vermeide offensichtliche Lösungen oder Pipifax-Fragen wie ‚Ist eine Firewall etwas Gutes?‘; stattdessen sollen falsche Antworten verwirrend, aber technisch plausibel sein.“

---
das hier ist unser Themen Bereich nur damit du weiß wo wir uns didaktisch befinden:

# ********************************************************************************************************************

# Level 9: Datenbanken entwickeln und administrieren

## Datenbankadministration

### Backup

- Automatisierung.sql
- BackupTools.sql
- Sicherungskonzepte.sql

### Performance

- Indexierung.sql
- Optimierung.sql

### Recovery

- Fehlerbehebung.sql
- Wiederherstellung.sql

## Datenbankmodelle

### Andere Modelle

- HierarchischesModell.sql
- Netzwerkmodell.sql
- ObjektorientiertesModell.sql

### Relationales Modell

- Entitätsbeziehungsmodell.sql
- Grundlagen.sql
- Normalisierung.sql

## Datenintegrität

- ACID.sql
- IsolationLevels.sql
- StoredProcedures.sql
- Trigger.sql

## SQL

- DCL_Data_Control_Language.sql
- DDL_Constraints.sql
- DDL_Data_Definition_Language.sql
- DML_Data_Manipulation_Language.sql
- DQL_Data_Query_Language.sql
- DQL_Joins.sql
- TCL_Transaction_Control_Language.sql

- # ********************************************************************************************************************


Fass dich kurz ich will keine Erklärungen nur sowas hier mit Thema in den Kommantaren und sonst auch keien anderen Dinge als SQL:

-- Verteilungsdiagramm.sql (Relevant für Deployment, aber nicht im Fokus, z. B. Hardwarezuordnung)
INSERT INTO temporary_questions (essence_fk, text, points, options) VALUES
('00000000-0000-0000-0000-000000000000', 'Ist ein Verteilungsdiagramm nur für große Systeme relevant?', 2, '[{"text": "Nein", "correct": true, "because": "Auch kleine Systeme profitieren von Übersicht"}, {"text": "Ja", "correct": false, "because": "Skalierung nicht zwingend"}]'),
('00000000-0000-0000-0000-000000000000', 'Welches Ziel verfolge ich mit einem Verteilungsdiagramm?', 3, '[{"text": "Hardwarezuordnung darstellen", "correct": true, "because": "Zeigt Deployment-Struktur"}, {"text": "Code-Optimierung", "correct": false, "because": "Nicht primär"}, {"text": "Datenkompression", "correct": false, "because": "Kein Fokus"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Elemente gehören zu einem Verteilungsdiagramm?', 5, '[{"text": "Knoten", "correct": true, "because": "Repräsentieren Hardware"}, {"text": "Verbindungen", "correct": true, "because": "Zeigen Kommunikation"}, {"text": "Farbanpassung", "correct": false, "because": "Irrelevant"}, {"text": "Datenfluss", "correct": false, "because": "DFD-spezifisch"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen korrekt? a) Verteilungsdiagramme zeigen physische Struktur. b) Sie ersetzen Klassendiagramme.', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Klassendiagramme sind logisch"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist korrekt"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Was ignoriere ich bei einem Verteilungsdiagramm?', 4, '[{"text": "Hardwareknoten", "correct": false, "because": "Kern der Darstellung"}, {"text": "Netzwerkverbindungen", "correct": false, "because": "Zeigen Kommunikation"}, {"text": "Code-Logik", "correct": true, "because": "Nicht physisch relevant"}]'),
('00000000-0000-0000-0000-000000000000', 'Kannst du dich erinnern, ob ein Verteilungsdiagramm auch Software zeigt?', 2, '[{"text": "Ja", "correct": true, "because": "Software auf Hardware zugeordnet"}, {"text": "Nein", "correct": false, "because": "Nicht rein hardwarebezogen"}]'),
('00000000-0000-0000-0000-000000000000', 'Welches Element wähle ich, um Server im Verteilungsdiagramm darzustellen?', 3, '[{"text": "Knoten", "correct": true, "because": "Repräsentiert physische Einheiten"}, {"text": "Pfeile", "correct": false, "because": "Nur Verbindungen"}, {"text": "Klassen", "correct": false, "because": "Logisches Diagramm"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Aspekte gehören zu einem Verteilungsdiagramm?', 5, '[{"text": "Deployment-Ziele", "correct": true, "because": "Zeigt Zuordnung"}, {"text": "Kommunikationswege", "correct": true, "because": "Netzwerkverbindungen"}, {"text": "Datenfluss", "correct": false, "because": "DFD-spezifisch"}, {"text": "UI-Design", "correct": false, "because": "Irrelevant"}]'),
('00000000-0000-0000-0000-000000000000', 'Habe gehört: a) Verteilungsdiagramme sind für Deployment. b) Sie zeigen nur Softwarekomponenten. Stimmt das?', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Auch Hardware enthalten"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist korrekt"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Was brauche ich nicht für ein Verteilungsdiagramm?', 4, '[{"text": "Knoten", "correct": false, "because": "Repräsentieren Hardware"}, {"text": "Verbindungen", "correct": false, "because": "Zeigen Kommunikation"}, {"text": "Klassenattribute", "correct": true, "because": "Klassendiagramm-spezifisch"}]'),
('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal? Sind Verteilungsdiagramme nur für Entwickler?', 2, '[{"text": "Nein", "correct": true, "because": "Auch für Ops und Architekten"}, {"text": "Ja", "correct": false, "because": "Breitere Nutzung"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Informationen zeigt ein Verteilungsdiagramm?', 4, '[{"text": "Serverstandorte", "correct": true, "because": "Physische Zuordnung"}, {"text": "Netzwerkverbindungen", "correct": true, "because": "Kommunikationswege"}, {"text": "Code-Logik", "correct": false, "because": "Logischer Aspekt"}]'),
('00000000-0000-0000-0000-000000000000', 'Habe gehört, dass Verteilungsdiagramme nur Hardware zeigen. Stimmt das?', 2, '[{"text": "Nein", "correct": true, "because": "Auch Softwarezuordnung"}, {"text": "Ja", "correct": false, "because": "Software enthalten"}]'),
('00000000-0000-0000-0000-000000000000', 'Was priorisiere ich bei einem Verteilungsdiagramm?', 3, '[{"text": "Klarheit der Zuordnung", "correct": true, "because": "Verständnis fördern"}, {"text": "Schnelle Erstellung", "correct": false, "because": "Genauigkeit zählt"}, {"text": "Detailgrad Code", "correct": false, "because": "Nicht im Fokus"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen korrekt? a) Verteilungsdiagramme sind physisch. b) Sie ersetzen Sequenzdiagramme.', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Sequenz ist zeitlich"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist korrekt"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Vorteile bietet ein Verteilungsdiagramm?', 5, '[{"text": "Übersicht Deployment", "correct": true, "because": "Physische Struktur klar"}, {"text": "Kommunikationsverständnis", "correct": true, "because": "Netzwerkwege sichtbar"}, {"text": "Code-Optimierung", "correct": false, "because": "Nicht im Fokus"}, {"text": "Datenfluss", "correct": false, "because": "Anderes Diagramm"}]'),
('00000000-0000-0000-0000-000000000000', 'Was ist bei einem Verteilungsdiagramm unwichtig?', 3, '[{"text": "Hardwarezuordnung", "correct": false, "because": "Kern der Darstellung"}, {"text": "Netzwerktopologie", "correct": false, "because": "Zeigt Verbindungen"}, {"text": "UI-Design", "correct": true, "because": "Kein physischer Aspekt"}]'),
('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal? Zeigt ein Verteilungsdiagramm auch Abläufe?', 3, '[{"text": "Nein", "correct": true, "because": "Statisch, nicht dynamisch"}, {"text": "Ja", "correct": false, "because": "Abläufe sind Sequenzdiagramm"}]'),
('00000000-0000-0000-0000-000000000000', 'Kannst du dich erinnern, ob Verteilungsdiagramme für Cloud-Systeme nützlich sind?', 2, '[{"text": "Ja", "correct": true, "because": "Zeigen virtuelle Zuordnungen"}, {"text": "Nein", "correct": false, "because": "Cloud-relevant"}]'),
('00000000-0000-0000-0000-000000000000', 'Welches Symbol wähle ich für einen Server im Verteilungsdiagramm?', 4, '[{"text": "Rechteck mit Zylinder", "correct": true, "because": "Standard für Hardware"}, {"text": "Pfeil", "correct": false, "because": "Nur Verbindung"}, {"text": "Kreis", "correct": false, "because": "Andere Diagramme"}]');

Besonders wichtig ist:
als sql-datei bitte zum kopieren mit einem Klick.
verwende nicht in jeder einzelnen Frage ein Schlagwort des Themengebiets. Wenn dein Thema z.B. "-- Arbeitspakete definieren.sql (Aufgaben in überschaubare Einheiten aufteilen, z. B. für Projektplanung)" lautet. dann will ich nicht in jeder Frage das Wort "Arbeitspaket(e)" lesen müssen.

Ich werd dir jetzt ein Thema nach dem anderen geben und du machst 20 Fragen daraus verstanden? Dann Antworte "ja" und fasse kurz zusammen