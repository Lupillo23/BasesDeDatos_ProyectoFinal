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

CREATE OR REPLACE FUNCTION validar_tecnico_sin_honorario()
RETURNS TRIGGER AS $$
DECLARE
    honorario_activo BOOLEAN;
BEGIN
    -- Verificar si tiene honorario activo
    SELECT TRUE INTO honorario_activo
    FROM Honorario
    WHERE id_persona = NEW.id_persona
    AND (fecha_fin IS NULL OR fecha_fin > CURRENT_DATE);
    
    IF honorario_activo THEN
        RAISE EXCEPTION 'No se puede contratar como técnico académico mientras esté activo como honorario';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tecnico_sin_honorario
BEFORE INSERT OR UPDATE ON Tecnico_Academico
FOR EACH ROW
EXECUTE FUNCTION validar_tecnico_sin_honorario();

-- Finalizar beca automáticamente al contratar como honorario
CREATE OR REPLACE PROCEDURE finalizar_beca_contratar_honorario(
    p_id_persona VARCHAR(5),
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Finalizar la beca si existe
    UPDATE Becario 
    SET fecha_fin_beca = CURRENT_DATE
    WHERE id_persona = p_id_persona
    AND (fecha_fin_beca IS NULL OR fecha_fin_beca > CURRENT_DATE);
    
    -- Insertar como honorario
    INSERT INTO Honorario (id_persona, fecha_inicio, fecha_fin)
    VALUES (p_id_persona, p_fecha_inicio, p_fecha_fin);
    
    COMMIT;
END;
$$;

-- Finalizar honorario automáticamente al contratar como técnico
CREATE OR REPLACE PROCEDURE finalizar_honorario_contratar_tecnico(
    p_id_persona VARCHAR(5),
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Finalizar el honorario si existe
    UPDATE Honorario 
    SET fecha_fin = CURRENT_DATE
    WHERE id_persona = p_id_persona
    AND (fecha_fin IS NULL OR fecha_fin > CURRENT_DATE);
    
    -- Insertar como técnico
    INSERT INTO Tecnico_Academico (id_persona, fecha_inicio, fecha_fin)
    VALUES (p_id_persona, p_fecha_inicio, p_fecha_fin);
    
    COMMIT;
END;
$$;

CREATE OR REPLACE VIEW estado_estudiantes AS
SELECT 
    p.id_persona,
    p.nombre,
    p.ape_pat,
    p.ape_mat,
    CASE 
        WHEN b.id_persona IS NOT NULL AND (b.fecha_fin_beca IS NULL OR b.fecha_fin_beca > CURRENT_DATE) THEN 'Becario Activo'
        WHEN b.id_persona IS NOT NULL THEN 'Ex-Becario'
        ELSE 'No Becario'
    END AS estado_beca,
    CASE 
        WHEN ss.id_persona IS NOT NULL THEN 'Servicio Social Realizado'
        ELSE 'Sin Servicio Social'
    END AS estado_servicio_social,
    CASE 
        WHEN h.id_persona IS NOT NULL AND (h.fecha_fin IS NULL OR h.fecha_fin > CURRENT_DATE) THEN 'Honorario Activo'
        WHEN h.id_persona IS NOT NULL THEN 'Ex-Honorario'
        ELSE 'No Honorario'
    END AS estado_honorario,
    CASE 
        WHEN ta.id_persona IS NOT NULL AND (ta.fecha_fin IS NULL OR ta.fecha_fin > CURRENT_DATE) THEN 'Técnico Activo'
        WHEN ta.id_persona IS NOT NULL THEN 'Ex-Técnico'
        ELSE 'No Técnico'
    END AS estado_tecnico
FROM 
    Persona p
LEFT JOIN Estudiante e ON p.id_persona = e.id_persona
LEFT JOIN Becario b ON e.id_persona = b.id_persona
LEFT JOIN Servicio_Social ss ON p.id_persona = ss.id_persona
LEFT JOIN Honorario h ON p.id_persona = h.id_persona
LEFT JOIN Tecnico_Academico ta ON p.id_persona = ta.id_persona
WHERE p.tipo_persona = 'E';

-- Permitir solo a admin gestionar estas tablas críticas
REVOKE ALL ON Servicio_Social, Becario, Honorario, Tecnico_Academico FROM operador, reportes;
GRANT SELECT ON Servicio_Social, Becario, Honorario, Tecnico_Academico TO reportes;
GRANT SELECT, INSERT, UPDATE ON Servicio_Social, Becario, Honorario, Tecnico_Academico TO operador;

-- Permitir ejecución de procedimientos solo a admin y operador
GRANT EXECUTE ON PROCEDURE finalizar_beca_contratar_honorario TO operador;
GRANT EXECUTE ON PROCEDURE finalizar_honorario_contratar_tecnico TO operador;

