set serveroutput on;


CREATE TABLE tipos_correos (
    cod_correo  NUMBER NOT NULL,
    descripcion VARCHAR2(100),
    CONSTRAINT correo_u UNIQUE ( descripcion ),
    CONSTRAINT tipos_correos_pk PRIMARY KEY ( cod_correo )
);

CREATE TABLE tipos_prestamos (
    cod_prestamo    NUMBER NOT NULL,
    nombre_prestamo VARCHAR2(100) NOT NULL,
    tasa_interes    NUMBER(2, 2) DEFAULT 0,
    CONSTRAINT t_prestam_u UNIQUE ( nombre_prestamo ),
    CONSTRAINT tipos_prestamos_pk PRIMARY KEY ( cod_prestamo )
);

CREATE TABLE tipos_telefonos (
    cod_telefono NUMBER NOT NULL,
    descripcion  VARCHAR2(100),
    CONSTRAINT telefonos_u UNIQUE ( descripcion ),
    CONSTRAINT tipos_telefonos_pk PRIMARY KEY ( cod_telefono )
);

CREATE TABLE profesiones (
    id_profesion NUMBER NOT NULL,
    descripcion  VARCHAR2(100),
    CONSTRAINT profesion_u UNIQUE ( descripcion ),
    CONSTRAINT profesion_pk PRIMARY KEY ( id_profesion )
);

CREATE TABLE distritos (
    cod_distrito NUMBER NOT NULL,
    nombre       VARCHAR2(100),
    CONSTRAINT distrito_u UNIQUE ( NOMBRE ),
    CONSTRAINT distritos_pk PRIMARY KEY ( cod_distrito )
);


CREATE TABLE provincias (
    cod_provincia NUMBER NOT NULL,
    nombre        VARCHAR2(100),
    CONSTRAINT provincia_u UNIQUE ( nombre ),
    CONSTRAINT provincias_pk PRIMARY KEY ( cod_provincia )
);

CREATE TABLE provincias_distritos (
    cod_provincia NUMBER NOT NULL,
    cod_distrito  NUMBER NOT NULL,
    CONSTRAINT provincias_distritos_pk PRIMARY KEY ( cod_provincia,cod_distrito ),
    CONSTRAINT distritos_fk FOREIGN KEY ( cod_distrito )
        REFERENCES distritos ( cod_distrito ),
    CONSTRAINT provincias_fk FOREIGN KEY ( cod_provincia )
        REFERENCES provincias ( cod_provincia )
);

CREATE TABLE sucursales (
    cod_sucursal   NUMBER NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    monto_prestamo NUMBER(15, 2) DEFAULT 0,
    CONSTRAINT sucursales_pk PRIMARY KEY ( cod_sucursal ),
    CONSTRAINT sucursales_un UNIQUE ( nombre )
);

CREATE TABLE clientes (
    id_cliente    NUMBER NOT NULL,
    cedula        VARCHAR2(10) NOT NULL,
    nombre1       VARCHAR2(100) not NULL,
    apellido1     VARCHAR2(100) not NULL,
    fecha_nac     DATE not NULL,
    edad          NUMBER(3),
    sexo          CHAR NOT NULL,
    cod_profesion NUMBER NOT NULL,
    direccion     VARCHAR2(250) not NULL,
    cod_sucursal  NUMBER NOT NULL,
    constraint c_sexo CHECK (sexo in ('F','M')),
    CONSTRAINT clientes_un UNIQUE ( cedula ),
    CONSTRAINT clientes_pk PRIMARY KEY ( id_cliente ),
    CONSTRAINT clientes_profesion_fk FOREIGN KEY ( cod_profesion )
        REFERENCES profesiones ( id_profesion ),
    CONSTRAINT clientes_sucursales_fk FOREIGN KEY ( cod_sucursal )
        REFERENCES sucursales ( cod_sucursal )
);



CREATE TABLE clientes_correos (
    id_cliente NUMBER NOT NULL,
    id_correo  NUMBER NOT NULL,
    correo     VARCHAR2(100),
    CONSTRAINT clientes_correos_pk PRIMARY KEY ( id_cliente,id_correo ),
    CONSTRAINT clientes_fk FOREIGN KEY ( id_cliente )
        REFERENCES clientes ( id_cliente ),
    CONSTRAINT tipos_correos_fk FOREIGN KEY ( id_correo )
        REFERENCES tipos_correos ( cod_correo )
);



