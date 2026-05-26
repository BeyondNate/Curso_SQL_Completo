/*
PROPIEDADES ACID
================
1.-ATOMICIDAD .-Una Transaccion es atómica  si se ejecuta completamente o no se ejecuta en absoluto. Si una parte
falla , todas las operaciones de la transaccion deben revertirse

*/

CREATE DATABASE BDbancos
use BDbancos
CREATE TABLE Cuentas (
Cuenta_id varchar(10) primary key,
balance DECIMAL(10,2) not null check (balance >=0))

insert into cuentas (Cuenta_id,balance) 
VALUES ('A',500.00),
       ('B',300.00)

SELECT * FROM CUENTAS      


BEGIN TRANSACTION;
--RESTAR DE LA CUENTA "A"
UPDATE cuentas
SET BALANCE = BALANCE - 100
WHERE Cuenta_id='A'

--SUMAR A LA CUENTA "B"
UPDATE cuentas
SET BALANCE = BALANCE + 100
WHERE Cuenta_id='B'

--CONFIRMAR LOS CAMBIOS
COMMIT;

--SI OCURRE UN ERROR DESHACER TODO
ROLLBACK
END

/*
PROPIEDADES ACID
================
2.-Consistencia .- Una Transaccion lleva la BD de un estado consistente a otro. Esto Significa que las reglas 
y restrinciones de la bd (como claves foraneas, restrinciones UNIQUE(no deben violarse) 

*/
BEGIN TRANSACTION;
--VERIFICAR QUE LA CUENTA A tiene suficientes saldo
IF (SELECT balance FROM Cuentas WHERE Cuenta_id='A') >=100
BEGIN
  --RESTAR DE LA CUENTA A
  UPDATE Cuentas
  SET balance = balance - 100
  WHERE Cuenta_id = 'A';

  --Sumar a la cuenta B
  UPDATE Cuentas
  SET balance = balance + 100
  WHERE Cuenta_id = 'B'

  COMMIT;
END
ELSE
BEGIN
 PRINT 'Saldo insuficiente'
 ROLLBACK;
END;

SELECT * FROM CUENTAS  

/*
PROPIEDADES ACID
================
3.-Aislamiento .- Las Transacciones deben ejecutarse como sifueran independientes entre si. El resultado de una 
Transaccion no debe verse afectado por otras que se estan ejecutando al mismo tiempo.

-Niveles de Aislamiento
 - Read Uncommitted . Permite LEER datos no confirmados.
 - Read Comitted .-Solo Permite LEER datos confirmados.
 - Repeteable Read .- Bloque lecturas concurrentes.
 - Serializable . Asegura el mas alto nivel de aislamiento.

*/
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION
IF (SELECT balance FROM Cuentas WHERE Cuenta_id='A')>=100
BEGIN
	UPDATE Cuentas
	SET balance = balance -100
	WHERE Cuenta_id = 'A';

	UPDATE Cuentas
	SET balance = balance + 100
	WHERE Cuenta_id=  'b';
	COMMIT;
	PRINT 'Transacciion completadas existosamente' 
END
ELSE
BEGIN
	PRINT 'Error Saldo Insuficiente'
	ROLLBACK
END

/*
PROPIEDADES ACID
================
4.-Durabilidad .- Una vez que una Transaccion se confirma (COMMIT) los cambios son permantes , incluso si ocurre un 
fallo en el sistema
*/
