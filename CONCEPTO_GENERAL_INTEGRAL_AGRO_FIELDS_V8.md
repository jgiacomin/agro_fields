# AGRO FIELDS V8
## Concepto General Integral del Sistema

**Documento de referencia conceptual y funcional**

**Estado:** Visión integral consolidada, con capacidades pendientes de diseño arquitectónico.

Actualización: 12/11/2026. Se suman las capacidades acordadas el 08, 10 y 11/11/2026.

Marcas de etapa: 🔴 entra en el lanzamiento de enero 2027 · 🟡 queda preparado (lugar en los datos, sin función completa) · 🟢 después del lanzamiento.

---

## 1. Identidad y propósito

Agro Fields V8 es un ecosistema tecnológico agropecuario, modular, interoperable y escalable, concebido para conectar productores, establecimientos, profesionales, empresas, cooperativas, instituciones, transportistas, compradores, inversores y organismos públicos y privados.

Su finalidad es facilitar la gestión integral de las actividades agropecuarias y agroindustriales, mejorar la disponibilidad y confiabilidad de la información, fortalecer la trazabilidad, simplificar procesos administrativos, mejorar la toma de decisiones y generar oportunidades de desarrollo económico.

No es solamente una aplicación de gestión rural ni un Marketplace. Es una plataforma de servicios y datos que permite que diferentes actores y aplicaciones trabajen conectados, conservando su autonomía y sus permisos.

### Principios fundamentales

- Simplicidad de uso.
- Modularidad funcional.
- Identidad digital permanente.
- Información respaldada y trazable.
- Privacidad y control de los datos.
- Interoperabilidad.
- Funcionamiento offline-first.
- Escalabilidad tecnológica.
- Adaptación a distintas actividades y escalas productivas.
- Cooperación entre actores públicos y privados.
- Innovación al servicio del productor.
- Independencia de plataformas comerciales y de certificación, con capacidad de conectarse a ellas.

### Independencia y conexión

Agro Fields es independiente de plataformas comerciales o de certificación (por ejemplo, las vinculadas al reglamento europeo de deforestación), pero queda preparado para conectarse con ellas. Sirve al productor más allá de cualquier entidad gremial, facilita información a certificadores, exportadores y compradores, y le indica al productor qué documentación necesita.

### Alcance tecnológico

- Aplicaciones Web, Android e iOS.
- Idiomas español e inglés.
- Arquitectura modular.
- Funcionamiento con conectividad limitada.
- Almacenamiento local y sincronización.
- Integración progresiva con servicios externos.
- Preparación para una futura evolución hacia SQL/PostgreSQL, sin convertirlo en requisito de la base offline actual.

---

## 2. El núcleo del sistema: Activo Agro y Expediente Digital Permanente

Esta es la columna vertebral de Agro Fields V8.

El sistema debe permitir que cada activo agropecuario tenga identidad propia, información organizada y una historia permanente, independientemente de quién lo administre o de los cambios que experimente a lo largo del tiempo.

### Concepto central

**Activo → Identidad → Expediente → Evidencias → Historial → Estado → Valor.**

### 2.1. Activo Agro

Es la entidad central que representa un activo agropecuario o productivo.

Puede comprender:

- Establecimientos rurales.
- Campos y parcelas.
- Rodeos y animales.
- Cultivos y producciones.
- Maquinaria y equipos.
- Instalaciones.
- Recursos productivos.
- Otros activos vinculados con la actividad agropecuaria.

Cada activo tendrá una identidad estable, relaciones, responsables, participantes, información productiva y antecedentes.

### 2.2. Expediente Digital Permanente

Es el repositorio organizado de información del activo.

Puede contener:

- Identificación y antecedentes.
- Ubicación y características territoriales.
- Suelos, agua y condiciones ambientales.
- Producción y evolución.
- Documentación.
- Fotografías y evidencias.
- Intervenciones profesionales.
- Movimientos y operaciones.
- Historial de titulares y participantes.
- Situación administrativa y documental.
- Información económica relacionada.
- Registros de verificación y auditoría.

El expediente debe diferenciar claramente:

1. Información declarada.
2. Documentación aportada.
3. Información obtenida de fuentes externas.
4. Información verificada.
5. Información pendiente de validación.

### 2.3. Privacidad y autorización

El expediente es privado y permanente. No es una ficha pública ni un catálogo comercial.

