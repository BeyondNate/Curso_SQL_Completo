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

-- Consultar todos los registros de la tabla Ventas
select * from Ventas;

-- Contar el total de ventas registradas en la tabla
select count(*) as TotalVentas from Ventas;

-- Contar el número de ventas por cada ciudad
select
	v.Ciudad, -- Ciudad en la que se realizó la venta
	count(*) as TotalVentas -- Total de ventas por ciudad
from
	Ventas v
group by
	v.Ciudad;

-- Sumar la cantidad total de unidades vendidas en todas las transacciones
select
	sum(v.Cantidad) as TotalCantidad -- Total de unidades vendidas
from
	Ventas v;

-- Sumar el valor total de las unidades vendidas por cada producto
select
	v.Producto, -- Nombre del producto
	sum(v.Cantidad * v.PrecioUnitario) as total -- Valor total de ventas por producto
from
	Ventas v
group by
	v.Producto;

-- Calcular el precio promedio de las unidades vendidas
select
	avg(v.PrecioUnitario) as Promedio -- Precio promedio de todas las unidades vendidas
from
	Ventas v;

-- Calcular el precio promedio de las unidades vendidas por cada ciudad
select
	v.Ciudad, -- Ciudad de venta
	avg(v.PrecioUnitario) as Promedio -- Precio promedio por ciudad
from
	Ventas v
group by
	v.Ciudad;

-- Obtener la cantidad máxima de productos vendidos en una sola transacción
select
	max(v.Cantidad) as MaxCantidad -- Cantidad máxima vendida en una transacción
from
	Ventas v;

-- Obtener la cantidad máxima vendida por cada tipo de producto
select
	v.Producto, -- Nombre del producto
	max(v.Cantidad) as MaxCantidad -- Cantidad máxima vendida por producto
from
	Ventas v
group by
	v.Producto;

-- Obtener la cantidad mínima vendida por cada tipo de producto
select
	v.Producto, -- Nombre del producto
	min(v.Cantidad) as MinCantidad -- Cantidad mínima vendida por producto
from
	Ventas v
group by
	v.Producto;

-- Calcular el total de ventas por ciudad en un rango de fechas específico
select
	v.Ciudad, -- Ciudad de la venta
	sum(v.Cantidad * v.PrecioUnitario) as TotalVentasPorCiudad -- Total de ventas por ciudad en el rango de fechas
from
	Ventas v
where
	FechaVenta between '2024-01-01' and '2024-01-03' -- Rango de fechas de la venta
group by
	v.Ciudad;

