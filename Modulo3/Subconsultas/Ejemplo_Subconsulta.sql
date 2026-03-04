-- Seguimos usando la base de datos TiendaVirtual, base creada en la clase de los JOIN
/*
SUBCONSULTAS (SUBQUERIES)
-- Es una consulta dentro de otra consulta
-- Las usamos para calcular valores o filtrar datos que la consulta principal necesita
-- Se ejecuta primero la subconsulta y luego la consulta principal (en subconsultas NO correlacionadas)
*/
USE TiendaVirtual;

SELECT * FROM pedidos;

-- EJEMPLO 1: Subconsulta básica (NO correlacionada)
-- Encontrar los pedidos que se realizaron en la fecha más reciente
SELECT
	c.NombreCliente,
	p.FechaPedido
FROM
	pedidos p
INNER JOIN
	Clientes c ON c.ClienteID = p.ClienteID
WHERE
	p.FechaPedido = (SELECT MAX(pe.FechaPedido) FROM pedidos pe);
-- NOTA: La subconsulta se ejecuta UNA SOLA VEZ, obtiene la fecha máxima
-- Luego la consulta principal usa ese valor para filtrar

-- EJEMPLO 2: Subconsulta básica con cálculo de promedio
-- Productos cuyo precio es superior al precio promedio de todos los productos
SELECT -- Consulta principal
	po.NombreProducto,
	po.PrecioProducto
FROM
	Productos po
WHERE
	po.PrecioProducto > (SELECT AVG(po1.PrecioProducto) FROM Productos po1); -- Subconsulta
-- NOTA: Primero se calcula el promedio de TODOS los productos (UNA VEZ)
-- Luego se comparan los productos individuales contra ese valor

/*
CONSULTAS CORRELACIONADAS (CORRELATED SUBQUERIES)
	-- Es una subconsulta que se ejecuta por CADA FILA de la consulta principal
	-- La subconsulta DEPENDE de los valores de la fila actual de la consulta principal
	-- Por eso se llama "correlacionada": está ligada a la fila exterior
*/

-- EJEMPLO 3: Subconsulta correlacionada con IN
-- Encontrar clientes que realizaron más de un pedido
SELECT -- Consulta principal
	c.NombreCliente,
	c.ClienteID
FROM
	Clientes c
WHERE
	c.ClienteID IN (
		SELECT -- Subconsulta (NO correlacionada en este caso)
			p.ClienteID
		FROM
			pedidos p
		GROUP BY 
			p.ClienteID
		HAVING
			COUNT(p.PedidosID) > 1
	);
-- NOTA: Esta NO es una subconsulta correlacionada, es una subconsulta normal
-- Se ejecuta UNA VEZ y devuelve una lista de IDs, luego la consulta principal filtra

-- Verificamos los datos actuales antes de insertar nuevos registros
SELECT * FROM pedidos;
SELECT * FROM Clientes;
SELECT * FROM Productos;

-- Agregamos un nuevo cliente para tener más datos
INSERT INTO Clientes(NombreCliente, EmailCliente, TelefonoCliente)
VALUES
	('Gerardo Rosas', 'gerardo.r@example.com', '444-4321');

-- Agregamos pedidos para el nuevo cliente (ClienteID = 5)
INSERT INTO pedidos(ClienteID, ProductoID, CantidadPedido, FechaPedido)
VALUES
	(5, 2, 20, GETDATE()); -- Cliente 5 compra 20 unidades del producto 2

INSERT INTO pedidos(ClienteID, ProductoID, CantidadPedido, FechaPedido)
VALUES
	(5, 1, 21, GETDATE()); -- Cliente 5 compra 21 unidades del producto 1

-- Ahora volvemos a ejecutar la consulta de clientes con más de un pedido
-- Debería aparecer el nuevo cliente "Gerardo Rosas"

-- EJEMPLO 4: Subconsulta correlacionada (pero con comparación simple)
-- Consultar los productos cuyo stock sea inferior al promedio de stock para todos los productos
SELECT
	po.NombreProducto,
	po.StockProducto
FROM
	Productos po
WHERE
	po.StockProducto < (
		SELECT
			AVG(po1.StockProducto)
		FROM
			Productos po1
	);
-- NOTA: Este NO es un ejemplo de subconsulta correlacionada
-- Es una subconsulta básica porque NO depende de la fila exterior
-- El AVG se calcula UNA VEZ para todos los productos

-- EJEMPLO 5: Subconsulta CORRELACIONADA (VERDADERA)
-- Encontrar el monto total gastado por cada cliente en pedidos
SELECT
	c.NombreCliente,
	(SELECT -- Esta subconsulta SÍ es correlacionada
		SUM(p.CantidadPedido * po.PrecioProducto)
	FROM
		Pedidos p
	INNER JOIN
		Productos po ON po.ProductoID = p.ProductoID
	WHERE
		c.ClienteID = p.ClienteID) AS total_Gastado
FROM
	Clientes c;

-- EXPLICACIÓN DETALLADA de la subconsulta correlacionada (Ejemplo 5):
/*
1. La consulta principal empieza con el primer cliente (c.ClienteID = 1)
2. Para ESE cliente específico, se ejecuta la subconsulta:
   "SUM(CantidadPedido * PrecioProducto) WHERE ClienteID = 1"
3. La subconsulta devuelve el total para el cliente 1 (ej. $500)
4. La consulta principal muestra: "María" | 500
5. Pasa al siguiente cliente (c.ClienteID = 2)
6. Se vuelve a ejecutar la subconsulta, pero ahora con "WHERE ClienteID = 2"
7. Y así sucesivamente hasta procesar TODOS los clientes

Si hay 100 clientes, la subconsulta se ejecuta 100 VECES (una por cada fila)
*/

-- EJEMPLO 6: Otra subconsulta correlacionada útil
-- Encontrar productos cuyo precio es mayor que el precio promedio de su propia categoría
-- (Necesitaríamos una columna de categoría, pero es un ejemplo conceptual)
/*
SELECT
	p1.NombreProducto,
	p1.PrecioProducto,
	p1.CategoriaID
FROM
	Productos p1
WHERE
	p1.PrecioProducto > (
		SELECT AVG(p2.PrecioProducto)
		FROM Productos p2
		WHERE p2.CategoriaID = p1.CategoriaID -- ¡Aquí está la correlación!
	);
*/

/*
RESUMEN FINAL - DIFERENCIAS CLAVE:

SUBCONSULTA BÁSICA (NO CORRELACIONADA):
-- Se ejecuta UNA SOLA VEZ
-- No depende de la consulta principal
-- Ejemplo: SELECT AVG(Precio) FROM Productos
-- Uso típico: Calcular un valor global para filtrar

SUBCONSULTA CORRELACIONADA:
-- Se ejecuta UNA VEZ POR CADA FILA de la consulta principal
-- Depende de la consulta principal (usa valores de ella)
-- Ejemplo: (SELECT SUM(...) WHERE c.ClienteID = p.ClienteID)
-- Uso típico: Calcular algo específico para cada fila individual
-- Puede ser más lenta si la tabla principal tiene muchas filas

REGLAS MNEMOTÉCNICAS:
-- Subconsulta básica: Para algo "global" dentro de la consulta principal
-- Subconsulta correlacionada: Para un "filtro o cálculo personalizado" para cada fila
-- ¿La subconsulta usa una columna de la consulta principal? → Es correlacionada
-- ¿La subconsulta NO usa columnas de la consulta principal? → Es básica
*/
