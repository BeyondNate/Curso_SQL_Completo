# Ejemplo Completo: GROUP BY y HAVING en SQL

## Introducción
Este documento presenta ejemplos prácticos del uso de **GROUP BY** y **HAVING** en SQL Server, mostrando cómo agrupar y filtrar datos agregados en consultas de bases de datos.

---

##  1. Configuración Inicial

### 1.1 Creación de la Base de Datos
```sql
-- Crear la base de datos EmpresaZ
CREATE DATABASE EmpresaZ;
GO

-- Seleccionar la base de datos creada
USE EmpresaZ;
GO
```

### 1.2 Creación de la Tabla `Inventario`
```sql
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

**Estructura de la tabla:**
- `ID`: Identificador único autoincremental
- `Producto`: Nombre del producto (máx. 50 caracteres)
- `Categoria`: Categoría del producto (máx. 70 caracteres)
- `Cantidad`: Stock disponible (entero)
- `Precio`: Valor unitario (decimal con 2 posiciones)
- `FechaIngreso`: Fecha de ingreso al inventario

### 1.3 Inserción de Datos de Ejemplo
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

### 1.4 Verificación de Datos
```sql
SELECT * FROM Inventario;
```

**Resultado esperado:**
| ID | Producto   | Categoria   | Cantidad | Precio | FechaIngreso |
|----|------------|-------------|----------|---------|--------------|
| 1  | Laptop     | Electrónica | 50       | 750.00  | 2024-01-10   |
| 2  | Teclado    | Electrónica | 200      | 25.00   | 2024-01-12   |
| 3  | Mouse      | Electrónica | 300      | 15.00   | 2024-01-12   |
| 4  | Silla      | Muebles     | 150      | 100.00  | 2024-01-15   |
| 5  | Mesa       | Muebles     | 100      | 150.00  | 2024-01-20   |
| 6  | Notebook   | Papelería   | 500      | 5.00    | 2024-02-01   |
| 7  | Bolígrafo  | Papelería   | 1000     | 1.50    | 2024-02-01   |
| 8  | Impresora  | Electrónica | 30       | 200.00  | 2024-02-05   |

---

## 2. Ejemplos de GROUP BY

### 2.1 Agrupación Básica por Categoría
```sql
SELECT
    i.Categoria,
    SUM(i.Cantidad) AS Cantidad_Total
FROM
    Inventario i
GROUP BY i.Categoria;
```

**Explicación:**
- `GROUP BY i.Categoria`: Agrupa todos los registros que pertenecen a la misma categoría
- `SUM(i.Cantidad)`: Calcula la suma total de cantidades para cada grupo
- Cada categoría se convierte en una fila única con su total acumulado

**Resultado:**
| Categoria   | Cantidad_Total |
|-------------|----------------|
| Electrónica | 580            | (50+200+300+30)
| Muebles     | 250            | (150+100)
| Papelería   | 1500           | (500+1000)

---

## 3. Ejemplos de HAVING

### 3.1 Filtrar Grupos con HAVING
```sql
SELECT
    i.Categoria,
    SUM(i.Cantidad) AS Cantidad_Total
FROM
    Inventario i
GROUP BY i.Categoria
HAVING SUM(i.Cantidad) > 500;
```

** Diferencia clave: WHERE vs HAVING**
| WHERE                        | HAVING                          |
|------------------------------|---------------------------------|
| Filtra **filas individuales** | Filtra **grupos completos**     |
| Se ejecuta **antes** de GROUP BY | Se ejecuta **después** de GROUP BY |
| Opera sobre **datos crudos** | Opera sobre **datos agregados** |

**Resultado:**
| Categoria   | Cantidad_Total |
|-------------|----------------|
| Electrónica | 580            |
| Papelería   | 1500           |

*Solo muestra categorías con más de 500 unidades en total.*

---

### 3.2 Múltiples Agregaciones por Categoría
```sql
SELECT
    i.Categoria,
    AVG(i.Precio) AS Precio_Promedio,
    SUM(i.Cantidad) AS Cantidad_por_Categoria
FROM
    Inventario i
GROUP BY i.Categoria;
```

** Fórmulas aplicadas:**
- **Precio promedio**: `(suma de precios) ÷ (número de productos en la categoría)`
- **Cantidad total**: `suma de todas las cantidades en la categoría`

**Resultado:**
| Categoria   | Precio_Promedio | Cantidad_por_Categoria |
|-------------|-----------------|------------------------|
| Electrónica | 247.50          | 580                    |
| Muebles     | 125.00          | 250                    |
| Papelería   | 3.25            | 1500                   |

---

## 4. Consultas Anidadas (Subconsultas)

### 4.1 Categorías con Precio Promedio Superior al General
```sql
SELECT
    i.Categoria,
    AVG(i.Precio) AS Precio_Categoria
