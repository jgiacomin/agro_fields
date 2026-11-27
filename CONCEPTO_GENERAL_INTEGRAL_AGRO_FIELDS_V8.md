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

No es autoridad, certificadora ni intermediario obligatorio. Informar no es certificar y conectar no es intermediar (va en los términos de uso). Casos de referencia adicionales: la cadena caprina exportadora del Chaco y la trazabilidad de soja con blockchain de Bunge y CP hacia Vietnam (sección 25.7).

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

### Incorporaciones del 13/11/2026

- Caso de referencia Pretto Agronegocios con cuadro de lo que existe y lo que falta (sección 25.1). Matriz AF-102 a AF-108.

### Incorporaciones del 18/11/2026

- Caso de referencia "Nueva era de la ganadería" (antecedente: declaraciones de Víctor Tonelli) (sección 25.2). Matriz AF-112 y AF-113.
- Avicultura y piscicultura: estado del núcleo productivo según la auditoría del código del 18/11/2026 (sección 25.3). Matriz AF-110.
- Caso de referencia: tormentas en el sur de Córdoba (sección 25.4). Matriz AF-111, AF-116 y AF-117.
- Caso de referencia: Inteligencia Hídrica Territorial, excesos hídricos en el sur de Santa Fe (sección 25.5). Matriz AF-114 y AF-115.

Los cuatro casos se cargaron a partir de los antecedentes registrados en las jornadas del 16 y 17/11/2026, no de los documentos originales completos. Toda cifra se confirma con su fuente antes de usarla.

- Caso de referencia: trazabilidad de soja con blockchain de Bunge y CP, ampliada a Vietnam con harina de soja argentina (sección 25.7). Matriz AF-118.

### Incorporaciones del 20/11/2026

- Caso de referencia: polémica VISEC Carne (sección 25.8). Sin AF nuevo; se vincula a AF-118 y AF-104.
- Caso de referencia: carne argentina terminada a grano en China y Asia (sección 25.9). Matriz AF-119; actualiza AF-103 y AF-118.
- Caso de referencia: compra de campos por extranjeros (sección 25.10). Matriz AF-120.
- Caso de referencia: estafas ganaderas (sección 25.11). Matriz AF-121 (GAP-CLI-01).
- Caso de referencia: Drively.me (sección 25.12). Matriz AF-122 a AF-125.

Los cinco casos se cargaron a partir de los antecedentes registrados en las jornadas del 18 y 19/11/2026, no de los documentos originales completos. Toda cifra y toda norma se confirman con su fuente antes de usarlas.

### Incorporaciones del 24/11/2026

- Caso de referencia: Uruguay, trazabilidad ganadera y acceso al mercado europeo (sección 25.13). Sin AF nuevo; refuerza el Expediente, AF-104 y AF-118.
- Caso de referencia: curso de invernada y feedlot (sección 25.14). Matriz AF-126 (carga animal) y AF-127 (resultado del rodeo).
- Caso de referencia: limón caviar en Paraguay (sección 25.15). Matriz AF-134 (cultivo perenne / frutales).
- AF nuevos aprobados entre el 21 y el 23/11/2026, sin caso propio: AF-128 (superficie en el mapa vs. escritura), AF-129 (piscicultura chica), AF-130 (genética), AF-131 (Emergencia ↔ Traslado), AF-132 (granos guardados) y AF-133 ("¿A dónde va la plata de mi venta?").

- Caso de referencia: maíz amarillento por fósforo bloqueado (sección 25.16). Matriz AF-136 (nutrientes en el suelo), AF-137 (síntomas en el monitoreo) y AF-138 (fertilizante en la siembra).
- Caso de referencia: El Niño muy fuerte 2026-2027 (sección 25.17). Matriz AF-139 (plan de emergencia del campo) y ampliación de AF-111 (INUMET, Uruguay).

Toda cifra y toda norma se confirman con su fuente antes de usarlas.

### Incorporaciones del 25/11/2026

- Caso de referencia: maíz barato y costo de alimentación ganadera (sección 25.18). Matriz AF-140 (precio de referencia manual); amplía AF-127 y AF-132.
- Caso de referencia: operación a término incumplida (sección 25.19). Matriz AF-141 (operación a término, dentro de GAP-OPER-01 y GAP-CLI-01).
- Caso de referencia: cooperativas vitivinícolas de San Martín, Mendoza (sección 25.20). Matriz AF-142 (cooperativas: entrega de la cosecha); amplía AF-134 y AF-038.
- Caso de referencia: cosecha de girasol en Corzuela, Chaco (sección 25.21). Matriz AF-143 (cosecha pausada por clima y promedio de referencia).
- Caso de referencia: frutihortícola de Presidencia Roque Sáenz Peña, Chaco (sección 25.22). Matriz AF-144 (horticultura de ciclos cortos); amplía AF-134.

Los cinco casos se cargaron a partir de los antecedentes registrados en la jornada del 24/11/2026, no de los documentos originales completos. Toda cifra y toda norma se confirman con su fuente antes de usarlas.

### Incorporaciones del 26/11/2026

- Caso de referencia: MiCampoDigital, competencia en gestión ganadera (sección 25.25). Matriz AF-147 (importar planilla Excel), AF-148 (archivo para SENASA/SIGSA), AF-149 (lector de caravanas y balanza), AF-150 (preñez y recordatorios sanitarios), AF-151 (potreros dibujados y verde por cuadro) y AF-152 (calculadoras gratis); el asistente con IA se suma a AF-082.
- Principio inspirador: "Verificar antes de arrancar", a partir de la parábola del trigo y la cizaña (sección 25.26). Matriz AF-153 (moderación del Mercado: marcar, apartar, decidir con criterio, mirar el fruto y cuidar el trigo); amplía AF-038 y AF-145.
- Principio inspirador: Virgilio, Bucólicas y Geórgicas, con el lema *"labor omnia vicit improbus"* para la página web (sección 25.27). Sin AF nuevo.

### Incorporaciones del 27/11/2026

- Caso de referencia: miArgentina y GDEBA como modelos de sencillez (sección 25.29). Matriz AF-154 (Inicio con botones y "Mis campos" en lista corta, validado), AF-155 (entrar con huella, 🟡 diciembre) y AF-156 (página web pública, demo aprobada).
- Decisión del Mercado: publicar directo con un solo "Guardar" para quien el admin habilitó una vez, con "Bajó de precio" (Matriz AF-157, validado: 300 pruebas de reglas y prueba en la app). Responsable del aviso: el primer broker o inmobiliaria que carga el campo, hasta que el dueño toma posesión; si el dueño nunca se suma, sigue el primer broker. Cada campo aparece una sola vez en el Mercado, con un solo precio. Amplía AF-038.
- Campanita de cambios para el dueño y el admin (Matriz AF-158) y aviso de campo repetido (Matriz AF-159, 🟡 enero).
- Campanita del Mercado para quien busca (compradores, inmobiliarias, inversores, arrendatarios): novedades de venta, alquiler y arrendamiento, en etapas (Matriz AF-161).
- Caso de referencia: pronóstico agroclimático de la Bolsa de Cereales de Buenos Aires para el 26/11 al 2/12/2026 (sección 25.28). Ligado a AF-117, AF-092 y AF-143. Revisión del código: "helada" ya existía; se sumó "Calor extremo" a las emergencias (27/11/2026) y el registro de lluvia queda como Matriz AF-160 (🟡 enero).

