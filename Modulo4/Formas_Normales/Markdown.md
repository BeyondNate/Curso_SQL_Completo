
# Guía Completa de Formas Normales (Normalización) en SQL Server
## Ejemplo Práctico: Sistema de Videoteca

Este documento contiene una guía completa sobre las Formas Normales en bases de datos relacionales, utilizando ejemplos prácticos de un sistema de videoteca.

## Índice
1. [Conceptos Fundamentales](#conceptos-fundamentales)
2. [Base de Datos Original (No Normalizada)](#base-de-datos-original-no-normalizada)
3. [Primera Forma Normal (1FN)](#primera-forma-normal-1fn)
4. [Segunda Forma Normal (2FN)](#segunda-forma-normal-2fn)
5. [Tercera Forma Normal (3FN)](#tercera-forma-normal-3fn)
6. [Resumen y Conclusiones](#resumen-y-conclusiones)

---

## Conceptos Fundamentales

```sql
/*
NORMALIZACIÓN DE BASES DE DATOS
¿QUÉ ES?
- Proceso de organizar datos para reducir redundancia y mejorar integridad
- Divide tablas grandes en tablas más pequeñas y relacionadas
- Elimina anomalías en inserción, actualización y eliminación

OBJETIVOS PRINCIPALES:
1. Eliminar datos redundantes
2. Asegurar dependencias lógicas de los datos
3. Evitar anomalías al modificar datos
4. Facilitar el mantenimiento de la base de datos

FORMAS NORMALES:
- 1FN: Atomicidad de datos
- 2FN: Eliminar dependencias parciales
- 3FN: Eliminar dependencias transitivas
*/
```

---

## Base de Datos Original (No Normalizada)

### Tabla Original con Problemas de Diseño

```sql
/*
VIDEOTECA - VERSIÓN NO NORMALIZADA
Problemas identificados:
1. Columna PELICULASRENTADAS contiene múltiples valores (no atómico)
2. Repetición de datos (dirección, saludo se repite por cada película)
3. Anomalías de actualización (cambiar dirección requiere múltiples updates)
4. Dependencias complejas
*/

CREATE DATABASE VIDEOTECA;
USE VIDEOTECA;

CREATE TABLE INFORMACION(
    NOMBRECOMPLETO VARCHAR(200),
    DIRECCION VARCHAR(150),
    PELICULASRENTADAS VARCHAR(MAX),  -- PROBLEMA: Múltiples valores separados por coma
    SALUDO VARCHAR(4)
);

INSERT INTO INFORMACION
VALUES 
('CARMEN RUIZ','JR CUZCO 234','PIRATES DEL CARIBE, TITANIC, BOB ESPONJA','SRA'),
('MARIA CAMARGO','AV SUCURSALES 1234','SPIDERMAN, LO QUE EL VIENTO SE LLEVO, HOST','SRA'),
('MANUEL TAPIA','CALLE LOS ALISOS 109','LA MOMIA, LOS GALACTICOS, EL ARO','SR'),
('RAFER ORTIZ','CALLE EL SALVADOR 129','LA MOMIA, TITANIC, SPIDERMAN','SR');

SELECT * FROM INFORMACION;
```

**Estado inicial de los datos:**
| NOMBRECOMPLETO | DIRECCION | PELICULASRENTADAS | SALUDO |
|----------------|-----------|-------------------|--------|
| CARMEN RUIZ | JR CUZCO 234 | PIRATES DEL CARIBE, TITANIC, BOB ESPONJA | SRA |
| MARIA CAMARGO | AV SUCURSALES 1234 | SPIDERMAN, LO QUE EL VIENTO SE LLEVO, HOST | SRA |
| MANUEL TAPIA | CALLE LOS ALISOS 109 | LA MOMIA, LOS GALACTICOS, EL ARO | SR |
| RAFAEL ORTIZ | CALLE EL SALVADOR 129 | LA MOMIA, TITANIC, SPIDERMAN | SR |

**Análisis de problemas:**
```
PROBLEMA DE ATOMICIDAD:
- La columna PELICULASRENTADAS contiene múltiples valores (no atómico)
- No se puede consultar eficientemente "quiénes vieron Titanic"
- Dificultad para contar películas por género o actor

PROBLEMA DE REDUNDANCIA:
- La dirección y saludo se repiten si un miembro renta múltiples películas
- Si Carmen cambia de dirección, hay que actualizar 3 registros

PROBLEMA DE INTEGRIDAD:
- No hay una clave primaria
- Posible duplicación de miembros
- Datos no estructurados
```
---

## Primera Forma Normal (1FN)

### Teoría de 1FN

```sql
/*
PRIMERA FORMA NORMAL (1FN)
REQUISITOS:
1. Cada columna debe contener valores atómicos (indivisibles)
2. Cada registro debe ser único (identificable)
3. Eliminar grupos repetidos

SOLUCIÓN APLICADA:
- Descomponer la columna PELICULASRENTADAS en filas individuales
- Cada película se convierte en un registro separado
- Agregar IDENTITY como clave primaria
*/
```

### Implementación de 1FN

```sql
/*
VERSIÓN 1FN: Datos atómicos
- Cada película ahora es un registro separado
- Se agregó ID como clave primaria
- Aún existe redundancia (datos del miembro se repiten)
*/

CREATE TABLE INFORMACION_1FN(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    NOMBRECOMPLETO VARCHAR(200),
    DIRECCION VARCHAR(150),
    PELICULASRENTADAS VARCHAR(MAX),  -- Ahora contiene UNA SOLA película
    SALUDO VARCHAR(4)
);

INSERT INTO INFORMACION_1FN
VALUES 
('CARMEN RUIZ','JR CUZCO 234','PIRATES DEL CARIBE','SRA'),
('CARMEN RUIZ','JR CUZCO 234','TITANIC','SRA'),
('CARMEN RUIZ','JR CUZCO 234','BOB ESPONJA','SRA'),

('MARIA CAMARGO','AV SUCURSALES 1234','SPIDERMAN','SRA'),
('MARIA CAMARGO','AV SUCURSALES 1234','LO QUE EL VIENTO SE LLEVO','SRA'),
('MARIA CAMARGO','AV SUCURSALES 1234','HOST','SRA'),

('MANUEL TAPIA','CALLE LOS ALISOS 109','LA MOMIA','SR'),
('MANUEL TAPIA','CALLE LOS ALISOS 109','LOS GALACTICOS','SR'),
('MANUEL TAPIA','CALLE LOS ALISOS 109','EL ARO','SR'),

('RAFAEL ORTIZ','CALLE EL SALVADOR 129','LA MOMIA','SR'),
('RAFAEL ORTIZ','CALLE EL SALVADOR 129','TITANIC','SR'),
('RAFAEL ORTIZ','CALLE EL SALVADOR 129','SPIDERMAN','SR');

SELECT * FROM INFORMACION_1FN;
```

**Resultado después de 1FN:**
| ID | NOMBRECOMPLETO | DIRECCION | PELICULASRENTADAS | SALUDO |
|----|----------------|-----------|-------------------|--------|
| 1 | CARMEN RUIZ | JR CUZCO 234 | PIRATES DEL CARIBE | SRA |
| 2 | CARMEN RUIZ | JR CUZCO 234 | TITANIC | SRA |
| 3 | CARMEN RUIZ | JR CUZCO 234 | BOB ESPONJA | SRA |
| 4 | MARIA CAMARGO | AV SUCURSALES 1234 | SPIDERMAN | SRA |
| ... | ... | ... | ... | ... |

**Análisis del avance:**
```
✅ LO LOGRADO EN 1FN:
- Datos atómicos (cada registro = una película)
- Clave primaria (ID) que identifica cada registro
- Consultas más flexibles (podemos filtrar por película)

❌ PROBLEMAS PERSISTENTES:
- Redundancia: datos del miembro se repiten por cada película
- Si Carmen cambia de dirección, hay que actualizar 3 registros
- Si un miembro no tiene películas, no podemos registrar sus datos
- Anomalías de actualización todavía presentes
```
---

## Segunda Forma Normal (2FN)

### Teoría de 2FN

```sql
/*
SEGUNDA FORMA NORMAL (2FN)
REQUISITOS:
1. Estar en 1FN
2. Cada columna no clave debe depender de la clave primaria COMPLETA
   (No puede haber dependencias parciales)

SOLUCIÓN APLICADA:
- Separar en dos tablas: MIEMBROS y PELICULAS
- La tabla MIEMBROS contiene datos que dependen del miembro
- La tabla PELICULAS contiene las películas con referencia al miembro
- Establecer relación con clave foránea
*/
```

### Implementación de 2FN

```sql
/*
VERSIÓN 2FN: Eliminar dependencias parciales
Tabla 1: MIEMBROS_2FN - Datos que dependen del miembro
Tabla 2: PELICULAS_2FN - Películas con referencia al miembro
*/

-- Tabla de Miembros (información que depende ÚNICAMENTE del miembro)
CREATE TABLE MIEMBROS_2FN(
    IDMIEMBRO INT IDENTITY(1,1) PRIMARY KEY,
    NOMBRECOMPLETO VARCHAR(200),
    DIRECCION VARCHAR(150),
    SALUDO VARCHAR(4)
);

INSERT INTO MIEMBROS_2FN
VALUES 
('CARMEN RUIZ','JR CUZCO 234','SRA'),
('MARIA CAMARGO','AV SUCURSALES 1234','SRA'),
('MANUEL TAPIA','CALLE LOS ALISOS 109','SR'),
('RAFAEL ORTIZ','CALLE EL SALVADOR 129','SR');

SELECT * FROM MIEMBROS_2FN;

-- Tabla de Películas (relacionada con el miembro que las rentó)
CREATE TABLE PELICULAS_2FN(
    IDPELICULA INT IDENTITY(1,1) PRIMARY KEY,
    PELICULAS VARCHAR(100),
    MIEMBRO_ID INT,
    FOREIGN KEY(MIEMBRO_ID) REFERENCES MIEMBROS_2FN(IDMIEMBRO)
);

INSERT INTO PELICULAS_2FN
VALUES
('PIRATES DEL CARIBE',1),  -- IDMIEMBRO = 1 (Carmen)
('TITANIC',1),
('BOB ESPONJA',1),
('SPIDERMAN',2),            -- IDMIEMBRO = 2 (María)
('LO QUE EL VIENTO SE LLEVO',2),
('HOST',2),
('LA MOMIA',3),             -- IDMIEMBRO = 3 (Manuel)
('LOS GALACTICOS',3),
('EL ARO',3),
('LA MOMIA',4),             -- IDMIEMBRO = 4 (Rafael)
('TITANIC',4),
('SPIDERMAN',4);
```

**Resultado después de 2FN:**
```
TABLA MIEMBROS_2FN:
| IDMIEMBRO | NOMBRECOMPLETO | DIRECCION | SALUDO |
|-----------|----------------|-----------|--------|
| 1 | CARMEN RUIZ | JR CUZCO 234 | SRA |
| 2 | MARIA CAMARGO | AV SUCURSALES 1234 | SRA |
| 3 | MANUEL TAPIA | CALLE LOS ALISOS 109 | SR |
| 4 | RAFAEL ORTIZ | CALLE EL SALVADOR 129 | SR |

TABLA PELICULAS_2FN:
| IDPELICULA | PELICULAS | MIEMBRO_ID |
|------------|-----------|------------|
| 1 | PIRATES DEL CARIBE | 1 |
| 2 | TITANIC | 1 |
| 3 | BOB ESPONJA | 1 |
| 4 | SPIDERMAN | 2 |
| ... | ... | ... |
```

**Análisis del avance:**
```
✅ LO LOGRADO EN 2FN:
- Eliminada la redundancia de datos del miembro
- Cada miembro aparece UNA SOLA VEZ en la tabla MIEMBROS
- Las películas se relacionan mediante clave foránea
- Si Carmen cambia de dirección, solo se actualiza UN registro

❌ PROBLEMAS PERSISTENTES:
- Dependencia transitiva: SALUDO depende de NOMBRECOMPLETO
- El saludo "SRA" se repite para todas las mujeres
- Si queremos cambiar "SRA" por "SEÑORA", hay que actualizar múltiples registros
```
---

## Tercera Forma Normal (3FN)

### Teoría de 3FN

```sql
/*
TERCERA FORMA NORMAL (3FN)
REQUISITOS:
1. Estar en 2FN
2. No tener dependencias transitivas
   (Una columna no clave no puede depender de otra columna no clave)

DEPENDENCIA TRANSITIVA DETECTADA:
- IDMIEMBRO → SALUDO (SALUDO depende de IDMIEMBRO)
- Pero SALUDO también depende de algo más (el género, que está en NOMBRECOMPLETO)
- SOLUCIÓN: Crear tabla independiente para SALUDOS

DEPENDENCIA TRANSITIVA:
Miembro → (NOMBRECOMPLETO) → SALUDO
```
```

### Implementación de 3FN

```sql
/*
VERSIÓN 3FN: Eliminar dependencias transitivas
Tabla 1: SALUDOS_3FN - Catálogo de saludos
Tabla 2: MIEMBROS_3FN - Miembros referenciando al saludo
Tabla 3: PELICULAS_3FN - Películas (igual que en 2FN)
*/

-- Primero creamos la tabla de saludos (catálogo)
CREATE TABLE SALUDOS_3FN(
    IDSALUDO INT IDENTITY(1,1) PRIMARY KEY,
    SALUDO VARCHAR(10)
);

INSERT INTO SALUDOS_3FN
VALUES ('SRA'), ('SR');

SELECT * FROM SALUDOS_3FN;

-- Luego la tabla de miembros con referencia a saludos
CREATE TABLE MIEMBROS_3FN(
    IDMIEMBRO INT IDENTITY(1,1) PRIMARY KEY,
    NOMBRECOMPLETO VARCHAR(200),
    DIRECCION VARCHAR(150),
    IDSALUDO INT,
    FOREIGN KEY (IDSALUDO) REFERENCES SALUDOS_3FN(IDSALUDO)
);

INSERT INTO MIEMBROS_3FN
VALUES 
('CARMEN RUIZ','JR CUZCO 234',1),  -- IDSALUDO = 1 (SRA)
('MARIA CAMARGO','AV SUCURSALES 1234',1),  -- IDSALUDO = 1 (SRA)
('MANUEL TAPIA','CALLE LOS ALISOS 109',2),  -- IDSALUDO = 2 (SR)
('RAFAEL ORTIZ','CALLE EL SALVADOR 129',2);  -- IDSALUDO = 2 (SR)

-- Tabla de películas (igual que en 2FN, pero con la nueva referencia)
CREATE TABLE PELICULAS_3FN(
    IDPELICULA INT IDENTITY(1,1) PRIMARY KEY,
    PELICULAS VARCHAR(100),
    MIEMBRO_ID INT,
    FOREIGN KEY(MIEMBRO_ID) REFERENCES MIEMBROS_3FN(IDMIEMBRO)
);

INSERT INTO PELICULAS_3FN
VALUES
('PIRATES DEL CARIBE',1),
('TITANIC',1),
('BOB ESPONJA',1),
('SPIDERMAN',2),
('LO QUE EL VIENTO SE LLEVO',2),
('HOST',2),
('LA MOMIA',3),
('LOS GALACTICOS',3),
('EL ARO',3),
('LA MOMIA',4),
('TITANIC',4),
('SPIDERMAN',4);
```

**Resultado final después de 3FN:**
```
TABLA SALUDOS_3FN:
| IDSALUDO | SALUDO |
|----------|--------|
| 1 | SRA |
| 2 | SR |

TABLA MIEMBROS_3FN:
| IDMIEMBRO | NOMBRECOMPLETO | DIRECCION | IDSALUDO |
|-----------|----------------|-----------|----------|
| 1 | CARMEN RUIZ | JR CUZCO 234 | 1 |
| 2 | MARIA CAMARGO | AV SUCURSALES 1234 | 1 |
| 3 | MANUEL TAPIA | CALLE LOS ALISOS 109 | 2 |
| 4 | RAFAEL ORTIZ | CALLE EL SALVADOR 129 | 2 |

TABLA PELICULAS_3FN:
| IDPELICULA | PELICULAS | MIEMBRO_ID |
|------------|-----------|------------|
| 1 | PIRATES DEL CARIBE | 1 |
| 2 | TITANIC | 1 |
| ... | ... | ... |
```

---

## Consultas para Verificar la Normalización

### Consultas que demuestran las ventajas

```sql
-- 1. Obtener todas las películas rentadas por Carmen Ruiz
SELECT 
    m.NOMBRECOMPLETO,
    p.PELICULAS
FROM MIEMBROS_3FN m
INNER JOIN PELICULAS_3FN p ON m.IDMIEMBRO = p.MIEMBRO_ID
WHERE m.NOMBRECOMPLETO = 'CARMEN RUIZ';

-- 2. Contar cuántas películas ha rentado cada miembro
SELECT 
    m.NOMBRECOMPLETO,
    COUNT(p.IDPELICULA) AS CantidadPeliculas
FROM MIEMBROS_3FN m
LEFT JOIN PELICULAS_3FN p ON m.IDMIEMBRO = p.MIEMBRO_ID
GROUP BY m.NOMBRECOMPLETO;

-- 3. Buscar todos los miembros que rentaron "TITANIC"
SELECT 
    m.NOMBRECOMPLETO,
    s.SALUDO
FROM MIEMBROS_3FN m
INNER JOIN PELICULAS_3FN p ON m.IDMIEMBRO = p.MIEMBRO_ID
INNER JOIN SALUDOS_3FN s ON m.IDSALUDO = s.IDSALUDO
WHERE p.PELICULAS = 'TITANIC';

-- 4. Cambiar un saludo (ejemplo de mantenimiento fácil)
-- Si queremos cambiar "SRA" por "SEÑORA", solo una actualización
UPDATE SALUDOS_3FN 
SET SALUDO = 'SEÑORA' 
WHERE SALUDO = 'SRA';
```

---

## Comparativa de las Formas Normales

| Característica | Sin Normalizar | 1FN | 2FN | 3FN |
|----------------|---------------|-----|-----|-----|
| **Datos atómicos** | ❌ | ✅ | ✅ | ✅ |
| **Sin grupos repetidos** | ❌ | ✅ | ✅ | ✅ |
| **Clave primaria** | ❌ | ✅ | ✅ | ✅ |
| **Sin redundancia de miembros** | ❌ | ❌ | ✅ | ✅ |
| **Sin dependencias transitivas** | ❌ | ❌ | ❌ | ✅ |
| **Facilidad de mantenimiento** | ❌ | ⚠️ | ✅ | ✅ |
| **Integridad referencial** | ❌ | ❌ | ✅ | ✅ |

---

## Resumen y Conclusiones

### Resumen del Proceso de Normalización

```
ESTADO INICIAL (No normalizada):
┌─────────────────────────────────────┐
│ Tabla única con todo mezclado       │
│ - Múltiples películas en una celda  │
│ - Datos redundantes                 │
│ - Sin claves                         │
└─────────────────────────────────────┘
                    ⬇️
PRIMERA FORMA NORMAL (1FN):
┌─────────────────────────────────────┐
│ Datos atómicos                       │
│ Cada película en su propia fila     │
│ Con clave primaria ID               │
│ AÚN HAY REDUNDANCIA DE MIEMBROS     │
└─────────────────────────────────────┘
                    ⬇️
SEGUNDA FORMA NORMAL (2FN):
┌─────────────────┐  ┌─────────────────┐
│ MIEMBROS        │  │ PELICULAS       │
│ - IDMIEMBRO (PK)│◄─┤ - MIEMBRO_ID (FK)│
│ - NOMBRE        │  │ - PELICULA      │
│ - DIRECCIÓN     │  └─────────────────┘
│ - SALUDO        │
└─────────────────┘
    ⬇️ (Eliminar dependencia transitiva)
TERCERA FORMA NORMAL (3FN):
┌─────────────────┐  ┌─────────────────┐
│ SALUDOS         │  │ MIEMBROS        │
│ - IDSALUDO (PK) │─►│ - IDSALUDO (FK)│
│ - SALUDO        │  │ - NOMBRE        │
└─────────────────┘  │ - DIRECCIÓN     │
                     └────────┬────────┘
                              │
                     ┌────────▼────────┐
                     │ PELICULAS       │
                     │ - MIEMBRO_ID (FK)│
                     │ - PELICULA      │
                     └─────────────────┘
```

### Ventajas de la Normalización

| Forma Normal | Problema que Resuelve | Ejemplo en Videoteca |
|--------------|----------------------|----------------------|
| **1FN** | Falta de atomicidad | Una celda con múltiples películas |
| **2FN** | Dependencias parciales | Datos de miembros repetidos |
| **3FN** | Dependencias transitivas | Saludo depende del nombre |

### Beneficios Obtenidos

```
1. INTEGRIDAD DE DATOS:
   - No más datos inconsistentes
   - Las relaciones están claramente definidas

2. MANTENIMIENTO SIMPLIFICADO:
   - Actualizar dirección de Carmen: 1 registro
   - Cambiar "SRA" por "SEÑORA": 1 registro
   - Eliminar un miembro: No afecta otros datos

3. FLEXIBILIDAD EN CONSULTAS:
   - Fácil encontrar quién rentó qué película
   - Posibilidad de consultas complejas sin errores

4. AHORRO DE ESPACIO:
   - Eliminada la redundancia
   - Datos almacenados una sola vez
```

### En Pocas Palabras

```
-- 1FN: "Una cosa por celda" (datos atómicos)
-- 2FN: "Los datos dependen de la clave completa" (separar entidades)
-- 3FN: "Los datos dependen directamente de la clave" (sin dependencias transitivas)

La normalización no es un fin en sí mismo, sino un medio para:
- Mantener la integridad de los datos
- Facilitar el mantenimiento
- Permitir consultas eficientes
```

### Consideraciones Finales

```sql
/*
CONCLUSIONES:

1. La normalización es un proceso GRADUAL:
   - No siempre es necesario llegar a 3FN
   - A veces 2FN es suficiente para ciertos casos
   - El equilibrio depende de las necesidades

2. Beneficios prácticos en la VIDEOTECA:
   - Podemos agregar nuevos saludos sin modificar miembros
   - Podemos tener miembros sin películas rentadas
   - Las consultas son más precisas y confiables

3. Regla de oro:
   - Diseña pensando en 3FN por defecto
   - Desnormaliza solo cuando sea necesario por rendimiento
   - La integridad de datos es más importante que la velocidad

4. Para recordar:
   - 1FN: Elimina grupos repetidos (una película por fila)
   - 2FN: Separa entidades (miembros por un lado, películas por otro)
   - 3FN: Elimina dependencias (saludos como tabla independiente)
*/
```
