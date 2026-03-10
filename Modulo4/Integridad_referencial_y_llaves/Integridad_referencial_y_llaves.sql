CREATE DATABASE bdejemploir;

use bdejemploir;

CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,       -- Clave primaria en la tabla Clientes
    Nombre NVARCHAR(100) NOT NULL
);

INSERT INTO Clientes (ClienteID, Nombre)
VALUES (1, 'Juan Pérez'),
       (2, 'María García'),
       (3, 'Carlos López');

CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY,        -- Clave primaria en la tabla Pedidos
    ClienteID INT,                   -- Clave foránea en la tabla Pedidos
    FechaPedido DATETIME,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)  -- Definimos la relación
);

INSERT INTO Pedidos (PedidoID, ClienteID, FechaPedido)
VALUES (101, 1, '2025-01-23'),
       (102, 1, '2025-01-24'),
       (103, 2, '2025-01-25'),
       (104, 3, '2025-01-26');

select * from pedidos;

/*
Configurar Acciones en la Integridad Referencial
-CASCADE .-Si se elimina o actualiza un registro en la tabla padre se propaga
           La accion en la tabla hija.
-SET NULL .-Si se elimina o actualiza un registro en la tabla padre la columna de 
            La Tabla Hija se establece como NULL
-NO ACTION o RESTRICT .-Impide la actualizacion o eliminacion si existen registros
            relacionados en la Tabla Hija.  

*/

select
    name
from
    sys.foreign_keys
where
    parent_object_id = OBJECT_ID('pedidos');
-- FK__Pedidos__Cliente__398D8EEE


/*
SELECT name
FROM sys.foreign_keys
WHERE parent_object_id=OBJECT_ID('PEDIDOS')
*/
ALTER TABLE PEDIDOS
DROP CONSTRAINT FK__Pedidos__Cliente__398D8EEE -- Eliminamos el Cosntraint

ALTER TABLE PEDIDOS
ADD CONSTRAINT FK_PEDIDOS_CLIENTES
FOREIGN KEY (CLIENTEID) REFERENCES CLIENTES(CLIENTEID)
ON DELETE CASCADE
ON UPDATE SET NULL

SELECT * FROM CLIENTES
SELECT * FROM PEDIDOS
DELETE FROM Clientes WHERE ClienteID=1 -- cascade lo hizo elimino td

UPDATE CLIENTES
SET CLIENTEID=99
WHERE ClienteID=2 -- quedo null

ALTER TABLE PEDIDOS
DROP CONSTRAINT FK_PEDIDOS_CLIENTES
ALTER TABLE PEDIDOS
ADD CONSTRAINT FK_PEDIDOS_CLIENTES
 FOREIGN KEY(CLIENTEID) REFERENCES CLIENTES(CLIENTEID)
 ON DELETE NO ACTION;

 DELETE FROM CLIENTES WHERE ClienteID=3 -- cumple
