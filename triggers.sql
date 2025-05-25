CREATE OR REPLACE FUNCTION validar_persona_honorario()
RETURNS TRIGGER AS $$
DECLARE
    es_estudiante BOOLEAN;
    becario_activo BOOLEAN := FALSE;
    ss_activo BOOLEAN := FALSE;
BEGIN
    -- Primero verificar si es estudiante (no debería serlo)
    SELECT TRUE INTO es_estudiante
    FROM Persona
    WHERE id_persona = NEW.id_persona AND tipo_persona = 'E';
    
    IF es_estudiante THEN
        RAISE EXCEPTION 'Un estudiante no puede ser registrado como personal honorario';
    END IF;

    -- Verificar si está activo como becario
    SELECT TRUE INTO becario_activo
    FROM Becario b
    JOIN Estudiante e ON b.id_persona = e.id_persona
    WHERE b.id_persona = NEW.id_persona
      AND b.recibe_beca = TRUE
      AND (SELECT fecha_fin FROM Honorario WHERE id_persona = NEW.id_persona) IS NULL;

    -- Verificar si está activo en servicio social
    SELECT TRUE INTO ss_activo
    FROM Servicio_Social
    WHERE id_persona = NEW.id_persona
      AND (fecha_fin IS NULL OR fecha_fin > CURRENT_DATE);

    -- Si está activo como alguno, lanzar error
    IF becario_activo OR ss_activo THEN
        RAISE EXCEPTION 'La persona no puede registrarse como HONORARIO mientras esté activa como BECARIO o en SERVICIO SOCIAL.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_honorario
BEFORE INSERT OR UPDATE ON Honorario
FOR EACH ROW
EXECUTE FUNCTION validar_persona_honorario();

CREATE OR REPLACE FUNCTION validar_tecnico_academico()
RETURNS TRIGGER AS $$
DECLARE
    es_estudiante BOOLEAN;
    honorario_activo BOOLEAN := FALSE;
BEGIN
    -- Primero verificar si es estudiante (no debería serlo)
    SELECT TRUE INTO es_estudiante
    FROM Persona
    WHERE id_persona = NEW.id_persona AND tipo_persona = 'E';
    
    IF es_estudiante THEN
        RAISE EXCEPTION 'Un estudiante no puede ser registrado como técnico académico';
    END IF;

    -- Verificar si la persona está activa como honorario
    SELECT TRUE INTO honorario_activo
    FROM Honorario
    WHERE id_persona = NEW.id_persona
      AND (fecha_fin IS NULL OR fecha_fin > CURRENT_DATE);

    -- Si está activo, lanzar error
    IF honorario_activo THEN
        RAISE EXCEPTION 'La persona no puede registrarse como TÉCNICO ACADÉMICO si está activa como PERSONAL DE HONORARIOS.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_tecnico_academico
BEFORE INSERT OR UPDATE ON Tecnico_Academico
FOR EACH ROW
EXECUTE FUNCTION validar_tecnico_academico();