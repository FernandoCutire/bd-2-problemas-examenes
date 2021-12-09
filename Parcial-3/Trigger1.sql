CREATE OR REPLACE TRIGGER Insert_Auditoria
After Insert or update
On prestamos
For EACH ROW

DECLARE

BEGIN

IF Inserting Then
Insert into Auditoria (id_auditoria, no_prestamo, id_cliente, id_tipo_prestamo, tipo_operacion, tipo_transac, tabla, saldo_anterior, monto_prestamo, saldo_final, usuario, fecha_transaccion) 
    VALUES (sec_cod_aut.nextval,:new.no_prestamo, :new.id_cliente, :new.cod_tipo_prestamo, 'I', 1, 'prestamos', :new.saldo_actual, :new.saldo_actual,:new.saldo_actual, user, sysdate);

IF UPDATING THEN
Insert into Auditoria (id_auditoria, no_prestamo, id_cliente, id_tipo_prestamo, tipo_operacion, tipo_transac, tabla, saldo_anterior, monto_prestamo, saldo_final, usuario, fecha_transaccion) 
    VALUES (sec_cod_aut.nextval,:new.no_prestamo, :new.id_cliente, :new.cod_tipo_prestamo, 'I', 1, 'prestamos', :old.saldo_actual, :new.saldo_actual,:new.saldo_actual, user, sysdate);

ELSE
Insert into Auditoria (id_auditoria, no_prestamo, id_cliente, id_tipo_prestamo, tipo_operacion, tipo_transac, tabla, saldo_anterior, monto_prestamo, saldo_final, usuario, fecha_transaccion) 
    VALUES (sec_cod_aut.nextval,:new.no_prestamo, :new.id_cliente, :new.cod_tipo_prestamo, 'I', 2, 'prestamos', :old.saldo_actual, :old.saldo_actual,:new.saldo_actual, user, sysdate);

    END IF;
END IF;

END Insert_Auditoria;
/