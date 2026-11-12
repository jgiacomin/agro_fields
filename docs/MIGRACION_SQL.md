# Agro Fields V8 — Camino de migración a SQL (PostgreSQL)

**Fecha:** 12/11/2026 · **Matriz:** AF-050 (separación de capas) y AF-051 (camino a SQL sin migrar antes de tiempo)

> Decisión vigente (06/11/2026): seguimos con **Firebase**, con seguridad muy fuerte, y dejamos el sistema **preparado** para migrar a SQL **si crece**, después del lanzamiento. Este documento **no** pide migrar ahora: es el mapa para cuando haga falta.

---

## 1. Por qué está preparado

1. **Capas separadas:** Pantalla → Servicio → Modelo → Firebase. Las pantallas nunca hablan con Firebase directamente. Para migrar se cambian los **servicios**; pantallas y modelos quedan.
2. **Modelos planos** con `toMap` / `fromMap` y nombres fijos: cada campo pasa a ser una columna.
3. **IDs armados en el teléfono** (ej.: `mov_…`, `emer_…`, `int_…`), que evitan duplicados sin señal. En SQL pasan a ser la clave primaria (texto).
4. **Relaciones explícitas:** casi todo cuelga de un `activoAgroId` (o `activoId`), que en SQL es la clave foránea a `activos_agro`.
5. **Eventos de solo agregar** (no se editan ni se borran): ideales para SQL y auditoría.
6. **Los cálculos viven en la app** (existencias, rendimiento, coherencia de traslados, vigencia de documentos, control de operaciones): se mueven tal cual.
7. **Cada regla de seguridad tiene su prueba** (224 en `test_rules`): son la lista de control para verificar que el servidor nuevo proteja igual.

---

## 2. Colección → tabla

| Colección Firestore | Tabla SQL | Clave | Relación principal | Notas |
|---|---|---|---|---|
| `usuarios` | `usuarios` | `uid` | — | El rol no lo cambia el usuario. |
| `activos_agro` | `activos_agro` | `activo_id` | `propietario_id`, `publicador_id` → usuarios | Expediente privado. Hoy guarda dentro listas (historial, documentos, participantes, derechos): ver punto 3. |
| `activos_publicos` | `activos_publicos` | `activo_id` | = `activos_agro.activo_id` | Resumen publicable (13 campos). |
| `hashes_activos` | `hashes_activos` | `hash` | `creado_por` → usuarios | Evita activos duplicados. |
| `eventos_afectacion` | `eventos_afectacion` | `evento_id` | `activo_agro_id` | Emergencias. Afectaciones y consecuencias → tablas hijas. |
| `evidencias` | `evidencias` | `evidencia_id` | `activo_agro_id` | |
| `auditoria_activos` | `auditoria_activos` | `evento_id` | `activo_id`, `usuario_id` | Solo agregar. |
| `recursos` | `recursos` | `recurso_id` | `activo_agro_id` | |
| `movimientos_stock` | `movimientos_stock` | `movimiento_id` | `recurso_id`, `activo_agro_id` | Stock = suma de movimientos. |
| `trabajos` | `trabajos` | `trabajo_id` | `activo_agro_id` | |
| `oportunidades_agro` | `oportunidades_agro` | `oportunidad_id` | `activo_id` | Privada. |
| `solicitudes_contacto` | `solicitudes_contacto` | `solicitud_id` | `activo_id`, usuarios | |
| `chats` / `mensajes` | `chats`, `mensajes` | `chat_id` / `mensaje_id` | `mensajes.chat_id` → chats | Subcolección → tabla hija. |
| `campos` | `campos_legacy` | `campo_id` | — | Congelada, solo lectura (paso 5). Migrar como archivo histórico. |
| `inversiones` | `inversiones` | `inversion_id` | usuarios | Pendiente de auditoría de seguridad. |
| `publicaciones_inversion` | `publicaciones_inversion` | `publicacion_id` | — | Pendiente de auditoría de seguridad. |
| `autorizaciones_activos` | `autorizaciones` | `autorizacion_id` (nombre armado) | `activo_id`, `usuario_autorizado`, `quien_otorga` | En SQL, además: índice único (activo, usuario, permiso, ámbito). |
| `intervenciones_profesionales` | `intervenciones_profesionales` | `intervencion_id` | `activo_agro_id`, `profesional_id` | Solo agregar. |
| `movimientos` | `traslados` | `movimiento_id` | `activo_agro_id`, `destino_activo_id` (opcional) | Núcleo común de transporte, campo `actividad`. |
| `unidades_productivas` | `unidades_productivas` | `unidad_id` | `activo_agro_id` | Lotes, potreros, corrales… |
| `grupos_productivos` | `grupos_productivos` | `grupo_id` | `activo_agro_id`, `unidad_inicial_id` | Rodeos y cultivos de la campaña. |
| `eventos_productivos` | `eventos_productivos` | `evento_id` | `grupo_id`, `unidad_id`, `activo_agro_id` | Solo agregar (altas, bajas, siembra, cosecha…). |
| `operaciones_protegidas` | `operaciones_protegidas` | `operacion_id` | `activo_agro_id` | Garantías → tabla hija. |
| `eventos_operacion` | `eventos_operacion` | `evento_id` | `operacion_id` | Solo agregar. |
| Storage (archivos) | almacenamiento de archivos + columna con la ruta | — | — | Los archivos no van a SQL: se guarda la ruta. |

