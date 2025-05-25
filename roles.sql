--=================================
--Creación de roles
--=================================

-- Rol administrador con todos los privilegios
CREATE ROLE admin LOGIN PASSWORD 'admin_pass';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;

-- Rol operador: puede insertar y actualizar datos pero no borrar
CREATE ROLE operador LOGIN PASSWORD 'operador_pass';

-- Rol reportes: solo puede leer datos (SELECT)
CREATE ROLE reportes LOGIN PASSWORD 'reportes_pass';

--=================================
--Asignación de privilegios
--=================================

--Operador
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO operador;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO operador;

--Reportes
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reportes;

--=================================
--Configuración 
--=================================

-- Default para tablas
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE ON TABLES TO operador;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO reportes;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO admin;

-- Default para secuencias (ej: SERIAL IDs)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO operador;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO reportes;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO admin;
