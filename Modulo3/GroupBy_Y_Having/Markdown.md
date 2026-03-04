
# Guía Completa de GROUP BY y HAVING en SQL Server

## Índice
1. [Introducción a GROUP BY](#introducción-a-group-by)
2. [Introducción a HAVING](#introducción-a-having)
3. [Configuración Inicial](#configuración-inicial)
4. [GROUP BY - Teoría y Ejemplos](#group-by---teoría-y-ejemplos)
5. [HAVING - Teoría y Ejemplos](#having---teoría-y-ejemplos)
6. [GROUP BY vs HAVING - Diferencias Clave](#group-by-vs-having---diferencias-clave)
7. [Ejemplos Avanzados con Subconsultas](#ejemplos-avanzados-con-subconsultas)
8. [Ejercicios Prácticos Resueltos](#ejercicios-prácticos-resueltos)
9. [Errores Comunes y Soluciones](#errores-comunes-y-soluciones)
10. [Resumen y Conclusiones](#resumen-y-conclusiones)

---

## Introducción a GROUP BY

### ¿Qué es GROUP BY?

**GROUP BY** es una cláusula en SQL que agrupa filas que tienen los mismos valores en columnas específicas, permitiendo aplicar funciones de agregación a cada grupo.

### Sintaxis Básica
```sql
SELECT columna_agrupada, funcion_agregacion(columna_calculo)
FROM tabla
GROUP BY columna_agrupada;
```

### ¿Cuándo usar GROUP BY?
- Cuando necesitas resumir datos por categorías
- Para calcular totales por grupos (ventas por región, productos por categoría)
- Para análisis estadísticos segmentados
- Cuando combinas datos detallados en reportes resumidos

---

## Introducción a HAVING

### ¿Qué es HAVING?

**HAVING** es una cláusula que filtra los resultados después de que se ha aplicado GROUP BY, permitiendo condiciones sobre datos agregados.

### Sintaxis Básica
```sql
SELECT columna_agrupada, funcion_agregacion(columna_calculo)
FROM tabla
GROUP BY columna_agrupada
HAVING condicion_agregada;
```

### ¿Cuándo usar HAVING?
- Para filtrar grupos basados en resultados de funciones de agregación
- Cuando necesitas condiciones como `SUM(ventas) > 1000`
- Para excluir categorías que no cumplen criterios estadísticos
- Después de GROUP BY (WHERE no puede usarse con agregaciones)

---

## Configuración Inicial

### Creación de la Base de Datos y Tabla

```sql
-- Crear la base de datos EmpresaZ
CREATE DATABASE EmpresaZ;
GO

-- Seleccionar la base de datos creada
USE EmpresaZ;
GO

-- Creación de la tabla Inventario
CREATE TABLE Inventario(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Producto NVARCHAR(50),
    Categoria NVARCHAR(70),
    Cantidad INT,
    Precio DECIMAL(10,2),
    FechaIngreso DATE
);
GO
```

### Inserción de Datos de Ejemplo

```sql
INSERT INTO Inventario (Producto, Categoria, Cantidad, Precio, FechaIngreso)
VALUES 
('Laptop', 'Electrónica', 50, 750.00, '2024-01-10'),
('Teclado', 'Electrónica', 200, 25.00, '2024-01-12'),
('Mouse', 'Electrónica', 300, 15.00, '2024-01-12'),
('Silla', 'Muebles', 150, 100.00, '2024-01-15'),
('Mesa', 'Muebles', 100, 150.00, '2024-01-20'),
('Notebook', 'Papelería', 500, 5.00, '2024-02-01'),
('Bolígrafo', 'Papelería', 1000, 1.50, '2024-02-01'),
('Impresora', 'Electrónica', 30, 200.00, '2024-02-05');
```

### Verificación de Datos

```sql
SELECT * FROM Inventario;
```

| ID | Producto   | Categoria   | Cantidad | Precio | FechaIngreso |
|----|------------|-------------|----------|--------|--------------|
| 1  | Laptop     | Electrónica | 50       | 750.00 | 2024-01-10   |
| 2  | Teclado    | Electrónica | 200      | 25.00  | 2024-01-12   |
| 3  | Mouse      | Electrónica | 300      | 15.00  | 2024-01-12   |
| 4  | Silla      | Muebles     | 150      | 100.00 | 2024-01-15   |
| 5  | Mesa       | Muebles     | 100      | 150.00 | 2024-01-20   |
| 6  | Notebook   | Papelería   | 500      | 5.00   | 2024-02-01   |
| 7  | Bolígrafo  | Papelería   | 1000     | 1.50   | 2024-02-01   |
| 8  | Impresora  | Electrónica | 30       | 200.00 | 2024-02-05   |

---

## GROUP BY - Teoría y Ejemplos

### Teoría Fundamental

**GROUP BY** transforma filas detalladas en filas resumidas. Cada grupo único se convierte en una sola fila en el resultado.

**Reglas importantes:**
1. Todas las columnas en SELECT deben estar en GROUP BY o ser funciones de agregación
2. NULL se trata como un grupo separado
3. Puedes agrupar por múltiples columnas
4. El orden de las columnas en GROUP BY afecta la jerarquía de agrupación

---

### Ejemplo 1: Agrupación Simple por Categoría

```sql
-- Obtener la cantidad total de productos por categoría
SELECT
    i.Categoria,
    SUM(i.Cantidad) AS Cantidad_Total
FROM
    Inventario i
GROUP BY i.Categoria;
```

**Explicación detallada:**
- `GROUP BY i.Categoria`: Crea un grupo para cada valor único en Categoria (Electrónica, Muebles, Papelería)
- `SUM(i.Cantidad)`: Suma todas las cantidades dentro de cada grupo
- `AS Cantidad_Total`: Asigna un alias descriptivo al resultado

**Proceso de agrupación:**
1. Electrónica: 50 + 200 + 300 + 30 = 580
2. Muebles: 150 + 100 = 250
3. Papelería: 500 + 1000 = 1500

| Categoria   | Cantidad_Total |
|-------------|----------------|
| Electrónica | 580            |
| Muebles     | 250            |
| Papelería   | 1500           |

---

### Ejemplo 2: Agrupación con Múltiples Agregaciones

```sql
-- Análisis completo por categoría
SELECT
    i.Categoria,
    COUNT(*) AS Numero_Productos,
    SUM(i.Cantidad) AS Stock_Total,
    AVG(i.Precio) AS Precio_Promedio,
    MIN(i.Precio) AS Precio_Minimo,
    MAX(i.Precio) AS Precio_Maximo,
    SUM(i.Cantidad * i.Precio) AS Valor_Total_Inventario
FROM
    Inventario i
GROUP BY i.Categoria;
```

**Cálculos realizados:**
| Categoria   | Productos | Stock | Precio Prom | Precio Min | Precio Max | Valor Total |
|-------------|-----------|-------|-------------|------------|------------|-------------|
| Electrónica | 4         | 580   | 247.50      | 15.00      | 750.00     | 750*50 + 25*200 + 15*300 + 200*30 = 53,500 |
| Muebles     | 2         | 250   | 125.00      | 100.00     | 150.00     | 100*150 + 150*100 = 30,000 |
| Papelería   | 2         | 1500  | 3.25        | 1.50       | 5.00       | 5*500 + 1.5*1000 = 4,000 |

---

### Ejemplo 3: Agrupación por Múltiples Columnas

```sql
-- Análisis por categoría y mes de ingreso
SELECT
    i.Categoria,
    MONTH(i.FechaIngreso) AS Mes_Ingreso,
    COUNT(*) AS Productos_Recibidos,
    SUM(i.Cantidad) AS Unidades_Recibidas
FROM
    Inventario i
GROUP BY 
    i.Categoria,
    MONTH(i.FechaIngreso)
ORDER BY 
    i.Categoria,
    Mes_Ingreso;
```

**Resultado:**
| Categoria   | Mes_Ingreso | Productos_Recibidos | Unidades_Recibidas |
|-------------|-------------|---------------------|--------------------|
| Electrónica | 1           | 3                   | 550                |
| Electrónica | 2           | 1                   | 30                 |
| Muebles     | 1           | 2                   | 250                |
| Papelería   | 2           | 2                   | 1500               |

---

### Ejemplo 4: GROUP BY con Expresiones

```sql
-- Clasificar productos por rango de precio y contar por categoría
SELECT
    i.Categoria,
    CASE 
        WHEN i.Precio < 50 THEN 'Económico'
        WHEN i.Precio BETWEEN 50 AND 200 THEN 'Medio'
        ELSE 'Premium'
    END AS Rango_Precio,
    COUNT(*) AS Cantidad_Productos,
    AVG(i.Cantidad) AS Stock_Promedio
FROM
    Inventario i
GROUP BY 
    i.Categoria,
    CASE 
        WHEN i.Precio < 50 THEN 'Económico'
        WHEN i.Precio BETWEEN 50 AND 200 THEN 'Medio'
        ELSE 'Premium'
    END
ORDER BY 
    i.Categoria,
    Rango_Precio;
```

---

## HAVING - Teoría y Ejemplos

### Teoría Fundamental

**HAVING** es el filtro para grupos, similar a cómo WHERE filtra filas individuales.

**Características clave:**
- Se ejecuta DESPUÉS de GROUP BY
- Puede usar funciones de agregación en sus condiciones
- Filtra grupos completos, no filas individuales
- Puede referirse a alias definidos en SELECT (en algunos motores)

**Orden de ejecución:**
```
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
```

---

### Ejemplo 1: Filtro Básico con HAVING

```sql
-- Categorías con más de 500 unidades en stock
SELECT
    i.Categoria,
    SUM(i.Cantidad) AS Cantidad_Total
FROM
    Inventario i
GROUP BY i.Categoria
HAVING SUM(i.Cantidad) > 500;
```

**Comparación con WHERE (no funciona):**
```sql
-- ESTO NO FUNCIONA - WHERE no puede usar agregaciones
SELECT Categoria, SUM(Cantidad)
FROM Inventario
WHERE SUM(Cantidad) > 500   -- Error!
GROUP BY Categoria;
```

**Resultado correcto con HAVING:**
| Categoria   | Cantidad_Total |
|-------------|----------------|
| Electrónica | 580            |
| Papelería   | 1500           |

---

### Ejemplo 2: Múltiples Condiciones en HAVING

```sql
-- Categorías con más de 2 productos Y stock total < 1000
SELECT
    i.Categoria,
    COUNT(*) AS Numero_Productos,
    SUM(i.Cantidad) AS Stock_Total,
    AVG(i.Precio) AS Precio_Promedio
FROM
    Inventario i
GROUP BY i.Categoria
HAVING 
    COUNT(*) > 2 
    AND SUM(i.Cantidad) < 1000;
```

**Evaluación de condiciones:**
| Categoria   | Productos | Stock | ¿Cumple? (Productos>2 y Stock<1000) |
|-------------|-----------|-------|-------------------------------------|
| Electrónica | 4         | 580   | ✅ Sí (4>2 y 580<1000)              |
| Muebles     | 2         | 250   | ❌ No (2 no es >2)                   |
| Papelería   | 2         | 1500  | ❌ No (2 no es >2 y 1500 no es <1000)|

**Resultado:**
| Categoria   | Numero_Productos | Stock_Total | Precio_Promedio |
|-------------|------------------|-------------|-----------------|
| Electrónica | 4                | 580         | 247.50          |

---

### Ejemplo 3: HAVING con Condiciones Complejas

```sql
-- Categorías donde:
-- - El precio promedio está entre 10 y 300
-- - La cantidad total es mayor que 200
-- - Tienen al menos 2 productos diferentes
SELECT
    i.Categoria,
    AVG(i.Precio) AS Precio_Promedio,
    SUM(i.Cantidad) AS Stock_Total,
    COUNT(*) AS Productos_Distintos
FROM
    Inventario i
GROUP BY i.Categoria
HAVING 
    AVG(i.Precio) BETWEEN 10 AND 300
    AND SUM(i.Cantidad) > 200
    AND COUNT(*) >= 2;
```

**Resultado:**
| Categoria   | Precio_Promedio | Stock_Total | Productos_Distintos |
|-------------|-----------------|-------------|---------------------|
| Electrónica | 247.50          | 580         | 4                   |
| Muebles     | 125.00          | 250         | 2                   |

*Papelería se excluye porque su precio promedio (3.25) no está entre 10 y 300*

---

## GROUP BY vs HAVING - Diferencias Clave

### Tabla Comparativa Detallada

| Característica | GROUP BY | HAVING |
|----------------|----------|--------|
| **Propósito** | Agrupar filas con valores comunes | Filtrar grupos después de la agregación |
| **Momento de ejecución** | Después de WHERE, antes de HAVING | Después de GROUP BY, antes de ORDER BY |
| **Qué filtra** | No filtra, solo organiza | Filtra grupos completos |
| **Puede usar agregaciones** | No en la cláusula misma | Sí, es su propósito principal |
| **Puede usar alias** | No | Sí (en algunos motores) |
| **Equivalente** | "Para cada categoría..." | "Mostrar solo categorías que..." |

### Ejemplo que muestra la diferencia:

```sql
-- Encontrar categorías con más de 200 unidades totales
-- que tengan al menos un producto con precio > 100

SELECT
    i.Categoria,
    SUM(i.Cantidad) AS Stock_Total,
    COUNT(*) AS Productos,
    MAX(i.Precio) AS Precio_Maximo
FROM
    Inventario i
WHERE 
    i.Precio > 100  -- Filtra productos INDIVIDUALES antes de agrupar
GROUP BY 
    i.Categoria
HAVING 
    SUM(i.Cantidad) > 200;  -- Filtra GRUPOS después de agrupar
```

**Paso a paso:**
1. **WHERE i.Precio > 100**: Solo considera productos con precio > 100
   - Electrónica: Laptop (750) e Impresora (200)
   - Muebles: Mesa (150)
   - Papelería: Ninguno

2. **GROUP BY Categoria**: Agrupa los productos filtrados

3. **SUM(i.Cantidad) > 200**: Filtra categorías con stock total > 200
   - Electrónica: 50 + 30 = 80 ❌ (no pasa)
   - Muebles: 100 ✅ (pasa)

**Resultado:**
| Categoria | Stock_Total | Productos | Precio_Maximo |
|-----------|-------------|-----------|---------------|
| Muebles   | 100         | 1         | 150.00        |

---

## Ejemplos Avanzados con Subconsultas

### Ejemplo 1: Comparación con Promedio Global

```sql
-- Categorías cuyo stock total es mayor que el promedio de todas las categorías
SELECT
    i.Categoria,
    SUM(i.Cantidad) AS Stock_Total
FROM
    Inventario i
GROUP BY i.Categoria
HAVING SUM(i.Cantidad) > (
    SELECT AVG(StockPorCategoria)
    FROM (
        SELECT 
            Categoria, 
            SUM(Cantidad) AS StockPorCategoria
        FROM Inventario
        GROUP BY Categoria
    ) AS Promedios
);
```

**Desglose:**
1. Subconsulta más interna calcula stock por categoría: (580, 250, 1500)
2. AVG de esos valores: (580 + 250 + 1500) / 3 = 776.67
3. HAVING filtra categorías con stock > 776.67

**Resultado:**
| Categoria   | Stock_Total |
|-------------|-------------|
| Papelería   | 1500        |

---

### Ejemplo 2: Categorías con Rendimiento Superior

```sql
-- Categorías con valor de inventario superior al promedio
SELECT
    i.Categoria,
    SUM(i.Cantidad * i.Precio) AS Valor_Inventario,
    COUNT(*) AS Productos,
    AVG(i.Precio) AS Precio_Promedio
FROM
    Inventario i
GROUP BY i.Categoria
HAVING SUM(i.Cantidad * i.Precio) > (
    SELECT AVG(ValorTotal)
    FROM (
        SELECT 
            Categoria,
            SUM(Cantidad * Precio) AS ValorTotal
        FROM Inventario
        GROUP BY Categoria
    ) AS Valores
);
```

**Cálculos:**
| Categoria   | Valor Inventario | ¿Supera promedio? (29,166.67) |
|-------------|------------------|-------------------------------|
| Electrónica | 53,500           | ✅ Sí                          |
| Muebles     | 30,000           | ✅ Sí                          |
| Papelería   | 4,000            | ❌ No                          |

**Resultado:**
| Categoria   | Valor_Inventario | Productos | Precio_Promedio |
|-------------|------------------|-----------|-----------------|
| Electrónica | 53,500.00        | 4         | 247.50          |
| Muebles     | 30,000.00        | 2         | 125.00          |

---

### Ejemplo 3: Porcentaje del Total

```sql
-- Categorías que representan más del 30% del stock total
SELECT
    i.Categoria,
    SUM(i.Cantidad) AS Stock_Categoria,
    (SUM(i.Cantidad) * 100.0 / (SELECT SUM(Cantidad) FROM Inventario)) AS Porcentaje_Total
FROM
    Inventario i
GROUP BY i.Categoria
HAVING 
    (SUM(i.Cantidad) * 100.0 / (SELECT SUM(Cantidad) FROM Inventario)) > 30;
```

**Stock total general:** 580 + 250 + 1500 = 2330

| Categoria   | Stock | Porcentaje | ¿>30%? |
|-------------|-------|------------|--------|
| Electrónica | 580   | 24.9%      | ❌      |
| Muebles     | 250   | 10.7%      | ❌      |
| Papelería   | 1500  | 64.4%      | ✅      |

**Resultado:**
| Categoria   | Stock_Categoria | Porcentaje_Total |
|-------------|-----------------|------------------|
| Papelería   | 1500            | 64.4             |

---

## Ejercicios Prácticos Resueltos

### Ejercicio 1: Análisis de Rentabilidad por Categoría

```sql
/*
Encontrar categorías que:
- Tengan un valor total de inventario mayor a 10,000
- Precio promedio superior a 50
- Al menos 3 productos diferentes
- Stock total entre 200 y 1000 unidades
*/

SELECT
    i.Categoria,
    COUNT(*) AS Numero_Productos,
    SUM(i.Cantidad) AS Stock_Total,
    AVG(i.Precio) AS Precio_Promedio,
    SUM(i.Cantidad * i.Precio) AS Valor_Total
FROM
    Inventario i
GROUP BY i.Categoria
HAVING 
    SUM(i.Cantidad * i.Precio) > 10000
    AND AVG(i.Precio) > 50
    AND COUNT(*) >= 3
    AND SUM(i.Cantidad) BETWEEN 200 AND 1000;
```

**Resultado:**
| Categoria   | Numero_Productos | Stock_Total | Precio_Promedio | Valor_Total |
|-------------|------------------|-------------|-----------------|-------------|
| Electrónica | 4                | 580         | 247.50          | 53,500.00   |

---

### Ejercicio 2: Análisis Temporal

```sql
/*
Analizar ingresos por mes, mostrando solo meses donde:
- Se recibieron más de 2 productos
- El valor total del inventario recibido supera los 5,000
- La cantidad promedio por producto es mayor a 100
*/

SELECT
    MONTH(i.FechaIngreso) AS Mes,
    COUNT(*) AS Productos_Recibidos,
    SUM(i.Cantidad) AS Unidades_Recibidas,
    AVG(i.Cantidad) AS Promedio_Unidades,
    SUM(i.Cantidad * i.Precio) AS Valor_Recibido
FROM
    Inventario i
GROUP BY MONTH(i.FechaIngreso)
HAVING 
    COUNT(*) > 2
    AND SUM(i.Cantidad * i.Precio) > 5000
    AND AVG(i.Cantidad) > 100;
```

| Mes | Productos_Recibidos | Unidades_Recibidas | Promedio_Unidades | Valor_Recibido |
|-----|---------------------|--------------------|-------------------|----------------|
| 1   | 5                   | 800                | 160.00            | 45,250.00      |

---

### Ejercicio 3: Segmentación Avanzada

```sql
/*
Clasificar categorías por rendimiento y filtrar las de alto rendimiento
*/

WITH ClasificacionCategorias AS (
    SELECT
        i.Categoria,
        SUM(i.Cantidad) AS Stock_Total,
        AVG(i.Precio) AS Precio_Promedio,
        SUM(i.Cantidad * i.Precio) AS Valor_Total,
        CASE 
            WHEN SUM(i.Cantidad * i.Precio) > 30000 THEN 'Alto'
            WHEN SUM(i.Cantidad * i.Precio) > 10000 THEN 'Medio'
            ELSE 'Bajo'
        END AS Rendimiento
    FROM
        Inventario i
    GROUP BY i.Categoria
)
SELECT *
FROM ClasificacionCategorias
WHERE Rendimiento = 'Alto';
```

**Resultado:**
| Categoria   | Stock_Total | Precio_Promedio | Valor_Total | Rendimiento |
|-------------|-------------|-----------------|-------------|-------------|
| Electrónica | 580         | 247.50          | 53,500.00   | Alto        |

---

## Errores Comunes y Soluciones

### Error 1: Usar WHERE con Agregaciones

```sql
-- INCORRECTO
SELECT Categoria, SUM(Cantidad)
FROM Inventario
WHERE SUM(Cantidad) > 500   -- Error!
GROUP BY Categoria;

-- CORRECTO
SELECT Categoria, SUM(Cantidad)
FROM Inventario
GROUP BY Categoria
HAVING SUM(Cantidad) > 500;
```

### Error 2: Olvidar Columnas en GROUP BY

```sql
-- INCORRECTO
SELECT 
    Categoria,
    Producto,        -- Error: Producto no está en GROUP BY
    SUM(Cantidad)
FROM Inventario
GROUP BY Categoria;

-- CORRECTO (si realmente quieres por producto)
SELECT 
    Categoria,
    Producto,
    SUM(Cantidad)
FROM Inventario
GROUP BY Categoria, Producto;

-- O CORRECTO (si quieres solo por categoría, quita Producto)
SELECT 
    Categoria,
    SUM(Cantidad)
FROM Inventario
GROUP BY Categoria;
```

### Error 3: Usar Alias en HAVING (depende del motor)

```sql
-- En SQL Server, esto funciona
SELECT 
    Categoria,
    SUM(Cantidad) AS Stock_Total
FROM Inventario
GROUP BY Categoria
HAVING SUM(Cantidad) > 500;  -- Usar la función, no el alias

-- En MySQL, podrías usar el alias
SELECT 
    Categoria,
    SUM(Cantidad) AS Stock_Total
FROM Inventario
GROUP BY Categoria
HAVING Stock_Total > 500;     -- MySQL permite alias
```

### Error 4: Confundir Orden de Ejecución

```sql
-- INCORRECTO (lógicamente)
SELECT 
    Categoria,
    SUM(Cantidad) AS Stock_Total
FROM Inventario
WHERE Stock_Total > 500        -- Stock_Total no existe cuando WHERE se ejecuta
GROUP BY Categoria;

-- CORRECTO
SELECT 
    Categoria,
    SUM(Cantidad) AS Stock_Total
FROM Inventario
GROUP BY Categoria
HAVING SUM(Cantidad) > 500;
```

---

## Resumen y Conclusiones

### Puntos Clave sobre GROUP BY

1. **Propósito fundamental**: Convertir filas detalladas en filas resumidas por grupos
2. **Regla de oro**: Toda columna en SELECT debe estar en GROUP BY o ser función de agregación
3. **Múltiples columnas**: Puedes agrupar por varias columnas para jerarquías
4. **Expresiones**: También puedes agrupar por resultados de expresiones

### Puntos Clave sobre HAVING

1. **Propósito**: Filtrar grupos después de la agregación
2. **Diferencia con WHERE**: WHERE filtra filas, HAVING filtra grupos
3. **Funciones de agregación**: HAVING puede usarlas, WHERE no
4. **Orden de ejecución**: HAVING se ejecuta después de GROUP BY

### Comparación Visual del Flujo de Ejecución

```
DATOS CRUDOS (tabla Inventario)
    │
    ▼
WHERE (filtra filas individuales)
    │
    ▼
GROUP BY (agrupa filas en categorías)
    │
    ▼
Funciones Agregadas (SUM, AVG, COUNT, etc.)
    │
    ▼
HAVING (filtra grupos completos)
    │
    ▼
SELECT (proyecta columnas finales)
    │
    ▼
ORDER BY (ordena resultados)
```

### Casos de Uso Típicos

| Situación | GROUP BY | HAVING |
|-----------|----------|--------|
| "Ventas totales por región" | ✅ Sí | ❌ No necesario |
| "Regiones con ventas > 1000" | ✅ Sí | ✅ Sí |
| "Producto más caro por categoría" | ✅ Sí | ❌ No necesario |
| "Categorías con precio promedio > 50" | ✅ Sí | ✅ Sí |
| "Clientes que compraron en 2024" | ✅ Sí | ❌ No necesario |
| "Clientes con más de 5 compras" | ✅ Sí | ✅ Sí |

### Fórmula para Consultas Exitosas

Para construir consultas con GROUP BY y HAVING correctamente:

1. **Paso 1**: Decide qué grupos quieres (categorías, meses, regiones)
2. **Paso 2**: Define qué cálculos necesitas por grupo (sumas, promedios)
3. **Paso 3**: Determina si necesitas filtrar filas individuales (usa WHERE)
4. **Paso 4**: Determina si necesitas filtrar grupos (usa HAVING)
5. **Paso 5**: Construye la consulta en orden lógico

### Ejemplo de Síntesis

```sql
-- Consulta que combina todo lo aprendido
SELECT
    i.Categoria,
    COUNT(DISTINCT i.Producto) AS Productos_Unicos,
    SUM(i.Cantidad) AS Stock_Total,
    AVG(i.Precio) AS Precio_Promedio,
    SUM(i.Cantidad * i.Precio) AS Valor_Total,
    CASE 
        WHEN SUM(i.Cantidad * i.Precio) > 50000 THEN 'Premium'
        WHEN SUM(i.Cantidad * i.Precio) > 10000 THEN 'Estándar'
        ELSE 'Económico'
    END AS Clasificacion
FROM
    Inventario i
WHERE
    i.FechaIngreso >= '2024-01-01'  -- Solo productos del 2024
GROUP BY
    i.Categoria
HAVING
    COUNT(DISTINCT i.Producto) >= 2  -- Al menos 2 productos
    AND AVG(i.Precio) > 10            -- Precio promedio > 10
ORDER BY
    Valor_Total DESC;
```

Este ejemplo muestra cómo WHERE, GROUP BY, HAVING, funciones de agregación y expresiones trabajan juntos para crear análisis de datos poderosos y significativos.

---

## Nota Final

El dominio de GROUP BY y HAVING es esencial para cualquier profesional que trabaje con bases de datos. Estas herramientas transforman datos crudos en información valiosa para la toma de decisiones. Practica con diferentes conjuntos de datos y situaciones para internalizar estos conceptos.


El formato MD está optimizado para GitHub con una estructura clara y navegable.|

