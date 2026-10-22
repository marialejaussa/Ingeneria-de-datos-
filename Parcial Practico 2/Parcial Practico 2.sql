--R2 DDL 

DROP database IF EXISTS cicloverde;
CREATE DATABASE cicloverde CHARACTER SET utf8mb4;
use cicloverde;

CREATE TABLE estaciones (
id_estacion INT AUTO_INCREMENT PRIMARY KEY,
nombre      VARCHAR(50) NOT NULL UNIQUE,
barrio      VARCHAR(50) NOT NULL,
capacidad   INT NOT NULL,
activa      BOOLEAN NOT NULL DEFAULT TRUE,
CONSTRAINT chk_estaciones_capacidad CHECK (capacidad > 0)
);

CREATE TABLE bicicletas (
id_bici       INT AUTO_INCREMENT PRIMARY KEY,
codigo        VARCHAR(10) NOT NULL UNIQUE,
modelo        VARCHAR(40) NOT NULL,
estado        VARCHAR(10) NOT NULL DEFAULT 'ACTIVA',
km_recorridos DECIMAL(7,1) NOT NULL DEFAULT 0,
id_estacion   INT NOT NULL,
CONSTRAINT chk_bicicletas_estado CHECK (estado IN ('ACTIVA','TALLER','BAJA')),
CONSTRAINT chk_bicicletas_km CHECK (km_recorridos >= 0),
CONSTRAINT fk_bicicletas_estacion FOREIGN KEY (id_estacion) REFERENCES estaciones(id_estacion)
);

CREATE TABLE usuarios (
id_usuario     INT AUTO_INCREMENT PRIMARY KEY,
documento      VARCHAR(15) NOT NULL UNIQUE,
nombres        VARCHAR(50) NOT NULL,
apellidos      VARCHAR(50) NOT NULL,
email          VARCHAR(80) NULL UNIQUE,
telefono       VARCHAR(15) NULL,
plan           VARCHAR(10) NOT NULL DEFAULT 'BASICO',
fecha_registro DATE NOT NULL,
id_referidor   INT NULL,
CONSTRAINT chk_usuarios_plan CHECK (plan IN ('BASICO','PREMIUM'))
);

CREATE TABLE accesorios (
id_accesorio INT AUTO_INCREMENT PRIMARY KEY,
nombre       VARCHAR(40) NOT NULL UNIQUE,
precio       DECIMAL(8,2) NOT NULL,
CONSTRAINT chk_accesorios_precio CHECK (precio > 0)
);

CREATE TABLE viajes(
id_viaje 		int auto_increment PRIMARY KEY,
id_usuario 		int NOT NULL,
id_bici 		int NOT NULL, 
id_estacion_origen int NOT NULL,
id_estacion_destino int NULL,
fecha_inicio 	datetime NOT NULL,
fecha_fin 		datetime NULL,
km 				decimal(5,1) NOT NULL DEFAULT 0,
estado 			varchar(12) NOT NULL DEFAULT 'EN_CURSO',
calificacion 	SMALLINT NULL,
CONSTRAINT chk_viajes_km CHECK (km >= 0),
CONSTRAINT chk_viajes_estado CHECK (estado IN ('EN_CURSO','FINALIZADO','CANCELADO')),
CONSTRAINT chk_viajes_calificacion CHECK (calificacion BETWEEN 1 AND 5),
CONSTRAINT fk_viajes_usuario  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
CONSTRAINT fk_viajes_bici     FOREIGN KEY (id_bici) REFERENCES bicicletas(id_bici),
CONSTRAINT fk_viajes_origen   FOREIGN KEY (id_estacion_origen) REFERENCES estaciones(id_estacion),
CONSTRAINT fk_viajes_destino  FOREIGN KEY (id_estacion_destino) REFERENCES estaciones(id_estacion)
);

CREATE TABLE viaje_accesorio (
id_viaje 		int  NOT NULL UNIQUE,
id_accesorio 	int NOT NULL UNIQUE,
cantidad 		int NOT NULL DEFAULT 1,
PRIMARY KEY (id_viaje, id_accesorio),
CONSTRAINT chk_va_cantidad CHECK (cantidad > 0),
CONSTRAINT fk_va_viaje     FOREIGN KEY (id_viaje) REFERENCES viajes(id_viaje),
CONSTRAINT fk_va_accesorio FOREIGN KEY (id_accesorio) REFERENCES accesorios(id_accesorio)
);

