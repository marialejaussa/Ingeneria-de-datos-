create database tiendamascotas
use tiendamascotas;

create table cliente(
  idcliente varchar(50) primary key,
  nombres varchar(100) not null,
  apellidos varchar(100) not null,
  direccion varchar(150) not null,
  telefono varchar(20) not null
);

create table mascota(
  idmascota varchar(50) primary key,
  nombremascota varchar(100) not null,
  tipo varchar(50) not null,
  genero varchar(20) not null,
  raza varchar(50) not null,
  idclientefk varchar(50)
);

alter table mascota
add constraint fkmascotacliente
foreign key (idclientefk)
references cliente(idcliente);

create table producto(
  codigobarras varchar(50) primary key,
  nombreproducto varchar(100) not null,
  marca varchar(100) not null,
  precio decimal(10,2) not null
);

create table ventaproducto(
  idventaproducto varchar(50) primary key,
  idclientefk varchar(50),
  codigobarrasfk varchar(50)
);

alter table ventaproducto
add constraint fkventaproductocliente
foreign key (idclientefk)
references cliente(idcliente);

alter table ventaproducto
add constraint fkventaproductoproducto
foreign key (codigobarrasfk)
references producto(codigobarras);

create table vacuna(
  codigovacuna varchar(50) primary key,
  nombrevacuna varchar(100) not null,
  dosis varchar(100) not null,
  enfermedad varchar(150) not null
);

create table aplicacionvacuna(
  idaplicacion varchar(50) primary key,
  idmascotafk varchar(50),
  codigovacunafk varchar(50)
);

alter table aplicacionvacuna
add constraint fkaplicacionvacunamascota
foreign key (idmascotafk)
references mascota(idmascota);

alter table aplicacionvacuna
add constraint fkaplicacionvacunavacuna
foreign key (codigovacunafk)
references vacuna(codigovacuna);