# Módulo 3: Consultas Avanzadas en SQL

Bienvenido al Módulo 3 del curso de SQL, en donde aprenderemos sobre las técnicas avanzadas de consulta. Este módulo cubre los siguientes temas:

## 3.1 Temas Principales

### 3.1.1 Funciones de Agregación
Las funciones de agregación permiten realizar cálculos sobre un conjunto de valores en una columna de una tabla. Las funciones más comunes incluyen:
- `COUNT()`: Cuenta el número de filas.
- `SUM()`: Suma los valores de una columna numérica.
- `AVG()`: Calcula el promedio de los valores en una columna.
- `MAX()`: Devuelve el valor máximo de una columna.
- `MIN()`: Devuelve el valor mínimo de una columna.

### 3.1.2 Uso de `GROUP BY` y `HAVING`
- **`GROUP BY`**: Se utiliza para agrupar filas con valores similares en una o más columnas y aplicar funciones de agregación sobre ellas.
- **`HAVING`**: Filtra los resultados de una agrupación en base a condiciones sobre funciones de agregación. A diferencia de `WHERE`, que no puede usarse con funciones agregadas, `HAVING` sí puede hacerlo.

### 3.1.3 Joins en SQL
Los **Joins** permiten combinar datos de dos o más tablas según una clave en común. Los tipos de **Join** son:
- **`INNER JOIN`**: Devuelve solo las filas que tienen coincidencias en ambas tablas.
- **`LEFT JOIN`**: Devuelve todas las filas de la tabla izquierda, y las coincidencias de la tabla derecha. Si no hay coincidencia, se mostrará `NULL`.
- **`RIGHT JOIN`**: Devuelve todas las filas de la tabla derecha, y las coincidencias de la tabla izquierda. Si no hay coincidencia, se mostrará `NULL`.
- **`FULL OUTER JOIN`**: Devuelve todas las filas de ambas tablas, mostrando `NULL` cuando no hay coincidencias.

### 3.1.4 Subconsultas y Consultas Correlacionadas
- **Subconsultas**: Son consultas dentro de otras consultas. Se utilizan para realizar operaciones más complejas y mejorar la legibilidad de las consultas.
- **Consultas Correlacionadas**: Son un tipo de subconsulta donde la subconsulta depende de la consulta principal. Se ejecutan para cada fila de la consulta principal.

### 3.1.5 Expresiones de Tabla Comunes (CTE)
Las **Expresiones de Tabla Comunes (CTE)** son consultas temporales que pueden ser referenciadas dentro de una consulta principal. Son útiles para consultas complejas y ayudan a mejorar la legibilidad y la organización del código SQL.

### 3.1.6 Consultas con Múltiples Tablas y Combinaciones Complejas
SQL permite realizar consultas que combinan múltiples tablas basadas en relaciones específicas. Esto permite obtener información más detallada y útil de los datos.

---

No te preocupes si no entiendes los conceptos al principio, con los ejemplos seguro te quedará más claro!

