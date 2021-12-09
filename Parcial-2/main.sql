/*
Parcial 2 
PISO1 - F.Sistemas 1-20
PISO2 - F.Civil 21-40
PISO3 - F.Industrial 41-60
PISO4 - F.Mecánica 61-70
PISO5 - F.Eléctrica 71-80

*/

-- Apartado A
CREATE TABLE AULAS (
  aula_id number not null,
  piso number, 
  salon number, 
  facultad number, 
  disponible CHAR,
  constraint disponible CHECK (disponible in ('S','N')),
  CONSTRAINT PK_AULAS PRIMARY KEY ( aula_id, piso, salon, facultad )
);

--Bloque Anonimo CASO 1 
DECLARE
v_aula_id Aulas.aula_id%TYPE;
v_piso Aulas.piso%TYPE;
v_salon Aulas.salon%TYPE;
v_facultad Aulas.facultad%TYPE;
v_disponible Aulas.disponible%TYPE;

BEGIN

--BUCLE PARA FACULTAD SISTEMAS
FOR v_indice IN 1..20 LOOP
 INSERT INTO AULAS (aula_id, piso, salon, facultad, disponible) VALUES (v_indice, 1, 1, 1, 'S' );
    END LOOP;
--BUCLE PARA FACULTAD CIVIL
FOR v_indice IN 21..40 LOOP
 INSERT INTO AULAS (aula_id, piso, salon, facultad, disponible) VALUES (v_indice, 2, 21, 2, 'S' );
    END LOOP;

----BUCLE PARA FACULTAD INDUSTRIAL
FOR v_indice IN 41..60 LOOP
 INSERT INTO AULAS (aula_id, piso, salon, facultad, disponible) VALUES (v_indice, 3, 41, 3, 'N' );
    END LOOP;
--BUCLE PARA FACULTAD MECANICA
FOR v_indice IN 61..70 LOOP
 INSERT INTO AULAS (aula_id, piso, salon, facultad, disponible) VALUES (v_indice, 4, 61, 4, 'S' );
END LOOP;
----BUCLE PARA FACULTAD ELECTRICA
FOR v_indice IN 71..80 LOOP
 INSERT INTO AULAS (aula_id, piso, salon, facultad, disponible) VALUES (v_indice, 4, 71, 5, 'N' );
END LOOP;

EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Datos repetidos');
	WHEN VALUE_ERROR THEN
		dbms_output.put_line('Error causado por el tamaño de los datos ingresados');
    WHEN OTHERS THEN
	    dbms_output.put_line('Ocurrió un error en la inserción de los datos');

END;
/

create table habitaciones (
 piso integer NOT NULL,
 habitacion varchar(2) NOT NULL,
 tipo varchar(10) DEFAULT 'Doble'
CONSTRAINT nn_tipo NOT NULL
CONSTRAINT ch_Tipo  CHECK (tipo IN ('Individual','Doble', 'Suite')),
 primary key(piso,habitacion));

create table reservas (
 piso integer,
 habitacion varchar(2),
 fechaentrada date DEFAULT SYSDATE,
 noches integer,
 
 primary key(piso,habitacion,fechaentrada),
 foreign key (piso,habitacion) references habitaciones
);

create table temporadas (
 nombre varchar(10) not null,
 mesInicio integer not null,
 diaInicio integer not null,
 mesFin integer not null,
 diaFin integer not null,
 primary key(nombre,mesInicio,diaInicio)
);

CREATE TABLE estadistica_hotel (
  id_cadena number not null,
  nombre_hotel varchar2(50) not null,
  habitacionesocupadas number default 0, --Se podría meter default de 0
  habitacionesdisponibles number,
  habitacionesreservadas number default 0, --Se podría meter default de 0
  CONSTRAINT pk_cadena PRIMARY KEY (id_cadena)
);

CREATE OR REPLACE PROCEDURE insertar_temp(
    p_nombre IN temporadas.nombre%TYPE,
    p_mesInicio IN temporadas.mesinicio%TYPE ,
    p_diaInicio IN temporadas.DIAINICIO%TYPE ,
    p_mesFin  IN temporadas.MESFIN%TYPE,
    p_diaFin  IN temporadas.DIAFIN%TYPE
)
IS

