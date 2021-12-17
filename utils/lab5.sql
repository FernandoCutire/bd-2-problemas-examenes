set serveroutput on;
 
--TABLA COLABORADORES--
create table colaboradores (
   id_codcolaborador number not null,
   nombre varchar2(25) not null,
   apellido VARCHAR2(25)not NULL,
   cedula varchar2(12) not NULL,
   sexo char not NULL,
   fecha_nacimiento date not NULL,
   fecha_ingreso date not NULL,
   status char not NULL,
   salario_mensual number(15,2) DEFAULT 0,
   constraint n_cedula unique (cedula),
   constraint c_sexo CHECK (sexo in ('F','M')),
   constraint c_status CHECK (status in ('A', 'V', 'R')),
   constraint pk_colab_cod primary key (id_codcolaborador)
);
--TABLA SALARIO QUINCENAL--
CREATE TABLE salario_quincenal (
   id_salario NUMBER not null,
   id_codcolaborador number not NULL,
   fecha_pago date NOT NULL,
   salario_quincenal number(15,2) DEFAULT 0,
   seguro_social number(15,2) DEFAULT 0,
   seguro_educativo number(15,2) DEFAULT 0,
   salario_neto NUMBER(15,2) DEFAULT 0,
   constraint pk_id_salario primary key (id_salario),
   constraint fk_codcolaborador foreign key (id_codcolaborador)
       references colaboradores (id_codcolaborador)
);
 
--VISTA DE COLABORADORES Y PAGO QUINCENAL--
CREATE VIEW Salario_Quincenal_vista AS
SELECT
c.id_codcolaborador AS codigo,
CONCAT(CONCAT(c.nombre, ' ' ), c.apellido) AS colaborador,
c.salario_mensual,
sq.salario_quincenal, sq.seguro_social,
sq.seguro_educativo,
sq.salario_neto AS salario_neto
FROM colaboradores c
INNER JOIN salario_quincenal sq ON c.id_codcolaborador = sq.id_codcolaborador
WHERE status = 'A'
ORDER BY c.id_codcolaborador ASC;
 
--SECUENCIAS DE ID DE TABLAS COLABORADORES--
CREATE SEQUENCE sec_id_colaborador
INCREMENT BY 1
START WITH 1
MAXVALUE 99999
MINVALUE 1;
 
--SECUENCIA ID DE SALARIO_QUINCENAL
CREATE SEQUENCE sec_id_salario
INCREMENT BY 1
START WITH 1
MAXVALUE 99999
MINVALUE 1;

 CREATE TABLE SalarioQuincenal(
  sal_idregistro number not null,
  sal_idempleado number not null,
  sal_salquincenalbruto number(15,2),
  sal_seguroSocial number(15,2),
  sal_seguroEducativo number(15,2),
  sal_netoquincenal number(15,2),
  sal_fecha date,
  CONSTRAINT pk_salario_quincenal PRIMARY KEY (sal_idregistro)
);

-- PROCEDIMIENTO DE INSERCION DE USUARIO--
CREATE or REPLACE PROCEDURE insertNewColab(
   p_Nombre_Colab    IN colaboradores.nombre%TYPE,
   p_Apellido_Colab  IN colaboradores.apellido%TYPE,
   p_cedula_colab    IN colaboradores.cedula%TYPE,
   p_sexo_colab      IN COLABORADORES.SEXO%TYPE,
   p_fecha_nac       IN colaboradores.fecha_nacimiento%TYPE,
   p_Status_colab    IN colaboradores.status%TYPE,
   p_SalarioM_Colab  IN colaboradores.salario_mensual%TYPE)
IS
intSeqVal number(10);
v_fechaIn date;
BEGIN
   select SEC_ID_COLABORADOR.nextval into intSeqVal from dual;
   select SYSDATE into v_fechaIn from DUAL;
   INSERT into COLABORADORES (id_codcolaborador,nombre,apellido,cedula,sexo,
           fecha_nacimiento,fecha_ingreso,status,salario_mensual)
   VALUES (intSeqVal, p_Nombre_Colab, p_Apellido_Colab, p_cedula_colab, p_sexo_colab,
           to_date(p_fecha_nac,'DD-MON-YY'),v_fechaIn, p_Status_colab, p_SalarioM_Colab);
   COMMIT;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
      DBMS_OUTPUT.PUT_LINE('💣 Error: El usuario ya existe la tabla de colaboradores');
END;
/
-- PARAMETROS: NOMBRE,APELLIDO,CEDULA,SEXO,FECHA NACIMIENTO,STATUS,SALARIO
EXECUTE insertNewColab('GABRIEL','DIAZ','7-125-778','M','14-FEB-21','A',8000.00);
EXECUTE insertNewColab('gabriel','diaz','20-53-5198','M','01-OCT-00','A',5000);
EXECUTE insertNewColab('william','feng','8-977-446','M','07-OCT-00','A',5000);
EXECUTE insertNewColab('jorge','escobar','2-747-1772','M','04-AUG-00','A',5000);
EXECUTE insertNewColab('Esperanza','Ordonez','8-972-906','F','06-JUL-00','A',5000);
EXECUTE insertNewColab('Carol','Santo','8-910-123','F','14-FEB-90','V',4000);
 
