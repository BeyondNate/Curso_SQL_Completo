# Propiedades ACID en Bases de Datos (SQL Server)

## Introducción

Las propiedades **ACID** son un conjunto de reglas fundamentales que garantizan que las transacciones en una base de datos sean seguras, confiables y consistentes.

ACID es el acrónimo de:

* **A** → Atomicidad (*Atomicity*)
* **C** → Consistencia (*Consistency*)
* **I** → Aislamiento (*Isolation*)
* **D** → Durabilidad (*Durability*)

Estas propiedades son esenciales en sistemas bancarios, sistemas de pagos, comercio electrónico y cualquier aplicación donde los datos deban mantenerse correctos incluso ante errores o fallos del sistema.

---

# 1. Atomicidad (Atomicity)

## Definición

La **Atomicidad** garantiza que una transacción se ejecute completamente o no se ejecute en absoluto.

Si alguna operación falla durante la transacción, todas las operaciones realizadas anteriormente deben revertirse usando `ROLLBACK`.

En otras palabras:

> **Todo o nada.**

---

## Ejemplo práctico

Supongamos una transferencia bancaria:

* Se descuentan 100 soles de la cuenta A.
* Se agregan 100 soles a la cuenta B.

Si el sistema falla después de descontar el dinero de A pero antes de agregarlo a B, el dinero desaparecería.

La atomicidad evita este problema.

---

## Creación de la Base de Datos

```sql
CREATE DATABASE BDbancos;
GO

USE BDbancos;
GO
```

---

## Creación de la tabla

```sql
CREATE TABLE Cuentas (
    Cuenta_id VARCHAR(10) PRIMARY KEY,
    balance DECIMAL(10,2) NOT NULL CHECK (balance >= 0)
);
```

### Explicación

* `PRIMARY KEY`
  → Garantiza que no existan cuentas repetidas.

* `DECIMAL(10,2)`
  → Permite almacenar montos monetarios.

* `CHECK (balance >= 0)`
  → Impide balances negativos.

---

## Insertar datos iniciales

```sql
INSERT INTO Cuentas (Cuenta_id, balance)
VALUES
('A', 500.00),
('B', 300.00);
```

---

## Verificar datos

```sql
SELECT * FROM Cuentas;
```

Resultado esperado:

| Cuenta_id | balance |
| --------- | ------- |
| A         | 500.00  |
| B         | 300.00  |

---

## Transferencia con transacción

```sql
BEGIN TRANSACTION;

-- Restar dinero de la cuenta A
UPDATE Cuentas
SET balance = balance - 100
WHERE Cuenta_id = 'A';

-- Sumar dinero a la cuenta B
UPDATE Cuentas
SET balance = balance + 100
WHERE Cuenta_id = 'B';

-- Confirmar cambios
COMMIT;
```

---

## ¿Qué hace COMMIT?

`COMMIT` confirma permanentemente los cambios realizados en la transacción.

---

## ¿Qué hace ROLLBACK?

`ROLLBACK` deshace todos los cambios realizados si ocurre un error.

Ejemplo:

```sql
ROLLBACK;
```

---

## Flujo de Atomicidad

```text
Inicio Transacción
       ↓
Actualizar Cuenta A
       ↓
Actualizar Cuenta B
       ↓
¿Todo salió bien?
   ↓           ↓
Sí             No
↓              ↓
COMMIT      ROLLBACK
```

---

# 2. Consistencia (Consistency)

## Definición

La **Consistencia** asegura que una transacción lleve la base de datos de un estado válido a otro estado válido.

Esto significa que:

* No se violen restricciones.
* No existan datos inválidos.
* Las reglas del negocio se mantengan correctas.

---

## Ejemplo

No se puede transferir dinero si la cuenta no tiene saldo suficiente.

---

## Código de ejemplo

```sql
BEGIN TRANSACTION;

-- Verificar saldo suficiente
IF (SELECT balance FROM Cuentas WHERE Cuenta_id = 'A') >= 100
BEGIN

    -- Restar dinero
    UPDATE Cuentas
    SET balance = balance - 100
    WHERE Cuenta_id = 'A';

    -- Sumar dinero
    UPDATE Cuentas
    SET balance = balance + 100
    WHERE Cuenta_id = 'B';

    COMMIT;

END
ELSE
BEGIN

    PRINT 'Saldo insuficiente';

    ROLLBACK;

END;
```

---

## Explicación detallada

### Verificación de saldo

```sql
IF (SELECT balance FROM Cuentas WHERE Cuenta_id='A') >=100
```

Comprueba si la cuenta tiene al menos 100.

---

### Si hay saldo suficiente

Se realiza la transferencia:

