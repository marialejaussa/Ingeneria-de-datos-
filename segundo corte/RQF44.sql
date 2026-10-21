-- ========================================================
-- Del microdato al indicador - Entregable 2
-- Realizado por: Lina Bautista, Jessica Gil, Mariana Ussa y Jorge Reza
-- ========================================================

-- 1. Creación y uso de la base de datos
drop database if exists proyecto_geih;
create database proyecto_geih;
use proyecto_geih;

-- 2. Creación de las tablas según modelo de BD

-- 2.1 Tabla Persona
create table persona (
	idPersona varchar (20) not null primary key, 
	idPeriodo int not null, 
	idsexo int not null, 
	edad int not null, 
	pet  TINYINT(1) generated always as (edad >= 15) stored,  -- población en edad de trabajar
	clase int not null, 
	area int not null,
	factorExpansion decimal (14, 4) not null, 
	constraint chk_edad
		check (edad between 0 and 120), 
	constraint chk_clase
		check (clase in (1,2)),
	constraint chk_fex
		check (factorExpansion > 0)
);

-- 2.2 Tabla Ocupado

create table ocupado (
  idPersona     varchar(12)  not null primary key,
  idRama        int          null,            -- 13 ramas agrupadas; NULL si no sabe, no informa o viene vacía
  horasTrabajo  decimal(5,2) null,
  ingreso        decimal(14,2) null,
  cotizaPension tinyint(1)   not null,
  constraint fkOcupadoPersona 
  	foreign key (idPersona) 
  	references persona (idPersona),
  constraint chk_OcupadoHoras   
  	check (horasTrabajo is null or horasTrabajo between 0 and 168),
  constraint chk_OcupadoIngreso 
  check (ingreso is null or ingreso >= 0)
);


-- 2.3 Tabla Desocupado
create table desocupado(
	idPersona varchar(12) not null primary key,
	constraint fk_desocupadoPersona
		foreign key (idPersona)
		references persona(idPersona)
);


-- 2.4 Tabla Usuario
create table usuario (
  idUsuario int auto_increment not null primary key,
  nombreUsuario varchar(100) not null,
  correoUsuario varchar(150) not null,
  rolUsuario varchar(50)  not null,
  activo tinyint(1)   not null default 1,   -- 1 activo, 0 inactivo (el usuario no se elimina)
  constraint uqUsuarioCorreo 
  	unique (correoUsuario),
  constraint chk_UsuarioRol 
  	check (rolUsuario in ('administrador', 'ingeniero de datos', 'investigador')),
  constraint chk_UsuarioActivo 
  	check (activo in (0, 1))
);

-- 2.5 Tabla Periodo
create table periodo (
	idPeriodo int not null primary key, 
	anio int not null, 
	mes int not null, 
	constraint uqPeriodo 
		unique (anio, mes), 
	constraint chk_periodo
		check (mes between 1 and 12 )
);

-- 2.6 Tabla Sexo
create table sexo(
    idSexo int not null primary key,
    nombreSexo varchar(20) not null,
    constraint uqNomSexo
    	unique(nombreSexo)
);

-- 2.7 Tabla RangoEdad
create table rangoEdad(
	idRangoEdad int auto_increment not null primary key ,
	nombreRangoEdad varchar(20) not null unique,
	edadInicial int not null,
	edadFinal int null, -- Es nula en el rango de 60 años o más
	constraint chk_rango_edad 
		check(edadFinal is null or edadFinal >=edadInicial)
);


-- 2.8 Tabla Territorio
create table territorio(
	idTerritorio int not null primary key,
	nombreTerritorio varchar(80) not null,
	tipoTerritorio varchar(20) not null,
	constraint chk_tipoTerritorio 
		check(tipoTerritorio in('nacional', 'zona', 'ciudad'))
);


-- 2.9 Tabla RamaActividad
create table ramaActividad(
    idRamaActividad int not null primary key,
    nombreRama varchar(100) not null
);

-- 2.10 Tabla TipoIndicador
create table TipoIndicador(
idTipoIndicador int not null auto_increment primary key,
idPeriodo int not null,
idSexo int  null,
idRangoEdad int  null,
idTerritorio int  null,
idRamaActividad int  null,
nombreIndicador varchar(100) not null,
formula text not null,
periodicidad varchar(10) not null,
constraint chk_periodicidad
	check(periodicidad in ('mensual', 'anual')),
constraint fk_periodo
	foreign key (idPeriodo)
	references periodo(idPeriodo),
constraint fk_sexo
	foreign key (idSexo)
	references sexo(idSexo),
constraint fk_rango
	foreign key (idRangoEdad)
	references rangoEdad(idRangoEdad),
constraint fk_territorio
	foreign key (idTerritorio)
	references territorio(idTerritorio),
constraint fk_rama
	foreign key (idRamaActividad)
	references ramaActividad(idRamaActividad)
);

-- 2.11 Tabla Indicador
create table indicador(
	idIndicador int auto_increment not null primary key,
	idTipoIndicador int not null,
	idUsuario int not null,
	valorIndicador decimal(15,4) not null,
	cvIndicador decimal(8,4) null, -- Casos en los que no se pueda calcular el cv
	fechaCalculoIndicador date not null,
	constraint chk_cvIndicador
		check (cvIndicador is null or cvIndicador >= 0),
	constraint fk_idTipoIndicador
		foreign key(idTipoIndicador)
		references tipoIndicador(idTipoIndicador),
	constraint fk_idUsuario
		foreign key(idUsuario)
		references usuario(idUsuario)
);
	
		
-- 2.12 Tabla AuditoriaIndicador -- Para hacer auditoria a indicador
create table auditoriaIndicador(
	idAuditoria int auto_increment not null primary key,
	idIndicador int not null,
	accionAuditoria varchar(10) not null,
	valorAnteriorIndicador decimal(15,4) null,
	valorNuevoIndicador decimal(15,4) null,
	usuarioBD varchar(100) not null,
	fechaAuditoria date not null,
	constraint chk_accionAuditoria
		check (accionAuditoria in ('INSERT', 'UPDATE', 'DELETE'))
);

-- 3. Inserciones en tablas

-- 3.1 Tabla Usuario
insert into usuario (nombreUsuario, correoUsuario, rolUsuario, activo) values
	('Mariana Vargas', 'mariana@example.com', 'administrador', 1),
	('Jessica Tellez', 'jessica@example.com', 'ingeniero de datos', 1),
	('Jorge Díaz', 'jorge@example.com', 'ingeniero de datos', 1),
	('Lina Parra', 'lina@example.com', 'ingeniero de datos', 1),
	('Camila Ramírez Moreno', 'camila.ramirez01@example.com', 'investigador', 1),
	('Andrés Cárdenas Peña', 'andres.cardenas02@example.com', 'investigador', 1),
	('Valentina Rincón Torres', 'valentina.rincon03@example.com', 'investigador', 1),
	('Santiago Montoya Quintero', 'santiago.montoya04@example.com', 'investigador', 1),
	('Daniela Herrera Montoya', 'daniela.herrera05@example.com', 'investigador', 1),
	('Sebastián Quintero Cárdenas', 'sebastian.quintero06@example.com', 'investigador', 1),
	('Laura Suárez Ibáñez', 'laura.suarez07@example.com', 'investigador', 1),
	('Juan Torres Vargas', 'juan.torres08@example.com', 'investigador', 1),
	('Paula Mejía Duarte', 'paula.mejia09@example.com', 'investigador', 0),
	('Felipe Peña Castro', 'felipe.pena10@example.com', 'investigador', 1),
	('Natalia Franco Acosta', 'natalia.franco11@example.com', 'investigador', 1),
	('David Moreno Gómez', 'david.moreno12@example.com', 'investigador', 1),
	('Carolina Salazar Salazar', 'carolina.salazar13@example.com', 'investigador', 1),
	('Mateo Cortés Franco', 'mateo.cortes14@example.com', 'investigador', 1),
	('Isabella Gómez Mejía', 'isabella.gomez15@example.com', 'investigador', 1),
	('Nicolás Ortiz Suárez', 'nicolas.ortiz16@example.com', 'investigador', 1),
	('Sofía Acosta Herrera', 'sofia.acosta17@example.com', 'investigador', 1),
	('Daniel Lozano Rincón', 'daniel.lozano18@example.com', 'investigador', 0),
	('María Castro Ramírez', 'maria.castro19@example.com', 'investigador', 1),
	('Alejandro Pineda Beltrán', 'alejandro.pineda20@example.com', 'investigador', 1),
	('Luisa Duarte Rojas', 'luisa.duarte21@example.com', 'investigador', 1),
	('Tomás Rojas Pineda', 'tomas.rojas22@example.com', 'investigador', 1),
	('Juliana Vargas Lozano', 'juliana.vargas23@example.com', 'investigador', 1),
	('Esteban Beltrán Ortiz', 'esteban.beltran24@example.com', 'investigador', 1),
	('Manuela Ibáñez Cortés', 'manuela.ibanez25@example.com', 'investigador', 1),
	('Camila Ramírez Moreno', 'camila.ramirez26@example.com', 'investigador', 1),
	('Andrés Cárdenas Peña', 'andres.cardenas27@example.com', 'investigador', 0),
	('Valentina Rincón Torres', 'valentina.rincon28@example.com', 'investigador', 1),
	('Santiago Montoya Quintero', 'santiago.montoya29@example.com', 'investigador', 1),
	('Daniela Herrera Montoya', 'daniela.herrera30@example.com', 'investigador', 1),
	('Sebastián Quintero Cárdenas', 'sebastian.quintero31@example.com', 'investigador', 1),
	('Laura Suárez Ibáñez', 'laura.suarez32@example.com', 'investigador', 1),
	('Juan Torres Vargas', 'juan.torres33@example.com', 'investigador', 1),
	('Paula Mejía Duarte', 'paula.mejia34@example.com', 'investigador', 1),
	('Felipe Peña Castro', 'felipe.pena35@example.com', 'investigador', 1),
	('Natalia Franco Acosta', 'natalia.franco36@example.com', 'investigador', 0),
	('David Moreno Gómez', 'david.moreno37@example.com', 'investigador', 1),
	('Carolina Salazar Salazar', 'carolina.salazar38@example.com', 'investigador', 1),
	('Mateo Cortés Franco', 'mateo.cortes39@example.com', 'investigador', 1),
	('Isabella Gómez Mejía', 'isabella.gomez40@example.com', 'investigador', 1),
	('Nicolás Ortiz Suárez', 'nicolas.ortiz41@example.com', 'investigador', 1),
	('Sofía Acosta Herrera', 'sofia.acosta42@example.com', 'investigador', 1),
	('Daniel Lozano Rincón', 'daniel.lozano43@example.com', 'investigador', 1),
	('María Castro Ramírez', 'maria.castro44@example.com', 'investigador', 1),
	('Alejandro Pineda Beltrán', 'alejandro.pineda45@example.com', 'investigador', 0),
	('Luisa Duarte Rojas', 'luisa.duarte46@example.com', 'investigador', 1);
 
