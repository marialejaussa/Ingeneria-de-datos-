DROP DATABASE IF EXISTS dronandes;
CREATE DATABASE dronandes CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE dronandes;

CREATE TABLE bases (
    id_base INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL,
    municipio VARCHAR(60) NOT NULL,
    departamento VARCHAR(40) NOT NULL,
    capacidad_drones INT NOT NULL,
    fecha_apertura DATE NOT NULL,
    CONSTRAINT uq_bases_nombre UNIQUE (nombre),
    CONSTRAINT chk_bases_capacidad CHECK (capacidad_drones > 0)
);

CREATE TABLE tipos_carga (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    tarifa_kg DECIMAL(10,2) NOT NULL,
    requiere_frio BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_tipos_carga_nombre UNIQUE (nombre),
    CONSTRAINT chk_tipos_carga_tarifa CHECK (tarifa_kg > 0)
);

CREATE TABLE drones (
    id_dron INT AUTO_INCREMENT PRIMARY KEY,
    codigo_serie VARCHAR(12) NOT NULL,
    modelo VARCHAR(40) NOT NULL,
    carga_max_kg DECIMAL(5,2) NOT NULL,
    autonomia_km DECIMAL(5,1) NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'ACTIVO',
    horas_vuelo DECIMAL(7,1) NOT NULL DEFAULT 0,
    fecha_adquisicion DATE NOT NULL,
    id_base INT NOT NULL,
    CONSTRAINT uq_drones_serie UNIQUE (codigo_serie),
    CONSTRAINT chk_drones_autonomia CHECK (autonomia_km > 0),
    CONSTRAINT chk_drones_estado CHECK (estado IN ('ACTIVO','MANTENIMIENTO','RETIRADO')),
    CONSTRAINT chk_drones_horas CHECK (horas_vuelo >= 0),
    CONSTRAINT fk_drones_base FOREIGN KEY (id_base) REFERENCES bases (id_base)
);

CREATE TABLE pilotos (
    id_piloto INT AUTO_INCREMENT PRIMARY KEY,
    documento VARCHAR(15) NOT NULL,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    email VARCHAR(80) NOT NULL,
    licencia CHAR(1) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    id_supervisor INT NULL,
    id_base INT NOT NULL,
    CONSTRAINT uq_pilotos_documento UNIQUE (documento),
    CONSTRAINT uq_pilotos_email UNIQUE (email),
    CONSTRAINT chk_pilotos_licencia CHECK (licencia IN ('A','B','C')),
    CONSTRAINT fk_pilotos_base FOREIGN KEY (id_base) REFERENCES bases (id_base)
);

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(12) NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    nit_documento VARCHAR(15) NOT NULL,
    email VARCHAR(80) NULL,
    telefono VARCHAR(15) NULL,
    municipio VARCHAR(60) NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT uq_clientes_nit UNIQUE (nit_documento),
    CONSTRAINT uq_clientes_email UNIQUE (email),
    CONSTRAINT chk_clientes_tipo CHECK (tipo IN ('HOSPITAL','FARMACIA','COMERCIO','ONG','PERSONA'))
);

CREATE TABLE entregas (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL,
    id_cliente INT NOT NULL,
    id_dron INT NOT NULL,
    id_piloto INT NOT NULL,
    fecha_programada DATETIME NOT NULL,
    fecha_entrega DATETIME NULL,
    municipio_destino VARCHAR(60) NOT NULL,
    distancia_km DECIMAL(5,1) NOT NULL,
    prioridad VARCHAR(8) NOT NULL DEFAULT 'NORMAL',
    estado VARCHAR(12) NOT NULL DEFAULT 'PROGRAMADA',
    calificacion SMALLINT NULL,
    CONSTRAINT uq_entregas_codigo UNIQUE (codigo),
    CONSTRAINT chk_entregas_distancia CHECK (distancia_km > 0),
    CONSTRAINT chk_entregas_prioridad CHECK (prioridad IN ('NORMAL','URGENTE','VITAL')),
    CONSTRAINT chk_entregas_estado CHECK (estado IN ('PROGRAMADA','EN_VUELO','ENTREGADA','CANCELADA','FALLIDA')),
    CONSTRAINT chk_entregas_calificacion CHECK (calificacion BETWEEN 1 AND 5),
    CONSTRAINT chk_entregas_fecha_entrega CHECK (fecha_entrega IS NULL OR estado = 'ENTREGADA'),
    CONSTRAINT fk_entregas_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente),
    CONSTRAINT fk_entregas_dron FOREIGN KEY (id_dron) REFERENCES drones (id_dron),
    CONSTRAINT fk_entregas_piloto FOREIGN KEY (id_piloto) REFERENCES pilotos (id_piloto)
);

