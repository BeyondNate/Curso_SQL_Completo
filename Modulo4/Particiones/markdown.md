# Ejemplo de Optimización de Consultas en SQL Server

## Índice
1. [Introducción](#introducción)
2. [Estructura de la Base de Datos](#estructura-de-la-base-de-datos)
3. [Creación de Tablas y Relaciones](#creación-de-tablas-y-relaciones)
4. [Inserción de Datos de Prueba](#inserción-de-datos-de-prueba)
5. [Optimización de Consultas](#optimización-de-consultas)
   - [Índices](#índices)
   - [Estadísticas](#estadísticas)
   - [Plan de Ejecución](#plan-de-ejecución)
6. [Particionamiento de Tablas](#particionamiento-de-tablas)
   - [Función de Partición](#función-de-partición)
   - [Esquema de Partición](#esquema-de-partición)
   - [Creación de Tabla Particionada](#creación-de-tabla-particionada)
7. [Monitoreo y Mantenimiento](#monitoreo-y-mantenimiento)

## Introducción

Este documento presenta un ejemplo práctico de cómo optimizar consultas en SQL Server utilizando diferentes técnicas como índices, estadísticas y particionamiento de tablas. El ejemplo se basa en una base de datos de plantas medicinales.

## Estructura de la Base de Datos

La base de datos `BDPLANTAS` consta de tres tablas principales:
- **Regiones**: Almacena las regiones donde se encuentran las plantas
- **Plantas**: Contiene información de las plantas medicinales
- **Observaciones**: Registra observaciones sobre las plantas

## Creación de Tablas y Relaciones

```sql
CREATE DATABASE BDPLANTAS
go
USE BDPLANTAS
go

-- Creación de la tabla Regiones (debe crearse primero por la FK en Plantas)
CREATE TABLE Regiones(
   RegionID INT PRIMARY KEY IDENTITY(1,1),
   NombreRegion NVARCHAR(100) NOT NULL
)
go

-- Creación de la tabla Plantas con FK a Regiones
CREATE TABLE Plantas(
	PlantaID INT Primary key IDENTITY(1,1),
	Nombre NVARCHAR(100) NOT NULL,
	Categoria NVARCHAR(50),
	Beneficio NVARCHAR(255),
	FechaDescubrimiento Date,
	RegionID INT Foreign Key References Regiones(RegionID)
)
go

-- Creación de la tabla Observaciones con FK a Plantas
CREATE TABLE Observaciones(
   ObservacionID INT PRIMARY KEY IDENTITY(1,1),
   PlantaID INT Foreign key References Plantas(PlantaID),
   Descripcion NVARCHAR(255),
   FechaObservacion Date
)
go
```

## Inserción de Datos de Prueba

```sql
-- Insertar regiones
Insert Into Regiones(NombreRegion)Values
('Amazonas'),
('Himalayas'),
('Andes');

-- Insertar plantas
Insert into plantas(Nombre,Categoria,Beneficio,FechaDescubrimiento,RegionID) VALUES
('Echinacea', 'Inmunológico', 'Fortalece el sistema inmune', '1800-05-10',1),
('Ginseng', 'Energizante', 'Aumenta la energía y reduce el estrés', '1750-08-25',2),
('Valeriana', 'Sedante', 'Reduce la ansiedad y mejora el sueño', '1825-11-12',3);

-- Insertar observaciones
INSERT INTO Observaciones(PlantaID,Descripcion,FechaObservacion) Values
(1, 'Efecto positivo en resfriados comunes', '2023-01-10'),
(2, 'Aumenta la resistencia física', '2022-07-15'),
(3, 'Eficaz contra insomnio', '2021-05-20');
```

## Optimización de Consultas

### Índices

Los índices mejoran significativamente la velocidad de las consultas que buscan datos específicos.

```sql
-- Consulta sin optimizar (realiza escaneo completo de tabla)
SELECT * FROM Plantas Where Nombre LIKE '%Ginseng%';

-- Creación de índice para optimizar búsquedas por nombre
CREATE INDEX idx_plantas_nombres ON Plantas(Nombre);

-- Consulta optimizada (usa el índice)
SELECT * FROM Plantas Where Nombre LIKE 'Ginseng%';
```

**Tipos de búsqueda con LIKE:**
- `LIKE '%Ginseng%'`: Búsqueda que contiene - No usa índice eficientemente
- `LIKE 'Ginseng%'`: Búsqueda que comienza con - Puede usar índice

### Estadísticas

Las estadísticas ayudan al optimizador de consultas a tomar mejores decisiones.

```sql
-- Actualizar estadísticas manualmente
UPDATE STATISTICS Plantas;

-- Ver estadísticas de un índice
DBCC SHOW_STATISTICS('Plantas', 'idx_plantas_nombres');
```

### Plan de Ejecución

SQL Server proporciona herramientas para medir el rendimiento de las consultas:

```sql
-- Activar estadísticas de E/S y tiempo
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Ejecutar consulta para analizar su rendimiento
SELECT * FROM Plantas WHERE Nombre='Ginseng';

-- Desactivar estadísticas
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

**Interpretación de resultados:**
- **STATISTICS IO**: Muestra el número de lecturas lógicas y físicas
- **STATISTICS TIME**: Muestra el tiempo de CPU y tiempo transcurrido

## Particionamiento de Tablas

El particionamiento divide tablas grandes en partes más pequeñas y manejables.

### Función de Partición

Define cómo se dividirán los datos:

```sql
CREATE PARTITION FUNCTION pfObservaciones (DATE)
AS RANGE RIGHT FOR VALUES ('2021-01-01', '2022-01-01', '2023-01-01');
```

**Explicación**: 
- `RANGE RIGHT`: Los valores límite pertenecen al partición derecha
- Las particiones se crean para: <2021, 2021-2022, 2022-2023, >2023

### Esquema de Partición

Mapea las particiones a filegroups:

```sql
CREATE PARTITION SCHEME psObservaciones
AS PARTITION pfObservaciones ALL TO ([Primary]);
```

### Creación de Tabla Particionada

```sql
-- Crear tabla utilizando el esquema de partición
CREATE TABLE ObservacionesPart(
 ObservacionID INT,
 PlantaId int,
 Descripcion NVARCHAR(255),
 FechaObservacion Date
) ON psObservaciones(FechaObservacion);

-- Insertar datos en la tabla particionada
INSERT INTO ObservacionesPart (ObservacionID, PlantaId, Descripcion, FechaObservacion)
VALUES 
    (1, 1, 'Efecto positivo en resfriados comunes', '2023-01-10'),
    (2, 2, 'Aumenta la resistencia física', '2022-07-15'),
    (3, 3, 'Eficaz contra insomnio', '2021-05-20');
```

### Consultar Particiones

```sql
-- Ver información de las particiones
SELECT 
 partition_id,
 rows
FROM SYS.partitions
WHERE object_id = OBJECT_ID('ObservacionesPart');

-- Consultar datos de una partición específica
SELECT *
FROM ObservacionesPart
WHERE FechaObservacion >= '2021-01-01' 
  AND FechaObservacion < '2022-01-01';
```

## Monitoreo y Mantenimiento

### Scripts Útiles para Monitoreo

```sql
-- Ver todos los índices de una tabla
SELECT 
    i.name AS IndexName,
    i.type_desc,
    STATS_DATE(i.object_id, i.index_id) AS LastStatsUpdate
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('Plantas');

-- Ver tamaño de las particiones
SELECT 
    p.partition_number,
    p.rows,
    au.total_pages * 8 / 1024 AS SizeMB
FROM sys.partitions p
INNER JOIN sys.allocation_units au
    ON p.partition_id = au.container_id
WHERE p.object_id = OBJECT_ID('ObservacionesPart');
```

### Buenas Prácticas

1. **Índices:**
   - Crear índices en columnas frecuentemente buscadas
   - Evitar índices en columnas con muchos valores NULL
   - No sobredimensionar con demasiados índices

2. **Estadísticas:**
   - Actualizar estadísticas regularmente
   - Programar actualizaciones automáticas

3. **Particionamiento:**
   - Útil para tablas muy grandes (>1 millón de registros)
   - Facilita la eliminación de datos antiguos
   - Mejora el rendimiento en consultas por rango

## Conclusión

La optimización de consultas en SQL Server es un proceso continuo que requiere:
- Análisis de patrones de consulta
- Implementación de índices apropiados
- Mantenimiento regular de estadísticas
- Consideración de particionamiento para tablas grandes

Estas técnicas, cuando se aplican correctamente, pueden mejorar drásticamente el rendimiento de las bases de datos y la experiencia del usuario final.
