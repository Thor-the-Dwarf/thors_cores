INSERT INTO temporary_questions (essence_fk, text, points, options) VALUES
-- 1. Wahr/Falsch-Frage (Faktisch)
('00000000-0000-0000-0000-000000000000', 'Ist eine ArrayList immer die beste Wahl, wenn ich schnelle Zugriffe auf Elemente brauche?', 2, '[{"text": "Nein", "correct": true, "because": "Abhängig vom Szenario, z. B. bei häufigen Einfügungen ist eine LinkedList besser"}, {"text": "Ja", "correct": false, "because": "Ignoriert andere Strukturen wie HashMap"}]'),

-- 2. Single-Choice-Frage (Analytisch)
('00000000-0000-0000-0000-000000000000', 'Welche Datenstruktur wähle ich für eine FIFO-Aufgabe wie eine Druckwarteschlange?', 3, '[{"text": "Queue", "correct": true, "because": "First-In-First-Out ist ideal für Warteschlangen"}, {"text": "Stack", "correct": false, "because": "LIFO passt nicht"}, {"text": "HashMap", "correct": false, "because": "Keine Reihenfolge garantiert"}]'),

-- 3. Multiple-Choice-Frage (Praktisch)
('00000000-0000-0000-0000-000000000000', 'Welche Strukturen eignen sich, wenn ich eine Datenbankabfrage mit vielen Schlüssel-Wert-Paaren optimieren will?', 5, '[{"text": "HashMap", "correct": true, "because": "O(1) Zugriff bei Schlüsselabfragen"}, {"text": "B-Baum", "correct": true, "because": "Effizient für sortierte Daten in Datenbanken"}, {"text": "Array", "correct": false, "because": "Lineare Suche ist zu langsam"}, {"text": "Stack", "correct": false, "because": "Keine Schlüssel-Wert-Struktur"}]'),

-- 4. Aussagenprüfung (Kombinierte Aussagenprüfung)
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen richtig? a) Ein Stack ist perfekt für rekursive Algorithmen. b) Eine Queue ist besser für rekursive Aufgaben.', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Stack unterstützt LIFO, ideal für Rekursion"}, {"text": "Beides stimmt", "correct": false, "because": "Queue ist FIFO, nicht für Rekursion geeignet"}, {"text": "Nur b) stimmt", "correct": false, "because": "Queue passt nicht"}, {"text": "Beides falsch", "correct": false, "because": "a) ist korrekt"}]'),

-- 5. Ausschlussfrage (Analytisch)
('00000000-0000-0000-0000-000000000000', 'Was ignoriere ich bei der Wahl einer Struktur für eine Suchmaschine mit schnellen Abfragen?', 4, '[{"text": "Schlüssel-Wert-Zugriff", "correct": false, "because": "Essenziell für schnelle Suchen"}, {"text": "Sortierfähigkeit", "correct": false, "because": "Wichtig für Relevanzranking"}, {"text": "Einfügegeschwindigkeit", "correct": true, "because": "Sekundär, wenn Abfragen Priorität haben"}]'),

-- 6. Wahr/Falsch-Frage (Erinnerungsfrage)
('00000000-0000-0000-0000-000000000000', 'Kannst du dich erinnern, ob eine HashMap bei vielen Kollisionen immer effizient bleibt?', 2, '[{"text": "Nein", "correct": true, "because": "Kollisionen verschlechtern die Leistung"}, {"text": "Ja", "correct": false, "because": "Ignoriert Hash-Funktion und Lastfaktor"}]'),

-- 7. Single-Choice-Frage (Praktisch)
('00000000-0000-0000-0000-000000000000', 'Was nehme ich für eine Aufgabe, bei der ich die letzten 10 Aktionen rückgängig machen können muss?', 3, '[{"text": "Stack", "correct": true, "because": "LIFO passt perfekt für Undo"}, {"text": "Queue", "correct": false, "because": "FIFO ist für Reihenfolge, nicht Rückgängigmachen"}, {"text": "ArrayList", "correct": false, "because": "Keine natürliche LIFO-Unterstützung"}]'),

-- 8. Multiple-Choice-Frage (Analytisch)
('00000000-0000-0000-0000-000000000000', 'Welche Strukturen helfen mir bei einem Szenario mit hierarchischen Daten wie einem Dateisystem?', 5, '[{"text": "Baum", "correct": true, "because": "Perfekt für Hierarchien wie Verzeichnisse"}, {"text": "Graph", "correct": true, "because": "Unterstützt komplexe Beziehungen"}, {"text": "Liste", "correct": false, "because": "Keine Hierarchie möglich"}, {"text": "HashSet", "correct": false, "because": "Keine Struktur für Beziehungen"}]'),