CREATE TABLE carga_entrega (
    id_entrega INT NOT NULL,
    id_tipo INT NOT NULL,
    peso_kg DECIMAL(6,2) NOT NULL,
    unidades INT NOT NULL DEFAULT 1,
    CONSTRAINT pk_carga_entrega PRIMARY KEY (id_entrega, id_tipo),
    CONSTRAINT chk_carga_peso CHECK (peso_kg > 0),
    CONSTRAINT chk_carga_unidades CHECK (unidades > 0),
    CONSTRAINT fk_carga_entrega FOREIGN KEY (id_entrega) REFERENCES entregas (id_entrega),
    CONSTRAINT fk_carga_tipo FOREIGN KEY (id_tipo) REFERENCES tipos_carga (id_tipo)
);

CREATE TABLE mantenimientos (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_dron INT NOT NULL,
    fecha DATE NOT NULL,
    tipo VARCHAR(12) NOT NULL,
    descripcion VARCHAR(200) NULL,
    costo DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_mantenimientos_tipo CHECK (tipo IN ('PREVENTIVO','CORRECTIVO')),
    CONSTRAINT chk_mantenimientos_costo CHECK (costo >= 0),
    CONSTRAINT fk_mantenimientos_dron FOREIGN KEY (id_dron) REFERENCES drones (id_dron)
);

CREATE TABLE historial_entregas (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_entrega INT NOT NULL,
    estado_anterior VARCHAR(12) NOT NULL,
    estado_nuevo VARCHAR(12) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_historial_entrega FOREIGN KEY (id_entrega) REFERENCES entregas (id_entrega)
);

SHOW TABLES;
DESCRIBE entregas;

INSERT INTO bases (id_base, nombre, municipio, departamento, capacidad_drones, fecha_apertura) VALUES
(1, 'Base Cóndor', 'Rionegro', 'Antioquia', 6, '2024-02-15'),
(2, 'Base Colibrí', 'Guatapé', 'Antioquia', 4, '2024-08-01'),
(3, 'Base Frailejón', 'Tunja', 'Boyacá', 5, '2025-01-20'),
(4, 'Base Guadua', 'Salento', 'Quindío', 3, '2026-07-01');

INSERT INTO tipos_carga (id_tipo, nombre, tarifa_kg, requiere_frio) VALUES
(1, 'Vacunas', 12000, TRUE),
(2, 'Muestras de laboratorio', 10000, TRUE),
(3, 'Medicamentos', 8000, FALSE),
(4, 'Documentos', 5000, FALSE),
(5, 'Repuestos', 4500, FALSE),
(6, 'Alimentos', 3500, FALSE);

INSERT INTO drones (id_dron, codigo_serie, modelo, carga_max_kg, autonomia_km, estado, horas_vuelo, fecha_adquisicion, id_base) VALUES
(1, 'DA-CX4-01', 'Cóndor X4', 8.00, 45.0, 'ACTIVO', 312.5, '2024-02-20', 1),
(2, 'DA-CX4-02', 'Cóndor X4', 8.00, 45.0, 'ACTIVO', 468.0, '2024-03-10', 1),
(3, 'DA-CX6-01', 'Cóndor X6', 15.00, 60.0, 'ACTIVO', 205.0, '2025-01-15', 1),
(4, 'DA-COL-01', 'Colibrí Mini', 2.50, 25.0, 'ACTIVO', 520.5, '2024-08-05', 2),
(5, 'DA-COL-02', 'Colibrí Mini', 2.50, 25.0, 'MANTENIMIENTO', 610.0, '2024-08-05', 2),
(6, 'DA-ALB-01', 'Albatros H8', 25.00, 90.0, 'ACTIVO', 98.0, '2025-02-01', 3),
(7, 'DA-CX6-02', 'Cóndor X6', 15.00, 60.0, 'ACTIVO', 150.5, '2025-03-12', 3),
(8, 'DA-ALB-02', 'Albatros H8', 25.00, 90.0, 'RETIRADO', 890.0, '2024-05-01', 3);

