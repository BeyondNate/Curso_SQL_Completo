/*
Veremos ahora un ejemplo de Group by y having
Crearemos primero nuestra database y una tabla de ejemplo
junto con la insercion de datos
*/
create database EmpresaZ;
go
use EmpresaZ;
go


create table Inventario(
	ID int identity(1,1) primary key,
	Producto nvarchar(50),
	Categoria nvarchar(70),
	Cantidad int,
	Precio decimal(10,2),
	FechaIngreso date
);

go


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

select * from Inventario;

-- Agrupemos los productos por categoria junto a su cantidad total
select
	i.Categoria,
	sum(i.Cantidad) as Cantidad_Total
from
	Inventario i
group by i.Categoria;

-- Filtrar los productos por categoria y una cantidad mayor a 500

select
	i.Categoria,
	sum(i.Cantidad) as Cantidad_Total
from
	Inventario i
group by i.Categoria
having sum(i.Cantidad) > 500; -- recordemos que el having opera con datos agregados despues del group by


-- calcular el precio promedio y el total de productos	por categoria
select
	i.Categoria,
	avg(i.Precio) as Precio_Promedio,
	sum(i.Cantidad) as Cantidad_por_Categoria
from
	Inventario i
group by i.Categoria;

-- Consultas anidadas
--		Filtre por categorias los precios promedios de la categoria mayores al precio promedio del inventario completo

select
	AVG(i.Precio)
from
	Inventario i -- Recomiendo ir de adentro para afuera, en este caso primero veremos el promedio de todo el inventario

select
	i.Categoria,
	AVG(i.Precio) as Precio_Categoria
from
	Inventario i
group by i.Categoria
having	AVG(i.Precio) > (
				select
					avg(ij.Precio) 
				from Inventario ij); -- para evitar errores en la consulta le daremos otro "nickname"

-- Categorias con un precio promedio superior a 50 y un total de productos menor a 800
select
	i.Categoria,
	avg(i.Precio) as PrecioPromedio
from
	Inventario i
group by
	i.Categoria
having
	avg(i.Precio) > 50 and
	sum(i.Cantidad) < 800;

-- categorias cuyo total de productos promedio supera al promedio global de productos por categoria	
	select
		i.Categoria,
		sum(i.Cantidad) as CantidadTotal
	from
		Inventario i
	group by
		i.Categoria
	having
		sum(i.Cantidad) > (
			select
				avg(ij.Cantidad) * count(distinct(ij.Categoria))
			from
				Inventario ij
		);
