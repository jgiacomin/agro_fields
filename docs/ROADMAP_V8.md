# ROADMAP AGRO FIELDS V8

## Estado del proyecto

Proyecto:

Agro Fields


Arquitectura:

V8.0


Último cierre técnico:

23/07/2026


Último commit:

ef874cb


Objetivo:

Continuar la evolución del ecosistema Agro Fields manteniendo:

- compatibilidad del modelo existente;
- trazabilidad mediante Git;
- documentación técnica;
- auditoría de cambios;
- evolución modular.


---

# Módulo principal

## ActivoAgroV2


Archivo:

lib/models/activos/activo_agro_model_v2.dart


Estado:

✅ Base arquitectónica implementada


Contiene:

- identidad;
- clasificación;
- ubicación;
- producción;
- economía;
- documentación;
- confianza;
- evaluación;
- madurez;
- participantes;
- historial;
- auditoría.

La auditoría forma parte de la trazabilidad integral del Activo Agro.

Su objetivo es conservar la historicidad del activo mediante el registro de eventos relevantes, participantes, modificaciones y evidencias asociadas.

No reemplaza el historial del activo.

Lo complementa permitiendo reconstruir la evolución completa de la entidad digital productiva.

Criterio definido:

No crear ActivoAgroV3.


Continuar evolución sobre ActivoAgroV2.


---

# Actualización 23/07/2026


ActivoAgroV2 incorpora evolución inicial de:


- ubicación territorial avanzada;
- participantes;
- historial;
- versión del modelo;
- trazabilidad de creación;
- relación Campo → Activo Agro.


Objetivo:


Transformar el Activo Agro desde una publicación hacia una entidad digital productiva trazable.


---

# Auditorías completadas


## Economía


Archivo:

economia_activo_model.dart


Estado:

✅ Auditado y evolucionado


Incorporado:

- objetivo del proyecto;
- etapa del proyecto;
- inversión esperada;
- capacidad actual;
- capacidad proyectada;
- riesgos;
- origen información;
- responsable declaración.


Objetivo futuro:

Relacionar producción, inversión y expansión del activo.


---

## Ubicación


Archivo:

ubicacion_activo_model.dart


Estado:

✅ Auditado y evolucionado


Incorporado:


Jerarquía territorial:


País

↓

Provincia / Estado

↓

Departamento

↓

Municipio / Localidad


Objetivo:


Preparar:

- análisis legal;
- restricciones territoriales;
- expansión internacional;
- evaluación por jurisdicción.


---

## Producción


Archivo:

modulo_produccion_model.dart


Estado:

✅ Auditado


Base existente:


- dominio;
- actividad;
- descripción;
- superficie;
- unidad;
- datos.


Evolución pendiente:


- ciclos productivos;
- historial;
- capacidad futura;
- expansión;
- validación profesional.


---

## Confianza


Archivo:

confianza_activo_model.dart


Estado:

✅ Auditado


Base existente:


- nivel general;
- identidad;
- documentación;
- evidencias;
- información productiva;
- participantes;
- observaciones.


Evolución pendiente:


Evolución pendiente:

- factores oficiales;
- cálculo multidimensional;
- evidencias asociadas;
- responsables de validación;
- profesionales participantes;
- auditorías;
- historial de verificaciones.

Criterio:

El Índice de Confianza no determina rentabilidad ni garantiza resultados económicos.

Evalúa el nivel de información, respaldo, trazabilidad e historial disponible sobre un Activo Agro.



---

## Documentación


Archivo:

documentacion_activo_model.dart


Estado:

✅ Auditado


Base existente:


- documentos;
- certificaciones;
- permisos;
- archivos;
- observaciones.


Evolución pendiente:


- metadata documental;
- vencimientos;
- validación profesional;
- evidencia verificable;
- trazabilidad documental.


---

## Servicio


Archivo:

activo_agro_service_v2.dart


Estado:

✅ Revisado


Funciones actuales:


- crear activo;
- obtener activo;
- listar activos;
- buscar por propietario;
- buscar por publicador;
- publicar;
- pausar;
- actualizar;
- actualizar confianza.


Evolución futura:


- generación automática de historial;
- control de permisos;
- auditoría de modificaciones;
- eventos profesionales.


---

# Evolución Jornada 23/07/2026


## Conversión Campo → Activo Agro


Archivo:

campo_to_activo_service.dart


Estado:

✅ Evolucionado


Incorpora:


- ubicación completa;
- economía inicial;
- propietario como participante;
- historial de creación;
- estado de publicación;
- versión del modelo.


Objetivo:


Transformar registros productivos existentes en activos digitales trazables.


---

## Creación manual de Activo Agro


Archivo:

crear_activo_agro_screen.dart


Estado:

✅ Actualizado


Incorpora:


- país;
- departamento;
- código postal;
- historial inicial;
- información económica ampliada;
- metadatos de versión.


Flujo validado:


Usuario propietario

↓

Crear Activo Agro

↓

Guardar

↓

Visualizar

↓

Publicar


---

# Evolución de módulos del Activo Agro V2


## 1. Participantes


Archivo:

participante_activo_model.dart


Estado:

🟢 Base implementada


Incorporado:


- propietario;
- usuario relacionado;
- estado de participación;
- fecha de ingreso.


Evolución pendiente:


- profesionales;
- inversores;
- permisos;
- validaciones;
- intervenciones.


Objetivo:


Representar el ecosistema humano alrededor del activo.


---

## 2. Historial


Archivo:

historial_activo_model.dart


Estado:

🟢 Base implementada


Incorporado:


- eventoId;
- tipoEvento;
- descripción;
- usuario responsable;
- fecha.


Evolución pendiente:


- eventos productivos;
- eventos económicos;
- auditorías;
- validaciones profesionales;
- eventos legales.
- eventos documentales;
- cambios de estado del activo;
- modificaciones relevantes;
- evidencias asociadas.



Objetivo:

Convertir el historial en la línea de tiempo verificable del Activo Agro.

Convertir el historial en trazabilidad completa del activo.


---

## 3. Evaluación de confianza


Archivo:

evaluacion_confianza_model.dart


Estado:

🟡 Pendiente auditoría


Analizar:


- índice;
- factores;
- puntuaciones;
- responsables;
- evidencias.


Evolución esperada:


Información

↓

Evidencia

↓

Factor de confianza

