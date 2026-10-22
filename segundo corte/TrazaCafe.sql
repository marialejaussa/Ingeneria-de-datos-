
DROP DATABASE IF EXISTS trazacafe;
CREATE DATABASE trazacafe CHARACTER SET utf8mb4;
USE trazacafe;
SET NAMES utf8mb4;

CREATE TABLE caficultores (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    documento VARCHAR(20)  NOT NULL,
    telefono   VARCHAR(15)  NULL,
    activo     BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uk_caficultores_documento UNIQUE (documento)
);

CREATE TABLE catadores (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT uk_catadores_nombre UNIQUE (nombre)
);

CREATE TABLE clientes (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    email  VARCHAR(100) NOT NULL,
    ciudad VARCHAR(60)  NULL,
    CONSTRAINT uk_clientes_email UNIQUE (email)
);

CREATE TABLE fincas (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    caficultor_id INT          NOT NULL,
    municipio     VARCHAR(60)  NOT NULL,
    departamento  VARCHAR(40)  NOT NULL,
    altitud_m     INT          NOT NULL,
    CONSTRAINT chk_fincas_altitud CHECK (altitud_m BETWEEN 800 AND 2500),
    CONSTRAINT fk_fincas_caficultor FOREIGN KEY (caficultor_id)
        REFERENCES caficultores(id) ON DELETE RESTRICT
);

CREATE TABLE lotes (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    codigo        VARCHAR(20)   NOT NULL,
    finca_id      INT           NOT NULL,
    variedad      VARCHAR(30)   NOT NULL,
    proceso       VARCHAR(10)   NOT NULL,
    fecha_cosecha DATE          NOT NULL,
    kilos         DECIMAL(7,2)  NOT NULL,
    CONSTRAINT uk_lotes_codigo UNIQUE (codigo),
    CONSTRAINT chk_lotes_proceso CHECK (proceso IN ('lavado','honey','natural')),
    CONSTRAINT chk_lotes_kilos CHECK (kilos > 0),
    CONSTRAINT fk_lotes_finca FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE RESTRICT
);

CREATE TABLE cataciones (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    lote_id        INT          NOT NULL,
    catador_id     INT          NOT NULL,
    fecha_catacion DATE         NOT NULL,
    puntaje        DECIMAL(5,2) NOT NULL,
    CONSTRAINT chk_cataciones_puntaje CHECK (puntaje BETWEEN 0 AND 100),
    CONSTRAINT fk_cataciones_lote FOREIGN KEY (lote_id) REFERENCES lotes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_cataciones_catador FOREIGN KEY (catador_id) REFERENCES catadores(id) ON DELETE RESTRICT
);

CREATE TABLE tostiones (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    lote_id       INT          NOT NULL,
    fecha         DATE         NOT NULL,
    kilos_entrada DECIMAL(7,2) NOT NULL,
    kilos_salida  DECIMAL(7,2) NOT NULL,
    perfil        VARCHAR(10)  NOT NULL,
    CONSTRAINT chk_tostiones_perfil CHECK (perfil IN ('claro','medio','oscuro')),
    CONSTRAINT chk_tostiones_kilos CHECK (kilos_salida <= kilos_entrada),
    CONSTRAINT chk_tostiones_entrada CHECK (kilos_entrada > 0 AND kilos_salida > 0),
    CONSTRAINT fk_tostiones_lote FOREIGN KEY (lote_id) REFERENCES lotes(id) ON DELETE RESTRICT
);

CREATE TABLE pedidos (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id   INT         NOT NULL,
    fecha_pedido DATE        NOT NULL DEFAULT (CURRENT_DATE),
    estado       VARCHAR(12) NOT NULL DEFAULT 'pendiente',
    CONSTRAINT chk_pedidos_estado CHECK (estado IN ('pendiente','confirmado','enviado','entregado','cancelado')),
    CONSTRAINT fk_pedidos_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
);

CREATE TABLE lineas_pedido (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id  INT           NOT NULL,
    tostion_id INT           NOT NULL,
    kilos      DECIMAL(7,2)  NOT NULL,
    precio_kg  DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_lineas_kilos CHECK (kilos > 0),
    CONSTRAINT chk_lineas_precio CHECK (precio_kg > 0),
    CONSTRAINT fk_lineas_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    CONSTRAINT fk_lineas_tostion FOREIGN KEY (tostion_id) REFERENCES tostiones(id) ON DELETE RESTRICT
);

DESCRIBE fincas;
DESCRIBE lotes;
SHOW TABLES;