Los titulares podrán autorizar accesos específicos mediante autorizaciones granulares por:

- Activo.
- Módulo.
- Dato o conjunto de datos.
- Usuario o institución.
- Finalidad.
- Vigencia.

Las autorizaciones deberán poder revocarse y quedar registradas en la trazabilidad correspondiente.

### 2.4. Relación con otras aplicaciones

Un productor podrá utilizar el Expediente Digital aunque gestione su producción con otra aplicación.

El sistema deberá facilitar la incorporación, conservación, consulta y exportación de información, sin obligarlo a contratar todos los módulos de Agro Fields.

---

## 3. Gestión de establecimientos y territorio

Módulo destinado a administrar la dimensión física, geográfica y territorial de la actividad agropecuaria.

Funciones:

- Registro de establecimientos.
- Identificación de campos, parcelas y lotes.
- Georreferenciación.
- Límites y superficies.
- Características del suelo.
- Recursos hídricos.
- Instalaciones y caminos internos.
- Infraestructura.
- Ubicación de activos.
- Relaciones entre establecimientos y unidades productivas.
- Historial territorial.
- Información ambiental y climática.

Debe permitir relacionar el territorio con la producción, la logística, las emergencias y el expediente de cada activo.

---

## 4. Gestión Productiva

Módulo destinado a administrar las diferentes actividades agropecuarias, contemplando sus particularidades.

No debe existir un único modelo productivo rígido. Cada actividad necesita sus propios procesos, registros, indicadores y ciclos.

### 4.1. Agricultura

- Cultivos y variedades.
- Campañas agrícolas.
- Siembra y labores.
- Insumos.
- Aplicaciones.
- Fertilización.
- Seguimiento fenológico.
- Cosecha.
- Rendimientos.
- Calidad.
- Acopio y almacenamiento.
- Trazabilidad de lotes y producción.

### 4.2. Ganadería bovina

- Identificación individual y grupal.
- Rodeos y categorías.
- Nacimientos.
- Recría.
- Engorde.
- Reproducción.
- Sanidad.
- Alimentación.
- Pesajes.
- Movimientos.
- Existencias.
- Mortandad.
- Manejo de establecimientos.
- Trazabilidad de animales.

### 4.3. Tambo y lechería

- Identificación de animales.
- Producción individual y grupal.
- Ordeñe.
- Calidad de leche.
- Sanidad.
- Reproducción.
- Alimentación.
- Control de mastitis.
- Recolección.
- Refrigeración.
- Entregas a industria.
- Liquidaciones y costos.

### 4.4. Feedlot

- Ingreso de animales.
- Identificación y lotes.
- Dietas.
- Consumo.
- Conversión alimenticia.
- Pesajes.
- Sanidad.
- Ocupación de corrales.
- Costos.
- Salida y comercialización.

### 4.5. Vitivinicultura y fruticultura

- Identificación de parcelas.
- Variedades.
- Ciclos productivos.
- Manejo de cultivos.
- Sanidad.
- Riego.
- Cosecha.
- Calidad.
- Trazabilidad.
- Conservación y distribución.

### 4.6. Apicultura

- Identificación de apiarios.
- Colmenas.
- Ubicación.
- Traslados.
- Sanidad.
- Alimentación.
- Producción de miel.
- Extracción.
- Calidad.
- Trazabilidad y comercialización.

### 4.7. Otras actividades

El sistema deberá contemplar la incorporación modular de:

- Horticultura.
- Agricultura protegida.
- Producción porcina.
- Avicultura.
- Equinos.
- Ovinos y caprinos.
- Piscicultura.
- Producción de ranas.
- Forestación.
- Otras actividades agropecuarias y agroindustriales.

La incorporación de cada actividad requiere estudiar primero su funcionamiento real, sus particularidades y sus necesidades específicas.

---

## 5. Gestión de recursos, inventarios y trabajos

Administración de los recursos necesarios para desarrollar la actividad productiva.

### Recursos e inventarios

- Insumos.
- Alimentos.
- Semillas.
- Fertilizantes.
- Productos sanitarios.
- Combustibles.
- Herramientas.
- Maquinaria.
- Repuestos.
- Materiales.
- Existencias y movimientos de stock.

### Trabajos y operaciones

