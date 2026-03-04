
# Funciones de Agregación en SQL Server

## Índice
1. [¿Qué son las Funciones de Agregación?](#qué-son-las-funciones-de-agregación)
2. [COUNT](#count)
3. [SUM](#sum)
4. [AVG](#avg)
5. [MAX](#max)
6. [MIN](#min)
7. [Combinación con GROUP BY](#combinación-con-group-by)
8. [Filtrado con HAVING](#filtrado-con-having)
9. [Funciones de Agregación con DISTINCT](#funciones-de-agregación-con-distinct)
10. [Ejercicios Prácticos](#ejercicios-prácticos)

---

## ¿Qué son las Funciones de Agregación?

Las funciones de agregación en SQL realizan cálculos sobre un conjunto de valores y devuelven un solo valor como resultado. Son fundamentales para el análisis de datos y la generación de reportes.

### Características principales:
- Operan sobre conjuntos de filas
- Devuelven un único valor escalar
- Se utilizan frecuentemente con GROUP BY
- Ignoran valores NULL (excepto COUNT(*))

### Base de Datos de Ejemplo

Primero, crearemos la base de datos y tabla que utilizaremos en todos los ejemplos:

```sql
create database DBTienda;
go
use DBTienda;

-- Crear la tabla Ventas con los campos necesarios para almacenar los datos de ventas
create table Ventas(
    VentaID int primary key identity(1,1), 
    Producto varchar(50), 
    Cantidad int, 
    PrecioUnitario decimal(10,2),
    FechaVenta date, 
    Ciudad varchar(150) 
);
go

-- Insertar datos de ejemplo en la tabla Ventas
INSERT INTO Ventas (Producto, Cantidad, PrecioUnitario, FechaVenta, Ciudad)
VALUES
( 'Camisa', 2, 20.00, '2024-01-01', 'Ciudad A'),
( 'Pantalón', 1, 50.00, '2024-01-01', 'Ciudad B'),
( 'Zapatos', 3, 30.00, '2024-01-02', 'Ciudad A'),
( 'Camisa', 1, 20.00, '2024-01-02', 'Ciudad A'),
( 'Pantalón', 2, 50.00, '2024-01-03', 'Ciudad C'),
( 'Zapatos', 4, 30.00, '2024-01-03', 'Ciudad B'),
( 'Camisa', 5, 20.00, '2024-01-04', 'Ciudad A'),
( 'Pantalón', 3, 50.00, '2024-01-04', 'Ciudad C'),
( 'Zapatos', 2, 30.00, '2024-01-05', 'Ciudad B'),
( 'Camisa', 4, 20.00, '2024-01-05', 'Ciudad C');
```

---

## COUNT

### Teoría
La función **COUNT** devuelve el número de registros (filas) en una consulta.

**Sintaxis básica:**
```sql
COUNT(*)           -- Cuenta todas las filas, incluyendo NULL
COUNT(columna)     -- Cuenta solo las filas donde la columna NO es NULL
COUNT(DISTINCT columna) -- Cuenta valores únicos no nulos
```

### Ejemplos

#### 1. Contar todas las ventas
```sql
-- Contar el total de ventas registradas en la tabla
select count(*) as TotalVentas from Ventas;
```
**Resultado:** 10 (total de registros en la tabla)

#### 2. Contar ventas por ciudad
```sql
-- Contar el número de ventas por cada ciudad
select
    v.Ciudad,
    count(*) as TotalVentas
from
    Ventas v
group by
    v.Ciudad;
```

| Ciudad | TotalVentas |
|--------|-------------|
| Ciudad A | 4 |
| Ciudad B | 3 |
| Ciudad C | 3 |

#### 3. Contar valores distintos
```sql
-- Contar cuántas ciudades diferentes tienen ventas
select count(distinct Ciudad) as CiudadesConVentas from Ventas;
```
**Resultado:** 3

---

## SUM

### Teoría
La función **SUM** calcula la suma total de una columna numérica.

**Sintaxis básica:**
```sql
SUM(columna_numerica)     -- Suma todos los valores
SUM(columna1 * columna2)  -- Suma de expresiones
```

### Ejemplos

#### 1. Suma total de cantidades
```sql
-- Sumar la cantidad total de unidades vendidas
select
    sum(v.Cantidad) as TotalUnidadesVendidas
from
    Ventas v;
```
**Resultado:** 27 unidades en total

#### 2. Suma del valor total de ventas por producto
```sql
-- Sumar el valor total de las unidades vendidas por cada producto
select
    v.Producto,
    sum(v.Cantidad * v.PrecioUnitario) as ValorTotalVentas
from
    Ventas v
group by
    v.Producto;
```

| Producto | ValorTotalVentas |
|----------|------------------|
| Camisa | 12 * 20 = 240.00 |
| Pantalón | 6 * 50 = 300.00 |
| Zapatos | 9 * 30 = 270.00 |

#### 3. Suma con filtro de fechas
```sql
-- Calcular el total de ventas por ciudad en un rango de fechas específico
select
    v.Ciudad,
    sum(v.Cantidad * v.PrecioUnitario) as TotalVentas
from
    Ventas v
where
    FechaVenta between '2024-01-01' and '2024-01-03'
group by
    v.Ciudad;
```

---

## AVG

### Teoría
La función **AVG** calcula el promedio (media aritmética) de una columna numérica.

**Sintaxis básica:**
```sql
AVG(columna_numerica)     -- Promedio simple
AVG(DISTINCT columna)      -- Promedio de valores únicos
```

### Ejemplos

#### 1. Precio promedio general
```sql
-- Calcular el precio promedio de las unidades vendidas
select
    avg(v.PrecioUnitario) as PrecioPromedio
from
    Ventas v;
```
**Resultado:** 30.00 (promedio entre 20, 50 y 30)

#### 2. Precio promedio por ciudad
```sql
-- Calcular el precio promedio por ciudad
select
    v.Ciudad,
    avg(v.PrecioUnitario) as PrecioPromedio
from
    Ventas v
group by
    v.Ciudad;
```

| Ciudad | PrecioPromedio |
|--------|----------------|
| Ciudad A | 22.50 |
| Ciudad B | 40.00 |
| Ciudad C | 36.66 |

#### 3. Promedio de cantidades vendidas
```sql
-- Calcular la cantidad promedio vendida por transacción
select
    v.Producto,
    avg(v.Cantidad) as CantidadPromedio
from
    Ventas v
group by
    v.Producto;
```

---

## MAX

### Teoría
La función **MAX** devuelve el valor máximo de una columna.

**Sintaxis básica:**
```sql
MAX(columna)     -- Valor máximo (numérico, fecha o texto)
```

### Ejemplos

#### 1. Cantidad máxima en una transacción
```sql
-- Obtener la cantidad máxima de productos vendidos en una sola transacción
select
    max(v.Cantidad) as MaxCantidad
from
    Ventas v;
```
**Resultado:** 5 (la venta de 5 Camisas)

#### 2. Cantidad máxima por producto
```sql
-- Obtener la cantidad máxima vendida por cada tipo de producto
select
    v.Producto,
    max(v.Cantidad) as MaxCantidad
from
    Ventas v
group by
    v.Producto;
```

| Producto | MaxCantidad |
|----------|-------------|
| Camisa | 5 |
| Pantalón | 3 |
| Zapatos | 4 |

#### 3. Fecha máxima de venta
```sql
-- Obtener la fecha más reciente de venta
select max(FechaVenta) as UltimaVenta from Ventas;
```
**Resultado:** 2024-01-05

---

## MIN

### Teoría
La función **MIN** devuelve el valor mínimo de una columna.

**Sintaxis básica:**
```sql
MIN(columna)     -- Valor mínimo (numérico, fecha o texto)
```

### Ejemplos

#### 1. Cantidad mínima por producto
```sql
-- Obtener la cantidad mínima vendida por cada tipo de producto
select
    v.Producto,
    min(v.Cantidad) as MinCantidad
from
    Ventas v
group by
    v.Producto;
```

| Producto | MinCantidad |
|----------|-------------|
| Camisa | 1 |
| Pantalón | 1 |
| Zapatos | 2 |

#### 2. Precio mínimo por ciudad
```sql
-- Obtener el precio mínimo por ciudad
select
    v.Ciudad,
    min(v.PrecioUnitario) as PrecioMinimo
from
    Ventas v
group by
    v.Ciudad;
```

#### 3. Primera fecha de venta
```sql
-- Obtener la fecha más antigua de venta
select min(FechaVenta) as PrimeraVenta from Ventas;
```
**Resultado:** 2024-01-01

---

## Combinación con GROUP BY

### Teoría
**GROUP BY** agrupa filas que tienen los mismos valores en columnas específicas, permitiendo aplicar funciones de agregación a cada grupo.

**Sintaxis básica:**
```sql
SELECT columna1, funcion_agregacion(columna2)
FROM tabla
GROUP BY columna1;
```

### Ejemplo completo con múltiples agregaciones
```sql
-- Análisis completo de ventas por ciudad
select
    v.Ciudad,
    count(*) as TotalVentas,
    sum(v.Cantidad) as UnidadesVendidas,
    sum(v.Cantidad * v.PrecioUnitario) as ValorTotal,
    avg(v.PrecioUnitario) as PrecioPromedio,
    max(v.Cantidad) as VentaMaxima,
    min(v.Cantidad) as VentaMinima
from
    Ventas v
group by
    v.Ciudad;
```

| Ciudad | TotalVentas | UnidadesVendidas | ValorTotal | PrecioPromedio | VentaMaxima | VentaMinima |
|--------|-------------|------------------|------------|----------------|-------------|-------------|
| Ciudad A | 4 | 12 | 220.00 | 22.50 | 5 | 1 |
| Ciudad B | 3 | 7 | 260.00 | 40.00 | 4 | 1 |
| Ciudad C | 3 | 8 | 330.00 | 36.66 | 4 | 2 |

---

## Filtrado con HAVING

### Teoría
**HAVING** filtra los resultados después de la agregación (similar a WHERE pero para grupos).

**Sintaxis básica:**
```sql
SELECT columna1, funcion_agregacion(columna2)
FROM tabla
GROUP BY columna1
HAVING condicion_agregada;
```

### Ejemplos

#### 1. Ciudades con más de 3 ventas
```sql
select
    v.Ciudad,
    count(*) as TotalVentas,
    sum(v.Cantidad * v.PrecioUnitario) as ValorTotal
from
    Ventas v
group by
    v.Ciudad
having
    count(*) > 3;
```
**Resultado:** Solo Ciudad A (4 ventas)

#### 2. Productos con valor total mayor a 250
```sql
select
    v.Producto,
    sum(v.Cantidad * v.PrecioUnitario) as ValorTotal
from
    Ventas v
group by
    v.Producto
having
    sum(v.Cantidad * v.PrecioUnitario) > 250;
```

| Producto | ValorTotal |
|----------|------------|
| Pantalón | 300.00 |
| Zapatos | 270.00 |

---

## Funciones de Agregación con DISTINCT

### Teoría
La palabra clave **DISTINCT** dentro de una función de agregación considera solo valores únicos.

**Sintaxis básica:**
```sql
COUNT(DISTINCT columna)
SUM(DISTINCT columna)
AVG(DISTINCT columna)
```

### Ejemplos

```sql
-- Comparación con y sin DISTINCT
select
    count(PrecioUnitario) as TodosLosPrecios,
    count(distinct PrecioUnitario) as PreciosUnicos,
    avg(PrecioUnitario) as PromedioNormal,
    avg(distinct PrecioUnitario) as PromedioValoresUnicos
from Ventas;
```

---

## Ejercicios Prácticos

### Ejercicio 1: Análisis por Producto
```sql
-- Calcula para cada producto:
-- - Total de unidades vendidas
-- - Valor total de ventas
-- - Precio promedio
-- - Número de transacciones
-- Ordenar por valor total descendente

select
    v.Producto,
    sum(v.Cantidad) as UnidadesVendidas,
    count(*) as NumeroTransacciones,
    sum(v.Cantidad * v.PrecioUnitario) as ValorTotal,
    avg(v.PrecioUnitario) as PrecioPromedio
from
    Ventas v
group by
    v.Producto
order by
    ValorTotal desc;
```

### Ejercicio 2: Análisis por Día
```sql
-- Análisis de ventas por día
select
    v.FechaVenta,
    count(*) as VentasDelDia,
    sum(v.Cantidad) as UnidadesVendidas,
    sum(v.Cantidad * v.PrecioUnitario) as IngresosDelDia
from
    Ventas v
group by
    v.FechaVenta
order by
    v.FechaVenta;
```

### Ejercicio 3: Productos Estrella
```sql
-- Identificar productos que han vendido más de 5 unidades en total
select
    v.Producto,
    sum(v.Cantidad) as TotalUnidades,
    count(distinct v.Ciudad) as CiudadesDondeSeVende
from
    Ventas v
group by
    v.Producto
having
    sum(v.Cantidad) > 5;
```

---

## Resumen de Funciones de Agregación

| Función | Descripción | Ejemplo de Uso |
|---------|-------------|----------------|
| **COUNT()** | Número de filas | `COUNT(*)` cuenta todas las filas |
| **SUM()** | Suma de valores | `SUM(Cantidad * Precio)` total ventas |
| **AVG()** | Promedio de valores | `AVG(PrecioUnitario)` precio promedio |
| **MAX()** | Valor máximo | `MAX(FechaVenta)` última venta |
| **MIN()** | Valor mínimo | `MIN(Cantidad)` venta más pequeña |

### Consideraciones Importantes:
1. Las funciones de agregación ignoran NULL (excepto COUNT(*))
2. GROUP BY agrupa antes de agregar
3. HAVING filtra después de agregar
4. WHERE filtra antes de agregar
5. DISTINCT dentro de agregación considera valores únicos

---

## Nota sobre Rendimiento

Para optimizar consultas con funciones de agregación:
- Crear índices en las columnas usadas en GROUP BY y WHERE
- Evitar funciones de agregación en columnas no indexadas para grandes volúmenes de datos
- Usar COUNT(1) en lugar de COUNT(*) en algunos motores (aunque en SQL Server son equivalentes)
- Filtrar la mayor cantidad de datos posible antes de la agregación usando WHERE
