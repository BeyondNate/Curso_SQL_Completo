
# Guía Completa de Buenas Prácticas en Bases de Datos SQL

Este documento explica los conceptos fundamentales de diseño y optimización de bases de datos utilizando como ejemplo el código proporcionado. Aprenderás sobre normalización, integridad referencial, restricciones y optimización mediante índices.

##  Estructura Inicial de la Base de Datos

```sql
CREATE DATABASE dbempesasac;
USE dbempesasac;

CREATE TABLE CLIENTES (
  CLIENTEID INT PRIMARY KEY,
  NOMBRE VARCHAR(100),
  DIRECCION NVARCHAR(200)
);

CREATE TABLE PEDIDOS (
  PEDIDOID INT PRIMARY KEY,
  CLIENTEID INT,
  PRODUCTO NVARCHAR(100),
  CANTIDAD INT,
  FOREIGN KEY (CLIENTEID) REFERENCES CLIENTES(CLIENTEID)
);
```

### ¿Qué tenemos aquí?
- **Dos tablas relacionadas**: CLIENTES y PEDIDOS
- **Relación uno a muchos**: Un cliente puede tener muchos pedidos
- **Integridad referencial**: La FOREIGN KEY asegura que todo pedido pertenezca a un cliente existente

### Insertando datos de ejemplo
```sql
INSERT INTO CLIENTES (CLIENTEID, NOMBRE, DIRECCION)
VALUES(1, 'Juan Perez', 'Calle Capon 123');

INSERT INTO PEDIDOS (PEDIDOID, CLIENTEID, PRODUCTO, CANTIDAD)
VALUES(1, 1, 'LAPTOP', 2),
      (2, 1, 'MOUSE', 4);
```

---

##  Principio 1: Minimización de Redundancia (Normalización)

###  MAL DISEÑO: Tabla con redundancia
```sql
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY,
    ClienteNombre NVARCHAR(100),    -- Datos del cliente repetidos
    ClienteDireccion NVARCHAR(200),  -- en cada pedido
    Producto NVARCHAR(100),
    Cantidad INT
);
```

**Problemas de este diseño:**
- Si un cliente cambia de dirección, hay que actualizar TODOS sus pedidos
- Ocupa más espacio en disco
- Riesgo de inconsistencia (un mismo cliente podría tener direcciones diferentes en distintos pedidos)

###  BUEN DISEÑO: Tablas normalizadas (como en el código original)
```
CLIENTES (CLIENTEID, NOMBRE, DIRECCION)
         ↑
         │ (1 cliente → muchos pedidos)
PEDIDOS (PEDIDOID, CLIENTEID, PRODUCTO, CANTIDAD)
```

**Ventajas:**
- La información del cliente está UNA sola vez
- Cambiar la dirección de Juan Pérez afecta UNA fila
- Ahorro de espacio y consistencia garantizada

---

##  Principio 2: Maximización de la Coherencia (Integridad de Datos)

### Problemas que pueden ocurrir sin restricciones

#### Caso 1: Cliente inexistente
```sql
-- Este INSERT debería fallar
INSERT INTO PEDIDOS(PEDIDOID, CLIENTEID, PRODUCTO, CANTIDAD)
VALUES(3, 999, 'LAPTOP', 2);
-- Error: ClienteID 999 no existe en la tabla clientes
```

**Solución aplicada**: La FOREIGN KEY ya previene esto. La base de datos rechaza automáticamente pedidos con CLIENTEID que no existan en la tabla CLIENTES.

#### Caso 2: Cantidades inválidas
```sql
-- Este INSERT debería fallar
INSERT INTO PEDIDOS(PEDIDOID, CLIENTEID, PRODUCTO, CANTIDAD)
VALUES(3, 1, 'TECLADO', 0);
-- La cantidad debe ser mayor a 0
```

**Solución**: Añadimos una restricción CHECK
```sql
ALTER TABLE Pedidos
ADD CONSTRAINT CK_Cantidad_Positiva
CHECK (CANTIDAD > 0);
```

### Tipos de restricciones de integridad
| Restricción | Propósito | Ejemplo |
|-------------|-----------|---------|
| PRIMARY KEY | Identificador único | CLIENTEID INT PRIMARY KEY |
| FOREIGN KEY | Relación entre tablas | FOREIGN KEY (CLIENTEID) REFERENCES CLIENTES |
| CHECK | Validación de valores | CHECK (CANTIDAD > 0) |
| UNIQUE | Valores no duplicados | EMAIL VARCHAR(100) UNIQUE |
| NOT NULL | Campo obligatorio | NOMBRE VARCHAR(100) NOT NULL |

---

## ⚡ Principio 3: Optimización del Acceso a Datos

### Consulta sin optimizar
```sql
SELECT *
FROM PEDIDOS
WHERE CLIENTEID = 1;
```

**¿Qué pasa sin índice?**
- La base de datos revisa TODAS las filas de PEDIDOS una por una
- En una tabla con millones de pedidos, esto es extremadamente lento
- Se llama "FULL TABLE SCAN"

### Creando un índice para optimizar
```sql
CREATE INDEX IDX_CLIENTEID ON Pedidos(Clienteid);
```

### ¿Qué mejora con el índice?
```
ANTES (SIN ÍNDICE):
[Pedido1] → ¿CLIENTEID=1? → No
[Pedido2] → ¿CLIENTEID=1? → Sí → Guardar
[Pedido3] → ¿CLIENTEID=1? → No
[Pedido4] → ¿CLIENTEID=1? → No
... (millones de filas)

DESPUÉS (CON ÍNDICE):
ÍNDICE: {1: [Pedido1, Pedido5, Pedido100], 2: [Pedido2, Pedido3], ...}
→ Busca CLIENTEID=1 en el índice (instantáneo)
→ Obtiene directamente los pedidos: [Pedido1, Pedido5, Pedido100]
```

### Verificando el uso del índice
```sql
-- En MySQL
EXPLAIN SELECT * FROM PEDIDOS WHERE CLIENTEID = 1;
-- Busca "type": si es "ref" o "range", está usando el índice

-- En SQL Server/PostgreSQL
EXPLAIN ANALYZE SELECT * FROM PEDIDOS WHERE CLIENTEID = 1;
```

---

## 📊 Resumen Visual de los Conceptos

```
┌─────────────────────────────────────────────────────────────┐
│                    BUEN DISEÑO DE BD                         │
├───────────────┬───────────────────┬─────────────────────────┤
│ NORMALIZACIÓN │ INTEGRIDAD        │ OPTIMIZACIÓN            │
├───────────────┼───────────────────┼─────────────────────────┤
│ • Sin         │ • PRIMARY KEY     │ • Índices en            │
│   redundancia │ • FOREIGN KEY     │   columnas de búsqueda  │
│ • Datos       │ • CHECK           │ • Consultas rápidas     │
│   atómicos    │ • UNIQUE          │ • Menos recursos        │
│ • 1 tabla por │ • NOT NULL        │ • Mejor experiencia     │
│   entidad     │                   │                         │
└───────────────┴───────────────────┴─────────────────────────┘
```
