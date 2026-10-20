create database techcorp;
use techcorp;

create table departamento(
    idDepartamento int auto_increment primary key,
    nombreDepartamento varchar(100) not null
);



create table empleado(
    idEmpleado int auto_increment primary key,
    nombreEmpleado varchar(100) not null,
    edad int not null,
    salario decimal(10,2) not null,
    fechaContratacion date not null,
    idDepartamentoFK int,
    
    constraint fk_empleado_departamento
    foreign key (idDepartamentoFK)
    references departamento(idDepartamento)
);




insert into departamento(nombreDepartamento)
values 
('Ventas'),
('IT'),
('Recursos Humanos'),
('Marketing'),
('Finanzas');




insert into empleado
(nombreEmpleado, edad, salario, fechaContratacion, idDepartamentoFK)
values 
('Ana Torres', 28, 3500.00, '2021-03-15', 1),
('Carlos Ramirez', 35, 4800.00, '2019-07-10', 2),
('Andres Martinez', 42, 5200.00, '2018-01-20', 1),
('Camila Rodriguez', 31, 4100.00, '2022-05-12', 3),
('Juan Perez', 29, 3900.00, '2023-02-01', 2),
('Laura Gomez', 36, 4500.00, '2020-08-17', 4),
('Pedro Sanchez', 40, 4300.00, '2017-11-25', 5),
('Carolina Vargas', 33, 4700.00, '2021-09-05', 1),
('Miguel Hernandez', 27, 3200.00, '2024-01-15', 2),
('Alejandra Castro', 38, 5500.00, '2019-04-22', 3);




select  
    nombreEmpleado,
    edad,
    salario
from empleado;




select
    nombreEmpleado,
    salario
from empleado
where salario > 4000;



select
    e.nombreEmpleado,
    d.nombreDepartamento
from empleado e
inner join departamento d
on e.idDepartamentoFK = d.idDepartamento
where d.nombreDepartamento = 'Ventas';



select
    nombreEmpleado,
    edad
from empleado
where edad between 30 and 40;



select
    nombreEmpleado,
    fechaContratacion
from empleado
where fechaContratacion > '2020-12-31';




select
    d.nombreDepartamento,
    COUNT(e.idEmpleado) AS cantidadEmpleados
from departamento d
left join empleado e
on d.idDepartamento = e.idDepartamentoFK
group by d.idDepartamento, d.nombreDepartamento;




select
    AVG(salario) AS salarioPromedio
from empleado;




select
    nombreEmpleado
from empleado
where nombreEmpleado LIKE 'A%'
   or nombreEmpleado LIKE 'C%';




select
    e.nombreEmpleado,
    d.nombreDepartamento
from empleado e
inner join departamento d
on e.idDepartamentoFK = d.idDepartamento
where d.nombreDepartamento <> 'IT';




select
    nombreEmpleado,
    salario
from empleado
where salario = (
    select MAX(salario)
    from empleado
);