- Planificación de tareas.
- Órdenes de trabajo.
- Responsables.
- Recursos utilizados.
- Tiempo de ejecución.
- Consumos.
- Costos.
- Evidencias.
- Historial de ejecución.

Cada movimiento debe tener identificación, origen, destino, responsable y respaldo trazable según corresponda.

---

## 6. Economía y Gestión Empresarial

Módulo que permite conocer la situación económica de cada actividad, establecimiento y empresa.

Funciones:

- Ingresos y egresos.
- Costos directos e indirectos.
- Costos por actividad.
- Costos por lote.
- Costos por animal o unidad productiva.
- Presupuestos.
- Flujo de fondos.
- Deudas y compromisos.
- Cuentas por cobrar y pagar.
- Resultados económicos.
- Rentabilidad.
- Proyecciones.
- Gestión documental económica.

Debe relacionar la información económica con los registros reales de producción, inventarios, trabajos y comercialización.

### 6.1. Protección Comercial y Confianza

Capacidad destinada a reducir riesgos en las operaciones agropecuarias.

Incluye:

- Identificación y validación de compradores.
- Identificación de representantes y facultades.
- Registro de compromisos comerciales.
- Seguimiento de obligaciones.
- Exposición económica.
- Respaldo patrimonial y financiero verificable.
- Avales bancarios.
- Garantías de SGR.
- Seguros de crédito y caución.
- Documentación de respaldo.
- Seguimiento de entregas y cobros.

### 6.2. Operación Agropecuaria Protegida

Concepto específico para proteger al productor antes de entregar hacienda, granos u otros productos de valor.

El sistema debe permitir relacionar:

- Comprador.
- Productor.
- Operación.
- Importe.
- Forma de pago.
- Cheques y vencimientos.
- Garantías.
- Seguros.
- Avales.
- Entregas.
- Cobros.
- Incumplimientos.

Agro Fields no garantiza el pago ni reemplaza a las entidades financieras o aseguradoras. Proporciona información, organización, controles y conexiones que ayudan a reducir riesgos.

### 6.3. Red de Inteligencia y Verificación de Cheques Agropecuarios

Capacidad complementaria destinada a identificar señales de riesgo relacionadas con cheques recibidos por productores participantes.

Considera:

- Identificación del librador y CUIT.
- Banco emisor.
- Identificador del cheque.
- Importe.
- Fecha de emisión.
- Vencimiento.
- Estado y antecedentes verificables.
- Concentración de cheques.
- Exposición acumulada.
- Compromisos distribuidos entre diferentes productores.
- Señales de alerta temprana.

La información debe tratarse con controles de privacidad, acceso autorizado, validación y protección contra errores o denuncias infundadas.

### 6.4. Mercado de Financiación de Operaciones Agropecuarias

Visión futura para conectar productores, compradores, inversores habilitados, entidades financieras, SGR y aseguradoras.

Agro Fields actuaría como nexo tecnológico e informativo.

La billetera virtual y la eventual tokenización son posibilidades futuras, no prioridades de la etapa actual.

---

## 7. Marketplace Campos y Agroalimentario

Es la ventana comercial del ecosistema.

Permite conectar oferta y demanda sin exponer indiscriminadamente los expedientes privados.

### Marketplace de campos

- Campos en venta.
- Campos en alquiler.
- Oportunidades productivas.
- Información territorial.
- Características y antecedentes autorizados.
- Documentación comercial disponible.
- Contacto entre interesados.

### Marketplace agroalimentario

- Granos.
- Hacienda.
- Leche.
- Carnes.
- Frutas.
- Hortalizas.
- Productos regionales.
- Insumos y servicios.
- Producción agroindustrial.

### Principio fundamental

El Marketplace presenta una oportunidad comercial; el Expediente Digital conserva la identidad y la historia del activo.

La publicación es temporal y configurable. El activo y su expediente permanecen.

---

## 8. Gestión Inteligente de Logística, Transporte y Distribución Agropecuaria

Capacidad transversal destinada a optimizar el traslado y distribución de la producción agropecuaria y agroindustrial.

Funciones:

- Planificación de recorridos.
- Comparación de rutas, distancias y tiempos.
- Cálculo de costos logísticos.
- Consolidación de cargas.
- Identificación de capacidad ociosa.
- Detección de retornos vacíos.
- Transporte de productos refrigerados.
- Cadena de frío.
- Conservación.
- Trazabilidad desde origen hasta destino.
- Comparación de alternativas multimodales.
- Inteligencia de costos por corredor y región.

