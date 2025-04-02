INSERT INTO temporary_questions (essence_fk, text, points, options) VALUES
-- Prüfung 1: Planen eines Softwareprodukts > SoftwareArchitektur > Schichtenmodell (Layers)
-- Ja/Nein-Fragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Ist das Schichtenmodell eine Architektur, die Software in verschiedene Ebenen aufteilt?', 2,
'[{"text": "Ja", "correct": true, "because": "Das Schichtenmodell teilt Funktionen in Ebenen auf"}, {"text": "Nein", "correct": false, "because": "Definition des Schichtenmodells"}]'),
('00000000-0000-0000-0000-000000000000', 'Können Schichten im Schichtenmodell direkt auf jede andere Schicht zugreifen?', 2,
'[{"text": "Nein", "correct": true, "because": "Schichten kommunizieren meist nur mit benachbarten Ebenen"}, {"text": "Ja", "correct": false, "because": "Abhängigkeiten sind strukturiert"}]'),
('00000000-0000-0000-0000-000000000000', 'Ist die Präsentationsschicht im Schichtenmodell für die Benutzeroberfläche verantwortlich?', 2,
'[{"text": "Ja", "correct": true, "because": "Die Präsentationsschicht zeigt Daten dem Benutzer"}, {"text": "Nein", "correct": false, "because": "Definition der Präsentationsschicht"}]'),
('00000000-0000-0000-0000-000000000000', 'Muss jede Software, die ein Schichtenmodell verwendet, mindestens drei Schichten haben?', 2,
'[{"text": "Nein", "correct": true, "because": "Anzahl der Schichten ist flexibel"}, {"text": "Ja", "correct": false, "because": "Keine feste Mindestanzahl"}]'),
('00000000-0000-0000-0000-000000000000', 'Kann das Schichtenmodell die Wartbarkeit einer Software verbessern?', 2,
'[{"text": "Ja", "correct": true, "because": "Trennung der Schichten erleichtert Änderungen"}, {"text": "Nein", "correct": false, "because": "Vorteil des Schichtenmodells"}]'),

-- Single-Choice-Fragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Welche Schicht ist im Schichtenmodell für die Geschäftslogik zuständig?', 2,
'[{"text": "Anwendungsschicht", "correct": true, "because": "Verarbeitet Geschäftslogik"}, {"text": "Präsentationsschicht", "correct": false, "because": "Benutzeroberfläche"}, {"text": "Datenschicht", "correct": false, "because": "Datenverwaltung"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Schicht im Schichtenmodell kümmert sich um die Datenbankinteraktion?', 2,
'[{"text": "Datenschicht", "correct": true, "because": "Verantwortlich für Datenpersistenz"}, {"text": "Anwendungsschicht", "correct": false, "because": "Geschäftslogik"}, {"text": "Präsentationsschicht", "correct": false, "because": "Oberfläche"}]'),
('00000000-0000-0000-0000-000000000000', 'Welches Prinzip beschreibt die Trennung der Zuständigkeiten im Schichtenmodell?', 2,
'[{"text": "Separation of Concerns", "correct": true, "because": "Jede Schicht hat eigene Aufgaben"}, {"text": "Single Responsibility", "correct": false, "because": "Klassenbezogen"}, {"text": "Dependency Inversion", "correct": false, "because": "Abhängigkeiten"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Schicht ist die oberste im typischen 3-Schichten-Modell?', 2,
'[{"text": "Präsentationsschicht", "correct": true, "because": "Interagiert mit dem Benutzer"}, {"text": "Anwendungsschicht", "correct": false, "because": "Mittlere Schicht"}, {"text": "Datenschicht", "correct": false, "because": "Unterste Schicht"}]'),
('00000000-0000-0000-0000-000000000000', 'Welcher Vorteil des Schichtenmodells erleichtert die Ersetzung einzelner Komponenten?', 2,
'[{"text": "Modularität", "correct": true, "because": "Schichten sind unabhängig austauschbar"}, {"text": "Skalierbarkeit", "correct": false, "because": "Verteilte Systeme"}, {"text": "Kapselung", "correct": false, "because": "Detailverbergung"}]'),

