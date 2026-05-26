create database bdtienda2;
use bdtienda2;

Create Table Productos(
	ID INT PRIMARY KEY IDENTITY(1,1),
	Nombre Varchar(100),
	Precio Decimal(10,2),
	Sttock Int);

Create Table Ventas(
	ID INT Primary Key IDENTITY(1,1),
	ProductoID INT,
	Cantidad INT,
	Fecha DATETIME DEFAULT GETDATE(),
	Foreign Key (ProductoID) REFERENCES Productos(ID))

INSERT INTO Productos (Nombre,Precio,Sttock) Values
	('Laptop',1200.10,10),
	('Mouse',25.99,50),
	('Teclado',45.00,30)
SELECT * FROM Productos

INSERT INTO Ventas(ProductoID,Cantidad)Values
	(1,2),
	(2,5)
SELECT * FROM Ventas

/*
 Concurrencia.- Ocurre cuando varios usarios intentan acceder
 y modificar la BD al mismo tiempo.
*/

/*
Bloqueo con Begin Transaction y Lock
-Evitar que otro usuario modifique un producto 
 mientras actualizamos su stock
*/
/*
Usuario Vendedor 1
*/
BEGIN TRANSACTION;
	UPDATE Productos SET Sttock=Sttock-1 where id=1
	--Simulamos que dejamos la transaccion abierta por un tiempo
	WAITFOR DELAY '00:00:10'; --Esperamos 10 Segundos
	COMMIT;

/*
Bloqueo Explicito  con TABLOCKX
	Bloquear una tabla completamente para evitar cualquier modificacion 
	conncurrente para esto usamos.
*/
BEGIN TRANSACTION
 SELECT * FROM Productos WITH(TABLOCKX)
 --Ahora Nadie mas puede modificar la tabla hasta que termine la transaccion
 WAITFOR DELAY '00:00:10';
 COMMIT;

/*
Control de versiones con un campo RowVersion
*/
ALTER TABLE Productos ADD RowVersion ROWVERSION;

/*
LOCK  WITH(UPDLOCK),TABLOCK,ROWLOKC, ETC
UNLOCK 
*/

/*
Bloquear un producto mientras actualizamos su stock 
podemos usar UPDLOCK
*/

BEGIN TRANSACTION
	SELECT * FROM Productos WITH(UPDLOCK) WHERE ID=1;
	WAITFOR DELAY '00:00:10' --Simular una operacion larga
	UPDATE Productos SET Sttock=Sttock-1 WHERE ID=1;
COMMIT;