CREATE TABLE historial_bicicletas(
id_historial 	int auto_increment PRIMARY KEY,
id_bici 		int NOT NULL,
estado_anterior varchar (10) NOT NULL,
estado_nuevo 	varchar (10) NOT NULL,
fecha_cambio 	datetime NOT NULL,
CONSTRAINT fk_historial_bici FOREIGN KEY (id_bici) REFERENCES bicicletas(id_bici)
);

-- =====================================================================
-- DATOS INICIALES — Operación Pedal (CicloVerde S.A.S.)
-- Ejecutar inmediatamente después del DDL de R2.
-- =====================================================================
INSERT INTO estaciones (id_estacion, nombre, barrio, capacidad, activa) VALUES
(1, 'Estación Las Aguas', 'La Candelaria', 12, TRUE),
(2, 'Estación Parque 93', 'Chapinero', 15, TRUE),
(3, 'Estación Usaquén', 'Usaquén', 10, TRUE),
(4, 'Estación Kennedy', 'Kennedy', 8, FALSE);
INSERT INTO bicicletas (id_bici, codigo, modelo, estado, km_recorridos, id_estacion)
VALUES
(1, 'CV-E01', 'Volta E2', 'ACTIVA', 1350.5, 1),
(2, 'CV-E02', 'Volta E2', 'ACTIVA', 820.0, 1),
(3, 'CV-M01', 'Urbana M1', 'ACTIVA', 240.0, 1),
(4, 'CV-E03', 'Volta E3', 'ACTIVA', 1620.0, 2),
(5, 'CV-M02', 'Urbana M1', 'TALLER', 95.5, 2),
(6, 'CV-E04', 'Volta E3', 'ACTIVA', 410.0, 3),
(7, 'CV-M03', 'Urbana M2', 'BAJA', 2100.0, 3),
(8, 'CV-E-PRO', 'Prototipo Volta X', 'ACTIVA', 60.0, 3);
-- Los usuarios que refieren se insertan antes que sus referidos.
INSERT INTO usuarios (id_usuario, documento, nombres, apellidos, email, telefono,
plan, fecha_registro, id_referidor) VALUES
(1, '1036101001', 'Valentina', 'Ríos Mejía', 'vale.rios@gmail.com',
'3001234567', 'PREMIUM', '2025-11-03', NULL),
(2, '1036101002', 'Santiago', 'Gómez Ruiz', 'sgomez@urosario.edu.co',
'3012223344', 'BASICO', '2026-01-15', 1),
(3, '1036101003', 'Isabella', 'Torres Cano', 'isa.torres@hotmail.com', NULL,
'PREMIUM', '2026-02-20', 1),
(4, '1036101004', 'Mateo', 'Herrera Díaz', NULL,
'312456789', 'BASICO', '2026-03-31', 2),
(5, '1036101005', 'Camila', 'Ortiz León', 'camila.ortiz@urosario.edu.co',
'3157654321', 'BASICO', '2026-05-10', NULL),
(6, '1036101006', 'Sebastián', 'Vargas Pino', 'sebas.vargas@gmail.com',
'3209876543', 'PREMIUM', '2026-07-01', 3),
(7, '1036101007', 'Daniela', 'Cruz Mora', 'DCRUZ@UROSARIO.EDU.CO',
'3104445566', 'BASICO', '2026-09-12', NULL),
(8, '1036101008', 'Andrés', 'Patiño Gil', NULL, NULL,
'BASICO', '2026-10-01', 5);
INSERT INTO accesorios (id_accesorio, nombre, precio) VALUES
(1, 'Casco', 2500),
(2, 'Candado', 1500),
(3, 'Canasta', 1000),
(4, 'Luz recargable', 2000);
INSERT INTO viajes (id_viaje, id_usuario, id_bici, id_estacion_origen,
id_estacion_destino, fecha_inicio, fecha_fin, km, estado, calificacion) VALUES
(1, 1, 1, 1, 2, '2026-10-01 07:10:00', '2026-10-01 07:32:00', 5.2, 'FINALIZADO',5),
(2, 2, 3, 1, 3, '2026-10-01 08:00:00', '2026-10-01 08:25:00', 3.8, 'FINALIZADO',4),
(3, 3, 4, 2, 1, '2026-10-02 18:05:00', '2026-10-02 18:40:00', 6.0, 'FINALIZADO',2),
(4, 1, 2, 1, 1, '2026-10-03 12:00:00', '2026-10-03 12:15:00', 2.1, 'FINALIZADO',NULL),
(5, 3, 6, 3, 2, '2026-10-04 09:30:00', '2026-10-04 09:58:00', 4.4, 'FINALIZADO',3),
(6, 5, 1, 2, NULL, '2026-10-05 10:00:00', NULL, 0.0, 'CANCELADO',NULL),
(7, 6, 4, 2, 3, '2026-10-06 17:20:00', '2026-10-06 18:05:00', 11.0, 'FINALIZADO',5),
(8, 2, 2, 1, 2, '2026-10-08 07:45:00', '2026-10-08 08:05:00', 4.9, 'FINALIZADO',1),
(9, 3, 6, 3, NULL, '2026-10-09 14:00:00', NULL, 0.8, 'CANCELADO',NULL),
(10, 1, 6, 3, 1, '2026-10-11 06:50:00', '2026-10-11 07:20:00', 6.0, 'FINALIZADO',4),
(11, 5, 3, 1, 3, '2026-10-12 16:00:00', '2026-10-12 16:18:00', 2.7, 'FINALIZADO',5),
(12, 6, 8, 3, NULL, '2026-10-14 11:00:00', NULL, 0.0, 'CANCELADO',NULL),
(13, 4, 2, 1, NULL, '2026-10-15 19:30:00', NULL, 1.2, 'EN_CURSO',NULL),
(14, 2, 6, 3, NULL, '2026-10-15 19:45:00', NULL, 0.0, 'EN_CURSO',NULL);
INSERT INTO viaje_accesorio (id_viaje, id_accesorio, cantidad) VALUES
(1, 1, 1), (1, 2, 1),(3, 1, 1),
(5, 3, 1),(7, 1, 1), (7, 3, 1),
(8, 2, 1),(10, 1, 1),(11, 2, 1),
(13, 1, 1);


