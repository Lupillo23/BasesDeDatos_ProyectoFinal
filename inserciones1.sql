-- Insertar 100 direcciones de prueba
DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Direccion (id_direccion, no_ext, clave_localidad, alcaldia, no_int, clave_municipio, calle, colonia, cp)
        VALUES (
Expand
message.txt
8 KB
﻿
-- Insertar 100 direcciones de prueba
DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Direccion (id_direccion, no_ext, clave_localidad, alcaldia, no_int, clave_municipio, calle, colonia, cp)
        VALUES (
            LPAD(i::text, 5, '0'),
            'EXT' || i,
            'LOC' || i,
            'Alcaldia ' || i,
            'INT' || i,
            'MUN' || i,
            'Calle ' || i,
            'Colonia ' || i,
            'CP' || i
        );
    END LOOP;
END$$;

---- comando para consultar registros 
SELECT COUNT(*) FROM Direccion;

-- Insertar 200 personas (100 estudiantes y 100 personal)
DO $$
BEGIN
    FOR i IN 1..200 LOOP
        INSERT INTO Persona (id_persona, nombre, curp, rfc, ape_pat, ape_mat, tel_fijo, correo, tel_mov, tipo_persona, id_direccion)
        VALUES (
            LPAD(i::text, 5, '0'),
            'Nombre_' || i,
            'CURP' || LPAD(i::text, 14, '0'),
            'RFC' || LPAD(i::text, 10, '0'),
            'ApellidoP_' || i,
            'ApellidoM_' || i,
            '5555' || LPAD(i::text, 6, '0'),
            'persona' || i || '@mail.com',
            '04455' || LPAD(i::text, 6, '0'),
            CASE WHEN i <= 100 THEN 'E' ELSE 'P' END,
            LPAD(((i - 1) % 100 + 1)::text, 5, '0')
        );
    END LOOP;
END$$;

-- Insertar 100 estudiantes

DO $$
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Padecimiento (no_cuenta, id_padecimiento, descripcion)
        VALUES (
            'NC' || i,
            LPAD(i::text, 5, '0'),
            'Descripción de padecimiento ' || i
        );
    END LOOP;
END$$;

DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO Estudiante (
            id_persona, antecedente_DGTIC, carrera, cvu,
            escuela, semestre, promedio, es_becario, no_cuenta, id_padecimiento
        )
        VALUES (
            LPAD(i::text, 5, '0'),
            'Antecedente ' || i,
            'Carrera ' || i,
            100000 + i,
            'Escuela ' || i,
            (i % 9) + 1,
            ROUND((2.5 + random() * 1.5)::numeric, 2),
            CASE WHEN i <= 70 THEN TRUE ELSE FALSE END,
            'NC' || ((i - 1) % 50 + 1),
            LPAD(((i - 1) % 50 + 1)::text, 5, '0')
        );
    END LOOP;
END$$;

--- servicio social 
DO $$
BEGIN
    FOR i IN 71..100 LOOP
        EXIT WHEN i > 100;
        INSERT INTO Servicio_Social (id_persona, fecha_inicio, fecha_fin, programa_alterno)
        VALUES (
            LPAD(i::text, 5, '0'),
            DATE '2023-01-01' + (i * INTERVAL '3 days'),
            DATE '2023-12-01' + (i * INTERVAL '3 days'),
            'Programa Alterno ' || i
        );
    END LOOP;
END$$;

DO $$
DECLARE
    c INT := 0;
BEGIN
    FOR i IN 1..100 LOOP
        -- Primer contacto
        INSERT INTO Contacto_Emergencia (
            id_contacto, id_persona, nombre, parentesco, telefono_fijo, correo, telefono_celular
        )
        VALUES (
            'C' || i || 'A',
            LPAD(i::text, 5, '0'),
            'Contacto1_' || i,
            'Padre',
            '555123' || i,
            'contacto1_' || i || '@mail.com',
            '04455' || i || '1'
        );

        -- Segundo contacto (solo si no supera 150)
        c := c + 2;
        EXIT WHEN c > 150;

        INSERT INTO Contacto_Emergencia (
            id_contacto, id_persona, nombre, parentesco, telefono_fijo, correo, telefono_celular
        )
        VALUES (
            'C' || i || 'B',
            LPAD(i::text, 5, '0'),
            'Contacto2_' || i,
            'Madre',
            '555456' || i,
            'contacto2_' || i || '@mail.com',
            '04455' || i || '2'
        );
    END LOOP;
END$$;

---- 
DO $$
BEGIN
    FOR i IN 1..20 LOOP
        INSERT INTO Equipo (id_equipo, nombre, fecha_creacion)
        VALUES (
            LPAD(i::text, 5, '0'),
            'Equipo_' || i,
            DATE '2022-01-01' + (i * INTERVAL '15 days')
        );
    END LOOP;
END$$;

---- proyecto 30 registros 

DO $$
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO Proyecto (id_proyecto, nombre, fecha_inicio, fecha_fin, id_equipo_responsable, id_personal_asignado)
        VALUES (
            LPAD(i::text, 5, '0'),
            'Proyecto_' || i,
            DATE '2023-01-01' + (i * INTERVAL '10 days'),
            DATE '2024-01-01' + (i * INTERVAL '10 days'),
            LPAD(((i - 1) % 20 + 1)::text, 5, '0'),
            LPAD(((i - 1) % 50 + 101)::text, 5, '0') -- personal del 101 al 150
        );
    END LOOP;
END$$;

DO $$
BEGIN
    FOR i IN 101..150 LOOP
        INSERT INTO Personal (id_persona, fecha_nac, tipo)
        VALUES (
            LPAD(i::text, 5, '0'),
            DATE '1980-01-01' + (i * INTERVAL '10 days'),
            CASE WHEN i <= 125 THEN 'H' ELSE 'T' END
        );
    END LOOP;
END$$;

--- proyecto
DO $$
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO Proyecto (id_proyecto, nombre, fecha_inicio, fecha_fin, id_equipo_responsable, id_personal_asignado)
        VALUES (
            LPAD(i::text, 5, '0'),
            'Proyecto_' || i,
            DATE '2023-01-01' + (i * INTERVAL '10 days'),
            DATE '2024-01-01' + (i * INTERVAL '10 days'),
            LPAD(((i - 1) % 20 + 1)::text, 5, '0'),      -- 20 equipos
            LPAD(((i - 1) % 50 + 101)::text, 5, '0')     -- personal del 101 al 150
        );
    END LOOP;
END$$;

--- institucion 15 registros a personas existentes
DO $$
BEGIN
    FOR i IN 1..15 LOOP
        INSERT INTO Institucion (nombre, telefono, carrera_afiliada, direccion, id_persona)
        VALUES (
            'Institución ' || i,
            '555100' || i,
            'Carrera Afiliada ' || i,
            'Dirección completa de institución ' || i,
            LPAD(((i - 1) % 200 + 1)::text, 5, '0')
        );
    END LOOP;
END$$;

---- modulo capacitacion 10 registros
DO $$
BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO Modulo_Capacitacion (id_modulo, descripcion, nombre)
        VALUES (
            'MOD' || i,
            'Descripción del módulo ' || i,
            'Módulo ' || i
        );
    END LOOP;
END$$;

----- 15 registros 1 a 3 por cada capacitacion
DO $$
DECLARE
    pid INT := 1;
BEGIN
    FOR i IN 1..5 LOOP
        FOR j IN 1..3 LOOP
            INSERT INTO Periodo (id_capacitacion, id_periodo, num_periodo, fecha_inicio, fecha_fin)
            VALUES (
                i,
                pid,
                j,
                DATE '2023-01-01' + (pid * INTERVAL '20 days'),
                DATE '2023-01-30' + (pid * INTERVAL '20 days')
            );
            pid := pid + 1;
        END LOOP;
    END LOOP;
END$$;

---- capaitacion 50 registros vinculados becarios y módulos
DO $$
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Capacitacion (id_capacitacion, id_becario)
        VALUES (
            ((i - 1) % 10 + 1),      -- ID de módulo (1 a 10)
            LPAD(((i - 1) % 70 + 1)::text, 5, '0')  -- ID de becario (1 a 70)
        );
    END LOOP;
END$$;

SELECT COUNT(*) FROM Becario;

DO $$
BEGIN
    FOR i IN 1..70 LOOP
        INSERT INTO Becario (id_persona, beca, trabajo, recibe_beca, horario_trabajo)
        VALUES (
            LPAD(i::text, 5, '0'),
            'Beca ' || i,
            'Trabajo ' || i,
            TRUE,
            'L-V 9:00-14:00'
        );
    END LOOP;
END$$;

DO $$
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO Capacitacion (id_capacitacion, id_becario)
        VALUES (
            ((i - 1) % 10 + 1),                -- módulo 1 a 10
            LPAD(((i - 1) % 70 + 1)::text, 5, '0')  -- becario 00001 a 00070
        );
    END LOOP;
END$$;

-- pruebas 
-- Verificar cantidad por tabla
SELECT COUNT(*) FROM Direccion;
SELECT COUNT(*) FROM Persona;
SELECT COUNT(*) FROM Estudiante;
SELECT COUNT(*) FROM Becario;
SELECT COUNT(*) FROM Proyecto;
-- etc.

SELECT * FROM Persona;
SELECT * FROM Estudiante;
SELECT * FROM Proyecto;