---

## 3. Lo que cambia de forma (listas dentro de documentos)

En Firestore, algunas listas viven **dentro** del documento del campo. En SQL conviene pasarlas a **tablas hijas**:

| Hoy dentro de `activos_agro` | Tabla hija SQL |
|---|---|
| `historial` | `historial_activo` (solo agregar) |
| `documentacion.documentosEstructurados` | `documentos_activo` |
| `participantes` | `participantes_activo` |
| `derechos`, `relacionesJuridicas` | `derechos_activo`, `relaciones_juridicas` |
| `infraestructura`, `producciones` | `infraestructura_activo`, `modulos_produccion` |
| `ubicacion`, `suelo`, `economia`, `confianza`, `evaluacion`, `madurez`, `disponibleParaRecibir` | columnas en `activos_agro` o tablas 1 a 1 |

Esto además permite el **historial unificado** (pendiente 🟡): una sola consulta que junte historial, traslados, intervenciones y emergencias.

---

## 4. El trabajo grande: la seguridad

Hoy las reglas viven en Firebase (`firestore.rules`). En SQL **no hay reglas por documento**: hace falta un **servidor propio (API)** que haga los mismos controles antes de leer o escribir.

* Cada función de las reglas (`puedeActivo`, `esDuenoActivo`, `tieneAutorizacion`, `puedeProduccion`, `puedeOperaciones`, `puedeMovimientos`…) pasa a ser una función del servidor.
* Los controles de datos (cantidades > 0, estados permitidos, solo agregar, quién firma) pasan a validaciones del servidor y a restricciones de la base (`CHECK`, `NOT NULL`, claves foráneas).
* **Las 224 pruebas de `test_rules` se reescriben contra el servidor nuevo.** Hasta que no den todas en verde, no se migra.

---

## 5. Pasos para migrar (cuando haga falta)

1. **Decidir con datos:** cantidad de usuarios, costo de Firebase, consultas que Firestore no resuelve bien.
2. **Crear el esquema** (tablas, claves, índices) a partir de la sección 2 y 3.
3. **Construir la API** con la seguridad de la sección 4 y pasar las 224 pruebas.
4. **Escribir un servicio nuevo por módulo** que hable con la API (mismos métodos que hoy). Las pantallas no cambian.
5. **Copiar los datos** de Firestore a SQL con un script, comparando cantidades por colección.
6. **Período en paralelo:** leer de los dos lados y comparar.
7. **Cambiar** módulo por módulo, con Bitácora, evidencia y posibilidad de volver atrás.

---

## 6. Reglas para no perder la preparación

* Ninguna pantalla nueva habla directo con Firebase: siempre a través de un servicio.
* Todo dato nuevo con `toMap`/`fromMap`, nombre fijo y su relación (`activoAgroId`).
* Los cálculos, en la app (o en el servicio), no en Firebase.
* Toda regla nueva con su prueba en `test_rules`.
* Evitar listas que crecen sin límite dentro de un documento: mejor una colección aparte.