INSERT INTO pilotos (id_piloto, documento, nombres, apellidos, email, licencia, fecha_ingreso, id_supervisor, id_base) VALUES
(1, '1036600111', 'Laura', 'Restrepo Gil', 'laura.restrepo@dronandes.co', 'C', '2024-02-01', NULL, 1),
(2, '1049600222', 'Camilo', 'Duarte Rojas', 'camilo.duarte@dronandes.co', 'C', '2025-01-10', NULL, 3),
(3, '1036600333', 'Mateo', 'Zapata Vélez', 'mateo.zapata@dronandes.co', 'B', '2024-04-15', 1, 1),
(4, '1036600444', 'Sara', 'Montoya Ruiz', 'sara.montoya@dronandes.co', 'B', '2024-08-10', 1, 2),
(5, '1036600555', 'Julián', 'Patiño Cruz', 'julian.patino@dronandes.co', 'A', '2025-06-01', 1, 2),
(6, '1049600666', 'Daniela', 'Suárez León', 'daniela.suarez@dronandes.co', 'B', '2025-02-01', 2, 3),
(7, '1049600777', 'Tomás', 'Becerra Niño', 'tomas.becerra@dronandes.co', 'A', '2026-06-15', 2, 3);

INSERT INTO clientes (id_cliente, tipo, nombre, nit_documento, email, telefono, municipio, fecha_registro) VALUES
(1, 'HOSPITAL', 'Hospital San Juan de Dios de Rionegro', '890980000-1', 'compras@hsjdrionegro.org', '6045310000', 'Rionegro', '2024-03-01'),
(2, 'FARMACIA', 'Droguería La Esperanza', '71234567', 'esperanza.drogueria@gmail.com', '3104567890', 'Guatapé', '2024-09-12'),
(3, 'HOSPITAL', 'E.S.E. Hospital San Rafael de Tunja', '891800231-6', 'Logistica@HSRTunja.gov.co', '6087405050', 'Tunja', '2025-01-25'),
(4, 'ONG', 'Fundación Alas para el Campo', '900456789-2', 'contacto@alasparaelcampo.org', NULL, 'Marinilla', '2024-11-03'),
(5, 'COMERCIO', 'Repuestos Agrícolas El Arriero', '900123456-7', NULL, '31245678', 'El Peñol', '2025-04-18'),
(6, 'PERSONA', 'Mariana Gómez Arango', '1040123456', 'mariana.gomez@hotmail.com', '3157778899', 'Guarne', '2025-07-07'),
(7, 'FARMACIA', 'Farmacia Botica del Páramo', '900777888-1', 'boticaparamo@gmail.com', '3209998877', 'Ventaquemada', '2025-02-14'),
(8, 'COMERCIO', 'Café de Altura Las Nubes', '901222333-4', 'ventas@cafelasnubes.co', '3001112233', 'Salento', '2026-07-20'),
(9, 'PERSONA', 'Jorge Iván Ríos', '79888777', NULL, NULL, 'Rionegro', '2026-08-30'),
(10, 'ONG', 'Corporación Montaña Viva', '900999111-0', 'info@montanaviva.org', '310555444', 'Sáchica', '2025-09-01');

