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