-- R3 ALTER TABLE 

ALTER TABLE usuarios
  ADD CONSTRAINT fk_usuarios_referidor
  FOREIGN KEY (id_referidor) REFERENCES usuarios(id_usuario);

ALTER TABLE viajes
  ADD CONSTRAINT chk_viajes_fechas
  CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio);

 -- R4 a

INSERT INTO usuarios (documento, nombres, apellidos, email, telefono, plan, fecha_registro, id_referidor) 
VALUES ('1036101009', 'Lucia', 'Arango Velez', 'lucia.arango@gmail.com', '316551234', 'PREMIUM', '2026-10-14', '2'),
('1036101010', 'Juan Pablo', 'Restrepro Sierra', 'jp.restrepo@unal.edu.co', '3001112222', 'BASICO', '2026-10-15', NULL);

 -- R4 b 

UPDATE bicicletas 
SET estado = 'TALLER'
WHERE estado = 'ACTIVA' AND km_recorridos > 1500;

-- R4 c
DELETE FROM viajes
WHERE estado = 'CANCELADO' AND km = 0;

-- R4 d.
SELECT
  (SELECT COUNT(*) FROM usuarios) AS usuarios,
  (SELECT COUNT(*) FROM viajes) AS viajes,
  (SELECT COUNT(*) FROM bicicletas WHERE estado = 'TALLER') AS bicis_en_taller;

-- R5 a.
SELECT id_viaje, id_estacion_origen, km, calificacion
FROM viajes
WHERE estado = 'FINALIZADO'
  AND km BETWEEN 2 AND 6
  AND id_estacion_origen IN (1, 2)
ORDER BY km DESC;

-- R5 b.
SELECT codigo, modelo, estado, km_recorridos
FROM bicicletas
WHERE estado != 'BAJA'
  AND (km_recorridos < 300 OR km_recorridos >= 1200)
ORDER BY codigo ASC;

-- R5 c.
SELECT id_viaje, id_usuario, estado, fecha_inicio
FROM viajes
WHERE fecha_fin IS NULL
  AND estado NOT IN ('CANCELADO')
ORDER BY fecha_inicio;

-- R5.d.
SELECT nombres, apellidos, plan, fecha_registro
FROM usuarios
WHERE NOT (plan = 'PREMIUM')
  AND fecha_registro <= '2026-03-31'
ORDER BY fecha_registro ASC;

-- R6.a
SELECT CONCAT(nombres, ' ', apellidos) AS usuario,
       LOWER(email) AS correo
FROM usuarios
WHERE email IS NOT NULL
  AND email NOT LIKE '%@gmail.com'
  AND email NOT LIKE '%@hotmail.com'
ORDER BY usuario;

-- R6.b
SELECT codigo,
       UPPER(modelo) AS modelo,
       km_recorridos,
       ROUND(km_recorridos / 1500 * 100, 1) AS pct_revision