INSERT INTO entregas (id_entrega, codigo, id_cliente, id_dron, id_piloto, fecha_programada, fecha_entrega, municipio_destino, distancia_km, prioridad, estado, calificacion) VALUES
(1, 'ENT-0001', 1, 1, 3, '2026-08-03 08:00:00', '2026-08-03 08:42:00', 'San Vicente', 18.5, 'VITAL', 'ENTREGADA', 5),
(2, 'ENT-0002', 1, 3, 1, '2026-08-05 09:30:00', '2026-08-05 10:20:00', 'Concepción', 32.0, 'VITAL', 'ENTREGADA', 4),
(3, 'ENT-0003', 2, 4, 4, '2026-08-07 14:00:00', '2026-08-07 14:25:00', 'San Rafael', 12.0, 'NORMAL', 'ENTREGADA', 5),
(4, 'ENT-0004', 4, 2, 3, '2026-08-10 07:45:00', '2026-08-10 08:30:00', 'El Carmen de Viboral', 22.4, 'URGENTE', 'ENTREGADA', 3),
(5, 'ENT-0005', 5, 3, 1, '2026-08-12 11:00:00', NULL, 'El Peñol', 15.0, 'NORMAL', 'CANCELADA', NULL),
(6, 'ENT-0006', 3, 6, 2, '2026-08-14 06:30:00', '2026-08-14 07:40:00', 'Ramiriquí', 48.0, 'VITAL', 'ENTREGADA', 5),
(7, 'ENT-0007', 10, 7, 6, '2026-08-18 10:00:00', '2026-08-18 10:35:00', 'Samacá', 20.5, 'NORMAL', 'ENTREGADA', 4),
(8, 'ENT-0008', 3, 8, 6, '2026-08-20 08:15:00', NULL, 'Chíquiza', 35.0, 'URGENTE', 'FALLIDA', NULL),
(9, 'ENT-0009', 6, 4, 5, '2026-08-22 16:00:00', '2026-08-22 16:20:00', 'Guarne', 9.5, 'NORMAL', 'ENTREGADA', 2),
(10, 'ENT-0010', 1, 1, 1, '2026-08-25 07:00:00', '2026-08-25 07:50:00', 'Sonsón', 41.0, 'VITAL', 'ENTREGADA', 5),
(11, 'ENT-0011', 10, 6, 2, '2026-08-27 09:00:00', '2026-08-27 10:05:00', 'Sáchica', 52.5, 'URGENTE', 'ENTREGADA', NULL),
(12, 'ENT-0012', 2, 5, 4, '2026-08-29 13:00:00', NULL, 'Alejandría', 14.0, 'NORMAL', 'CANCELADA', NULL),
(13, 'ENT-0013', 4, 2, 1, '2026-09-01 08:00:00', '2026-09-01 08:55:00', 'Granada', 38.0, 'URGENTE', 'ENTREGADA', 4),
(14, 'ENT-0014', 1, 3, 1, '2026-09-03 10:30:00', '2026-09-03 11:15:00', 'Abejorral', 44.0, 'VITAL', 'ENTREGADA', 5),
(15, 'ENT-0015', 7, 7, 6, '2026-09-08 15:00:00', '2026-09-08 15:30:00', 'Turmequé', 17.0, 'NORMAL', 'ENTREGADA', 3),
(16, 'ENT-0016', 3, 6, 2, '2026-09-15 06:00:00', '2026-09-15 07:10:00', 'Miraflores', 58.0, 'VITAL', 'ENTREGADA', 4),
(17, 'ENT-0017', 6, 2, 3, '2026-09-21 17:00:00', NULL, 'Guarne', 10.0, 'NORMAL', 'CANCELADA', NULL),
(18, 'ENT-0018', 10, 7, 6, '2026-09-30 17:40:00', NULL, 'Villa de Leyva', 26.0, 'NORMAL', 'EN_VUELO', NULL),
(19, 'ENT-0019', 1, 1, 1, '2026-10-01 07:30:00', NULL, 'Nariño', 47.0, 'VITAL', 'PROGRAMADA', NULL),
(20, 'ENT-0020', 3, 6, 6, '2026-10-02 06:00:00', NULL, 'Pesca', 39.0, 'VITAL', 'PROGRAMADA', NULL);

INSERT INTO carga_entrega (id_entrega, id_tipo, peso_kg, unidades) VALUES
(1, 1, 3.00, 60), (1, 3, 2.00, 15),
(2, 2, 1.50, 30), (2, 3, 4.00, 40),
(3, 3, 1.80, 12),
(4, 3, 3.50, 25), (4, 4, 0.50, 3),
(5, 5, 6.00, 4),
(6, 1, 5.00, 100), (6, 2, 2.00, 40),
(7, 3, 6.00, 50),
(8, 1, 8.00, 160), (8, 3, 4.00, 30),
(9, 4, 0.80, 5),
(10, 1, 4.00, 80), (10, 2, 1.00, 20), (10, 3, 2.50, 20),
(11, 3, 7.00, 60), (11, 4, 1.00, 6),
(13, 3, 5.00, 40), (13, 5, 2.00, 2),
(14, 1, 6.00, 120), (14, 2, 3.00, 60),
(15, 3, 3.00, 25), (15, 4, 0.30, 2),
(16, 1, 10.00, 200), (16, 3, 8.00, 70),
(18, 3, 4.00, 35),
(19, 1, 3.50, 70),
(20, 2, 2.50, 50), (20, 1, 6.00, 120);

