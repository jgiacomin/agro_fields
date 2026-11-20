# QA integral para el lanzamiento — Agro Fields V8

**Inicio:** 18/11/2026. **Objetivo:** revisar toda la app antes de publicar en Android (antes del 12/12/2026) y, al mismo tiempo, dejar cargado un campo de demo para mostrar a los Fundadores.

Los datos exactos para cargar están en `docs/CAMPO_DEMO_DATOS.md`.

## Cómo se usa esta lista

1. Se hace **una tanda por vez**, en orden.
2. En cada paso: hacer lo que dice y mirar si pasa lo que dice "Debería".
3. Marcar **✅** si anduvo, **❌** si no. Si algo falla: **captura de pantalla + número de paso** (por ejemplo "T1-07").
4. No arreglar nada en el momento: se anotan los errores, y al final de cada tanda se arreglan juntos en una rama `qa-tanda-N`.

**Dónde probar:** Chrome (`flutter run -d chrome`) y, en las tandas 1 y 4, también **Chrome en modo celular** (F12 → ícono de celular → Pixel 7).

**Cuentas:**
- **Dueño** = tu cuenta (también es admin).
- **Segunda cuenta** = compradorb (para encargado, profesional y comprador).

## Campo de demo

Se usa un campo **ficticio**, inspirado en el aviso de Carlos Tejedor pero **sin datos reales del dueño**, porque se va a mostrar a otras personas.

| Dato | Valor |
|---|---|
| Nombre | Estancia Demo La Esperanza |
| País / provincia / localidad | Argentina / Buenos Aires / Carlos Tejedor |
| Superficie | 3.290 ha |
| Uso | 2.390 ha ganaderas, 400 ha agrícolas, 500 ha de laguna |
| Actividades | Ganadería y agricultura (y un galpón de aves para mostrar) |

---

## Tanda 1 — El dueño carga su campo (gestión)

| Paso | Qué hacer | Debería | ✅/❌ | Nota |
|---|---|---|---|---|
| T1-01 | Entrar con Google | Pide aceptar términos (si es la primera vez) y después muestra el Inicio | | |
| T1-02 | Crear el campo de demo con los datos de arriba | Aparece en "Mis campos" del Inicio | | |
| T1-03 | Ficha → Ubicación: marcar el campo en el mapa | Queda guardado; al volver, el punto sigue ahí | | |
| T1-04 | Documentos: cargar una escritura (sin datos reales) con vencimiento y adjuntar un PDF | Se ve en la lista; "Ver archivo" lo abre | | |
| T1-05 | Documentos: cargar una certificación con vencimiento en menos de 30 días | Aparece el aviso de vencimiento | | |
| T1-06 | Suelo: cargar un análisis (pH 6,2, MO 3,1 %) con fecha | Decimales con coma y fecha dd/mm/aaaa | | |
| T1-07 | Producción → "+ Lote o potrero": Potrero 1 (800 ha), Potrero 2 (600 ha), Corral 1 (capacidad 500), Lote 3 agrícola (400 ha), Galpón 1, Laguna (tipo "otro") | Aparecen todos en "Lotes, potreros y corrales" | | |
| T1-08 | "+ Animales" → Ganadería → "Rodeo de cría" en Potrero 1 | Aparece en Rodeos | | |
| T1-09 | Entrada: 300 vacas, compra | El rodeo muestra 300 cabezas | | |
| T1-10 | Entrada: 120 terneros, nacimiento | 420 cabezas | | |
| T1-11 | Cambio de potrero: 100 vacas de Potrero 1 a Potrero 2 | "Dónde están" muestra los dos potreros | | |
| T1-12 | Vacuna o tratamiento: aftosa a 420 animales | Queda en la historia | | |
| T1-13 | Pesaje terneros: 180 kg hoy; otro pesaje con fecha de hace 30 días: 150 kg | Ganancia diaria ≈ 1 kg/día | | |
| T1-14 | Salida: 3 terneros por muerte | Mortandad calculada | | |
| T1-15 | "+ Animales" → Aves → "Galpón 1 ponedoras" → Entrada 2000 ponedoras | Dice "animales", ícono de huevo | | |
| T1-16 | "+ Nuevo cultivo": Soja 2026/27 en Lote 3 | Aparece en Cultivos | | |
| T1-17 | Siembra: 400 ha, material y densidad | Queda en el cultivo | | |
| T1-18 | Monitoreo: plaga, nivel medio, fuente "recorrida" | Queda en el cultivo | | |
| T1-19 | Stock: cargar "Glifosato 66%" con stock inicial 1000 l y mínimo 200 | Aparece en Stock | | |
| T1-20 | Aplicación: glifosato 2 l/ha en 400 ha, viento 20 km/h | Avisa por el viento; al guardar descuenta 800 l y quedan 200 l (aviso de mínimo) | | |
| T1-21 | Economía: 3 gastos (insumos en ARS, combustible en USD, sanidad) | Totales por moneda, sin convertir | | |
| T1-22 | Traslados: 50 novillos al frigorífico, con transportista y guía | Queda "Programado"; pasarlo a "Entregado" con 49 recibidos → avisa la diferencia | | |
| T1-23 | Emergencias: registrar granizo, gravedad media | Aparece en la lista | | |
| T1-24 | Emergencias: activar "Mi campo puede recibir" (hacienda, 300 cabezas) | Queda guardado | | |
| T1-25 | Emergencias: "Ver alertas oficiales" | Abre la página del SMN | | |
| T1-26 | Historia del territorio: cargar un canal (2018) y un camino (2022) | Se ven junto con la emergencia de granizo | | |
| T1-27 | Operaciones: venta de hacienda con cheque a 30 días | Avisa 7 días antes del vencimiento | | |
| T1-28 | Volver al Inicio | El resumen muestra los números del campo de demo | | |
| T1-29 | Repetir T1-28, T1-07 y T1-09 en **modo celular** | Nada se corta ni se superpone | | |