-- FUNCIÓN CALCULAR SALARIO QUINCENAL
CREATE OR REPLACE FUNCTION Cal_salarioQuincenal (
       p_SalarioM_colab COLABORADORES.salario_mensual%TYPE)
  RETURN NUMBER IS
       V_SALARIO_QUINCENAL NUMBER;
       v_SalarioM_Colab NUMBER := p_SalarioM_Colab;
  BEGIN
     -- Salario quincenal
       V_SALARIO_QUINCENAL := v_SalarioM_Colab/2;
  RETURN V_SALARIO_QUINCENAL;
EXCEPTION
   WHEN ZERO_DIVIDE THEN
   DBMS_OUTPUT.PUT_LINE('División invalida');
END Cal_salarioQuincenal;
/
 
-- FUNCIÓN CALCULAR SEGURO EDUCATIVO
CREATE OR REPLACE FUNCTION Cal_seguroEducativo (
       p_SalarioM_colab COLABORADORES.salario_mensual%TYPE)
   RETURN NUMBER IS
       V_SEGURO_EDUCATIVO NUMBER;
       v_SalarioM_Colab NUMBER := p_SalarioM_Colab;
   BEGIN
  -- Seguro educativo
       V_SEGURO_EDUCATIVO := (v_SalarioM_Colab/2) * 0.0125;
   RETURN V_SEGURO_EDUCATIVO;
   EXCEPTION
   WHEN ZERO_DIVIDE THEN
   DBMS_OUTPUT.PUT_LINE('División invalida');
END Cal_seguroEducativo;
/
-- FUNCIÓN CALCULAR SEGURO SOCIAL
CREATE OR REPLACE FUNCTION Cal_seguroSocial (
  p_SalarioM_colab COLABORADORES.salario_mensual%TYPE)
  RETURN NUMBER IS
       V_SEGURO_SOCIAL NUMBER;
       v_SalarioM_Colab NUMBER := p_SalarioM_Colab;
  BEGIN  
  -- Seguro social
       V_SEGURO_SOCIAL := (v_SalarioM_Colab/2) * 0.0975;
  RETURN V_SEGURO_SOCIAL;
   EXCEPTION
   WHEN ZERO_DIVIDE THEN
   DBMS_OUTPUT.PUT_LINE('División invalida');
END Cal_seguroSocial;
/
 
-- FUNCION CALCULAR SALRIO NETO
CREATE OR REPLACE FUNCTION Cal_salarioNeto (
  p_SalarioM_colab COLABORADORES.salario_mensual%TYPE)
  RETURN NUMBER IS
  V_SALARIO_NETO NUMBER;
  v_SalarioM_Colab NUMBER := p_SalarioM_Colab;
  BEGIN
  -- Salario Neto
  V_SALARIO_NETO := (v_SalarioM_Colab/2) - (v_SalarioM_Colab/2 * 0.0975) - (v_SalarioM_Colab/2 * 0.0125);
  RETURN V_SALARIO_NETO;
  WHEN ZERO_DIVIDE THEN
   DBMS_OUTPUT.PUT_LINE('División invalida');
  END Cal_salarioNeto;
/
 
-- PROCEDIMIENTO: CALCULO DE NOMINA --
CREATE OR REPLACE PROCEDURE Nomina(
   P_FECHAPAGO DATE)
  AS
  v_Id_Colab                       colaboradores.id_codcolaborador%TYPE;
  v_SalarioM_Colab                 colaboradores.salario_mensual%TYPE;
  v_Status_colab                   colaboradores.status%TYPE := 'A';
  v_intSeqVal NUMBER;
 
  CURSOR c_Salarios IS
  SELECT id_codcolaborador,
  salario_mensual
  FROM COLABORADORES
  WHERE status = v_Status_colab;
  
BEGIN
  -- Este código se emplea los días quince y treinta de cada mes.
  -- Si se quiere probar el código, cambiar los valores a el día en la que usted se encuentra
  -- Por ejemplo: Si usted lo prueba el 6 de octubre, colocar 06 en el date
  -- Ejem: IF to_char(CURRENT_DATE, 'dd') = '06' OR to_char(CURRENT_DATE, 'dd') = '30' THEN
  IF to_char(P_FECHAPAGO, 'dd') = '15' OR to_char(P_FECHAPAGO, 'dd') = '30' THEN
      OPEN c_Salarios;
      LOOP
      FETCH c_Salarios INTO
      v_Id_Colab,
      v_SalarioM_Colab;
      EXIT
      WHEN c_salarios%NOTFOUND;
      select SEC_ID_SALARIO.nextval into v_intSeqVal from dual;
      INSERT INTO salario_quincenal (
          id_salario,id_codcolaborador, fecha_pago, salario_quincenal,
          seguro_social, seguro_educativo, salario_neto)
      VALUES (
          v_intSeqVal,
          v_Id_Colab,
          SYSDATE(),
          Cal_salarioQuincenal(v_SalarioM_Colab),
          Cal_seguroEducativo(v_SalarioM_Colab),
          Cal_seguroSocial(v_SalarioM_Colab),
          Cal_salarioNeto(v_SalarioM_Colab)
      );
     
      END LOOP;
      CLOSE c_Salarios;
      COMMIT;
  ELSE
      DBMS_OUTPUT.PUT_LINE('💣 Error: Hoy no es día de pago.');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('💣 Error: Este ID no existe.');
END NOMINA;
/
 
 
--LLAMADA AL PROCEDIMIENTO DE PAGO QUINCENAL
DECLARE
   V_FECHA_PAGO DATE;
BEGIN
   V_FECHA_PAGO := '&FECHA';
   NOMINA(V_FECHA_PAGO);
   DBMS_OUTPUT.PUT_LINE('Pago de nómina quincenal realizado correctamente');
END;
/
