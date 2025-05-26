-- Database: Proyecto_Final

-- DROP DATABASE IF EXISTS "Proyecto_Final";

-- ====================
-- TABLAS PRINCIPALES
-- ====================

CREATE TABLE Direccion (
    id_direccion VARCHAR(5) PRIMARY KEY NOT NULL,
    no_ext VARCHAR(10) NOT NULL,
    clave_localidad VARCHAR(20) NOT NULL,
    alcaldia VARCHAR(50) NOT NULL,
    no_int VARCHAR(10) NOT NULL,
    clave_municipio VARCHAR(20) NOT NULL,
    calle VARCHAR(100) NOT NULL,
    colonia VARCHAR(100) NOT NULL,
    cp VARCHAR(10)
);

CREATE TABLE Persona (
    id_persona VARCHAR(5) PRIMARY KEY NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    curp VARCHAR(18) NOT NULL,
    rfc VARCHAR(13) NOT NULL,
    ape_pat VARCHAR(50) NOT NULL,
    ape_mat VARCHAR(50) NOT NULL,
    tel_fijo VARCHAR(15) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    tel_mov VARCHAR(15) NOT NULL,
    tipo_persona CHAR(1) NOT NULL, -- 'P': personal, 'E': estudiante
    id_direccion VARCHAR(5) NOT NULL REFERENCES Direccion(id_direccion)
);

ALTER TABLE Persona
ALTER COLUMN id_persona TYPE VARCHAR(5);

-- ====================
-- ESTUDIANTE Y BECARIO
-- ====================
CREATE TABLE Padecimiento (
    no_cuenta VARCHAR(9) NOT NULL,
	id_padecimiento VARCHAR(5) NOT NULL,
    descripcion TEXT NOT NULL,
    PRIMARY KEY(no_cuenta, id_padecimiento)
);

-- Tabla Estudiante
CREATE TABLE Estudiante (
    id_persona VARCHAR(5) PRIMARY KEY REFERENCES Persona(id_persona),
    antecedente_DGTIC VARCHAR(100) NOT NULL,
    carrera VARCHAR(100) NOT NULL,
    cvu INT NOT NULL,
    escuela VARCHAR(100) NOT NULL,
    semestre INT NOT NULL,
    promedio NUMERIC(3,2) NOT NULL,
    es_becario BOOLEAN NOT NULL,
    no_cuenta VARCHAR(9) NOT NULL,
    id_padecimiento VARCHAR(5) NOT NULL,
    -- Definir una llave foránea compuesta que referencia Padecimiento
    FOREIGN KEY (no_cuenta, id_padecimiento) 
        REFERENCES Padecimiento(no_cuenta, id_padecimiento)
);

CREATE TABLE Becario (
    id_persona VARCHAR(5) NOT NULL PRIMARY KEY REFERENCES Estudiante(id_persona),
    beca VARCHAR(100) NOT NULL,
    trabajo VARCHAR(100) NOT NULL,
    recibe_beca BOOLEAN NOT NULL,
    horario_trabajo VARCHAR(100) NOT NULL
);

-- ====================
-- DATOS ESCOLARES, CONTACTO Y PADECIMIENTO
-- ====================

CREATE TABLE Datos_Escolares (
    id_persona VARCHAR(5) NOT NULL PRIMARY KEY REFERENCES Estudiante(id_persona),
    escuela VARCHAR(100) NOT NULL,
    carrera VARCHAR(100) NOT NULL,
    creditos INT NULL NULL,
    semestre INT NOT NULL,
    promedio NUMERIC(3,2) NOT NULL
);

CREATE TABLE Contacto_Emergencia (
    id_contacto VARCHAR(5) NOT NULL,
    id_persona VARCHAR(5) NOT NULL REFERENCES Persona(id_persona),
    nombre VARCHAR(100) NOT NULL,
    parentesco VARCHAR(50) NOT NULL,
    telefono_fijo VARCHAR(15) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    telefono_celular VARCHAR(15) NOT NULL,
    PRIMARY KEY(id_contacto, id_persona)
);

