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

















