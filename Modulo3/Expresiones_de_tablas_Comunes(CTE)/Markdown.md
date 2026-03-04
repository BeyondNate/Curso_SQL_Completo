
# Guía Completa de CTE (Common Table Expressions) en SQL Server
## Ejemplo Práctico con Tienda Virtual

Este documento contiene una guía completa sobre CTE en SQL Server, utilizando ejemplos prácticos de una tienda virtual.

## Índice
1. [Conceptos Fundamentales](#conceptos-fundamentales)
2. [Creación de la Base de Datos](#creación-de-la-base-de-datos)
3. [CTE Básico](#cte-básico)
4. [CTE Recursivo para Jerarquías](#cte-recursivo-para-jerarquías)
5. [Análisis del Funcionamiento Recursivo](#análisis-del-funcionamiento-recursivo)
6. [Resumen y Conclusiones](#resumen-y-conclusiones)

---

## Conceptos Fundamentales

```sql
/*
CTE (Common Table Expression)
¿QUÉ ES?
- Es una tabla "virtual" definida con WITH al inicio de la consulta
- Divide consultas complejas en pasos logicos
- Evita subconsultas repetidas
- Realiza consultas recursivas como jerarquias

Ventajas
- Organiza consultas complejas en pasos claros
- Evita repetir subconsultas
- No ocupa espacio en el disco, ya que solo existen durante la ejecucion de la consulta
*/
```

---

## Creación de la Base de Datos

```sql
CREATE DATABASE TIENDACTE;
USE TIENDACTE;

/*
Tabla Categorias
Almacena las categorias principales de productos
*/
CREATE TABLE Categorias (
    CategoriaID INT PRIMARY KEY IDENTITY(1,1),
    NombreCategoria NVARCHAR(50)
);  
go

/*
Tabla Productos
Almacena los productos con referencia a su categoria
*/
CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    NombreProducto NVARCHAR(50),
    Precio DECIMAL(10,2),
    Stock INT,
    CategoriaID INT FOREIGN KEY REFERENCES Categorias(CategoriaID)
);

-- Insercion de datos de ejemplo
INSERT INTO Categorias (NombreCategoria)
VALUES ('Electronica'), ('Ropa'), ('Hogar');
go

INSERT INTO Productos (NombreProducto, Precio, Stock, CategoriaID)
VALUES 
('Laptop Dell', 1200.00, 10, 1),
('Smartphone Samsung', 800.00, 25, 1),
('Camiseta Nike', 50.00, 100, 2),
('Sofa', 300.00, 5, 3);
```

---

## CTE Básico

### Ejemplo 1: Filtrar productos caros

**Descripción:** Creamos una tabla virtual con productos que cuestan mas de 500 y luego la consulta principal la ordena por precio.

```sql
/*
Ejemplo 1: CTE basico para filtrar productos caros
- Creamos una tabla virtual con productos que cuestan mas de 500
- Luego la consulta principal la ordena por precio
*/
with ProductosFiltrados as(
    select
        po.CategoriaID,
        po.NombreProducto,
        po.Precio
    from
        Productos po
    inner join
        Categorias c on c.CategoriaID = po.CategoriaID
    where
        po.Precio > 500
)
select
    *
from
    ProductosFiltrados
order by
    Precio desc;
```

**Resultado:**
| CategoriaID | NombreProducto | Precio |
|-------------|----------------|--------|
| 1 | Laptop Dell | 1200.00 |
| 1 | Smartphone Samsung | 800.00 |

**Explicación del proceso:**
```
1. El CTE "ProductosFiltrados" se ejecuta primero
2. Filtra los productos con precio > 500
3. La consulta principal toma ese resultado y lo ordena
4. El CTE solo existe durante esta consulta
```

---

## CTE Recursivo para Jerarquías

### Tabla de Jerarquías

```sql
/*
Tabla para ejemplos de jerarquias
- Esta tabla es autoreferenciada: un registro puede apuntar a otro como su padre
- CategoriaPadreID puede ser NULL para las categorias raiz
- Permite representar estructuras de arbol como categorias y subcategorias
*/
CREATE TABLE JerarquiaCategorias (
    CategoriaID INT PRIMARY KEY,
    NombreCategoria NVARCHAR(50),
    CategoriaPadreID INT NULL -- Permite nulo para categorias raiz
);
go

/*
Insercion de datos jerarquicos
Estructura:
- Electronica (raiz)
  - Computadoras (hija de Electronica)
    - Laptops (hija de Computadoras)
  - Celulares (hija de Electronica)
- Hogar (raiz)
  - Muebles (hija de Hogar)
*/
INSERT INTO JerarquiaCategorias (CategoriaID, NombreCategoria, CategoriaPadreID)
VALUES 
(1, 'Electronica', NULL),  -- Categoria raiz
(2, 'Computadoras', 1),     -- Hija de Electronica
(3, 'Laptops', 2),          -- Hija de Computadoras
(4, 'Celulares', 1),        -- Hija de Electronica
(5, 'Hogar', NULL),         -- Categoria raiz
(6, 'Muebles', 5);          -- Hija de Hogar
go

-- Verificamos los datos insertados
SELECT * FROM JerarquiaCategorias;
```

**Datos insertados:**
| CategoriaID | NombreCategoria | CategoriaPadreID |
|-------------|-----------------|------------------|
| 1 | Electronica | NULL |
| 2 | Computadoras | 1 |
| 3 | Laptops | 2 |
| 4 | Celulares | 1 |
| 5 | Hogar | NULL |
| 6 | Muebles | 5 |

---

### Ejemplo 2: CTE Recursivo para mostrar jerarquía de categorías

```sql
/*
Ejemplo 2: CTE Recursivo para mostrar jerarquia de categorias
- Muestra todas las categorias organizadas por nivel jerarquico
- La parte inicial (ancla) obtiene las categorias raiz (nivel 1)
- La parte recursiva obtiene las hijas y va incrementando el nivel
- La recursion termina cuando no hay mas hijas que encontrar
*/
with cte_Jerarquia as (
    -- NIVEL ANCLA: categorias raiz (las que no tienen padre)
    -- Estas son el punto de partida de la recursion
    select
        j.CategoriaID,
        j.NombreCategoria,
        j.CategoriaPadreID,
        1 as Nivel  -- Las raices siempre estan en nivel 1
    from
        JerarquiaCategorias j
    where
        j.CategoriaPadreID is null  -- Filtro para obtener solo raices
    
    union all
    
    -- NIVEL RECURSIVO: categorias hijas
    -- Se ejecuta repetidamente hasta que no encuentre mas registros
    -- Cada iteracion encuentra los hijos de las categorias ya encontradas
    select
        je.CategoriaID,
        je.NombreCategoria,
        je.CategoriaPadreID,
        cte.Nivel + 1  -- Incrementa el nivel en cada iteracion
    from
        JerarquiaCategorias je
        inner join cte_Jerarquia cte on je.CategoriaPadreID = cte.CategoriaID
        -- La condicion de join encuentra hijos cuyo padre fue encontrado antes
)
select * 
from cte_Jerarquia 
order by Nivel, NombreCategoria;  -- Ordena por nivel y luego alfabeticamente
```

**Resultado:**
| CategoriaID | NombreCategoria | CategoriaPadreID | Nivel |
|-------------|-----------------|------------------|-------|
| 1 | Electronica | NULL | 1 |
| 5 | Hogar | NULL | 1 |
| 4 | Celulares | 1 | 2 |
| 2 | Computadoras | 1 | 2 |
| 6 | Muebles | 5 | 2 |
| 3 | Laptops | 2 | 3 |

---

## Análisis del Funcionamiento Recursivo

### Visualización de la Jerarquía

```
Nivel 1 (Raices)
    ├── Electronica (ID: 1)
    │       ├── Nivel 2: Computadoras (ID: 2)
    │       │       └── Nivel 3: Laptops (ID: 3)
    │       └── Nivel 2: Celulares (ID: 4)
    │
    └── Hogar (ID: 5)
            └── Nivel 2: Muebles (ID: 6)
```

### Proceso Paso a Paso

```
ITERACION 1 (ANCLA):
- Busca categorias con CategoriaPadreID IS NULL
- Encuentra: Electronica (ID 1) y Hogar (ID 5)
- Asigna Nivel = 1 a ambas

ITERACION 2 (RECURSIVA):
- Busca categorias donde CategoriaPadreID = 1 (hijas de Electronica)
- Encuentra: Computadoras (ID 2) y Celulares (ID 4)
- Asigna Nivel = 2
- Busca categorias donde CategoriaPadreID = 5 (hijas de Hogar)
- Encuentra: Muebles (ID 6)
- Asigna Nivel = 2

ITERACION 3 (RECURSIVA):
- Busca categorias donde CategoriaPadreID = 2 (hijas de Computadoras)
- Encuentra: Laptops (ID 3)
- Asigna Nivel = 3
- Busca categorias donde CategoriaPadreID = 4 (hijas de Celulares)
- No encuentra (Celulares no tiene hijas)
- Busca categorias donde CategoriaPadreID = 6 (hijas de Muebles)
- No encuentra (Muebles no tiene hijas)

ITERACION 4 (RECURSIVA):
- Busca categorias donde CategoriaPadreID = 3 (hijas de Laptops)
- No encuentra
- FIN DE LA RECURSION
```

---

## Resumen y Conclusiones

### Comparativa: Con y Sin CTE

| Situación | Sin CTE | Con CTE |
|-----------|---------|---------|
| Consultas simples | Subconsultas anidadas | CTE básico legible |
| Jerarquías | Múltiples subconsultas complejas | CTE recursivo claro |
| Reutilización de lógica | Repetir mismo código | Definir una vez y reutilizar |
| Mantenimiento | Código difícil de modificar | Pasos lógicos separados |

### Tipos de CTE

| Tipo | Descripción | Ejemplo de uso |
|------|-------------|----------------|
| **CTE Básico** | Tabla virtual simple | Filtrar datos, cálculos intermedios |
| **CTE Recursivo** | Se llama a sí mismo | Jerarquías, árboles, organigramas |

### Reglas Importantes

```
1. Un CTE solo existe durante la ejecucion de la consulta
2. Debe usarse inmediatamente despues de su definicion
3. En CTE recursivo:
   - La parte ANCLA debe ir antes de UNION ALL
   - La parte RECURSIVA debe referenciar al propio CTE
   - Debe tener una condicion de terminacion explicita o implicita
```

### En Pocas Palabras

```
-- CTE basico: Para simplificar consultas complejas en pasos logicos
-- CTE recursivo: Perfecto para representar datos jerarquicos
-- Ventaja principal: Codigo mas limpio y mantenible
-- Sin CTE: Se necesitarian tecnicas y subconsultas mas avanzadas
```

### Aplicaciones Comunes

- **CTE Básico:** Reportes con múltiples cálculos, filtros complejos
- **CTE Recursivo:** Categorias de productos, organigramas de empleados, arboles familiares, rutas de navegacion

```sql
/*
CONCLUSIONES FINALES:

1. CTE basico:
   - Ideal para simplificar consultas complejas
   - Mejora la legibilidad del codigo
   - Permite reutilizar la misma logica en varias partes

2. CTE Recursivo:
   - Perfecto para representar datos jerarquicos (relacion de padres e hijos)
   - Optimiza consultas con estructuras de arbol
   - Muy util para categorias, organigramas, arboles familiares, etc.

3. Ventajas generales:
   - Organiza consultas complejas en pasos logicos
   - Evita repetir la misma subconsulta multiples veces
   - No ocupa espacio en disco (solo existe en memoria durante la ejecucion)
   - Hace el codigo mas mantenible y facil de entender
*/
```
