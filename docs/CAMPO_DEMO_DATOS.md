# Campo de demo: Estancia Demo La Esperanza

Datos **ficticios** para cargar en la app, paso por paso, en el orden de la Tanda 1 del QA (`docs/QA_LANZAMIENTO_V8.md`). Están armados con los mismos nombres que tienen los campos en cada pantalla. Lo que no figura acá se deja vacío.

En las fechas, "hoy" es el día que lo cargás.

---

## 1. Crear el campo (T1-02)

Inicio → "+ Nuevo campo"

| Campo de la pantalla | Qué escribir |
|---|---|
| Nombre del activo | Estancia Demo La Esperanza |
| País | Argentina |
| Provincia | Buenos Aires |
| Departamento / Estado | Carlos Tejedor |
| Localidad | Carlos Tejedor |
| Código postal | 6455 |
| Superficie hectáreas | 3290 |
| Descripción | Campo mixto de demostración: 2.390 ha ganaderas, 400 ha agrícolas y 500 ha de laguna. Datos ficticios para mostrar la app. |

## 2. Ubicación en el mapa (T1-03)

Ficha → Ubicación → tocá el mapa cerca de **Carlos Tejedor** (oeste de la provincia de Buenos Aires, cerca del límite con La Pampa) → Guardar.

## 3. Documentos (T1-04 y T1-05)

Ficha → Documentos → "+ Nuevo documento"

**Documento 1: escritura**

| Campo | Qué poner |
|---|---|
| Tipo de documento | Escritura |
| Descripción | Escritura del campo (demo) |
| ¿Quién lo emitió? | Escribanía Demo |
| Número, matrícula o expediente | DEMO-0001 |
| Fecha de emisión | 15/03/2015 |
| ¿Vence? | vacío (no vence) |
| Provincia o departamento | Buenos Aires |
| Si se vende el campo, ¿pasa al nuevo dueño? | Sí, es transferible |
| Archivo | cualquier PDF de prueba (no uses una escritura real) |

**Documento 2: certificación** (para ver el aviso de vencimiento)

| Campo | Qué poner |
|---|---|
| Tipo de documento | Certificación |
| ¿Qué certifica? | Bienestar animal (demo) |
| ¿A qué animales o producción aplica? | Rodeo de cría |
| ¿Quién lo emitió? | Certificadora Demo |
| Fecha de emisión | 01/12/2025 |
| ¿Vence? | **dentro de 20 días** (por ejemplo, si hoy es 18/11, el 08/12/2026) |
| Si se vende el campo, ¿pasa al nuevo dueño? | No es transferible |

## 4. Suelo (T1-06)

Ficha → Suelo

| Campo | Qué poner |
|---|---|
| Textura | Franco arenoso |
| Drenaje | Bueno |
| pH | 6,2 |
| Materia orgánica % | 3,1 |
| Profundidad | Profundo |
| Salinidad | Sin salinidad |
| Erosión | Leve |
| Clase de capacidad de uso | II |
| Limitaciones | Bajos que se anegan en años lluviosos |
| Observaciones | Análisis de suelo 2025 (demo) |

Si alguna opción no aparece igual, elegí la más parecida y anotalo en el QA.

## 5. Lugares (T1-07)

Producción → "+ Lote o potrero". Uno por vez:

| Tipo | Nombre | Hectáreas | Capacidad |
|---|---|---|---|
| Potrero | Potrero 1 | 800 | — |
| Potrero | Potrero 2 | 600 | — |
| Corral | Corral 1 | — | 500 |
| Lote | Lote 3 | 400 | — |
| Galpón | Galpón 1 | — | 3000 |
| Otro | Laguna | 500 | — |

## 6. Rodeo de vacas (T1-08 a T1-14)

**"+ Animales" → Ganadería**

| Campo | Qué poner |
|---|---|
| Nombre | Rodeo de cría |
| Etapa | Cría |
| ¿De quién son los animales? | Propios |
| ¿En qué potrero arranca? | Potrero 1 |

Después, dentro del rodeo → **"Registrar evento"**, uno por vez:

| # | Evento | Datos |
|---|---|---|
| 1 | Entrada | 300 · Vacas · Compra · Potrero 1 · hoy |
| 2 | Entrada | 120 · Terneros · Nacimiento · Potrero 1 · hoy |
| 3 | Cambio de potrero | 100 · Vacas · desde Potrero 1 hacia Potrero 2 · hoy |
| 4 | Vacuna o tratamiento | Aftosa · 420 animales · dosis 2 ml · hoy |
| 5 | Pesaje | Terneros · 120 · **150** kg · fecha de **hace 30 días** |
| 6 | Pesaje | Terneros · 120 · **180** kg · hoy |
| 7 | Salida | 3 · Terneros · Muerte · hoy |

Debería quedar: 417 cabezas, ganancia diaria de unos 1 kg/día y mortandad de unos 0,7 %.

## 7. Aves (T1-15)

**"+ Animales" → Aves**

| Campo | Qué poner |
|---|---|
| Nombre | Galpón 1 ponedoras |
| ¿En qué galpón o estanque arranca? | Galpón 1 |

Registrar evento → **Entrada**: 2000 · Ponedoras · Compra · Galpón 1 · hoy.

## 8. Cultivo de soja (T1-16 a T1-18)