CREATE TABLE clientes_telefonos (
    id_cliente  NUMBER NOT NULL,
    id_telefono NUMBER NOT NULL,
    telefono    VARCHAR2(10),
    CONSTRAINT clientes_telefonos_pk PRIMARY KEY ( id_cliente,id_telefono ),
    CONSTRAINT clientes_telefonos_fk FOREIGN KEY ( id_cliente )
        REFERENCES clientes ( id_cliente ),
    CONSTRAINT clientes_tipos_telefonos_fk FOREIGN KEY ( id_telefono )
        REFERENCES tipos_telefonos ( cod_telefono )
);

CREATE TABLE tipos_pre_sucursal (
    cod_sucursal  NUMBER NOT NULL,
    cod_t_prestam NUMBER NOT NULL,
    monto_presta NUMBER NOT NULL,
    fecha_mod      DATE,
    CONSTRAINT tipos_pre_sucursal_pk PRIMARY KEY ( cod_sucursal,cod_t_prestam ),
    CONSTRAINT tipos_prestamos_fk FOREIGN KEY ( cod_t_prestam )
        REFERENCES tipos_prestamos ( cod_prestamo ),
CONSTRAINT tipos_sucursales_fk FOREIGN KEY ( cod_sucursal )
        REFERENCES sucursales ( cod_sucursal )
);


CREATE TABLE prestamos (
    no_prestamo       NUMBER NOT NULL,
    id_cliente        NUMBER NOT NULL,
    cod_tipo_prestamo NUMBER NOT NULL,
    fecha_aprobado    DATE,
    monto_aprobado    NUMBER(15,2) DEFAULT 0,
    letra_mensual      NUMBER(15,2) DEFAULT 0,
    importe_pago      NUMBER(15,2) DEFAULT 0,
    fecha_pago        DATE,
    tasa_interes      NUMBER(2, 2) DEFAULT 0,
    saldo_acual       NUMBER(15, 2) DEFAULT 0,
    interes_pagado    NUMBER(15, 2) DEFAULT 0,
    fecha_mod         date,
    cod_sucursal      number,
    usuario           varchar2(50),
    CONSTRAINT prestamos_pk PRIMARY KEY ( id_cliente,cod_tipo_prestamo ),
    CONSTRAINT prestamos_clientes_fk FOREIGN KEY ( id_cliente )
        REFERENCES clientes ( id_cliente ),
    CONSTRAINT tipos_presta_fk FOREIGN KEY ( cod_tipo_prestamo )
        REFERENCES tipos_prestamos ( cod_prestamo )
);


CREATE TABLE transacpagos (
    id_transaccion   NUMBER NOT NULL,
    id_cliente     NUMBER NOT NULL,
    tipo_prestamo    NUMBER NOT NULL,
    cod_sucursal       NUMBER NOT NULL,
    fecha_transac    DATE,
    monto_pago       NUMBER(15, 2) DEFAULT 0,
    fecha_inserccion DATE,
    usuario          VARCHAR2(45),
    status             char(2);
    -- PAGADO, EN PROCESO, NO PAGADO
    constraint status_check CHECK(status in('P','EP', 'NP')),
    CONSTRAINT transacpagos_pk PRIMARY KEY ( id_transaccion ),
    CONSTRAINT transacpagos_prestamos_fk FOREIGN KEY ( id_cliente,tipo_prestamo )
        REFERENCES prestamos ( id_cliente,cod_tipo_prestamo ),
    CONSTRAINT transac_sucursales_fk FOREIGN KEY ( cod_sucursal )
        REFERENCES sucursales ( cod_sucursal )
);


---VISTA DE LOS PRESTAMOS--