---

## 25. Casos de referencia estratégicos

### 25.1. Pretto Agronegocios (5.º Congreso Federal Ganadero de ROSGAN, noviembre de 2026)

**Fuente:** panel "De productor a empresario" (nota de Mac Lean Consultores / Patricia Martino). **Estado:** referencia conceptual analizada el 13/11/2026; no es especificación técnica.

**Síntesis:** empresa familiar de Sacanta (Córdoba) que, tras la muerte del fundador en 2012, atravesó inundaciones y deudas, se apoyó en CREA (desde 2019) y pasó de 2 a más de 25 colaboradores. Integra agricultura, cría, recría, feedlot, desposte y venta de cortes con marca propia; red de más de 30 empresas aliadas; unas 3.000 t de carne comercializadas y meta de 100.000 cabezas; más de 21.000 caravanas trazadas y casi 700 búfalos identificados; plataforma digital para vender medias reses a más de 100 carniceros; 300 visitas y 15 ganaderos formados en un año. Frase: «La ganadería sola puede ir rápido, pero aliada puede llegar lejos».

**Principios que confirma** (ya están en este Concepto): conectar sin quitar autonomía; compartir información solo con autorización (activo, ámbito, dato y vigencia); profesionalizar sin complicar; acompañar al pequeño productor; no imponer un modelo único de empresa; el sistema no fija precios.

**Qué tiene hoy Agro Fields y qué falta (cotejado con el código el 13/11/2026):**

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Mortandad | Bajas con motivo "muerte" por rodeo | Calcular el % de mortandad del rodeo | 🔴 con pesajes |
| Ganancia de peso | Tipo de evento "pesaje" preparado | Pantalla de pesajes y ganancia diaria de peso | 🔴 con pesajes |
| Conversión alimenticia | Tipo de evento "alimentación" preparado; stock de alimento | Registrar alimentación y cruzarla con pesajes | 🟡 |
| Identificación individual (caravanas) | Modo de identificación "por animal" preparado en el rodeo | Ficha por animal, caravana, historia individual (enlaza con el caso SNIG, sección 12) | 🟡 |
| Del maíz a la carne | Cosecha, traslados, stock y economía | Unir cosecha propia como alimento del feedlot (sin duplicar datos) | 🟡 |
| Hotelería y capitalización entre aliados | Tenencia "capitalización" y "hotelería"; origen de alta | Vínculo con el dueño de los animales y lo que se le informa | 🟢 |
| Costos y resultado | Gastos por categoría y actividad (GAP-ECO-01) | Ingresos por ventas, resultado y planificado contra real | 🟡 / 🟢 |
| Historia y legado del establecimiento | Historial del campo | Registrar hitos y decisiones relevantes a mano | 🟡 |
| Equipo, delegación y capacitación | Encargado y profesional invitados con permisos | Roles del equipo, responsabilidades y capacitación (AF-080) | 🟢 |
| Compartir números con el equipo | Autorización "ver" por ámbito (economía, producción) | — (se cubre con permisos) | ✅ |
| Red de aliados | Autorizaciones por campo | Red Agropecuaria: aliados, indicadores compartidos con permiso | 🟢 |
| Venta a carniceros (medias reses, cortes) | Marketplace de campos y operaciones protegidas | Comercialización B2B de productos | 🟢 |
| Trazabilidad de la carne hasta el consumidor | Eventos, movimientos y documentos | Faena, desposte, rendimiento de carne (conexión con frigoríficos) | 🟢 |

**Criterio:** no se crea un módulo por caso. Cada punto se apoya en lo que ya existe (núcleo productivo, movimientos, stock, economía, autorizaciones). Lo 🔴 entra con el punto 6 del plan (Suelo y pesajes), sin módulo nuevo.

### 25.2. "Nueva era de la ganadería" (antecedente: declaraciones de Víctor Tonelli, El Rural, 16/11/2026)

**Estado:** antecedente estratégico registrado el 16/11/2026 a partir del análisis del usuario; no es el documento original ni una especificación técnica. Las cifras son las atribuidas a Tonelli y se confirman con la fuente antes de usarlas.

**Síntesis del antecedente:** animales terminados de 550 a 600 kg; transformación genética y nutricional; más recría y permanencia en feedlot; ocupación de corrales del 72 %; según Tonelli, potencial de aumentar un 60 % la producción de carne.

**Principio:** los indicadores se calculan con los datos que el productor ya carga (pesajes, altas, bajas, movimientos, capacidad de las unidades). No se escriben a mano ni se crea un módulo nuevo.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Peso de terminación (550–600 kg) | Pesaje con peso promedio y ganancia diaria (GAP-PESO-01) | — | ✅ |
| Ocupación de corrales | Unidad "corral" con capacidad; existencias calculadas por eventos | Calcular existencias ÷ capacidad de cada corral | 🟡 |
| Recría y permanencia en feedlot | Etapas del rodeo (recría pastoril, de corral, mixta, feedlot); altas, bajas y movimientos con fecha | Calcular días de permanencia por lote | 🟡 |
| Nutrición y conversión | Evento "alimentación" preparado; stock de alimento | Registrar alimentación y cruzarla con pesajes | 🟡 |
| Genética | — | Registro genético por lote o animal (enlaza con identificación individual) | 🟢 |
| Producción de carne del campo | Pesajes, ventas y bajas | Kilos producidos por hectárea y por año | 🟢 |

### 25.3. Avicultura y piscicultura

**Estado:** el 16/11/2026 el usuario señaló que todavía falta todo lo avícola y piscícola, y que no se sabe si habrá productores de esas actividades entre los primeros Fundadores (cualquiera puede registrarse con un mail). El 18/11/2026 se auditó el código del núcleo productivo (GAP-PROD-01).

**Qué ya sirve (sin cambiar reglas de producción):**

- Unidades productivas: el modelo ya tiene "galpón" y "estanque".
- Grupo productivo: la actividad es texto libre; no está atado a la ganadería bovina.
- Categorías: texto libre; cada productor puede usar las suyas.
- Eventos: alta, baja (mortandad), pesaje (acepta decimales), sanidad y movimiento sirven igual para aves y peces.
- Traslados: la colección única de movimientos ya acepta "piscicultura".