-- 3.2 Tabla Periodo 
insert ignore into periodo (idPeriodo, anio, mes)
values 
/* año 2022 */
(202201, 2022, 1),
(202202, 2022, 2),
(202203, 2022, 3),
(202204, 2022, 4),
(202205, 2022, 5),
(202206, 2022, 6),
(202207, 2022, 7),
(202208, 2022, 8),
(202209, 2022, 9),
(202210, 2022, 10),
(202211, 2022, 11),
(202212, 2022, 12),
/* año 2023 */
(202301, 2023, 1),
(202302, 2023, 2),
(202303, 2023, 3),
(202304, 2023, 4),
(202305, 2023, 5),
(202306, 2023, 6),
(202307, 2023, 7),
(202308, 2023, 8),
(202309, 2023, 9),
(202310, 2023, 10),
(202311, 2023, 11),
(202312, 2023, 12),
/* año 2024 */
(202401, 2024, 1),
(202402, 2024, 2),
(202403, 2024, 3),
(202404, 2024, 4),
(202405, 2024, 5),
(202406, 2024, 6),
(202407, 2024, 7),
(202408, 2024, 8),
(202409, 2024, 9),
(202410, 2024, 10),
(202411, 2024, 11),
(202412, 2024, 12),
/* año 2025 */
(202501, 2025, 1),
(202502, 2025, 2),
(202503, 2025, 3),
(202504, 2025, 4),
(202505, 2025, 5),
(202506, 2025, 6),
(202507, 2025, 7),
(202508, 2025, 8),
(202509, 2025, 9),
(202510, 2025, 10),
(202511, 2025, 11),
(202512, 2025, 12),
/* año 2026 */
(202601, 2026, 1),
(202602, 2026, 2),
(202603, 2026, 3),
(202604, 2026, 4),
(202605, 2026, 5),
(202606, 2026, 6),
(202607, 2026, 7),
(202608, 2026, 8),
(202609, 2026, 9),
(202610, 2026, 10);

-- 3.3 Tabla Sexo
insert into sexo (idSexo, nombreSexo) values
	(1, 'Hombre'),
	(2, 'Mujer');

-- 3.4 Tabla RangoEdad
insert into rangoEdad (nombreRangoEdad, edadInicial, edadFinal) values 
	('15-17', 15, 17),
	('18-28', 18, 28),
	('29-44', 29, 44),
	('45-59', 45, 59),
	('60 o más', 60, null);

-- 3.5 Tabla Territorio
insert into territorio (idTerritorio, nombreTerritorio, tipoTerritorio) values
  	(3, 'Nacional', 'nacional'),
  	(1, 'Urbano', 'zona'),
  	(2, 'Resto', 'zona'),
  	(11, 'Bogotá D.C.', 'ciudad'),
  	(5, 'Medellín y A.M.', 'ciudad'),
  	(76, 'Cali y A.M.', 'ciudad'),
  	(8, 'Barranquilla y A.M.', 'ciudad'),
  	(68, 'Bucaramanga y A.M.', 'ciudad'),
  	(17, 'Manizales y A.M.', 'ciudad'),
  	(66, 'Pereira y A.M.', 'ciudad'),
  	(54, 'Cúcuta y A.M.', 'ciudad'),
  	(52, 'Pasto', 'ciudad'),
  	(73, 'Ibagué', 'ciudad'),
  	(23, 'Montería', 'ciudad'),
  	(13, 'Cartagena', 'ciudad'),
  	(50, 'Villavicencio', 'ciudad');

-- 3.6 Tabla RamaActividad
insert into ramaActividad (idRamaActividad, nombreRama) values
  (1, 'Agricultura, ganadería, caza, silvicultura y pesca'),
  (2, 'Suministro de electricidad, gas, agua y gestión de desechos'),
  (3, 'Industrias manufactureras'),
  (4, 'Construcción'),
  (5, 'Comercio y reparación de vehículos'),
  (6, 'Alojamiento y servicios de comida'),
  (7, 'Transporte y almacenamiento'),
  (8, 'Información y comunicaciones'),
  (9, 'Actividades financieras y de seguros'),
  (10, 'Actividades inmobiliarias'),
  (11, 'Actividades profesionales, científicas, técnicas y servicios administrativos'),
  (12, 'Administración pública y defensa, educación y atención de la salud humana'),
  (13, 'Actividades artísticas, entretenimiento, recreación y otras actividades de servicios');

-- 3.7 Tabla TipoIndicador

