/* consultas multitabla subconsultas y funciones */
/* situación: “el miércoles del gerente” */
/* trabajas como desarrollador en tecnoandes, una tienda de tecnología. 
el sistema de ventas guarda la información en cinco tablas: clientes, vendedores, productos, pedidos y detalle_pedido. 
el miércoles a las 8:00 el gerente te escribe por el chat:
1. “¿qué clientes han comprado? clientes pedido (fk de clientes)”
2. “¿qué productos compró cada cliente?” detalle_pedido 
3. “¿qué vendedor vendió más?”
4. “¿cuáles productos cuestan más que el promedio?”
5. “¿cuánto hemos vendido en total?”
6. “¿qué clientes se registraron y nunca compraron? quiero llamarlos.”
necesita todo antes de la reunión de las 10:00. */

create database if not exists ventas_join character set utf8mb4;
use ventas_join;

create table clientes (
  id             int auto_increment primary key,   -- pk: identifica a cada cliente
  nombre         varchar(50)  not null,
  apellido       varchar(50)  not null,
  email          varchar(100) not null unique,
  ciudad         varchar(50),
  fecha_registro date         not null
);

create table vendedores (
  id     int auto_increment primary key,
  nombre varchar(100) not null,
  zona   varchar(30)  not null
);

create table productos (
  id        int auto_increment primary key,
  nombre    varchar(100)  not null,
  categoria varchar(50)   not null,
  precio    decimal(12,2) not null
);

create table pedidos (
  id          int auto_increment primary key,
  cliente_id  int  not null,                        -- fk hacia clientes
  vendedor_id int  null,                            -- fk opcional: venta online = null
  fecha       date not null,
  constraint fk_pedidos_cliente  foreign key (cliente_id)  references clientes(id),
  constraint fk_pedidos_vendedor foreign key (vendedor_id) references vendedores(id)
);

create table detalle_pedido (
  id              int auto_increment primary key,
  pedido_id       int           not null,
  producto_id     int           not null,
  cantidad        int           not null,
  precio_unitario decimal(12,2) not null,           -- precio al momento de la venta
  constraint fk_detalle_pedido   foreign key (pedido_id)   references pedidos(id),
  constraint fk_detalle_producto foreign key (producto_id) references productos(id)
);

insert into clientes (nombre, apellido, email, ciudad, fecha_registro) values
  ('ana',   'torres',  'ana@correo.com',   'bogotá',       '2025-01-15'),
  ('luis',  'pérez',   'luis@correo.com',  'medellín',     '2025-03-02'),
  ('marta', 'gómez',   'marta@correo.com', 'cali',         '2025-06-20'),
  ('sofía', 'ramírez', 'sofia@correo.com', 'bogotá',       '2026-02-10'),
  ('diego', 'castro',  'diego@correo.com', 'barranquilla', '2026-05-05');

insert into vendedores (nombre, zona) values
  ('carlos ruiz', 'norte'),
  ('diana león',  'sur'),
  ('laura mesa',  'centro');   

insert into productos (nombre, categoria, precio) values
  ('portátil 14\"',        'computadores', 2500000.00),
  ('mouse inalámbrico',   'accesorios',     60000.00),
  ('monitor 24\"',         'pantallas',     700000.00),
  ('teclado mecánico',    'accesorios',    250000.00),
  ('audífonos bluetooth', 'accesorios',    180000.00),
  ('tablet 10\"',          'computadores', 1200000.00);  
  
insert into pedidos (cliente_id, vendedor_id, fecha) values
  (1, 1,    '2026-07-05'),
  (2, 2,    '2026-07-18'),
  (1, 2,    '2026-08-02'),
  (3, 1,    '2026-08-15'),
  (2, 1,    '2026-09-01'),
  (3, null, '2026-09-10');   

insert into detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario) values
  (25, 1, 1, 2500000.00),
  (25, 2, 2,   60000.00),
  (26, 3, 2,  700000.00),
  (27, 4, 1,  250000.00),
  (27, 5, 1,  180000.00),
  (28, 2, 3,   60000.00),
  (28, 3, 1,  700000.00),
  (29, 1, 1, 2500000.00),
  (29, 5, 2,  180000.00),
  (30, 4, 2,  250000.00);
  
select * from clientes;
select * from vendedores;
select * from detalle_pedido;
select * from productos;
select * from pedidos;
describe pedidos;

/* 1. ¿qué clientes han comprado? clientes pedido (fk de clientes) */
select c.nombre, c.apellido, p.id as pedido, p.fecha
from clientes c
inner join pedidos p on p.cliente_id = c.id
order by p.id;

/* 3. ¿qué vendedor vendió más? */
select 
    c.nombre,
    count(p.id) as cantidad_pedidos
from clientes c
left join pedidos p on p.cliente_id = c.id
group by c.id, c.nombre
order by cantidad_pedidos desc
limit 1;

select c.nombre, p.id as pedido
from clientes c
left join pedidos p on p.cliente_id = c.id
order by c.id, p.id;