↓

Evaluación

↓

Índice de confianza del activo

La evaluación utiliza información histórica y evidencias disponibles.

No representa una recomendación financiera ni una garantía de inversión.

---

## 4. Madurez del activo


Archivo:

madurez_activo_model.dart


Estado:

🟡 Pendiente auditoría


Analizar:


- etapa productiva;
- nivel tecnológico;
- capacidad de expansión;
- preparación para inversión.


Objetivo:


Determinar el grado de desarrollo del activo.


---

# Nuevos módulos futuros

# Evolución de módulos del Activo Agro V2

## 1. Participantes

...

## 2. Historial

...

## 3. Evaluación de confianza

...

## 4. Madurez del activo

...


---

# Auditoría y Trazabilidad Agro Fields

Estado:

🟢 Arquitectura definida

🟡 Implementación progresiva


Objetivo:

Crear una capa transversal de auditoría que permita registrar la evolución completa del ecosistema Agro Fields.


La auditoría permitirá:

- registrar eventos importantes;
- identificar usuario responsable;
- conservar historial de cambios;
- asociar evidencias;
- mantener versiones de información;
- reconstruir la evolución del Activo Agro.


Integración:

La capa de Auditoría y Trazabilidad será utilizada por:

- Activos Agro;
- Producción;
- Economía;
- Documentación;
- Profesionales;
- Inversiones;
- Chat;
- Futuras integraciones.


Relación con confianza:

La confianza del ecosistema se construye mediante:

Información

+

Evidencias

+

Profesionales

+

Historial

+

Auditoría


Futuro:

Certificado de Trazabilidad Agro Fields.


Criterio:

La auditoría no reemplaza el historial del activo.

El historial representa la evolución del negocio.

La auditoría registra quién, cuándo y cómo ocurrió cada cambio.



## Marco legal internacional


Estado:

❌ Pendiente


Crear módulo para:


- jurisdicción;
- restricciones;
- tipo operación;
- superficie;
- nacionalidad inversor.


Resultado:


- permitido;
- requiere revisión profesional;
- restringido.


---

## Inteligencia Artificial


Estado:

🔜 Futuro


Aplicaciones:


- análisis documental;
- detección de inconsistencias;
- recomendaciones;
- evaluación de riesgo;
- asistencia al inversor.


Criterio:


La IA interpreta información existente.


No reemplaza validaciones profesionales.

Certificado de Trazabilidad Agro Fields
Estado:

🔜 Futuro

Objetivo:

Crear una capacidad de certificación digital basada en la historia verificable del Activo Agro.

Podrá considerar:

historial del activo;
auditorías registradas;
documentación disponible;
evidencias asociadas;
participación profesional;
evolución productiva.
Finalidad:

Demostrar que la información de un activo u operación posee un historial trazable dentro del ecosistema Agro Fields.

No representa:

certificación estatal;
garantía económica;
validación financiera.
---

# Cierre técnico Jornada 23/07/2026


Estado alcanzado:


✅ ActivoAgroV2 consolidado como entidad principal

✅ Campo convertido en Activo Agro trazable

✅ Ubicación territorial ampliada

✅ Participantes iniciales operativos

✅ Historial inicial operativo

✅ Creación manual actualizada

✅ Conversión automática actualizada

✅ Documentación técnica sincronizada


Próxima etapa:


- índice de confianza;
- evolución productiva;
- marco legal;
- red profesional;
- trazabilidad económica.

- auditoría y trazabilidad integral;
- historial de eventos del Activo Agro;
- evidencias verificables;
- seguimiento de intervenciones profesionales;
- preparación para certificaciones futuras.


---

# Regla de trabajo V8


Cada evolución debe seguir:


Modelo Dart

+

Auditoría técnica

+

Actualización documentación

+

Commit Git


---

# Próximo inicio


Continuar desde:


## 1. evaluacion_confianza_model.dart


Analizar:


- factores de confianza;
- cálculo de índice;
- evidencias;
- responsables;
- integración con historial.


---

## 2. modulo_produccion_model.dart


Analizar:


- ciclos productivos;
- historial productivo;
- capacidad futura;
- expansión;
- intervenciones técnicas.


---

## 3. madurez_activo_model.dart


Analizar:


- etapa del activo;
- preparación para inversión;
- nivel tecnológico;
- evolución del proyecto.
---

# Arquitectura Base del Ecosistema Agro Fields V8

## Estado

Iniciado - En evolución

## Objetivo

Definir y documentar los principios arquitectónicos que permitirán la evolución de Agro Fields V8 como ecosistema escalable, modular y preparado para crecimiento futuro.

## Alcance Arquitectónico

Esta línea de trabajo establece las bases para:

- Modularidad del sistema.
- Separación de responsabilidades.
- Configuración desacoplada del código.
- Internacionalización (i18n).
- Regionalización (l10n).
- Catálogos centralizados.
- Roles y permisos.
- Parámetros configurables.
- Auditoría y trazabilidad.
- Preparación para integraciones futuras.

## Criterio de implementación

La arquitectura base no modifica el alcance del MVP actual.

Su incorporación tiene como objetivo evitar decisiones estructurales que dificulten la evolución futura del ecosistema.

La implementación será progresiva acompañando el desarrollo de los módulos principales.
 ---

# Cierre Arquitectura Integral Agro Fields V8
## Jornada 24/07/2026

## Estado

✅ Arquitectura técnica integral documentada

## Objetivo alcanzado

Completar la definición arquitectónica del ecosistema Agro Fields V8 preparando la plataforma para evolución modular, escalable e integración de nuevas capacidades tecnológicas.

---

# Arquitecturas completadas

## Núcleo de plataforma

✅ Arquitectura Base del Ecosistema  
✅ Arquitectura API Backend  
✅ Arquitectura Datos y Modelo de Entidades  
✅ Arquitectura Firebase / Firestore  
✅ Arquitectura Búsqueda e Indexación  
✅ Arquitectura Escalabilidad e Infraestructura  

---

## Experiencia de usuario

✅ Arquitectura App Móvil Frontend  
✅ Arquitectura Admin Panel  
✅ Arquitectura Marketplace  

---

## Negocio

✅ Arquitectura Modelo Comercial  
✅ Arquitectura Monetización y Suscripciones  
✅ Arquitectura Cumplimiento Legal y Normativo  
✅ Arquitectura Localización e Internacionalización  

