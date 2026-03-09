
# Guía Completa de Consultas con Múltiples Tablas en SQL Server
## Ejemplo Práctico: Sistema de Ventas

Este documento contiene una guía completa sobre consultas complejas con múltiples tablas en SQL Server, utilizando ejemplos prácticos de un sistema de ventas.

## Índice
1. [Conceptos Fundamentales](#conceptos-fundamentales)
2. [Creación de la Base de Datos](#creación-de-la-base-de-datos)
3. [Consulta Básica con Múltiples JOIN](#consulta-básica-con-múltiples-join)
4. [Consulta Avanzada: Producto Más Vendido](#consulta-avanzada-producto-más-vendido)
5. [Técnicas de Optimización](#técnicas-de-optimización)
6. [Resumen y Conclusiones](#resumen-y-conclusiones)

---

## Conceptos Fundamentales

```sql
/*
CONSULTAS CON MÚLTIPLES TABLAS
¿QUÉ SON?
- Consultas que combinan datos de dos o más tablas
- Utilizan diferentes tipos de JOIN para relacionar la información
- Permiten obtener una visión completa del negocio

Ventajas
- Obtienes información contextualizada (ej: ventas + cliente + vendedor)
- Evitas la redundancia de datos en la base
- Permite análisis complejos del negocio
*/
```

---

## Creación de la Base de Datos

```sql
/*
SISTEMA DE VENTAS
Estructura de tablas:
- Clientes: Información de clientes
- Vendedores: Información de vendedores con su comisión
- Productos: Catálogo de productos disponibles
- Ventas: Cabecera de cada venta realizada
- DetallesVenta: Líneas de detalle de cada venta
*/

CREATE DATABASE BDSISVENTAS;
GO
USE BDSISVENTAS;
GO

-- Tabla de Clientes
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    NombreCliente NVARCHAR(100),
    Email NVARCHAR(100)
);
GO

-- Tabla de Vendedores con porcentaje de comisión
CREATE TABLE Vendedores (
    VendedorID INT PRIMARY KEY,
    NombreVendedor NVARCHAR(100),
    ComisionPorVenta DECIMAL(5, 2) -- Porcentaje de comisión por venta
);
GO

-- Tabla de Productos
CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY,
    NombreProducto NVARCHAR(100),
    Precio DECIMAL(10, 2)
);
GO

-- Tabla de Ventas (cabecera)
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

-- Tabla de Detalles de Venta (líneas)
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

-- Inserción de datos de ejemplo
INSERT INTO Clientes (ClienteID, NombreCliente, Email)
VALUES 
(1, 'Juan Pérez', 'juan.perez@mail.com'),
(2, 'Ana González', 'ana.gonzalez@mail.com'),
(3, 'Carlos Ruiz', 'carlos.ruiz@mail.com');
GO

INSERT INTO Vendedores (VendedorID, NombreVendedor, ComisionPorVenta)
VALUES 
(1, 'Pedro Martínez', 5.00),
(2, 'Lucía Fernández', 7.50),
(3, 'David López', 6.00);
GO

INSERT INTO Productos (ProductoID, NombreProducto, Precio)
VALUES 
(1, 'Laptop', 800.00),
(2, 'Smartphone', 600.00),
(3, 'Tablet', 350.00),
(4, 'Auriculares', 50.00);
GO

INSERT INTO Ventas (VentaID, ClienteID, VendedorID, FechaVenta, TotalVenta)
VALUES 
(1, 1, 2, '2024-11-01', 1200.00),
(2, 2, 1, '2024-11-02', 950.00),
(3, 3, 3, '2024-11-03', 1400.00);
GO

INSERT INTO DetallesVenta (DetalleVentaID, VentaID, ProductoID, Cantidad, PrecioVenta)
VALUES 
(1, 1, 1, 1, 800.00),
(2, 1, 2, 1, 400.00),
(3, 2, 3, 2, 350.00),
(4, 3, 1, 1, 800.00),
(5, 3, 4, 2, 50.00);
GO
```

---

## Consulta Básica con Múltiples JOIN

### Ejemplo 1: Detalle completo de ventas con comisión de vendedor

**Descripción:** Obtenemos el detalle de cada venta incluyendo información del cliente, vendedor, productos vendidos, y calculamos la comisión de cada vendedor.

```sql
/*
CONSULTA ORIGINAL
Objetivo: Obtener detalles de ventas junto con los productos vendidos
y calcular la comisión del vendedor
*/

SELECT
    c.NombreCliente,
    v.FechaVenta,
    p.NombreProducto,
    dv.Cantidad,
    dv.PrecioVenta,
    v.TotalVenta,
    -- Cálculo de comisión: TotalVenta * (porcentaje/100)
    v.TotalVenta * (ve.ComisionPorVenta / 100) AS comisionVendedor
FROM
    Ventas v
    INNER JOIN Clientes c ON c.ClienteID = v.ClienteID
    INNER JOIN Vendedores ve ON ve.VendedorID = v.VendedorID
    INNER JOIN DetallesVenta dv ON dv.VentaID = v.VentaID
    INNER JOIN Productos p ON p.ProductoID = dv.ProductoID
ORDER BY
    v.FechaVenta;
```

**Resultado:**
| NombreCliente | FechaVenta | NombreProducto | Cantidad | PrecioVenta | TotalVenta | comisionVendedor |
|---------------|------------|----------------|----------|-------------|------------|------------------|
| Juan Pérez | 2024-11-01 | Laptop | 1 | 800.00 | 1200.00 | 90.00 |
| Juan Pérez | 2024-11-01 | Smartphone | 1 | 400.00 | 1200.00 | 90.00 |
| Ana González | 2024-11-02 | Tablet | 2 | 350.00 | 950.00 | 47.50 |
| Carlos Ruiz | 2024-11-03 | Laptop | 1 | 800.00 | 1400.00 | 84.00 |
| Carlos Ruiz | 2024-11-03 | Auriculares | 2 | 50.00 | 1400.00 | 84.00 |

**Análisis de la consulta:**
```
TABLAS INVOLUCRADAS: 5 tablas (Clientes, Vendedores, Ventas, DetallesVenta, Productos)
RELACIONES:
- Ventas → Clientes (ClienteID)
- Ventas → Vendedores (VendedorID)
- DetallesVenta → Ventas (VentaID)
- DetallesVenta → Productos (ProductoID)

PROCESO DE EJECUCIÓN:
1. INNER JOIN entre Ventas y Clientes
2. INNER JOIN con Vendedores
3. INNER JOIN con DetallesVenta (expande cada venta en sus líneas)
4. INNER JOIN con Productos
5. Cálculo de comisión en la proyección
6. Ordenamiento por fecha
```

---

## Consulta Avanzada: Producto Más Vendido

### Ejemplo 2: Encontrar el producto más vendido y qué vendedor lo realizó

**Descripción:** Esta consulta identifica cuál es el producto con mayor cantidad vendida y qué vendedor participó en esas ventas.

```sql
/*
CONSULTA COMPLEJA CON SUBCONSULTAS ANIDADAS
Objetivo: Encontrar el producto más vendido en total y el vendedor que realizó esa venta

NOTA: Esta consulta funciona pero puede optimizarse
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
        SELECT
            MAX(cantidadVendida)
        FROM
            (
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
```

**Resultado:**
| NombreProducto | NombreVendedor | cantidadVendida |
|----------------|----------------|-----------------|
| Tablet | Pedro Martínez | 2 |
| Auriculares | David López | 2 |

**Análisis de la estructura compleja:**
```
ESTRUCTURA DE LA CONSULTA (3 niveles de anidación):

NIVEL 1 (Consulta Principal):
├── GROUP BY producto y vendedor
└── HAVING con subconsulta

    NIVEL 2 (Subconsulta en HAVING):
    ├── Obtiene el MAX de...
    └──

        NIVEL 3 (Subconsulta anidada):
            ├── Calcula suma por producto
            └── Agrupa por ProductoID

PROBLEMAS DE ESTE ENFOQUE:
- Difícil de leer y mantener (3 niveles de anidación)
- La subconsulta se ejecuta múltiples veces
- Lógica redundante (calcula dos veces la misma suma)
- Propenso a errores en la sintaxis
```

---

## Técnicas de Optimización

Existen varias maneras de optimizar consultas complejas como la anterior. Aquí una breve explicación de las principales técnicas:

### 1. **Common Table Expressions (CTE)**
```sql
/*
Los CTE permiten dividir una consulta compleja en pasos lógicos
Ventajas:
- Código más legible y mantenible
- Evita subconsultas repetidas
- Puedes reutilizar la misma lógica en múltiples partes
*/
```

### 2. **Funciones de Ventana (Window Functions)**
```sql
/*
Funciones como RANK(), ROW_NUMBER(), DENSE_RANK()
Ventajas:
- Una sola pasada por los datos
- Máximo rendimiento
- Perfecto para rankings, top N, etc.
*/
```

### 3. **Subconsultas Correlacionadas vs No Correlacionadas**
```sql
/*
- Las subconsultas no correlacionadas se ejecutan una vez
- Las correlacionadas se ejecutan por cada fila (más lentas)
- Siempre que sea posible, usa no correlacionadas
*/
```

### 4. **Índices Apropiados**
```sql
/*
- Crear índices en las columnas usadas en JOINs
- Índices en columnas usadas en WHERE y GROUP BY
- Puede mejorar drásticamente el rendimiento
*/
```

### Comparativa de Enfoques

| Técnica | Cuándo usarla | Beneficio principal |
|---------|---------------|---------------------|
| **CTE** | Consultas con múltiples pasos lógicos | Legibilidad y mantenibilidad |
| **Window Functions** | Rankings, totales acumulados, top N | Rendimiento óptimo |
| **Subconsultas optimizadas** | Comparaciones simples contra agregados | Simplicidad |
| **Tablas temporales** | Datos intermedios muy grandes | Control sobre el proceso |

---

## Resumen y Conclusiones

### Lecciones Aprendidas

| Aspecto | Consulta Original | Consulta Optimizada |
|---------|------------------|---------------------|
| **Legibilidad** | ❌ Difícil de seguir (3 niveles anidados) | ✅ Clara (pasos lógicos separados) |
| **Mantenimiento** | ❌ Modificar es riesgoso | ✅ Fácil de modificar |
| **Rendimiento** | ❌ Ejecuta subconsultas repetidas | ✅ Una sola pasada por los datos |
| **Escalabilidad** | ❌ Problemas con grandes volúmenes | ✅ Optimizada para grandes datos |

### Buenas Prácticas para Consultas con Múltiples Tablas

```
1. USA ALIAS: Siempre utiliza alias para las tablas (v, c, ve, dv, p)
2. COMENTA EL CÓDIGO: Explica la lógica de negocios detrás
3. PIENSA EN EL RENDIMIENTO: Identifica posibles cuellos de botella
4. PRUEBA CON DATOS REALES: Verifica el comportamiento con volúmenes grandes
5. REVISA EL PLAN DE EJECUCIÓN: Analiza cómo SQL Server ejecuta tu consulta
```

### En Pocas Palabras

```
-- CONSULTA CON MÚLTIPLES TABLAS: Necesaria para visión completa del negocio
-- SUBCONSULTAS ANIDADAS:  Funcionan pero  difíciles de mantener
-- TÉCNICAS DE OPTIMIZACIÓN: Hacen el código más limpio y rápido

La optimización no es solo sobre velocidad:
- Optimizamos para LEGIBILIDAD (que otros entiendan tu código)
- Optimizamos para MANTENIMIENTO (fácil de modificar después)
- Optimizamos para RENDIMIENTO (que ejecute rápido)
```

### Aplicaciones Comunes

- **Reportes de ventas:** Información combinada de clientes, productos y vendedores
- **Análisis de comisiones:** Cálculos basados en ventas y vendedores
- **Productos más vendidos:** Identificar tendencias y best-sellers
- **Rendimiento de vendedores:** Evaluar desempeño por período

```sql
/*
CONCLUSIONES FINALES:

1. Consultas con múltiples tablas:
   - Son esenciales para obtener una visión completa del negocio
   - Requieren entender bien las relaciones entre tablas
   - Los JOINs son la herramienta fundamental

2. Identificar oportunidades de optimización:
   - Busca subconsultas repetidas
   - Detecta cálculos redundantes
   - Analiza niveles de anidación excesivos

3. Buenas prácticas:
   - Siempre usar alias de tablas (v, c, ve, dv, p)
   - Comentar consultas complejas
   - Probar con diferentes volúmenes de datos
   - Revisar el plan de ejecución

4. Recuerda:
   - El SQL más corto no siempre es el más rápido
   - La claridad del código es tan importante como el rendimiento
   - Optimiza pensando en quien mantendrá el código después
   - "Existen maneras de optimizar las consultas, ya sea con CTE, funciones de ventana u otras opciones"
*/
```