**Qué falta para una versión mínima:**

- Elegir la actividad al crear el grupo (hoy la pantalla guarda siempre "ganadería").
- Ofrecer "estanque" en la lista de unidades.
- Categorías sugeridas por especie (aves: pollitos BB, parrilleros, ponedoras, reproductores; peces: alevines, juveniles, engorde, reproductores).
- Textos neutros ("lote", "animales") en lugar de "rodeo" y "cabezas" cuando no es ganadería.
- Sumar "avicultura" a los traslados y, si se decide, "avicultura" y "piscicultura" a las actividades de gastos (hoy se puede usar "general").

**Para después:** conversión alimenticia, biomasa y densidad del estanque, postura de huevos y calidad de agua como indicadores propios (🟡/🟢). Antes de programarlos se estudia el funcionamiento real de cada actividad (sección 4.7).

**Decisión (18/11/2026):** versión mínima para enero (GAP-PROD-02, Matriz AF-110).

### 25.4. Tormentas en el sur de Córdoba (noviembre de 2026)

**Estado:** caso de referencia registrado el 16/11/2026; no es especificación técnica.

**Síntesis:** tormentas fuertes con granizo, lluvias intensas y viento en Río Cuarto, General Cabrera, San Basilio y Adelia María; alerta naranja del Servicio Meteorológico Nacional para Córdoba y sectores de Catamarca, La Rioja, San Luis y Santa Fe. El usuario señaló que Emergencias puede potenciar mucho el sistema, más con El Niño.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Registrar lo que pasó en cada campo | Registrar emergencia en el expediente (AF-092) | — | ✅ |
| Campos que pueden recibir hacienda | Marca voluntaria "disponible para recibir" (AF-092) | — | ✅ |
| Memoria del territorio | Historia del territorio en la ficha del campo (AF-109) | — | ✅ |
| Saber qué campos están en la zona afectada | Ubicación del campo en el mapa (AF-090) | Cruzar la ubicación con la zona de la alerta | 🟡 |
| Evaluación de daños | Afectaciones dentro del evento de emergencia | Pantalla guiada de daños (superficie, cultivo, animales, infraestructura) | 🟡 |
| Llegar a la alerta oficial | — | Botón "Ver alertas oficiales" según el país del campo (AF-111) | 🔴 |
| Alertas automáticas | — | Conexión con alertas del SMN por vías oficiales y avisos automáticos (AF-117) | 🟢 |

**Criterio:** Agro Fields informa y registra; la alerta oficial es del organismo. No se generan alertas propias como si fueran oficiales.

### 25.5. Inteligencia Hídrica Territorial (antecedente: excesos hídricos en el sur de Santa Fe, 17/11/2026)

**Estado:** antecedente estratégico registrado el 17/11/2026; no es el documento original ni una especificación técnica.

**Síntesis del antecedente:** excesos hídricos en el sur de Santa Fe; demoras en siembra y cosecha; anegamientos y planchado de suelos; caminos rurales intransitables; dificultades para trasladar maquinaria. Temas que abre: agua, napas, caminos, cuencas, transitabilidad y logística.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Registrar el anegamiento | Emergencia en el expediente (AF-092); monitoreo con objetivo "agua" (GAP-MON-01) | — | ✅ |
| Obras que cambian el agua (canales, drenajes, caminos) | Historia del territorio con tipos canal, drenaje y camino (AF-109) | — | ✅ |
| Planchado y estado del suelo | Pantalla de suelo (GAP-SUELO-01) | Registrar el planchado con fecha y evidencia | 🟡 |
| Caminos y accesos intransitables | — | Estado de acceso del campo (transitable / con dificultad / intransitable) con fecha y fuente | 🟡 |
| Demoras en siembra y cosecha | Siembra y cosecha con fecha | Comparar fecha planificada contra real | 🟡 |
| Napas | — | Dato de profundidad de napa con fuente y fecha | 🟡 |
| Cuencas, satélite y transitabilidad regional | — | Capas territoriales y fuentes oficiales | 🟢 |
| Traslado de maquinaria y logística | Núcleo común de movimientos (sección 8) | Avisos de acceso para transporte | 🟢 |

**Criterio:** se conecta con Territorio (sección 9) y Emergencias (sección 10) sin duplicar datos. Se separan hechos, estimaciones e hipótesis, y no se atribuye una causa ambiental sin evidencia suficiente.

### 25.7. Trazabilidad de soja con blockchain: Bunge y CP amplían a Vietnam (17/11/2026)

**Fuente:** anuncio de Bunge y Bangkok Produce Merchandising (BKP, grupo Charoen Pokphand) del 17/11/2026, nota de Clarín Rural y otras coberturas del mismo anuncio. **Estado:** caso de referencia registrado el 18/11/2026; no es especificación técnica ni acuerdo con ninguna empresa.

**Síntesis:** el programa de trazabilidad de soja con blockchain que ya funcionaba de Brasil a Tailandia se amplía a Vietnam y suma por primera vez harina de soja argentina, que Bunge entrega directamente a CP Vietnam. El origen y los atributos de sustentabilidad se verifican combinando blockchain, documentación de la cadena y monitoreo satelital.

**Qué confirma para Agro Fields:**

- El comprador internacional pide saber de qué campo sale el grano y si ese campo está en regla. Eso es dato de origen: el núcleo de Agro Fields.
- El blockchain es una herramienta del exportador, no el valor en sí. El valor es el dato de origen confiable, con fuente, fecha, aportante, evidencia y estado. Se mantiene el principio: identidad persistente y trazable, no token especulativo.
- Estos programas los manejan hoy las grandes empresas, del puerto hacia adelante. Agro Fields le da al productor sus propios datos de origen, ordenados, para que los comparta él, con permiso, con cualquier comprador, sin quedar atado a un solo intermediario («Una plataforma propia. Muchas conexiones.»).

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Ubicación del lote de origen | Ubicación del campo en el mapa (AF-090) | — | ✅ |
| Sin desmonte / historia del uso del suelo | Historia del territorio (AF-109) | — | ✅ |
| Certificados y atributos de sustentabilidad | Documentos del campo con "certificación" como tipo (AF-095) | — | ✅ |
| Cultivo, cosecha y trazabilidad del producto | Cadena Activo → Lote → Cultivo → Cosecha; movimientos | — | ✅ |
| Compartir el origen con un exportador o comprador | Copia congelada y acceso revocable del marketplace; estados del dato | "Paquete de origen" que el productor comparte con permiso (AF-118) | 🟡 |
| Requisitos de cada mercado | — | Requisitos por mercado y semáforo de brechas (sección 15) | 🟡 |
| Monitoreo satelital | Campo "fuente del dato" en Monitoreo (GAP-MON-01) | Capas satelitales (sección 9) | 🟢 |
| Conexión con plataformas de exportadores | — | VISEC y plataformas de exportadores por vías oficiales (sección 17) | 🟢 |