/* 6. ¿qué clientes se registraron y nunca compraron? quiero llamarlos. */
select c.nombre, c.apellido
from clientes c
left join pedidos p on p.cliente_id = c.id
where p.id is null; 

select 
    c.nombre,
    count(p.id) as cantidad_pedidos
from clientes c
left join pedidos p on p.cliente_id = c.id
group by c.id, c.nombre
order by cantidad_pedidos desc;

select p.id as pedido, v.nombre as vendedor
from pedidos p
right join vendedores v on v.id = p.vendedor_id
order by v.id, p.id;

/* 2. ¿qué productos compró cada cliente? detalle_pedido */
describe pedidos;
describe clientes;
describe detalle_pedido;
describe productos;

select c.nombre as cliente, p.id as pedido, pr.nombre as producto,
       d.cantidad
from clientes c
join pedidos p on p.cliente_id = c.id
join detalle_pedido d on d.pedido_id = p.id
join productos pr on pr.id = d.producto_id
order by p.id, pr.nombre;

/* ------------------------------------------------------------- */
/* eduplus: plataforma de cursos en línea */
/* ------------------------------------------------------------- */

create database if not exists eduplus character set utf8mb4;
use eduplus;

create table instructores (
  id     int auto_increment primary key,
  nombre varchar(100) not null,
  email  varchar(100) not null unique
);

create table cursos (
  id            int auto_increment primary key,
  titulo        varchar(100)  not null,
  area          varchar(50)   not null,
  precio        decimal(10,2) not null,
  instructor_id int           not null,
  constraint fk_cursos_instructor foreign key (instructor_id) references instructores(id)
);

create table estudiantes (
  id       int auto_increment primary key,
  nombre   varchar(50) not null,
  apellido varchar(50) not null,
  ciudad   varchar(50) not null
);

create table inscripciones (
  id                int auto_increment primary key,
  estudiante_id     int           not null,
  curso_id          int           not null,
  fecha_inscripcion date          not null,
  valor_pagado      decimal(10,2) not null,
  nota_final        decimal(3,1)  null,          
  constraint fk_insc_estudiante foreign key (estudiante_id) references estudiantes(id),
  constraint fk_insc_curso      foreign key (curso_id)      references cursos(id)
);

insert into instructores (nombre, email) values
  ('paula herrera',   'paula@eduplus.co'),
  ('andrés quintero', 'andres@eduplus.co'),
  ('camilo vargas',   'camilo@eduplus.co');

insert into cursos (titulo, area, precio, instructor_id) values
  ('sql desde cero',       'bases de datos', 200000.00, 1),
  ('python para análisis', 'programación',   350000.00, 2),
  ('git y github',         'herramientas',   120000.00, 1),
  ('react avanzado',       'programación',   450000.00, 2),
  ('docker práctico',      'herramientas',   300000.00, 1);

insert into estudiantes (nombre, apellido, ciudad) values
  ('valeria',  'ortiz',  'bogotá'),
  ('samuel',   'rojas',  'medellín'),
  ('isabella', 'cruz',   'cali'),
  ('tomás',    'pineda', 'bogotá'),
  ('juliana',  'soto',   'pereira'),
  ('martín',   'lópez',  'cali');

insert into inscripciones (estudiante_id, curso_id, fecha_inscripcion, valor_pagado, nota_final) values
  (1, 1, '2026-06-01', 200000.00, 4.5),
  (1, 2, '2026-06-10', 350000.00, 4.0),
  (2, 1, '2026-06-05', 180000.00, 3.8),
  (2, 4, '2026-07-01', 450000.00, null),
  (3, 2, '2026-07-15', 315000.00, 4.8),
  (3, 3, '2026-07-20', 120000.00, 4.2),
  (4, 1, '2026-08-01', 200000.00, null),
  (4, 3, '2026-08-03', 120000.00, 3.5),
  (4, 4, '2026-08-10', 450000.00, null);
  
/* punto 1 — inner join: listar todos los cursos con su área, precio y el nombre de su instructor, ordenados por instructor y título. */
select c.titulo,
       c.area,
       c.precio,
       i.nombre as instructor
from cursos c
inner join instructores i on i.id = c.instructor_id
order by i.nombre, c.titulo;

/* punto 2 — left join: el área de mercadeo quiere escribir a los estudiantes registrados que no se han inscrito en ningún curso. mostrar nombre, apellido y ciudad. */
select e.nombre,
       e.apellido,
       e.ciudad
from estudiantes e
left join inscripciones ins on ins.estudiante_id = e.id
where ins.id is null;

/* punto 3 — tres o más tablas: para cada inscripción: nombre completo del estudiante (en una sola columna), título del curso, nombre del instructor, fecha de inscripción y valor pagado, ordenado por fecha. */
select concat(e.nombre, ' ', e.apellido) as estudiante,
       c.titulo                          as curso,
       i.nombre                          as instructor,
       ins.fecha_inscripcion,
       ins.valor_pagado
from inscripciones ins
join estudiantes  e on e.id = ins.estudiante_id
join cursos       c on c.id = ins.curso_id
join instructores i on i.id = c.instructor_id
order by ins.fecha_inscripcion;