Debe contemplar circuitos específicos por actividad: lechería, ganadería, agricultura, vitivinicultura, fruticultura, apicultura, feedlot y demás producciones.

Se vincula con cooperativas, transportistas, industrias, productores y comercializadores.

Agro Fields será plataforma de información, coordinación y análisis, no una empresa transportista.

### 8.1. Principio de arquitectura: el transporte es un servicio transversal

El transporte, la logística y la trazabilidad de movimientos no son un módulo de una actividad. Ganadería, agricultura, apicultura, piscicultura y demás actividades comparten un mismo núcleo, cada una con sus propios datos, controles y requisitos. Así se evitan sistemas separados.

- Núcleo común: movimiento, estados, evidencias, incidencias y control de coherencia (declarado / cargado / recibido).
- Ficha por actividad: identificación según el tipo (caravanas, lotes, colmenas, etc.), unidades, condiciones y controles propios.
- Reglas por jurisdicción guardadas aparte (el SNIG de Uruguay es un ejemplo, no un modelo para copiar).
- Una sola colección de movimientos con un campo "actividad".
- Expediente y evidencias de cada movimiento.
- Funcionamiento sin señal (offline-first), resuelto de la forma más eficiente.

Incluye transporte de hacienda y agrícola, inteligencia logística, costos de referencia (sin fijar tarifas), seguimiento, exportación y traslados en emergencias.

### 8.2. Etapas

- 🔴 Traslado simple, construido sobre el núcleo común: origen, destino, cantidad, categoría, transportista, guía y fecha.
- 🟡 Fuente del dato y vínculo con lotes y animales del núcleo productivo.
- 🟢 Seguimiento GPS, costos por corredor, exportación y conexión con organismos (SENASA, Aduana y otros) solo por vías oficiales.

---

## 9. Territorio Inteligente y Red de Información, Alertas y Prevención Territorial

Capacidad transversal destinada a conectar a quienes viven y trabajan en el territorio rural.

Toma como referencia conceptual experiencias colaborativas como Red Rural de Brandsen, sin reproducir necesariamente su implementación.

### Funciones

- Reportes comunitarios.
- Estado de caminos rurales.
- Cortes y anegamientos.
- Pozos y deterioro vial.
- Animales sueltos.
- Incendios.
- Obstáculos.
- Accidentes.
- Situaciones de inseguridad rural.
- Alertas preventivas.
- Información climática.
- Estadísticas territoriales.
- Identificación de zonas problemáticas.
- Coordinación institucional.

### Funcionamiento colaborativo

Productores, vecinos, transportistas y técnicos podrán reportar situaciones mediante mecanismos sencillos.

Los reportes tendrán estados diferenciados:

- Reportado.
- Pendiente de verificación.
- Confirmado.
- Resuelto.
- Descartado.

### Conectividad rural

Debe contemplar:

- Funcionamiento offline.
- Almacenamiento local.
- Sincronización posterior.
- Comunicación alternativa.
- Posible utilización de SMS cuando la infraestructura y los servicios disponibles lo permitan.

### Seguridad y privacidad

La identidad del informante no debe exponerse a quienes reciben una alerta pública.

Deben existir controles administrativos, trazabilidad, permisos y mecanismos para evitar reportes maliciosos.

La plataforma complementa, pero no sustituye, a los servicios oficiales de emergencia y seguridad.

### 9.1. Identificación territorial y recursos

- Identificación territorial: ubicación del campo en el mapa.
- Recursos naturales: agua, suelo, monte, riego o secano.
- Información satelital y climática.
- Infraestructura, accesos y servicios.
- Inteligencia territorial.

Drones, agricultura de precisión y teledetección (también satélites, sensores, estaciones, maquinaria y servicios de terceros) se contemplan como fuentes de datos. Agro Fields no vende drones: registra de dónde viene cada dato.

Mapa mundial de campos: nunca muestra datos privados sin permiso del titular.

### 9.2. Integración de sistemas productivos y complementariedad territorial

Capacidad transversal para combinar sistemas productivos de una zona (por ejemplo, campos con riego y campos de secano, o chacras reconvertidas a pasturas). Caso de referencia: El Monterizo, 25 de Mayo, La Pampa (más de 70 productores). No se refiere al desmonte de monte nativo.

