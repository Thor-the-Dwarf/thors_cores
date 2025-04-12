-- questions.sql (Front Side Bus - Schnittstelle zwischen CPU und Speicher, z. B. für Systemintegration)

INSERT INTO temporary_questions (essence_fk, text, points, options) VALUES
('00000000-0000-0000-0000-000000000000', 'Ist der Front Side Bus (FSB) dasselbe wie der Back Side Bus?', 2, '[{"text": "No", "correct": true, "because": "CPU-Speicher vs. Cache"}, {"text": "Yes", "correct": false, "because": "Different functions"}]');