FROM bicicletas
WHERE codigo LIKE 'CV-E__'
ORDER BY km_recorridos DESC;

-- R6.c
SELECT CONCAT(nombres, ' ', apellidos) AS usuario,
       COALESCE(telefono, 'SIN TELÉFONO') AS telefono,
       COALESCE(LENGTH(telefono), 0) AS digitos
FROM usuarios
WHERE telefono IS NULL OR LENGTH(telefono) <> 10
ORDER BY usuario;

-- R7.a
SELECT e.nombre AS estacion,
       COUNT(*) AS viajes,
       SUM(v.km) AS km_totales,
       ROUND(AVG(v.km), 2) AS km_promedio,
       MIN(v.km) AS km_minimo,
       MAX(v.km) AS km_maximo
FROM viajes v
JOIN estaciones e ON e.id_estacion = v.id_estacion_origen
WHERE v.estado = 'FINALIZADO'
GROUP BY e.id_estacion, e.nombre
ORDER BY km_totales DESC;

-- R7.b
SELECT CONCAT(u.nombres, ' ', u.apellidos) AS usuario,
       COUNT(*) AS viajes,
       SUM(v.km) AS km_totales
FROM viajes v
JOIN usuarios u ON u.id_usuario = v.id_usuario
WHERE v.estado = 'FINALIZADO'
GROUP BY u.id_usuario, u.nombres, u.apellidos
HAVING COUNT(*) >= 2 AND SUM(v.km) > 10
ORDER BY km_totales DESC;

-- R8.a
SELECT v.id_viaje,
       CONCAT(u.nombres, ' ', u.apellidos) AS usuario,
       b.codigo AS bicicleta,
       e.nombre AS origen,
       v.km,
       TIMESTAMPDIFF(MINUTE, v.fecha_inicio, v.fecha_fin) AS minutos
FROM viajes v
INNER JOIN usuarios u   ON u.id_usuario = v.id_usuario
INNER JOIN bicicletas b ON b.id_bici = v.id_bici
INNER JOIN estaciones e ON e.id_estacion = v.id_estacion_origen
WHERE v.estado = 'FINALIZADO' AND u.plan = 'PREMIUM'
ORDER BY v.id_viaje;

-- R8.b
SELECT e.nombre AS estacion,
       e.capacidad,
       COUNT(b.id_bici) AS bicicletas,
       e.capacidad - COUNT(b.id_bici) AS cupos_libres
FROM estaciones e
LEFT JOIN bicicletas b ON b.id_estacion = e.id_estacion
GROUP BY e.id_estacion, e.nombre, e.capacidad
ORDER BY e.id_estacion;

-- R8.c
SELECT u.id_usuario,
       CONCAT(u.nombres, ' ', u.apellidos) AS usuario,
       COALESCE(CONCAT(r.nombres, ' ', r.apellidos), 'SIN REFERIDOR') AS referido_por
FROM usuarios u
LEFT JOIN usuarios r ON r.id_usuario = u.id_referidor
ORDER BY u.id_usuario;

-- R8.d
SELECT v.id_viaje,
       a.nombre AS accesorio,
       va.cantidad,
       va.cantidad * a.precio AS subtotal
FROM viaje_accesorio va
JOIN viajes v     ON v.id_viaje = va.id_viaje
JOIN accesorios a ON a.id_accesorio = va.id_accesorio
WHERE v.estado = 'FINALIZADO'
ORDER BY v.id_viaje, a.nombre;

-- R9.a
SELECT id_viaje, km
FROM viajes
WHERE estado = 'FINALIZADO'
  AND km > (SELECT AVG(km) FROM viajes WHERE estado = 'FINALIZADO')
ORDER BY km DESC;

-- R9.b
SELECT nombres, apellidos, fecha_registro
FROM usuarios
WHERE id_usuario NOT IN (SELECT id_usuario FROM viajes)
ORDER BY fecha_registro;

-- R9.c
SELECT b.codigo, b.id_estacion, b.km_recorridos
FROM bicicletas b
WHERE b.km_recorridos > (
  SELECT AVG(b2.km_recorridos)
  FROM bicicletas b2
  WHERE b2.id_estacion = b.id_estacion
)
ORDER BY b.codigo;

-- R9.d
SELECT a.nombre, a.precio
FROM accesorios a
WHERE NOT EXISTS (
  SELECT 1 FROM viaje_accesorio va WHERE va.id_accesorio = a.id_accesorio
);

