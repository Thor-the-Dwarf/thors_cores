-- Tabellen in der richtigen Reihenfolge droppen
DROP TABLE IF EXISTS option_explanations;
DROP TABLE IF EXISTS option;
DROP TABLE IF EXISTS explanation;
DROP TABLE IF EXISTS question;
DROP TABLE IF EXISTS question_type;
DROP TABLE IF EXISTS level_cores;
DROP TABLE IF EXISTS sub_levels;
DROP TABLE IF EXISTS essence;
DROP TABLE IF EXISTS core;
DROP TABLE IF EXISTS levels;

-- Levels-Tabelle erstellen
CREATE TABLE levels (
    level_pk UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    details TEXT
);

-- Core-Tabelle erstellen
CREATE TABLE core (
    core_pk UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    details TEXT
);

-- Essence-Tabelle erstellen
CREATE TABLE essence (
    essence_pk UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    core_fk UUID NOT NULL,
    name TEXT NOT NULL,
    FOREIGN KEY (core_fk) REFERENCES core(core_pk) ON DELETE CASCADE
);

-- SubLevels-Tabelle erstellen (Level-Hierarchie)
CREATE TABLE sub_levels (
    sublevel_pk UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_level_fk UUID NOT NULL,
    child_level_fk UUID NOT NULL,
    FOREIGN KEY (parent_level_fk) REFERENCES levels(level_pk) ON DELETE CASCADE,
    FOREIGN KEY (child_level_fk) REFERENCES levels(level_pk) ON DELETE CASCADE
);
ALTER TABLE sub_levels ADD CONSTRAINT check_no_cycles CHECK (parent_level_fk <> child_level_fk);

-- LevelCores-Tabelle erstellen (Verknüpfung Level ↔ Core)
CREATE TABLE level_cores (
    level_core_pk UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_level_fk UUID NOT NULL,
    core_fk UUID NOT NULL,
    FOREIGN KEY (parent_level_fk) REFERENCES levels(level_pk) ON DELETE CASCADE,
    FOREIGN KEY (core_fk) REFERENCES core(core_pk) ON DELETE CASCADE
);

-- Question-Tabelle erstellen
CREATE TABLE question (
    question_pk UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    essence_fk UUID,
    text TEXT NOT NULL,
    points INTEGER NOT NULL CHECK (points >= 0),
    options JSONB NOT NULL,  -- JSONB für Antwortoptionen
    FOREIGN KEY (essence_fk) REFERENCES essence(essence_pk) ON DELETE CASCADE
);

-- Funktion zur JSONB-Validierung in question.options
CREATE OR REPLACE FUNCTION validate_question_options()
RETURNS TRIGGER AS $$
DECLARE
    option JSONB;
BEGIN
    -- Überprüfe, ob 'options' ein Array ist
    IF jsonb_typeof(NEW.options) <> 'array' THEN
        RAISE EXCEPTION 'options muss ein JSON-Array sein!';
    END IF;

    -- Durchlaufe alle Elemente in 'options'
    FOR option IN SELECT * FROM jsonb_array_elements(NEW.options)
    LOOP
        -- Prüfe, ob "text" ein String ist
        IF jsonb_typeof(option->'text') <> 'string' THEN
            RAISE EXCEPTION 'Jede Option muss ein "text"-Feld mit einem String enthalten!';
        END IF;

        -- Prüfe, ob "because" ein String ist
        IF jsonb_typeof(option->'because') <> 'string' THEN
            RAISE EXCEPTION 'Jede Option muss ein "because"-Feld mit einem String enthalten!';
        END IF;

        -- Prüfe, ob "correct" ein Boolean ist
        IF jsonb_typeof(option->'correct') <> 'boolean' THEN
            RAISE EXCEPTION 'Jede Option muss ein "correct"-Feld mit einem Boolean enthalten!';
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger für die JSONB-Validierung hinzufügen
CREATE TRIGGER check_question_options
BEFORE INSERT OR UPDATE ON question
FOR EACH ROW
EXECUTE FUNCTION validate_question_options();
