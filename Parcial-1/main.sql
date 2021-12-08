CREATE TABLE EMPLEADO(
  CIP number not null,
  nombre VARCHAR2 not null,
  primer_apellido VARCHAR2(45),
  segundo_apellido VARCHAR2(45),
)

CREATE TABLE SUCURSALES {
  cod_sucursal number not null,
  domicilio string,
  su_cod_tel number
}