- Los datos del campo (riego/secano, agua, suelo, infraestructura, accesos, potencial forrajero) se guardan en Territorio.
- La integración solo consulta esos datos con permiso, sin duplicarlos.
- Lo que el dueño decide ofrecer se marca de forma voluntaria: superficie disponible, "disponible para producir forraje" o "disponible para recibir hacienda", igual que "disponible para recibir" en emergencias.
- El forraje sembrado o en stock se registra en Gestión Productiva.

Estado: referencia conceptual pendiente de análisis, sin código.

### 9.3. Etapas

- 🔴 Ubicación del campo en el mapa.
- 🟡 Capas de información, alertas por ubicación y campo "fuente del dato" (en Monitoreo y Trabajos).
- 🟢 Imágenes satelitales, índices, sensores, integración territorial completa y conexión con organismos.

---

## 10. Sistema Inteligente de Alertas, Emergencias y Recuperación Agropecuaria

Capacidad transversal destinada a prevenir, detectar, evaluar y gestionar emergencias que afectan a productores, establecimientos, activos y cadenas productivas.

### 10.1. Emergencias climáticas

- Inundaciones.
- Sequías.
- Granizo.
- Heladas.
- Tormentas.
- Vientos severos.
- Incendios.
- Olas de calor.
- Eventos climáticos extremos.

### 10.2. Emergencias sanitarias y productivas

- Enfermedades.
- Plagas.
- Fusariosis.
- Contaminación.
- Deterioro de calidad.
- Problemas sanitarios de animales.
- Otras amenazas productivas.

### 10.3. Ciclo de gestión de emergencias

1. Detección de amenazas.
2. Identificación de establecimientos expuestos.
3. Alertas preventivas.
4. Relevamiento de daños.
5. Evaluación técnica.
6. Coordinación de asistencia.
7. Recuperación productiva.
8. Registro histórico y aprendizaje.

### 10.4. Evaluación de daños

El sistema debe registrar:

- Superficie afectada.
- Cultivo o actividad.
- Estado fenológico.
- Intensidad del daño.
- Evidencias fotográficas.
- Informes profesionales.
- Rendimiento esperado.
- Pérdidas estimadas.
- Intervenciones realizadas.
- Resultados de recuperación.

Debe distinguir entre declaraciones, estimaciones y pericias verificadas.

### 10.5. Escalas de emergencia

- Predial.
- Zonal.
- Regional.

Debe permitir coordinar respuestas sin perder la individualización de cada establecimiento y productor.

### 10.6. Expediente de emergencia y campos disponibles

Principio: "de la alerta a la acción". Cada emergencia queda registrada en el expediente del activo afectado, con su historia.

- Prevención, alertas, diagnóstico, coordinación y recursos.
- Marca voluntaria "disponible para recibir": campos que pueden recibir animales o producción ante una catástrofe (por ejemplo, una inundación).
- Trazabilidad del traslado usando el núcleo común de transporte (sección 8).

### 10.7. Etapas

- 🔴 Registrar la emergencia en el expediente y la marca "disponible para recibir".
- 🟡 Alertas por ubicación.
- 🟢 Coordinación zonal y regional, y conexión con organismos.

Territorio, Emergencias y Transporte comparten los mismos datos, sin duplicarlos.

---

## 11. Articulación Institucional, Ciencia e Innovación Agropecuaria

Capacidad transversal destinada a conectar el conocimiento, la experiencia profesional y las instituciones que intervienen en el desarrollo agropecuario.

Incluye expresamente:

- Ingenieros agrónomos.
- Veterinarios.
- Especialistas forestales.
- Técnicos de campo.
- Asesores independientes.
- Profesionales especializados.
- Productores.
- Cooperativas.
- Asociaciones rurales.
- CREA y otras redes.
- Universidades.
- Centros de investigación.
- INTA y organismos públicos.
- Instituciones privadas.

### Funcionalidades

- Directorio de profesionales e instituciones.
- Perfiles y competencias.
- Especialidades.
- Ubicación y zonas de trabajo.
- Servicios.
- Proyectos colaborativos.
- Intercambio de conocimientos.
- Asistencia técnica.
- Investigación aplicada.
- Innovación.
- Capacitación.
- Validaciones e informes profesionales.

La plataforma debe diferenciar las competencias declaradas de las credenciales verificadas y respetar las atribuciones profesionales de cada especialidad.