INSERT INTO mantenimientos (id_mantenimiento, id_dron, fecha, tipo, descripcion, costo) VALUES
(1, 2, '2026-03-15', 'PREVENTIVO', 'Cambio de hélices', 350000),
(2, 4, '2026-04-02', 'PREVENTIVO', 'Calibración de GPS', 180000),
(3, 5, '2026-09-25', 'CORRECTIVO', 'Falla en motor 3', 1250000),
(4, 8, '2026-08-21', 'CORRECTIVO', 'Impacto en aterrizaje, evaluación de daños', 2800000),
(5, 1, '2026-06-10', 'PREVENTIVO', 'Revisión general de 300 horas', 420000),
(6, 6, '2026-07-05', 'PREVENTIVO', NULL, 260000),
(7, 5, '2026-05-14', 'PREVENTIVO', 'Cambio de baterías', 950000),
(8, 2, '2026-09-12', 'CORRECTIVO', 'Sensor de altitud defectuoso', 610000);

ALTER TABLE clientes MODIFY COLUMN nombre VARCHAR(120) NOT NULL;

ALTER TABLE drones ADD CONSTRAINT chk_drones_carga CHECK (carga_max_kg BETWEEN 0.5 AND 25);

ALTER TABLE pilotos ADD CONSTRAINT fk_pilotos_supervisor FOREIGN KEY (id_supervisor) REFERENCES pilotos (id_piloto);

INSERT INTO clientes (tipo, nombre, nit_documento, email, telefono, municipio, fecha_registro) VALUES
('FARMACIA', 'Droguería Santa Ana', '900314159-2', 'santaana@gmail.com', '3112223344', 'Marinilla', '2026-09-28'),
('PERSONA', 'Esteban Mejía Toro', '1036987654', NULL, '3015556677', 'Rionegro', '2026-09-29'),
('COMERCIO', 'Tienda Naturista Frailejón', '901555666-3', 'tienda.frailejon@outlook.com', '3209871234', 'Tunja', '2026-09-30');

UPDATE drones SET estado = 'MANTENIMIENTO' WHERE estado = 'ACTIVO' AND horas_vuelo > 500;

DELETE FROM entregas
WHERE estado = 'CANCELADA'
  AND id_entrega NOT IN (SELECT id_entrega FROM carga_entrega);

SELECT
    (SELECT COUNT(*) FROM clientes) AS total_clientes,
    (SELECT COUNT(*) FROM entregas) AS total_entregas,
    (SELECT COUNT(*) FROM drones WHERE estado = 'MANTENIMIENTO') AS drones_mantenimiento;

SELECT codigo, municipio_destino, distancia_km, prioridad
FROM entregas
WHERE estado = 'ENTREGADA'
  AND distancia_km BETWEEN 20 AND 45
  AND prioridad IN ('VITAL', 'URGENTE')
ORDER BY distancia_km DESC;

SELECT codigo, estado, fecha_programada
FROM entregas
WHERE estado NOT IN ('PROGRAMADA', 'EN_VUELO', 'ENTREGADA')
  AND fecha_entrega IS NULL
ORDER BY codigo;

SELECT codigo, fecha_entrega
FROM entregas
WHERE fecha_entrega IS NOT NULL
  AND calificacion IS NULL;

SELECT codigo_serie, modelo, carga_max_kg, horas_vuelo, autonomia_km, estado
FROM drones
WHERE estado <> 'RETIRADO'
  AND ((carga_max_kg >= 8 AND horas_vuelo < 400) OR autonomia_km > 80)
ORDER BY codigo_serie ASC;

SELECT nombres, apellidos, licencia, fecha_ingreso
FROM pilotos
WHERE NOT licencia = 'A'
  AND fecha_ingreso <= '2025-02-01'