INSERT INTO caficultores (nombre, documento) VALUES ('Prueba Restricciones', '000');
INSERT INTO fincas (nombre, caficultor_id, municipio, departamento, altitud_m)
VALUES ('Finca Prueba', 1, 'Pitalito', 'Huila', 1500);
INSERT INTO lotes (codigo, finca_id, variedad, proceso, fecha_cosecha, kilos)
VALUES ('TST-2026-001', 1, 'Castillo', 'lavado', '2026-01-10', 100);
INSERT INTO catadores (nombre) VALUES ('Catador Prueba');

INSERT INTO fincas (nombre, caficultor_id, municipio, departamento, altitud_m)
VALUES ('Finca Muy Baja', 1, 'Girardot', 'Cundinamarca', 500);

INSERT INTO cataciones (lote_id, catador_id, fecha_catacion, puntaje) VALUES (1, 1, '2026-01-20', 101.00);

INSERT INTO lotes (codigo, finca_id, variedad, proceso, fecha_cosecha, kilos)
VALUES ('TST-2026-001', 1, 'Caturra', 'honey', '2026-01-11', 50);

INSERT INTO tostiones (lote_id, fecha, kilos_entrada, kilos_salida, perfil) VALUES (1, '2026-01-25', 50, 60, 'medio');

INSERT INTO lotes (codigo, finca_id, variedad, proceso, fecha_cosecha, kilos)
VALUES ('TST-2026-002', 999, 'Caturra', 'honey', '2026-01-11', 50);

INSERT INTO lotes (codigo, finca_id, variedad, proceso, fecha_cosecha, kilos)
VALUES ('TST-2026-003', 1, 'Caturra', 'fermentado', '2026-01-11', 50);

INSERT INTO clientes (nombre, email, ciudad) VALUES ('Cliente Prueba', 'prueba@correo.com', 'Bogotá');
INSERT INTO pedidos (cliente_id) VALUES (1);
SELECT id, estado FROM pedidos;         

DELETE FROM pedidos;
DELETE FROM clientes;
DELETE FROM lotes;
DELETE FROM catadores;
DELETE FROM fincas;
DELETE FROM caficultores;
ALTER TABLE pedidos AUTO_INCREMENT = 1;
ALTER TABLE clientes AUTO_INCREMENT = 1;
ALTER TABLE lotes AUTO_INCREMENT = 1;
ALTER TABLE catadores AUTO_INCREMENT = 1;
ALTER TABLE fincas AUTO_INCREMENT = 1;
ALTER TABLE caficultores AUTO_INCREMENT = 1;

ALTER TABLE clientes ADD COLUMN pais VARCHAR(40) NOT NULL DEFAULT 'Colombia';

ALTER TABLE tostiones ADD COLUMN huella_carbono_kg DECIMAL(8,2) NULL;
ALTER TABLE tostiones ADD CONSTRAINT chk_tostiones_huella CHECK (huella_carbono_kg IS NULL OR huella_carbono_kg >= 0);

ALTER TABLE lotes         MODIFY COLUMN kilos         DECIMAL(10,2) NOT NULL;
ALTER TABLE tostiones     MODIFY COLUMN kilos_entrada DECIMAL(10,2) NOT NULL;
ALTER TABLE tostiones     MODIFY COLUMN kilos_salida  DECIMAL(10,2) NOT NULL;
ALTER TABLE lineas_pedido MODIFY COLUMN kilos         DECIMAL(10,2) NOT NULL;

CREATE TABLE certificaciones (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL,
    CONSTRAINT uk_certificaciones_nombre UNIQUE (nombre)
);
CREATE TABLE finca_certificaciones (
    finca_id         INT  NOT NULL,
    certificacion_id INT  NOT NULL,
    vigente_hasta    DATE NULL,
    CONSTRAINT pk_finca_certificaciones PRIMARY KEY (finca_id, certificacion_id),
    CONSTRAINT fk_fincacert_finca FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE RESTRICT,
    CONSTRAINT fk_fincacert_cert FOREIGN KEY (certificacion_id) REFERENCES certificaciones(id) ON DELETE RESTRICT
);

ALTER TABLE tostiones RENAME COLUMN fecha TO fecha_tostion;

DESCRIBE tostiones;

INSERT INTO caficultores (nombre, documento, telefono) VALUES
('Gilberto Ortiz Mora',      '12345678', '3101112233'),
('María Eugenia Cardona',    '41234567', '3112223344'),
('Hernán Bedoya Pantoja',    '98765432', '3123334455'),
('Lucía Paredes Londoño',    '43987654', '3134445566');