BEGIN

INSERT INTO temporadas(nombre, mesinicio, diainicio,mesfin,diafin)
VALUES (p_nombre, p_mesInicio, p_diaInicio, p_mesFin, p_diaFin);

EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('La descripcion ya existe');
    WHEN OTHERS THEN
	    dbms_output.put_line('Ocurrió un error en la inserción de los datos');

END;
/
--PROCEDIMIENTO 2
CREATE OR REPLACE PROCEDURE creaHabitaciones AS
  piso integer;
  habitacion integer;
BEGIN
  -- primero borramos las habitaciones que haya anteriormente
  delete from habitaciones;
  -- las primeras 11 plantas
 FOR piso in 1..11 LOOP
     FOR habitacion in 1..20 LOOP
        insert into habitaciones values(piso,habitacion,'Doble');
     END LOOP;
     FOR habitacion in 21..25 LOOP
        insert into habitaciones values(piso,habitacion,'Individual');
     END LOOP;
 END LOOP;
 
  -- ahora la planta 12
  piso:=12;
  FOR habitacion in 1..8 LOOP
        insert into habitaciones values(piso,habitacion,'Suite');
  END LOOP;
 
END creaHabitaciones; 
/

--parte c
CREATE OR REPLACE FUNCTION CalcularDisponible(fecha1 date, fecha2 date, n1 integer, n2 integer) RETURN integer AS
  reservacion integer;
BEGIN
if (fecha1>=fecha2 and fecha1<=fecha2+n2-1) or (fecha1+n1-1>=fecha2 and fecha1+n1-1<=fecha2+n2-1) or
      (fecha1>=fecha2 and fecha1+n1-1<=fecha2+n2-1) then
   reservacion := 1;
else
   reservacion :=0;
end if;         
 RETURN reservacion;
END;
/

CREATE OR REPLACE PROCEDURE reservaHabitacion(
  p_piso  IN reservas.piso%TYPE,
   p_habitacion  IN reservas.habitacion%TYPE,
    p_fechaentrada  IN reservas.fechaentrada%TYPE,
     p_noches  IN reservas.noches%TYPE) 
     AS
 numero integer;
BEGIN
     SELECT count(*) INTO numero FROM reservas r
     where r.piso=p_piso and r.habitacion=p_habitacion and
    CalcularDisponible(r.fechaentrada,p_fechaentrada,r.noches,p_noches)=1;
     if (numero=0) then
        insert into reservas (piso, habitacion, fechaentrada, noches )values(p_piso,p_habitacion,p_fechaentrada,p_noches);
       DBMS_OUTPUT.PUT_LINE('Reservado');
     else
        DBMS_OUTPUT.PUT_LINE('No se puede reservar');
     end if;
END reservaHabitacion;
/

show error;

--BLOQUE ANONIMO PARTE B
DECLARE
BEGIN
INSERTAR_TEMP('ALTA',6,1,8,30);
INSERTAR_TEMP('MEDIA',1,1,31,5);
INSERTAR_TEMP('BAJA',1,9,31,12);
END;
/

select * from temporadas;

--BLOQUE ANONIMO PARTE C
DECLARE
BEGIN
creaHabitaciones();
END;
/

SELECT * from habitaciones;

--BLOQUE ANONIMO PARTE C
DECLARE

BEGIN
reservaHabitacion(1,1,'8-DEC-2021',10);
reservaHabitacion(1,1,'19-DEC-2021',1);
reservaHabitacion(1,1,'21-DEC-2021',10);
reservaHabitacion(1,1,'11-DEC-2021',10);
reservaHabitacion(1,1,'12-DEC-2021',10);
reservaHabitacion(1,1,'13-DEC-2021',10);
reservaHabitacion(1,1,'14-DEC-2021',10);
reservaHabitacion(1,1,'15-DEC-2021',10);
reservaHabitacion(1,1,'16-DEC-2021',10);

END;
/