CREATE VIEW VIEW_PRESTAMOS
AS select    pe.NO_PRESTAMO as "NO. PRESTAMO",c.CEDULA as "CEDULA",
c.NOMBRE1 as "NOMBRE",
     c.APELLIDO1 as "APELLIDO",
     tp.NOMBRE_PRESTAMO as "TIPO DEPRESTAMO",
     pe.MONTO_APROBADO as "MONTO APROBADO",
     pe.LETRA_MENSUAL as "LETRA MENSUAL",
     p.DESCRIPCION as "PROFESION"
 from    PROFESIONES p,
     PRESTAMOS pe,
     TIPOS_PRESTAMOS tp,
     CLIENTES c
     where c.id_cliente = pe.id_cliente and pe.TIPO_PRESTAMO = tp.COD_PRESTAMO and c.COD_PROFESION = p.ID_PROFESION
order by c.CEDULA ASC;
--TIPOS CORREOS
CREATE or REPLACE PROCEDURE Nuevo_tipoCorreo(
    p_Correo    IN tipos_correos.descripcion%TYPE)
IS
intSeqVal number(10);
BEGIN
    select sec_cod_correo.nextval into intSeqVal from dual;
    INSERT into TIPOS_CORREOS (cod_correo,descripcion)
    VALUES (intSeqVal,p_Correo);
    COMMIT;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El tipo de correo ya existe.');
END Nuevo_tipoCorreo;
/

--TIPOS PRESTAMOS
CREATE or REPLACE PROCEDURE Nuevo_tipoPrestamo(
    p_prestam    IN tipos_prestamos.nombre_prestamo%TYPE,
    p_interes    IN TIPOS_PRESTAMOS.TASA_INTERES%TYPE)
IS
intSeqVal number(10);
BEGIN
    select sec_cod_prestamo.nextval into intSeqVal from dual;
    INSERT into TIPOS_PRESTAMOS (cod_prestamo,nombre_prestamo,tasa_interes)
    VALUES (intSeqVal,p_prestam,p_interes);
    COMMIT;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El tipo de prestamo ya existe.');
END Nuevo_tipoPrestamo;
/

--TIPOS telefonos
CREATE or REPLACE PROCEDURE Nuevo_tipotelefonos(
    p_telefonos    IN tipos_telefonos.descripcion%TYPE)
IS
intSeqVal number(10);
BEGIN
    select sec_cod_telefono.nextval into intSeqVal from dual;
    INSERT into TIPOS_TELEFONOS (cod_telefono,descripcion)
    VALUES (intSeqVal,p_telefonos);
    COMMIT;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El tipo de telefono ya existe.');
END Nuevo_tipotelefonos;
/

--TIPOS profesion
CREATE or REPLACE PROCEDURE Nuevo_tipoprofesion(
    p_profesion    IN profesiones.descripcion%TYPE)
IS
intSeqVal number(10);
BEGIN
    select sec_id_profesion.nextval into intSeqVal from dual;
    INSERT into PROFESIONES(id_profesion,descripcion)
    VALUES (intSeqVal,p_profesion);
    COMMIT;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: La profesion ya existe.');
END Nuevo_tipoprofesion;
/

--Distritos
CREATE or REPLACE PROCEDURE NuevoDistrito(
    p_distrito    IN distritos.nombre%TYPE)
IS
intSeqVal number(10);
BEGIN
    select sec_cod_distrito.nextval into intSeqVal from dual;
    INSERT into DISTRITOS(cod_distrito,nombre)
    VALUES (intSeqVal,p_distrito);
    COMMIT;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El distrito ya existe.');
END NuevoDistrito;
/

--Provincias
CREATE or REPLACE PROCEDURE NuevaProvincia(
    p_provincia    IN provincias.nombre%TYPE)
IS
intSeqVal number(10);
BEGIN
    select sec_cod_provincia.nextval into intSeqVal from dual;
    INSERT into PROVINCIAS(cod_provincia,nombre)
    VALUES (intSeqVal,p_provincia);
    COMMIT;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: La provincia ya existe.');
END NuevaProvincia;
/

--sucursales
CREATE or REPLACE PROCEDURE NuevaSucursal(
    p_sucursal    IN SUCURSALES.nombre%TYPE)
IS
intSeqVal number(10);
v_sucursal VARCHAR2(100) := p_sucursal;
v_monto number := 0;
BEGIN

select sec_cod_sucursal.nextval into intSeqVal from dual;
    INSERT into SUCURSALES(COD_SUCURSAL,nombre,MONTO_PRESTAMO)
    VALUES (
        intSeqVal,
        v_sucursal,
        v_monto);

