create database Biblioteca;
use Biblioteca;

create table libro(
idLibro varchar(20) primary key,
tituloLibro varchar(50) not null,
identificacionAutorFK varchar(50),
anioPublicacion year not null,
estadoLibro bool
);

create table autor(
identificacionAutor varchar (50) primary key,
nombreAutor varchar(50) not null,
fechaNacimiento date
);

alter table libro 
add constraint autorlibro
foreign key (identificacionAutorFK)
references autor (identificacionAutor);

create table miembro (
identificacionMiembro int auto_increment primary key,
documentoMiembro int not null,
nombreMiembro varchar (20) not null,
direccionMiembro varchar (50) null,
fechaInscripcion date not null,
estadoMiembro bool
);

create table prestamo (
idPrestamo int auto_increment primary key,
fechaPrestamo date not null,
fechaDevolucion date not null,
estadoPrestamo bool,
identificacionMiembroFK int,
idLibroFK varchar (20),
constraint fkprestamomiembro
	foreign key (identificacionMiembroFK)
    references miembro (identificacionMiembro)
    on delete cascade, 
constraint fkprestamolibro
	foreign key (idLibroFK)
    references libro (idLibro)
    on delete cascade
);
/* describir la estructura de las tablas*/
describe prestamo;

alter table prestamo
add descripcion varchar (100);

alter table libro
modify anioPublicacion varchar(100);

alter table miembro
drop column documentoMiembro;

/*se va a cambiar el nombre de la tabla por socio*/
rename table miembro to socio;