**"+ Nuevo cultivo"**

| Campo | Qué poner |
|---|---|
| ¿Qué cultivo? | Soja |
| ¿En qué lote? | Lote 3 |
| Campaña | 2026/27 |
| Variedad o híbrido | DM 46i20 |

Dentro del cultivo:

**Siembra:** 400 ha · material DM 46i20 · densidad 70 kg/ha · hoy.

**Monitoreo:**

| Campo | Qué poner |
|---|---|
| Fecha | hoy |
| ¿Qué miraste? | Plaga |
| ¿Qué viste? | Chinche verde en el borde norte, 2 por metro |
| Nivel | Medio |
| ¿De dónde sale el dato? | Recorrida |
| Recomendación | Volver a mirar en 5 días |

## 9. Stock (T1-19)

Ficha → Stock → "+ Nuevo producto"

| Campo | Qué poner |
|---|---|
| Tipo | Agroquímico (o el más parecido) |
| Nombre | Glifosato 66% |
| Unidad | litros |
| ¿Cuánto tenés hoy? | 1000 |
| Mínimo para avisar | 200 |
| Notas | Depósito del galpón (demo) |

## 10. Aplicación (T1-20)

Cultivo de soja → **Aplicación**

| Campo | Qué poner |
|---|---|
| Fecha | hoy |
| Hectáreas aplicadas | 400 |
| Producto | Glifosato 66% |
| Dosis | 2 l/ha |
| ¿Quién aplicó? | Contratista Demo |
| Número de receta agronómica | REC-0001 |
| Viento en km/h | **20** (tiene que avisar por viento alto) |
| Temperatura en °C | 24 |
| Humedad del aire en % | 60 |
| ¿Descontar del stock? | Glifosato 66% · **800** |

Debería quedar: stock de glifosato en 200 litros, justo en el mínimo para avisar.

## 11. Gastos (T1-21)

Ficha → Economía → "+ Nuevo gasto", tres veces:

| # | Fecha | Monto | Moneda | ¿En qué se gastó? | ¿Para qué actividad? | Proveedor | Detalle |
|---|---|---|---|---|---|---|---|
| 1 | hoy | 2.400.000 | ARS | Insumos | Agricultura | Cooperativa Demo | Glifosato para la soja |
| 2 | hoy | 850 | USD | Combustible | Agricultura | Estación Demo | Gasoil para la siembra |
| 3 | hoy | 380.000 | ARS | Sanidad | Ganadería | Veterinaria Demo | Vacuna aftosa |

## 12. Traslado (T1-22)

Ficha → Traslados → "+ Nuevo traslado"

| Campo | Qué poner |
|---|---|
| ¿Qué se traslada? | Hacienda |
| Detalle de la carga | Novillos |
| Cantidad | 50 |
| Unidad | cabezas |
| ¿A dónde va? | Frigorífico Demo, Pehuajó (Buenos Aires) |
| Fecha de salida | hoy |
| Transportista | Transporte Demo |
| Patente | AA000AA |
| Número de guía o DTe | DTE-DEMO-0001 |

Después: pasarlo a **En camino** y luego a **Entregado**, con **49** recibidos. Tiene que avisar la diferencia de 1.

## 13. Emergencias (T1-23 a T1-25)

**Registrar emergencia**

| Campo | Qué poner |
|---|---|
| ¿Qué pasó? | Granizo |
| ¿Desde cuándo? | hace 5 días |
| ¿Qué tan grave es? | Medio |
| Hectáreas afectadas | 120 |
| Contá qué pasó | Granizo sobre el Lote 3 y parte del Potrero 2 (demo) |

**Mi campo puede recibir en una emergencia:** activado · Hacienda · capacidad "300 cabezas, Potrero 2 con agua" → Guardar.

**Ver alertas oficiales:** tiene que abrir el SMN.

## 14. Historia del territorio (T1-26)

Ficha → Historia del territorio, dos registros:

| # | ¿Qué cambió? | ¿Cuándo pasó? | Contá qué cambió | ¿Quién lo hizo? | ¿Cómo lo sabés? |
|---|---|---|---|---|---|
| 1 | Canal | 2018 | Canal de desagüe desde la laguna hacia el camino vecinal | Consorcio de productores | Lo contó el dueño anterior |
| 2 | Camino | 2022 | Se abrió un camino interno entre Potrero 1 y Lote 3 | El dueño | Lo vi / lo hice yo |

## 15. Operación protegida con cheque (T1-27)

Ficha → Operaciones → "+ Nueva operación"

| Campo | Qué poner |
|---|---|
| ¿Qué producto? | Hacienda (novillos) |
| Cantidad | 50 |
| Comprador | Frigorífico Demo SA |
| CUIT / RUC del comprador | 30-00000000-0 |
| ¿Quién firma por el comprador? | Juan Demo |
| Importe total | 45000000 |
| Forma de pago | Cheque |
| Notas | Operación de demostración |

Dentro de la operación → registrar **cheque acordado** con vencimiento **dentro de 5 días**, así aparece el aviso de los 7 días.

---

**Al terminar:** volvé al Inicio, mirá el resumen y recorré la ficha en modo celular (T1-28 y T1-29). Cualquier cosa que no ande o no coincida, captura + número de paso.
