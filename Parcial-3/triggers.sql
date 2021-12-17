-- Cutire, Fernando
CREATE OR REPLACE TRIGGER t_auditoria
AFTER INSERT ON PRESTAMOS
FOR EACH ROW
DECLARE
v_tipo_oper char;
v_tipo_trans number;
v_saldo_antig number;

BEGIN 

v_tipo_oper := 'I';
v_tipo_trans := 1;
v_saldo_antig := 0;


INSERT INTO AUDITORIA(ID_AUDITORIA,NO_CUENTA,ID_CLIENTE,id_tipo_ahorro,TIPO_OPERACION,TIPO_TRANSAC,TABLA,saldo_anterior,monto_deposito,saldo_final,USUARIO,fecha_transaccion)
VALUES(sec_cod_aut.nextval,:NEW.no_prestamo,:NEW.id_cliente,:NEW.cod_tipo_prestamo,v_tipo_oper,v_tipo_trans,'PRESTAMOS',v_saldo_antig,:new.letra_mensual,:new.saldo_actual,USER,SYSDATE);

END t_auditoria;
/

-- #2

CREATE OR REPLACE TRIGGER trigger_pres_sucursal
AFTER UPDATE ON PRESTAMOS
FOR EACH ROW
BEGIN
UPDATE 
    tipos_pre_sucursal 
SET 
    monto_presta = monto_presta - (:new.saldo_actual - :old.saldo_actual)
WHERE
(tipos_pre_sucursal = :new.cod_sucursal) and 
(tipos_pre_sucursal.cod_t_prestam = :new.cod_tipo_prestamo);

END trigger_pres_sucursal;
/

-- #3


CREATE OR REPLACE TRIGGER transa_auditoria_t
AFTER UPDATE ON PRESTAMOS
FOR EACH ROW
DECLARE
v_tipo_oper char;
v_saldo_antig number;
v_tipo_trans number;
BEGIN
v_tipo_oper := 'U';
v_saldo_antig := :old.saldo_actual;
IF(:old.saldo_actual = :new.saldo_actual) THEN
    v_tipo_trans := 1;
ELSE IF
    v_tipo_trans := 2;
END IF;
INSERT INTO AUDITORIA(ID_AUDITORIA,NO_CUENTA,ID_CLIENTE,id_tipo_ahorro,TIPO_OPERACION,TIPO_TRANSAC,TABLA,saldo_anterior,monto_deposito,saldo_final,USUARIO,fecha_transaccion)
VALUES(sec_cod_aut.nextval,:NEW.no_prestamo,:NEW.id_cliente,:NEW.cod_tipo_prestamo,v_tipo_oper,v_tipo_trans,'PRESTAMOS',v_saldo_antig,:new.letra_mensual,:new.saldo_actual,USER,SYSDATE);
END transa_auditoria_t;
/

-- #4

-- #5 View
CREATE VIEW Sucursal_Tipo_Prestamo AS
SELECT s.nombre AS Sucursal, tp.nombre_prestamo AS Tipo_Prestamo, sp.monto_presta as SucursalTipoPrestamox
FROM  tipos_pre_sucursal sp
INNER JOIN sucursales s ON sp.cod_sucursal = s.cod_sucursal
INNER JOIN tipos_prestamos tp ON sp.cod_t_prestam = tp.cod_prestamo
ORDER BY s.nombre DESC;