FOR v_counter IN 1..5 LOOP

    INSERT INTO TIPOS_PRE_SUCURSAL(
        COD_SUCURSAL,
        COD_T_PRESTAM,
        monto_prestamo,
        fecha_mod)
     VALUES(
        intSeqVal,
        v_counter,
        v_monto,
        to_date(sysdate,'DD-MM-YY')
    );
    COMMIT;
    END LOOP;
   
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: La sucursal ya existe.');
END NuevaSucursal;
/

CREATE OR REPLACE FUNCTION calcularEdadCliente(p_fecha date)
RETURN NUMBER IS
v_clienteEdad number(3);
v_fecha date := p_fecha;
BEGIN
  -- Necesitamos eso en años
  v_clienteEdad := (SYSDATE - v_fecha) / 365;

  RETURN v_clienteEdad;
 
  EXCEPTION
   WHEN ZERO_DIVIDE THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El tipo de correo ya existe.');
END calcularEdadCliente;
/


CREATE OR REPLACE PROCEDURE insertCliente(
    p_cedula    IN clientes.cedula%TYPE,
    p_Nombre    IN clientes.nombre1%TYPE,
    p_Apellido  IN clientes.apellido1%TYPE,
    p_fecha     IN clientes.fecha_nac%TYPE,
    p_sexo      IN clientes.SEXO%TYPE,
    p_profesion IN clientes.cod_profesion%TYPE,
    p_direccion IN clientes.direccion%TYPE,
    p_sucursal  IN clientes.cod_sucursal%TYPE)

IS
    intSeqVal number(10);
    v_edad number(3) := calcularEdadCliente(p_fecha);
BEGIN
    select SEC_ID_cliente.nextval into intSeqVal from dual;
INSERT into CLIENTES (id_cliente,
    cedula,
    nombre1,
    apellido1,
    fecha_nac,
    edad,
    sexo,
    cod_profesion,
    direccion,
    cod_sucursal);
VALUES (intSeqVal,
    p_cedula,
    p_nombre,
    p_apellido,
    to_date(p_fecha,'DD-MON-YY'),
    v_edad,
    p_sexo,
    p_profesion,
    p_direccion,
    p_sucursal);
    COMMIT;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El cliente ya existe.');
END insertCliente;
/

CREATE OR REPLACE PROCEDURE insertPrestamo(
    p_id_cliente            IN prestamos.id_cliente%TYPE,
    p_cod_tipo_prestamo     IN prestamos.cod_tipo_prestamo%TYPE,
    p_monto_aprobado        IN prestamos.monto_aprobado%TYPE,
    p_fecha_pago            IN prestamos.fecha_pago%TYPE,
    p_cuotas NUMBER;
    p_no_sucursal number;
)
IS
  v_cod_prestamo NUMBER := p_cod_tipo_prestamo;
  intSeqVal number(10);
  v_fecha date := SYSDATE;
  v_saldo := p_monto_aprobado;
  v_moto_prestamo number := v_monto_prestamo+v_saldo;
  v_interes NUMBER;
  v_importe number := 0;
BEGIN

--1--
  select sec_no_prestamo.nextval into intSeqVal from dual;
  SELECT tasa_interes INTO v_interes FROM TIPOS_PRESTAMOS WHERE cod_prestamo = v_cod_prestamo;
--2  
INSERT INTO PRESTAMOS(
  no_prestamo,    
  id_cliente,
  cod_tipo_prestamo,    
  fecha_aprobado,
  monto_aprobado,    
  letra_mensual,      
  importe_pago,
  fecha_pago,
  tasa_interes,
  saldo_actual,
  interes_pagado,
  fecha_mod,
  cod_sucursal,
  usuario);
VALUES (intSeqVal,
    p_no_prestamo,
    p_id_cliente,
    p_cod_tipo_prestamo,
    to_date(v_fecha,'DD-MM-YYY HH:MI:SS')
    p_monto_aprobado,
    p_letra_mensual,
    v_importe,
    to_date(p_fecha_pago, 'DD-MM-YYY'),
    v_interes,
    saldo,
    p_interes_pagado,
    to_date(v_fecha,'DD-MM-YYY HH:MI:SS'),
    p_no_sucursal,
    user,
    );

 --3  