-- 9. Aussagenprüfung (Kombinierte Aussagenprüfung)
('00000000-0000-0000-0000-000000000000', 'Habe gehört: a) Arrays sind gut für zufälligen Zugriff. b) Sie sind auch ideal für häufiges Einfügen. Stimmt das?', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "Einfügen in Arrays ist O(n)"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist korrekt"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),

-- 10. Ausschlussfrage (Praktisch)
('00000000-0000-0000-0000-000000000000', 'Was brauche ich nicht, wenn ich eine Struktur für eine Warteschlange in einem Callcenter suche?', 4, '[{"text": "FIFO-Unterstützung", "correct": false, "because": "Kernmerkmal einer Warteschlange"}, {"text": "Dynamische Größe", "correct": false, "because": "Wichtig für variable Anrufe"}, {"text": "Sortierfähigkeit", "correct": true, "because": "Reihenfolge zählt, nicht Ordnung"}]'),

-- 11. Single-Choice-Frage (Faktisch)
('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal? Welche Struktur hat O(1) Zugriff bei bekannter Position?', 2, '[{"text": "Array", "correct": true, "because": "Direkter Indexzugriff"}, {"text": "LinkedList", "correct": false, "because": "O(n) für Zugriff"}, {"text": "Baum", "correct": false, "because": "O(log n) im besten Fall"}]'),

-- 12. Multiple-Choice-Frage (Praktisch)
('00000000-0000-0000-0000-000000000000', 'Welche Strukturen passen, wenn ich Duplikate vermeiden und schnelle Suchen brauche?', 4, '[{"text": "HashSet", "correct": true, "because": "Keine Duplikate, O(1) Suche"}, {"text": "TreeSet", "correct": true, "because": "Keine Duplikate, O(log n) Suche"}, {"text": "ArrayList", "correct": false, "because": "Erlaubt Duplikate"}, {"text": "Queue", "correct": false, "because": "Fokus auf Reihenfolge"}]'),

-- 13. Wahr/Falsch-Frage (Hörensagen-Frage)
('00000000-0000-0000-0000-000000000000', 'Habe gehört, dass eine Liste immer besser ist als ein Array. Stimmt das wirklich?', 2, '[{"text": "Nein", "correct": true, "because": "Arrays sind schneller bei Zugriffen"}, {"text": "Ja", "correct": false, "because": "Listen sind nur bei Änderungen flexibler"}]'),

-- 14. Single-Choice-Frage (Analytisch)
('00000000-0000-0000-0000-000000000000', 'Was priorisiere ich bei einer Struktur für eine Autovervollständigung?', 3, '[{"text": "Schnelle Suche", "correct": true, "because": "Nutzer erwarten sofortige Ergebnisse"}, {"text": "Einfügegeschwindigkeit", "correct": false, "because": "Sekundär bei statischen Daten"}, {"text": "Speicherbedarf", "correct": false, "because": "Weniger kritisch"}]'),

-- 15. Aussagenprüfung (Kombinierte Aussagenprüfung)
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen korrekt? a) Ein Baum ist gut für sortierte Daten. b) Eine HashMap ist besser dafür.', 3, '[{"text": "Nur a) stimmt", "correct": true, "because": "HashMap sortiert nicht"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist korrekt"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),

-- 16. Multiple-Choice-Frage (Praktisch)
('00000000-0000-0000-0000-000000000000', 'Welche Strukturen helfen bei einem Szenario mit häufigen Lese- und Schreibzugriffen?', 5, '[{"text": "HashMap", "correct": true, "because": "O(1) für beide Operationen"}, {"text": "ArrayList", "correct": true, "because": "Schnelle Lesezugriffe mit Index"}, {"text": "Stack", "correct": false, "because": "Nur LIFO-Zugriff"}, {"text": "Baum", "correct": false, "because": "O(log n) Zugriff"}]'),

-- 17. Ausschlussfrage (Analytisch)
('00000000-0000-0000-0000-000000000000', 'Was ist bei einer Struktur für eine Chat-Historie unwichtig?', 3, '[{"text": "Reihenfolge", "correct": false, "because": "Kernmerkmal für Chronologie"}, {"text": "Schneller Zugriff", "correct": false, "because": "Wichtig für Anzeige"}, {"text": "Sortierfähigkeit", "correct": true, "because": "Chronologie zählt, nicht alphabetisch"}]'),

-- 18. Single-Choice-Frage (Rückblick-Frage)
('00000000-0000-0000-0000-000000000000', 'Wie war das nochmal mit der Wahl? Ist eine Queue immer die beste Wahl für chronologische Daten?', 3, '[{"text": "Nein", "correct": true, "because": "Listen oder Arrays können auch passen"}, {"text": "Ja", "correct": false, "because": "Queue ist nur eine Option"}]'),

-- 19. Wahr/Falsch-Frage (Erinnerungsfrage)
('00000000-0000-0000-0000-000000000000', 'Kannst du dich erinnern, ob ein Baum immer ausbalanciert sein muss, um nützlich zu sein?', 2, '[{"text": "Nein", "correct": true, "because": "Auch unausbalanciert funktional"}, {"text": "Ja", "correct": false, "because": "Balance optimiert nur Effizienz"}]'),

-- 20. Single-Choice-Frage (Praktisch)
('00000000-0000-0000-0000-000000000000', 'Welche Struktur wähle ich für eine Aufgabe, bei der ich schnell prüfen muss, ob ein Element existiert?', 4, '[{"text": "HashSet", "correct": true, "because": "O(1) für Contains-Operation"}, {"text": "ArrayList", "correct": false, "because": "O(n) für Suche"}, {"text": "Queue", "correct": false, "because": "Keine schnelle Suche"}]');