**Criterio:** no se crea un módulo nuevo ni se usa blockchain. El "paquete de origen" reutiliza lo que ya existe. Agro Fields informa y conecta; no certifica, no garantiza el cumplimiento ni es intermediario obligatorio.

### 25.8. Polémica VISEC Carne (denuncia de la Sociedad Rural de Santa Fe, noviembre de 2026)

**Estado:** caso de referencia registrado el 18/11/2026 a partir del análisis del usuario; no es especificación técnica ni toma posición en la polémica.

**Síntesis:** la Sociedad Rural de Santa Fe cuestionó públicamente el funcionamiento de VISEC Carne, la plataforma de verificación usada para exportar carne vacuna con exigencias de origen.

**Qué confirma para Agro Fields:**

- Con buena trazabilidad del rodeo y de cada animal, Agro Fields puede ser una buena vidriera del productor frente al comprador.
- Principio (también va en los términos de uso): **Agro Fields es un servicio de trazabilidad de los datos que el productor brinda al cliente, sin certificar ni garantizar.**
- Agro Fields no compite con VISEC ni la reemplaza; puede conectarse por vías oficiales (sección 17) sin depender de una sola plataforma.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Mostrar al comprador el origen del ganado | Copia congelada, acceso revocable y estados del dato | Paquete de origen (AF-118) | 🟡 |
| Trazabilidad animal por animal | Modo de identificación "por animal" preparado en el rodeo | Caravana individual e historia por animal (AF-104) | 🟡 marzo 2027 |
| Conexión con VISEC u otras plataformas | — | Interoperabilidad por vías oficiales (sección 17) | 🟢 |

**Criterio:** no se crea un módulo nuevo. Informar ≠ certificar.

### 25.9. Carne argentina terminada a grano en China y Asia (feria CIIE, Shanghái, noviembre de 2026)

**Estado:** caso de referencia registrado el 19/11/2026; no es especificación técnica. Requisitos y precios por mercado se confirman con fuente oficial.

**Síntesis:** el IPCVA y frigoríficos argentinos presentaron en la feria CIIE de Shanghái carne terminada a grano; también se apuntan Filipinas, Vietnam y Singapur. Estos compradores valoran saber cómo se terminó el animal y cuántos días estuvo a corral.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Cómo se terminó el lote | Etapas del rodeo (recría, feedlot) en GAP-PROD-01 | Tipo de terminación (pasto / grano / mixto), fecha de entrada al corral y días de encierre (AF-119) | 🔴 enero |
| Ración y consumo del lote de feedlot | Evento "alimentación" preparado; stock de alimento | Ración unida al stock y conversión alimenticia (AF-103) | 🟡 |
| Mostrarlo al comprador | — | "Terminado a grano, X días" dentro del paquete de origen (AF-118) | 🟡 |
| Requisitos y precios de cada mercado | — | Inteligencia regulatoria y de mercados (secciones 14 y 15) | 🟡 |

**Criterio:** se apoya en el núcleo productivo existente, sin módulo nuevo. El código se escribe recién después de la Matriz y la Auditoría.

### 25.10. Compra de campos por extranjeros (noviembre de 2026)

**Estado:** caso de referencia registrado el 19/11/2026; las normas de cada país se confirman con fuente oficial antes de usarlas.

**Síntesis:** inversores brasileños eligen comprar campos en Paraguay y Bolivia por las restricciones que tiene Argentina para la compra de tierras rurales por extranjeros.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Saber si un campo puede venderse a un extranjero | Publicación con país y provincia | Marca "apto para comprador extranjero" en la publicación (declarada por quien publica) (AF-120) | 🟡 |
| Reglas de cada país o provincia | — | Reglas por jurisdicción con fuente, fecha y vigencia (AF-120) | 🟢 |

**Criterio:** Agro Fields informa lo que declara quien publica; no da asesoramiento legal ni garantiza que la operación sea posible.

### 25.11. Estafas ganaderas (El Doce, Córdoba y Santa Fe, noviembre de 2026)

**Estado:** caso de referencia registrado el 19/11/2026 a partir del análisis del usuario; no es especificación técnica. Las propuestas del análisis (PROP-EST) se asignan a AF existentes; el detalle se completa con el documento original.

**Síntesis:** casos de estafas en la compraventa de hacienda en Córdoba y Santa Fe, donde el productor entrega sin saber bien con quién opera.

**Qué confirma para Agro Fields:**

- El productor necesita conocer a su cliente antes de operar. De ahí nace el **registro de clientes** (AF-121, GAP-CLI-01) para enero: el productor puede ver la información que el propio cliente brinda (trazabilidad de datos y confianza, como dice el lema).
- Se reutiliza lo que ya existe: Operación Agropecuaria Protegida y cheques (sección 6.2), estados del dato, documentos y permisos.

**Criterio:** Agro Fields no es garante. Muestra lo que el cliente declaró y con qué respaldo, con su estado (declarado / con documento / verificado); la decisión y el riesgo son de las partes. No se publican listas de "malos clientes" ni acusaciones: los datos de una persona son privados y solo se comparten con su permiso.

### 25.12. Drively.me: concesionaria virtual con IA (Forbes, noviembre de 2026)

**Estado:** caso de referencia registrado el 19/11/2026; no es especificación técnica ni acuerdo con la empresa.

**Síntesis:** concesionaria virtual de autos que usa inteligencia artificial y una red de vendedores sobre un mismo catálogo. Sirve de ejemplo para el Mercado de inmobiliarias y brokers de Agro Fields.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Que el comprador o arrendatario siga usando Agro Fields | El dueño puede tomar posesión del expediente y pasarlo a gestión | Invitar al comprador o arrendatario a pasar el campo a gestión (AF-122) | 🔴 enero |
| Crecer de boca en boca | Plan Fundadores | Código de invitación para Fundadores, con premio a definir (AF-123) | 🔴 enero |
| Un campo, muchos vendedores | Un solo registro por campo; cualquier broker lo ofrece | Marca "otros brokers pueden ofrecerlo" y registro de quién trajo cada consulta (AF-124) | 🔴 enero |
| Vidriera y página propia | — | Vidriera por broker y página propia de la inmobiliaria (AF-125) | 🟡 |
| Carga rápida con IA y videos | Carga rápida en 4 pasos | Carga con IA pegando un aviso; videos del campo (AF-125) | 🟡 / 🟢 |
| Comisiones | — | Solo a estudiar (AF-125) | 🟢 |

**Criterio:** se apoya en el marketplace existente (un campo, un registro). La IA ayuda a cargar pero no verifica. Conectar no es intermediar.

