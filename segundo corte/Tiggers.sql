/* ejercicio trigger — biblioteca universitaria  */

drop database if exists biblioteca;
create database biblioteca character set utf8mb4;
use biblioteca;
set names utf8mb4;

create table socios (
  id     int auto_increment primary key,
  nombre varchar(100) not null,
  email  varchar(100) not null unique,
  activo boolean      not null default true
);

create table libros (
  id                     int auto_increment primary key,
  titulo                 varchar(150) not null,
  autor                  varchar(100) not null,
  ejemplares_totales     int not null check (ejemplares_totales >= 0),
  ejemplares_disponibles int not null check (ejemplares_disponibles >= 0)
);

create table prestamos (
  id               int auto_increment primary key,
  socio_id         int  not null,
  libro_id         int  not null,
  fecha_prestamo   date not null,
  fecha_limite     date not null,
  fecha_devolucion date null,
  constraint fk_prestamos_socio foreign key (socio_id) references socios(id),
  constraint fk_prestamos_libro foreign key (libro_id) references libros(id)
);

create table historial_prestamos (
  id          int auto_increment primary key,
  prestamo_id int          not null,
  accion      varchar(20)  not null,
  detalle     varchar(255),
  usuario     varchar(100) not null,
  fecha       datetime     not null default current_timestamp,
  constraint fk_historial_prestamo foreign key (prestamo_id) references prestamos(id)
);

/* datos de prueba (fechas relativas al día de ejecución) */
insert into socios (nombre, email, activo) values
  ('camila rojas',   'camila@correo.com',    true),
  ('andrés díaz',    'andres@correo.com',    true),
  ('valentina ríos', 'valentina@correo.com', false),   -- inactiva
  ('mateo castro',   'mateo@correo.com',     true);    -- ya tiene 3 préstamos activos

insert into libros (titulo, autor, ejemplares_totales, ejemplares_disponibles) values
  ('cien años de soledad',          'gabriel garcía márquez',    3, 2),
  ('clean code',                    'robert c. martin',          2, 0),    -- agotado
  ('fundamentos de bases de datos', 'abraham silberschatz',      4, 3),
  ('el principito',                 'antoine de saint-exupéry',  2, 2);

insert into prestamos (socio_id, libro_id, fecha_prestamo, fecha_limite, fecha_devolucion) values
  (1, 1, current_date - interval '40' day, current_date - interval '26' day, current_date - interval '27' day), -- devuelto
  (2, 2, current_date - interval '20' day, current_date - interval '6' day,  null),  -- vencido hace 6 días
  (4, 2, current_date - interval '18' day, current_date - interval '4' day,  null),  -- vencido hace 4 días
  (4, 1, current_date - interval '5' day,  current_date + interval '9' day,  null),  -- al día
  (4, 3, current_date - interval '2' day,  current_date + interval '12' day, null);  -- al día

/* r1 — vista: préstamos vencidos (no devueltos y con fecha límite pasada) */
create or replace view v_prestamos_vencidos as
select p.id                                  as prestamo_id,
       s.nombre                              as socio,
       s.email,
       l.titulo                              as libro,
       p.fecha_limite,
       datediff(current_date, p.fecha_limite) as dias_retraso
from prestamos p
inner join socios s on s.id = p.socio_id
inner join libros l on l.id = p.libro_id
where p.fecha_devolucion is null
  and p.fecha_limite < current_date;