ORDER BY fecha_ingreso ASC;

SELECT UPPER(nombre) AS cliente,
       municipio,
       COALESCE(telefono, 'SIN TELÉFONO') AS telefono,
       LENGTH(telefono) AS digitos
FROM clientes
WHERE telefono IS NULL OR LENGTH(telefono) <> 10
ORDER BY nombre ASC;

SELECT nombre,
       LOWER(email) AS correo,
       CONCAT(nombre, ' <', LOWER(email), '>') AS contacto
FROM clientes
WHERE email IS NOT NULL
  AND LOWER(email) NOT LIKE '%@gmail.com'
  AND LOWER(email) NOT LIKE '%@hotmail.com'
  AND LOWER(email) NOT LIKE '%@outlook.com'
ORDER BY nombre;

SELECT codigo_serie,
       UPPER(modelo) AS modelo,
       horas_vuelo,
       ROUND(horas_vuelo * 100 / 1000, 1) AS pct_vida_util
FROM drones
WHERE codigo_serie LIKE 'DA-CX_-__'
ORDER BY horas_vuelo DESC;

SELECT t.nombre AS tipo_carga,
       COUNT(DISTINCT ce.id_entrega) AS num_entregas,
       SUM(ce.peso_kg) AS kg_totales,
       ROUND(AVG(ce.peso_kg), 2) AS kg_promedio,
       MIN(ce.peso_kg) AS kg_minimo,
       MAX(ce.peso_kg) AS kg_maximo
FROM tipos_carga t
INNER JOIN carga_entrega ce ON ce.id_tipo = t.id_tipo
INNER JOIN entregas e ON e.id_entrega = ce.id_entrega
WHERE e.estado = 'ENTREGADA'
GROUP BY t.id_tipo, t.nombre
ORDER BY kg_totales DESC;

SELECT c.nombre AS cliente,
       COUNT(*) AS entregas_realizadas,
       ROUND(AVG(e.calificacion), 2) AS calificacion_promedio
FROM clientes c
INNER JOIN entregas e ON e.id_cliente = c.id_cliente
WHERE e.estado = 'ENTREGADA'
GROUP BY c.id_cliente, c.nombre
HAVING COUNT(*) >= 2 AND AVG(e.calificacion) >= 4
ORDER BY calificacion_promedio DESC, cliente ASC;

SELECT e.codigo,
       c.nombre AS cliente,
       CONCAT(p.nombres, ' ', p.apellidos) AS piloto,
       d.codigo_serie AS dron,
       b.nombre AS base,
       TIMESTAMPDIFF(MINUTE, e.fecha_programada, e.fecha_entrega) AS minutos_vuelo
FROM entregas e
INNER JOIN clientes c ON c.id_cliente = e.id_cliente
INNER JOIN pilotos p ON p.id_piloto = e.id_piloto
INNER JOIN drones d ON d.id_dron = e.id_dron
INNER JOIN bases b ON b.id_base = d.id_base
WHERE e.prioridad = 'VITAL' AND e.estado = 'ENTREGADA'
ORDER BY e.fecha_programada ASC;

SELECT CONCAT(p.nombres, ' ', p.apellidos) AS piloto,
       p.licencia,
       COUNT(e.id_entrega) AS entregas_realizadas
FROM pilotos p
LEFT JOIN entregas e ON e.id_piloto = p.id_piloto AND e.estado = 'ENTREGADA'
GROUP BY p.id_piloto, p.nombres, p.apellidos, p.licencia
ORDER BY entregas_realizadas DESC, piloto ASC;

SELECT CONCAT(p.nombres, ' ', p.apellidos) AS piloto,
       p.licencia,
       CASE WHEN s.id_piloto IS NULL THEN 'DIRECCIÓN DE OPERACIONES'
            ELSE CONCAT(s.nombres, ' ', s.apellidos) END AS supervisor
FROM pilotos p
LEFT JOIN pilotos s ON s.id_piloto = p.id_supervisor
ORDER BY supervisor, piloto;

SELECT e.codigo,
       c.nombre AS cliente,
       d.codigo_serie AS dron,
       e.distancia_km,
       d.autonomia_km,
       e.distancia_km - d.autonomia_km AS exceso_km
