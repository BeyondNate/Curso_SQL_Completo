CREATE DATABASE BDPLANTAS
go
USE BDPLANTAS
go
CREATE TABLE Plantas(
	PlantaID INT Primary key IDENTITY(1,1),
	Nombre NVARCHAR(100) NOT NULL,
	Categoria NVARCHAR(50),
	Beneficio NVARCHAR(255),
	FechaDescubrimiento Date,
	RegionID INT Foreign Key References Regiones(RegionID))
go
Insert into plantas(Nombre,Categoria,Beneficio,FechaDescubrimiento,RegionID) VALUES
('Echinacea', 'Inmunológico', 'Fortalece el sistema inmune', '1800-05-10',1),
('Ginseng', 'Energizante', 'Aumenta la energía y reduce el estrés', '1750-08-25',2),
('Valeriana', 'Sedante', 'Reduce la ansiedad y mejora el sueño', '1825-11-12',3);
go
SELECT * From Plantas;
go
CREATE TABLE Regiones(
   RegionID INT PRIMARY KEY IDENTITY(1,1),
   NombreRegion NVARCHAR(100) NOT NULL)
go
Insert Into Regiones(NombreRegion)Values
('Amazonas'),('Himalayas'),('Andes');
Select * From Regiones
go
CREATE TABLE Observaciones(
   ObservacionID INT PRIMARY KEY IDENTITY(1,1),
   PlantaID INT Foreign key References Plantas(PlantaID),
   Descripcion NVARCHAR(255),
   FechaObservacion Date)
go   
INSERT INTO Observaciones(PlantaID,Descripcion,FechaObservacion) Values
(1, 'Efecto positivo en resfriados comunes', '2023-01-10'),
(2, 'Aumenta la resistencia física', '2022-07-15'),
(3, 'Eficaz contra insomnio', '2021-05-20');
go
Select * from Observaciones

/*
Optimizar Consultas
*/
SELECT * FROM Plantas Where Nombre LIKE '%Ginseng%';

--Creamos un Indice para Optimizar la Consulta
create index idx_plantas_nombres On Plantas(Nombre)
--CREATE INDEX idx_plantas_nombre ON Plantas(Nombre);
SELECT * FROM Plantas Where Nombre LIKE 'Ginseng%';

--Optimizaciones Con Estadisticas y Plan de Ejecuccion
SET STATISTICS IO ON;  --Cuantas Paginas de datos y de indice se leen desde el disco
SET STATISTICS TIME ON; --Cuanto Tarda la consulta en completarse
SELECT * FROM Plantas WHERE Nombre='Ginseng';
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

UPDATE STATISTICS Plantas;


--Optimizacion con Particionamientos de Tablas
 --Crear una funcion de particion
--DROP PARTITION FUNCTION pfObservaciones
CREATE PARTITION FUNCTION pfObservaciones (DATE)
AS RANGE RIGHT FOR VALUES ('2021-01-01', '2022-01-01', '2023-01-01');

--CREAR UN ESQUEMA DE PARTICION
--DROP PARTITION SCHEME  psObservaciones
CREATE PARTITION SCHEME psObservaciones
AS PARTITION pfObservaciones All TO ([Primary]);

--CREAR LA TABLA PARTICION
CREATE TABLE ObservacionesPart(
 ObservacionID INT,
 PlantaId int,
 Descripcion NVARCHAR(255),
 FechaObservacion Date) on psObservaciones(FechaObservacion);

--Llenar los registros en la tabla particionada
INSERT INTO ObservacionesPart (ObservacionID, Descripcion, FechaObservacion)
VALUES 
    (1, 'Efecto positivo en resfriados comunes', '2023-01-10'),
    (2, 'Aumenta la resistencia física', '2022-07-15'),
    (3, 'Eficaz contra insomnio', '2021-05-20');

 
--Consultar las Particiones de la Tabla
Select 
 partition_id,
 rows
FROM SYS.partitions
WHERE object_id=OBJECT_ID('ObservacionesPart')

Select *
From ObservacionesPart
WHERE FechaObservacion >='2021-01-01' AND FechaObservacion <'2022-01-01'
