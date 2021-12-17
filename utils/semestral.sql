/* Cutire, Fernando */

CREATE TABLE Empleados (
  emp_idempleado number not null,
  emp_nombre varchar2(45),
  emp_apellido  varchar2(45),
  emp_sexo char,
  emp_fnacimiento date,
  emp_salarioMensual number(15,2),
  emp_fecha_ingreso date,
  emp_status char,
  CONSTRAINT pk_empleados PRIMARY KEY (emp_idempleado),
  constraint emp_status CHECK (emp_status in ('A','I', 'E')),
  constraint emp_sexo CHECK (emp_sexo in ('M','F'))
);

CREATE TABLE SalarioQuincenal(
  sal_idregistro number not null,
  sal_idempleado number not null,
  sal_salquincenalbruto number(15,2),
  sal_seguroSocial number(15,2),
  sal_seguroEducativo number(15,2),
  sal_netoquincenal number(15,2),
  sal_fecha date,
  CONSTRAINT pk_salario_quincenal PRIMARY KEY (sal_idregistro),
  CONSTRAINT fk_salario_idempleado FOREIGN KEY (sal_idempleado)
    REFERENCES EMPLEADOS (emp_idempleado)
);

CREATE TABLE AUDITORIA(
  aud_idtransaccion number not null,
  aud_tabla_afectada varchar2(20),
  aud_tipo_operacion char,
  aud_idempleado  number,
  aud_salbrutoqicenal number(15,2),
  aud_netoquincenal number(15,2),
  aud_usuario varchar2(20),
  aud_fecha date,
  CONSTRAINT pk_auditoria PRIMARY KEY (aud_idtransaccion)
);

-- A
CREATE OR REPLACE FUNCTION Cal_seguroSocial (
  p_SalarioM_colab Empleados.EMP_SALARIOMENSUAL%TYPE)
  RETURN NUMBER IS
       V_SEGURO_SOCIAL NUMBER;
       v_SalarioM_Colab NUMBER := p_SalarioM_Colab;
  BEGIN  
  -- Seguro social
       V_SEGURO_SOCIAL := (v_SalarioM_Colab/2) * 0.0975;
  RETURN V_SEGURO_SOCIAL;
   EXCEPTION
   WHEN ZERO_DIVIDE THEN
   DBMS_OUTPUT.PUT_LINE('Error: División invalida');
END Cal_seguroSocial;
/

CREATE OR REPLACE FUNCTION Cal_seguroEducativo (
       p_SalarioM_colab Empleados.EMP_SALARIOMENSUAL%TYPE)
   RETURN NUMBER IS
       V_SEGURO_EDUCATIVO NUMBER;
       v_SalarioM_Colab NUMBER := p_SalarioM_Colab;
   BEGIN
  -- Seguro educativo
   V_SEGURO_EDUCATIVO := (v_SalarioM_Colab/2) * 0.0125;
   RETURN V_SEGURO_EDUCATIVO;
   EXCEPTION
   WHEN ZERO_DIVIDE THEN
   DBMS_OUTPUT.PUT_LINE('Error: División invalida');
END Cal_seguroEducativo;
/

CREATE OR REPLACE FUNCTION Cal_salarioNeto (
  p_SalarioM_colab EMPLEADOS.EMP_SALARIOMENSUAL%TYPE)
  RETURN NUMBER IS
  V_SALARIO_NETO NUMBER;
  v_SalarioM_Colab NUMBER := p_SalarioM_Colab;
  BEGIN
  -- Salario Neto
  V_SALARIO_NETO := (v_SalarioM_Colab/2) - (v_SalarioM_Colab/2 * 0.0975) - (v_SalarioM_Colab/2 * 0.0125);
  RETURN V_SALARIO_NETO;
  EXCEPTION
  WHEN ZERO_DIVIDE THEN
   DBMS_OUTPUT.PUT_LINE('División invalida');
  END Cal_salarioNeto;
/

CREATE SEQUENCE sec_id_empleado
INCREMENT BY 1
START WITH 1
MAXVALUE 99999
MINVALUE 1;

CREATE OR REPLACE PROCEDURE insertSalarioQuincenal(
  p_sal_idregistro IN SalarioQuincenal.sal_idregistro%TYPE,
  p_sal_idempleado IN SalarioQuincenal.sal_idempleado%TYPE,
  p_sal_salquincenalbruto IN SalarioQuincenal.sal_salquincenalbruto%TYPE,
  p_sal_seguroSocial IN SalarioQuincenal.sal_seguroSocial%TYPE,
  p_sal_seguroEducativo IN SalarioQuincenal.sal_seguroEducativo%TYPE,
  p_sal_netoquincenal IN SalarioQuincenal.sal_netoquincenal%TYPE,
  p_sal_fecha IN SalarioQuincenal.sal_fecha%TYPE)
IS 
intSeqVal number(10);
v_fechaIn date;
BEGIN
 select sec_id_empleado.nextval into intSeqVal from dual;
   select SYSDATE into v_fechaIn from DUAL;
   INSERT into SalarioQuincenal (sal_idregistro,sal_idempleado,sal_salquincenalbruto,sal_seguroSocial,sal_seguroEducativo,sal_netoquincenal,sal_fecha)
   VALUES (intSeqVal, p_sal_idregistro, p_sal_idempleado, p_sal_salquincenalbruto, p_sal_seguroSocial,p_sal_seguroEducativo,p_sal_fecha);
   COMMIT;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
      DBMS_OUTPUT.PUT_LINE('💣 Error: El salario ya existe la tabla de SalarioQuincenal');
END insertSalarioQuincenal;
/




CREATE VIEW EMPLEADO_GENERAL AS
SELECT em.emp_idempleado AS no_empleado, em.emp_nombre AS Nombre, 
em.emp_apellido AS Apellido, em.emp_salarioMensual AS Salario Mensual Bruto, 
sq.sal_salquincenalbruto AS Salario Quincenal Bruto,
sq.sal_seguroSocial AS Seguro Social, sq.sal_seguroEducativo AS Seguro Educativo, sq.sal_netoquincenal AS Salario Neto Quincenal
FROM Empleados em 
INNER JOIN SalarioQuincenal sq ON em.emp_idempleado = sq.sal_idempleado 
WHERE status = 'A'
ORDER BY em.emp_idempleado ASC;


CREATE SEQUENCE sec_cod_aut
INCREMENT BY 1
START WITH 1
MAXVALUE 99999
MINVALUE 1;

CREATE OR REPLACE TRIGGER t_auditoria
AFTER INSERT ON SalarioQuincenal
FOR EACH ROW
DECLARE
v_tabla_afectada varchar2(45);
v_tipo_oper char;
BEGIN
v_tabla_afectada := 'SALARIO_QUINCENAL';
v_tipo_oper := 'I';
INSERT INTO AUDITORIA(aud_idtransaccion,aud_tabla_afectada,aud_tipo_operacion,aud_idempleado,aud_salbrutoqicenal,aud_netoquincenal,aud_usuario,aud_fecha)
VALUES(sec_cod_aut.nextval, v_tabla_afectada,v_tipo_oper,:new.sal_idempleado,:new.sal_salquincenalbruto,:new.sal_netoquincenal,USER,SYSDATE);
END t_auditoria;
/