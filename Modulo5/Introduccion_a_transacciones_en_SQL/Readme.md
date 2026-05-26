# 🏦 Base de Datos BANCOS — Documentación de Transacciones SQL

> **Tecnología:** SQL Server (T-SQL)  
> **Tema:** Manejo de transacciones, control de errores con TRY/CATCH y uso de SAVEPOINTS con CHECKPOINT

---

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Estructura de la Base de Datos](#estructura-de-la-base-de-datos)
   - [Tabla: Accounts](#tabla-accounts)
   - [Tabla: Transactions](#tabla-transactions)
3. [Datos Iniciales](#datos-iniciales)
4. [Escenario 1 — Transferencia Simple con TRY/CATCH](#escenario-1--transferencia-simple-con-trycatch)
   - [¿Qué hace paso a paso?](#qué-hace-paso-a-paso-escenario-1)
   - [Flujo de Éxito](#flujo-de-éxito)
   - [Flujo de Error](#flujo-de-error)
5. [Escenario 2 — Transferencia con CHECKPOINT](#escenario-2--transferencia-con-checkpoint)
   - [¿Qué hace paso a paso?](#qué-hace-paso-a-paso-escenario-2)
   - [¿Qué es CHECKPOINT?](#qué-es-checkpoint)
6. [Conceptos Clave](#conceptos-clave)
   - [BEGIN TRANSACTION / COMMIT / ROLLBACK](#begin-transaction--commit--rollback)
   - [TRY / CATCH en T-SQL](#try--catch-en-t-sql)
   - [@@ROWCOUNT](#rowcount)
   - [THROW](#throw)
   - [IDENTITY](#identity)
7. [Resultado Final Esperado](#resultado-final-esperado)
8. [Resumen Visual del Flujo](#resumen-visual-del-flujo)

---

## Descripción General

Este script implementa un sistema bancario simplificado en **SQL Server** que demuestra:

- Cómo crear y relacionar tablas para cuentas y transacciones.
- Cómo usar **transacciones ACID** para garantizar integridad en transferencias de dinero.
- Cómo manejar errores con `TRY/CATCH` y revertir cambios con `ROLLBACK`.
- El uso de `CHECKPOINT` como punto de control dentro de una transacción.

> 💡 **¿Por qué importa esto?**  
> En sistemas financieros, si una operación falla a mitad de camino (por ejemplo, se debita una cuenta pero no se acredita la otra), los datos quedan en un estado inconsistente. Las transacciones SQL previenen exactamente eso.

---

## Estructura de la Base de Datos

```sql
CREATE DATABASE BANCOS
USE BANCOS
```

Se crea la base de datos `BANCOS` y se selecciona para trabajar en ella.

---

### Tabla: Accounts

```sql
CREATE TABLE Accounts (
    AccountID       INT PRIMARY KEY,
    AccountHolder   VARCHAR(100),
    Balance         DECIMAL(18, 2)
);
```

| Columna         | Tipo            | Descripción                                      |
|-----------------|-----------------|--------------------------------------------------|
| `AccountID`     | `INT PK`        | Identificador único de la cuenta                 |
| `AccountHolder` | `VARCHAR(100)`  | Nombre completo del titular de la cuenta         |
| `Balance`       | `DECIMAL(18,2)` | Saldo disponible con hasta 2 decimales (ej: $500.00) |

> ℹ️ `DECIMAL(18, 2)` significa: hasta 18 dígitos en total, con 2 decimales. Ideal para valores monetarios precisos, evitando errores de redondeo de `FLOAT`.

---

### Tabla: Transactions

```sql
CREATE TABLE Transactions (
    TransactionID   INT PRIMARY KEY IDENTITY,
    FromAccountID   INT,
    ToAccountID     INT,
    Amount          DECIMAL(18, 2),
    TransactionDate DATETIME DEFAULT GETDATE(),
    Status          VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (FromAccountID) REFERENCES Accounts(AccountID),
    FOREIGN KEY (ToAccountID)   REFERENCES Accounts(AccountID)
);
```

| Columna           | Tipo            | Descripción                                                   |
|-------------------|-----------------|---------------------------------------------------------------|
| `TransactionID`   | `INT IDENTITY`  | ID autoincremental — SQL Server lo asigna solo (1, 2, 3...) |
| `FromAccountID`   | `INT FK`        | Cuenta de origen que envía el dinero                         |
| `ToAccountID`     | `INT FK`        | Cuenta de destino que recibe el dinero                       |
| `Amount`          | `DECIMAL(18,2)` | Monto transferido                                            |
| `TransactionDate` | `DATETIME`      | Fecha y hora automática con `GETDATE()` al insertar          |
| `Status`          | `VARCHAR(20)`   | Estado: `'Pending'`, `'Completed'` o `'Failed'`              |

> ℹ️ Las **FOREIGN KEY** garantizan integridad referencial: no puedes registrar una transacción con un `AccountID` que no exista en `Accounts`.

---

## Datos Iniciales

```sql
INSERT INTO Accounts (AccountID, AccountHolder, Balance)
VALUES 
    (1, 'Juan Pérez', 5000.00),
    (2, 'Ana García', 3000.00);
```

Se crean dos cuentas de prueba:

| AccountID | Titular     | Saldo Inicial |
|-----------|-------------|---------------|
| 1         | Juan Pérez  | $5,000.00     |
| 2         | Ana García  | $3,000.00     |

---

## Escenario 1 — Transferencia Simple con TRY/CATCH

**Objetivo:** Transferir **$1,000** desde la cuenta de Juan Pérez (ID 1) hacia la cuenta de Ana García (ID 2), con manejo de errores.

```sql
BEGIN TRANSACTION
  BEGIN TRY 
    -- Paso 1: Restar $1000 de Juan (solo si tiene saldo suficiente)
    UPDATE Accounts
    SET Balance = Balance - 1000
    WHERE AccountID = 1 AND Balance >= 1000

    -- Paso 2: Verificar que la actualización afectó filas
    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50000, 'Saldo Insuficiente en la cuenta de Juan Perez', 1;
    END

    -- Paso 3: Acreditar $1000 a Ana García
    UPDATE Accounts
    SET Balance = Balance + 1000
    WHERE AccountID = 2

    -- Paso 4: Registrar la transacción
    INSERT INTO Transactions(FromAccountID, ToAccountID, Amount, Status)
    VALUES(1, 2, 1000, 'Completed');

    -- Paso 5: Confirmar todos los cambios
    COMMIT TRANSACTION
    PRINT 'Transferencia completada con exito'
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT 'ERROR OCURRIDO TRANSACCION REVERTIDA'
    PRINT ERROR_MESSAGE();
  END CATCH;
```

### ¿Qué hace paso a paso? (Escenario 1)

```
┌─────────────────────────────────────────────────────────┐
│                   BEGIN TRANSACTION                     │
│                                                         │
│  1. UPDATE Accounts → Balance = Balance - 1000          │
│     (WHERE AccountID=1 AND Balance >= 1000)             │
│                                                         │
│  2. ¿@@ROWCOUNT = 0?                                    │
│     ├─ SÍ  → THROW (error: saldo insuficiente)         │
│     └─ NO  → continuar                                  │
│                                                         │
│  3. UPDATE Accounts → Balance = Balance + 1000          │
│     (WHERE AccountID=2)                                 │
│                                                         │
│  4. INSERT INTO Transactions → Status='Completed'       │
│                                                         │
│  5. COMMIT TRANSACTION ✅                               │
└─────────────────────────────────────────────────────────┘
         Si algo falla en cualquier paso:
         ↓
  CATCH → ROLLBACK TRANSACTION ❌ (se deshacen TODOS los cambios)
```

### Flujo de Éxito

| Evento              | Juan Pérez (ID 1) | Ana García (ID 2) |
|---------------------|-------------------|-------------------|
| Antes               | $5,000.00         | $3,000.00         |
| Después del COMMIT  | $4,000.00         | $4,000.00         |

Y en `Transactions` se registra:

| TransactionID | FromAccountID | ToAccountID | Amount  | Status    |
|---------------|---------------|-------------|---------|-----------|
| 1             | 1             | 2           | 1000.00 | Completed |

### Flujo de Error

Si Juan tuviera solo $500 y se intentara transferir $1,000:

1. El `UPDATE` con `Balance >= 1000` **no afecta ninguna fila** → `@@ROWCOUNT = 0`
2. Se lanza `THROW 50000, 'Saldo Insuficiente...'`
3. El bloque `CATCH` captura el error
4. Se ejecuta `ROLLBACK` → **ningún cambio persiste en la base de datos**
5. Se imprime el mensaje de error

> ✅ Esto garantiza que **nunca se debite dinero sin acreditarlo** o viceversa.

---

## Escenario 2 — Transferencia con CHECKPOINT

**Objetivo:** Transferir **$500** desde Juan hacia Ana, pero con un **punto de control** (CHECKPOINT) para ilustrar el registro de escritura anticipada del motor SQL.

```sql
BEGIN TRANSACTION
BEGIN TRY
    -- Paso 1: Deducir $500 de Juan (validando saldo)
    UPDATE Accounts
    SET Balance = Balance - 500
    WHERE AccountID = 1 AND Balance >= 500

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50001, 'Saldo Insuficiente en la cuenta de Juan Perez', 1;
    END

    -- Punto de Control: forzar escritura del log al disco
    CHECKPOINT;

    -- Paso 2: Registrar la transferencia como 'Pending'
    INSERT INTO Transactions(FromAccountID, ToAccountID, Amount, Status)
    VALUES(1, 2, 500, 'Pending')

    -- Paso 3: Acreditar $500 a Ana
    UPDATE Accounts
    SET Balance = Balance + 500
    WHERE AccountID = 2

    -- Paso 4: Actualizar estado a 'Completed'
    UPDATE Transactions
    SET Status = 'Completed'
    WHERE FromAccountID = 1 AND ToAccountID = 2 AND Amount = 500

    COMMIT TRANSACTION;
    PRINT 'Operaciones completadas con exito'
END TRY
BEGIN CATCH
    PRINT 'ERROR OCURRIDO REVERTIENDO LA TRANSACCION PARCIAL'
    PRINT ERROR_MESSAGE()
    ROLLBACK TRANSACTION;
END CATCH;
```

### ¿Qué hace paso a paso? (Escenario 2)

```
┌──────────────────────────────────────────────────────────────┐
│                     BEGIN TRANSACTION                        │
│                                                              │
│  1. UPDATE Accounts → Balance = Balance - 500                │
│     (WHERE AccountID=1 AND Balance >= 500)                   │
│                                                              │
│  2. IF @@ROWCOUNT = 0 → THROW (saldo insuficiente)           │
│                                                              │
│  ────────── CHECKPOINT ──────────                            │
│   (Escribe el log de transacciones al disco físico)          │
│   La deducción de $500 queda registrada en disco             │
│   pero la transacción AÚN NO está confirmada (COMMITTED)     │
│  ───────────────────────────────                             │
│                                                              │
│  3. INSERT INTO Transactions → Status='Pending'              │
│                                                              │
│  4. UPDATE Accounts → Balance = Balance + 500 (Ana)          │
│                                                              │
│  5. UPDATE Transactions → Status='Completed'                 │
│                                                              │
│  6. COMMIT TRANSACTION ✅                                    │
└──────────────────────────────────────────────────────────────┘
         Si algo falla después del CHECKPOINT:
         ↓
  CATCH → ROLLBACK TRANSACTION ❌
  (Se revierten TODOS los cambios, incluidos los anteriores al CHECKPOINT)
```

### ¿Qué es CHECKPOINT?

`CHECKPOINT` es un comando de **SQL Server** que fuerza al motor a escribir todas las **páginas de datos modificadas** (dirty pages) del buffer en memoria hacia el **archivo de log de transacciones en disco**.

**¿Para qué sirve aquí?**

| Aspecto                       | Explicación                                                                                    |
|-------------------------------|------------------------------------------------------------------------------------------------|
| **Propósito principal**       | Garantiza que si el servidor se cae después del CHECKPOINT, SQL Server puede recuperar el estado gracias al log de transacciones |
| **¿Confirma la transacción?** | ❌ No. El CHECKPOINT solo escribe el log al disco; la transacción sigue abierta hasta el `COMMIT` |
| **¿Actúa como SAVEPOINT?**    | ⚠️ En T-SQL, `CHECKPOINT` NO es un SAVEPOINT. Para revertir solo una parte, se usa `SAVE TRANSACTION nombre_punto` |
| **Contexto real**             | En producción, SQL Server hace CHECKPOINT automáticamente cada cierto tiempo para acelerar la recuperación ante fallos |

> ⚠️ **Nota importante:** En T-SQL, si quisieras hacer un rollback parcial (solo revertir a partir de cierto punto), deberías usar:
> ```sql
> SAVE TRANSACTION MiPunto;
> -- ... operaciones ...
> ROLLBACK TRANSACTION MiPunto; -- Solo revierte hasta ese punto
> ```
> `CHECKPOINT` por sí solo **no** permite rollback parcial; afecta al motor de almacenamiento, no a la lógica de la transacción.

---

## Conceptos Clave

### BEGIN TRANSACTION / COMMIT / ROLLBACK

| Comando              | Descripción                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `BEGIN TRANSACTION`  | Inicia un bloque transaccional. Todos los cambios son temporales hasta confirmar |
| `COMMIT TRANSACTION` | Confirma y hace permanentes **todos** los cambios realizados desde el `BEGIN` |
| `ROLLBACK TRANSACTION` | Deshace **todos** los cambios realizados desde el `BEGIN` (o hasta un SAVEPOINT) |

**Analogía:** Imagina que estás editando un documento de texto. `BEGIN TRANSACTION` es abrir el archivo, `COMMIT` es guardar, y `ROLLBACK` es cerrar sin guardar.

---

### TRY / CATCH en T-SQL

```sql
BEGIN TRY
    -- Código que puede fallar
END TRY
BEGIN CATCH
    -- Código que se ejecuta si ocurre un error
    PRINT ERROR_MESSAGE(); -- Mensaje del error
    ROLLBACK TRANSACTION;
END CATCH
```

Funciona igual que el `try/catch` de lenguajes como Java, C# o Python. Si **cualquier instrucción** dentro del `TRY` falla (ya sea por un error de SQL o por un `THROW` manual), la ejecución salta directamente al bloque `CATCH`.

Funciones útiles dentro de CATCH:

| Función           | Retorna                                   |
|-------------------|-------------------------------------------|
| `ERROR_MESSAGE()` | Texto descriptivo del error               |
| `ERROR_NUMBER()`  | Número identificador del error            |
| `ERROR_LINE()`    | Línea donde ocurrió el error              |
| `ERROR_SEVERITY()`| Nivel de severidad del error (1–25)       |

---

### @@ROWCOUNT

```sql
UPDATE Accounts
SET Balance = Balance - 1000
WHERE AccountID = 1 AND Balance >= 1000

IF @@ROWCOUNT = 0
BEGIN
    THROW 50000, 'Saldo Insuficiente', 1;
END
```

`@@ROWCOUNT` es una **variable de sistema** que contiene el número de filas afectadas por la última instrucción SQL.

- Si el `UPDATE` afectó **1 fila** → `@@ROWCOUNT = 1` → la cuenta existía y tenía saldo suficiente ✅
- Si el `UPDATE` afectó **0 filas** → `@@ROWCOUNT = 0` → la cuenta no existe o el saldo era insuficiente ❌

> ℹ️ Debe consultarse **inmediatamente** después de la instrucción, ya que cualquier nueva instrucción resetea su valor.

---

### THROW

```sql
THROW 50000, 'Saldo Insuficiente en la cuenta de Juan Perez', 1;
```

Permite lanzar un error **personalizado** para interrumpir el flujo y saltar al bloque `CATCH`.

| Parámetro     | Valor en el ejemplo             | Descripción                                              |
|---------------|---------------------------------|----------------------------------------------------------|
| Número        | `50000`                         | Identificador del error (debe ser ≥ 50000 para errores de usuario) |
| Mensaje       | `'Saldo Insuficiente...'`       | Texto descriptivo del error                              |
| Estado        | `1`                             | Valor entre 0 y 255, útil para distinguir variantes del mismo error |

---

### IDENTITY

```sql
TransactionID INT PRIMARY KEY IDENTITY
```

La propiedad `IDENTITY` hace que SQL Server **asigne automáticamente** un número incremental a cada nueva fila insertada, comenzando desde 1 por defecto (`IDENTITY(1,1)`).

Esto significa que al hacer:
```sql
INSERT INTO Transactions(FromAccountID, ToAccountID, Amount, Status)
VALUES(1, 2, 1000, 'Completed');
```
No necesitas especificar `TransactionID`; SQL Server lo genera solo (1, 2, 3...).

---

## Resultado Final Esperado

Después de ejecutar ambos escenarios exitosamente:

### SELECT * FROM Accounts

| AccountID | AccountHolder | Balance    |
|-----------|---------------|------------|
| 1         | Juan Pérez    | $3,500.00  |
| 2         | Ana García    | $4,500.00  |

> Juan inicia con $5,000 → pierde $1,000 (Escenario 1) → pierde $500 (Escenario 2) = **$3,500**  
> Ana inicia con $3,000 → gana $1,000 (Escenario 1) → gana $500 (Escenario 2) = **$4,500**

### SELECT * FROM Transactions

| TransactionID | FromAccountID | ToAccountID | Amount   | TransactionDate     | Status    |
|---------------|---------------|-------------|----------|---------------------|-----------|
| 1             | 1             | 2           | 1000.00  | 2024-xx-xx xx:xx:xx | Completed |
| 2             | 1             | 2           | 500.00   | 2024-xx-xx xx:xx:xx | Completed |

---

## Resumen Visual del Flujo

```
ESCENARIO 1 — Transferencia $1,000 (Sin CHECKPOINT)
═══════════════════════════════════════════════════

  BEGIN TRANSACTION
       │
       ▼
  ┌────────────────────────┐
  │  UPDATE Accounts       │  Juan: $5000 → $4000
  │  Balance - 1000        │
  └────────────┬───────────┘
               │
       ¿@@ROWCOUNT = 0?
       ├── SÍ → THROW → CATCH → ROLLBACK ❌
       └── NO ↓
  ┌────────────────────────┐
  │  UPDATE Accounts       │  Ana: $3000 → $4000
  │  Balance + 1000        │
  └────────────┬───────────┘
               ↓
  ┌────────────────────────┐
  │  INSERT Transactions   │  Status = 'Completed'
  └────────────┬───────────┘
               ↓
         COMMIT ✅ — Cambios permanentes


ESCENARIO 2 — Transferencia $500 (Con CHECKPOINT)
══════════════════════════════════════════════════

  BEGIN TRANSACTION
       │
       ▼
  UPDATE Accounts (Juan - $500)
       │
  ══ CHECKPOINT ══ (log → disco)
       │
  INSERT Transactions (Status='Pending')
       │
  UPDATE Accounts (Ana + $500)
       │
  UPDATE Transactions (Status='Completed')
       │
  COMMIT ✅
```

---

> 📌 **Autor:** Documentación generada para fines educativos  
> 🛠️ **Motor de BD:** Microsoft SQL Server (T-SQL)  
> 📚 **Temas cubiertos:** Transacciones ACID, TRY/CATCH, ROLLBACK, CHECKPOINT, IDENTITY, FOREIGN KEY