insert into tipoIndicador (idPeriodo, idSexo, idRangoEdad, idTerritorio, idRamaActividad, nombreIndicador, formula, periodicidad) values
  (202601, null, null, 3, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, 1, null, 3, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, 2, null, 3, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, null, 1, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, null, 2, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, null, 11, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, null, 5, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, null, 76, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, 1, 3, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, 2, 3, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, 3, 3, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, 4, 3, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, 5, 3, null, 'PEA', 'Suma del factor de expansión de ocupados y desocupados', 'mensual'),
  (202601, null, null, 3, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, 1, null, 3, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, 2, null, 3, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, null, 1, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, null, 2, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, null, 11, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, null, 5, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, null, 76, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, 1, 3, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, 2, 3, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, 3, 3, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, 4, 3, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, 5, 3, null, 'TGP', 'PEA / PET x 100', 'mensual'),
  (202601, null, null, 3, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, 1, null, 3, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, 2, null, 3, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, null, 1, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, null, 2, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, null, 11, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, null, 5, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, null, 76, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, 1, 3, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, 2, 3, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, 3, 3, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, 4, 3, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, 5, 3, null, 'Tasa de ocupación', 'Ocupados / PET x 100', 'mensual'),
  (202601, null, null, 3, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, 1, null, 3, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, 2, null, 3, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, null, 1, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, null, 2, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, null, 11, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, null, 5, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, null, 76, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, 1, 3, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, 2, 3, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, 3, 3, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, 4, 3, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, 5, 3, null, 'Tasa de desocupación', 'Desocupados / PEA x 100', 'mensual'),
  (202601, null, null, 3, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, 1, null, 3, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, 2, null, 3, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 1, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 2, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 11, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 5, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 76, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 1, 3, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 2, 3, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 3, 3, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 4, 3, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 5, 3, null, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, 1, null, 3, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, 2, null, 3, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 1, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 2, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 11, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 5, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 76, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 1, 3, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 2, 3, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 3, 3, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 4, 3, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, 5, 3, null, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, 1, null, 3, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, 2, null, 3, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 1, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 2, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 11, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 5, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 76, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, 1, 3, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, 2, 3, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, 3, 3, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, 4, 3, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, 5, 3, null, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 1, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 2, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 3, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 4, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 5, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 6, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 7, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 8, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 9, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 10, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 11, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 12, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 13, 'Salario promedio', 'Promedio del ingreso laboral de los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 1, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 2, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 3, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 4, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 5, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 6, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 7, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 8, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 9, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 10, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 11, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 12, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 13, 'Horas trabajadas', 'Promedio de horas semanales trabajadas por los ocupados, ponderado por el factor de expansión', 'mensual'),
  (202601, null, null, 3, 1, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 2, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 3, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 4, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 5, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 6, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 7, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 8, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 9, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 10, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 11, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 12, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual'),
  (202601, null, null, 3, 13, 'Tasa de informalidad', 'Ocupados que no cotizan a pensión / ocupados x 100', 'mensual');


-- Nota: Para las tablas de Persona, Ocupado y Desocupado se insertan 
-- los datos de la GEIH a usar que ya estan filtrados con las variables 
-- que necesitamos

show variables like 'secure_file_priv';
show grants for current_user();
show global variables like 'local_infile';
set global local_infile = 1;

-- Nota: Se pone una ruta fija para que cualquiera cambie la ubicación de la carpeta de los datos en su dispositivo
@set ruta = C:/Users/jessi/OneDrive/Documents/GitHub/Proyecto-ingeniera-de-datos-/Entregable 2/Datos para BD
-- 3.8 Tabla Persona
load data infile '${ruta}/2026/Enero/persona_202601.csv'
into table persona
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(idPersona, idPeriodo, idSexo, edad, clase, area, factorExpansion);

-- 3.2 Tabla Ocupado
load data infile '${ruta}/2026/Enero/ocupado_202601.csv'
into table ocupado
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(idPersona, idRama, horasTrabajo, ingreso, cotizaPension);

-- 3.3 Tabla Desocupado
load data infile '${ruta}/2026/Enero/desocupado_202601.csv'
into table desocupado
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(idPersona);

-- Insertar datos de otro periodo
load data infile '${ruta}/2026/Febrero/persona_202602.csv'
into table persona
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(idPersona, idPeriodo, idSexo, edad, clase, area, factorExpansion);

load data infile '${ruta}/2026/Febrero/ocupado_202602.csv'
into table ocupado
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(idPersona, idRama, horasTrabajo, ingreso, cotizaPension);

load data infile '${ruta}/2026/Febrero/desocupado_202602.csv'
into table desocupado
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(idPersona);

-- Verificación de la carga: personas por periodo y condición laboral
select idPeriodo, count(*) as personas from persona group by idPeriodo;
select (select count(*) from ocupado) as ocupados, (select count(*) from desocupado) AS desocupados;

-- 3.11 Tabla Indicador - No se puede crear aún porque primero el cálculo de los indicadores que va en indicador usa funciones
-- Nota: Para insertar datos en la tabla indicador toca crear unas funciones que calculen los indicadores 
-- y tambien un procedimiento almacenado.
-- Se crea una funcion por cada indicador

-- Es importante crear una vista que contenga la información que me permita calcular 
-- los indicadores por ejemplo una tabla general que muestre si la persona esta ocupada o desocupada

-- Creación de vista
create or replace view v_infoPersonas as
select p.idPersona, p.idPeriodo, p.idSexo, r.idRangoEdad, p.edad, p.pet, p.clase, p.area, p.factorExpansion,
	case when o.idPersona is not null then 'Ocupado'
		when d.idPersona is not null then 'Desocupado'
		when p.pet=1 then 'Inactivo'
		else 'Menor de 15' end as condicion,
	o.idRama, o.horasTrabajo, o.ingreso, o.CotizaPension
from persona p
left join ocupado o on o.idPersona = p.idPersona
left join desocupado d on d.idPErsona = p.idPersona
left join rangoEdad r on p.edad>=r.edadInicial and (r.edadFinal is null or p.edad<=r.edadFinal);

-- 5. Creación de funciones para calcular valores de la tabla indicador
-- (Función por cada indicador a calcular)

-- 5.1 Población en Edad de Trabajar (PET)

drop function if exists fn_indicador_pet;
create function fn_indicador_pet(p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns decimal (20,6)
reads sql data
begin
	declare v decimal(20,6);
	select sum(factorExpansion) into v
	from v_infoPersonas
	where pet =1 and idPeriodo = p_periodo
		and (p_sexo is null or idSexo=p_sexo)
		and (p_rango is null or idRangoEdad=p_rango)
		and (p_terr is null or p_terr =3 or (p_terr in (1,2) and clase = p_terr) or (p_terr>3 and area= p_terr));
	return v;
end; 

-- 5.2 Población económicamente activa (PEA): Ocupados y desocupados
drop function if exists fn_indicador_pea;
create function fn_indicador_pea(p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns decimal(20,6)
reads sql data
begin 
	declare v decimal(20,6);
	select sum(factorExpansion) into v
	from v_infoPersonas
	where condicion in ('Ocupado', 'Desocupado') and idPeriodo=p_periodo
		and (p_sexo is null or idSexo=p_sexo)
		and (p_rango is null or idRangoEdad = p_rango)
		and (p_terr is null or p_terr=3 or (p_terr in (1,2) and clase =p_terr) or (p_terr>3 and area = p_terr));
	return v;
end;

-- Ocupados
drop function if exists fn_indicador_ocupados;
create function fn_indicador_ocupados(p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns decimal (20,6)
reads sql data
begin
	declare v decimal(20,6);
	select sum(factorExpansion) into v
	from v_infoPersonas
	where condicion = 'Ocupado' and idPeriodo=p_periodo
		and (p_sexo is null or idSexo=p_sexo)
		and (p_rango is null or idRangoEdad = p_rango)
		and (p_terr is null or p_terr=3 or (p_terr in (1,2) and clase =p_terr) or (p_terr>3 and area = p_terr))
		and (p_rama is null or idRama=p_rama);
	return v;
end;

-- Desocupados
drop function if exists fn_indicador_desocupados;
create function fn_indicador_desocupados(p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns decimal (20,6)
reads sql data
begin
	declare v decimal(20,6);
	select sum(factorExpansion) into v
	from v_infoPersonas
	where condicion = 'Desocupado' and idPeriodo=p_periodo
		and (p_sexo is null or idSexo=p_sexo)
		and (p_rango is null or idRangoEdad = p_rango)
		and (p_terr is null or p_terr=3 or (p_terr in (1,2) and clase =p_terr) or (p_terr>3 and area = p_terr));
	return v;
end;

-- Ocupados informales (no cotizan a pensión)
drop function if exists fn_indicador_informales;
create function fn_indicador_informales(p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns decimal (20,6)
reads sql data
begin
	declare v decimal(20,6);
	select sum(factorExpansion) into v
	from v_infoPersonas
	where condicion = 'Ocupado' and cotizaPension=0 and idPeriodo=p_periodo
		and (p_sexo is null or idSexo=p_sexo)
		and (p_rango is null or idRangoEdad = p_rango)
		and (p_terr is null or p_terr=3 or (p_terr in (1,2) and clase =p_terr) or (p_terr>3 and area = p_terr))
		and (p_rama is null or idRama=p_rama);
	return v;
end;

-- Salario promedio de los ocupados (ponderado por factor de expansión)
drop function if exists fn_salario_promedio;
create function fn_salario_promedio(p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns decimal (20,6)
reads sql data
begin
	declare v decimal(20,6);
	select sum(factorExpansion * ingreso) / sum(factorExpansion) into v
	from v_infoPersonas
	where condicion = 'Ocupado' and ingreso>0 and idPeriodo=p_periodo
		and (p_sexo is null or idSexo=p_sexo)
		and (p_rango is null or idRangoEdad = p_rango)
		and (p_terr is null or p_terr=3 or (p_terr in (1,2) and clase =p_terr) or (p_terr>3 and area = p_terr))
		and (p_rama is null or idRama=p_rama);
	return v;
end;

-- Horas semanales trabajadas promedio (ponderado por factor de expansión)
drop function if exists fn_horas_promedio;
create function fn_horas_promedio(p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns decimal (20,6)
reads sql data
begin
	declare v decimal(20,6);
	select sum(factorExpansion * horasTrabajo) / sum(factorExpansion) into v
	from v_infoPersonas
	where condicion = 'Ocupado' and horasTrabajo is not null and idPeriodo=p_periodo
		and (p_sexo is null or idSexo=p_sexo)
		and (p_rango is null or idRangoEdad = p_rango)
		and (p_terr is null or p_terr=3 or (p_terr in (1,2) and clase =p_terr) or (p_terr>3 and area = p_terr))
		and (p_rama is null or idRama=p_rama);
	return v;
end;

-- Valor indicadores finales
drop function if exists fn_valor_indicador;
create function fn_valor_indicador(p_nombre varchar(100), p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns decimal (15,4)
reads sql data
begin
	declare v decimal(20,6);
  	if p_nombre = 'PEA' then
    	set v = fn_indicador_pea(p_periodo, p_sexo, p_rango, p_terr, p_rama);
  	elseif p_nombre = 'TGP' then
    	set v = fn_indicador_pea(p_periodo, p_sexo, p_rango, p_terr, p_rama) / nullif(fn_indicador_pet(p_periodo, p_sexo, p_rango, p_terr, p_rama), 0) * 100;
  elseif p_nombre = 'Tasa de ocupación' then
    set v = fn_indicador_ocupados(p_periodo, p_sexo, p_rango, p_terr, p_rama) / nullif(fn_indicador_pet(p_periodo, p_sexo, p_rango, p_terr, p_rama), 0) * 100;
  elseif p_nombre = 'Tasa de desocupación' then
    set v = fn_indicador_desocupados(p_periodo, p_sexo, p_rango, p_terr, p_rama) / nullif(fn_indicador_pea(p_periodo, p_sexo, p_rango, p_terr, p_rama), 0) * 100;
  elseif p_nombre = 'Salario promedio' then
    set v = fn_salario_promedio(p_periodo, p_sexo, p_rango, p_terr, p_rama);
  elseif p_nombre = 'Horas trabajadas' then
    set v = fn_horas_promedio(p_periodo, p_sexo, p_rango, p_terr, p_rama);
  elseif p_nombre = 'Tasa de informalidad' then
    set v = fn_indicador_informales(p_periodo, p_sexo, p_rango, p_terr, p_rama) / nullif(fn_indicador_ocupados(p_periodo, p_sexo, p_rango, p_terr, p_rama), 0) * 100;
  end if;
  return round(v, 4);
end;

-- Número de personas de la muestra (sin expandir) que sustentan el indicador
drop function if exists fn_n_muestra;
create function fn_n_muestra(p_nombre varchar(100), p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns int
reads sql data
begin
  declare n int;
  select count(*) into n
  from v_infoPersonas
  where idPeriodo = p_periodo
    and (p_sexo is null or idSexo = p_sexo)
    and (p_rango is null or idRangoEdad = p_rango)
    and (p_terr is null or p_terr = 3 or (p_terr in (1, 2) and clase = p_terr) or (p_terr > 3 and area = p_terr))
    and (p_rama is null or idRama = p_rama)
    and ((p_nombre in ('PEA', 'TGP', 'Tasa de ocupación') and pet = 1)
      OR (p_nombre = 'Tasa de desocupación' and condicion in ('Ocupado', 'Desocupado'))
      OR (p_nombre in ('Salario promedio', 'Horas trabajadas', 'Tasa de informalidad') and condicion = 'Ocupado'));
  return n;
end;

-- Coeficiente de variación (%) del indicador.
-- Es una aproximación con muestreo aleatorio simple:
--   tasas:     raíz((1 - p) / (p * n)) * 100
--   promedios: (desviación ponderada / raíz(n)) / media ponderada * 100
drop function if exists fn_cv_indicador;
create function fn_cv_indicador(p_nombre varchar(100), p_periodo int, p_sexo int, p_rango int, p_terr int, p_rama int)
returns decimal(8,4)
reads sql data
begin
  declare n int;
  declare p decimal(20,10);
  declare cv DECIMAL(20,6) default null;
  set n = fn_n_muestra(p_nombre, p_periodo, p_sexo, p_rango, p_terr, p_rama);
  if n is null or n = 0 then
    return null;
  end if;
  if p_nombre = 'PEA' then
    set p = fn_indicador_pea(p_periodo, p_sexo, p_rango, p_terr, p_rama) / nullif(fn_indicador_pet(p_periodo, p_sexo, p_rango, p_terr, p_rama), 0);
  else
    set p = fn_valor_indicador(p_nombre, p_periodo, p_sexo, p_rango, p_terr, p_rama) / 100;
  end if;
  if p_nombre in ('PEA', 'TGP', 'Tasa de ocupación', 'Tasa de desocupación', 'Tasa de informalidad') then
    if p > 0 and p < 1 then
      set cv = sqrt((1 - p) / (p * n)) * 100;
    end if;
  elseif p_nombre = 'Salario promedio' then
    select sqrt(GREATEST(sum(factorExpansion * ingreso * ingreso) / sum(factorExpansion)
                         - pow(sum(factorExpansion * ingreso) / sum(factorExpansion), 2), 0) / n)
           / (sum(factorExpansion * ingreso) / sum(factorExpansion)) * 100 into cv
    from v_infoPersonas
    where condicion = 'Ocupado' and ingreso > 0 and idPeriodo = p_periodo
      and (p_sexo is null or idSexo = p_sexo)
      and (p_rango is null or idRangoEdad = p_rango)
      and (p_terr is null or p_terr = 3 or (p_terr in (1, 2) and clase = p_terr) or (p_terr > 3 and area = p_terr))
      and (p_rama is null or idRama = p_rama);
  elseif p_nombre = 'Horas trabajadas' then
    select sqrt(GREATEST(sum(factorExpansion * horasTrabajo * horasTrabajo) / sum(factorExpansion)
                         - pow(sum(factorExpansion * horasTrabajo) / sum(factorExpansion), 2), 0) / n)
           / (sum(factorExpansion * horasTrabajo) / sum(factorExpansion)) * 100 into cv
    from v_infoPersonas
    where condicion = 'Ocupado' and horasTrabajo is not null and idPeriodo = p_periodo
      and (p_sexo is null or idSexo = p_sexo)
      and (p_rango is null or idRangoEdad = p_rango)
      and (p_terr is null or p_terr = 3 or (p_terr IN (1, 2) and clase = p_terr) or (p_terr > 3 and area = p_terr))
      and (p_rama is null or idRama = p_rama);
  end if;
  return round(cv, 4);
end;

-- Confiabilidad según el CV. Umbral del 15 %.
drop function if exists fn_confiabilidad;
create function fn_confiabilidad(p_cv decimal(8,4))
returns VARCHAR(20)
deterministic
begin
  if p_cv is null then
    return 'Sin dato';
  elseif p_cv <= 15 THEN
    return 'Confiable';
  end if;
  return 'Baja confiabilidad';
end;

-- Creación del procedimiento almacenado para calcular los indicadores por periodo
drop procedure if exists sp_calcular_periodo;
create procedure sp_calcular_periodo(in p_periodo int, in p_usuario int)
begin
	insert into indicador (idTipoIndicador, idUsuario, valorIndicador, cvIndicador, fechaCalculoIndicador)
	select t.idTipoIndicador, p_usuario,
		fn_valor_indicador(t.nombreIndicador, t.idPeriodo, t.idSexo, t.idRangoEdad, t.idTerritorio, t.idRamaActividad),
		fn_cv_indicador(t.nombreIndicador, t.idPeriodo, t.idSexo, t.idRangoEdad, t.idTerritorio, t.idRamaActividad),
		curdate()
	from tipoIndicador t
	where t.idPeriodo = p_periodo
		and fn_valor_indicador(t.nombreIndicador, t.idPeriodo, t.idSexo, t.idRangoEdad, t.idTerritorio, t.idRamaActividad) is not null;
	select row_count() as indicadoresCalculados;
end;

call sp_calcular_periodo(202601, 12);
select * from indicador;


-- 4. Consultas básicas por tabla
select * from persona;
select * from ocupado;
select * from desocupado;
select * from periodo;
select * from indicador; 
select * from tipoIndicado;
select * from usuario;
select * from ramaActividad;
select * from rangoEdad;
select * from sexo;
select * from territorio;

-- 5. Consultas específicas por tabla
-- Las bases son mensuales: el factor de expansión de cada mes representa a toda la población de ese mes.
-- Por eso, para no contar dos veces, las consultas ponderadas fijan un periodo (202601, enero de 2026)
-- o agrupan por periodo. Para otro mes basta cambiar el valor 202601.

-- persona
/* personas mayores de 20 años en enero de 2026 */
select count(*) as personasMuestra, round(sum(factorExpansion)) as personasExpandidas
from persona
where idPeriodo = 202601 and edad > 20;
/* personas entre 18 y 30 años en enero de 2026 */
select count(*) as personasMuestra, round(sum(factorExpansion)) as personasExpandidas
from persona
where idPeriodo = 202601 and edad between 18 and 30;
/* mujeres en enero de 2026 */
select count(*) as mujeresMuestra, round(sum(factorExpansion)) as mujeresExpandidas
from persona
where idPeriodo = 202601 and idSexo = 2;
/* población de 2026 por periodo */
select idPeriodo, count(*) as personasMuestra, round(sum(factorExpansion)) as personasExpandidas
from persona
where idPeriodo between 202601 and 202612
group by idPeriodo
order by idPeriodo;
/* población en edad de trabajar por periodo */
select idPeriodo, count(*) as petMuestra, round(sum(factorExpansion)) as petExpandida
from persona
where pet = 1
group by idPeriodo;
/* personas por sexo en enero de 2026 */
select idSexo, count(*) as cantidadPersonas, round(sum(factorExpansion)) as personasExpandidas
from persona
where idPeriodo = 202601
group by idSexo;
/* edad promedio ponderada en enero de 2026 */
select round(sum(edad * factorExpansion) / sum(factorExpansion), 1) as edadPromedio
from persona
where idPeriodo = 202601;

-- ocupado
/* ocupados con jornada superior a 48 horas semanales */
select idPersona, idRama, horasTrabajo
from ocupado
where horasTrabajo > 48
order by horasTrabajo desc;
/* ocupados que no cotizan a pensión */
select count(*) as sinPension
from ocupado
where cotizaPension = 0;
/* ingreso mínimo, máximo y promedio de los ocupados con ingreso */
select min(ingreso) as minimo, max(ingreso) as maximo, round(avg(ingreso)) as promedio
from ocupado
where ingreso > 0;
/* horas semanales promedio de trabajo */
select round(avg(horasTrabajo), 1) as horasPromedio
from ocupado
where horasTrabajo is not null;
/* ocupados sin ingreso reportado o con ingreso cero */
select idPersona, idRama, ingreso
from ocupado
where ingreso is null or ingreso = 0;
/* las 5 ramas con más ocupados en la muestra */
select idRama, count(*) as ocupados
from ocupado
where idRama is not null
group by idRama
order by ocupados desc
limit 5;
/* ingreso promedio por rama (ramas con al menos 5 ocupados con ingreso) */
select idRama, count(*) as ocupados, round(avg(ingreso)) as ingresoPromedio
from ocupado
where ingreso > 0
group by idRama
having count(*) >= 5
order by ingresoPromedio desc;

-- desocupado
/* total de desocupados en la muestra */
select count(*) as desocupados
from desocupado;
/* primer y último identificador de desocupado */
select min(idPersona) as primero, max(idPersona) as ultimo
from desocupado;
/* los 10 primeros desocupados por identificador */
select * from desocupado
order by idPersona
limit 10;
/* los 5 últimos desocupados por identificador */
select * from desocupado
order by idPersona desc
limit 5;
/* desocupados cuyo identificador empieza por 5 */
select count(*) as desocupados
from desocupado
where idPersona like '5%';
/* longitud de los identificadores de desocupado */
select char_length(idPersona) as longitud, count(*) as desocupados
from desocupado
group by char_length(idPersona);
/* directorios con más de un desocupado (primeros 8 dígitos del identificador) */
select substr(idPersona, 1, 8) as directorio, count(*) as desocupados
from desocupado
group by substr(idPersona, 1, 8)
having count(*) > 1
order by desocupados desc;

-- usuario
/* usuarios por rol */
select rolUsuario, count(*) as usuarios
from usuario
group by rolUsuario;
/* usuarios con correo del dominio observatorio.example.org */
select nombreUsuario, correoUsuario
from usuario
where correoUsuario like '%@observatorio.example.org'
order by nombreUsuario;
/* usuarios activos e inactivos por rol */
select rolUsuario, sum(activo = 1) as activos, sum(activo = 0) as inactivos
from usuario
group by rolUsuario
order by rolUsuario;
/* usuarios ordenados por nombre */
select nombreUsuario, rolUsuario
from usuario
order by nombreUsuario;
/* usuarios inactivos */
select idUsuario, nombreUsuario, rolUsuario
from usuario
where activo = 0;
/* usuarios por dominio de correo */
select substring_index(correoUsuario, '@', -1) as dominio, count(*) as usuarios
from usuario
group by dominio;
/* usuarios con rol de investigador o ingeniero de datos */
select nombreUsuario, rolUsuario
from usuario
where rolUsuario in ('investigador', 'ingeniero de datos')
order by rolUsuario, nombreUsuario;

-- periodo
/* periodos del año 2026 */
select * from periodo
where anio = 2026
order by mes;
/* número de periodos por año */
select anio, count(*) as periodos
from periodo
group by anio;
/* periodos del primer trimestre de cada año */
select * from periodo
where mes between 1 and 3
order by anio, mes;
/* segundo semestre de 2026 */
select * from periodo
where anio = 2026 and mes between 7 and 12;
/* último periodo del catálogo */
select * from periodo
order by idPeriodo desc
limit 1;
/* primer periodo del catálogo */
select * from periodo
order by idPeriodo
limit 1;
/* periodos de junio de todos los años */
select * from periodo
where mes = 6
order by anio;

-- sexo
/* categoría con identificador 1 */
select * from sexo
where idSexo = 1;
/* búsqueda de categorías por nombre */
select * from sexo
where nombreSexo like 'M%';
/* cantidad de categorías */
select count(*) as categorias
from sexo;
/* categorías ordenadas por nombre de forma descendente */
select * from sexo
order by nombreSexo desc;
/* longitud del nombre de cada categoría */
select nombreSexo, char_length(nombreSexo) as longitud
from sexo;
/* nombres en mayúsculas */
select idSexo, upper(nombreSexo) as nombreMayuscula
from sexo;
/* identificador más alto del catálogo */
select max(idSexo) as ultimoId
from sexo;

-- rangoEdad
/* rangos ordenados por edad inicial */
select nombreRangoEdad, edadInicial, edadFinal
from rangoEdad
order by edadInicial;
/* rango abierto (sin edad final) */
select * from rangoEdad
where edadFinal is null;
/* amplitud en años de cada rango cerrado */
select nombreRangoEdad, edadFinal - edadInicial + 1 as anios
from rangoEdad
where edadFinal is not null;
/* rango al que pertenece una persona de 30 años */
select nombreRangoEdad
from rangoEdad
where edadInicial <= 30 and (edadFinal is null or edadFinal >= 30);
/* rangos cerrados con amplitud mayor a 15 años */
select nombreRangoEdad, edadFinal - edadInicial + 1 as anios
from rangoEdad
where edadFinal - edadInicial + 1 > 15;
/* edad inicial más baja del catálogo */
select min(edadInicial) as edadMinima
from rangoEdad;
/* rangos que empiezan después de los 25 años */
select * from rangoEdad
where edadInicial > 25
order by edadInicial;

-- territorio
/* territorios por tipo */
select tipoTerritorio, count(*) as territorios
from territorio
group by tipoTerritorio;
/* ciudades en orden alfabético */
select nombreTerritorio
from territorio
where tipoTerritorio = 'ciudad'
order by nombreTerritorio;
/* áreas metropolitanas (nombre con "A.M.") */
select * from territorio
where nombreTerritorio like '%A.M.%';
/* zonas (urbano y rural) */
select * from territorio
where tipoTerritorio = 'zona';
/* territorio nacional */
select * from territorio
where tipoTerritorio = 'nacional';
/* ciudades con código DIVIPOLA mayor a 50 */
select idTerritorio, nombreTerritorio
from territorio
where tipoTerritorio = 'ciudad' and idTerritorio > 50
order by idTerritorio;
/* ciudades que no son área metropolitana */
select nombreTerritorio
from territorio
where tipoTerritorio = 'ciudad' and nombreTerritorio not like '%A.M.%'
order by nombreTerritorio;

-- ramaActividad
/* las cinco primeras ramas del catálogo */
select * from ramaActividad
where idRamaActividad between 1 and 5;
/* ramas cuyo nombre incluye "comercio" */
select * from ramaActividad
where nombreRama like '%omercio%';
/* ramas ordenadas alfabéticamente */
select * from ramaActividad
order by nombreRama;
/* rama con el nombre más largo */
select nombreRama, char_length(nombreRama) as longitud
from ramaActividad
order by longitud desc
limit 1;
/* cantidad de ramas del catálogo */
select count(*) as ramas
from ramaActividad;
/* ramas cuyo nombre incluye la palabra "servicios" */
select * from ramaActividad
where nombreRama like '%ervicios%';
/* ramas con identificador entre 6 y 10 */
select * from ramaActividad
where idRamaActividad between 6 and 10;

-- tipoIndicador
/* cantidad de definiciones por indicador */
select nombreIndicador, count(*) as definiciones
from tipoIndicador
group by nombreIndicador
order by definiciones desc;
/* definiciones nacionales sin ninguna otra desagregación */
select idTipoIndicador, nombreIndicador, idPeriodo
from tipoIndicador
where idTerritorio = 3 and idSexo is null and idRangoEdad is null and idRamaActividad is null
order by idPeriodo, nombreIndicador;
/* definiciones por periodo y periodicidad */
select idPeriodo, periodicidad, count(*) as definiciones
from tipoIndicador
group by idPeriodo, periodicidad
order by idPeriodo;
/* definiciones nacionales de la tasa de desocupación con su fórmula */
select idTipoIndicador, idPeriodo, formula
from tipoIndicador
where nombreIndicador = 'Tasa de desocupación' and idTerritorio = 3 and idSexo is null and idRangoEdad is null and idRamaActividad is null;
/* definiciones de enero de 2026 desagregadas por sexo */
select idTipoIndicador, nombreIndicador, idSexo
from tipoIndicador
where idPeriodo = 202601 and idSexo is not null
order by nombreIndicador, idSexo;
/* definiciones de enero de 2026 desagregadas por rama de actividad */
select nombreIndicador, idRamaActividad
from tipoIndicador
where idPeriodo = 202601 and idRamaActividad is not null
order by nombreIndicador, idRamaActividad;
/* definiciones de enero de 2026 desagregadas por rango de edad */
select nombreIndicador, idRangoEdad
from tipoIndicador
where idPeriodo = 202601 and idRangoEdad is not null
order by nombreIndicador, idRangoEdad;

-- indicador
/* indicadores con baja confiabilidad (CV superior a 15 %) */
select count(*) as bajaConfiabilidad
from indicador
where cvIndicador > 15;
/* indicadores con confiabilidad aceptable (CV entre 5 % y 15 %) */
select idIndicador, idTipoIndicador, valorIndicador, cvIndicador
from indicador
where cvIndicador between 5 and 15
order by cvIndicador
limit 10;
/* valor mínimo, máximo y promedio de los indicadores */
select min(valorIndicador) as minimo, max(valorIndicador) as maximo, round(avg(valorIndicador), 2) as promedio
from indicador;
/* indicadores calculados por día */
select fechaCalculoIndicador, count(*) as indicadores
from indicador
group by fechaCalculoIndicador
order by fechaCalculoIndicador;
/* indicadores calculados por cada usuario */
select idUsuario, count(*) as indicadores
from indicador
group by idUsuario
order by indicadores desc;
/* los 10 indicadores con mayor valor */
select idIndicador, idTipoIndicador, valorIndicador, cvIndicador
from indicador
order by valorIndicador desc
limit 10;
/* indicadores clasificados por confiabilidad según su CV */
select case when cvIndicador is null then 'sin CV'
            when cvIndicador <= 5 then 'alta (CV hasta 5 %)'
            when cvIndicador <= 15 then 'aceptable (CV hasta 15 %)'
            else 'baja (CV mayor a 15 %)' end as confiabilidad,
       count(*) as indicadores
from indicador
group by confiabilidad;


-- 6. Modificaciones y eliminaciones
-- Se ejecuta dentro de una transacción que termina en rollback: la base queda intacta y la prueba se puede repetir.
-- Para conservar los cambios, reemplazar el rollback final por commit.
-- persona, ocupado y desocupado no se modifican ni se eliminan: son el microdato del DANE y solo se les agregan periodos nuevos.

start transaction;

/* inactivar un usuario sin eliminar su registro */
update usuario
set activo = 0
where idUsuario = 49;
/* corregir el nombre de un territorio */
update territorio
set nombreTerritorio = 'Bogotá, D.C.'
where idTerritorio = 11;
/* cambiar la fórmula de una definición de indicador */
update tipoIndicador
set formula = concat(formula, ' (revisada)')
where idTipoIndicador = 1;
/* recalcular el valor de un indicador */
update indicador
set valorIndicador = valorIndicador + 0.5
where idIndicador = 1;
/* ajustar el coeficiente de variación de un indicador */
update indicador
set cvIndicador = 9.5
where idIndicador = 2;

/* eliminar el último indicador calculado */
delete from indicador
order by idIndicador desc
limit 1;

rollback;


-- 7. Consultas multitabla y subconsultas

/* persona + ocupado + sexo: ocupados expandidos por sexo en enero de 2026 */
select s.nombreSexo, count(*) as ocupadosMuestra, round(sum(p.factorExpansion)) as ocupadosExpandidos
from ocupado o
join persona p on p.idPersona = o.idPersona
join sexo s on s.idSexo = p.idSexo
where p.idPeriodo = 202601
group by s.idSexo, s.nombreSexo;
/* persona + desocupado + rangoEdad: desocupados expandidos por rango de edad en enero de 2026 */
select r.nombreRangoEdad, round(sum(p.factorExpansion)) as desocupadosExpandidos
from desocupado d
join persona p on p.idPersona = d.idPersona
join rangoEdad r on p.edad >= r.edadInicial and (r.edadFinal is null or p.edad <= r.edadFinal)
where p.idPeriodo = 202601
group by r.idRangoEdad, r.nombreRangoEdad
order by r.idRangoEdad;
/* ocupado + persona + ramaActividad: las 5 ramas con más ocupados expandidos en enero de 2026 */
select ra.nombreRama, round(sum(p.factorExpansion)) as ocupadosExpandidos
from ocupado o
join persona p on p.idPersona = o.idPersona
join ramaActividad ra on ra.idRamaActividad = o.idRama
where p.idPeriodo = 202601
group by ra.idRamaActividad, ra.nombreRama
order by ocupadosExpandidos desc
limit 5;
/* persona + territorio + periodo: población expandida por ciudad y mes */
select pe.anio, pe.mes, t.nombreTerritorio, round(sum(p.factorExpansion)) as poblacion
from persona p
join territorio t on t.idTerritorio = p.area
join periodo pe on pe.idPeriodo = p.idPeriodo
where t.tipoTerritorio = 'ciudad'
group by pe.anio, pe.mes, t.idTerritorio, t.nombreTerritorio
order by pe.anio, pe.mes, poblacion desc;
/* persona + ocupado + desocupado + sexo: tasa de desocupación ponderada por sexo y periodo */
select p.idPeriodo, s.nombreSexo,
       round(sum(case when d.idPersona is not null then p.factorExpansion end) * 100 / sum(p.factorExpansion), 2) as tasaDesocupacion
from persona p
join sexo s on s.idSexo = p.idSexo
left join ocupado o on o.idPersona = p.idPersona
left join desocupado d on d.idPersona = p.idPersona
where o.idPersona is not null or d.idPersona is not null
group by p.idPeriodo, s.idSexo, s.nombreSexo
order by p.idPeriodo, s.idSexo;
/* ocupado + persona + ramaActividad + sexo: salario promedio ponderado por rama y sexo en enero de 2026 */
select ra.nombreRama, s.nombreSexo, round(sum(p.factorExpansion * o.ingreso) / sum(p.factorExpansion)) as salarioPromedio
from ocupado o
join persona p on p.idPersona = o.idPersona
join ramaActividad ra on ra.idRamaActividad = o.idRama
join sexo s on s.idSexo = p.idSexo
where p.idPeriodo = 202601 and o.ingreso > 0
group by ra.idRamaActividad, ra.nombreRama, s.idSexo, s.nombreSexo
having count(*) >= 3
order by ra.nombreRama, s.idSexo;
/* ocupado + persona + rangoEdad: informalidad ponderada por rango de edad en enero de 2026 */
select r.nombreRangoEdad,
       round(sum(case when o.cotizaPension = 0 then p.factorExpansion end) * 100 / sum(p.factorExpansion), 1) as informalidad
from ocupado o
join persona p on p.idPersona = o.idPersona
join rangoEdad r on p.edad >= r.edadInicial and (r.edadFinal is null or p.edad <= r.edadFinal)
where p.idPeriodo = 202601
group by r.idRangoEdad, r.nombreRangoEdad
order by r.idRangoEdad;
/* tipoIndicador + periodo + sexo: definiciones desagregadas por sexo, con el mes */
select pe.anio, pe.mes, t.nombreIndicador, s.nombreSexo
from tipoIndicador t
join periodo pe on pe.idPeriodo = t.idPeriodo
join sexo s on s.idSexo = t.idSexo
where t.idPeriodo = 202601
order by t.nombreIndicador, s.idSexo;
/* tipoIndicador + territorio + rangoEdad: definiciones por territorio y rango de edad */
select te.nombreTerritorio, r.nombreRangoEdad, count(*) as definiciones
from tipoIndicador t
join territorio te on te.idTerritorio = t.idTerritorio
join rangoEdad r on r.idRangoEdad = t.idRangoEdad
group by te.idTerritorio, te.nombreTerritorio, r.idRangoEdad, r.nombreRangoEdad
order by te.nombreTerritorio, r.idRangoEdad;
/* tipoIndicador + ramaActividad + periodo: definiciones desagregadas por rama de actividad */
select pe.anio, pe.mes, t.nombreIndicador, ra.nombreRama
from tipoIndicador t
join periodo pe on pe.idPeriodo = t.idPeriodo
join ramaActividad ra on ra.idRamaActividad = t.idRamaActividad
where t.idPeriodo = 202601
order by t.nombreIndicador, ra.idRamaActividad;
/* persona + periodo: población expandida y en edad de trabajar por mes */
select pe.anio, pe.mes, round(sum(p.factorExpansion)) as poblacion,
       round(sum(case when p.pet = 1 then p.factorExpansion end)) as petExpandida
from persona p
join periodo pe on pe.idPeriodo = p.idPeriodo
group by pe.anio, pe.mes
order by pe.anio, pe.mes;
/* indicador + tipoIndicador + periodo: tasa de desocupación nacional por mes */
select pe.anio, pe.mes, i.valorIndicador, i.cvIndicador
from indicador i
join tipoIndicador t on t.idTipoIndicador = i.idTipoIndicador
join periodo pe on pe.idPeriodo = t.idPeriodo
where t.nombreIndicador = 'Tasa de desocupación' and t.idTerritorio = 3 and t.idSexo is null and t.idRangoEdad is null and t.idRamaActividad is null
order by pe.anio, pe.mes;
/* indicador + tipoIndicador + sexo: tasa de desocupación de hombres y mujeres por periodo */
select t.idPeriodo, s.nombreSexo, i.valorIndicador, i.cvIndicador
from indicador i
join tipoIndicador t on t.idTipoIndicador = i.idTipoIndicador
join sexo s on s.idSexo = t.idSexo
where t.nombreIndicador = 'Tasa de desocupación' and t.idTerritorio = 3 and t.idRangoEdad is null and t.idRamaActividad is null
order by t.idPeriodo, s.idSexo;
/* indicador + tipoIndicador + territorio: salario promedio por territorio en enero de 2026 */
select te.nombreTerritorio, i.valorIndicador as salarioPromedio
from indicador i
join tipoIndicador t on t.idTipoIndicador = i.idTipoIndicador
join territorio te on te.idTerritorio = t.idTerritorio
where t.nombreIndicador = 'Salario promedio' and t.idPeriodo = 202601 and t.idSexo is null and t.idRangoEdad is null and t.idRamaActividad is null
order by i.valorIndicador desc;
/* indicador + tipoIndicador + ramaActividad: tasa de informalidad por rama en enero de 2026 */
select ra.nombreRama, i.valorIndicador as informalidad, i.cvIndicador
from indicador i
join tipoIndicador t on t.idTipoIndicador = i.idTipoIndicador
join ramaActividad ra on ra.idRamaActividad = t.idRamaActividad
where t.nombreIndicador = 'Tasa de informalidad' and t.idPeriodo = 202601
order by i.valorIndicador desc;
/* indicador + usuario + tipoIndicador: indicadores calculados por usuario y periodo */
select u.nombreUsuario, t.idPeriodo, count(*) as indicadores
from indicador i
join usuario u on u.idUsuario = i.idUsuario
join tipoIndicador t on t.idTipoIndicador = i.idTipoIndicador
group by u.idUsuario, u.nombreUsuario, t.idPeriodo
order by t.idPeriodo, indicadores desc;

/* persona: personas de enero de 2026 con factor de expansión mayor al promedio */
select idPersona, edad, factorExpansion
from persona
where idPeriodo = 202601
  and factorExpansion > (select avg(factorExpansion) from persona where idPeriodo = 202601)
order by factorExpansion desc
limit 10;
/* ocupado: ocupados con ingreso mayor al ingreso promedio */
select idPersona, idRama, ingreso
from ocupado
where ingreso > (select avg(ingreso) from ocupado where ingreso > 0)
order by ingreso desc
limit 10;
/* desocupado: desocupados de enero de 2026 mayores que la edad promedio de los ocupados */
select p.idPersona, p.edad
from persona p
where p.idPeriodo = 202601
  and p.idPersona in (select idPersona from desocupado)
  and p.edad > (select avg(p2.edad) from persona p2 where p2.idPersona in (select idPersona from ocupado))
order by p.edad desc;
/* usuario: usuarios con el mismo rol que el usuario 1 */
select idUsuario, nombreUsuario, rolUsuario
from usuario
where rolUsuario = (select rolUsuario from usuario where idUsuario = 1)
order by nombreUsuario;
/* periodo: periodos con microdato cargado */
select idPeriodo, anio, mes
from periodo
where idPeriodo in (select distinct idPeriodo from persona);
/* sexo: categorías que tienen personas ocupadas */
select idSexo, nombreSexo
from sexo
where idSexo in (select p.idSexo from persona p where p.idPersona in (select idPersona from ocupado));
/* rangoEdad: rango al que pertenece la persona de mayor edad de la muestra */
select nombreRangoEdad
from rangoEdad
where edadInicial <= (select max(edad) from persona)
  and (edadFinal is null or edadFinal >= (select max(edad) from persona));
/* territorio: ciudades con personas en la muestra de enero de 2026 */
select idTerritorio, nombreTerritorio
from territorio
where tipoTerritorio = 'ciudad'
  and idTerritorio in (select distinct area from persona where idPeriodo = 202601)
order by nombreTerritorio;
/* ramaActividad: ramas con más ocupados que el promedio por rama */
select idRamaActividad, nombreRama
from ramaActividad
where idRamaActividad in (select idRama from ocupado group by idRama
                          having count(*) > (select count(*) / count(distinct idRama) from ocupado));
/* tipoIndicador: definiciones del último periodo que tiene microdato */
select idTipoIndicador, nombreIndicador, idPeriodo
from tipoIndicador
where idPeriodo = (select max(idPeriodo) from persona)
  and idTerritorio = 3 and idSexo is null and idRangoEdad is null and idRamaActividad is null;
/* persona: tasa de desocupación de enero de 2026 con una tabla derivada */
select round(x.desocupados * 100 / x.pea, 2) as tasaDesocupacion
from (select sum(case when d.idPersona is not null then p.factorExpansion end) as desocupados,
             sum(p.factorExpansion) as pea
      from persona p
      left join ocupado o on o.idPersona = p.idPersona
      left join desocupado d on d.idPersona = p.idPersona
      where p.idPeriodo = 202601 and (o.idPersona is not null or d.idPersona is not null)) x;
/* indicador: indicadores con coeficiente de variación mayor al promedio */
select idIndicador, idTipoIndicador, valorIndicador, cvIndicador
from indicador
where cvIndicador > (select avg(cvIndicador) from indicador)
order by cvIndicador desc
limit 10;
/* indicador: indicadores del último día de cálculo */
select idIndicador, idTipoIndicador, valorIndicador
from indicador
where fechaCalculoIndicador = (select max(fechaCalculoIndicador) from indicador)
limit 10;
/* usuario: usuarios que no han calculado ningún indicador */
select count(*) as sinIndicadores
from usuario
where idUsuario not in (select idUsuario from indicador);


-- 8. Procedimientos almacenados y vistas
-- (El procedimiento sp_calcular_periodo y la vista v_infoPersonas ya se crearon en la sección 5.)

-- 8.1 Procedimiento: calcular y guardar un solo indicador a partir de su definición en tipoIndicador
drop procedure if exists sp_calcular_indicador;
create procedure sp_calcular_indicador(in p_tipo int, in p_usuario int)
begin
	declare v_nombre varchar(100);
	declare v_periodo, v_sexo, v_rango, v_terr, v_rama int;
	declare v_valor decimal(15,4);
	select nombreIndicador, idPeriodo, idSexo, idRangoEdad, idTerritorio, idRamaActividad
		into v_nombre, v_periodo, v_sexo, v_rango, v_terr, v_rama
	from tipoIndicador
	where idTipoIndicador = p_tipo;
	if v_nombre is null then
		signal sqlstate '45000' set message_text = 'No existe la definición del indicador';
	end if;
	set v_valor = fn_valor_indicador(v_nombre, v_periodo, v_sexo, v_rango, v_terr, v_rama);
	if v_valor is null then
		signal sqlstate '45000' set message_text = 'No hay datos para calcular el indicador';
	end if;
	insert into indicador (idTipoIndicador, idUsuario, valorIndicador, cvIndicador, fechaCalculoIndicador)
	values (p_tipo, p_usuario, v_valor,
		fn_cv_indicador(v_nombre, v_periodo, v_sexo, v_rango, v_terr, v_rama), curdate());
end;

-- 8.2 Procedimiento: crear las definiciones de un periodo nuevo copiando las de otro periodo
drop procedure if exists sp_copiar_definiciones;
create procedure sp_copiar_definiciones(in p_origen int, in p_destino int)
begin
	if exists (select 1 from tipoIndicador where idPeriodo = p_destino) then
		signal sqlstate '45000' set message_text = 'El periodo destino ya tiene definiciones';
	end if;
	insert into tipoIndicador (idPeriodo, idSexo, idRangoEdad, idTerritorio, idRamaActividad, nombreIndicador, formula, periodicidad)
	select p_destino, idSexo, idRangoEdad, idTerritorio, idRamaActividad, nombreIndicador, formula, periodicidad
	from tipoIndicador
	where idPeriodo = p_origen;
	select row_count() as definicionesCopiadas;
end;

-- 8.3 Procedimiento: verificar el microdato cargado de un periodo antes de calcular los indicadores
drop procedure if exists sp_verificar_microdato;
create procedure sp_verificar_microdato(in p_periodo int)
begin
	select 'personas del periodo' as verificacion, count(*) as registros
	from persona where idPeriodo = p_periodo
	union all
	select 'periodo fuera del catálogo', count(*)
	from persona where idPeriodo = p_periodo and idPeriodo not in (select idPeriodo from periodo)
	union all
	select 'sexo fuera del catálogo', count(*)
	from persona where idPeriodo = p_periodo and idSexo not in (select idSexo from sexo)
	union all
	select 'rama fuera del catálogo', count(*)
	from v_infoPersonas
	where idPeriodo = p_periodo and condicion = 'Ocupado' and idRama not in (select idRamaActividad from ramaActividad)
	union all
	select 'personas ocupadas y desocupadas a la vez', count(*)
	from persona p
	where p.idPeriodo = p_periodo
		and p.idPersona in (select idPersona from ocupado)
		and p.idPersona in (select idPersona from desocupado)
	union all
	select 'área fuera del catálogo de territorios (informativo)', count(*)
	from persona where idPeriodo = p_periodo and area not in (select idTerritorio from territorio);
end;

-- 8.4 Procedimiento: inactivar un usuario sin eliminar su registro (conserva el historial de indicadores)
drop procedure if exists sp_inactivar_usuario;
create procedure sp_inactivar_usuario(in p_usuario int)
begin
	update usuario set activo = 0 where idUsuario = p_usuario and activo = 1;
	if row_count() = 0 then
		signal sqlstate '45000' set message_text = 'El usuario no existe o ya está inactivo';
	end if;
end;

-- 8.5 Vista: indicadores con sus dimensiones escritas (insumo del tablero)
create or replace view v_indicador_detalle as
select i.idIndicador, pe.anio, pe.mes, t.nombreIndicador,
	coalesce(s.nombreSexo, 'Todos')           as sexo,
	coalesce(r.nombreRangoEdad, 'Todos')      as rangoEdad,
	coalesce(te.nombreTerritorio, 'Nacional') as territorio,
	coalesce(ra.nombreRama, 'Todas')          as ramaActividad,
	i.valorIndicador, i.cvIndicador, fn_confiabilidad(i.cvIndicador) as confiabilidad,
	i.fechaCalculoIndicador, u.nombreUsuario
from indicador i
join tipoIndicador t on t.idTipoIndicador = i.idTipoIndicador
join periodo pe      on pe.idPeriodo = t.idPeriodo
join usuario u       on u.idUsuario = i.idUsuario
left join sexo s           on s.idSexo = t.idSexo
left join rangoEdad r      on r.idRangoEdad = t.idRangoEdad
left join territorio te    on te.idTerritorio = t.idTerritorio
left join ramaActividad ra on ra.idRamaActividad = t.idRamaActividad;

-- 8.6 Vista: solo el cálculo más reciente de cada tipo de indicador
create or replace view v_indicador_vigente as
select d.*
from v_indicador_detalle d
where d.idIndicador in (select max(idIndicador) from indicador group by idTipoIndicador);

-- 8.7 Vista: resumen laboral por periodo con cifras expandidas
create or replace view v_resumen_laboral_periodo as
select idPeriodo,
	count(*)                                                          as personasMuestra,
	sum(factorExpansion)                                              as poblacion,
	sum(case when pet = 1 then factorExpansion end)                   as pet,
	sum(case when condicion = 'Ocupado' then factorExpansion end)     as ocupados,
	sum(case when condicion = 'Desocupado' then factorExpansion end)  as desocupados
from v_infoPersonas
group by idPeriodo;

-- 8.8 Vista: ocupados por rama de actividad y periodo
create or replace view v_ocupados_por_rama as
select b.idPeriodo, r.idRamaActividad, r.nombreRama,
	count(*)                as ocupadosMuestra,
	sum(b.factorExpansion)  as ocupadosExpandidos
from v_infoPersonas b
join ramaActividad r on r.idRamaActividad = b.idRama
group by b.idPeriodo, r.idRamaActividad, r.nombreRama;

-- 8.9 Uso de los procedimientos y las vistas
call sp_verificar_microdato(202601);
call sp_verificar_microdato(202602);
call sp_copiar_definiciones(202601, 202602);
call sp_calcular_periodo(202602, 12);
call sp_calcular_indicador(1, 12);
select * from v_resumen_laboral_periodo;
select * from v_ocupados_por_rama where idPeriodo = 202601 order by ocupadosExpandidos desc;
select * from v_indicador_vigente where territorio = 'Nacional' and ramaActividad = 'Todas' and sexo = 'Todos' and rangoEdad = 'Todos' order by anio, mes, nombreIndicador;


-- 9. Triggers
-- Se crean al final: desde aquí la tabla auditoriaIndicador se llena sola con los cambios en indicador
-- y se protegen el microdato y la propia auditoría.
-- Cada trigger se ejecuta seleccionando su bloque completo (desde create hasta end;) con Ctrl+Enter.

-- 9.1 Auditoría de la tabla indicador (3 triggers: insert, update y delete)
drop trigger if exists trg_indicador_ai;
create trigger trg_indicador_ai after insert on indicador for each row
begin
	insert into auditoriaIndicador (idIndicador, accionAuditoria, valorAnteriorIndicador, valorNuevoIndicador, usuarioBD, fechaAuditoria)
	values (new.idIndicador, 'INSERT', null, new.valorIndicador, current_user(), curdate());
end;

drop trigger if exists trg_indicador_au;
create trigger trg_indicador_au after update on indicador for each row
begin
	insert into auditoriaIndicador (idIndicador, accionAuditoria, valorAnteriorIndicador, valorNuevoIndicador, usuarioBD, fechaAuditoria)
	values (old.idIndicador, 'UPDATE', old.valorIndicador, new.valorIndicador, current_user(), curdate());
end;

drop trigger if exists trg_indicador_ad;
create trigger trg_indicador_ad after delete on indicador for each row
begin
	insert into auditoriaIndicador (idIndicador, accionAuditoria, valorAnteriorIndicador, valorNuevoIndicador, usuarioBD, fechaAuditoria)
	values (old.idIndicador, 'DELETE', old.valorIndicador, null, current_user(), curdate());
end;

-- 9.2 La auditoría no se puede modificar ni borrar
drop trigger if exists trg_auditoria_bu;
create trigger trg_auditoria_bu before update on auditoriaIndicador for each row
begin
	signal sqlstate '45000' set message_text = 'La tabla de auditoría no se puede modificar';
end;

drop trigger if exists trg_auditoria_bd;
create trigger trg_auditoria_bd before delete on auditoriaIndicador for each row
begin
	signal sqlstate '45000' set message_text = 'La tabla de auditoría no se puede borrar';
end;

-- 9.3 Validación de la condición laboral al cargar ocupados y desocupados
drop trigger if exists trg_ocupado_bi;
create trigger trg_ocupado_bi before insert on ocupado for each row
begin
	if (select pet from persona where idPersona = new.idPersona) = 0 then
		signal sqlstate '45000' set message_text = 'La persona no pertenece a la población en edad de trabajar';
	end if;
	if exists (select 1 from desocupado where idPersona = new.idPersona) then
		signal sqlstate '45000' set message_text = 'La persona ya está registrada como desocupada';
	end if;
end;

drop trigger if exists trg_desocupado_bi;
create trigger trg_desocupado_bi before insert on desocupado for each row
begin
	if (select pet from persona where idPersona = new.idPersona) = 0 then
		signal sqlstate '45000' set message_text = 'La persona no pertenece a la población en edad de trabajar';
	end if;
	if exists (select 1 from ocupado where idPersona = new.idPersona) then
		signal sqlstate '45000' set message_text = 'La persona ya está registrada como ocupada';
	end if;
end;

-- 9.4 El microdato (como lo publica el DANE) no se modifica ni se borra: solo se agregan periodos nuevos
drop trigger if exists trg_persona_bu;
create trigger trg_persona_bu before update on persona for each row
begin
	signal sqlstate '45000' set message_text = 'El microdato no se puede modificar';
end;

drop trigger if exists trg_persona_bd;
create trigger trg_persona_bd before delete on persona for each row
begin
	signal sqlstate '45000' set message_text = 'El microdato no se puede borrar';
end;

drop trigger if exists trg_ocupado_bu;
create trigger trg_ocupado_bu before update on ocupado for each row
begin
	signal sqlstate '45000' set message_text = 'El microdato no se puede modificar';
end;

drop trigger if exists trg_ocupado_bd;
create trigger trg_ocupado_bd before delete on ocupado for each row
begin
	signal sqlstate '45000' set message_text = 'El microdato no se puede borrar';
end;

drop trigger if exists trg_desocupado_bu;
create trigger trg_desocupado_bu before update on desocupado for each row
begin
	signal sqlstate '45000' set message_text = 'El microdato no se puede modificar';
end;

drop trigger if exists trg_desocupado_bd;
create trigger trg_desocupado_bd before delete on desocupado for each row
begin
	signal sqlstate '45000' set message_text = 'El microdato no se puede borrar';
end;

-- 9.5 Pruebas de los triggers
-- Prueba de la auditoría: un indicador de prueba se inserta, se actualiza y se elimina; quedan 3 registros en auditoriaIndicador
insert into indicador (idTipoIndicador, idUsuario, valorIndicador, cvIndicador, fechaCalculoIndicador)
values (1, 12, 100, 1, curdate());
set @id_prueba = last_insert_id();
update indicador set valorIndicador = 150 where idIndicador = @id_prueba;
delete from indicador where idIndicador = @id_prueba;
select * from auditoriaIndicador order by idAuditoria desc limit 3;

-- Pruebas negativas: ejecutar UNA POR UNA (Ctrl+Enter); cada una debe fallar con el mensaje indicado
-- 9.5.1 Debe fallar con "El microdato no se puede modificar"
update persona set edad = 40 where idPersona = (select x.id from (select min(idPersona) as id from persona) x);
-- 9.5.2 Debe fallar con "El microdato no se puede borrar"
delete from ocupado where idPersona = (select x.id from (select min(idPersona) as id from ocupado) x);
-- 9.5.3 Debe fallar con "La tabla de auditoría no se puede modificar"
update auditoriaIndicador set valorNuevoIndicador = 0 where idAuditoria = 1;
-- 9.5.4 Debe fallar con "La tabla de auditoría no se puede borrar"
delete from auditoriaIndicador where idAuditoria = 1;
-- 9.5.5 Debe fallar con "La persona ya está registrada como ocupada"
insert into desocupado (idPersona) select min(idPersona) from ocupado;
--RQF 44
select * from auditoriaIndicador
where idIndicador = 1,
order by idAuditoria;
