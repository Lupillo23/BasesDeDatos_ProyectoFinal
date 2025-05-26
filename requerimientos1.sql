-- Modificación a la tabla Servicio_Social para registrar solo una vez por estudiante
ALTER TABLE Servicio_Social ADD COLUMN realizado BOOLEAN NOT NULL DEFAULT FALSE;

-- Modificación a la tabla Becario para llevar control de periodos
ALTER TABLE Becario ADD COLUMN fecha_fin_beca DATE;

CREATE OR REPLACE FUNCTION validar_servicio_social_unico()
RETURNS TRIGGER AS $$
DECLARE
    servicio_previo BOOLEAN;
BEGIN
    -- Verificar si el estudiante ya realizó servicio social
    SELECT realizado INTO servicio_previo
    FROM Servicio_Social
    WHERE id_persona = NEW.id_persona;
    
    IF servicio_previo THEN
        RAISE EXCEPTION 'Un estudiante solo puede realizar servicio social una vez';
    END IF;
    
    -- Marcar como realizado al insertar
    NEW.realizado := TRUE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_servicio_social_unico
BEFORE INSERT ON Servicio_Social
FOR EACH ROW
EXECUTE FUNCTION validar_servicio_social_unico();

CREATE OR REPLACE FUNCTION validar_solapamiento_beca_servicio()
RETURNS TRIGGER AS $$
BEGIN
    -- No se necesita validación especial ya que el solapamiento está permitido
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_solapamiento_beca_servicio
BEFORE INSERT OR UPDATE ON Servicio_Social
FOR EACH ROW
EXECUTE FUNCTION validar_solapamiento_beca_servicio();

CREATE OR REPLACE FUNCTION validar_honorario_sin_beca()
RETURNS TRIGGER AS $$
DECLARE
    beca_activa BOOLEAN;
BEGIN
    -- Verificar si tiene beca activa
    SELECT TRUE INTO beca_activa
    FROM Becario
    WHERE id_persona = NEW.id_persona
    AND (fecha_fin_beca IS NULL OR fecha_fin_beca > CURRENT_DATE);
    
    IF beca_activa THEN
        RAISE EXCEPTION 'No se puede contratar como honorario mientras tenga una beca activa';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_honorario_sin_beca
BEFORE INSERT OR UPDATE ON Honorario
FOR EACH ROW
EXECUTE FUNCTION validar_honorario_sin_beca();



-- Permitir ejecución de procedimientos solo a admin y operador
GRANT EXECUTE ON PROCEDURE finalizar_beca_contratar_honorario TO operador;
GRANT EXECUTE ON PROCEDURE finalizar_honorario_contratar_tecnico TO operador;

