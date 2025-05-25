CREATE OR REPLACE FUNCTION validar_persona_honorario()
RETURNS TRIGGER AS $$
DECLARE
    becario_activo BOOLEAN;
    ss_activo BOOLEAN;
BEGIN
    -- Verificar si está activo como becario
    SELECT TRUE INTO becario_activo
    FROM Becario
    WHERE id_persona = NEW.id_persona
      AND recibe_beca = TRUE;

    -- Verificar si está activo en servicio social
    SELECT TRUE INTO ss_activo
    FROM Servicio_Social
    WHERE id_persona = NEW.id_persona
      AND (fecha_fin IS NULL OR fecha_fin > CURRENT_DATE);

    -- Si está activo como alguno, lanzar error
    IF becario_activo IS TRUE OR ss_activo IS TRUE THEN
        RAISE EXCEPTION 'La persona no puede registrarse como HONORARIO mientras esté activa como BECARIO o en SERVICIO SOCIAL.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_honorario
BEFORE INSERT ON Honorario
FOR EACH ROW
EXECUTE FUNCTION validar_persona_honorario();
