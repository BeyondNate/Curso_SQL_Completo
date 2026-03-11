Aquí tienes un resumen estructurado del módulo en formato Markdown para GitHub:

# TRANSACCIONES Y CONTROL DE CONCURRENCIA EN SQL

## Índice
1. [Introducción a Transacciones](#introducción-a-transacciones)
2. [Propiedades ACID](#propiedades-acid)
3. [Control de Concurrencia](#control-de-concurrencia)
4. [Manejo de Transacciones](#manejo-de-transacciones)
5. [Niveles de Aislamiento](#niveles-de-aislamiento)

---

## Introducción a Transacciones

Las transacciones en SQL son secuencias de operaciones que se ejecutan como una **unidad atómica** para garantizar la integridad y consistencia de los datos.

### Ejemplo básico:
```sql
BEGIN TRANSACTION;
UPDATE cuentas SET saldo = saldo - 100 WHERE id = 1;
UPDATE cuentas SET saldo = saldo + 100 WHERE id = 2;
COMMIT;
```

---

## Propiedades ACID

| Propiedad | Descripción |
|-----------|-------------|
| **Atomicidad** | Todas las operaciones se completan o ninguna se ejecuta |
| **Consistencia** | La BD pasa de un estado válido a otro |
| **Aislamiento** | Transacciones concurrentes no interfieren entre sí |
| **Durabilidad** | Los cambios persisten incluso tras fallos del sistema |

---

## Control de Concurrencia

Mecanismos que evitan conflictos cuando múltiples transacciones acceden simultáneamente a los mismos datos mediante **bloqueo de recursos**.

---

## Manejo de Transacciones

Comandos fundamentales para el control de transacciones:

| Comando | Función |
|---------|---------|
| **COMMIT** | Confirma permanentemente los cambios |
| **ROLLBACK** | Revierte los cambios realizados |
| **SAVEPOINT** | Establece un punto intermedio para rollback parcial |

---

## Niveles de Aislamiento

El aislamiento determina cómo las transacciones interactúan entre sí cuando operan sobre los mismos datos simultáneamente, evitando:
- Lecturas sucias
- Lecturas no repetibles
- Lecturas fantasma