---

## Datos e inteligencia

✅ Arquitectura Analytics y Business Intelligence  
✅ Arquitectura Inteligencia Artificial y Machine Learning  
✅ Arquitectura Big Data y Data Lake  
✅ Arquitectura Gobernanza de Datos  

---

## Ecosistema Agro avanzado

✅ Arquitectura IoT y Sensores Agro  
✅ Arquitectura Digital Twin Agro  
✅ Arquitectura Blockchain y Trazabilidad Agro  

---

## Seguridad y control

✅ Arquitectura Seguridad y Privacidad  
✅ Arquitectura Auditoría y Trazabilidad  
✅ Arquitectura Notificaciones y Eventos  
✅ Arquitectura Integraciones Externas  

---

# Resultado arquitectónico

Agro Fields V8 queda definido como un ecosistema compuesto por:

Usuario

↓

Aplicaciones Agro

↓

Servicios Backend

↓

Modelo Activo Agro V2

↓

Datos Productivos

↓

IoT

↓

Digital Twin

↓

IA / Analytics

↓

Blockchain

↓

Marketplace

↓

Inversión y comercialización

---

# Estado de madurez

Antes:

Activo Agro como entidad digital productiva.

Ahora:

Activo Agro como ecosistema digital trazable, inteligente, verificable y preparado para expansión internacional.

---

# Próxima etapa V8

Inicio fase implementación:

## Prioridad 1

Evolución técnica ActivoAgroV2:

- evaluación de confianza;
- factores de confianza;
- cálculo de índice;
- evidencias verificables;
- integración historial.

## Prioridad 2

Evolución productiva:

- ciclos productivos;
- capacidad futura;
- intervenciones técnicas;
- validaciones profesionales.

## Prioridad 3

Prioridad 3

Infraestructura:

- servicios backend;
- eventos;
- auditoría y trazabilidad;
- permisos;
- integraciones.


---

# Regla V8 actualizada

Cada evolución debe mantener:

Modelo

+

Arquitectura

+

Auditoría

+

Bitácora

+

Roadmap

+

Commit Git

---

Fecha cierre arquitectura:

24/07/2026
# Cierre Arquitectura Integral Agro Fields V8

La versión V8 consolida la evolución arquitectónica del ecosistema Agro Fields estableciendo un modelo basado en capas, donde el Activo Agro V2 representa la entidad central del dominio.

Las capacidades incorporadas funcionan como módulos especializados:

- API Backend V8
  - Comunicación y exposición de servicios.

- Modelo de Datos V8
  - Núcleo de entidades y relaciones.

- Gobernanza de Datos V8
  - Calidad, seguridad y control de información.

- IoT V8
  - Captura de datos del mundo físico.

- Big Data / Data Lake V8
  - Almacenamiento y procesamiento masivo.

- Digital Twin V8
  - Representación dinámica del activo.

- IA y Machine Learning V8
  - Predicción y recomendaciones inteligentes.

- Analytics & BI V8
  - Transformación de datos en conocimiento.

- Blockchain y Trazabilidad V8
  - Certificación y verificación de eventos.

- Marketplace V8
  - Conexión comercial del ecosistema.

- Modelo Comercial V8
  - Generación futura de valor económico.

---

# Arquitectura conceptual final

Campo físico

↓

Activo Agro V2

↓

Datos + Eventos + Documentos

↓

Gobernanza y Auditoría

↓

IoT / Big Data / Digital Twin

↓

IA / Analytics

↓

Blockchain (certificación)

↓

Marketplace / Modelo Comercial

↓

Confianza del Mercado


---

# Estado del Roadmap V8

La arquitectura V8 queda definida como una base escalable preparada para:

- crecimiento internacional;
- integración de nuevos servicios;
- automatización inteligente;
- analítica avanzada;
- modelos comerciales futuros.

La implementación podrá evolucionar por fases manteniendo la separación de responsabilidades y la independencia entre capas.

---

# Principio arquitectónico final

Agro Fields V8 no se construye como una aplicación aislada.

Se define como un ecosistema digital agro donde:

Activo Agro V2 = núcleo del dominio

y las demás capacidades agregan:

- información;
- inteligencia;
- confianza;
- conectividad;
- valor económico.


# Roadmap Agro Fields

## Estado general

### Fase 1 — Núcleo del Activo Agro

- [x] Modelo ActivoAgroV2
- [x] Firestore
- [x] Serialización
- [x] CRUD
- [x] Historial
- [x] Sistema de Confianza

Estado: 100%

---

### Fase 2 — Módulos

- [ ] Producción
- [ ] Economía
- [ ] Documentación
- [ ] Participantes
- [ ] Validaciones

Estado aproximado: 40%

---

### Fase 3 — Automatización

- [ ] Historial automático
- [ ] Auditoría
- [ ] Reglas de negocio
- [ ] Eventos
- [ ] Notificaciones

---

### Fase 4 — Marketplace

- [ ] Publicación
- [ ] Búsqueda
- [ ] Ranking
- [ ] Reputación
- [ ] Compra/Venta

---

## Objetivo inmediato

Finalizar los módulos funcionales del Activo Agro.

Después comenzar el Marketplace.

# Agro Fields V8
# Roadmap de Jornada

## Fecha 28/07/2026


# Módulo

Historial y Auditoría del Activo Agro V2


---

# Objetivo de la jornada

Iniciar la evolución del sistema de trazabilidad del Activo Agro mediante eventos asociados a cambios relevantes del ecosistema.

Transformar el historial actual en una línea temporal verificable que permita reconstruir la evolución del activo.


---

# Objetivo arquitectónico

Convertir el Activo Agro en una entidad digital con memoria propia.


El activo debe poder responder:

- qué ocurrió;
- cuándo ocurrió;
- quién participó;
- qué módulo generó el cambio.


---

# Alcance de la jornada


## 1. Evolución del HistorialActivo


Archivo:

lib/models/activos/historial_activo_model.dart


Objetivo:

Implementar la primera capa de eventos del Activo Agro.


Estado esperado:

Historial capaz de registrar:


- eventoId;
- tipoEvento;
- descripción;
- usuario responsable;
- módulo origen;
- fecha.


Resultado:

Base para la trazabilidad integral futura.


---

# 2. Integración con ActivoAgroV2


Archivo:

lib/models/activos/activo_agro_model_v2.dart