FROM
    Inventario i
GROUP BY i.Categoria
HAVING AVG(i.Precio) > (
    SELECT
        AVG(ij.Precio) 
    FROM Inventario ij
);
```

** Análisis paso a paso:**
1. **Subconsulta interna**: Calcula el precio promedio de TODOS los productos
   ```sql
   SELECT AVG(Precio) FROM Inventario
   -- Resultado: (750+25+15+100+150+5+1.5+200)/8 = 158.31
   ```

2. **Consulta principal**: 
   - Agrupa por categoría
   - Calcula promedio por categoría
   - Filtra categorías cuyo promedio > 158.31

**Resultado:**
| Categoria   | Precio_Categoria |
|-------------|------------------|
| Electrónica | 247.50           |
| Muebles     | 125.00           |

---

### 4.2 Condiciones Múltiples en HAVING
```sql
SELECT
    i.Categoria,
    AVG(i.Precio) AS PrecioPromedio
FROM
    Inventario i
GROUP BY i.Categoria
HAVING
    AVG(i.Precio) > 50 AND
    SUM(i.Cantidad) < 800;
```

**Lógica del filtro:**
1. `AVG(i.Precio) > 50`: Precio promedio mayor a 50
2. `SUM(i.Cantidad) < 800`: Menos de 800 unidades en total

**Resultado:**
| Categoria | PrecioPromedio |
|-----------|----------------|
| Muebles   | 125.00         |

*Solo Muebles cumple ambas condiciones.*

---

### 4.3 Comparación con Promedio Global de Productos
```sql
SELECT
    i.Categoria,
    SUM(i.Cantidad) AS CantidadTotal
FROM
    Inventario i
GROUP BY i.Categoria
HAVING SUM(i.Cantidad) > (
    SELECT
        AVG(ij.Cantidad) * COUNT(DISTINCT(ij.Categoria))
    FROM Inventario ij
);
```

**Cálculo detallado:**
1. **Subconsulta**: 
   ```sql
   -- Promedio global de cantidad = (50+200+300+150+100+500+1000+30)/8 = 291.25
   -- Categorías distintas = 3
   -- Resultado: 291.25 × 3 = 873.75
   ```

2. **Interpretación**: Busca categorías cuya cantidad total sea mayor que el "promedio esperado" si la cantidad total se distribuyera uniformemente entre categorías.

**Resultado:**
| Categoria   | CantidadTotal |
|-------------|---------------|
| Papelería   | 1500          |

---

## 5. Consejos Prácticos

### Mejores Prácticas
1. **Alias claros**: Use alias descriptivos para columnas calculadas
2. **Formato consistente**: Mantenga mayúsculas/minúsculas uniformes
3. **Comentarios**: Documente consultas complejas
4. **Pruebas incrementales**: Construya consultas paso a paso

### Errores Comunes
```sql
-- ERROR: Columna no agrupada ni agregada
SELECT Producto, SUM(Cantidad) 
FROM Inventario 
GROUP BY Categoria;  -- Producto no está en GROUP BY ni en función agregada

-- ERROR: WHERE con función agregada
SELECT Categoria, SUM(Cantidad)
FROM Inventario
WHERE SUM(Cantidad) > 100  -- ¡Usar HAVING aquí!
GROUP BY Categoria;
```



##  6. Ejercicio Propuesto

Intente resolver este problema:

```sql
/* 
RETO: Encontrar categorías que cumplen TODAS estas condiciones:
1. Tienen más de 2 productos diferentes
2. El precio promedio es menor a 200
3. La cantidad total es mayor a 300
4. Han ingresado productos en más de una fecha diferente
*/

```

---

## 7. Recursos Adicionales

### Funciones Agregadas Comunes
| Función | Descripción | Ejemplo |
|---------|-------------|---------|
| `COUNT()` | Cuenta registros | `COUNT(*)` |
| `SUM()` | Suma valores | `SUM(Cantidad)` |
| `AVG()` | Calcula promedio | `AVG(Precio)` |
| `MIN()` | Valor mínimo | `MIN(Precio)` |
| `MAX()` | Valor máximo | `MAX(Precio)` |
| `STDEV()` | Desviación estándar | `STDEV(Precio)` |

