-- Database: Proyecto_Final

-- DROP DATABASE IF EXISTS "Proyecto_Final";

-- ====================
-- TABLAS PRINCIPALES
-- ====================

CREATE TABLE Direccion (
    id_direccion SERIAL PRIMARY KEY,
    no_ext VARCHAR(10),
    clave_localidad VARCHAR(20),
    alcaldia VARCHAR(50),
    no_int VARCHAR(10),
    clave_municipio VARCHAR(20),
    calle VARCHAR(100),
    colonia VARCHAR(100),
    cp VARCHAR(10)
);

CREATE TABLE Persona (
    id_persona SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    curp VARCHAR(18),
    rfc VARCHAR(13),
    ape_pat VARCHAR(50),
    ape_mat VARCHAR(50),
    tel_fijo VARCHAR(15),
    correo VARCHAR(100),
    tel_mov VARCHAR(15),
    tipo_persona CHAR(1), -- 'P': personal, 'E': estudiante
    id_direccion INT REFERENCES Direccion(id_direccion)
);

-- ====================
-- ESTUDIANTE Y BECARIO
-- ====================

CREATE TABLE Estudiante (
    id_persona INT PRIMARY KEY REFERENCES Persona(id_persona),
    antecedente_DGTCI VARCHAR(100),
    carrera VARCHAR(100),
    cvu CONSTRAINT chk_cvu CHECK (cvu ~ '^[0-9]+$'),
    escuela VARCHAR(100),
    semestre INT,
    promedio NUMERIC(3,2),
    es_becario BOOLEAN,
    no_cuenta_padecimientos INT
);

CREATE TABLE Becario (
    id_persona INT PRIMARY KEY REFERENCES Estudiante(id_persona),
    beca VARCHAR(100),
    trabajo VARCHAR(100),
    recibe_beca BOOLEAN,
    horario_trabajo VARCHAR(100)
);

-- ====================
-- DATOS ESCOLARES, CONTACTO Y PADECIMIENTO
-- ====================

CREATE TABLE Datos_Escolares (
    id_persona INT PRIMARY KEY REFERENCES Estudiante(id_persona),
    escuela VARCHAR(100),
    carrera VARCHAR(100),
    creditos INT,
    semestre INT,
    promedio NUMERIC(3,2)
);

CREATE TABLE Contacto_Emergencia (
    id_contacto SERIAL,
    id_persona INT REFERENCES Persona(id_persona),
    nombre VARCHAR(100),
    parentesco VARCHAR(50),
    telefono_fijo VARCHAR(15),
    correo VARCHAR(100),
    telefono_celular VARCHAR(15),
    PRIMARY KEY(id_contacto, id_persona)
);

CREATE TABLE Padecimiento (
    id_cuenta_padecimientos INT,
    id_persona INT REFERENCES Estudiante(id_persona),
    descripcion TEXT,
    PRIMARY KEY(id_cuenta_padecimientos, id_persona)
);

-- ====================
-- PERSONAL Y ESPECIALIZACIONES
-- ====================

CREATE TABLE Personal (
    id_persona INT PRIMARY KEY REFERENCES Persona(id_persona),
    fecha_nac DATE,
    tipo CHAR(1) -- 'H' Honorario, 'T' Técnico Académico
);

CREATE TABLE Honorario (
    id_persona INT PRIMARY KEY REFERENCES Personal(id_persona),
    fecha_inicio DATE,
    fecha_fin DATE
);

CREATE TABLE Tecnico_Academico (
    id_persona INT PRIMARY KEY REFERENCES Personal(id_persona),
    fecha_inicio DATE,
    fecha_fin DATE
);

-- ====================
-- SERVICIO SOCIAL
-- ====================

CREATE TABLE Servicio_Social (
    id_persona INT PRIMARY KEY REFERENCES Persona(id_persona),
    fecha_inicio DATE,
    fecha_fin DATE,
    programa_alterno VARCHAR(100)
);

-- ====================
-- EQUIPO Y PROYECTO
-- ====================

CREATE TABLE Equipo (
    id_equipo SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    fecha_creacion DATE
);

CREATE TABLE Proyecto (
    id_proyecto SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    id_equipo_responsable INT REFERENCES Equipo(id_equipo),
    id_personal_asignado INT REFERENCES Personal(id_persona),
    fecha_inicio DATE,
    fecha_fin DATE
);

-- ====================
-- ASIGNACION DE PERSONAS A EQUIPOS
-- ====================

CREATE TABLE Asignacion (
    id_asignacion SERIAL PRIMARY KEY,
    fecha_inicio DATE,
    fecha_fin DATE,
    id_equipo INT REFERENCES Equipo(id_equipo),
    id_persona INT REFERENCES Persona(id_persona)
);

-- ====================
-- INSTITUCION
-- ====================

CREATE TABLE Institucion (
    id_institucion SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    telefono VARCHAR(15),
    carrera_afiliada VARCHAR(100),
    direccion TEXT,
    id_persona INT REFERENCES Persona(id_persona)
);

-- ====================
-- CAPACITACION
-- ====================

CREATE TABLE Modulo_Capacitacion (
    id_capacitacion SERIAL PRIMARY KEY,
    id_modulo VARCHAR(50),
    descripcion TEXT,
    nombre VARCHAR(100)
);

CREATE TABLE Periodo (
    id_capacitacion INT REFERENCES Modulo_Capacitacion(id_capacitacion),
    id_periodo SERIAL,
    num_periodo INT,
    fecha_inicio DATE,
    fecha_fin DATE,
    PRIMARY KEY(id_capacitacion, id_periodo)
);

CREATE TABLE Capacitacion (
    id_capacitacion INT REFERENCES Modulo_Capacitacion(id_capacitacion),
    id_becario INT REFERENCES Becario(id_persona),
    PRIMARY KEY(id_capacitacion, id_becario)
);