Objetivo:

Incorporar historial dentro del núcleo del activo.


Acciones:


Agregar:

```dart
List<HistorialActivo> historial
## Fase: Valorización y Mercado Inteligente Agro

Objetivo:

Transformar activos registrados en oportunidades agro analizadas.

Incluye:

- motor de valorización
- comparación de activos
- ranking de oportunidades
- búsqueda avanzada
- perfiles de inversores

---

# Evolución Estratégica Agro Fields V8.X

## Nueva etapa: Inteligencia de Mercado y Valorización Agro

## Objetivo

Transformar los Activos Agro registrados en oportunidades analizadas mediante información histórica, productiva, económica y documental.

Esta evolución busca ampliar el ecosistema desde una plataforma de registro y gestión hacia una infraestructura digital de confianza para análisis agropecuario.

---

# Fase 5 — Inteligencia de Mercado Agro

## Estado

🔜 Futuro


## Objetivo

Crear capacidades para analizar activos agropecuarios utilizando información validada dentro del ecosistema.


## Capacidades futuras

### Motor de análisis de activos

Permitirá:

- comparar activos;
- analizar evolución histórica;
- identificar características productivas;
- visualizar capacidad de expansión;
- generar indicadores.


---

### Búsqueda avanzada de oportunidades

Preparada para:

- filtros productivos;
- ubicación geográfica;
- características económicas;
- tipo de actividad;
- nivel de confianza;
- estado del activo.


---

### Ranking de oportunidades

Permitirá organizar activos según:

- información disponible;
- nivel de confianza;
- características productivas;
- objetivos del inversor;
- criterios configurables.


---

### Perfiles de inversores

Preparado para:

- intereses productivos;
- ubicación;
- tipo de inversión;
- preferencias;
- objetivos.


---

# Nuevo flujo estratégico

Activo Agro V2

↓

Información Productiva

↓

Historial

↓

Auditoría

↓

Confianza

↓

Analytics

↓

Valorización Inteligente

↓

Marketplace

↓

Inversión


---

# Criterio de valorización

Agro Fields no determina:

- precio definitivo;
- rentabilidad garantizada;
- recomendación financiera.


La plataforma organiza información verificable para facilitar análisis y toma de decisiones entre participantes.


---

# Relación con el ecosistema

Esta evolución utiliza las capacidades existentes:

- Activo Agro V2;
- Historial;
- Auditoría;
- Documentación;
- Confianza;
- Producción;
- Economía;
- IA;
- Analytics;
- Marketplace.


---

# Diferenciador estratégico

Agro Fields no funciona únicamente como un marketplace agropecuario.

El diferencial es construir una memoria digital del activo que permita comprender:

- qué ocurrió;
- cuándo ocurrió;
- quién participó;
- qué evidencia existe;
- cómo evolucionó.


---

# Próxima implementación técnica

Prioridades actuales:

1. Evaluación de confianza:
   - factores;
   - evidencias;
   - responsables;
   - cálculo de índice.

2. Evolución productiva:
   - ciclos productivos;
   - historial;
   - capacidad futura;
   - expansión.

3. Auditoría integral:
   - eventos;
   - trazabilidad;
   - evidencias.

4. Inteligencia futura:
   - análisis;
   - recomendaciones;
   - comparación de activos.

---

# Regla V8

Cada evolución debe mantener:

Modelo

+

Arquitectura

+

Auditoría

+

Bitácora

+

Roadmap

+

Commit Git

---

Fase:
Evolución técnica Activo Agro V2

Módulo:
Producción

Estado:
Modelo base actualizado

Avances:
✅ identidad del módulo
✅ relación con Activo Agro V2
✅ compatibilidad Firestore

Próximos pasos:
- ciclos productivos
- historial productivo
- capacidad futura
- intervenciones técnicas
---

# Evolución Madurez Activo V8

## Módulo

Madurez del Activo Agro V2

## Estado

Modelo base actualizado.

## Avances realizados

Se incorpora una capa de evolución del activo considerando:

- porcentaje de madurez;
- faltantes identificados;
- etapa del activo;
- nivel tecnológico;
- preparación para inversión.

## Objetivo

Permitir representar el grado de evolución y organización del Activo Agro dentro del ecosistema Agro Fields V8.

## Integraciones futuras

Preparado para relacionarse con:

- Evaluación de Confianza;
- Producción;
- Analytics;
- Marketplace.

## Próximas evoluciones

- historial de madurez;
- eventos de evolución;
- indicadores avanzados.
# 🗺️ ROADMAP AGRO FIELDS

## Versión
V8.X

## Fecha de actualización
13/08/2026

## Arquitectura base
V8.0

## Principio estratégico

Agro Fields evoluciona desde una plataforma de publicación y contacto
hacia una infraestructura digital de información para Activos Agro.

El objetivo no es solamente publicar campos.

El objetivo es:

> estructurar, documentar, relacionar, validar y contextualizar
> información de activos agropecuarios reales.

---

# 1. Visión del producto

Campo real
↓
Activo Agro
↓
Información estructurada
↓
Documentación
↓
Evidencias
↓
Validaciones
↓
Confianza
↓
Oportunidad
↓
Comprador / Inversor / Productor

---

# 2. Estado actual

## 🟢 Funcional

Actualmente el sistema cuenta con:

- Activo Agro V2;
- creación y gestión de activos;
- información productiva;
- información económica;
- documentación;
- confianza inicial;
- madurez del activo;
- solicitudes de contacto;
- aceptación de solicitudes;
- creación de conversaciones;
- chat comprador ↔ propietario;
- mensajes persistidos en Firebase;
- listado de conversaciones;
- información real del activo dentro del chat;
- información real del participante;
- historial y auditoría como base arquitectónica.

---

# 3. Etapa actual — Contacto y Conversación

## Estado

🟢 Funcional / consolidación

El sistema ya permite:

Comprador
↓
Oportunidad
↓
Solicitud de contacto
↓
Propietario acepta
↓
Conversación
↓
Mensaje
↓
Respuesta

---

## Próximas tareas inmediatas

### Unicidad de conversaciones

Garantizar que no puedan existir conversaciones duplicadas para la
misma relación:

```text
campoId
+
propietarioId
+
interesadoId
---

# Evolución V8 — Suelo Activo Agro

## Estado

🟡 En evolución.

