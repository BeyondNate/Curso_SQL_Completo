# Control de Concurrencia y Bloqueos en SQL Server

## Introducción

En sistemas multiusuario, varias personas pueden acceder y modificar la base de datos al mismo tiempo.
Esto puede provocar:

* Pérdida de datos
* Inconsistencias
* Actualizaciones incorrectas
* Lecturas inválidas

Para evitar estos problemas, los motores de bases de datos como SQL Server implementan mecanismos de:

* Concurrencia
* Bloqueos (*Locks*)
* Control de transacciones
* Versionado de registros

---

# ¿Qué es la Concurrencia?

La **concurrencia** ocurre cuando varios usuarios o procesos intentan acceder y modificar datos simultáneamente.

---

## Ejemplo real

Imagina una tienda virtual:

* Usuario 1 compra una laptop.
* Usuario 2 compra la misma laptop al mismo tiempo.

Si no existe control de concurrencia:

❌ Ambos podrían comprar el último producto disponible.
❌ El stock quedaría incorrecto.
❌ Se generarían inconsistencias.

---

# Creación de la Base de Datos

```sql id="oqx4mk"
CREATE DATABASE bdtienda2;
GO

USE bdtienda2;
GO
```

---

# Creación de Tablas

## Tabla Productos

```sql id="7u3vw0"
CREATE TABLE Productos(
    ID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100),
    Precio DECIMAL(10,2),
    Sttock INT
);
```

---

## Explicación

### `IDENTITY(1,1)`

Genera IDs automáticos.

Ejemplo:

| ID |
| -- |
| 1  |
| 2  |
| 3  |

---

### `DECIMAL(10,2)`

Permite almacenar precios monetarios.

Ejemplo:

```text id="tov1bh"
1200.10
25.99
```

---

## Tabla Ventas

```sql id="1l0g8r"
CREATE TABLE Ventas(
    ID INT PRIMARY KEY IDENTITY(1,1),
    ProductoID INT,
    Cantidad INT,
    Fecha DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (ProductoID)
    REFERENCES Productos(ID)
);
```

---

# Relación entre tablas

```text id="9qb7nh"
Productos
   ↓
Ventas
```

La tabla `Ventas` depende de `Productos`.

---

# Insertar Datos

## Productos

```sql id="t7n8v0"
INSERT INTO Productos (Nombre, Precio, Sttock)
VALUES
('Laptop',1200.10,10),
('Mouse',25.99,50),
('Teclado',45.00,30);
```

---

## Ver Productos

```sql id="qtx8u8"
SELECT * FROM Productos;
```

Resultado esperado:

| ID | Nombre  | Precio  | Sttock |
| -- | ------- | ------- | ------ |
| 1  | Laptop  | 1200.10 | 10     |
| 2  | Mouse   | 25.99   | 50     |
| 3  | Teclado | 45.00   | 30     |

---

## Insertar Ventas

```sql id="spx2nl"
INSERT INTO Ventas(ProductoID, Cantidad)
VALUES
(1,2),
(2,5);
```

---

## Ver Ventas

```sql id="w0zj5l"
SELECT * FROM Ventas;
```

---

# Problemas de Concurrencia

Cuando múltiples usuarios modifican datos simultáneamente pueden ocurrir:

| Problema     | Descripción                   |
| ------------ | ----------------------------- |
| Dirty Read   | Leer datos no confirmados     |
| Lost Update  | Sobrescribir cambios          |
| Deadlock     | Bloqueo entre transacciones   |
| Phantom Read | Aparición de nuevos registros |

---

# Uso de Transacciones

Las transacciones ayudan a proteger operaciones críticas.

```sql id="uvkqkr"
BEGIN TRANSACTION;

-- Operaciones SQL

COMMIT;
```

---

# Bloqueos (Locks)

Los bloqueos impiden que otros usuarios modifiquen datos mientras una transacción está en proceso.

---

# Ejemplo 1: Bloqueo con BEGIN TRANSACTION

## Objetivo

Evitar que otro usuario modifique un producto mientras actualizamos el stock.

---

## Código

```sql id="2dv9nn"
BEGIN TRANSACTION;

    UPDATE Productos
    SET Sttock = Sttock - 1
    WHERE ID = 1;

    -- Simular operación larga
    WAITFOR DELAY '00:00:10';

COMMIT;
```

---

# Explicación paso a paso

## 1. Inicia la transacción

```sql id="9j7oj8"
BEGIN TRANSACTION;
```

SQL Server comienza una operación protegida.

---

## 2. Actualiza el stock

```sql id="7hl8xt"
UPDATE Productos
SET Sttock = Sttock - 1
WHERE ID = 1;
```

Reduce el stock de la laptop.

---

## 3. Espera 10 segundos

```sql id="dld0v9"
WAITFOR DELAY '00:00:10';
```

Simula una operación lenta.

Durante este tiempo:

* El registro permanece bloqueado.
* Otros usuarios deberán esperar.

---

## 4. Confirmar cambios

```sql id="4o0u7k"
COMMIT;
```

Se liberan los bloqueos.

---

# ¿Qué ocurre internamente?

```text id="j7kh7m"
Usuario 1 actualiza producto
            ↓
SQL Server bloquea el registro
            ↓
Otros usuarios esperan
            ↓
COMMIT
            ↓
Se libera el bloqueo
```

---

# Bloqueo Explícito con TABLOCKX

## ¿Qué hace TABLOCKX?

`TABLOCKX` aplica un:

> Bloqueo exclusivo a toda la tabla.

Mientras exista el bloqueo:

❌ Nadie puede modificar la tabla
❌ Nadie puede insertar registros
❌ Nadie puede actualizar datos

---

# Ejemplo con TABLOCKX

```sql id="16vxk8"
BEGIN TRANSACTION;

    SELECT * FROM Productos WITH(TABLOCKX);

    -- Tabla bloqueada completamente
    WAITFOR DELAY '00:00:10';

COMMIT;
```

---

# Explicación

## `WITH(TABLOCKX)`

Significa:

```text id="2z2g96"
TAB = Tabla
LOCK = Bloqueo
X = Exclusivo
```

Bloquea toda la tabla `Productos`.

---

# ¿Cuándo usar TABLOCKX?

Se utiliza cuando:

* Se harán cambios masivos.
* Importaciones grandes.
* Migraciones.
* Procesos críticos.

---

# Riesgos de TABLOCKX

⚠ Puede afectar el rendimiento.
⚠ Otros usuarios deberán esperar.
⚠ Puede generar cuellos de botella.

---

# Control de Versiones con ROWVERSION

## ¿Qué es ROWVERSION?

`ROWVERSION` genera automáticamente una versión única para cada fila modificada.

---

# Agregar ROWVERSION

```sql id="fjlwm4"
ALTER TABLE Productos
ADD RowVersion ROWVERSION;
```

---

# ¿Para qué sirve?

Permite detectar si otro usuario modificó el registro antes de guardar cambios.

Muy útil en:

* Sistemas web
* APIs
* ERP
* Aplicaciones concurrentes

---

# Ejemplo práctico

Supongamos:

| Usuario   | Acción                           |
| --------- | -------------------------------- |
| Usuario 1 | Lee producto                     |
| Usuario 2 | Modifica producto                |
| Usuario 1 | Intenta guardar cambios antiguos |

Gracias a `ROWVERSION`, SQL Server detecta que el registro cambió.

---

# Tipos de Locks en SQL Server

| Lock     | Función                    |
| -------- | -------------------------- |
| UPDLOCK  | Bloqueo para actualización |
| TABLOCK  | Bloqueo de tabla           |
| TABLOCKX | Bloqueo exclusivo de tabla |
| ROWLOCK  | Bloqueo por fila           |
| XLOCK    | Bloqueo exclusivo          |

---

# Uso de UPDLOCK

## Objetivo

Bloquear un producto mientras se actualiza.

---

# Ejemplo con UPDLOCK

```sql id="p5wvkk"
BEGIN TRANSACTION;

    SELECT *
    FROM Productos WITH(UPDLOCK)
    WHERE ID = 1;

    WAITFOR DELAY '00:00:10';

    UPDATE Productos
    SET Sttock = Sttock - 1
    WHERE ID = 1;

COMMIT;
```

---

# Explicación de UPDLOCK

`UPDLOCK`:

* Bloquea registros para actualización.
* Evita modificaciones simultáneas.
* Reduce conflictos de concurrencia.

---

# Diferencia entre Locks

| Tipo     | Nivel                          |
| -------- | ------------------------------ |
| ROWLOCK  | Solo una fila                  |
| TABLOCK  | Toda la tabla                  |
| TABLOCKX | Toda la tabla con exclusividad |
| UPDLOCK  | Bloqueo para actualizar        |

---

# WAITFOR DELAY

## ¿Qué hace?

Simula operaciones largas.

```sql id="hx1jgv"
WAITFOR DELAY '00:00:10';
```

---

# ¿Por qué se usa?

Ayuda a:

* Probar concurrencia
* Simular usuarios simultáneos
* Detectar bloqueos
* Estudiar comportamiento de transacciones

---

# Deadlocks

## ¿Qué es un Deadlock?

Sucede cuando:

* Usuario 1 espera recursos de Usuario 2
* Usuario 2 espera recursos de Usuario 1

Ninguno puede continuar.

---

# Ejemplo conceptual

```text id="ec3oc8"
Usuario 1 bloquea Producto A
Usuario 2 bloquea Producto B

Usuario 1 quiere Producto B
Usuario 2 quiere Producto A

❌ DEADLOCK
```

---

# ¿Cómo evita SQL Server los Deadlocks?

SQL Server detecta automáticamente el conflicto y cancela una de las transacciones.

---

# Buenas prácticas

## ✔ Mantener transacciones cortas

Evita bloqueos largos.

---

## ✔ Usar índices

Reduce tiempo de búsqueda.

---

## ✔ Evitar TABLOCKX innecesario

Puede bloquear todo el sistema.

---

## ✔ Usar niveles de aislamiento adecuados

Ayuda a equilibrar:

* Rendimiento
* Seguridad
* Concurrencia

---

# Resumen General

| Concepto     | Función                    |
| ------------ | -------------------------- |
| Concurrencia | Acceso simultáneo          |
| Transacción  | Grupo de operaciones       |
| Lock         | Bloqueo de datos           |
| TABLOCKX     | Bloqueo total              |
| UPDLOCK      | Bloqueo para actualización |
| ROWVERSION   | Control de versiones       |
| WAITFOR      | Simular operaciones largas |

---

# Conclusión

El control de concurrencia es fundamental en bases de datos modernas.

Gracias a:

* Transacciones
* Locks
* Versionado
* Niveles de aislamiento

los sistemas pueden garantizar:

✔ Integridad de datos
✔ Seguridad
✔ Consistencia
✔ Correcto acceso multiusuario

Motores como:

* SQL Server
* PostgreSQL
* Oracle Database
* MySQL

implementan estos mecanismos para asegurar operaciones confiables en entornos concurrentes.