-- R10.a VISTA
CREATE VIEW vw_actividad_usuarios AS
SELECT u.id_usuario,
       CONCAT(u.nombres, ' ', u.apellidos) AS usuario,
       u.plan,
       COUNT(v.id_viaje) AS total_viajes,
       COALESCE(SUM(v.km), 0) AS km_totales
FROM usuarios u
LEFT JOIN viajes v
       ON v.id_usuario = u.id_usuario AND v.estado = 'FINALIZADO'
GROUP BY u.id_usuario, u.nombres, u.apellidos, u.plan;

SELECT usuario, plan, total_viajes, km_totales
FROM vw_actividad_usuarios
ORDER BY km_totales DESC, usuario;

-- R10.b ÍNDICES
-- Igualdad en estado y rango en fecha_inicio: un solo índice compuesto sirve al filtro.
CREATE INDEX idx_viajes_estado_fecha ON viajes (estado, fecha_inicio);

-- Evita recorrer toda la tabla al buscar usuarios por apellido.
CREATE INDEX idx_usuarios_apellidos ON usuarios (apellidos);

-- R11 FUNCIÓN
DELIMITER $$
CREATE FUNCTION fn_costo_viaje(p_km DECIMAL(7,1), p_plan VARCHAR(10))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE v_costo DECIMAL(10,2);
  SET v_costo = 1800 + 700 * p_km;
  IF p_plan = 'PREMIUM' THEN
    SET v_costo = v_costo * 0.75;
  END IF;
  RETURN ROUND(v_costo, 2);
END$$
DELIMITER ;

SELECT fn_costo_viaje(10, 'BASICO') AS costo_basico,
       fn_costo_viaje(10, 'PREMIUM') AS costo_premium;

SELECT v.id_viaje, u.plan, v.km, fn_costo_viaje(v.km, u.plan) AS costo
FROM viajes v
JOIN usuarios u ON u.id_usuario = v.id_usuario
WHERE v.estado = 'FINALIZADO' AND v.id_estacion_origen = 1
ORDER BY costo DESC;

-- R12 TRIGGER
DELIMITER $$
CREATE TRIGGER trg_bicicletas_estado
AFTER UPDATE ON bicicletas
FOR EACH ROW
BEGIN
  IF NOT (OLD.estado <=> NEW.estado) THEN
    INSERT INTO historial_bicicletas (id_bici, estado_anterior, estado_nuevo)
    VALUES (NEW.id_bici, OLD.estado, NEW.estado);
  END IF;
END$$
DELIMITER ;

UPDATE bicicletas SET estado = 'ACTIVA' WHERE codigo = 'CV-M02';
UPDATE bicicletas SET estado = 'BAJA' WHERE codigo = 'CV-E03';
UPDATE bicicletas SET km_recorridos = km_recorridos + 5 WHERE codigo = 'CV-E01';

SELECT b.codigo, h.estado_anterior, h.estado_nuevo, h.fecha_cambio
FROM historial_bicicletas h
JOIN bicicletas b ON b.id_bici = h.id_bici
ORDER BY h.id_historial;

-- R13 PROCEDIMIENTO
DELIMITER $$
CREATE PROCEDURE sp_iniciar_viaje(
  IN p_id_usuario INT,
  IN p_id_bici INT,
  IN p_fecha DATETIME
)
BEGIN
  DECLARE v_estado VARCHAR(10);
  DECLARE v_estacion INT;
  DECLARE v_en_curso INT;

  SELECT estado, id_estacion INTO v_estado, v_estacion
  FROM bicicletas WHERE id_bici = p_id_bici;

  IF v_estado IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La bicicleta no existe';
  END IF;

  IF v_estado <> 'ACTIVA' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'La bicicleta no está ACTIVA: no puede iniciar un viaje';
  END IF;

  SELECT COUNT(*) INTO v_en_curso
  FROM viajes WHERE id_usuario = p_id_usuario AND estado = 'EN_CURSO';

  IF v_en_curso > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El usuario ya tiene un viaje EN_CURSO';
  END IF;

  INSERT INTO viajes (id_usuario, id_bici, id_estacion_origen, fecha_inicio)
  VALUES (p_id_usuario, p_id_bici, v_estacion, p_fecha);

  SELECT LAST_INSERT_ID() AS id_viaje_creado;
END$$
DELIMITER ;

CALL sp_iniciar_viaje(7, 3, '2026-10-16 08:00:00');
-- CALL sp_iniciar_viaje(8, 4, '2026-10-16 08:05:00');
-- CALL sp_iniciar_viaje(2, 1, '2026-10-16 08:10:00');

SELECT * FROM viajes WHERE id_usuario IN (2, 7, 8) ORDER BY id_viaje;