### 25.13. Uruguay: trazabilidad ganadera, sostenibilidad y acceso al mercado europeo (noviembre de 2026)

**Estado:** caso de referencia registrado el 24/11/2026; no es especificación técnica. Cifras a confirmar con su fuente antes de usarlas.

**Síntesis:** con la aplicación provisional del acuerdo MERCOSUR–Unión Europea (desde el 01/05/2026), Uruguay busca vender más carne vacuna a Europa. El INAC lanzó la campaña "Uruguay Beef – Made in Nature" (Alemania y Países Bajos) apoyada en origen, calidad y pastizales, y destaca su trazabilidad obligatoria del ganado y su bajo riesgo de deforestación. En los primeros meses se concretó solo una parte chica de lo pedido dentro de la cuota (alrededor del 15 %), por falta de acuerdo entre los países del bloque para repartir el contingente.

| Lo que pide el mercado | Respuesta de Agro Fields | Etapa |
|---|---|---|
| Identificación del animal | Caravana individual (AF-104) | 🟡 / 🟢 |
| Origen | Activo Agro y ubicación en el mapa (AF-090) | 🔴 hecho |
| Trazabilidad | Historial de movimientos (AF-089) | 🔴 hecho |
| Alimentación y producción | Expediente productivo; terminación del lote (AF-119) | 🔴 |
| Sanidad | Documentos y evidencias del campo | 🔴 hecho |
| Sostenibilidad | Historia del territorio (AF-109) | 🔴 hecho |
| Información para compradores | Paquete de origen (AF-118) | 🟡 |
| Auditoría | Registro de quién cargó y quién vio cada dato | 🔴 hecho |

**Criterio:** la trazabilidad no es solo una obligación: puede ser una ventaja comercial. La confianza comercial se construye con información verificable, no solo con lo que declara el vendedor. Sin AF nuevo; refuerza el Expediente, AF-104 y AF-118. Agro Fields no certifica ni garantiza el acceso a un mercado.

**Fuentes a conservar:** INAC (campaña Uruguay Beef); Cancillería de Uruguay (acuerdo MERCOSUR–UE); DOXA (uso de las cuotas); Noticias AgroPecuarias (balance de seis meses, 23/11/2026).

### 25.14. Curso de invernada y feedlot (noviembre de 2026)

**Estado:** caso de referencia registrado el 24/11/2026 a partir de lo aprobado el 21 y el 23/11/2026; no es especificación técnica.

**Síntesis:** el productor de invernada o feedlot necesita saber cuántos animales aguanta su campo y si el rodeo le deja plata: kilos producidos, kilos por hectárea, costo por kilo y kilos necesarios para cubrir los costos.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Cuántos animales aguanta el campo | Rodeos y lugares (GAP-PROD-01) | Carga animal con semáforo (AF-126) | 🔴 enero |
| Si el rodeo gana o pierde | Pesajes (GAP-PESO-01) y gastos (GAP-ECO-01) | Resultado del rodeo (AF-127) | 🔴 si llega, si no marzo |
| Estacionalidad y materia seca | — | Ampliación de AF-126 | 🟢 marzo |

**Criterio:** todo se calcula con datos que el productor ya carga; sin colecciones nuevas. Los valores de referencia son orientativos y los ajusta el productor o su ingeniero.

### 25.15. Limón caviar en Paraguay: cultivos perennes y frutales (noviembre de 2026)

**Estado:** caso de referencia registrado el 24/11/2026 a partir de lo aprobado el 23/11/2026; no es especificación técnica.

**Síntesis:** productores que plantan frutales o cultivos que producen varios años (por ejemplo, limón caviar en Paraguay, o nogales) también necesitan llevar su producción y mostrar su origen.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Registrar un frutal | Agricultura (cultivo) | Auditar que acepte un frutal (y el maní, cultivo anual común) | 🔴 enero, nada nuevo |
| Cultivo de varios años | — | Cultivo perenne / frutales (AF-134) | 🟡 |
| Módulo completo y origen | Paquete de origen (AF-118) | Módulo de frutales completo | 🟢 |

**Criterio:** en enero no se agrega nada nuevo; primero se audita lo que ya existe.

### 25.16. Maíz amarillento por fósforo bloqueado (publicación de Agrobull Ecuador, 23/11/2026)

**Estado:** caso de referencia registrado el 24/11/2026; no es especificación técnica. Es una publicación de una empresa que vende productos: no se toma su oferta comercial, y lo agronómico se confirma con una fuente técnica (por ejemplo, INTA) antes de usarlo en la app.

**Síntesis:** el maíz que nace amarillento y con poco vigor muchas veces tiene el fósforo bloqueado (suelo compactado, muy húmedo o con pH alto), aunque se haya aplicado. Se relacionan la ubicación del fertilizante (en la línea), la humedad y el zinc.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Saber qué nutrientes tiene el suelo | Suelo (pH, materia orgánica, textura, drenaje); botón Adjuntar | Análisis de nutrientes: fósforo, zinc, nitrógeno, potasio, con fecha, laboratorio y archivo (AF-136) | 🟡 |
| Registrar lo que se ve en el cultivo | Monitoreo con fuente del dato y fotos (GAP-MON-01) | Síntomas: hojas amarillas, poco vigor, nacimiento desparejo, con foto y lote (AF-137) | 🟡 |
| Saber qué fertilizante se puso y dónde | Aplicaciones y Stock (GAP-APLI-01, GAP-STOCK-01) | Fertilizante en la línea de siembra: producto y kg/ha, descontado del stock (AF-138) | 🟡 |
| Entender posibles causas | Suelo + Monitoreo + clima; profesional invitado (AF-093) | "Posibles causas para consultar con tu ingeniero" cruzando síntoma, suelo y clima (dentro de AF-137) | 🟢 marzo |

**Criterio:** la IA es copiloto: sugiere posibles causas para consultar, no diagnostica ni receta. La decisión es del productor y su profesional. En enero no se agrega nada nuevo.

### 25.17. El Niño muy fuerte 2026-2027 (Infobae, 24/11/2026, con datos del boletín del CIIFEN)

**Estado:** caso de referencia registrado el 24/11/2026; no es especificación técnica. Cifras a confirmar con el boletín del CIIFEN (próxima actualización: primera quincena de diciembre de 2026) y los servicios meteorológicos de cada país.

**Síntesis:** el CIIFEN clasifica el evento como "muy fuerte"; los modelos ubican el pico entre diciembre de 2026 y febrero de 2027 y prevén más lluvias en el sur de Brasil, Argentina, Paraguay y Uruguay. En octubre ya hubo exceso de lluvias en partes de Paraguay y el sur de Brasil. La nota no detalla inundaciones ni efectos concretos en el agro de estos países.

