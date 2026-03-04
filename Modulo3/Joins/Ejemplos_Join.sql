/*
Para esta ocasión veremos los diferentes tipos de JOIN en SQL Server.
En este ejemplo crearemos una base de datos de una Tienda Virtual para demostrar
cómo funcionan las relaciones entre tablas y los distintos tipos de combinaciones.
*/

create database TiendaVirtual;
go
use TiendaVirtual;
go

/*
Creación de tabla Clientes
Almacena la información básica de los clientes de la tienda
*/
create table Clientes(
	ClienteID int identity(1,1),
	NombreCliente nvarchar(50),
	EmailCliente nvarchar(70),
	TelefonoCliente nvarchar(15),
	constraint PK_ClienteID primary key (ClienteID)
);
go

/*
Creación de tabla Productos
Contiene el catálogo de productos disponibles en la tienda
*/
create table Productos(
	ProductoID int identity(1,1),
	NombreProducto nvarchar(50),
	PrecioProducto decimal(10,2),
	StockProducto int,
	constraint PK_ProductoId primary key (ProductoID)
);
go

/*
Creación de tabla Pedidos (tabla intermedia)
Esta tabla resuelve la relación muchos a muchos entre Clientes y Productos
Un cliente puede tener muchos pedidos y un producto puede estar en muchos pedidos
Las foreign keys garantizan la integridad referencial
*/
create table pedidos(
 PedidosID int identity(1,1),
 ClienteID int,
 ProductoID int,
 CantidadPedido int,
 FechaPedido datetime,
 constraint FK_ClienteID Foreign key (ClienteID) references Clientes(ClienteID),
 constraint FK_ProductoID Foreign key (ProductoID) references Productos(ProductoID)
);

-- Cambiamos el nombre de la tabla para mantener consistencia en SQL Server
exec sp_rename 'pedidos','Pedidos';

-- Inserción de datos de ejemplo
-- Primero, agregamos clientes a la tabla
INSERT INTO Clientes (NombreCliente, EmailCliente, TelefonoCliente)
VALUES 
('Juan Pérez', 'juan.perez@example.com', '555-1234'),
('Ana García', 'ana.garcia@example.com', '555-5678'),
('Carlos López', 'carlos.lopez@example.com', '555-9876');

-- Agregamos un cliente adicional que no realizará pedidos (para demostrar JOINs)
INSERT INTO Clientes (NombreCliente, EmailCliente, TelefonoCliente)
VALUES 
('Armando Ruiz', 'aruiz@example.com', '9345-134');

-- Verificamos los clientes insertados
select * from Clientes;

-- Insertamos productos en el catálogo
INSERT INTO Productos (NombreProducto, PrecioProducto, StockProducto)
VALUES 
('Laptop Dell XPS', 1200.00, 10),
('Mouse Inalámbrico Logitech', 25.00, 50),
('Teclado Mecánico Razer', 100.00, 30);

-- Agregamos un producto adicional que no tendrá pedidos (para demostrar JOINs)
INSERT INTO Productos (NombreProducto, PrecioProducto, StockProducto)
VALUES 
('Teclado Microsoft', 1200.00, 10);

-- Insertamos pedidos con clientes existentes
INSERT INTO Pedidos (ClienteID, ProductoID, CantidadPedido, FechaPedido)
VALUES 
(1, 1, 1, '2024-11-01'), -- Juan Pérez compra una Laptop
(2, 2, 3, '2024-11-02'), -- Ana García compra 3 Mouse
(3, 3, 2, '2024-11-03'); -- Carlos López compra 2 Teclados

-- Insertamos un pedido sin cliente asociado (ClienteID NULL)
-- Esto demuestra la importancia de los diferentes tipos de JOIN
INSERT INTO Pedidos (ProductoID, CantidadPedido, FechaPedido)
VALUES 
(1, 1, '2024-11-01');

/*
=============================================================================
TIPOS DE JOIN EN SQL SERVER
=============================================================================

A continuación se presentan los diferentes tipos de JOIN con ejemplos prácticos
basados en los datos insertados anteriormente.
=============================================================================
*/

/*
INNER JOIN
- Devuelve únicamente las filas que tienen correspondencia en ambas tablas
- Si no existe relación entre los registros, se excluyen del resultado
- Es el tipo de JOIN más utilizado y el que mejor rendimiento ofrece
- Ideal para obtener datos completos y consistentes donde todas las relaciones existen

Ejemplo: Obtener todos los pedidos que tienen cliente Y producto válidos
*/
select
	p.PedidosID,
	c.NombreCliente,
	po.NombreProducto,
	p.CantidadPedido,
	p.FechaPedido
from
	pedidos p
inner join
	Clientes c on p.ClienteID = c.ClienteID
inner join
	Productos po on p.ProductoID = po.ProductoID;

-- Nota: El pedido con ClienteID NULL queda excluido del resultado