/* r2 — procedimiento: sp_prestar_libro */
drop procedure if exists sp_prestar_libro;
delimiter //
create procedure sp_prestar_libro(
    in  p_socio_id    int,
    in  p_libro_id    int,
    in  p_dias        int,
    out p_prestamo_id int
)
begin
    declare v_activo      boolean;
    declare v_disponibles int;
    declare v_activos     int;

    -- atomicidad: ante cualquier error se deshace todo y se vuelve a lanzar el error
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    set p_prestamo_id = null;

    -- regla 4: el préstamo dura entre 1 y 30 días
    if p_dias is null or p_dias < 1 or p_dias > 30 then
        signal sqlstate '45000' set message_text = 'días fuera de rango: el préstamo dura entre 1 y 30 días';
    end if;

    start transaction;

    -- for update bloquea la fila del socio y del libro hasta el commit
    select activo into v_activo from socios where id = p_socio_id for update;
    if v_activo is null then
        signal sqlstate '45000' set message_text = 'el socio no existe';
    end if;

    select ejemplares_disponibles into v_disponibles from libros where id = p_libro_id for update;
    if v_disponibles is null then
        signal sqlstate '45000' set message_text = 'el libro no existe';
    end if;

    -- regla 1: un socio inactivo no puede recibir préstamos
    if v_activo = false then
        signal sqlstate '45000' set message_text = 'socio inactivo: no puede recibir préstamos';
    end if;

    -- regla 2: máximo 3 préstamos activos (sin devolver)
    select count(*) into v_activos
      from prestamos where socio_id = p_socio_id and fecha_devolucion is null;
    if v_activos >= 3 then
        signal sqlstate '45000' set message_text = 'el socio ya tiene 3 préstamos activos';
    end if;

    -- regla 3: solo se presta si hay ejemplares disponibles
    if v_disponibles <= 0 then
        signal sqlstate '45000' set message_text = 'no hay ejemplares disponibles de este libro';
    end if;

    -- crear el préstamo: fecha de hoy y límite = hoy + días
    insert into prestamos (socio_id, libro_id, fecha_prestamo, fecha_limite)
    values (p_socio_id, p_libro_id, current_date, date_add(current_date, interval p_dias day));
    set p_prestamo_id = last_insert_id();

    -- descontar un ejemplar disponible
    update libros set ejemplares_disponibles = ejemplares_disponibles - 1 where id = p_libro_id;

    -- registrar la acción prestamo
    insert into historial_prestamos (prestamo_id, accion, detalle, usuario)
    values (p_prestamo_id, 'prestamo',
            concat('préstamo por ', p_dias, ' días; vence el ', date_add(current_date, interval p_dias day)),
            current_user());

    commit;
end//
delimiter ;

/* r3 — trigger: devolución (after update sobre prestamos) */
drop trigger if exists trg_prestamos_after_update;
delimiter //
create trigger trg_prestamos_after_update
after update on prestamos
for each row
begin
    -- solo cuando pasa de "no devuelto" a "devuelto"
    if old.fecha_devolucion is null and new.fecha_devolucion is not null then
        update libros
           set ejemplares_disponibles = ejemplares_disponibles + 1
         where id = new.libro_id;

        insert into historial_prestamos (prestamo_id, accion, detalle, usuario)
        values (new.id, 'devolucion',
                concat('días de retraso: ', greatest(datediff(new.fecha_devolucion, new.fecha_limite), 0)),
                current_user());
    end if;
end//
delimiter ;


drop trigger if exists trg_prestamos_before_update;
delimiter //
create trigger trg_prestamos_before_update
before update on prestamos
for each row
begin
    if new.fecha_devolucion is not null and new.fecha_devolucion < new.fecha_prestamo then
        signal sqlstate '45000'
        set message_text = 'la fecha de devolución no puede ser anterior a la fecha de préstamo';
    end if;
end//
delimiter ;

/* 1. consultar la vista: 2 filas (andrés 6 días y mateo 4 días) */
select * from v_prestamos_vencidos;

/* 2. prestar a camila (1) "el principito" (4) por 14 días: préstamo id 6; el principito queda con 1 */
call sp_prestar_libro(1, 4, 14, @id_prestamo);
select @id_prestamo as prestamo_creado;
select id, titulo, ejemplares_disponibles from libros where id = 4;

/* 3. valentina (3), socio inactivo -> error */
call sp_prestar_libro(3, 1, 7, @x);
/* 4. camila (1) "clean code" (2), sin ejemplares -> error */
call sp_prestar_libro(1, 2, 7, @x);
/* 5. mateo (4), ya tiene 3 préstamos activos -> error */
call sp_prestar_libro(4, 4, 7, @x);
/* 6. préstamo con 0 días -> error */
call sp_prestar_libro(1, 3, 0, @x);

/* 7. devolución del préstamo 2 con fecha de hoy: clean code pasa a 1; historial con 6 días de retraso */
update prestamos set fecha_devolucion = current_date where id = 2;
select id, titulo, ejemplares_disponibles from libros where id = 2;
select * from historial_prestamos order by id;

/* 8. la vista otra vez: solo queda mateo */
select * from v_prestamos_vencidos;

/* 9. repetir el mismo update del paso 7: no cambia el inventario ni agrega historial */
update prestamos set fecha_devolucion = current_date where id = 2;
select id, titulo, ejemplares_disponibles from libros where id = 2;
select count(*) as registros_historial from historial_prestamos;

/* prueba del reto opcional (debe fallar): devolución anterior al préstamo */
update prestamos set fecha_devolucion = '2000-01-01' where id = 6;

