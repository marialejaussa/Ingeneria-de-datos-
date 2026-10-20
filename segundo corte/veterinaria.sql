create database veterinaria;
use veterinaria;

create table cliente(
  idcliente varchar(30) primary key,
  nombrecompleto varchar(120) not null,
  telefono varchar(15) not null,
  correo varchar(80) not null,
  direccion varchar(120) not null
);

create table sede(
  idsede varchar(30) primary key,
  nombresede varchar(80) not null,
  ubicacionsede varchar(200) not null,
  horarioatencion varchar(80) not null
);

create table veterinario(
  idveterinario varchar(30) primary key,
  especialidad varchar(80) not null,
  horariotrabajo varchar(80) not null
);

create table mascota(
  idmascota varchar(30) primary key,
  nombremascota varchar(80) not null,
  especie varchar(40) not null,
  raza varchar(40) not null,
  fechanacimiento date not null,
  sexo varchar(15) not null,
  peso decimal(6,2) not null,
  idclientefk varchar(30),
  numeromicrochip varchar(40) not null
);

alter table mascota
add constraint fkmascotacliente
foreign key (idclientefk)
references cliente(idcliente);

create table cita(
  idcita varchar(30) primary key,
  motivo varchar(250) not null,
  fecha date not null,
  idclientefk varchar(30),
  hora time not null
);

alter table cita
add constraint fkcitacliente
foreign key (idclientefk)
references cliente(idcliente);

alter table cita
add idmascotafk varchar(30),
add idsedefk varchar(30),
add idveterinariofk varchar(30);

alter table cita
add constraint fkcitamascota
foreign key (idmascotafk)
references mascota(idmascota);

alter table cita
add constraint fkcitasede
foreign key (idsedefk)
references sede(idsede);

alter table cita
add constraint fkcitaveterinario
foreign key (idveterinariofk)
references veterinario(idveterinario);

create table consulta(
  idconsulta varchar(30) primary key,
  sintomas varchar(400) not null,
  diagnostico varchar(400) not null,
  indicaciones varchar(400) not null,
  idcitafk varchar(30) unique 
);

alter table consulta
add constraint fkconsultacita
foreign key (idcitafk)
references cita(idcita);

create table medicamento(
  idmedicamento varchar(30) primary key,
  nombremedicamento varchar(120) not null,
  descripcionmedicamento varchar(250) not null
);

create table inventario(
  idinventario varchar(30) primary key,
  cantidaddisponible int not null,
  lote varchar(40) not null,
  fechavencimiento date not null
);

alter table inventario
add idsedefk varchar(30),
add idmedicamentofk varchar(30);

alter table inventario
add constraint fkinventariosede
foreign key (idsedefk)
references sede(idsede);

alter table inventario
add constraint fkinventariomedicamento
foreign key (idmedicamentofk)
references medicamento(idmedicamento);

create table prescripcion(
  idprescripcion varchar(30) primary key,
  dosis varchar(80) not null,
  frecuencia varchar(80) not null,
  duracion varchar(80) not null,
  idconsultafk varchar(30),
  idmedicamentofk varchar(30)
);

alter table prescripcion
add constraint fkprescripcionconsulta
foreign key (idconsultafk)
references consulta(idconsulta);

alter table prescripcion
add constraint fkprescripcionmedicamento
foreign key (idmedicamentofk)
references medicamento(idmedicamento);

create table hospitalizacion(
  idhospitalizacion varchar(30) primary key,
  fechaingreso date not null,
  fechasalida date,
  notasevolucion varchar(400),
  jaula varchar(30),
  idmascotafk varchar(30)
);

alter table hospitalizacion
add constraint fkhospitalizacionmascota
foreign key (idmascotafk)
references mascota(idmascota);

create table factura(
  idfactura varchar(30) primary key,
  fecha date not null,
  total decimal(12,2) not null,
  estadopago varchar(25) not null,
  idclientefk varchar(30),
  idconsultafk varchar(30) unique 
);

alter table factura
add constraint fkfacturacliente
foreign key (idclientefk)
references cliente(idcliente);

alter table factura
add constraint fkfacturaconsulta
foreign key (idconsultafk)
references consulta(idconsulta);