Agro Fields facilita, no reemplaza, a profesionales e instituciones. El título profesional se considera "declarado" hasta que se verifique. Caso de origen: comunicado de CREA Paraguay.

### 11.1. Etapas

- 🔴 Invitar al profesional al campo (se apoya en los permisos ya construidos) y registrar sus intervenciones con evidencia.
- 🟢 Directorio y perfiles de profesionales e instituciones.

---

## 12. Control de Coherencia, Identificación y Validación de Movimientos Ganaderos

Capacidad transversal de control de integridad y trazabilidad de los movimientos ganaderos.

Se toma como referencia conceptual el sistema de controles de identificación individual y validación de movimientos implementado en Uruguay.

Debe contemplar:

- Identificación individual.
- Caravanas y dispositivos de identificación.
- Registro de animales previstos para traslado.
- Comparación con animales efectivamente leídos.
- Detección de diferencias.
- Validación de origen y destino.
- Coherencia documental.
- Controles de integridad.
- Reglas jurisdiccionales configurables.
- Plazos y restricciones.
- Registro de excepciones.
- Evidencias de lectura.
- Historial de movimientos.

Debe ser adaptable a las normativas de cada jurisdicción y permitir interoperabilidad con los organismos competentes.

No debe confundirse con una certificación oficial ni reemplazar las facultades de control del Estado.

### 12.1. Caso de referencia: SNIG Uruguay

Vigente desde el 10/11/2026 (fuente oficial: MGAP, hojas informativas H202 y H203). Puntos de referencia: la cantidad declarada en el preembarque debe coincidir con las caravanas leídas; si no coinciden, no se genera la guía (también en guías manuales); las correcciones tienen plazos y límites, y pasados esos límites corresponde una guía nueva; hay plazos para identificar a los animales antes del primer movimiento o cambio de dueño.

Estas reglas son uruguayas: no se copian a Argentina ni a Paraguay. Deben contrastarse con la normativa oficial antes de usarlas.

### 12.2. Cinco funciones

- Control de identidad.
- Control de cantidades: declarados, previstos y leídos.
- Control documental: preembarque, guía y movimiento.
- Motor de reglas por jurisdicción: país, organismo, normativa, vigencia, identificación exigida, plazos, límites, correcciones, excepciones y evidencias.
- Historial de correcciones.

Agro Fields valida y advierte; la autorización oficial es del organismo competente. Se apoya en el núcleo común de transporte (sección 8) y puede alimentarse con lecturas de caravanas importadas de equipos de campo (sección 17.1).

Estado: concepto ampliado. Pendiente: diseño y adaptación a Argentina (SENASA) y Paraguay (SENACSA). Sin número de GAP ni código hasta cotejar con la Matriz.

---

## 13. Certificaciones, Bienestar Animal y Trazabilidad Comercial

Capacidad transversal para toda la producción (no solo feedlot). Agro Fields no certifica: guarda, ordena y avisa sobre las certificaciones del productor.

Casos de referencia: comunicado de Trade Food (sin incluir su oferta comercial) y el feedlot Los Aromos de ACA (Cafferata, Santa Fe), primer feedlot argentino con certificación de bienestar animal Welfair.

- La certificación es un documento con entidad, alcance, vigencia, a qué animales o producción aplica y aviso de vencimiento.
- Los requisitos se configuran por norma; no se fijan los principios de una certificadora como campos del sistema.

### 13.1. Etapas

- 🔴 Nada nuevo: "certificación" como tipo dentro de Documentos del campo, con su alcance.
- 🟡 Vincular el certificado a lotes o animales del núcleo productivo.
- 🟢 Requisitos por norma, registro de auditorías y conexión con certificadoras (Welfair, VISEC y otras).

---

## 14. Inteligencia de Mercados Agropecuarios

Fuente de datos externa (precios de referencia) que se cruza con el inventario, los costos, las ventas y el resultado del productor. Sirve al pequeño productor, a la cooperativa y a la agroindustria.

- El precio de un mercado internacional (por ejemplo, Chicago) no es el precio que recibe el productor: influyen el tipo de cambio, las retenciones, los costos y la comercialización.
- Todo precio de referencia lleva fuente, fecha y vigencia.
- Agro Fields informa y explica; no fija precios, no tasa y no recomienda vender ni comprar (va en los términos de uso).
- Atención a las licencias pagas de cotizaciones en tiempo real.