El módulo de Suelo se incorpora al Activo Agro V2 como una nueva dimensión de información y evaluación del activo.

Se mantiene la arquitectura existente.

Criterio:

No crear ActivoAgroV3.

La evolución del suelo continúa sobre ActivoAgroV2.

---

## Modelo de Suelo

Archivo:

lib/models/activos/suelo_activo_model.dart

Estado:

🟢 Modelo base implementado.

El modelo contempla:

- estado de evaluación;
- textura;
- drenaje;
- pH;
- materia orgánica;
- evidencias;
- observaciones;
- fecha de evaluación.

El modelo incorpora:

- constructor;
- estado inicial;
- deserialización desde Map;
- serialización a Map;
- conversión de Timestamp;
- copyWith.

---

## Integración con ActivoAgroV2

Archivo:

lib/models/activos/activo_agro_model_v2.dart

Estado:

🟢 Integrado.

ActivoAgroV2 incorpora:

```dart
final SueloActivo suelo;
```

La información del suelo forma parte de la estructura persistente del Activo Agro V2.

La deserialización y serialización se realizan mediante:

```dart
SueloActivo.fromMap(...)
```

y:

```dart
suelo.toMap()
```

# EVOLUCIÓN MÓDULO SUELO — CIERRE DE ETAPA

## Inicialización del Suelo

El Suelo se inicializa actualmente mediante:

`SueloActivo.inicial()`

Estado inicial:

`sin_evaluar`

Las evidencias comienzan vacías.

El objetivo es permitir que todo nuevo Activo Agro disponga desde su creación de una estructura de suelo preparada para futuras evaluaciones.

---

## Próxima evolución funcional del Suelo

### 1. Validación de serialización

Estado:

🟡 Pendiente.

Agregar pruebas específicas para validar:

`SueloActivo`
↓
`toMap`
↓
`fromMap`
↓
`SueloActivo`

Se deberá verificar la conservación de:

- estado;
- textura;
- drenaje;
- pH;
- materia orgánica;
- evidencias;
- observaciones;
- fecha de evaluación.

---

### 2. Visualización del Suelo

Estado:

🟡 Pendiente.

Integrar el módulo Suelo en:

`lib/screens/campos/detalle_activo_agro_screen.dart`

La pantalla deberá mostrar inicialmente:

- estado;
- textura;
- drenaje;
- pH;
- materia orgánica;
- cantidad de evidencias;
- observaciones;
- fecha de evaluación.

---

### 3. Actualización del Suelo

Estado:

🟡 Pendiente.

Evolucionar:

`lib/services/activo_agro_service_v2.dart`

incorporando una operación específica para actualizar el módulo Suelo.

La actualización deberá mantener la arquitectura existente de persistencia del Activo Agro.

---

### 4. Historial del Suelo

Estado:

🟡 Pendiente.

Las modificaciones del módulo deberán generar eventos dentro del historial del Activo Agro.

Evento previsto:

`actualizacion_suelo`

El historial permitirá conservar la evolución temporal de la información del suelo.

---

### 5. Auditoría del Suelo

Estado:

🟡 Pendiente.

Las modificaciones del módulo Suelo deberán registrarse mediante:

`AuditService`

utilizando:

`modulo: suelo`

y una acción específica para la actualización del módulo.

La auditoría deberá conservar:

- activo afectado;
- usuario responsable;
- acción;
- referencia;
- datos relevantes de la modificación.

---

### 6. Evaluación del Suelo

Estado:

🟡 Pendiente.

Se deberá implementar posteriormente un flujo de evaluación del suelo que permita registrar:

- características físicas;
- condiciones de drenaje;
- pH;
- materia orgánica;
- observaciones;
- evidencias;
- fecha de evaluación.

Flujo previsto:

Detalle Activo Agro
↓
Evaluación de Suelo
↓
SueloActivo
↓
ActivoAgroServiceV2
↓
Firestore
↓
Historial
↓
Auditoría

---

## Relación futura entre Suelo, Confianza y Madurez

Estado:

⚪ Posterior.

En esta etapa el módulo Suelo se considera una dimensión independiente de información y evaluación del Activo Agro.

No se incorpora todavía al cálculo automático de:

- Confianza;
- Madurez;
- rentabilidad;
- publicación.

Antes de establecer dicha relación deberá definirse:

- metodología de evaluación;
- criterios agronómicos;
- evidencia requerida;
- responsables de validación;
- niveles de confianza;
- impacto sobre la madurez del activo.

Criterio arquitectónico:

No establecer dependencias entre Suelo, Confianza y Madurez hasta contar con una definición funcional y metodológica suficiente.

---

## Criterio de continuidad V8

La evolución del módulo Suelo continuará sobre:

`ActivoAgroV2`

sin crear una nueva versión estructural del modelo.

La prioridad inmediata será cerrar el circuito:

Modelo
↓
Serialización
↓
Visualización
↓
Actualización
↓
Historial
↓
Auditoría
↓
Evaluación

Una vez cerrado este circuito se evaluará la integración del Suelo con las capas superiores de Confianza y Madurez.

---

## Próxima jornada técnica

Prioridad:

1. cerrar test de serialización de Suelo;
2. integrar visualización en `DetalleActivoAgroScreen`;
3. implementar actualización del Suelo;
4. incorporar historial;
5. incorporar auditoría;
6. implementar evaluación;
7. ejecutar pruebas;
8. documentar resultados en `BITACORA.md`.

Estado de cierre:

🟡 Módulo Suelo incorporado arquitectónicamente y pendiente de completar su circuito funcional.

---

# CIERRE DE JORNADA — MÓDULO SUELO

El módulo Suelo queda formalmente incorporado a la arquitectura del Activo Agro V2.

La estructura de datos, integración con `ActivoAgroV2`, inicialización y persistencia base se encuentran implementadas.

La evolución funcional queda deliberadamente pendiente de la siguiente etapa, manteniendo separación entre:

- información del suelo;
- evaluación agronómica;
- confianza;
- madurez;
- publicación.

No se crea una nueva versión del modelo.

La continuidad del desarrollo se realizará sobre `ActivoAgroV2`, respetando la arquitectura V8, la trazabilidad mediante Git, el historial del activo y la auditoría transversal.

Estado general:

🟡 **Módulo Suelo incorporado arquitectónicamente — circuito funcional pendiente.**
# Paso 9 — Validación de OportunidadAgroService