## Tanda 2 — El equipo (encargado y profesional)

| Paso | Qué hacer | Debería | ✅/❌ | Nota |
|---|---|---|---|---|
| T2-01 | Dueño: Encargados → invitar con áreas "producción" y "stock" | Da un código | ✅ | Probado 20/11. Primero aceptó un código inventado (ver Errores). |
| T2-02 | Segunda cuenta: usar el código | Ve el campo de demo como encargado | ✅ | La segunda cuenta ve el campo como encargado. |
| T2-03 | Encargado: cargar una entrada en el rodeo | Se guarda | ✅ | Lo que carga el encargado lo ve el dueño (stock de combustible). |
| T2-04 | Encargado: intentar entrar a Economía | No puede (no tiene esa área) | ✅ | En La tana no aparece Economía; en Campo La Esperanza sí, porque tiene "Gastos". |
| T2-05 | Dueño: quitarle el permiso al encargado | El encargado deja de ver el campo | ✅ | Quedan "Sin acceso (quitado)" en la lista (trazabilidad). |
| T2-06 | Segunda cuenta: Mi código profesional → copiar | Muestra el código | ✅ |  |
| T2-07 | Dueño: Profesionales → invitar con ese código | Queda invitado | ✅ |  |
| T2-08 | Profesional: registrar una intervención con evidencia | El dueño la ve | 🟡 | Se registra y el dueño la ve, pero no se puede adjuntar evidencia (ver Errores). |
| T2-09 | Profesional: ver Historia del territorio | La ve, pero no puede cargar | ✅ | Antes no había cómo llegar (ver Errores). Arreglado: solo lectura. |

## Tanda 3 — El mercado (publicar, aprobar, contactar)