**Por qué importa:** el pico coincide con el lanzamiento y los primeros Fundadores. Prepararse antes de la lluvia y reaccionar rápido es un valor concreto de Emergencias y Territorio Inteligente.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Prepararse antes de la lluvia | Emergencias (AF-092); lugares de Producción; historia del territorio (AF-109) | Plan de emergencia del campo: potreros altos o seguros, caminos que se cortan, contactos y vecino que puede recibir; "Trasladar animales" propone el potrero seguro (AF-139) | 🔴 enero, versión chica |
| Saber qué dicen los organismos | Botón "Ver alertas oficiales" (SMN, DMH) (AF-111) | Sumar INUMET (Uruguay) | 🔴 enero |
| Mover animales y registrar daños | Emergencia ↔ Traslado (AF-131) | Mapa de campos "disponibles para recibir" cercanos (🟡 en AF-131): evaluar adelantarlo a enero o febrero | Evaluar |
| Avisos automáticos por ubicación | — | Alertas por ubicación (AF-117) | 🟢 marzo |

**Criterio:** Agro Fields no pronostica ni reemplaza a los servicios meteorológicos: muestra las alertas oficiales con su fuente y ayuda a prepararse y registrar. No atribuir causas sin evidencia.

### 25.18. Maíz barato y costo de alimentación ganadera (nota de Valor Agro, Federico Morixe, noviembre de 2026)

**Estado:** caso de referencia registrado el 24/11/2026; no es especificación técnica. Cifras y precios a confirmar con la fuente antes de usarlos.

**Síntesis:** la abundancia de maíz en Argentina, Brasil y Paraguay baja el costo de alimentación de los feedlots y de la producción animal en general.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Conocer el precio del maíz | Ventas guarda el precio obtenido | Precio de referencia manual del maíz (y otros granos) con fuente y fecha, dentro de Inteligencia de Mercados (AF-140) | 🟡 |
| Saber cuánto cuesta alimentar por kilo producido | Pesajes (AF-102), Gastos (GAP-ECO-01), Stock (GAP-STOCK-01) | Costo de alimentación por kilo producido en "Resultado del rodeo" (AF-127), con la ración del feedlot unida al Stock y el precio del maíz | 🟡 |
| Avisar cuando cambia el precio | — | Aviso automático de precio | 🟢 |
| Conectar al que tiene grano con el que lo necesita | Granos guardados (AF-132) | Marca voluntaria "tengo grano para vender" para conectar silobolsa con ganadero de la zona | 🟢 marzo |

**Criterio:** Agro Fields informa, no recomienda comprar ni vender; conecta, no garantiza. No cambia el plan de diciembre.

### 25.19. Operación a término incumplida (Formosa, noviembre de 2026)

**Estado:** caso de referencia registrado el 24/11/2026; no es especificación técnica. No se nombra a ninguna persona.

**Síntesis:** una venta de hacienda a término (entrega y pago en fechas futuras, con cheques) que no se cumplió. Muestra el riesgo de operar sin conocer a la otra parte ni seguir los compromisos.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Registrar la operación a término | Operación Agropecuaria Protegida y cheques (GAP-OPER-01); aviso 7 días antes del vencimiento de un cheque | Operación a término: animales, kilos, precio, fecha de entrega, calendario de cheques; estados pendiente de entrega / entregado / incumplido; aviso 7 días antes de la entrega (AF-141) | 🔴 enero |
| Conocer al cliente | Registro de clientes (GAP-CLI-01, AF-121) | Unir la operación a término con el cliente | 🔴 enero |
| Revisar los cheques | — | Botón "Consultar cheques en el Banco Central" que abre la consulta oficial por CUIT | 🔴 enero |
| Saber si el vendedor tiene lo que vende | Producción (existencias) | Lugar preparado para que el vendedor comparta su stock real | 🟡 |
| Confianza compartida | — | Semáforo automático con el BCRA (confirmar si se permite), historial de cumplimiento compartido (red de cheques), pago en garantía con banco o billetera virtual | 🟢 marzo o después |

**Criterio:** la app no nombra a nadie como estafador: solo muestra datos objetivos. Agro Fields no es garante. Amplía GAP-OPER-01 sin módulo nuevo y no cambia el plan de diciembre.

### 25.20. Cooperativas vitivinícolas de San Martín (Mendoza, noviembre de 2026)

**Estado:** caso de referencia registrado el 24/11/2026; no es especificación técnica.

**Síntesis:** en San Martín (Mendoza) los productores de uva entregan la cosecha a cooperativas vitivinícolas. Hay fincas con viñedo abandonadas.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Registrar el viñedo | Agricultura (cultivo); Cultivo perenne / frutales (AF-134) | "Vid / viñedo" como ejemplo en AF-134 | 🟡 |
| Entregar la cosecha a la cooperativa | Cosecha; "¿A dónde va la plata de mi venta?" (AF-133) | Cooperativas: entrega de la cosecha (cantidad, fecha, cooperativa, liquidación) unida al desglose de la venta (AF-142) | 🟡 febrero-marzo |
| Ofrecer fincas abandonadas | Mercado para inmobiliarias (AF-038, GAP-MERC-01) | Usarlas como ejemplo de publicación en el Mercado | Ejemplo |

**Criterio:** nada nuevo antes de la prueba cerrada del ~15/12/2026.

### 25.21. Cosecha de girasol en Corzuela (Chaco, noviembre de 2026)

**Estado:** caso de referencia registrado el 24/11/2026; no es especificación técnica. Cifras a confirmar con la fuente.

**Síntesis:** en el establecimiento Don Vidal (Corzuela) se cosecharon unas 70 ha de girasol de un total de unas 700, con un rendimiento informado de 2.200 kg/ha contra 1.800 kg/ha de promedio provincial. La cosecha se frenó por el clima, y en diciembre siguen soja y maíz.

**Revisión del código (25/11/2026, solo lectura):**

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Cosechar un lote por partes | ✅ Varias cosechas en el mismo cultivo se suman solas (sembrado X ha / cosechado Y ha) y avisa si se cosecha más de lo sembrado | — | Hecho |
| Pausar la cosecha por el clima y retomarla | 🟡 Cada parte tiene fecha y notas | Marca "cosecha en pausa" con motivo (clima), unible a Emergencias (AF-143) | 🟡 enero-febrero |
| Rendimiento por lote comparado con un promedio | 🟡 El sistema calcula el rendimiento (tn ÷ ha cosechadas) por cultivo y lote | Promedio de referencia con fuente y fecha y la comparación "+X % sobre el promedio" (AF-143) | 🟡 enero-febrero |
| Segundo cultivo en el mismo lote y la misma campaña | ✅ Cada cultivo es "cultivo + campaña + lote": se pueden cargar dos en el mismo lote | Marcar "de segunda" (opcional) | Hecho |

