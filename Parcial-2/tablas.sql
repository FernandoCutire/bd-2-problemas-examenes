create table Aulas(
salon number PRIMARY KEY NOT NULL,
piso number NOT NULL ,
facultad number NOT NULL,
disponible char NOT NULL CHECK ('S', 'N')
);

DECLARE

BEGIN

	for v_indice1 IN 1..20 LOOP
insert into Aulas (piso, salon ,facultad ,disponible) values
	(1, v_indice1, 1, 'S');
END LOOP;

	for v_indice2 IN 21..40 LOOP
insert into Aulas (piso,salon ,facultad ,disponible) values
	(2,v_indice2, 2, 'S');
END LOOP;

	for v_indice3 IN 41..60 LOOP
insert into Aulas (piso,salon ,facultad ,disponible) values
	(3,v_indice3, 3, 'S');
END LOOP;

	for v_indice4 IN 61..70 LOOP
insert into Aulas (piso,salon ,facultad ,disponible) values
	(4,v_indice4, 4, 'S');
END LOOP;

	for v_indice5 IN 71..80 LOOP
insert into Aulas (piso,salon ,facultad ,disponible) values
	(4,v_indice5, 5, 'S');
END LOOP;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Ya se encuentran registrados estos datos');
    WHEN OTHERS THEN
        dbms_output.put_line('Ocurrió un error en la inserción de los datos');
END;
/

SELECT * FROM Aulas;

SELECT * FROM AULAS
WHERE piso=3 AND salon=15 AND disponible = 'S';









