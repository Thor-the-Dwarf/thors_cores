INSERT INTO temporary_questions (essence_fk, text, points, options) VALUES
-- Prüfung 1: Planen eines Softwareprodukts > Kundenbeziehungen > Kundenbeziehungen aus rechtlicher Sicht
-- Ja/Nein-Fragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Sind Kundenbeziehungen aus rechtlicher Sicht ausschließlich durch das Bürgerliche Gesetzbuch (BGB) geregelt?', 2,
'[{"text": "Nein", "correct": true, "because": "Auch Gesetze wie UWG oder DSGVO spielen eine Rolle"}, {"text": "Ja", "correct": false, "because": "Nur BGB wäre zu eingeschränkt"}]'),
('00000000-0000-0000-0000-000000000000', 'Müssen Kundenbeziehungen aus rechtlicher Sicht zwingend schriftlich dokumentiert werden?', 2,
'[{"text": "Nein", "correct": true, "because": "Formfreiheit gilt, es sei denn, gesetzlich vorgeschrieben"}, {"text": "Ja", "correct": false, "because": "Schriftform ist nicht immer Pflicht"}]'),
('00000000-0000-0000-0000-000000000000', 'Ist ein Vertrag mit einem Kunden rechtlich ungültig, wenn er gegen die guten Sitten verstößt?', 2,
'[{"text": "Ja", "correct": true, "because": "§ 138 BGB stuft solche Verträge als nichtig"}, {"text": "Nein", "correct": false, "because": "Sittenwidrigkeit führt zur Nichtigkeit"}]'),
('00000000-0000-0000-0000-000000000000', 'Kann ein Unternehmen rechtlich verpflichtet sein, Kundenbeziehungen auch nach Vertragsende zu pflegen?', 2,
'[{"text": "Nein", "correct": true, "because": "Pflicht endet meist mit Vertrag, außer bei Nachwirkungen"}, {"text": "Ja", "correct": false, "because": "Nachpflege ist nicht generell vorgeschrieben"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind Kundenbeziehungen aus rechtlicher Sicht unabhängig von Datenschutzvorschriften zu betrachten?', 2,
'[{"text": "Nein", "correct": true, "because": "DSGVO beeinflusst Umgang mit Kundendaten"}, {"text": "Ja", "correct": false, "because": "Datenschutz ist integraler Bestandteil"}]'),

-- Single-Choice-Fragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Welches Gesetz regelt primär den unlauteren Wettbewerb im Kontext von Kundenbeziehungen?', 2,
'[{"text": "UWG", "correct": true, "because": "Gesetz gegen unlauteren Wettbewerb ist maßgeblich"}, {"text": "BDSG", "correct": false, "because": "Datenschutz, nicht Wettbewerb"}, {"text": "HGB", "correct": false, "because": "Handelsrecht, nicht spezifisch"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Rechtsfolge tritt ein, wenn ein Unternehmen Kunden durch irreführende Angaben gewinnt?', 3,
'[{"text": "Schadensersatzpflicht", "correct": true, "because": "§ 3 UWG kann dies auslösen"}, {"text": "Automatische Vertragsverlängerung", "correct": false, "because": "Keine rechtliche Folge"}, {"text": "Steuerliche Vergünstigung", "correct": false, "because": "Irreführung wird nicht belohnt"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Instanz kann bei Streitigkeiten über Kundenbeziehungen rechtlich bindend entscheiden?', 2,
'[{"text": "Gericht", "correct": true, "because": "Nur Gerichte fällen bindende Urteile"}, {"text": "Schlichtungsstelle", "correct": false, "because": "Vorschläge sind nicht bindend"}, {"text": "Unternehmensleitung", "correct": false, "because": "Keine rechtliche Autorität"}]'),
('00000000-0000-0000-0000-000000000000', 'Welcher rechtliche Grundsatz schützt Kunden vor versteckten Klauseln in Verträgen?', 2,
'[{"text": "Transparenz", "correct": true, "because": "AGB-Gesetz fordert Klarheit"}, {"text": "Zweckbindung", "correct": false, "because": "Datenschutz, nicht Vertrag"}, {"text": "Datenminimierung", "correct": false, "because": "Datenschutz, nicht Klauseln"}]'),
('00000000-0000-0000-0000-000000000000', 'Was ist die rechtliche Grundlage für die Verwendung von Kundendaten in Kundenbeziehungen?', 2,
'[{"text": "Einwilligung", "correct": true, "because": "DSGVO Art. 6 verlangt Zustimmung"}, {"text": "Unternehmensinteresse", "correct": false, "because": "Nicht ausreichend allein"}, {"text": "Branchenüblichkeit", "correct": false, "because": "Keine rechtliche Basis"}]'),