## Estado

🟢 VALIDADO

## Fecha

03/09/2026

## Validación realizada

Se validó mediante Integration Test la integración real entre:

`ActivoAgroV2`

↓

`OportunidadAgro`

↓

`OportunidadAgroService`

↓

`Firestore Emulator`

↓

`Auditoría`

## Capacidades verificadas

- creación de Activo Agro V2;
- persistencia del Activo Agro;
- recuperación del Activo Agro;
- creación de OportunidadAgro vinculada;
- persistencia de la oportunidad;
- recuperación por ID;
- consulta de oportunidades por Activo Agro;
- consulta de oportunidades activas;
- generación de auditoría;
- trazabilidad de usuario y referencia;
- rechazo de oportunidades vinculadas a activos inexistentes.

## Evidencia

Test:

`integration_test/oportunidad_agro_service_integration_test.dart`

Resultado:

`All tests passed!`

## Arquitectura

La implementación continúa sobre `ActivoAgroV2`.

No se crea `ActivoAgroV3`.

Se mantiene:

`Screen → Service → Model → Firebase`

con auditoría transversal.

## Próxima etapa

Consolidar el cierre del Paso 9 mediante:

- actualización de documentación;
- actualización de BITÁCORA;
- commit;
- push;
- verificación de working tree limpio.

Una vez completado el versionado, iniciar la planificación del Paso 10 sin modificar innecesariamente las capas ya validadas.
# Principios rectores de experiencia Agro Fields

## 1. Experiencia adaptativa

Responsive no alcanza.

Agro Fields debe adaptar la experiencia al contexto de uso, manteniendo la misma plataforma, información, arquitectura, modelos, servicios y lógica de negocio.

---

## 2. Complejidad detrás de escena

La complejidad queda en el sistema, no en la pantalla.

El usuario debe poder realizar acciones simples sin tener que comprender la complejidad interna de Agro Fields.

---

## 3. Registro inmediato y estructuración automática

Registrar en el momento, con el mínimo esfuerzo; estructurar automáticamente detrás.

Principio operativo:

> Lo veo → lo registro → Agro Fields lo organiza.
# Paso 11 — Inversiones

## Estado

🟢 **VALIDACIÓN TÉCNICA COMPLETADA**

## Fecha

07/09/2026

## Objetivo

Validar el registro de inversiones y la actualización del monto recaudado de una publicación de inversión mediante una transacción Firestore.

## Implementación validada

Archivo:

`lib/services/inversion_service.dart`

La operación:

`InversionService.crearInversion()`

utiliza una transacción Firestore para mantener coordinadas las siguientes operaciones:

1. verificar la existencia de la publicación de inversión;
2. obtener `montoRecaudado`;
3. calcular el nuevo monto recaudado;
4. registrar la inversión;
5. actualizar `montoRecaudado`.

## Test de integración

Archivo:

`integration_test/inversion_service_integration_test.dart`

Se validó mediante:

`Android Emulator`

`emulator-5554`

con:

`Firestore Emulator`

Host desde Android:

`10.0.2.2`

Puerto:

`8080`

Comando:

`flutter test integration_test/inversion_service_integration_test.dart -d emulator-5554`

Resultado:

`All tests passed!`

También se ejecutó:

`flutter analyze integration_test/inversion_service_integration_test.dart`

Resultado:

`No issues found!`

## Caso validado

Monto recaudado inicial:

`25000.0`

Inversión:

`15000.0`

Monto recaudado final:

`40000.0`

Resultado:

`25000.0 + 15000.0 = 40000.0`

## Arquitectura

Se mantiene:

`Screen → Service → Model → Firebase`

No se crea `ActivoAgroV3`.

La evolución continúa sobre la arquitectura V8 existente.

## Próximo paso

Completar el cierre formal del Paso 11 mediante:

* actualización de `BITACORA.md`;
* actualización de `ROADMAP_V8.md`;
* revisión de cambios;
* commit;
* push a `origin/main`;
* verificación de working tree limpio y rama sincronizada.

El Paso 11 no se considerará formalmente cerrado hasta completar el versionado y publicación.

---

## Regla de cierre

Primero validar.

Después documentar.

Después versionar.

No acelerar etapas.

No crear V3.

Mantener la arquitectura V8.

---

# PASO 11 — INVERSIONES — CIERRE FORMAL

## Fecha

07/09/2026

## Estado

🟢 **CERRADO**

La validación técnica de `InversionService.crearInversion()` fue completada mediante Integration Test con Android Emulator y Firestore Emulator.

Resultado:

`All tests passed!`

También se validó:

`flutter analyze integration_test/inversion_service_integration_test.dart`

Resultado:

`No issues found!`

Caso validado:

`25000.0 + 15000.0 = 40000.0`

Commit:

`805a279 feat: validar paso 11 inversiones`

El commit fue publicado en `origin/main`.

Por lo tanto:

**Paso 11 — INVERSIONES: CERRADO.**

---

# PASO 12 — EXPEDIENTE DIGITAL PERMANENTE DEL ACTIVO AGRO

## Fecha de inicio

07/09/2026

## Estado

🟢 **12.1–12.7 CERRADOS CONCEPTUAL Y DOCUMENTALMENTE**

## Objetivo

Definir el Expediente Digital Permanente como la memoria digital histórica y trazable del Activo Agro.

La arquitectura mantiene:

`ActivoAgroV2`

↓

`Expediente Digital Permanente`

↓

`Datos + Historial + Evidencias`

↓

`Auditoría`

↓

`Confianza`

↓

`Publicación / Evaluación`

El expediente se define como una composición lógica de las capacidades existentes y no como un nuevo modelo duplicado.

Criterio:

**No crear `ActivoAgroV3`.**

---

# Paso 12.1 — Auditoría de arquitectura actual

Estado:

🟢 **CERRADO**

Se revisaron los modelos, servicios y capas existentes relacionados con el Activo Agro.

Se confirmó la existencia de:

- `ActivoAgroV2`;
- `HistorialActivo`;
- `AuditEvent`;
- `DocumentacionActivo`;
- `ConfianzaActivo`;
- `EvaluacionConfianza`;
- `MadurezActivo`;
- `ParticipanteActivo`;
- `SueloActivo`.

Conclusión:

La base actual permite evolucionar el Expediente Digital Permanente sin crear una entidad estructural duplicada.

