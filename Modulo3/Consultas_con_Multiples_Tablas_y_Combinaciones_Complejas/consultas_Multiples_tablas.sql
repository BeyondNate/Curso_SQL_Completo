/*
===================================================
SISTEMA DE VENTAS - BDSISVENTAS
===================================================
Base de datos para gestión de ventas con:
- Clientes
- Vendedores (con comisiones)
- Productos
- Ventas (cabecera)
- Detalles de Venta (líneas)

Las consultas muestran diferentes niveles de complejidad
y técnicas de optimización
===================================================
*/

-- ===================================================
-- CREACIÓN DE LA BASE DE DATOS
-- ===================================================

CREATE DATABASE BDSISVENTAS;
GO

USE BDSISVENTAS;
GO

-- ===================================================
-- CREACIÓN DE TABLAS
-- ===================================================

/*
Tabla: Clientes
Almacena información básica de los clientes
ClienteID: Identificador único (PRIMARY KEY)
*/
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    NombreCliente NVARCHAR(100),
    Email NVARCHAR(100)
);
GO

/*
Tabla: Vendedores
Incluye el porcentaje de comisión que recibe cada vendedor
ComisionPorVenta: Porcentaje (ej: 5.00 = 5%)
*/
CREATE TABLE Vendedores (
    VendedorID INT PRIMARY KEY,
    NombreVendedor NVARCHAR(100),
    ComisionPorVenta DECIMAL(5, 2) -- Porcentaje de comisión por venta
);
GO

/*
Tabla: Productos
Catálogo de productos disponibles
Precio: Precio unitario del producto
*/
CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY,
    NombreProducto NVARCHAR(100),
    Precio DECIMAL(10, 2)
);
GO

/*
Tabla: Ventas (cabecera)
Registro principal de cada venta
TotalVenta: Monto total de la venta (suma de detalles)
FOREIGN KEY: Relaciones con Clientes y Vendedores
*/
CREATE TABLE Ventas (
    VentaID INT PRIMARY KEY,
    ClienteID INT,
    VendedorID INT,
    FechaVenta DATETIME,
    TotalVenta DECIMAL(10, 2),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
    FOREIGN KEY (VendedorID) REFERENCES Vendedores(VendedorID)
);
GO