-- Multiple-Choice-Fragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Welche Gesetze sind für Kundenbeziehungen aus rechtlicher Sicht relevant?', 4,
'[{"text": "BGB", "correct": true, "because": "Regelt Verträge"}, {"text": "UWG", "correct": true, "because": "Unlauterer Wettbewerb"}, {"text": "DSGVO", "correct": true, "because": "Datenschutz"}, {"text": "EStG", "correct": false, "because": "Steuerrecht, nicht Kunden"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Aspekte fallen unter die rechtliche Betrachtung von Kundenbeziehungen?', 3,
'[{"text": "Vertragsschluss", "correct": true, "because": "BGB regelt dies"}, {"text": "Werbemaßnahmen", "correct": true, "because": "UWG relevant"}, {"text": "Datenverarbeitung", "correct": true, "because": "DSGVO zwingend"}, {"text": "Produktentwicklung", "correct": false, "because": "Technisch, nicht rechtlich"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche rechtlichen Pflichten hat ein Unternehmen gegenüber Kunden?', 4,
'[{"text": "Information über Vertragsbedingungen", "correct": true, "because": "Transparenzpflicht"}, {"text": "Schutz personenbezogener Daten", "correct": true, "because": "DSGVO Art. 5"}, {"text": "Einhaltung fairer Wettbewerbspraktiken", "correct": true, "because": "UWG"}, {"text": "Jährliche Geschenke", "correct": false, "because": "Keine rechtliche Pflicht"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche Verstöße können rechtlich bei Kundenbeziehungen sanktioniert werden?', 3,
'[{"text": "Irreführende Werbung", "correct": true, "because": "UWG § 5"}, {"text": "Unzureichender Datenschutz", "correct": true, "because": "DSGVO Verstöße"}, {"text": "Wettbewerbsverzerrung", "correct": true, "because": "UWG § 3"}, {"text": "Zu späte Lieferung", "correct": false, "because": "Vertragsrecht, nicht spezifisch"}]'),
('00000000-0000-0000-0000-000000000000', 'Welche rechtlichen Instrumente schützen Kunden in Kundenbeziehungen?', 3,
'[{"text": "Widerrufsrecht", "correct": true, "because": "BGB § 355"}, {"text": "Datenschutzrechte", "correct": true, "because": "DSGVO Art. 12-22"}, {"text": "Wettbewerbsregeln", "correct": true, "because": "UWG schützt vor Täuschung"}, {"text": "Steuererleichterungen", "correct": false, "because": "Kein Schutzmechanismus"}]'),

-- Richtig/Falsch-Kombinationsfragen (5 Stück)
('00000000-0000-0000-0000-000000000000', 'Sind folgende Aussagen richtig? a) Das UWG schützt Kunden vor irreführender Werbung. b) Die DSGVO gilt nur für EU-Bürger.', 3,
'[{"text": "Nur a) stimmt", "correct": true, "because": "UWG ja, DSGVO gilt für Datenverarbeitung in EU"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen korrekt? a) Ein Vertrag kann wegen Verstoßes gegen das AGB-Gesetz unwirksam sein. b) Kundenbeziehungen sind rechtlich von Ethik unabhängig.', 3,
'[{"text": "Nur a) stimmt", "correct": true, "because": "AGB-Gesetz ja, Ethik beeinflusst Recht"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen richtig? a) Die DSGVO verlangt eine Einwilligung für die Datenverarbeitung. b) Das BGB regelt ausschließlich Kundenbeziehungen.', 3,
'[{"text": "Nur a) stimmt", "correct": true, "because": "DSGVO ja, BGB allgemeines Vertragsrecht"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind folgende Aussagen korrekt? a) Versteckte Klauseln in AGB sind rechtlich zulässig. b) Kunden haben ein Widerrufsrecht bei Fernabsatzverträgen.', 3,
'[{"text": "Nur b) stimmt", "correct": true, "because": "Versteckte Klauseln nein, Widerruf ja"}, {"text": "Beides stimmt", "correct": false, "because": "a) ist falsch"}, {"text": "Nur a) stimmt", "correct": false, "because": "b) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "b) ist richtig"}]'),
('00000000-0000-0000-0000-000000000000', 'Sind diese Aussagen richtig? a) Ein Verstoß gegen das UWG kann zu Schadensersatz führen. b) Datenschutzverletzungen sind rechtlich irrelevant für Kundenbeziehungen.', 3,
'[{"text": "Nur a) stimmt", "correct": true, "because": "UWG ja, Datenschutz ist relevant"}, {"text": "Beides stimmt", "correct": false, "because": "b) ist falsch"}, {"text": "Nur b) stimmt", "correct": false, "because": "a) ist richtig"}, {"text": "Beides falsch", "correct": false, "because": "a) ist richtig"}]');