---

# Paso 12.2 — Master Plan ↔ Arquitectura V8 ↔ Código real

Estado:

🟢 **CERRADO**

La arquitectura conceptual fue contrastada con la implementación real.

Se identificaron como áreas futuras de evolución:

- validez;
- fuentes;
- evidencias;
- verificaciones;
- temporalidad;
- metadatos documentales;
- profundidad de auditoría.

No se modificó código durante esta etapa.

---

# Paso 12.3 — Expediente Digital Permanente

Estado:

🟢 **CERRADO**

El Expediente Digital Permanente representa la memoria continua del Activo Agro.

Debe permitir reconstruir:

- información;
- fechas;
- participantes;
- evidencias;
- modificaciones;
- estados;
- evaluaciones;
- evolución.

No reemplaza a `ActivoAgroV2`, HistorialActivo ni AuditEvent.

---

# Paso 12.4 — Ciclo de vida

Estado:

🟢 **CERRADO CONCEPTUALMENTE**

Se mantiene la separación entre:

- estado del Activo;
- estado de publicación;
- confianza/verificación;
- flujo comercial.

Estados actualmente utilizados en código:

- `borrador`;
- `publicado`;
- `pausado`.

Los restantes estados del enum requieren definición funcional antes de considerarse transiciones implementadas.

El archivado no elimina el expediente permanente.

---

# Paso 12.5 — Historial y Auditoría

Estado:

🟢 **CERRADO CONCEPTUALMENTE**

Criterio:

**Historial = evolución significativa del Activo.**

**Auditoría = trazabilidad de la acción.**

Los acontecimientos relevantes pueden generar ambos registros.

Se establece trazabilidad profunda para cambios relevantes, evitando registrar indiscriminadamente toda actividad técnica de la aplicación.

---

# Paso 12.6 — Validez de los datos

Estado:

🟢 **CERRADO CONCEPTUALMENTE**

Estados definidos:

- 🟢 `vigente_verificado`
- 🟡 `vigente_informado`
- 🟠 `requiere_actualizacion`
- 🔴 `desactualizado`
- ⚪ `sin_informacion`

Principio:

**Validez ≠ Confianza**

La actualización de un registro no implica automáticamente que el dato sea vigente.

Los hechos históricos mantienen su contexto temporal.

No se agregan todavía campos genéricos de validez directamente a `ActivoAgroV2`.

---

# Paso 12.7 — Documentación

Estado:

🟢 **CERRADO**

Se actualizan:

- `docs/BITACORA.md`;
- `docs/ROADMAP_V8.md`.

La documentación consolida las decisiones arquitectónicas del Paso 12 y el cierre formal del Paso 11.

No se modifica código.

---

# Decisiones arquitectónicas consolidadas

- `ActivoAgroV2` continúa como identidad permanente.
- No crear `ActivoAgroV3`.
- Expediente Digital Permanente como composición lógica.
- Publicación comercial separada del expediente.
- Historial y Auditoría como capas complementarias.
- Validez separada de Confianza.
- No duplicar modelos sin necesidad demostrada.
- Identificar el GAP antes de modificar código.

---

# Paso 12.8 — GAP Arquitectura ↔ Código

## Estado

🟡 **PRÓXIMO PASO**

Objetivo:

Determinar qué modificaciones mínimas son realmente necesarias para llevar las decisiones arquitectónicas del Expediente Digital Permanente al código existente.

La revisión deberá cubrir:

- `ActivoAgroV2`;
- `HistorialActivo`;
- `AuditEvent`;
- `DocumentacionActivo`;
- `ConfianzaActivo`;
- `EvaluacionConfianza`;
- `MadurezActivo`;
- `ParticipanteActivo`;
- `SueloActivo`;
- servicios relacionados.

Regla:

**Identificar GAP → definir solución → modificar código → probar → validar → documentar → versionar.**

No modificar código antes de cerrar el análisis del GAP.

No crear V3.

Mantener arquitectura V8.

---

# Estado general del Roadmap

🟢 Paso 9 — OportunidadAgroService: CERRADO

🟢 Paso 11 — Inversiones: CERRADO

🟢 Paso 12.1 — Auditoría arquitectónica: CERRADO

🟢 Paso 12.2 — Matriz Master Plan ↔ Arquitectura ↔ Código: CERRADO

🟢 Paso 12.3 — Expediente Digital Permanente: CERRADO

🟢 Paso 12.4 — Ciclo de vida: CERRADO CONCEPTUALMENTE

🟢 Paso 12.5 — Historial y Auditoría: CERRADO CONCEPTUALMENTE

🟢 Paso 12.6 — Validez de datos: CERRADO CONCEPTUALMENTE

🟢 Paso 12.7 — Documentación: CERRADO

🟡 Paso 12.8 — GAP Arquitectura ↔ Código: PRÓXIMO

---

# Regla V8

Cada evolución debe mantener:

`Modelo`

+

`Arquitectura`

+

`Auditoría`

+

`Bitácora`

+

`Roadmap`

+

`Pruebas`

+

`Validación`

+

`Commit Git`

## PASO 12.8 — Auditoría GAP y cierre arquitectónico

### Estado

**CERRADO ARQUITECTÓNICAMENTE**

Se completó la auditoría del código real relacionada con el Expediente Digital Permanente del Activo Agro.

### Componentes auditados

* `ActivoAgroV2`
* `HistorialActivo`
* `AuditEvent`
* `AuditService`
* `AuditType`
* `DocumentacionActivo`
* Producción y ciclos productivos
* Economía
* Participantes
* Confianza
* Evaluación de confianza
* Factores de confianza
* Madurez
* Servicio de confianza

Se verificó además la existencia de infraestructura transversal para Evidencia, Documento, Verificación y Fuente.

### Resultado

No existe actualmente una entidad transversal formal de Evidencia.

Los modelos actuales contienen referencias simples a evidencias, archivos, fuentes o declaraciones, pero no una estructura común para conectar:

**Dato → Evidencia → Verificación → Validez → Confianza**

### GAP confirmados