/*
LEFT JOIN (o LEFT OUTER JOIN)
- Devuelve TODOS los registros de la tabla izquierda (la primera que se menciona)
- Incluye los registros relacionados de la tabla derecha cuando existen
- Cuando no hay coincidencia, los campos de la tabla derecha aparecen como NULL
- Útil para encontrar registros "huérfanos" o para reportes que requieren totales
  incluyendo elementos sin relación

Ejemplo: Mostrar todos los pedidos, incluso aquellos sin cliente asignado
*/
select
	p.PedidosID,
	p.CantidadPedido,
	c.NombreCliente as Nombre
from
	pedidos p
left join
	Clientes c on c.ClienteID = p.ClienteID;

/*
En el resultado anterior, el PedidoID 4 aparece con NULL en NombreCliente
Esto indica que es un pedido sin cliente asociado, lo cual podría ser un
error en la integridad de los datos o un pedido realizado por un cliente
no registrado (venta mostrador, por ejemplo)
*/

/*
RIGHT JOIN (o RIGHT OUTER JOIN)
- Es el complemento del LEFT JOIN
- Devuelve TODOS los registros de la tabla derecha
- Incluye los registros relacionados de la tabla izquierda cuando existen
- Muchos desarrolladores prefieren usar siempre LEFT JOIN por consistencia,
  reordenando las tablas según sea necesario

Ejemplo: Mostrar todos los productos, incluso aquellos que nunca han sido pedidos
*/
select
	po.NombreProducto,
	p.CantidadPedido
from
	pedidos p
right join 
	Productos po on p.ProductoID = po.ProductoID;

/*
En este resultado, el Teclado Microsoft aparece con NULL en CantidadPedido
Esto indica que es un producto que está en el catálogo pero nunca se ha vendido,
lo cual puede ser útil para análisis de inventario o rotación de productos
*/

/*
FULL OUTER JOIN
- Combina los resultados de LEFT JOIN y RIGHT JOIN
- Devuelve TODOS los registros de ambas tablas, tengan o no relación
- Los valores sin relación se completan con NULL en la tabla correspondiente
- Es el tipo de JOIN menos utilizado pero muy valioso para:
  * Auditorías completas de datos
  * Detección de datos huérfanos en ambas direcciones
  * Reportes de integridad referencial
  * Identificar discrepancias entre tablas relacionadas

Ejemplo: Mostrar todos los clientes y todos los productos en un solo reporte,
         junto con los pedidos existentes
*/
select
	p.PedidosID,
	c.NombreCliente as Nombre,
	po.NombreProducto as Producto,
	p.CantidadPedido as Cantidad,
	p.FechaPedido as Fecha
from
	pedidos p
full outer join
	Clientes c on c.ClienteID = p.ClienteID
full outer join
	Productos po on po.ProductoID = p.ProductoID;

/*
=============================================================================
ANÁLISIS DE RESULTADOS DEL FULL OUTER JOIN
=============================================================================

El resultado mostrará diferentes categorías de registros:

1. RELACIONES COMPLETAS (Pedidos con cliente y producto)
   - PedidosID 1, 2, 3: Tienen toda la información

2. PEDIDOS HUÉRFANOS (Sin cliente pero con producto)
   - PedidosID 4: Tiene producto pero no cliente (problema de integridad)

3. CLIENTES INACTIVOS (Sin pedidos)
   - Armando Ruiz: Cliente registrado pero sin compras

4. PRODUCTOS SIN VENTAS (En catálogo pero no pedidos)
   - Teclado Microsoft: Producto disponible pero sin demanda

=============================================================================
RESUMEN COMPARATIVO DE JOINs
=============================================================================

+----------------+----------------------------------+---------------------------+
| Tipo de JOIN   | Registros incluidos              | Uso típico                |
+----------------+----------------------------------+---------------------------+
| INNER JOIN     | Solo los que coinciden           | Consultas estándar        |
|                | en ambas tablas                  | donde todas las           |
|                |                                  | relaciones deben existir  |
+----------------+----------------------------------+---------------------------+
| LEFT JOIN      | Todos de izquierda +             | Reportes que necesitan    |
|                | coincidencias de derecha         | incluir todo de una       |
|                |                                  | tabla principal           |
+----------------+----------------------------------+---------------------------+
| RIGHT JOIN     | Todos de derecha +               | Similar a LEFT JOIN       |
|                | coincidencias de izquierda       | pero con tabla            |
|                |                                  | principal a la derecha    |
+----------------+----------------------------------+---------------------------+
| FULL OUTER JOIN| Todos de ambas tablas            | Auditorías, detección     |
|                |                                  | de datos huérfanos,       |
|                |                                  | análisis completo         |
+----------------+----------------------------------+---------------------------+

=============================================================================
RECOMENDACIONES FINALES
=============================================================================

- Los alias (p, c, po) hacen el código más legible y fácil de mantener
- Siempre especificar el tipo de JOIN explícitamente (INNER, LEFT, etc.)
- Indexar las columnas utilizadas en las condiciones JOIN para optimizar
- Verificar que las condiciones de JOIN sean lógicamente correctas
- Probar con datos de ejemplo pequeños antes de ejecutar en producción
- Documentar los JOIN complejos para facilitar el mantenimiento futuro
=============================================================================
*/