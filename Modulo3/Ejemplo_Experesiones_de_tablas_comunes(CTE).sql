/*
CTE (Common Table Expression)
¿QUÉ ES?
-Es una tabla "virtual" definida con WITH al inicio de la consulta
-Divide consultas complejas en pasos logicos
-Evita subconsultas repetidas
-Realiza consultas recursivas como jerarquias

Ventajas
-Organiza consultas complejas en pasos claros
-Evita repetir subconsultas
-No ocupa espacio en el disco, ya que solo existen durante la ejecucion de la consulta
*/

CREATE DATABASE TIENDACTE;
USE TIENDACTE;

CREATE TABLE Categorias (
    CategoriaID INT PRIMARY KEY IDENTITY(1,1),
    NombreCategoria NVARCHAR(50)
);  
go

CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    NombreProducto NVARCHAR(50),
    Precio DECIMAL(10,2),
    Stock INT,
    CategoriaID INT FOREIGN KEY REFERENCES Categorias(CategoriaID)
);

INSERT INTO Categorias (NombreCategoria)
VALUES ('Electronica'), ('Ropa'), ('Hogar');
go

INSERT INTO Productos (NombreProducto, Precio, Stock, CategoriaID)
VALUES 
('Laptop Dell', 1200.00, 10, 1),
('Smartphone Samsung', 800.00, 25, 1),
('Camiseta Nike', 50.00, 100, 2),
('Sofa', 300.00, 5, 3);

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

INSERT INTO JerarquiaCategorias (CategoriaID, NombreCategoria, CategoriaPadreID)
VALUES 
(1, 'Electronica', NULL),  -- Categoria raiz
(2, 'Computadoras', 1),     -- Hija de Electronica
(3, 'Laptops', 2),          -- Hija de Computadoras
(4, 'Celulares', 1),        -- Hija de Electronica
(5, 'Hogar', NULL),         -- Categoria raiz
(6, 'Muebles', 5);          -- Hija de Hogar
go

SELECT * FROM JerarquiaCategorias;

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

/*
CONCLUSIONES SOBRE CTEs:

1. CTE basico:
   - Ideal para simplificar consultas complejas
   - Mejora la legibilidad del codigo
   - Permite reutilizar la misma logica en varias partes

2. CTE Recursivo:
   - Perfecto para representar datos jerarquicos (relacion de padres e hijos)
   - Optimiza consultas con estructuras de arbol
   - Sin CTE se necesitarian tecnicas y subconsultas mas avanzadas
   - Muy util para categorias, organigramas, arboles familiares, etc.

3. Ventajas generales:
   - Organiza consultas complejas en pasos logicos
   - Evita repetir la misma subconsulta multiples veces
   - No ocupa espacio en disco (solo existe en memoria durante la ejecucion)
   - Hace el codigo mas mantenible y facil de entender
*/