**Criterio:** el caso ya se puede cargar casi completo. No cambia el plan de diciembre.

### 25.22. Frutihortícola de Presidencia Roque Sáenz Peña (Chaco, noviembre de 2026)

**Estado:** caso de referencia registrado el 24/11/2026; no es especificación técnica.

**Síntesis:** la Ing. Agr. Cecilia Codutti busca que los productores frutihortícolas de la zona incorporen nuevas tecnologías.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Frutales | Cultivo perenne / frutales (AF-134) | — (se suma como ejemplo) | 🟡 |
| Hortalizas de ciclo corto | Agricultura (cultivo + campaña + lote) | Horticultura: varios ciclos por año en el mismo lote, lotes chicos (m² o surcos), invernadero y riego, venta frecuente (feria, mercado concentrador, directo) (AF-144) | 🟡 |
| Probar lo que hay | — | Auditar que Agricultura acepte un lote chico con más de un cultivo por año | 🔴 enero, nada nuevo |
| Módulo completo | — | Módulo de horticultura completo | 🟢 después |

**Criterio:** en enero no se agrega nada nuevo; primero se audita lo que ya existe.

### 25.23. Resolución 2003/2026: frigoríficos que exportan carne vacuna a la Unión Europea (noviembre de 2026)

**Estado:** caso de referencia registrado el 25/11/2026; no es especificación técnica. Confirmar cifras y requisitos con el texto oficial del Boletín Oficial antes de usarlos.

**Síntesis:** el Ministerio de Economía fijó nuevas reglas para los frigoríficos que exportan carne vacuna a la Unión Europea dentro del cupo de cortes enfriados y congelados con arancel cero: faena primero y en orden cronológico de las tropas, identificación de las reses, cajas cerradas con fajas y rótulos, y exclusión y sumarios si no se cumple.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Saber de qué tropa y de qué campo viene cada res | Traslado simple (AF-089), núcleo productivo ganadero (GAP-PROD-01) | — | 🔴 enero, nada nuevo |
| Marcar un lote "pensado para Europa" y ver qué requisitos le faltan | Paquete de origen (AF-118) | Marca de lote "pensado para Europa" con requisitos faltantes | 🟡 |
| Unir cada animal con su paquete de origen y conectarse con el frigorífico | Caravana individual (AF-104) | Caravana individual unida al paquete de origen; conexión con frigoríficos por vías oficiales | 🟢 |

**Relación:** 25.13 (Uruguay y carne a Europa) y 25.8 (VISEC Carne).

**Criterio:** Agro Fields no certifica ni garantiza: brinda la trazabilidad de los datos que el productor entrega a su cliente. Sin AF nuevo.

### 25.24. Búfalos en Chaco (noviembre de 2026)

**Estado:** caso de referencia registrado el 25/11/2026; no es especificación técnica.

**Síntesis:** nota sobre la cría de búfalos en Chaco. El usuario quiere incorporar la especie a Agro Fields.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Cargar un rodeo de búfalos | Núcleo productivo ganadero (GAP-PROD-01), apto para otras especies | Especie "búfalo" en la lista | 🔴 enero |
| Caravana electrónica y razas | Genética (AF-130), caravana individual (AF-104) | Razas bubalinas; caravana electrónica según la norma | 🟡 |
| Leche de búfala y exportación | Paquete de origen (AF-118), caso 25.23 | Producción de leche y requisitos de exportación | 🟢 |

**Pendiente:** cuando se trabaje la hacienda, confirmar con fuente oficial (SENASA) desde cuándo es obligatoria la caravana electrónica para búfalos y cuáles son las categorías oficiales.

**Criterio:** sin AF nuevo; se reutiliza el núcleo ganadero.

### 25.25. MiCampoDigital: competencia en gestión ganadera (noviembre de 2026)

**Estado:** caso de referencia registrado el 26/11/2026 a partir de la página comercial https://micampodigital.com.ar/; no es especificación técnica. Lo que dice la página no está verificado por Agro Fields.

**Síntesis:** software argentino de gestión ganadera (cría, recría, invernada y feedlot), sin agricultura. Hoy todas sus funciones son gratis. Fuerte en la carga en la manga: historia de cada animal por caravana, preñez y sanidad, administración (gastos, ingresos, libro diario), mapa satelital de potreros con índice de verde y carga, asistente con IA por texto o audio, importación de Excel, calculadoras gratis sin cuenta, funcionamiento sin señal, roles de equipo, archivo para SENASA (SIGSA, Res. 841/2025) y lector de caravanas y balanza.

| Aprendizaje del caso | Ya existe | Falta | Etapa |
|---|---|---|---|
| Pasar planillas sin cargar todo de nuevo | AF-052 (Excel/CSV, sin hacer) | Importar Excel con elección de columnas y vista previa (AF-147) | 🔴 enero si entra |
| Declarar ante SENASA sin carga doble | Traslado simple (AF-089), caso SNIG (sección 12) | Archivo para SIGSA, con formato confirmado en fuente oficial (AF-148) | 🟡 |
| Cargar en la manga con lector y balanza | Pesajes (GAP-PESO-01), sin señal (GAP-OFF-01), Tru-Test (sección 17) | Lectura de caravanas EID/RFID y balanza (AF-149) | 🟡 / 🟢 |
| Preñez y vacunas | Eventos del rodeo (GAP-PROD-01), campanita (AF-145) | Tasa de preñez por lote y recordatorios sanitarios (AF-150) | 🟡 |
| Manejar el pasto con el mapa | Ubicación (AF-090), carga animal (AF-126), superficie dibujada (AF-128) | Potreros dibujados y verde por cuadro (AF-151) | 🟢 marzo |
| Atraer usuarios con algo útil | Precio de referencia (AF-140) | Calculadoras gratis en la web (AF-152) | 🟢 |
| Consultar con IA por texto o audio | Asistente Integral (AF-082) | Asistente por texto y audio | 🟢 |

**Lo que Agro Fields tiene y ellos no:** agricultura y otras especies (aves, peces, búfalos), Mercado para inmobiliarias y brokers, expediente del campo con estados de confianza, documentos con vencimiento, emergencias e historia del territorio, operaciones y cheques, stock e insumos, Paraguay y Argentina.

**Criterio:** en ganadería pura y gratis la competencia es fuerte; el diferencial de Agro Fields es el campo completo, la confianza en los datos y el Mercado. Revisar el precio de Pro Productor (US$ 19) con los Fundadores teniendo en cuenta que esta competencia es gratis. La IA sugiere, no verifica.

### 25.26. "Verificar antes de arrancar": la parábola del trigo y la cizaña (noviembre de 2026)

**Estado:** principio inspirador registrado el 26/11/2026 a pedido del usuario; no es especificación técnica.