| Paso | Qué hacer | Debería | ✅/❌ | Nota |
|---|---|---|---|---|
| T3-01 | Dueño: publicar el campo de demo en venta | Queda "pendiente de aprobación" | ✅ | Con una cuenta común (comprador.agrofields). |
| T3-02 | Admin: Administración → Publicaciones → aprobar | Pasa a publicado | ✅ | Se aprobaba pero salía un error en inglés al recargar (ver Errores). Arreglado. |
| T3-03 | Segunda cuenta: Mercado | Ve el campo con los datos públicos, sin datos privados | 🟡 | Solo datos públicos, bien. Falta precio, venta/alquiler y fotos (ver Errores). |
| T3-04 | Comprador: "Enviar solicitud" | El dueño la ve en "Solicitudes recibidas" | ✅ | La solicitud llega. Quedaba cargando para siempre (ver Errores). Arreglado. |
| T3-05 | Comprador y dueño: chat | Los mensajes llegan a los dos | ✅ | Con usuarios comunes la lista de conversaciones salía vacía (ver Errores). Arreglado. |
| T3-06 | Admin: rechazar otra publicación con un motivo | Vuelve a borrador | ✅ | Sin el error de recarga. |

## Tanda 4 — Cuenta, plan, sin señal y celular

| Paso | Qué hacer | Debería | ✅/❌ | Nota |
|---|---|---|---|---|
| T4-01 | Mi plan (dueño) | Muestra Esencial | | |
| T4-02 | Admin: dar de alta a la segunda cuenta como Fundador | Su "Mi plan" muestra Pro gratis por 12 meses | | |
| T4-03 | Sin señal (F12 → Network → Offline): cargar un evento en el rodeo | Se guarda en el teléfono; aparece el aviso de pendientes | | |
| T4-04 | Volver a Online | El evento sube solo y el aviso desaparece | | |
| T4-05 | Sin señal: intentar adjuntar un archivo | Avisa que hace falta señal | | |
| T4-06 | Términos: leerlos desde el menú | Se ven completos | | |
| T4-07 | Segunda cuenta: "Borrar mi cuenta" | Queda el pedido; el admin lo ve en Bajas | | |
| T4-08 | Recorrer Inicio, ficha, Producción, Stock y Emergencias en modo celular | Nada se corta | | |

---

## Errores encontrados

