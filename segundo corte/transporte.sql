create database if not exists transporte character set utf8mb4;
use transporte;

create table camionero (
  idcamionero varchar(30) primary key,
  nombrecamionero varchar(80) not null,
  telefono int not null,
  direccioncamionero varchar(150) not null 
);

create table conduccion (
  idconduccion varchar(30) primary key
);

alter table conduccion
add idcamionerofk varchar(30);

alter table conduccion
add constraint conduccioncamionero
foreign key (idcamionerofk)
references camionero(idcamionero);

alter table conduccion
add placafk varchar(15);

create table camion (
  idcamion varchar(30) primary key,
  placacamion varchar(15) not null,
  potenciacamion int not null,
  tipocamion varchar(40) not null 
);

alter table camion
add constraint uq_placa_camion
unique (placacamion);

alter table conduccion
add constraint fk_conduccion_camion
foreign key (placafk)
references camion(placacamion);

create table paquete (
  idpaquete varchar(30) primary key,
  descripcionpaquete varchar(200) not null,
  destinatariopaquete varchar(80) not null,
  direccionpaquete varchar(150) not null 
);

alter table paquete
add idcamionerofk varchar(30);

alter table paquete
add constraint fk_paquete_camionero
foreign key (idcamionerofk)
references camionero(idcamionero);

create table ciudad (
  codigociudad varchar(20) primary key,  
  idpaquetefk varchar(30),
  nombreciudad varchar(50)
);

alter table ciudad
add constraint fk_ciudad_paquete
foreign key (idpaquetefk)
references paquete(idpaquete);