/*
Parcial 2 
Cutire, Fernando
P1 - F.Sistemas 1-20
P2 - F.Civil 21-40
P3 - F.Industrial 41-60
P4 - F.Mecánica 61-70
P5 - F.Eléctrica 71-80

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
        dbms_output.put_line('⚠️ Error: Datos repetidos');
	WHEN VALUE_ERROR THEN
		dbms_output.put_line('⚠️ Error: causado por el tamaño de los datos ingresados');
    WHEN OTHERS THEN
	    dbms_output.put_line('⚠️ Error: Ocurrió un error en la inserción de los datos');

END;
/

create table habitaciones (
 piso integer NOT NULL,
 habitacion varchar(2) NOT NULL,
 tipo varchar(10) DEFAULT 'Doble'
CONSTRAINT nn_tipo NOT NULL
CONSTRAINT ch_Tipo  CHECK (tipo IN ('Individual','Doble', 'Suite')),
 primary key(piso,habitacion)
 );

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

CREATE TABLE hotel_estadistica (
  id_cadena number not null,
  nombre_hotel varchar2(50) not null,
  habs_ocup number default 0, 
  habs_dispo number,
  habs_reser number default 0,
  CONSTRAINT pk_cadena PRIMARY KEY (id_cadena)
);

CREATE OR REPLACE PROCEDURE insert_temp(
    p_nombre IN temporadas.nombre%TYPE,
    p_mInicio IN temporadas.mesinicio%TYPE ,
    p_dInicio IN temporadas.DIAINICIO%TYPE ,
    p_mFin  IN temporadas.MESFIN%TYPE,
    p_dFin  IN temporadas.DIAFIN%TYPE
)
IS

BEGIN

INSERT INTO temporadas(nombre, mesinicio, diainicio,mesfin,diafin)
VALUES (p_nombre, p_mInicio, p_dInicio, p_mFin, p_dFin);

EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('⚠️Error: La descripcion ya existe');
    WHEN OTHERS THEN
	    dbms_output.put_line('⚠️Error: Ocurrió un error en la inserción de los datos');

END;
/
--PROCEDIMIENTO 2
CREATE OR REPLACE PROCEDURE creaHabitaciones AS
  piso integer;
  habitacion integer;
BEGIN
  delete from habitaciones;
 FOR piso in 1..11 LOOP
     FOR habitacion in 1..20 LOOP
        insert into habitaciones values(piso,habitacion,'Doble');
     END LOOP;
     FOR habitacion in 21..25 LOOP
        insert into habitaciones values(piso,habitacion,'Individual');
     END LOOP;
 END LOOP;
 
  piso:=12;
  FOR habitacion in 1..8 LOOP
        insert into habitaciones values(piso,habitacion,'Suite');
  END LOOP;
 
END creaHabitaciones; 
/

--parte c
CREATE OR REPLACE FUNCTION CalcularDisponible(fechaI date, fechaF date, n1 integer, n2 integer) RETURN integer AS
  reservacion integer;
BEGIN
if (fechaI>=fechaF and fechaI<=fechaF+n2-1) or (fechaI+n1-1>=fechaF and fechaI+n1-1<=fechaF+n2-1) or
      (fechaI>=fechaF and fechaI+n1-1<=fechaF+n2-1) then
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
 num integer;
BEGIN
     SELECT count(*) INTO num FROM reservas r
     where r.piso=p_piso and r.habitacion=p_habitacion and
    CalcularDisponible(r.fechaentrada,p_fechaentrada,r.noches,p_noches)=1;
     if (num=0) then
        insert into reservas (piso, habitacion, fechaentrada, noches )values(p_piso,p_habitacion,p_fechaentrada,p_noches);
       DBMS_OUTPUT.PUT_LINE('Reservado');
     else
        DBMS_OUTPUT.PUT_LINE('⚠️Error: No se puede reservar en la fecha asignada');
     end if;
END reservaHabitacion;
/

show error;

--BLOQUE ANONIMO PARTE B
DECLARE
BEGIN
insert_temp('BAJA',1,7,31,12);
insert_temp('MEDIA',1,2,31,5);
insert_temp('ALTA',6,10,8,30);

END;
/


--BLOQUE ANONIMO PARTE C
DECLARE
BEGIN
creaHabitaciones();
END;
/


--BLOQUE ANONIMO PARTE C
DECLARE

BEGIN
reservaHabitacion(1,1,'09-DEC-2021',7);
reservaHabitacion(1,1,'15-DEC-2021',3);
reservaHabitacion(1,1,'18-DEC-2021',10);

END;
/