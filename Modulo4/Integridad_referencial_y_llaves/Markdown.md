# Ejemplo de Integridad Referencial en SQL Server

## Índice
1. [Introducción](#introducción)
2. [Estructura de la Base de Datos](#estructura-de-la-base-de-datos)
3. [Creación de Tablas](#creación-de-tablas)
4. [Inserción de Datos](#inserción-de-datos)
5. [Integridad Referencial](#integridad-referencial)
6. [Acciones en la Integridad Referencial](#acciones-en-la-integridad-referencial)
   - [CASCADE](#cascade)
   - [SET NULL](#set-null)
   - [NO ACTION / RESTRICT](#no-action--restrict)
7. [Gestión de Constraints](#gestión-de-constraints)
8. [Ejemplos Prácticos](#ejemplos-prácticos)

## Introducción

Este documento muestra un ejemplo práctico de cómo implementar y gestionar la integridad referencial en SQL Server. La integridad referencial es un concepto fundamental en bases de datos relacionales que garantiza la consistencia de las relaciones entre tablas.

## Estructura de la Base de Datos

El ejemplo utiliza dos tablas relacionadas:
- **Clientes**: Tabla padre que almacena información de clientes
- **Pedidos**: Tabla hija que registra los pedidos realizados por los clientes

## Creación de Tablas

```sql
CREATE DATABASE bdejemploir;

use bdejemploir;

CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,       -- Clave primaria en la tabla Clientes
    Nombre NVARCHAR(100) NOT NULL
);

CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY,        -- Clave primaria en la tabla Pedidos
    ClienteID INT,                   -- Clave foránea en la tabla Pedidos
    FechaPedido DATETIME,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)  -- Definimos la relación
);
```

## Inserción de Datos

```sql
INSERT INTO Clientes (ClienteID, Nombre)
VALUES (1, 'Juan Pérez'),
       (2, 'María García'),
       (3, 'Carlos López');

INSERT INTO Pedidos (PedidoID, ClienteID, FechaPedido)
VALUES (101, 1, '2025-01-23'),
       (102, 1, '2025-01-24'),
       (103, 2, '2025-01-25'),
       (104, 3, '2025-01-26');

select * from pedidos;
```

## Integridad Referencial

La integridad referencial asegura que:
- No se pueden insertar registros en la tabla hija con valores de clave foránea que no existan en la tabla padre
- No se pueden eliminar registros de la tabla padre si existen registros relacionados en la tabla hija (dependiendo de la acción configurada)
- No se pueden modificar valores de clave primaria en la tabla padre si existen registros relacionados (dependiendo de la acción configurada)

## Acciones en la Integridad Referencial

SQL Server permite configurar diferentes acciones para mantener la integridad referencial cuando se actualizan o eliminan registros en la tabla padre:

### CASCADE

Propaga los cambios de la tabla padre a la tabla hija:
- **ON DELETE CASCADE**: Si se elimina un registro en la tabla padre, se eliminan automáticamente todos los registros relacionados en la tabla hija
- **ON UPDATE CASCADE**: Si se actualiza la clave primaria en la tabla padre, se actualiza automáticamente el valor de la clave foránea en la tabla hija

### SET NULL

Cuando se elimina o actualiza un registro en la tabla padre, los valores de la clave foránea en la tabla hija se establecen como NULL:
- Requiere que la columna de clave foránea acepte valores NULL
- Útil cuando queremos mantener el registro histórico pero sin relación con el padre

### NO ACTION / RESTRICT

Impide la actualización o eliminación en la tabla padre si existen registros relacionados en la tabla hija:
- Es el comportamiento por defecto
- Garantiza que no se pierdan relaciones existentes
- Genera un error si se intenta violar la integridad referencial

## Gestión de Constraints

### Consultar Constraints Existentes

```sql
-- Consultar claves foráneas de una tabla
select
    name
from
    sys.foreign_keys
where
    parent_object_id = OBJECT_ID('pedidos');

-- Método alternativo
SELECT name
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('PEDIDOS');
```

### Eliminar Constraints

```sql
ALTER TABLE PEDIDOS
DROP CONSTRAINT FK__Pedidos__Cliente__398D8EEE;
```

### Crear Constraints con Acciones Específicas

```sql
-- Ejemplo con CASCADE y SET NULL combinados
ALTER TABLE PEDIDOS
ADD CONSTRAINT FK_PEDIDOS_CLIENTES
FOREIGN KEY (CLIENTEID) REFERENCES CLIENTES(CLIENTEID)
ON DELETE CASCADE
ON UPDATE SET NULL;

-- Ejemplo con NO ACTION
ALTER TABLE PEDIDOS
DROP CONSTRAINT FK_PEDIDOS_CLIENTES;

ALTER TABLE PEDIDOS
ADD CONSTRAINT FK_PEDIDOS_CLIENTES
FOREIGN KEY (CLIENTEID) REFERENCES CLIENTES(CLIENTEID)
ON DELETE NO ACTION;
```

## Ejemplos Prácticos

### Ejemplo 1: Comportamiento CASCADE

```sql
-- Configurar CASCADE para DELETE
ALTER TABLE PEDIDOS
ADD CONSTRAINT FK_PEDIDOS_CLIENTES
FOREIGN KEY (CLIENTEID) REFERENCES CLIENTES(CLIENTEID)
ON DELETE CASCADE;

-- Eliminar un cliente
DELETE FROM Clientes WHERE ClienteID=1;
-- Resultado: Se elimina el cliente y TODOS sus pedidos automáticamente
```

### Ejemplo 2: Comportamiento SET NULL

```sql
-- Configurar SET NULL para UPDATE
ALTER TABLE PEDIDOS
ADD CONSTRAINT FK_PEDIDOS_CLIENTES
FOREIGN KEY (CLIENTEID) REFERENCES CLIENTES(CLIENTEID)
ON UPDATE SET NULL;

-- Actualizar ID de cliente
UPDATE CLIENTES
SET CLIENTEID = 99
WHERE ClienteID = 2;
-- Resultado: Los pedidos del cliente 2 quedan con ClienteID = NULL
```

### Ejemplo 3: Comportamiento NO ACTION

```sql
-- Configurar NO ACTION para DELETE
ALTER TABLE PEDIDOS
ADD CONSTRAINT FK_PEDIDOS_CLIENTES
FOREIGN KEY (CLIENTEID) REFERENCES CLIENTES(CLIENTEID)
ON DELETE NO ACTION;

-- Intentar eliminar un cliente con pedidos
DELETE FROM CLIENTES WHERE ClienteID = 3;
-- Resultado: Error - No se puede eliminar porque existen registros relacionados
```

## Consideraciones Importantes

1. **Diseño de Base de Datos**: Elegir la acción apropiada depende de los requisitos del negocio
2. **Rendimiento**: Las operaciones CASCADE pueden afectar el rendimiento si se eliminan muchos registros
3. **Integridad de Datos**: NO ACTION es la opción más segura pero puede requerir más lógica de aplicación
4. **Mantenimiento**: Documentar claramente qué acciones se utilizan en cada relación

## Conclusión

La integridad referencial es esencial para mantener la consistencia de los datos en bases de datos relacionales. SQL Server proporciona flexibilidad para elegir cómo manejar las relaciones entre tablas mediante las diferentes acciones (CASCADE, SET NULL, NO ACTION), permitiendo adaptarse a diferentes escenarios y requisitos de negocio.