FROM entregas e
INNER JOIN clientes c ON c.id_cliente = e.id_cliente
INNER JOIN drones d ON d.id_dron = e.id_dron
WHERE e.estado = 'PROGRAMADA' AND e.distancia_km > d.autonomia_km;

SELECT codigo, municipio_destino, distancia_km
FROM entregas
WHERE estado = 'ENTREGADA'
  AND distancia_km > (SELECT AVG(distancia_km) FROM entregas WHERE estado = 'ENTREGADA')
ORDER BY distancia_km DESC;

SELECT nombre, tipo, municipio, fecha_registro
FROM clientes
WHERE id_cliente NOT IN (SELECT id_cliente FROM entregas)
ORDER BY fecha_registro, nombre;

SELECT d.codigo_serie, b.nombre AS base, d.horas_vuelo
FROM drones d
INNER JOIN bases b ON b.id_base = d.id_base
WHERE d.horas_vuelo > (SELECT AVG(d2.horas_vuelo) FROM drones d2 WHERE d2.id_base = d.id_base)
ORDER BY base;

SELECT d.codigo_serie, d.modelo, d.estado
FROM drones d
WHERE d.estado <> 'RETIRADO'
  AND NOT EXISTS (SELECT 1 FROM mantenimientos m WHERE m.id_dron = d.id_dron)
ORDER BY d.codigo_serie;

CREATE OR REPLACE VIEW vw_tablero_entregas AS
SELECT e.codigo,
       e.fecha_programada,
       c.nombre AS cliente,
       c.tipo AS tipo_cliente,
       e.municipio_destino,
       d.codigo_serie AS dron,
       CONCAT(p.nombres, ' ', p.apellidos) AS piloto,
       e.prioridad,
       e.estado,
       COUNT(ce.id_tipo) AS tipos_carga,
       COALESCE(SUM(ce.peso_kg), 0) AS peso_total_kg
FROM entregas e
INNER JOIN clientes c ON c.id_cliente = e.id_cliente
INNER JOIN drones d ON d.id_dron = e.id_dron
INNER JOIN pilotos p ON p.id_piloto = e.id_piloto
LEFT JOIN carga_entrega ce ON ce.id_entrega = e.id_entrega
GROUP BY e.id_entrega, e.codigo, e.fecha_programada, c.nombre, c.tipo,
         e.municipio_destino, d.codigo_serie, p.nombres, p.apellidos,
         e.prioridad, e.estado;

SELECT *
FROM vw_tablero_entregas
WHERE estado IN ('PROGRAMADA', 'EN_VUELO')
ORDER BY fecha_programada;

CREATE INDEX idx_entregas_estado_fecha ON entregas (estado, fecha_programada);
CREATE INDEX idx_clientes_tipo_municipio ON clientes (tipo, municipio);

SHOW INDEX FROM entregas;
SHOW INDEX FROM clientes;

DELIMITER $$
CREATE FUNCTION fn_valor_entrega(p_id_entrega INT)
RETURNS DECIMAL(14,2)
READS SQL DATA
BEGIN
    DECLARE v_dist DECIMAL(5,1);
    DECLARE v_prio VARCHAR(8);
    DECLARE v_carga DECIMAL(18,2);
    DECLARE v_total DECIMAL(18,2);

    SELECT distancia_km, prioridad
    INTO v_dist, v_prio
    FROM entregas
    WHERE id_entrega = p_id_entrega;

    IF v_dist IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(SUM(ce.peso_kg * t.tarifa_kg), 0)
    INTO v_carga
    FROM carga_entrega ce
    INNER JOIN tipos_carga t ON t.id_tipo = ce.id_tipo
    WHERE ce.id_entrega = p_id_entrega;

    SET v_total = v_carga + v_dist * 1200;

    IF v_prio = 'URGENTE' THEN
        SET v_total = v_total * 1.2;
    END IF;

    RETURN ROUND(v_total, 2);
END$$
DELIMITER ;

SELECT codigo, prioridad, fn_valor_entrega(id_entrega) AS valor_cop
FROM entregas
WHERE estado = 'ENTREGADA' AND prioridad = 'URGENTE'
ORDER BY valor_cop DESC;

SELECT fn_valor_entrega(999) AS valor_entrega_inexistente;