**Síntesis:** en la parábola (Mateo 13,24-30 y 36-43) un hombre siembra buena semilla, pero mientras todos duermen un enemigo siembra cizaña. Los siervos quieren arrancarla enseguida; el dueño les dice que esperen a la cosecha para no arrancar también el trigo, y que la separación la harán los segadores en su momento: primero juntan la cizaña y después guardan el trigo en el granero. La cizaña joven se parece mucho al trigo y recién se distingue bien cuando espiga.

| Enseñanza | Ya existe | Falta | Etapa |
|---|---|---|---|
| El enemigo siembra de noche: alguien tiene que estar atento | Campanita de avisos (AF-145); aprobación del broker/inmobiliaria (AF-038) | Avisos de publicaciones marcadas como dudosas | AF-153 |
| No arrancar apurado: lo dudoso se marca y se aparta, no se borra | Pausar aviso o sacar permiso (AF-038) | Estado "en revisión" con motivo visible para el afectado | AF-153 |
| No separa cualquiera: hace falta un rol y un criterio | Roles y permisos (administrador) | Reglas claras de revisión; solo el administrador decide | AF-153 |
| Se conoce por el fruto | Fecha de publicación (AF-038 H), operaciones y cheques | Historial del usuario como apoyo para decidir | AF-153 / 🟡 |
| Cuidar el trigo: lo bueno se guarda con cuidado | Trazabilidad y expediente del campo | Registro de quién, cuándo y por qué; poder deshacer | AF-153 |

**Criterio:** Agro Fields no juzga personas: revisa publicaciones y datos con paciencia, criterio y registro. Nada se borra por un error y todo se puede deshacer. Sembrar bien desde el principio (datos correctos y reglas claras) evita la mayor parte de los problemas.

### 25.27. Virgilio: Bucólicas y Geórgicas, y el lema de la página web (noviembre de 2026)

**Estado:** principio inspirador registrado el 26/11/2026 a pedido del usuario; no es especificación técnica.

**Lema aprobado para la página web:** *"Labor omnia vicit improbus"* (Geórgicas I, 145-146): el trabajo constante lo vence todo. El usuario pidió que la página web de Agro Fields lleve estas inspiraciones (este lema, la parábola del trigo y la cizaña de la sección 25.26 y las enseñanzas de abajo).

**Síntesis:** Virgilio escribió hace más de 2.000 años las Bucólicas (poemas de pastores) y las Geórgicas (un libro de trabajo rural en cuatro partes: cultivos y clima, árboles y viñas, ganado, abejas). Muchas de sus enseñanzas coinciden con lo que Agro Fields busca resolver.

| Enseñanza de Virgilio | Dónde aparece en Agro Fields |
|---|---|
| No todas las tierras pueden dar de todo; probar el suelo antes de sembrar (Geórgicas II) | Pregunta guía y expediente del campo: clase de suelo, producción compatible |
| Leer las señales del cielo y de los animales para anticipar el tiempo (Geórgicas I) | Clima, alertas y emergencias |
| Rotar cultivos y dejar descansar la tierra (Geórgicas I) | Historial productivo de cada lote |
| Elegir bien las madres para la cría (Geórgicas III) | Genética (AF-130) |
| Apartar a tiempo al animal enfermo para que no contagie (Geórgicas III) | Sanidad y trazabilidad; "marcar y apartar" (AF-153) |
| La colmena funciona porque cada abeja tiene su tarea (Geórgicas IV) | Roles: dueño, encargado, ingeniero, broker |
| Un pastor pierde su tierra y otro la conserva (Bucólica I) | Seguridad de los títulos: expediente y toma de posesión del Mercado (AF-038 F) |

**Criterio:** inspiración para el tono y los textos de la página web; no agrega funciones. Las frases en latín se citan con su fuente (obra, libro y verso) y con traducción simple.

### 25.28. Pronóstico agroclimático de la Bolsa de Cereales (nota de Clarín, semana del 26/11 al 2/12/2026)

**Fuente:** nota de Clarín Rural con el pronóstico de la Bolsa de Cereales de Buenos Aires (la nota no se pudo abrir completa; los datos se tomaron de la Bolsa). **Estado:** caso de referencia aprobado el 26/11/2026 y anotado el 27/11/2026; no es especificación técnica.

**Síntesis:** en una misma semana, frío con riesgo de heladas en sierras y cordillera, sierras bonaerenses y centro-norte de Uruguay; después calor fuerte (más de 35 °C en el norte y hasta 45 °C en puntos del Chaco, este del NOA, Mesopotamia y sudeste de Paraguay); y lluvias muy desparejas: de menos de 10 mm a focos de 100-150 mm.

| Enseñanza | Dónde aparece en Agro Fields | Estado en el código (revisado el 27/11/2026) |
|---|---|---|
| La alerta tiene que ser por campo, no por provincia | AF-117 (alerta según la ubicación del campo, 🟢 marzo) | Planificado |
| Heladas como emergencia | AF-092 (emergencias) | Ya existe el tipo "Helada" |
| Ola de calor como emergencia (y estrés por calor en la hacienda) | AF-092 | Sumado "Calor extremo" el 27/11/2026 |
| Lo que vale es lo que marcó el pluviómetro del campo, con fecha y fuente | Clima e Inteligencia hídrica (25.5) | No existe: AF-160 Registro de lluvia (🟡 enero) |
| Cosecha frenada por lluvias | AF-143 (cosecha en pausa por clima) | Planificado |
| La Bolsa de Cereales como fuente con fecha, junto al SMN | Botón "Ver alertas oficiales" | Solo SMN |

**Criterio:** Agro Fields informa con fuente y fecha; no pronostica. Ligado a los casos 25.3 (Córdoba) y 25.5 (Inteligencia hídrica).

### 25.29. miArgentina y GDEBA: sencillez como modelo (noviembre de 2026)

**Estado:** referencia de diseño registrada el 27/11/2026 a pedido del usuario; no es especificación técnica.

**Qué se tomó:** de la app miArgentina, el Inicio con pocos botones grandes y casi sin bajar ("¿Qué necesitás hoy?"); de la página de GDEBA, una web pública con menú, banner, objetivos numerados y un botón de acceso que lleva al sistema. Agro Fields usa su propia frase: "¿Qué hacemos hoy en el campo?".

| Referencia | Dónde aparece en Agro Fields |
|---|---|
| Inicio con botones grandes y perfil arriba (miArgentina) | AF-154: Inicio con 9 botones, campanita y personita ("Mi perfil") |
| Ingreso simple en el celular | AF-155: entrar con huella (solo en el celular) |
| Web pública con "Acceso" (GDEBA) | AF-156: página web con el lema de Virgilio (25.27) |

**Criterio:** menos pantallas y menos botones repetidos; lo importante, a un toque. Las ideas se inspiran en esos sitios, sin copiar su marca ni su diseño.