INSERT INTO fincas (nombre, caficultor_id, municipio, departamento, altitud_m) VALUES
('Finca La Esperanza', 1, 'Pitalito', 'Huila',      1750),
('Finca El Mirador',   2, 'Salento',  'Quindío',    1900),
('Finca Los Naranjos', 3, 'Buesaco',  'Nariño',     2050),
('Finca La Cumbre',    4, 'Jardín',   'Antioquia',  1800);

INSERT INTO certificaciones (nombre) VALUES ('Orgánico'), ('Fair Trade'), ('Rainforest Alliance');

INSERT INTO finca_certificaciones (finca_id, certificacion_id, vigente_hasta) VALUES
(1, 1, '2027-06-30'), (1, 2, '2027-03-31'), (2, 2, '2026-12-31'), (3, 1, '2027-09-30');

INSERT INTO lotes (codigo, finca_id, variedad, proceso, fecha_cosecha, kilos) VALUES
('HUI-2026-014', 1, 'Caturra', 'lavado',  '2026-02-10', 350.00),
('HUI-2026-015', 1, 'Geisha',  'honey',   '2026-02-12', 120.00),
('QUI-2026-003', 2, 'Castillo','lavado',  '2026-02-20', 500.00),
('QUI-2026-004', 2, 'Bourbon', 'natural', '2026-02-22', 200.00),
('NAR-2026-007', 3, 'Caturra', 'lavado',  '2026-03-01', 420.00),
('NAR-2026-008', 3, 'Geisha',  'natural', '2026-03-03',  90.00),
('ANT-2026-002', 4, 'Castillo','honey',   '2026-03-05', 380.00),
('ANT-2026-003', 4, 'Bourbon', 'lavado',  '2026-03-06', 260.00);

INSERT INTO catadores (nombre) VALUES ('Andrea Salazar'), ('Julián Mejía'), ('Camila Restrepo');

INSERT INTO cataciones (lote_id, catador_id, fecha_catacion, puntaje) VALUES
(1, 1, '2026-02-25', 86.50), (1, 2, '2026-02-25', 86.00),
(2, 1, '2026-02-26', 90.25), (2, 3, '2026-02-26', 89.75),
(3, 2, '2026-03-02', 82.00),
(4, 1, '2026-03-03', 83.50), (4, 3, '2026-03-03', 84.00),
(5, 1, '2026-03-10', 85.00), (5, 2, '2026-03-10', 85.50),
(6, 3, '2026-03-12', 88.00),
(7, 2, '2026-03-14', 80.50);

INSERT INTO tostiones (lote_id, fecha_tostion, kilos_entrada, kilos_salida, perfil, huella_carbono_kg) VALUES
(1, '2026-03-02', 100.00,  84.00, 'medio',  12.40),
(2, '2026-03-05',  40.00,  33.50, 'claro',   5.10),
(3, '2026-03-10', 150.00, 126.00, 'medio',  18.75),
(5, '2026-03-14', 120.00, 100.00, 'oscuro', 14.90),
(6, '2026-03-20',  30.00,  25.00, 'claro',   4.20);

INSERT INTO clientes (nombre, email, ciudad, pais) VALUES
('Röststätte Berlin GmbH', 'einkauf@roeststaette-berlin.de', 'Berlín',   'Alemania'),
('Café Aurora S.A.S.',     'compras@cafeaurora.co',          'Medellín', 'Colombia'),
('Tostadores del Sur',     'pedidos@tostadoresdelsur.co',    'Cali',     'Colombia');

INSERT INTO pedidos (cliente_id, fecha_pedido, estado) VALUES
(1, '2026-04-01', 'confirmado'),
(1, '2026-05-10', 'pendiente'),
(2, '2026-04-15', 'entregado'),
(3, '2026-05-02', 'enviado');

INSERT INTO lineas_pedido (pedido_id, tostion_id, kilos, precio_kg) VALUES
(1, 1, 20.00, 62000.00), (1, 2, 10.00, 150000.00),
(2, 4, 30.00, 58000.00),
(3, 3, 50.00, 48000.00), (3, 1, 15.00, 62000.00),
(4, 5, 12.00, 140000.00), (4, 3, 25.00, 48000.00);

CREATE TABLE lotes_especialidad (
    codigo_lote      VARCHAR(20)  NOT NULL PRIMARY KEY,
    puntaje_promedio DECIMAL(5,2) NOT NULL
);
INSERT INTO lotes_especialidad (codigo_lote, puntaje_promedio)
SELECT l.codigo, AVG(c.puntaje)
FROM lotes l
JOIN cataciones c ON c.lote_id = l.id
GROUP BY l.codigo
HAVING AVG(c.puntaje) >= 85;