### 14.1. Etapas

- 🔴 Nada nuevo: Ventas ya guarda el precio obtenido.
- 🟡 Campo "precio de referencia" cargado a mano, con fuente y fecha.
- 🟢 Cotizaciones automáticas, escenarios y relación costo/precio.

Estado: sin módulo, arquitectura ni código aprobados.

---

## 15. Inteligencia Regulatoria y Acceso a Mercados Agropecuarios

Agro Fields no decide por el productor qué mercado o plataforma usar. Conoce e interpreta regulaciones nacionales e internacionales (no solo Europa: también Brasil, Chile, Estados Unidos, China, países árabes y otros), identifica oportunidades y evalúa brechas.

- Semáforo de brechas por requisito: cumple, pendiente o falta evidencia.
- Cada requisito con fuente oficial, fecha y vigencia.
- Conecta actores: exportadores, frigoríficos, certificadoras, organismos, profesionales y compradores.
- Interoperabilidad autorizada con plataformas como VISEC, sin depender de ninguna en exclusiva.
- Aviso de cambios regulatorios.

No es autoridad, certificadora ni intermediario obligatorio. Informar no es certificar y conectar no es intermediar (va en los términos de uso). Caso de referencia adicional: la cadena caprina exportadora del Chaco.

### 15.1. Etapas

- 🔴 Nada nuevo: Documentos del campo con "certificación" como tipo.
- 🟡 Requisitos por mercado cargados a mano y semáforo de brechas.
- 🟢 Avisos automáticos de cambios, directorio y conexión con VISEC y otras plataformas por vías oficiales.

---

## 16. Gestión documental, evidencias y trazabilidad

Capacidad transversal presente en todo el ecosistema.

Cada información relevante debe poder relacionarse con:

- Un activo.
- Un establecimiento.
- Una operación.
- Un responsable.
- Una fecha.
- Una fuente.
- Un documento.
- Una evidencia.
- Un estado de verificación.

Debe contemplar:

- Documentos digitales.
- Fotografías.
- Videos.
- Informes.
- Certificados.
- Contratos.
- Comprobantes.
- Vigencias y vencimientos.
- Alertas.
- Historial.
- Auditoría.

La información debe poder consultarse y exportarse según permisos.

El historial funcional del activo debe diferenciarse de la auditoría técnica del sistema.

---

## 17. Integraciones e interoperabilidad

Agro Fields deberá poder conectarse progresivamente con:

- Organismos públicos.
- Registros agropecuarios.
- Sistemas sanitarios.
- Sistemas de identificación animal.
- Instituciones financieras.
- Aseguradoras.
- SGR.
- Cooperativas.
- Universidades.
- Centros de investigación.
- Aplicaciones productivas externas.
- Servicios meteorológicos.
- Sistemas cartográficos.
- Plataformas logísticas.
- Mercados y operadores comerciales.

Las integraciones dependerán de la disponibilidad de interfaces, acuerdos institucionales, permisos y normativa aplicable.

VISEC se contempla como posible interoperabilidad, no como certificación propia de Agro Fields.

### 17.1. Importación de datos de equipos de campo

Importar datos de balanzas y lectores de caravanas (por ejemplo, Tru-Test). Sirve para la gestión ganadera y para trabajar sin señal: los datos se toman en el campo y se suben después. Se relaciona con la lectura de caravanas del control de movimientos (sección 12).

Otros sistemas administrativos (por ejemplo, Finnegans o Procreare): sin conexión por ahora, solo "preparado para conectarse".

---

## 18. Inteligencia de datos y asistencia a decisiones

El sistema debe transformar registros y evidencias en información útil.

Capacidades:

- Indicadores productivos.
- Indicadores económicos.
- Comparación de campañas.
- Análisis de costos.
- Alertas.
- Detección de inconsistencias.
- Tendencias territoriales.
- Análisis de riesgos.
- Proyecciones.
- Apoyo a decisiones.

La inteligencia artificial podrá incorporarse progresivamente como herramienta de asistencia, nunca como sustituto automático de las verificaciones profesionales, decisiones del productor o controles oficiales.

---

## 19. Modelo de confianza y protección de la información

La confianza no debe depender únicamente de que una persona o empresa tenga un perfil registrado.

Debe construirse sobre información respaldada y verificable.