/*
Tabla: DetallesVenta (líneas de detalle)
Registro de cada producto vendido en una venta
PrecioVenta: Precio al que se vendió (puede diferir del precio actual)
Cantidad: Unidades vendidas de este producto
FOREIGN KEY: Relaciones con Ventas y Productos
*/
CREATE TABLE DetallesVenta (
    DetalleVentaID INT PRIMARY KEY,
    VentaID INT,
    ProductoID INT,
    Cantidad INT,
    PrecioVenta DECIMAL(10, 2),
    FOREIGN KEY (VentaID) REFERENCES Ventas(VentaID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);
GO

-- ===================================================
-- INSERCIÓN DE DATOS DE EJEMPLO
-- ===================================================

-- Datos de clientes
INSERT INTO Clientes (ClienteID, NombreCliente, Email)
VALUES 
(1, 'Juan Pérez', 'juan.perez@mail.com'),
(2, 'Ana González', 'ana.gonzalez@mail.com'),
(3, 'Carlos Ruiz', 'carlos.ruiz@mail.com');
GO

-- Datos de vendedores con sus porcentajes de comisión
INSERT INTO Vendedores (VendedorID, NombreVendedor, ComisionPorVenta)
VALUES 
(1, 'Pedro Martínez', 5.00),
(2, 'Lucía Fernández', 7.50),
(3, 'David López', 6.00);
GO

-- Catálogo de productos
INSERT INTO Productos (ProductoID, NombreProducto, Precio)
VALUES 
(1, 'Laptop', 800.00),
(2, 'Smartphone', 600.00),
(3, 'Tablet', 350.00),
(4, 'Auriculares', 50.00);
GO

-- Cabeceras de ventas
INSERT INTO Ventas (VentaID, ClienteID, VendedorID, FechaVenta, TotalVenta)
VALUES 
(1, 1, 2, '2024-11-01', 1200.00),
(2, 2, 1, '2024-11-02', 950.00),
(3, 3, 3, '2024-11-03', 1400.00);
GO

-- Detalles de cada venta (productos vendidos)
INSERT INTO DetallesVenta (DetalleVentaID, VentaID, ProductoID, Cantidad, PrecioVenta)
VALUES 
(1, 1, 1, 1, 800.00),  -- Venta 1: 1 Laptop a 800
(2, 1, 2, 1, 400.00),  -- Venta 1: 1 Smartphone a 400 (nota: precio menor al catálogo)
(3, 2, 3, 2, 350.00),  -- Venta 2: 2 Tablets a 350 c/u
(4, 3, 1, 1, 800.00),  -- Venta 3: 1 Laptop a 800
(5, 3, 4, 2, 50.00);   -- Venta 3: 2 Auriculares a 50 c/u
GO

-- ===================================================
-- CONSULTAS DE VERIFICACIÓN
-- ===================================================

-- Verificar datos insertados
SELECT * FROM Clientes;
SELECT * FROM Vendedores;
SELECT * FROM Productos;
SELECT * FROM Ventas;
SELECT * FROM DetallesVenta;

-- ===================================================
-- CONSULTA 1: DETALLE COMPLETO DE VENTAS
-- ===================================================

/*
CONSULTA BÁSICA CON MÚLTIPLES JOINS
Objetivo: Obtener detalle de ventas con información de:
- Cliente (nombre)
- Vendedor (para calcular comisión)
- Producto (nombre y precio)
- Cálculo de comisión del vendedor

TABLAS INVOLUCRADAS: 5 (Clientes, Vendedores, Ventas, DetallesVenta, Productos)
*/
SELECT
    c.NombreCliente,
    v.FechaVenta,
    p.NombreProducto,
    dv.Cantidad,
    dv.PrecioVenta,
    v.TotalVenta,
    -- Cálculo de comisión: TotalVenta * (porcentaje/100)
    -- Nota: La comisión se calcula sobre el total de la venta, no por producto
    v.TotalVenta * (ve.ComisionPorVenta / 100) AS comisionVendedor
FROM
    Ventas v
    INNER JOIN Clientes c ON c.ClienteID = v.ClienteID
    INNER JOIN Vendedores ve ON ve.VendedorID = v.VendedorID
    INNER JOIN DetallesVenta dv ON dv.VentaID = v.VentaID
    INNER JOIN Productos p ON p.ProductoID = dv.ProductoID
ORDER BY
    v.FechaVenta;
GO

-- ===================================================
-- CONSULTA 2: PRODUCTO MÁS VENDIDO
-- ===================================================

/*
CONSULTA COMPLEJA CON SUBCONSULTAS ANIDADAS
Objetivo: Encontrar el producto más vendido y qué vendedor lo realizó

ESTRUCTURA:
- Nivel 1: Consulta principal con GROUP BY producto/vendedor
- Nivel 2: Subconsulta para obtener el máximo
- Nivel 3: Subconsulta anidada para calcular totales por producto

NOTA: Esta consulta funciona pero puede optimizarse
(Existen técnicas como CTE, funciones de ventana, etc.)
*/
SELECT
    p.NombreProducto,
    ve.NombreVendedor,
    SUM(dv.Cantidad) AS cantidadVendida
FROM
    DetallesVenta dv
    INNER JOIN Productos p ON p.ProductoID = dv.ProductoID
    INNER JOIN Ventas v ON v.VentaID = dv.VentaID
    INNER JOIN Vendedores ve ON ve.VendedorID = v.VendedorID
GROUP BY
    p.NombreProducto,
    ve.NombreVendedor
HAVING
    SUM(dv.Cantidad) = (
        -- Subconsulta que encuentra la cantidad máxima vendida
        SELECT
            MAX(cantidadVendida)
        FROM
            (
                -- Subconsulta anidada que calcula total por producto
                SELECT
                    SUM(dv1.Cantidad) AS cantidadVendida
                FROM
                    DetallesVenta dv1
                GROUP BY
                    dv1.ProductoID
            ) AS SubQuery
    )
ORDER BY
    cantidadVendida DESC;
GO


/*
EXISTEN MANERAS DE OPTIMIZAR LAS CONSULTAS ANTERIORES:

1. Common Table Expressions (CTE):
   - Dividen la lógica en pasos legibles
   - Ej: WITH VentasPorProducto AS (SELECT...)

2. Funciones de Ventana (Window Functions):
   - RANK(), DENSE_RANK(), ROW_NUMBER()
   - Permiten rankings sin subconsultas

3. Subconsultas optimizadas:
   - Evitar subconsultas correlacionadas
   - Calcular una vez y reutilizar

4. Índices apropiados:
   - En columnas usadas en JOINs
   - En columnas de filtro (WHERE, GROUP BY)

La mejor técnica depende del contexto y volumen de datos
*/