DELIMITER $$
CREATE TRIGGER trg_entregas_estado
BEFORE UPDATE ON entregas
FOR EACH ROW
BEGIN
    IF NEW.estado <> OLD.estado THEN
        IF NEW.estado = 'ENTREGADA' AND NEW.fecha_entrega IS NULL THEN
            SET NEW.fecha_entrega = NOW();
        END IF;
        INSERT INTO historial_entregas (id_entrega, estado_anterior, estado_nuevo)
        VALUES (OLD.id_entrega, OLD.estado, NEW.estado);
    END IF;
END$$
DELIMITER ;

UPDATE entregas SET estado = 'ENTREGADA', calificacion = 5 WHERE codigo = 'ENT-0018';
UPDATE entregas SET estado = 'CANCELADA' WHERE codigo = 'ENT-0019';
UPDATE entregas SET calificacion = 4 WHERE codigo = 'ENT-0011';

SELECT h.id_historial, e.codigo, h.estado_anterior, h.estado_nuevo, h.fecha_cambio
FROM historial_entregas h
INNER JOIN entregas e ON e.id_entrega = h.id_entrega
ORDER BY h.id_historial;

SELECT codigo, estado, fecha_entrega, calificacion
FROM entregas
WHERE codigo IN ('ENT-0018', 'ENT-0019', 'ENT-0011')
ORDER BY codigo;

DELIMITER $$
CREATE PROCEDURE sp_programar_entrega(
    IN p_codigo VARCHAR(10),
    IN p_id_cliente INT,
    IN p_id_dron INT,
    IN p_id_piloto INT,
    IN p_fecha_programada DATETIME,
    IN p_municipio_destino VARCHAR(60),
    IN p_distancia_km DECIMAL(5,1),
    IN p_prioridad VARCHAR(8)
)
BEGIN
    DECLARE v_existe_dron INT DEFAULT 0;
    DECLARE v_existe_piloto INT DEFAULT 0;
    DECLARE v_estado VARCHAR(15);
    DECLARE v_autonomia DECIMAL(5,1);
    DECLARE v_licencia CHAR(1);
    DECLARE v_id INT;

    SELECT COUNT(*) INTO v_existe_dron FROM drones WHERE id_dron = p_id_dron;
    SELECT COUNT(*) INTO v_existe_piloto FROM pilotos WHERE id_piloto = p_id_piloto;

    IF v_existe_dron = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El dron indicado no existe';
    END IF;

    IF v_existe_piloto = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El piloto indicado no existe';
    END IF;

    SELECT estado, autonomia_km INTO v_estado, v_autonomia
    FROM drones WHERE id_dron = p_id_dron;

    SELECT licencia INTO v_licencia
    FROM pilotos WHERE id_piloto = p_id_piloto;

    IF v_estado <> 'ACTIVO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El dron no esta ACTIVO y no puede recibir entregas nuevas';
    END IF;

    IF p_distancia_km > v_autonomia THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La distancia supera la autonomia del dron';
    END IF;

    IF (v_licencia = 'A' AND p_distancia_km > 20)
       OR (v_licencia = 'B' AND p_distancia_km > 40) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La licencia del piloto no permite esa distancia';
    END IF;

    INSERT INTO entregas (codigo, id_cliente, id_dron, id_piloto, fecha_programada,
                          municipio_destino, distancia_km, prioridad)
    VALUES (p_codigo, p_id_cliente, p_id_dron, p_id_piloto, p_fecha_programada,
            p_municipio_destino, p_distancia_km, p_prioridad);

    SET v_id = LAST_INSERT_ID();

    SELECT CONCAT('Entrega programada con identificador ', v_id) AS mensaje;
END$$
DELIMITER ;

CALL sp_programar_entrega('ENT-0021', 11, 3, 3, '2026-10-03 10:00:00', 'Marinilla', 16.0, 'URGENTE');
CALL sp_programar_entrega('ENT-0022', 6, 4, 4, '2026-10-03 11:00:00', 'Guarne', 9.0, 'NORMAL');
CALL sp_programar_entrega('ENT-0023', 2, 7, 7, '2026-10-04 08:00:00', 'Arcabuco', 28.0, 'NORMAL');

SELECT * FROM vw_tablero_entregas WHERE codigo = 'ENT-0021';
