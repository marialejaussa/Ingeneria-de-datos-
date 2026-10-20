create database empresadeseguros;
use empresadeseguros;

create table compañia(
  idcompañia varchar(50) primary key,
  nitcompañia int not null,
  nombrecompañia varchar(50) not null,
  fechafundacion date,
  representantelegal varchar(50) not null
);

create table automovil(
  idautomovil varchar(50) primary key,
  marcaautomovil varchar(50) not null,
  modeloautomovil varchar(50) not null,
  placaautomovil varchar(10) not null,
  tipoautomovil varchar(50) not null,
  aniofabricacion year not null,
  seriechasis int not null,
  pasajeros int,
  cilindrajeautomovil varchar(30),
  idcompañiafk varchar(50),
  fechainicio date,
  estadoautomovil bool, 
  valorasegurado int not null,
  costoautomovil int not null
);

alter table automovil
add constraint fkautomovilcompañia
foreign key (idcompañiafk)
references compañia (idcompañia);

create table accidente(
  idaccidente varchar(50) primary key,
  fechaaccidente date,
  lugaraccidente varchar(50) not null,
  heridosaccidente int not null,
  fatalidades varchar(50) not null,
  automores int not null
);

create table involucra(
  idinvolucra varchar(50) primary key,
  idautomovilkf varchar(50),
  idaccidentefk varchar(50)
);

alter table involucra
add constraint fkinvolucraautomovil
foreign key (idautomovilkf)
references automovil (idautomovil);

alter table involucra
add constraint fkinvolucraaccidente
foreign key (idaccidentefk)
references accidente (idaccidente);