| Paso | Qué pasó | Gravedad (🔴 bloquea / 🟡 molesta / ⚪ estético) | Arreglado en |
|---|---|---|---|
| General | Cuesta entender cómo se usa sin preguntar: dónde está el suelo, que los lugares se cargan dentro de Producción, que a un rodeo se le suman animales con "Registrar evento", cómo confirmar el punto del mapa. Propuesta aprobada (18/11): "Primeros pasos" con tildes en la ficha (cada renglón lleva a su pantalla) + una frase de ayuda en cada pantalla, sobre todo vacía. Después del lanzamiento: videos cortos y manual simple | 🔴 | Grupo A (ayudas) + Grupo B "Primeros pasos" (rama qa-primeros-pasos) |
| — | Resumen de Producción muestra "-2 cabezas" con datos de prueba viejos (visto el 18/11) | ⚪ | Grupo A: "Revisar" / "cuentas para revisar" |
| T1-02 | "Mis campos" no está ordenado por fecha: el campo nuevo aparece al final y es fácil tocar otro por error (pasó: secciones 2 y 3 cargadas en "La Esperanza"). Ordenar del más nuevo al más viejo | 🟡 | Grupo A (main d70ed3d) |
| T1-03 | El mapa arrancaba mostrando todo Argentina y Paraguay: costaba encontrar el campo | 🟡 | rama `qa-mapa`: arranca en la localidad + buscar pueblo + pegar coordenadas o link |
| T1-04 | No se puede archivar un documento cargado por error. Agregar "Archivar" (queda en la historia, sale de la lista; no se borra) | 🟡 | |
| T1-06 | Suelo es difícil de encontrar (está abajo, en "Información del expediente"). Ponerlo entre los botones de "Gestión del campo" | 🟡 | Grupo A (main d70ed3d) |
| T1-03 | La lupa de la cajita de búsqueda del mapa queda escondida a la derecha | ⚪ | Grupo A: botón "Buscar" |
| T1-07 | Al crear un lugar no se puede cargar la capacidad (cabezas del corral, aves del galpón). El modelo y las reglas ya la aceptan; falta en la pantalla. La necesita AF-112 (ocupación de corrales) | 🟡 | Grupo A (main d70ed3d) |
| T1-07 | La pantalla dice "Nuevo potrero" / "Guardar potrero" aunque se elija corral, galpón o estanque | ⚪ | Grupo A (main d70ed3d) |
| T1-27 | En "Nueva operación", los botones cabezas / kg / toneladas / unidades no tienen título: no se entiende que son la unidad de la cantidad. Agregar "¿En qué unidad?" | ⚪ | Grupo A (main d70ed3d) |
| T1-02 | La pantalla de crear campo dice "Crear Activo Agro" / "Nombre del activo" (palabra interna): debería decir "Crear campo" / "Nombre del campo" | ⚪ | |
| T1-02 | La pantalla de crear campo tiene el diseño viejo (campos con rayita) y la superficie queda debajo de la descripción: es fácil poner las hectáreas en la descripción | ⚪ | |
| T2-01 | Al invitar encargado (o profesional) se aceptaba cualquier código, aunque no fuera de ningún usuario: quedaba un "encargado fantasma". Además el administrador saltaba el control | 🟡 | rama `qa-codigo-valido` (58deff2): regla `exists(usuarios/...)` para todos, también el admin; cartel "Código equivocado" |
| T2-09 | El profesional no tenía cómo llegar a la Historia del territorio (la regla lo permitía, faltaba el botón) y la pantalla mostraba "+ Cargar" y "Corregir" | 🟡 | rama `qa-prof-territorio` (2df11d2): "Ver historia del territorio" + modo solo lectura |
| T2-08 | La intervención del profesional no permite adjuntar evidencia (el Concepto la pide con evidencia). Requiere que el profesional pueda subir archivos (Storage Rules, mismo límite que el archivo del territorio) | 🟡 | Pendiente |
| T2-05 | El título "Campos donde soy encargado" se corta en pantallas angostas | ⚪ | Pendiente: acortar a "Soy encargado" |
| General | Las pruebas como dueño se hicieron con la cuenta de administrador, que salta controles. Para las tandas 3 y 4 usar como dueño una cuenta común | — | Anotado |
| T3-02 | Al aprobar (y al dar de alta Fundadores o completar bajas) salía "setState() callback argument returned a Future"; la acción se guardaba igual | 🟡 | rama `qa-mercado-arreglos` (ba6af68) |
| T3-04 | "Solicitudes recibidas" quedaba cargando para siempre: intentaba leer nombre y email del interesado, que las reglas no dejan (privacidad). Al aceptar no llevaba al chat | 🟡 | rama `qa-mercado-arreglos`: texto "Un usuario de Agro Fields está interesado…" y abre el chat al aceptar |
| T3-05 | Con usuarios comunes "Mis conversaciones" salía vacía (misma causa: leer datos del otro usuario). Con la cuenta admin andaba | 🔴 | rama `qa-mercado-arreglos`: muestra "Interesado" / "Dueño del campo" |
| T3-03 | El Mercado no muestra precio ni si es venta o alquiler, y no tiene fotos | 🔴 | Pendiente: GAP del Mercado para inmobiliarias |
| T3-03 | "Confianza 44 %" y "Madurez 55 %" no se explican; "Tipo: agricola", "agricultura" e "Interés: inversion" sin tilde ni mayúscula; tarjetas con diseño viejo (rosado, emojis) | 🟡 | Pendiente: GAP del Mercado |
| T3-04 | El tipo de interés aparece como "inversion" aunque el campo está en venta | 🟡 | Pendiente: revisar en el GAP del Mercado |
| T3-05 | Los dos participantes del chat no se ven por su nombre (privacidad); que cada uno elija qué nombre mostrar al consultar o aceptar | 🟡 | Pendiente: GAP del Mercado (cambia datos y reglas) |