El sistema deberá distinguir:

- Identidad declarada.
- Identidad verificada.
- Documentación aportada.
- Documentación validada.
- Información externa.
- Información pendiente.
- Historial de operaciones.
- Autorizaciones.
- Evidencias.
- Responsabilidades.

La información privada no se publica automáticamente.

Cada usuario conserva control sobre sus datos y sus autorizaciones.

---

## 20. Modelo de usuarios y participación

Agro Fields deberá adaptarse a diferentes actores:

- Productor individual.
- Empresa agropecuaria.
- Administrador.
- Responsable de establecimiento.
- Técnico.
- Profesional independiente.
- Cooperativa.
- Transportista.
- Industria.
- Comprador.
- Inversor habilitado.
- Institución pública.
- Institución privada.
- Investigador.
- Organismo de control.

Cada participante accederá exclusivamente a los módulos, activos e información que le correspondan según sus permisos.

---

## 21. Experiencia de usuario

El sistema debe ser simple, claro y práctico.

Principios:

- Pantallas ordenadas.
- Navegación intuitiva.
- Pocos pasos.
- Información jerarquizada.
- Formularios adecuados a cada actividad.
- Accesibilidad.
- Botones claros.
- Uso desde dispositivos móviles.
- Alertas comprensibles.
- Funcionamiento con conectividad limitada.

La identidad visual deberá transmitir tecnología, confianza, naturaleza y modernidad, evitando una interfaz sobrecargada.

La experiencia debe ser consistente entre aplicaciones, módulos y usuarios.

---

## 22. Modelo de evolución y desarrollo

Agro Fields V8 debe evolucionar por etapas, sin comprometer la integridad del núcleo.

Orden funcional de referencia:

1. Identidad y Expediente Digital Permanente.
2. Establecimientos y Territorio.
3. Gestión Productiva.
4. Recursos, Inventarios y Trabajos.
5. Economía y Costos.
6. Documentación, Evidencias y Trazabilidad.
7. Marketplace y Comercialización.
8. Capacidades transversales e integraciones.

Las capacidades transversales deben diseñarse en relación con las necesidades reales de cada actividad, evitando módulos aislados o duplicaciones.

---

## 23. Visión final

Agro Fields V8 busca construir un ecosistema agropecuario donde cada activo tenga identidad, cada operación tenga trazabilidad, cada productor pueda controlar su información y cada actor encuentre oportunidades para colaborar.

Un sistema que no obligue a todos a trabajar de la misma manera, sino que conecte distintas realidades productivas mediante información confiable, servicios modulares y herramientas inteligentes.

Un ecosistema que permita:

- Producir mejor.
- Administrar mejor.
- Conocer los costos reales.
- Proteger las operaciones.
- Reducir riesgos.
- Mejorar la logística.
- Prevenir emergencias.
- Compartir conocimiento.
- Simplificar trámites.
- Conectar mercados.
- Fortalecer la confianza.

**Agro Fields V8: un ecosistema para conectar el campo, proteger su trabajo y potenciar su desarrollo.**

---

### Criterio de implementación

Este documento constituye la visión conceptual y funcional integral. No representa una certificación de funcionalidades implementadas.

Toda capacidad deberá pasar por análisis funcional, diseño arquitectónico, evaluación de brechas, desarrollo, pruebas y evidencias antes de considerarse implementada y validada.

**Principio rector:** primero comprender y diseñar correctamente; después desarrollar con cambios mínimos, verificables y trazables.

---

## 24. Estado de las incorporaciones

### Incorporaciones del 12/11/2026 (concepto, sin código nuevo)

- Independencia de plataformas comerciales y de certificación (sección 1).
- Transporte como servicio transversal con núcleo común (sección 8).
- Identificación territorial, teledetección e integración de sistemas productivos (sección 9).
- Expediente de emergencia y marca "disponible para recibir" (sección 10).
- Etapas de la articulación institucional (sección 11).
- Ampliación del control de movimientos ganaderos con el caso SNIG (sección 12).
- Certificaciones y bienestar animal (sección 13).
- Inteligencia de mercados (sección 14).
- Inteligencia regulatoria y acceso a mercados (sección 15).
- Importación de datos de equipos de campo (sección 17.1).

Todo lo marcado 🔴 debe pasar al cuadro de lanzamiento, a la Matriz y al Roadmap antes de programarse.
