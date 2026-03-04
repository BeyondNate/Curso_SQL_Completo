
# Guía de Subconsultas en SQL Server
## Ejemplo Práctico con Tienda Virtual

Este documento contiene una guía sobre subconsultas en SQL Server, utilizando el ejemplo práctico de la tienda virtual.

## Índice
1. [Conceptos Fundamentales](#conceptos-fundamentales)
2. [Preparación de la Base de Datos](#preparación-de-la-base-de-datos)
3. [Subconsultas Básicas](#subconsultas-básicas)
4. [Subconsultas Correlacionadas](#subconsultas-correlacionadas)
5. [Manejo de Valores NULL](#manejo-de-valores-null)
6. [Resumen](#resumen)

---

## Conceptos Fundamentales

```sql
/*
SUBCONSULTAS (SUBQUERIES)
-- Es una consulta dentro de otra consulta
-- La usamos para calcular valores o filtrar datos que la consulta principal necesita
-- Se ejecuta la subconsulta y luego la consulta principal

CONSULTAS CORRELACIONADAS
-- Es una subconsulta que se ejecuta por cada fila de la consulta principal
-- La subconsulta depende de los valores de la fila actual de la consulta principal
*/
```

---

## Preparación de la Base de Datos

```sql
-- Seguimos usando BD de TiendaVirtual, base creada en la clase de los Join
use TiendaVirtual;

-- Verificamos los datos existentes
select * from pedidos;
select * from Clientes;
select * from Productos;

-- Insertamos un nuevo cliente para tener más ejemplos
insert into Clientes(NombreCliente, EmailCliente, TelefonoCliente)
values
    ('Gerardo Rosas', 'gerardo.r@example.com', '444-4321');

-- Insertamos pedidos para el nuevo cliente
insert into pedidos(ClienteID, ProductoID, CantidadPedido, FechaPedido)
values
    (5, 2, 20, GETDATE());

insert into pedidos(ClienteID, ProductoID, CantidadPedido, FechaPedido)
values
    (5, 1, 21, GETDATE());
```

---

## Subconsultas Básicas

### Ejemplo 1: Pedidos en la fecha más reciente

**Descripción:** Encontrar los pedidos que se realizaron en la fecha más reciente.

```sql
select
    c.NombreCliente,
    p.FechaPedido
from
    pedidos p
    inner join Clientes c on c.ClienteID = p.ClienteID
where
    p.FechaPedido = (select max(pe.FechaPedido) from pedidos pe);
```

| NombreCliente | FechaPedido |
|---------------|-------------|
| Gerardo Rosas | 2024-11-22 |
| Gerardo Rosas | 2024-11-22 |

> **🔍 NOTA:** La subconsulta `(select max(pe.FechaPedido) from pedidos pe)` se ejecuta UNA SOLA VEZ y devuelve la fecha más reciente. Luego la consulta principal usa ese valor para filtrar.

---

### Ejemplo 2: Productos con precio superior al promedio

**Descripción:** Productos cuyo precio es superior al precio promedio de todos los productos.

```sql
-- Productos cuyo precio es superior al precio promedio
select -- esta es mi consulta principal
    po.NombreProducto,
    po.PrecioProducto
from
    Productos po
where
    po.PrecioProducto > (select avg(po1.PrecioProducto) from Productos po1); -- esta es mi subconsulta
```

| NombreProducto | PrecioProducto |
|----------------|----------------|
| Laptop Dell XPS | 1200.00 |
| Teclado Microsoft | 1200.00 |
| Monitor 24" LG | 250.00 |
| SSD 1TB Samsung | 120.00 |

> **🔍 NOTA:** Primero se calcula el promedio de TODOS los productos, luego se comparan los productos individuales contra ese valor.

---

### Ejemplo 3: Productos con stock inferior al promedio

**Descripción:** Consultar los productos cuyo stock sea inferior al promedio de stock para todos los productos.

```sql
-- Consultar los productos cuyo stock sea inferior al promedio de stock para todos los productos
select
    po.NombreProducto,
    po.StockProducto
from
    Productos po
where
    po.StockProducto < (
        select
            avg(po1.StockProducto)
        from
            Productos po1
    );
```

| NombreProducto | StockProducto |
|----------------|---------------|
| Laptop Dell XPS | 10 |
| Monitor 24" LG | 15 |
| SSD 1TB Samsung | 20 |

> **🔍 NOTA:** Este es otro ejemplo de subconsulta básica. El promedio se calcula UNA VEZ y se compara con cada producto.

---

## Subconsultas Correlacionadas

### Ejemplo 4: Clientes que realizaron más de un pedido

**Descripción:** Encontrar clientes que realizaron más de un pedido.

```sql
-- Encontrar clientes que realizaron mas de un pedido
select -- consulta principal
    c.NombreCliente
from
    Clientes c
where
    c.ClienteID in (
        select -- subconsulta
            p.ClienteID
        from
            pedidos p
        group by ClienteID
        having
            count(PedidosID) > 1
    );
```

| NombreCliente |
|---------------|
| Ana García |
| Carlos López |
| Gerardo Rosas |
| Laura Méndez |

> **⚠️ IMPORTANTE:** Este NO es un ejemplo de subconsulta correlacionada. Es una subconsulta básica porque se ejecuta UNA SOLA VEZ y devuelve una lista de IDs.

---

## Manejo de Valores NULL

### El Problema: Clientes sin pedidos

Cuando un cliente no tiene pedidos, la subconsulta no encuentra ninguna fila que cumpla la condición, y `SUM()` retorna NULL.

**Versión sin manejo de NULLs:**

```sql
-- Versión SIN manejo de NULL (Armando Ruiz aparece como NULL)
select
    c.NombreCliente,
    (select
        sum(p.CantidadPedido * po.PrecioProducto)
    from
        Pedidos p
        inner join Productos po on po.ProductoID = p.ProductoID
    where
        c.ClienteID = p.ClienteID) as total_Gastado
from
    Clientes c;
```

| NombreCliente | total_Gastado |
|---------------|---------------|
| Juan Pérez | 1200.00 |
| Ana García | 75.00 |
| Carlos López | 200.00 |
| Armando Ruiz | NULL | ← Problema: aparece NULL
| Gerardo Rosas | 650.00 |
| Laura Méndez | 720.00 |
| Roberto Sánchez | 200.00 |

---

### Solución 1: Usando ISNULL()

```sql
-- Versión con ISNULL() - SQL Server
select
    c.NombreCliente,
    (select
        ISNULL(sum(p.CantidadPedido * po.PrecioProducto), 0)
    from
        Pedidos p
        inner join Productos po on po.ProductoID = p.ProductoID
    where
        c.ClienteID = p.ClienteID) as total_Gastado
from
    Clientes c;
```

---

### Solución 2: Usando COALESCE() (Estándar SQL)

```sql
-- Versión con COALESCE() - Estándar SQL
select
    c.NombreCliente,
    (select
        COALESCE(sum(p.CantidadPedido * po.PrecioProducto), 0)
    from
        Pedidos p
        inner join Productos po on po.ProductoID = p.ProductoID
    where
        c.ClienteID = p.ClienteID) as total_Gastado
from
    Clientes c;
```

---

### Resultado Corregido

| NombreCliente | total_Gastado |
|---------------|---------------|
| Juan Pérez | 1200.00 |
| Ana García | 75.00 |
| Carlos López | 200.00 |
| Armando Ruiz | 0.00 | ← CORREGIDO: ahora aparece 0
| Gerardo Rosas | 650.00 |
| Laura Méndez | 720.00 |
| Roberto Sánchez | 200.00 |

**Explicación del proceso:**
```
┌─────────────────────────────────────────────────────────────────┐
│ 1. La consulta principal empieza con el primer cliente          │
│    (Juan Pérez - ClienteID = 1)                                 │
├─────────────────────────────────────────────────────────────────┤
│ 2. Para ESE cliente, se ejecuta la subconsulta:                 │
│    "sum(...) WHERE ClienteID = 1" → 1200.00                     │
├─────────────────────────────────────────────────────────────────┤
│ 3. La consulta principal muestra: "Juan Pérez" | 1200.00        │
├─────────────────────────────────────────────────────────────────┤
│ 4. ... (siguientes clientes) ...                                │
├─────────────────────────────────────────────────────────────────┤
│ 5. Llega a Armando Ruiz (ClienteID = 4)                         │
│    La subconsulta ejecuta "WHERE ClienteID = 4"                 │
│    → No encuentra pedidos → SUM() retorna NULL                  │
│    → ISNULL() convierte NULL en 0                               │
├─────────────────────────────────────────────────────────────────┤
│ 6. Muestra: "Armando Ruiz" | 0.00                               │
└─────────────────────────────────────────────────────────────────┘

RENDIMIENTO: Si hay 7 clientes, la subconsulta se ejecuta 7 VECES
```

> **CLAVE DE CORRELACIÓN:** La subconsulta usa `c.ClienteID = p.ClienteID`, donde `c.ClienteID` viene de la consulta principal. Esto la hace CORRELACIONADA.

---

## Resumen

### Diferencias Clave

| Tipo | Subconsulta Básica | Subconsulta Correlacionada |
|------|---------------------|----------------------------|
| **Ejecución** | Una sola vez | Una vez por cada fila |
| **Dependencia** | Independiente | Depende de la fila actual |
| **Identificador** | No usa alias exterior | Usa alias de la consulta principal |

### Manejo de NULLs

| Situación | Resultado sin manejo | Con ISNULL/COALESCE |
|-----------|---------------------|---------------------|
| Cliente con pedidos | Total calculado | Total calculado |
| Cliente sin pedidos | NULL | 0 |