SELECT * FROM lotes_especialidad;   

CREATE TABLE precios_referencia (
    variedad       VARCHAR(30)   NOT NULL PRIMARY KEY,
    precio_kg      DECIMAL(10,2) NOT NULL,
    actualizado_en DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO precios_referencia (variedad, precio_kg) VALUES
('Castillo', 32000), ('Caturra', 35500), ('Geisha', 120000);
SELECT * FROM precios_referencia;
SELECT SLEEP(2);   

INSERT INTO precios_referencia (variedad, precio_kg) VALUES
('Caturra', 36800), ('Geisha', 118000), ('Bourbon', 41000) AS nuevo
ON DUPLICATE KEY UPDATE precio_kg = nuevo.precio_kg, actualizado_en = NOW();

SELECT * FROM precios_referencia ORDER BY variedad;
SELECT COUNT(*) AS variedades FROM precios_referencia;

SELECT c.id, l.codigo, c.puntaje
FROM cataciones c JOIN lotes l ON l.id = c.lote_id
WHERE c.catador_id = 2;                            

UPDATE cataciones
SET puntaje = GREATEST(puntaje - 1.5, 0)
WHERE catador_id = 2;                              

SELECT lp.id, lp.precio_kg
FROM lineas_pedido lp
JOIN pedidos p  ON p.id = lp.pedido_id
JOIN clientes c ON c.id = p.cliente_id
WHERE c.pais = 'Alemania';                         

UPDATE lineas_pedido lp
JOIN pedidos p  ON p.id = lp.pedido_id
JOIN clientes c ON c.id = p.cliente_id
SET lp.precio_kg = lp.precio_kg * 0.90
WHERE c.pais = 'Alemania';                         

DELETE FROM fincas WHERE id = 1;

ALTER TABLE fincas ADD COLUMN activa BOOLEAN NOT NULL DEFAULT TRUE;
UPDATE fincas SET activa = FALSE WHERE id = 1;
UPDATE caficultores SET activo = FALSE WHERE id = 1;
SELECT id, nombre, activa FROM fincas;

INSERT INTO lotes (codigo, finca_id, variedad, proceso, fecha_cosecha, kilos)
VALUES ('PRU-2026-001', 4, 'Castillo', 'lavado', '2026-03-10', 10.00);
INSERT INTO cataciones (lote_id, catador_id, fecha_catacion, puntaje)
SELECT id, 1, '2026-03-15', 79.00 FROM lotes WHERE codigo = 'PRU-2026-001';
INSERT INTO cataciones (lote_id, catador_id, fecha_catacion, puntaje)
SELECT id, 3, '2026-03-15', 78.50 FROM lotes WHERE codigo = 'PRU-2026-001';
DELETE c
FROM cataciones c
JOIN lotes l ON l.id = c.lote_id
WHERE l.codigo = 'PRU-2026-001';                    
DELETE FROM lotes WHERE codigo = 'PRU-2026-001';  

TRUNCATE TABLE lotes_especialidad;
DROP TABLE lotes_especialidad;

ALTER TABLE tostiones ADD COLUMN kilos_disponibles DECIMAL(10,2) NOT NULL DEFAULT 0;
UPDATE tostiones t
SET t.kilos_disponibles = t.kilos_salida - COALESCE((SELECT SUM(lp.kilos) FROM lineas_pedido lp WHERE lp.tostion_id = t.id), 0);
ALTER TABLE tostiones ADD CONSTRAINT chk_tostiones_disponibles CHECK (kilos_disponibles >= 0);
SELECT id, kilos_salida, kilos_disponibles FROM tostiones;   

START TRANSACTION;
INSERT INTO pedidos (cliente_id) VALUES (2);
SET @pedido = LAST_INSERT_ID();
INSERT INTO lineas_pedido (pedido_id, tostion_id, kilos, precio_kg) VALUES (@pedido, 4, 20.00, 58000.00);
UPDATE tostiones SET kilos_disponibles = kilos_disponibles - 20.00 WHERE id = 4;
INSERT INTO lineas_pedido (pedido_id, tostion_id, kilos, precio_kg) VALUES (@pedido, 5, 5.00, 140000.00);
UPDATE tostiones SET kilos_disponibles = kilos_disponibles - 5.00 WHERE id = 5;
COMMIT;
SELECT id, kilos_disponibles FROM tostiones WHERE id IN (4, 5);   

START TRANSACTION;
INSERT INTO pedidos (cliente_id) VALUES (2);
SET @pedido = LAST_INSERT_ID();
INSERT INTO lineas_pedido (pedido_id, tostion_id, kilos, precio_kg) VALUES (@pedido, 5, 40.00, 140000.00);
UPDATE tostiones SET kilos_disponibles = kilos_disponibles - 40.00 WHERE id = 5;   
ROLLBACK;
SELECT COUNT(*) AS pedidos_del_desastre FROM pedidos WHERE id = @pedido;             
SELECT COUNT(*) AS lineas_del_desastre  FROM lineas_pedido WHERE pedido_id = @pedido; 

START TRANSACTION;
INSERT INTO pedidos (cliente_id) VALUES (3);
SET @pedido = LAST_INSERT_ID();
INSERT INTO lineas_pedido (pedido_id, tostion_id, kilos, precio_kg) VALUES (@pedido, 4, 10.00, 58000.00);
UPDATE tostiones SET kilos_disponibles = kilos_disponibles - 10.00 WHERE id = 4;
SAVEPOINT despues_linea1;
INSERT INTO lineas_pedido (pedido_id, tostion_id, kilos, precio_kg) VALUES (@pedido, 2, 5.00, 150000.00);
UPDATE tostiones SET kilos_disponibles = kilos_disponibles - 5.00 WHERE id = 2;
ROLLBACK TO SAVEPOINT despues_linea1;      
COMMIT;                                    
SELECT pedido_id, tostion_id, kilos FROM lineas_pedido WHERE pedido_id = @pedido;   
SELECT id, kilos_disponibles FROM tostiones WHERE id IN (2, 4);                     

START TRANSACTION;
CREATE TABLE prueba (id INT);
ROLLBACK;
SHOW TABLES LIKE 'prueba';    
DROP TABLE IF EXISTS prueba;

ALTER TABLE fincas ADD COLUMN latitud  DECIMAL(9,6) NULL;
ALTER TABLE fincas ADD COLUMN longitud DECIMAL(9,6) NULL;
ALTER TABLE fincas ADD CONSTRAINT chk_fincas_coordenadas
    CHECK ((latitud IS NULL OR latitud BETWEEN -90 AND 90) AND (longitud IS NULL OR longitud BETWEEN -180 AND 180));
UPDATE fincas SET latitud = 1.853700, longitud = -76.050900 WHERE nombre = 'Finca La Esperanza';
UPDATE fincas SET latitud = 4.637500, longitud = -75.570200 WHERE nombre = 'Finca El Mirador';

DROP VIEW IF EXISTS v_trazabilidad;
CREATE OR REPLACE VIEW v_trazabilidad AS
SELECT lp.id            AS linea_id,
       p.id             AS pedido_id,
       c.nombre         AS cliente,
       c.pais,
       f.nombre         AS finca,
       cf.nombre        AS caficultor,
       f.municipio,
       f.altitud_m,
       f.latitud,
       f.longitud,
       l.variedad,
       l.proceso,
       ROUND(pm.puntaje_prom, 2) AS puntaje_sca_promedio,
       t.fecha_tostion,
       t.perfil,
       CONCAT(l.variedad, ' ', l.proceso, ' de ', f.nombre, ', ', f.municipio,
              ' (', REPLACE(FORMAT(f.altitud_m, 0), ',', '.'), ' m). ',
              'Puntaje ', REPLACE(CAST(ROUND(pm.puntaje_prom, 2) AS CHAR), '.', ','), '. ',
              'Tostado ', t.perfil, ' el ', t.fecha_tostion, '.') AS texto_qr
FROM lineas_pedido lp
JOIN pedidos p       ON p.id  = lp.pedido_id
JOIN clientes c      ON c.id  = p.cliente_id
JOIN tostiones t     ON t.id  = lp.tostion_id
JOIN lotes l         ON l.id  = t.lote_id
JOIN fincas f        ON f.id  = l.finca_id
JOIN caficultores cf ON cf.id = f.caficultor_id
LEFT JOIN (SELECT lote_id, AVG(puntaje) AS puntaje_prom FROM cataciones GROUP BY lote_id) pm
       ON pm.lote_id = l.id;

SELECT linea_id, cliente, finca, caficultor, variedad, proceso, puntaje_sca_promedio, perfil, texto_qr
FROM v_trazabilidad
WHERE pedido_id = 1
ORDER BY linea_id;