--ACTUALIZACION DE LA TABLA SUCURSALES: MONTOS
SELECT monto_prestamo INTO v_monto_prestamo
    FROM TIPOS_PRE_SUCURSAL
    WHERE cod_sucursal = p_no_sucursal and cod_t_prestam = p_cod_tipo_prestamo;

--Actualizacion de la tabla relacion muchos a muchos de TIPO PRESTAMO Y SUCURSAL
UPDATE SET MONTO_PRESTAMO=v_monto_prestamo+v_monto_prestamos FROM TIPOS_PRE_SUCURSAL;
 
COMMIT;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El cliente ya existe.');
END insertPrestamo;
/

CREATE OR REPLACE PROCEDURE insertPagos(
 p_id_transaccion   IN transacpagos.id_transaccion %TYPE,  
    p_id_cliente      IN transacpagos.id_cliente %TYPE,
    p_tipo_prestamo    IN transacpagos.tipo_prestamo %TYPE,
    p_cod_sucursal     IN transacpagos.cod_sucursal %TYPE,
    p_fecha_transac    IN transacpagos.fecha_transac %TYPE,
    p_monto_pago       IN transacpagos.monto_pago %TYPE
)
IS
  intSeqVal number(10);
BEGIN
  select sec_id_transac.nextval into intSeqVal from dual;
INSERT INTO transacpagos(
    id_transaccion,    
    id_cliente,      
    tipo_prestamo,    
    cod_sucursal,    
    fecha_transac,    
    monto_pago,      
    fecha_inserccion,
    usuario        
);
VALUES(
  intSeqVal,
  id_transaccion,    
  id_cliente,      
  tipo_prestamo,    
  cod_sucursal,    
  SYSDATE,    
  monto_pago,      
  SYSDATE,
  USER);
COMMIT;

EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El cliente ya existe.');
END insertPagos;
/

-- Función de calcular interés
CREATE OR REPLACE FUNCTION calcularInteres(
    p_prestamo PRESTAMOS.monto_aprobado%TYPE,
    p_interes PRESTAMOS.tasa_interes%TYPE,
)
RETURN NUMBER IS
   V_interes_calculado NUMBER;
   v_prestamo NUMBER := p_prestamo;
   v_interes NUMBER := p_interes;
   BEGIN

   -- Interes calculado mediante el préstamo e interes
   V_interes_calculado := (v_prestamo * v_interes) ;
 
   RETURN V_interes_calculado;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El préstamo no ha sido encontrado.');

   END calcularInteres;
/

-- Función de disminuir préstamo

CREATE OR REPLACE FUNCTION disminuirPrestamo(
    p_monto_mensual IN PRESTAMOS.monto_aprobado%TYPE,
    p_monto_interes IN PRESTAMOS.interes_pagado%TYPE,
    p_monto_a_pagar IN PRESTAMOS.importe_pago%TYPE,
)
RETURN NUMBER IS
   V_monto_actual NUMBER;
   v_monto_mensual NUMBER := p_monto_mensual;
   v_monto_a_pagar NUMBER := p_monto_a_pagar;
   v_monto_interes NUMBER := p_monto_interes;
;
   BEGIN

   -- Interes calculado mediante el préstamo e interes
   IF v_monto_a_pagar - (v_monto_interes + v_monto_mensual) >= 0
   V_monto_actual = v_monto_a_pagar - (v_monto_interes + v_monto_mensual)  
   ELSE
    V_monto_actual = v_monto_a_pagar - v_monto_interes

    RETURN V_monto_actual
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       DBMS_OUTPUT.PUT_LINE('💣 Error: El monto insertado no ha sido calculado.');


   END disminuirPrestamo;
/



CREATE OR REPLACE PROCEDURE insertUpdate(
    p_monto_prestamo IN SUCURSALES.monto_prestamo%TYPE;
    p_saldo_actual IN PRESTAMOS.saldo_actual&TYPE;
)
BEGIN

    -- Aqui se implementaría el cursor
    CURSOR Pagos IS
    SELECT saldo_actual, monto_prestamo
    FROM p PRESTAMOS, s SUCURSALES

    -- Aqui iria la logica del update

   

END;
/
