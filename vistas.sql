-- Lista de becarios activos actualmente
CREATE VIEW Becarios_activos AS
SELECT 
    p.id_persona, 
    p.nombre, 
    p.ape_pat, 
    p.ape_mat, 
    a.fecha_inicio, 
    a.fecha_fin, 
    e.nombre AS equipo
FROM 
    Persona p
JOIN 
    Becario b ON p.id_persona = b.id_persona
JOIN 
    Asignacion a ON p.id_persona = a.id_persona
JOIN 
    Equipo e ON a.id_equipo = e.id_equipo
WHERE 
    CURRENT_DATE BETWEEN a.fecha_inicio AND a.fecha_fin;

-- Lista de becarios próximos a terminar un periodo
CREATE VIEW Becarios_a_terminar AS
SELECT 
    p.id_persona, 
    p.nombre, 
    p.ape_pat, 
    p.ape_mat, 
    a.fecha_fin, 
    e.nombre AS equipo
FROM 
    Persona p
JOIN 
    Becario b ON p.id_persona = b.id_persona
JOIN 
    Asignacion a ON p.id_persona = a.id_persona
JOIN 
    Equipo e ON a.id_equipo = e.id_equipo
WHERE 
    CURRENT_DATE BETWEEN a.fecha_inicio AND a.fecha_fin
    AND a.fecha_fin BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '30 días');

-- Historial completo de una persona por nombre
CREATE VIEW Historial_persona AS
SELECT 
    p.id_persona,
    p.nombre,
    p.ape_pat,
    p.ape_mat,
    p.curp,
    p.rfc,
    a.fecha_inicio AS asignacion_inicio,
    a.fecha_fin AS asignacion_fin,
    eq.nombre AS equipo,
    pr.nombre AS proyecto,
    pr.fecha_inicio AS proyecto_inicio,
    pr.fecha_fin AS proyecto_fin,
    de.escuela,
    de.carrera,
    de.semestre,
    de.promedio,
    ce.nombre AS contacto_nombre,
    ce.parentesco
FROM 
    Persona p
LEFT JOIN 
    Asignacion a ON p.id_persona = a.id_persona
LEFT JOIN 
    Equipo eq ON a.id_equipo = eq.id_equipo
LEFT JOIN 
    Proyecto pr ON eq.id_equipo = pr.id_equipo_responsable
LEFT JOIN 
    Datos_Escolares de ON p.id_persona = de.id_persona
LEFT JOIN 
    Contacto_Emergencia ce ON p.id_persona = ce.id_persona;

-- Lista del equipo de un proyecto en particular
CREATE VIEW Lista_equipo AS
SELECT 
    pr.id_proyecto,
    pr.nombre AS proyecto_nombre,
    eq.id_equipo,
    eq.nombre AS equipo_nombre,
    p.id_persona,
    p.nombre,
    p.ape_pat,
    p.ape_mat
FROM 
    Proyecto pr
JOIN 
    Equipo eq ON pr.id_equipo_responsable = eq.id_equipo
JOIN 
    Asignacion a ON eq.id_equipo = a.id_equipo
JOIN 
    Persona p ON a.id_persona = p.id_persona;

-- Lista completa de los becarios incluyendo los proyectos y las fechas en las que participa o ha participado.
CREATE VIEW Proyectos_becarios AS
SELECT 
    b.id_persona,
    p.nombre,
    p.ape_pat,
    p.ape_mat,
    a.fecha_inicio AS asignacion_inicio,
    a.fecha_fin AS asignacion_fin,
    eq.nombre AS equipo,
    pr.nombre AS proyecto,
    pr.fecha_inicio AS proyecto_inicio,
    pr.fecha_fin AS proyecto_fin
FROM 
    Becario b
JOIN 
    Persona p ON b.id_persona = p.id_persona
JOIN 
    Asignacion a ON p.id_persona = a.id_persona
JOIN 
    Equipo eq ON a.id_equipo = eq.id_equipo
JOIN 
    Proyecto pr ON eq.id_equipo = pr.id_equipo_responsable
    AND (pr.fecha_inicio <= a.fecha_fin AND pr.fecha_fin >= a.fecha_inicio);