-- Multiple-Choice-Fragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Welche Schichten sind typisch für ein 3-Schichten-Modell?', 3,
'[{"text": "Präsentationsschicht", "correct": true, "because": "Benutzeroberfläche"}, {"text": "Anwendungsschicht", "correct": true, "because": "Geschäftslogik"}, {"text": "Datenschicht", "correct": true, "because": "Datenverwaltung"}, {"text": "Netzwerkschicht", "correct": false, "because": "Nicht Teil des Modells"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Vorteile bietet das Schichtenmodell?', 3,
'[{"text": "Wartbarkeit", "correct": true, "because": "Trennung erleichtert Änderungen"}, {"text": "Wiederverwendbarkeit", "correct": true, "because": "Schichten sind unabhängig"}, {"text": "Modularität", "correct": true, "because": "Klar abgegrenzte Schichten"}, {"text": "Maximale Geschwindigkeit", "correct": false, "because": "Nicht primär"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Prinzipien unterstützt das Schichtenmodell?', 3,
'[{"text": "Trennung der Zuständigkeiten", "correct": true, "because": "Separation of Concerns"}, {"text": "Abhängigkeitsmanagement", "correct": true, "because": "Schichtenabhängigkeiten"}, {"text": "Kapselung", "correct": true, "because": "Schichten verbergen Details"}, {"text": "Polymorphismus", "correct": false, "because": "Objektorientiert"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Aufgaben übernimmt die Anwendungsschicht im Schichtenmodell?', 3,
'[{"text": "Verarbeitung der Geschäftslogik", "correct": true, "because": "Kernfunktion"}, {"text": "Koordination zwischen Schichten", "correct": true, "because": "Vermittelt"}, {"text": "Validierung von Daten", "correct": true, "because": "Logik enthalten"}, {"text": "Datenbankverwaltung", "correct": false, "because": "Datenschicht"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Nachteile kann das Schichtenmodell haben?', 3,
'[{"text": "Komplexität bei vielen Schichten", "correct": true, "because": "Mehr Schichten erhöhen Aufwand"}, {"text": "Leistungseinbußen durch Overhead", "correct": true, "because": "Schichtübergänge"}, {"text": "Eingeschränkte Flexibilität", "correct": true, "because": "Strenge Struktur"}, {"text": "Hohe Speichereffizienz", "correct": false, "because": "Kein Nachteil"}]'),

-- Richtig/Falsch-Kombinationsfragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Sind folgende Aussagen richtig? a) Das Schichtenmodell trennt die Benutzeroberfläche von der Geschäftslogik. b) Jede Schicht kann auf jede andere direkt zugreifen.', 3,
'[{"text": "Nur a) stimmt", "correct": true, "because": "Trennung ja, direkter Zugriff nein"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen korrekt? a) Die Datenschicht verwaltet die Datenpersistenz. b) Die Präsentationsschicht enthält die Geschäftslogik.', 3,
'[{"text": "Nur a) stimmt", "correct": true, "because": "Datenschicht ja, Geschäftslogik nein"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen richtig? a) Das Schichtenmodell verbessert die Modularität. b) Es reduziert immer die Komplexität einer Anwendung.', 3,
'[{"text": "Nur a) stimmt", "correct": true, "because": "Modularität ja, Komplexität nicht immer"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind folgende Aussagen korrekt? a) Die Anwendungsschicht koordiniert zwischen Präsentation und Daten. b) Das Schichtenmodell ist nur für kleine Anwendungen geeignet.', 3,
'[{"text": "Nur a) stimmt", "correct": true, "because": "Koordination ja, Größe flexibel"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen richtig? a) Das Schichtenmodell kann Leistungseinbußen verursachen. b) Jede Schicht muss physisch getrennt sein.', 3,
'[{"text": "Nur a) stimmt", "correct": true, "because": "Overhead ja, physische Trennung nein"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]');