```sql
UPDATE Cuentas
SET balance = balance - 100
```

---

### Si no hay saldo

```sql
PRINT 'Saldo insuficiente';
ROLLBACK;
```

La transacción se cancela completamente.

---

## Beneficios de la Consistencia

✔ Evita datos corruptos
✔ Mantiene reglas del negocio
✔ Impide balances inválidos
✔ Garantiza integridad de datos

---

# 3. Aislamiento (Isolation)

## Definición

El **Aislamiento** asegura que múltiples transacciones concurrentes no interfieran entre sí.

Cada transacción debe ejecutarse como si fuera la única en el sistema.

---

## Problema sin aislamiento

Imagina:

* Usuario 1 retira dinero.
* Usuario 2 consulta saldo al mismo tiempo.

Sin aislamiento, el usuario podría ver datos inconsistentes.

---

# Niveles de Aislamiento

## 1. Read Uncommitted

Permite leer datos no confirmados.

### Problema

Puede producir:

* Dirty Reads (lecturas sucias)

---

## 2. Read Committed

Solo permite leer datos confirmados.

Es el nivel más utilizado.

---

## 3. Repeatable Read

Bloquea modificaciones mientras se leen datos.

Evita:

* Non-repeatable reads

---

## 4. Serializable

Es el nivel más alto de aislamiento.

Evita:

* Dirty reads
* Phantom reads
* Lecturas inconsistentes

También bloquea más recursos.

---

# Ejemplo usando SERIALIZABLE

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

IF (SELECT balance FROM Cuentas WHERE Cuenta_id='A') >= 100
BEGIN

    UPDATE Cuentas
    SET balance = balance - 100
    WHERE Cuenta_id = 'A';

    UPDATE Cuentas
    SET balance = balance + 100
    WHERE Cuenta_id = 'B';

    COMMIT;

    PRINT 'Transacción completada exitosamente';

END
ELSE
BEGIN

    PRINT 'Saldo insuficiente';

    ROLLBACK;

END;
```

---

# ¿Qué hace SERIALIZABLE?

Garantiza que:

* Nadie modifique los datos mientras la transacción está en proceso.
* Nadie lea datos inconsistentes.
* Las transacciones se ejecuten de manera segura.

---

# Problemas que evita el aislamiento

| Problema            | Descripción                                      |
| ------------------- | ------------------------------------------------ |
| Dirty Read          | Leer datos no confirmados                        |
| Non-repeatable Read | Leer datos diferentes en la misma consulta       |
| Phantom Read        | Nuevos registros aparecen durante la transacción |

---

# 4. Durabilidad (Durability)

## Definición

La **Durabilidad** garantiza que una vez realizada una transacción con `COMMIT`, los cambios serán permanentes.

Incluso si:

* Se apaga el servidor.
* Hay un fallo eléctrico.
* El sistema colapsa.

Los datos seguirán guardados.

---

## Ejemplo

```sql
COMMIT;
```

Una vez ejecutado:

✔ Los cambios quedan almacenados en disco.
✔ SQL Server registra la operación en el Transaction Log.
✔ Los datos pueden recuperarse después de un fallo.

---

# ¿Cómo funciona internamente?

SQL Server utiliza:

* **Transaction Log**
* Archivos de recuperación
* Checkpoints

Esto permite restaurar información incluso tras errores graves.

---

# Resumen General de ACID

| Propiedad    | Función                |
| ------------ | ---------------------- |
| Atomicidad   | Todo o nada            |
| Consistencia | Mantiene datos válidos |
| Aislamiento  | Evita interferencias   |
| Durabilidad  | Cambios permanentes    |

---

# Ejemplo completo de transferencia bancaria segura

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

IF (SELECT balance FROM Cuentas WHERE Cuenta_id='A') >= 100
BEGIN

    UPDATE Cuentas
    SET balance = balance - 100
    WHERE Cuenta_id='A';

    UPDATE Cuentas
    SET balance = balance + 100
    WHERE Cuenta_id='B';

    COMMIT;

    PRINT 'Transferencia realizada correctamente';

END
ELSE
BEGIN

    PRINT 'Saldo insuficiente';

    ROLLBACK;

END;
```

---

# Conclusión

Las propiedades ACID son fundamentales para garantizar:

* Integridad de datos
* Seguridad
* Confiabilidad
* Correcto manejo de transacciones

Sin ACID, los sistemas bancarios y financieros podrían perder información o generar inconsistencias graves.

Por eso, los motores de bases de datos como:

* SQL Server
* PostgreSQL
* MySQL
* Oracle Database

implementan estas propiedades para garantizar operaciones seguras y confiables.
