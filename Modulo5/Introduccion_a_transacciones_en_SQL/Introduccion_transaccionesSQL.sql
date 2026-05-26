CREATE DATABASE BANCOS;
USE BANCOS;

CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,           -- Identificador único de la cuenta
    AccountHolder VARCHAR(100),          -- Nombre del titular de la cuenta
    Balance DECIMAL(18, 2)              -- Saldo disponible en la cuenta
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY,   -- Identificador único de la transacción
    FromAccountID INT,                        -- Cuenta desde la cual se transfiere dinero
    ToAccountID INT,                          -- Cuenta hacia la cual se transfiere dinero
    Amount DECIMAL(18, 2),                    -- Monto transferido
    TransactionDate DATETIME DEFAULT GETDATE(),  -- Fecha y hora de la transacción
    Status VARCHAR(20) DEFAULT 'Pending',     -- Estado de la transacción (Pendiente, Completada, Fallida)
    FOREIGN KEY (FromAccountID) REFERENCES Accounts(AccountID),  -- Relación con la cuenta origen
    FOREIGN KEY (ToAccountID) REFERENCES Accounts(AccountID)    -- Relación con la cuenta destino
);

-- Insertamos datos en la tabla Accounts
INSERT INTO Accounts (AccountID, AccountHolder, Balance)
VALUES 
    (1, 'Juan Pérez', 5000.00),  -- Cuenta de Juan Pérez con $5000
    (2, 'Ana García', 3000.00);  -- Cuenta de Ana García con $3000

BEGIN TRANSACTION  --Iniciamos la Transaccion
  BEGIN TRY 
    UPDATE Accounts
	SET Balance = Balance -1000 --Restar 1000 de la cuenta de juan perez
	WHERE AccountID=1 AND Balance>=1000 --Solo si hay suficente saldo

	--Verificamos si se afectaran filas en la cuenta de Juan perez
	IF @@ROWCOUNT = 0 -- Hay filas afectadas?, hay
	BEGIN
	  THROW 50000 , 'Saldo Insuficiente en la cuenta de Juan perez',1; --Error Personalizado
    END
	--Acredito el monto en la cuenta de destino (Ana Garcia)
	UPDATE Accounts
	SET Balance = Balance + 1000 --Añadir 1000 a la cuenta de Ana
	WHERE AccountID=2
	--Registramos la transaccion en la tabla Transacciones
	INSERT INTO Transactions(FromAccountID,ToAccountID,Amount,Status)
	VALUES(1,2,1000,'Completed');
	--Confirmamos al Transaccion
	COMMIT TRANSACTION
	PRINT 'Trasferencia completada con exito'
END TRY
BEGIN CATCH
    --SI OCURRE UN ERROR REVERTIMOS TODOS LOS CAMBIOS
	ROLLBACK TRANSACTION
	PRINT 'ERROR OCURRIDO TRANSACCION REVERTIDA'
	PRINT ERROR_MESSAGE(); --Mostramos el Mensaje de error
END CATCH;

SELECT * FROM Accounts
SELECT * FROM Transactions

/*
Escenario
-Deducir un monto de una cuenta
-Registrar Transferencia entre cuentas
-Aumentar el saldo de otra cuenta como bonificacion
-Punto de Control : Revertir solo los cambios realizados despues de ese punto.
*/
BEGIN TRANSACTION

BEGIN TRY
	--Paso 1: Deducir un monto de la cuenta de Juan perez
	UPDATE Accounts
	SET Balance = Balance - 500 --Deducitr 500
	WHERE AccountID=1 AND Balance >=500
	--Aseguramos que la operacion afecta la fila
	IF @@ROWCOUNT =0
	BEGIN
		THROW 50001,'Saldo Insuficiente en la cuenta de Juan Perez',1;
	END
	--Creamos UN Punto de Control despues de la Primera Operacion
	CHECKPOINT;
	--Paso 2: Registrar la Transferencia en la tabla Transactions
	INSERT INTO Transactions(FromAccountID,ToAccountID,Amount,Status)
	VALUES(1,2,500,'Pending')
	--Paso 3:Aumentar el saldo en la cuenta de destino
	UPDATE Accounts
	SET Balance=Balance+500
	WHERE AccountID=2
	--Actualizar el estado de la transaccion
	UPDATE Transactions
	SET Status='Completed'
	WHERE FromAccountID = 1 AND ToAccountID = 2 AND Amount=500
	COMMIT TRANSACTION;
	PRINT 'Operaciones completadas con exito'
END TRY
BEGIN CATCH
	PRINT 'ERROR OCURRIDO REVERTIENDO LA TRANSACCION PARCIAL'
	PRINT ERROR_MESSAGE()
	ROLLBACK TRANSACTION;
END CATCH;

SELECT * FROM Accounts
SELECT * FROM Transactions