* **GAP-EVID-01:** falta entidad transversal de Evidencia.
* **GAP-DOC-01:** documentación basada en listas simples.
* **GAP-PROD-01:** producción sin respaldo estructurado transversal.
* **GAP-ECON-01:** economía sin evidencia estructurada.
* **GAP-PART-01:** participación sin registro estructurado de contribución, manteniendo acciones en historial/auditoría.
* **GAP-VAL-01:** falta representación transversal de Validez.
* **GAP-TRACE-01:** falta normalización documental del uso de old/new en cambios relevantes.
* **GAP-AUD-01:** consulta de auditoría puede evolucionar para ordenar explícitamente por fecha.
* **GAP-MAD-01:** algoritmo de madurez requiere futura revisión.
* **GAP-CONF-01:** confianza reconoce evidencias conceptualmente, pero todavía no dispone de una capa real de evidencia.

### Decisiones arquitectónicas

* Mantener `ActivoAgroV2`.
* No crear `ActivoAgroV3`.
* No crear un `ExpedienteDigitalPermanenteModel`.
* El Expediente Digital Permanente será una composición lógica del Activo y sus capas de información, memoria y trazabilidad.
* Crear posteriormente una única capa transversal de Evidencia.
* Mantener separadas Evidencia, Verificación, Validez, Confianza, Historial y Auditoría.
* Evolucionar los módulos existentes en lugar de duplicarlos.
* No crear modelos de evidencia específicos por módulo.

### Estado conceptual del Expediente

```text
ActivoAgroV2
      │
      ├── Datos
      ├── Documentación
      ├── Producción
      ├── Economía
      ├── Participantes
      │
      ├── Evidencias
      │       ↓
      │   Verificación
      │       ↓
      │     Validez
      │
      ├── Historial
      ├── Auditoría
      ├── Confianza
      └── Madurez
```

### Próximo paso

**PASO 13 — Diseño técnico de Evidencia**

Orden previsto:

1. Definir modelo conceptual final.
2. Definir campos.
3. Definir relaciones.
4. Definir tipos de evidencia.
5. Definir verificación.
6. Definir validez.
7. Definir persistencia.
8. Definir servicio.
9. Definir integración con módulos.
10. Definir auditoría.
11. Crear tests.
12. Implementar.
13. Validar con Firestore Emulator.
14. Documentar.
15. Commit.
16. Push.

**Regla:** no implementar hasta cerrar el diseño técnico.

# PASO 12.9 — Matriz Ficha Maestra V1.0 ↔ Arquitectura V8 ↔ Código real

## Estado

🟢 **CERRADO — VALIDADO TÉCNICAMENTE**

## Objetivo

Traducir la Ficha Maestra del Activo Agro V1 a la arquitectura existente de Agro Fields, verificando qué información ya existe, qué capacidades requieren evolución y cuáles son los GAP concretos que deben resolverse sin duplicar modelos.

## Principio

**No agregar campos ni crear modelos nuevos hasta comprobar si la información ya existe en la arquitectura actual.**

La referencia funcional es la Ficha Maestra.

La referencia técnica es la arquitectura V8 y el código real existente.

## Resultado

La matriz confirmó que el Expediente Digital Permanente puede evolucionar sobre `ActivoAgroV2`, utilizando los módulos existentes y una capa transversal de `Evidencia`.

Se mantiene la decisión:

**No crear `ActivoAgroV3`.**

No se crea un modelo `ExpedienteDigitalPermanente`.

## Evidencia transversal

Durante la implementación posterior al GAP arquitectónico se confirmó que ya existía el modelo:

`Evidencia`

y se implementó:

`EvidenciaService`

La evidencia queda como capa transversal y no como modelos específicos por módulo.

No se crearán:

* `EvidenciaSuelo`;
* `EvidenciaProduccion`;
* `EvidenciaEconomia`.

## Validación de suelo

Se integró evidencia al flujo de actualización de `SueloActivo`.

Flujo validado:

`Dato de suelo`
→ `Evidencia`
→ `HistorialActivo`
→ `AuditEvent`
→ `Firestore Emulator`

La integración fue validada mediante test de integración con Android Emulator + Firestore Emulator.

Resultado:

**All tests passed!**

## Validación de producción y ciclo productivo

Se integró evidencia al registro de `CicloProductivo`.

Flujo validado:

`CicloProductivo`
→ `Evidencia`
→ `HistorialActivo`
→ `AuditEvent`
→ `Firestore Emulator`

La integración fue validada mediante test de integración con Android Emulator + Firestore Emulator.

Resultado:

**All tests passed!**

## GAP-PROD-ID-01 — Identidad estable del módulo de producción

Durante la validación de producción se detectó un GAP adicional:

`ModuloProduccion.id` es actualmente opcional y existen rutas de creación que no establecen necesariamente un identificador estable del módulo.

Esto dificulta garantizar una referencia inequívoca entre:

`ActivoAgroV2`
→ `ModuloProduccion`
→ `CicloProductivo`
→ `Evidencia`

### Decisión

**No modificar todavía el modelo ni las rutas de creación.**

El GAP queda documentado como pendiente técnico para una evolución posterior.

Antes de resolverlo deberán auditarse todas las rutas de creación y persistencia de `ModuloProduccion`.

## Estado de GAP

| GAP               | Estado                    |
| ----------------- | ------------------------- |
| GAP-EVID-01       | 🟢 Resuelto en capa base  |
| GAP-SUELO-EVID-01 | 🟢 Resuelto y validado    |
| GAP-PROD-01       | 🟢 Resuelto y validado    |
| GAP-PROD-ID-01    | 🟡 Pendiente              |
| GAP-DOC-01        | 🟡 Pendiente              |
| GAP-ECON-01       | 🟡 Pendiente              |
| GAP-PART-01       | 🟢 Mantener modelo actual |
| GAP-VAL-01        | 🟡 Pendiente              |
| GAP-TRACE-01      | 🟡 Pendiente              |
| GAP-AUD-01        | 🟡 Mejora futura          |
| GAP-MAD-01        | 🟡 Mejora futura          |
| GAP-CONF-01       | 🟡 Integración futura     |

## Regla de continuidad

Los nuevos GAP detectados durante la implementación deberán documentarse antes de modificarse.

Secuencia:

`GAP → decisión → implementación → test → validación → documentación → commit`

## Próximo paso

Continuar con la revisión de los GAP pendientes de la matriz, priorizando aquellos que impacten directamente en la Ficha Maestra y en la trazabilidad histórica del Activo Agro.

**GAP-PROD-ID-01 queda pendiente y no se implementa en este paso.**
