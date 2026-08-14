# MATRIZ — FICHA MAESTRA ACTIVO AGRO V1

## Objetivo

Documento de trabajo para traducir la Ficha Maestra del Activo Agro V1
a la arquitectura existente de Agro Fields.

La matriz permitirá determinar:

- qué información ya existe en ActivoAgroV2;
- qué información falta;
- qué información pertenece a modelos especializados;
- dónde se persiste;
- qué información requiere evidencia;
- qué información debe generar auditoría;
- qué forma parte del MVP.

---

## Regla principal

No agregar campos ni crear modelos nuevos hasta comprobar
si la información ya existe en la arquitectura actual.

La Ficha Maestra es la referencia funcional.
La arquitectura existente es la referencia técnica.

---

## Matriz

| Bloque | Campo | ActivoAgroV2 | Modelo especializado | Firestore | Evidencia | Auditoría | MVP | Observaciones |
|---|---|---|---|---|---|---|---|---|
| Identidad | | | | | | | | |
| Ubicación | | | | | | | | |
| Superficie | | | | | | | | |
| Producción | | | | | | | | |
| Infraestructura | | | | | | | | |
| Situación comercial | | | | | | | | |
| Documentación | | | | | | | | |
| Normativa | | | | | | | | |
| Evidencias | | | | | | | | |
| Historial | | | | | | | | |
| Auditoría | | | | | | | | |
| Confianza | | | | | | | | |
| Información faltante | | | | | | | | |

---

## Estados de análisis

### 🟢 Existe

El dato ya está correctamente representado
en el modelo o arquitectura existente.

### 🟡 Existe parcialmente

Existe información relacionada, pero requiere
revisión o ampliación.

### 🔵 Modelo especializado

El dato no debe incorporarse directamente al
ActivoAgroV2 y corresponde a otro modelo.

### 🔴 Falta

La arquitectura actual no representa adecuadamente
el dato.

### ⚪ Pendiente de decisión

Necesita análisis antes de modificar código.

---

## Criterios MVP

Un campo será considerado MVP cuando:

1. sea necesario para identificar el activo;
2. sea necesario para comprender su situación productiva;
3. sea necesario para publicar o evaluar el activo;
4. sea necesario para trazabilidad;
5. sea necesario para confianza o validación;
6. sea necesario para detectar información faltante.

---

## Principio de no duplicación

Antes de crear:

- un campo;
- un modelo;
- una colección;
- un servicio;

se debe comprobar si la arquitectura existente
ya resuelve esa necesidad.

---

## Próxima revisión

La matriz será completada campo por campo utilizando:

1. `FICHA_MAESTRA_ACTIVO_AGRO_V1.md`
2. `ActivoAgroV2`
3. servicios existentes;
4. modelos especializados;
5. arquitectura de datos;
6. Firebase / Firestore;
7. auditoría y trazabilidad.

No se implementarán cambios de código hasta completar
la revisión correspondiente.