-- ====================
-- PERSONAL Y ESPECIALIZACIONES
-- ====================

CREATE TABLE Personal (
    id_persona VARCHAR(5) NOT NULL PRIMARY KEY REFERENCES Persona(id_persona),
    fecha_nac DATE NOT NULL,
    tipo CHAR(1) NOT NULL -- 'H' Honorario, 'T' Técnico Académico
);

CREATE TABLE Honorario (
    id_persona VARCHAR(5) NOT NULL PRIMARY KEY REFERENCES Personal(id_persona),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL
);

CREATE TABLE Tecnico_Academico (
    id_persona VARCHAR(5) NOT NULL PRIMARY KEY REFERENCES Personal(id_persona),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL
);

-- ====================
-- SERVICIO SOCIAL
-- ====================

CREATE TABLE Servicio_Social (
    id_persona VARCHAR(5) NOT NULL PRIMARY KEY REFERENCES Persona(id_persona),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    programa_alterno VARCHAR(100) NOT NULL
);

-- ====================
-- EQUIPO Y PROYECTO
-- ====================

CREATE TABLE Equipo (
    id_equipo VARCHAR(5) NOT NULL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_creacion DATE NOT NULL
);

CREATE TABLE Proyecto (
    id_proyecto VARCHAR(5) NOT NULL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
	id_equipo_responsable VARCHAR(5) NOT NULL REFERENCES Equipo(id_equipo),
    id_personal_asignado VARCHAR(5) NOT NULL REFERENCES Personal(id_persona)
);

-- ====================
-- ASIGNACION DE PERSONAS A EQUIPOS
-- ====================

CREATE TABLE Asignacion (
    id_asignacion VARCHAR(5) NOT NULL PRIMARY KEY,
    fecha_inicio DATE,
    fecha_fin DATE,
    id_equipo VARCHAR(5) NOT NULL REFERENCES Equipo(id_equipo),
    id_persona VARCHAR(5) NOT NULL REFERENCES Persona(id_persona)
);

-- ====================
-- INSTITUCION
-- ====================

CREATE TABLE Institucion (
    id_institucion SERIAL NOT NULL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    carrera_afiliada VARCHAR(100) NOT NULL,
    direccion TEXT NOT NULL,
    id_persona VARCHAR(5) NOT NULL REFERENCES Persona(id_persona)
);

-- ====================
-- CAPACITACION
-- ====================

CREATE TABLE Modulo_Capacitacion (
    id_capacitacion SERIAL NOT NULL PRIMARY KEY,
    id_modulo VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Periodo (
    id_capacitacion SERIAL NOT NULL REFERENCES Modulo_Capacitacion(id_capacitacion),
    id_periodo SERIAL NOT NULL,
    num_periodo INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    PRIMARY KEY(id_capacitacion, id_periodo)
);

CREATE TABLE Capacitacion (
    id_capacitacion SERIAL NOT NULL REFERENCES Modulo_Capacitacion(id_capacitacion),
    id_becario VARCHAR(5) NOT NULL REFERENCES Becario(id_persona),
    PRIMARY KEY(id_capacitacion, id_becario)
);

-- Función que verifica el número de contactos
CREATE OR REPLACE FUNCTION validar_max_contactos()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT COUNT(*) FROM Contacto_Emergencia
        WHERE id_persona = NEW.id_persona
    ) >= 2 THEN
        RAISE EXCEPTION 'Un estudiante solo puede tener como máximo 2 contactos de emergencia';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que llama a la función antes del INSERT
CREATE TRIGGER trg_validar_max_contactos
BEFORE INSERT ON Contacto_Emergencia
FOR EACH ROW
EXECUTE FUNCTION validar_max_contactos();
