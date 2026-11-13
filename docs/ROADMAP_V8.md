# ROADMAP AGRO FIELDS V8

## Estado del proyecto

Proyecto:

Agro Fields


Arquitectura:

V8.0


Ãšltimo cierre tÃ©cnico:

23/07/2026


Ãšltimo commit:

ef874cb


Objetivo:

Continuar la evoluciÃ³n del ecosistema Agro Fields manteniendo:

- compatibilidad del modelo existente;
- trazabilidad mediante Git;
- documentaciÃ³n tÃ©cnica;
- auditorÃ­a de cambios;
- evoluciÃ³n modular.


---

# MÃ³dulo principal

## ActivoAgroV2


Archivo:

lib/models/activos/activo_agro_model_v2.dart


Estado:

âœ… Base arquitectÃ³nica implementada


Contiene:

- identidad;
- clasificaciÃ³n;
- ubicaciÃ³n;
- producciÃ³n;
- economÃ­a;
- documentaciÃ³n;
- confianza;
- evaluaciÃ³n;
- madurez;
- participantes;
- historial;
- auditorÃ­a.

La auditorÃ­a forma parte de la trazabilidad integral del Activo Agro.

Su objetivo es conservar la historicidad del activo mediante el registro de eventos relevantes, participantes, modificaciones y evidencias asociadas.

No reemplaza el historial del activo.

Lo complementa permitiendo reconstruir la evoluciÃ³n completa de la entidad digital productiva.

Criterio definido:

No crear ActivoAgroV3.


Continuar evoluciÃ³n sobre ActivoAgroV2.


---

# ActualizaciÃ³n 23/07/2026


ActivoAgroV2 incorpora evoluciÃ³n inicial de:


- ubicaciÃ³n territorial avanzada;
- participantes;
- historial;
- versiÃ³n del modelo;
- trazabilidad de creaciÃ³n;
- relaciÃ³n Campo â†’ Activo Agro.


Objetivo:


Transformar el Activo Agro desde una publicaciÃ³n hacia una entidad digital productiva trazable.


---

# AuditorÃ­as completadas


## EconomÃ­a


Archivo:

economia_activo_model.dart


Estado:

âœ… Auditado y evolucionado


Incorporado:

- objetivo del proyecto;
- etapa del proyecto;
- inversiÃ³n esperada;
- capacidad actual;
- capacidad proyectada;
- riesgos;
- origen informaciÃ³n;
- responsable declaraciÃ³n.


Objetivo futuro:

Relacionar producciÃ³n, inversiÃ³n y expansiÃ³n del activo.


---

## UbicaciÃ³n


Archivo:

ubicacion_activo_model.dart


Estado:

âœ… Auditado y evolucionado


Incorporado:


JerarquÃ­a territorial:


PaÃ­s

â†“

Provincia / Estado

â†“

Departamento

â†“

Municipio / Localidad


Objetivo:


Preparar:

- anÃ¡lisis legal;
- restricciones territoriales;
- expansiÃ³n internacional;
- evaluaciÃ³n por jurisdicciÃ³n.


---

## ProducciÃ³n


Archivo:

modulo_produccion_model.dart


Estado:

âœ… Auditado


Base existente:


- dominio;
- actividad;
- descripciÃ³n;
- superficie;
- unidad;
- datos.


EvoluciÃ³n pendiente:


- ciclos productivos;
- historial;
- capacidad futura;
- expansiÃ³n;
- validaciÃ³n profesional.


---

## Confianza


Archivo:

confianza_activo_model.dart


Estado:

âœ… Auditado


Base existente:


- nivel general;
- identidad;
- documentaciÃ³n;
- evidencias;
- informaciÃ³n productiva;
- participantes;
- observaciones.


EvoluciÃ³n pendiente:


EvoluciÃ³n pendiente:

- factores oficiales;
- cÃ¡lculo multidimensional;
- evidencias asociadas;
- responsables de validaciÃ³n;
- profesionales participantes;
- auditorÃ­as;
- historial de verificaciones.

Criterio:

El Ãndice de Confianza no determina rentabilidad ni garantiza resultados econÃ³micos.

EvalÃºa el nivel de informaciÃ³n, respaldo, trazabilidad e historial disponible sobre un Activo Agro.



---

## DocumentaciÃ³n


Archivo:

documentacion_activo_model.dart


Estado:

âœ… Auditado


Base existente:


- documentos;
- certificaciones;
- permisos;
- archivos;
- observaciones.


EvoluciÃ³n pendiente:


- metadata documental;
- vencimientos;
- validaciÃ³n profesional;
- evidencia verificable;
- trazabilidad documental.


---

## Servicio


Archivo:

activo_agro_service_v2.dart


Estado:

âœ… Revisado


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


EvoluciÃ³n futura:


- generaciÃ³n automÃ¡tica de historial;
- control de permisos;
- auditorÃ­a de modificaciones;
- eventos profesionales.


---

# EvoluciÃ³n Jornada 23/07/2026


## ConversiÃ³n Campo â†’ Activo Agro


Archivo:

campo_to_activo_service.dart


Estado:

âœ… Evolucionado


Incorpora:


- ubicaciÃ³n completa;
- economÃ­a inicial;
- propietario como participante;
- historial de creaciÃ³n;
- estado de publicaciÃ³n;
- versiÃ³n del modelo.


Objetivo:


Transformar registros productivos existentes en activos digitales trazables.


---

## CreaciÃ³n manual de Activo Agro


Archivo:

crear_activo_agro_screen.dart


Estado:

âœ… Actualizado


Incorpora:


- paÃ­s;
- departamento;
- cÃ³digo postal;
- historial inicial;
- informaciÃ³n econÃ³mica ampliada;
- metadatos de versiÃ³n.


Flujo validado:


Usuario propietario

â†“

Crear Activo Agro

â†“

Guardar

â†“

Visualizar

â†“

Publicar


---

# EvoluciÃ³n de mÃ³dulos del Activo Agro V2


## 1. Participantes


Archivo:

participante_activo_model.dart


Estado:

ðŸŸ¢ Base implementada


Incorporado:


- propietario;
- usuario relacionado;
- estado de participaciÃ³n;
- fecha de ingreso.


EvoluciÃ³n pendiente:


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

ðŸŸ¢ Base implementada


Incorporado:


- eventoId;
- tipoEvento;
- descripciÃ³n;
- usuario responsable;
- fecha.


EvoluciÃ³n pendiente:


- eventos productivos;
- eventos econÃ³micos;
- auditorÃ­as;
- validaciones profesionales;
- eventos legales.
- eventos documentales;
- cambios de estado del activo;
- modificaciones relevantes;
- evidencias asociadas.



Objetivo:

Convertir el historial en la lÃ­nea de tiempo verificable del Activo Agro.

Convertir el historial en trazabilidad completa del activo.


---

## 3. EvaluaciÃ³n de confianza


Archivo:

evaluacion_confianza_model.dart


Estado:

ðŸŸ¡ Pendiente auditorÃ­a


Analizar:


- Ã­ndice;
- factores;
- puntuaciones;
- responsables;
- evidencias.


EvoluciÃ³n esperada:


InformaciÃ³n

â†“

Evidencia

â†“

Factor de confianza

â†“

EvaluaciÃ³n

â†“

Ãndice de confianza del activo

La evaluaciÃ³n utiliza informaciÃ³n histÃ³rica y evidencias disponibles.

No representa una recomendaciÃ³n financiera ni una garantÃ­a de inversiÃ³n.

---

## 4. Madurez del activo


Archivo:

madurez_activo_model.dart


Estado:

ðŸŸ¡ Pendiente auditorÃ­a


Analizar:


- etapa productiva;
- nivel tecnolÃ³gico;
- capacidad de expansiÃ³n;
- preparaciÃ³n para inversiÃ³n.


Objetivo:


Determinar el grado de desarrollo del activo.


---

# Nuevos mÃ³dulos futuros

# EvoluciÃ³n de mÃ³dulos del Activo Agro V2

## 1. Participantes

...

## 2. Historial

...

## 3. EvaluaciÃ³n de confianza

...

## 4. Madurez del activo

...


---

# AuditorÃ­a y Trazabilidad Agro Fields

Estado:

ðŸŸ¢ Arquitectura definida

ðŸŸ¡ ImplementaciÃ³n progresiva


Objetivo:

Crear una capa transversal de auditorÃ­a que permita registrar la evoluciÃ³n completa del ecosistema Agro Fields.


La auditorÃ­a permitirÃ¡:

- registrar eventos importantes;
- identificar usuario responsable;
- conservar historial de cambios;
- asociar evidencias;
- mantener versiones de informaciÃ³n;
- reconstruir la evoluciÃ³n del Activo Agro.


IntegraciÃ³n:

La capa de AuditorÃ­a y Trazabilidad serÃ¡ utilizada por:

- Activos Agro;
- ProducciÃ³n;
- EconomÃ­a;
- DocumentaciÃ³n;
- Profesionales;
- Inversiones;
- Chat;
- Futuras integraciones.


RelaciÃ³n con confianza:

La confianza del ecosistema se construye mediante:

InformaciÃ³n

+

Evidencias

+

Profesionales

+

Historial

+

AuditorÃ­a


Futuro:

Certificado de Trazabilidad Agro Fields.


Criterio:

La auditorÃ­a no reemplaza el historial del activo.

El historial representa la evoluciÃ³n del negocio.

La auditorÃ­a registra quiÃ©n, cuÃ¡ndo y cÃ³mo ocurriÃ³ cada cambio.



## Marco legal internacional


Estado:

âŒ Pendiente


Crear mÃ³dulo para:


- jurisdicciÃ³n;
- restricciones;
- tipo operaciÃ³n;
- superficie;
- nacionalidad inversor.


Resultado:


- permitido;
- requiere revisiÃ³n profesional;
- restringido.


---

## Inteligencia Artificial


Estado:

ðŸ”œ Futuro


Aplicaciones:


- anÃ¡lisis documental;
- detecciÃ³n de inconsistencias;
- recomendaciones;
- evaluaciÃ³n de riesgo;
- asistencia al inversor.


Criterio:


La IA interpreta informaciÃ³n existente.


No reemplaza validaciones profesionales.

Certificado de Trazabilidad Agro Fields
Estado:

ðŸ”œ Futuro

Objetivo:

Crear una capacidad de certificaciÃ³n digital basada en la historia verificable del Activo Agro.

PodrÃ¡ considerar:

historial del activo;
auditorÃ­as registradas;
documentaciÃ³n disponible;
evidencias asociadas;
participaciÃ³n profesional;
evoluciÃ³n productiva.
Finalidad:

Demostrar que la informaciÃ³n de un activo u operaciÃ³n posee un historial trazable dentro del ecosistema Agro Fields.

No representa:

certificaciÃ³n estatal;
garantÃ­a econÃ³mica;
validaciÃ³n financiera.
---

# Cierre tÃ©cnico Jornada 23/07/2026


Estado alcanzado:


âœ… ActivoAgroV2 consolidado como entidad principal

âœ… Campo convertido en Activo Agro trazable

âœ… UbicaciÃ³n territorial ampliada

âœ… Participantes iniciales operativos

âœ… Historial inicial operativo

âœ… CreaciÃ³n manual actualizada

âœ… ConversiÃ³n automÃ¡tica actualizada

âœ… DocumentaciÃ³n tÃ©cnica sincronizada


PrÃ³xima etapa:


- Ã­ndice de confianza;
- evoluciÃ³n productiva;
- marco legal;
- red profesional;
- trazabilidad econÃ³mica.

- auditorÃ­a y trazabilidad integral;
- historial de eventos del Activo Agro;
- evidencias verificables;
- seguimiento de intervenciones profesionales;
- preparaciÃ³n para certificaciones futuras.


---

# Regla de trabajo V8


Cada evoluciÃ³n debe seguir:


Modelo Dart

+

AuditorÃ­a tÃ©cnica

+

ActualizaciÃ³n documentaciÃ³n

+

Commit Git


---

# PrÃ³ximo inicio


Continuar desde:


## 1. evaluacion_confianza_model.dart


Analizar:


- factores de confianza;
- cÃ¡lculo de Ã­ndice;
- evidencias;
- responsables;
- integraciÃ³n con historial.


---

## 2. modulo_produccion_model.dart


Analizar:


- ciclos productivos;
- historial productivo;
- capacidad futura;
- expansiÃ³n;
- intervenciones tÃ©cnicas.


---

## 3. madurez_activo_model.dart


Analizar:


- etapa del activo;
- preparaciÃ³n para inversiÃ³n;
- nivel tecnolÃ³gico;
- evoluciÃ³n del proyecto.
---

# Arquitectura Base del Ecosistema Agro Fields V8

## Estado

Iniciado - En evoluciÃ³n

## Objetivo

Definir y documentar los principios arquitectÃ³nicos que permitirÃ¡n la evoluciÃ³n de Agro Fields V8 como ecosistema escalable, modular y preparado para crecimiento futuro.

## Alcance ArquitectÃ³nico

Esta lÃ­nea de trabajo establece las bases para:

- Modularidad del sistema.
- SeparaciÃ³n de responsabilidades.
- ConfiguraciÃ³n desacoplada del cÃ³digo.
- InternacionalizaciÃ³n (i18n).
- RegionalizaciÃ³n (l10n).
- CatÃ¡logos centralizados.
- Roles y permisos.
- ParÃ¡metros configurables.
- AuditorÃ­a y trazabilidad.
- PreparaciÃ³n para integraciones futuras.

## Criterio de implementaciÃ³n

La arquitectura base no modifica el alcance del MVP actual.

Su incorporaciÃ³n tiene como objetivo evitar decisiones estructurales que dificulten la evoluciÃ³n futura del ecosistema.

La implementaciÃ³n serÃ¡ progresiva acompaÃ±ando el desarrollo de los mÃ³dulos principales.
 ---

# Cierre Arquitectura Integral Agro Fields V8
## Jornada 24/07/2026

## Estado

âœ… Arquitectura tÃ©cnica integral documentada

## Objetivo alcanzado

Completar la definiciÃ³n arquitectÃ³nica del ecosistema Agro Fields V8 preparando la plataforma para evoluciÃ³n modular, escalable e integraciÃ³n de nuevas capacidades tecnolÃ³gicas.

---

# Arquitecturas completadas

## NÃºcleo de plataforma

âœ… Arquitectura Base del Ecosistema  
âœ… Arquitectura API Backend  
âœ… Arquitectura Datos y Modelo de Entidades  
âœ… Arquitectura Firebase / Firestore  
âœ… Arquitectura BÃºsqueda e IndexaciÃ³n  
âœ… Arquitectura Escalabilidad e Infraestructura  

---

## Experiencia de usuario

âœ… Arquitectura App MÃ³vil Frontend  
âœ… Arquitectura Admin Panel  
âœ… Arquitectura Marketplace  

---

## Negocio

âœ… Arquitectura Modelo Comercial  
âœ… Arquitectura MonetizaciÃ³n y Suscripciones  
âœ… Arquitectura Cumplimiento Legal y Normativo  
âœ… Arquitectura LocalizaciÃ³n e InternacionalizaciÃ³n  

---

## Datos e inteligencia

âœ… Arquitectura Analytics y Business Intelligence  
âœ… Arquitectura Inteligencia Artificial y Machine Learning  
âœ… Arquitectura Big Data y Data Lake  
âœ… Arquitectura Gobernanza de Datos  

---

## Ecosistema Agro avanzado

âœ… Arquitectura IoT y Sensores Agro  
âœ… Arquitectura Digital Twin Agro  
âœ… Arquitectura Blockchain y Trazabilidad Agro  

---

## Seguridad y control

âœ… Arquitectura Seguridad y Privacidad  
âœ… Arquitectura AuditorÃ­a y Trazabilidad  
âœ… Arquitectura Notificaciones y Eventos  
âœ… Arquitectura Integraciones Externas  

---

# Resultado arquitectÃ³nico

Agro Fields V8 queda definido como un ecosistema compuesto por:

Usuario

â†“

Aplicaciones Agro

â†“

Servicios Backend

â†“

Modelo Activo Agro V2

â†“

Datos Productivos

â†“

IoT

â†“

Digital Twin

â†“

IA / Analytics

â†“

Blockchain

â†“

Marketplace

â†“

InversiÃ³n y comercializaciÃ³n

---

# Estado de madurez

Antes:

Activo Agro como entidad digital productiva.

Ahora:

Activo Agro como ecosistema digital trazable, inteligente, verificable y preparado para expansiÃ³n internacional.

---

# PrÃ³xima etapa V8

Inicio fase implementaciÃ³n:

## Prioridad 1

EvoluciÃ³n tÃ©cnica ActivoAgroV2:

- evaluaciÃ³n de confianza;
- factores de confianza;
- cÃ¡lculo de Ã­ndice;
- evidencias verificables;
- integraciÃ³n historial.

## Prioridad 2

EvoluciÃ³n productiva:

- ciclos productivos;
- capacidad futura;
- intervenciones tÃ©cnicas;
- validaciones profesionales.

## Prioridad 3

Prioridad 3

Infraestructura:

- servicios backend;
- eventos;
- auditorÃ­a y trazabilidad;
- permisos;
- integraciones.


---

# Regla V8 actualizada

Cada evoluciÃ³n debe mantener:

Modelo

+

Arquitectura

+

AuditorÃ­a

+

BitÃ¡cora

+

Roadmap

+

Commit Git

---

Fecha cierre arquitectura:

24/07/2026
# Cierre Arquitectura Integral Agro Fields V8

La versiÃ³n V8 consolida la evoluciÃ³n arquitectÃ³nica del ecosistema Agro Fields estableciendo un modelo basado en capas, donde el Activo Agro V2 representa la entidad central del dominio.

Las capacidades incorporadas funcionan como mÃ³dulos especializados:

- API Backend V8
  - ComunicaciÃ³n y exposiciÃ³n de servicios.

- Modelo de Datos V8
  - NÃºcleo de entidades y relaciones.

- Gobernanza de Datos V8
  - Calidad, seguridad y control de informaciÃ³n.

- IoT V8
  - Captura de datos del mundo fÃ­sico.

- Big Data / Data Lake V8
  - Almacenamiento y procesamiento masivo.

- Digital Twin V8
  - RepresentaciÃ³n dinÃ¡mica del activo.

- IA y Machine Learning V8
  - PredicciÃ³n y recomendaciones inteligentes.

- Analytics & BI V8
  - TransformaciÃ³n de datos en conocimiento.

- Blockchain y Trazabilidad V8
  - CertificaciÃ³n y verificaciÃ³n de eventos.

- Marketplace V8
  - ConexiÃ³n comercial del ecosistema.

- Modelo Comercial V8
  - GeneraciÃ³n futura de valor econÃ³mico.

---

# Arquitectura conceptual final

Campo fÃ­sico

â†“

Activo Agro V2

â†“

Datos + Eventos + Documentos

â†“

Gobernanza y AuditorÃ­a

â†“

IoT / Big Data / Digital Twin

â†“

IA / Analytics

â†“

Blockchain (certificaciÃ³n)

â†“

Marketplace / Modelo Comercial

â†“

Confianza del Mercado


---

# Estado del Roadmap V8

La arquitectura V8 queda definida como una base escalable preparada para:

- crecimiento internacional;
- integraciÃ³n de nuevos servicios;
- automatizaciÃ³n inteligente;
- analÃ­tica avanzada;
- modelos comerciales futuros.

La implementaciÃ³n podrÃ¡ evolucionar por fases manteniendo la separaciÃ³n de responsabilidades y la independencia entre capas.

---

# Principio arquitectÃ³nico final

Agro Fields V8 no se construye como una aplicaciÃ³n aislada.

Se define como un ecosistema digital agro donde:

Activo Agro V2 = nÃºcleo del dominio

y las demÃ¡s capacidades agregan:

- informaciÃ³n;
- inteligencia;
- confianza;
- conectividad;
- valor econÃ³mico.


# Roadmap Agro Fields

## Estado general

### Fase 1 â€” NÃºcleo del Activo Agro

- [x] Modelo ActivoAgroV2
- [x] Firestore
- [x] SerializaciÃ³n
- [x] CRUD
- [x] Historial
- [x] Sistema de Confianza

Estado: 100%

---

### Fase 2 â€” MÃ³dulos

- [ ] ProducciÃ³n
- [ ] EconomÃ­a
- [ ] DocumentaciÃ³n
- [ ] Participantes
- [ ] Validaciones

Estado aproximado: 40%

---

### Fase 3 â€” AutomatizaciÃ³n

- [ ] Historial automÃ¡tico
- [ ] AuditorÃ­a
- [ ] Reglas de negocio
- [ ] Eventos
- [ ] Notificaciones

---

### Fase 4 â€” Marketplace

- [ ] PublicaciÃ³n
- [ ] BÃºsqueda
- [ ] Ranking
- [ ] ReputaciÃ³n
- [ ] Compra/Venta

---

## Objetivo inmediato

Finalizar los mÃ³dulos funcionales del Activo Agro.

DespuÃ©s comenzar el Marketplace.

# Agro Fields V8
# Roadmap de Jornada

## Fecha 28/07/2026


# MÃ³dulo

Historial y AuditorÃ­a del Activo Agro V2


---

# Objetivo de la jornada

Iniciar la evoluciÃ³n del sistema de trazabilidad del Activo Agro mediante eventos asociados a cambios relevantes del ecosistema.

Transformar el historial actual en una lÃ­nea temporal verificable que permita reconstruir la evoluciÃ³n del activo.


---

# Objetivo arquitectÃ³nico

Convertir el Activo Agro en una entidad digital con memoria propia.


El activo debe poder responder:

- quÃ© ocurriÃ³;
- cuÃ¡ndo ocurriÃ³;
- quiÃ©n participÃ³;
- quÃ© mÃ³dulo generÃ³ el cambio.


---

# Alcance de la jornada


## 1. EvoluciÃ³n del HistorialActivo


Archivo:

lib/models/activos/historial_activo_model.dart


Objetivo:

Implementar la primera capa de eventos del Activo Agro.


Estado esperado:

Historial capaz de registrar:


- eventoId;
- tipoEvento;
- descripciÃ³n;
- usuario responsable;
- mÃ³dulo origen;
- fecha.


Resultado:

Base para la trazabilidad integral futura.


---

# 2. IntegraciÃ³n con ActivoAgroV2


Archivo:

lib/models/activos/activo_agro_model_v2.dart


Objetivo:

Incorporar historial dentro del nÃºcleo del activo.


Acciones:


Agregar:

```dart
List<HistorialActivo> historial
## Fase: ValorizaciÃ³n y Mercado Inteligente Agro

Objetivo:

Transformar activos registrados en oportunidades agro analizadas.

Incluye:

- motor de valorizaciÃ³n
- comparaciÃ³n de activos
- ranking de oportunidades
- bÃºsqueda avanzada
- perfiles de inversores

---

# EvoluciÃ³n EstratÃ©gica Agro Fields V8.X

## Nueva etapa: Inteligencia de Mercado y ValorizaciÃ³n Agro

## Objetivo

Transformar los Activos Agro registrados en oportunidades analizadas mediante informaciÃ³n histÃ³rica, productiva, econÃ³mica y documental.

Esta evoluciÃ³n busca ampliar el ecosistema desde una plataforma de registro y gestiÃ³n hacia una infraestructura digital de confianza para anÃ¡lisis agropecuario.

---

# Fase 5 â€” Inteligencia de Mercado Agro

## Estado

ðŸ”œ Futuro


## Objetivo

Crear capacidades para analizar activos agropecuarios utilizando informaciÃ³n validada dentro del ecosistema.


## Capacidades futuras

### Motor de anÃ¡lisis de activos

PermitirÃ¡:

- comparar activos;
- analizar evoluciÃ³n histÃ³rica;
- identificar caracterÃ­sticas productivas;
- visualizar capacidad de expansiÃ³n;
- generar indicadores.


---

### BÃºsqueda avanzada de oportunidades

Preparada para:

- filtros productivos;
- ubicaciÃ³n geogrÃ¡fica;
- caracterÃ­sticas econÃ³micas;
- tipo de actividad;
- nivel de confianza;
- estado del activo.


---

### Ranking de oportunidades

PermitirÃ¡ organizar activos segÃºn:

- informaciÃ³n disponible;
- nivel de confianza;
- caracterÃ­sticas productivas;
- objetivos del inversor;
- criterios configurables.


---

### Perfiles de inversores

Preparado para:

- intereses productivos;
- ubicaciÃ³n;
- tipo de inversiÃ³n;
- preferencias;
- objetivos.


---

# Nuevo flujo estratÃ©gico

Activo Agro V2

â†“

InformaciÃ³n Productiva

â†“

Historial

â†“

AuditorÃ­a

â†“

Confianza

â†“

Analytics

â†“

ValorizaciÃ³n Inteligente

â†“

Marketplace

â†“

InversiÃ³n


---

# Criterio de valorizaciÃ³n

Agro Fields no determina:

- precio definitivo;
- rentabilidad garantizada;
- recomendaciÃ³n financiera.


La plataforma organiza informaciÃ³n verificable para facilitar anÃ¡lisis y toma de decisiones entre participantes.


---

# RelaciÃ³n con el ecosistema

Esta evoluciÃ³n utiliza las capacidades existentes:

- Activo Agro V2;
- Historial;
- AuditorÃ­a;
- DocumentaciÃ³n;
- Confianza;
- ProducciÃ³n;
- EconomÃ­a;
- IA;
- Analytics;
- Marketplace.


---

# Diferenciador estratÃ©gico

Agro Fields no funciona Ãºnicamente como un marketplace agropecuario.

El diferencial es construir una memoria digital del activo que permita comprender:

- quÃ© ocurriÃ³;
- cuÃ¡ndo ocurriÃ³;
- quiÃ©n participÃ³;
- quÃ© evidencia existe;
- cÃ³mo evolucionÃ³.


---

# PrÃ³xima implementaciÃ³n tÃ©cnica

Prioridades actuales:

1. EvaluaciÃ³n de confianza:
   - factores;
   - evidencias;
   - responsables;
   - cÃ¡lculo de Ã­ndice.

2. EvoluciÃ³n productiva:
   - ciclos productivos;
   - historial;
   - capacidad futura;
   - expansiÃ³n.

3. AuditorÃ­a integral:
   - eventos;
   - trazabilidad;
   - evidencias.

4. Inteligencia futura:
   - anÃ¡lisis;
   - recomendaciones;
   - comparaciÃ³n de activos.

---

# Regla V8

Cada evoluciÃ³n debe mantener:

Modelo

+

Arquitectura

+

AuditorÃ­a

+

BitÃ¡cora

+

Roadmap

+

Commit Git

---

Fase:
EvoluciÃ³n tÃ©cnica Activo Agro V2

MÃ³dulo:
ProducciÃ³n

Estado:
Modelo base actualizado

Avances:
âœ… identidad del mÃ³dulo
âœ… relaciÃ³n con Activo Agro V2
âœ… compatibilidad Firestore

PrÃ³ximos pasos:
- ciclos productivos
- historial productivo
- capacidad futura
- intervenciones tÃ©cnicas
---

# EvoluciÃ³n Madurez Activo V8

## MÃ³dulo

Madurez del Activo Agro V2

## Estado

Modelo base actualizado.

## Avances realizados

Se incorpora una capa de evoluciÃ³n del activo considerando:

- porcentaje de madurez;
- faltantes identificados;
- etapa del activo;
- nivel tecnolÃ³gico;
- preparaciÃ³n para inversiÃ³n.

## Objetivo

Permitir representar el grado de evoluciÃ³n y organizaciÃ³n del Activo Agro dentro del ecosistema Agro Fields V8.

## Integraciones futuras

Preparado para relacionarse con:

- EvaluaciÃ³n de Confianza;
- ProducciÃ³n;
- Analytics;
- Marketplace.

## PrÃ³ximas evoluciones

- historial de madurez;
- eventos de evoluciÃ³n;
- indicadores avanzados.
# ðŸ—ºï¸ ROADMAP AGRO FIELDS

## VersiÃ³n
V8.X

## Fecha de actualizaciÃ³n
13/08/2026

## Arquitectura base
V8.0

## Principio estratÃ©gico

Agro Fields evoluciona desde una plataforma de publicaciÃ³n y contacto
hacia una infraestructura digital de informaciÃ³n para Activos Agro.

El objetivo no es solamente publicar campos.

El objetivo es:

> estructurar, documentar, relacionar, validar y contextualizar
> informaciÃ³n de activos agropecuarios reales.

---

# 1. VisiÃ³n del producto

Campo real
â†“
Activo Agro
â†“
InformaciÃ³n estructurada
â†“
DocumentaciÃ³n
â†“
Evidencias
â†“
Validaciones
â†“
Confianza
â†“
Oportunidad
â†“
Comprador / Inversor / Productor

---

# 2. Estado actual

## ðŸŸ¢ Funcional

Actualmente el sistema cuenta con:

- Activo Agro V2;
- creaciÃ³n y gestiÃ³n de activos;
- informaciÃ³n productiva;
- informaciÃ³n econÃ³mica;
- documentaciÃ³n;
- confianza inicial;
- madurez del activo;
- solicitudes de contacto;
- aceptaciÃ³n de solicitudes;
- creaciÃ³n de conversaciones;
- chat comprador â†” propietario;
- mensajes persistidos en Firebase;
- listado de conversaciones;
- informaciÃ³n real del activo dentro del chat;
- informaciÃ³n real del participante;
- historial y auditorÃ­a como base arquitectÃ³nica.

---

# 3. Etapa actual â€” Contacto y ConversaciÃ³n

## Estado

ðŸŸ¢ Funcional / consolidaciÃ³n

El sistema ya permite:

Comprador
â†“
Oportunidad
â†“
Solicitud de contacto
â†“
Propietario acepta
â†“
ConversaciÃ³n
â†“
Mensaje
â†“
Respuesta

---

## PrÃ³ximas tareas inmediatas

### Unicidad de conversaciones

Garantizar que no puedan existir conversaciones duplicadas para la
misma relaciÃ³n:

```text
campoId
+
propietarioId
+
interesadoId
---

# EvoluciÃ³n V8 â€” Suelo Activo Agro

## Estado

ðŸŸ¡ En evoluciÃ³n.

El mÃ³dulo de Suelo se incorpora al Activo Agro V2 como una nueva dimensiÃ³n de informaciÃ³n y evaluaciÃ³n del activo.

Se mantiene la arquitectura existente.

Criterio:

No crear ActivoAgroV3.

La evoluciÃ³n del suelo continÃºa sobre ActivoAgroV2.

---

## Modelo de Suelo

Archivo:

lib/models/activos/suelo_activo_model.dart

Estado:

ðŸŸ¢ Modelo base implementado.

El modelo contempla:

- estado de evaluaciÃ³n;
- textura;
- drenaje;
- pH;
- materia orgÃ¡nica;
- evidencias;
- observaciones;
- fecha de evaluaciÃ³n.

El modelo incorpora:

- constructor;
- estado inicial;
- deserializaciÃ³n desde Map;
- serializaciÃ³n a Map;
- conversiÃ³n de Timestamp;
- copyWith.

---

## IntegraciÃ³n con ActivoAgroV2

Archivo:

lib/models/activos/activo_agro_model_v2.dart

Estado:

ðŸŸ¢ Integrado.

ActivoAgroV2 incorpora:

```dart
final SueloActivo suelo;
```

La informaciÃ³n del suelo forma parte de la estructura persistente del Activo Agro V2.

La deserializaciÃ³n y serializaciÃ³n se realizan mediante:

```dart
SueloActivo.fromMap(...)
```

y:

```dart
suelo.toMap()
```

# EVOLUCIÃ“N MÃ“DULO SUELO â€” CIERRE DE ETAPA

## InicializaciÃ³n del Suelo

El Suelo se inicializa actualmente mediante:

`SueloActivo.inicial()`

Estado inicial:

`sin_evaluar`

Las evidencias comienzan vacÃ­as.

El objetivo es permitir que todo nuevo Activo Agro disponga desde su creaciÃ³n de una estructura de suelo preparada para futuras evaluaciones.

---

## PrÃ³xima evoluciÃ³n funcional del Suelo

### 1. ValidaciÃ³n de serializaciÃ³n

Estado:

ðŸŸ¡ Pendiente.

Agregar pruebas especÃ­ficas para validar:

`SueloActivo`
â†“
`toMap`
â†“
`fromMap`
â†“
`SueloActivo`

Se deberÃ¡ verificar la conservaciÃ³n de:

- estado;
- textura;
- drenaje;
- pH;
- materia orgÃ¡nica;
- evidencias;
- observaciones;
- fecha de evaluaciÃ³n.

---

### 2. VisualizaciÃ³n del Suelo

Estado:

ðŸŸ¡ Pendiente.

Integrar el mÃ³dulo Suelo en:

`lib/screens/campos/detalle_activo_agro_screen.dart`

La pantalla deberÃ¡ mostrar inicialmente:

- estado;
- textura;
- drenaje;
- pH;
- materia orgÃ¡nica;
- cantidad de evidencias;
- observaciones;
- fecha de evaluaciÃ³n.

---

### 3. ActualizaciÃ³n del Suelo

Estado:

ðŸŸ¡ Pendiente.

Evolucionar:

`lib/services/activo_agro_service_v2.dart`

incorporando una operaciÃ³n especÃ­fica para actualizar el mÃ³dulo Suelo.

La actualizaciÃ³n deberÃ¡ mantener la arquitectura existente de persistencia del Activo Agro.

---

### 4. Historial del Suelo

Estado:

ðŸŸ¡ Pendiente.

Las modificaciones del mÃ³dulo deberÃ¡n generar eventos dentro del historial del Activo Agro.

Evento previsto:

`actualizacion_suelo`

El historial permitirÃ¡ conservar la evoluciÃ³n temporal de la informaciÃ³n del suelo.

---

### 5. AuditorÃ­a del Suelo

Estado:

ðŸŸ¡ Pendiente.

Las modificaciones del mÃ³dulo Suelo deberÃ¡n registrarse mediante:

`AuditService`

utilizando:

`modulo: suelo`

y una acciÃ³n especÃ­fica para la actualizaciÃ³n del mÃ³dulo.

La auditorÃ­a deberÃ¡ conservar:

- activo afectado;
- usuario responsable;
- acciÃ³n;
- referencia;
- datos relevantes de la modificaciÃ³n.

---

### 6. EvaluaciÃ³n del Suelo

Estado:

ðŸŸ¡ Pendiente.

Se deberÃ¡ implementar posteriormente un flujo de evaluaciÃ³n del suelo que permita registrar:

- caracterÃ­sticas fÃ­sicas;
- condiciones de drenaje;
- pH;
- materia orgÃ¡nica;
- observaciones;
- evidencias;
- fecha de evaluaciÃ³n.

Flujo previsto:

Detalle Activo Agro
â†“
EvaluaciÃ³n de Suelo
â†“
SueloActivo
â†“
ActivoAgroServiceV2
â†“
Firestore
â†“
Historial
â†“
AuditorÃ­a

---

## RelaciÃ³n futura entre Suelo, Confianza y Madurez

Estado:

âšª Posterior.

En esta etapa el mÃ³dulo Suelo se considera una dimensiÃ³n independiente de informaciÃ³n y evaluaciÃ³n del Activo Agro.

No se incorpora todavÃ­a al cÃ¡lculo automÃ¡tico de:

- Confianza;
- Madurez;
- rentabilidad;
- publicaciÃ³n.

Antes de establecer dicha relaciÃ³n deberÃ¡ definirse:

- metodologÃ­a de evaluaciÃ³n;
- criterios agronÃ³micos;
- evidencia requerida;
- responsables de validaciÃ³n;
- niveles de confianza;
- impacto sobre la madurez del activo.

Criterio arquitectÃ³nico:

No establecer dependencias entre Suelo, Confianza y Madurez hasta contar con una definiciÃ³n funcional y metodolÃ³gica suficiente.

---

## Criterio de continuidad V8

La evoluciÃ³n del mÃ³dulo Suelo continuarÃ¡ sobre:

`ActivoAgroV2`

sin crear una nueva versiÃ³n estructural del modelo.

La prioridad inmediata serÃ¡ cerrar el circuito:

Modelo
â†“
SerializaciÃ³n
â†“
VisualizaciÃ³n
â†“
ActualizaciÃ³n
â†“
Historial
â†“
AuditorÃ­a
â†“
EvaluaciÃ³n

Una vez cerrado este circuito se evaluarÃ¡ la integraciÃ³n del Suelo con las capas superiores de Confianza y Madurez.

---

## PrÃ³xima jornada tÃ©cnica

Prioridad:

1. cerrar test de serializaciÃ³n de Suelo;
2. integrar visualizaciÃ³n en `DetalleActivoAgroScreen`;
3. implementar actualizaciÃ³n del Suelo;
4. incorporar historial;
5. incorporar auditorÃ­a;
6. implementar evaluaciÃ³n;
7. ejecutar pruebas;
8. documentar resultados en `BITACORA.md`.

Estado de cierre:

ðŸŸ¡ MÃ³dulo Suelo incorporado arquitectÃ³nicamente y pendiente de completar su circuito funcional.

---

# CIERRE DE JORNADA â€” MÃ“DULO SUELO

El mÃ³dulo Suelo queda formalmente incorporado a la arquitectura del Activo Agro V2.

La estructura de datos, integraciÃ³n con `ActivoAgroV2`, inicializaciÃ³n y persistencia base se encuentran implementadas.

La evoluciÃ³n funcional queda deliberadamente pendiente de la siguiente etapa, manteniendo separaciÃ³n entre:

- informaciÃ³n del suelo;
- evaluaciÃ³n agronÃ³mica;
- confianza;
- madurez;
- publicaciÃ³n.

No se crea una nueva versiÃ³n del modelo.

La continuidad del desarrollo se realizarÃ¡ sobre `ActivoAgroV2`, respetando la arquitectura V8, la trazabilidad mediante Git, el historial del activo y la auditorÃ­a transversal.

Estado general:

ðŸŸ¡ **MÃ³dulo Suelo incorporado arquitectÃ³nicamente â€” circuito funcional pendiente.**
# Paso 9 â€” ValidaciÃ³n de OportunidadAgroService

## Estado

ðŸŸ¢ VALIDADO

## Fecha

03/09/2026

## ValidaciÃ³n realizada

Se validÃ³ mediante Integration Test la integraciÃ³n real entre:

`ActivoAgroV2`

â†“

`OportunidadAgro`

â†“

`OportunidadAgroService`

â†“

`Firestore Emulator`

â†“

`AuditorÃ­a`

## Capacidades verificadas

- creaciÃ³n de Activo Agro V2;
- persistencia del Activo Agro;
- recuperaciÃ³n del Activo Agro;
- creaciÃ³n de OportunidadAgro vinculada;
- persistencia de la oportunidad;
- recuperaciÃ³n por ID;
- consulta de oportunidades por Activo Agro;
- consulta de oportunidades activas;
- generaciÃ³n de auditorÃ­a;
- trazabilidad de usuario y referencia;
- rechazo de oportunidades vinculadas a activos inexistentes.

## Evidencia

Test:

`integration_test/oportunidad_agro_service_integration_test.dart`

Resultado:

`All tests passed!`

## Arquitectura

La implementaciÃ³n continÃºa sobre `ActivoAgroV2`.

No se crea `ActivoAgroV3`.

Se mantiene:

`Screen â†’ Service â†’ Model â†’ Firebase`

con auditorÃ­a transversal.

## PrÃ³xima etapa

Consolidar el cierre del Paso 9 mediante:

- actualizaciÃ³n de documentaciÃ³n;
- actualizaciÃ³n de BITÃCORA;
- commit;
- push;
- verificaciÃ³n de working tree limpio.

Una vez completado el versionado, iniciar la planificaciÃ³n del Paso 10 sin modificar innecesariamente las capas ya validadas.
# Principios rectores de experiencia Agro Fields

## 1. Experiencia adaptativa

Responsive no alcanza.

Agro Fields debe adaptar la experiencia al contexto de uso, manteniendo la misma plataforma, informaciÃ³n, arquitectura, modelos, servicios y lÃ³gica de negocio.

---

## 2. Complejidad detrÃ¡s de escena

La complejidad queda en el sistema, no en la pantalla.

El usuario debe poder realizar acciones simples sin tener que comprender la complejidad interna de Agro Fields.

---

## 3. Registro inmediato y estructuraciÃ³n automÃ¡tica

Registrar en el momento, con el mÃ­nimo esfuerzo; estructurar automÃ¡ticamente detrÃ¡s.

Principio operativo:

> Lo veo â†’ lo registro â†’ Agro Fields lo organiza.
# Paso 11 â€” Inversiones

## Estado

ðŸŸ¢ **VALIDACIÃ“N TÃ‰CNICA COMPLETADA**

## Fecha

07/09/2026

## Objetivo

Validar el registro de inversiones y la actualizaciÃ³n del monto recaudado de una publicaciÃ³n de inversiÃ³n mediante una transacciÃ³n Firestore.

## ImplementaciÃ³n validada

Archivo:

`lib/services/inversion_service.dart`

La operaciÃ³n:

`InversionService.crearInversion()`

utiliza una transacciÃ³n Firestore para mantener coordinadas las siguientes operaciones:

1. verificar la existencia de la publicaciÃ³n de inversiÃ³n;
2. obtener `montoRecaudado`;
3. calcular el nuevo monto recaudado;
4. registrar la inversiÃ³n;
5. actualizar `montoRecaudado`.

## Test de integraciÃ³n

Archivo:

`integration_test/inversion_service_integration_test.dart`

Se validÃ³ mediante:

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

TambiÃ©n se ejecutÃ³:

`flutter analyze integration_test/inversion_service_integration_test.dart`

Resultado:

`No issues found!`

## Caso validado

Monto recaudado inicial:

`25000.0`

InversiÃ³n:

`15000.0`

Monto recaudado final:

`40000.0`

Resultado:

`25000.0 + 15000.0 = 40000.0`

## Arquitectura

Se mantiene:

`Screen â†’ Service â†’ Model â†’ Firebase`

No se crea `ActivoAgroV3`.

La evoluciÃ³n continÃºa sobre la arquitectura V8 existente.

## PrÃ³ximo paso

Completar el cierre formal del Paso 11 mediante:

* actualizaciÃ³n de `BITACORA.md`;
* actualizaciÃ³n de `ROADMAP_V8.md`;
* revisiÃ³n de cambios;
* commit;
* push a `origin/main`;
* verificaciÃ³n de working tree limpio y rama sincronizada.

El Paso 11 no se considerarÃ¡ formalmente cerrado hasta completar el versionado y publicaciÃ³n.

---

## Regla de cierre

Primero validar.

DespuÃ©s documentar.

DespuÃ©s versionar.

No acelerar etapas.

No crear V3.

Mantener la arquitectura V8.

---

# PASO 11 â€” INVERSIONES â€” CIERRE FORMAL

## Fecha

07/09/2026

## Estado

ðŸŸ¢ **CERRADO**

La validaciÃ³n tÃ©cnica de `InversionService.crearInversion()` fue completada mediante Integration Test con Android Emulator y Firestore Emulator.

Resultado:

`All tests passed!`

TambiÃ©n se validÃ³:

`flutter analyze integration_test/inversion_service_integration_test.dart`

Resultado:

`No issues found!`

Caso validado:

`25000.0 + 15000.0 = 40000.0`

Commit:

`805a279 feat: validar paso 11 inversiones`

El commit fue publicado en `origin/main`.

Por lo tanto:

**Paso 11 â€” INVERSIONES: CERRADO.**

---

# PASO 12 â€” EXPEDIENTE DIGITAL PERMANENTE DEL ACTIVO AGRO

## Fecha de inicio

07/09/2026

## Estado

ðŸŸ¢ **12.1â€“12.7 CERRADOS CONCEPTUAL Y DOCUMENTALMENTE**

## Objetivo

Definir el Expediente Digital Permanente como la memoria digital histÃ³rica y trazable del Activo Agro.

La arquitectura mantiene:

`ActivoAgroV2`

â†“

`Expediente Digital Permanente`

â†“

`Datos + Historial + Evidencias`

â†“

`AuditorÃ­a`

â†“

`Confianza`

â†“

`PublicaciÃ³n / EvaluaciÃ³n`

El expediente se define como una composiciÃ³n lÃ³gica de las capacidades existentes y no como un nuevo modelo duplicado.

Criterio:

**No crear `ActivoAgroV3`.**

---

# Paso 12.1 â€” AuditorÃ­a de arquitectura actual

Estado:

ðŸŸ¢ **CERRADO**

Se revisaron los modelos, servicios y capas existentes relacionados con el Activo Agro.

Se confirmÃ³ la existencia de:

- `ActivoAgroV2`;
- `HistorialActivo`;
- `AuditEvent`;
- `DocumentacionActivo`;
- `ConfianzaActivo`;
- `EvaluacionConfianza`;
- `MadurezActivo`;
- `ParticipanteActivo`;
- `SueloActivo`.

ConclusiÃ³n:

La base actual permite evolucionar el Expediente Digital Permanente sin crear una entidad estructural duplicada.

---

# Paso 12.2 â€” Master Plan â†” Arquitectura V8 â†” CÃ³digo real

Estado:

ðŸŸ¢ **CERRADO**

La arquitectura conceptual fue contrastada con la implementaciÃ³n real.

Se identificaron como Ã¡reas futuras de evoluciÃ³n:

- validez;
- fuentes;
- evidencias;
- verificaciones;
- temporalidad;
- metadatos documentales;
- profundidad de auditorÃ­a.

No se modificÃ³ cÃ³digo durante esta etapa.

---

# Paso 12.3 â€” Expediente Digital Permanente

Estado:

ðŸŸ¢ **CERRADO**

El Expediente Digital Permanente representa la memoria continua del Activo Agro.

Debe permitir reconstruir:

- informaciÃ³n;
- fechas;
- participantes;
- evidencias;
- modificaciones;
- estados;
- evaluaciones;
- evoluciÃ³n.

No reemplaza a `ActivoAgroV2`, HistorialActivo ni AuditEvent.

---

# Paso 12.4 â€” Ciclo de vida

Estado:

ðŸŸ¢ **CERRADO CONCEPTUALMENTE**

Se mantiene la separaciÃ³n entre:

- estado del Activo;
- estado de publicaciÃ³n;
- confianza/verificaciÃ³n;
- flujo comercial.

Estados actualmente utilizados en cÃ³digo:

- `borrador`;
- `publicado`;
- `pausado`.

Los restantes estados del enum requieren definiciÃ³n funcional antes de considerarse transiciones implementadas.

El archivado no elimina el expediente permanente.

---

# Paso 12.5 â€” Historial y AuditorÃ­a

Estado:

ðŸŸ¢ **CERRADO CONCEPTUALMENTE**

Criterio:

**Historial = evoluciÃ³n significativa del Activo.**

**AuditorÃ­a = trazabilidad de la acciÃ³n.**

Los acontecimientos relevantes pueden generar ambos registros.

Se establece trazabilidad profunda para cambios relevantes, evitando registrar indiscriminadamente toda actividad tÃ©cnica de la aplicaciÃ³n.

---

# Paso 12.6 â€” Validez de los datos

Estado:

ðŸŸ¢ **CERRADO CONCEPTUALMENTE**

Estados definidos:

- ðŸŸ¢ `vigente_verificado`
- ðŸŸ¡ `vigente_informado`
- ðŸŸ  `requiere_actualizacion`
- ðŸ”´ `desactualizado`
- âšª `sin_informacion`

Principio:

**Validez â‰  Confianza**

La actualizaciÃ³n de un registro no implica automÃ¡ticamente que el dato sea vigente.

Los hechos histÃ³ricos mantienen su contexto temporal.

No se agregan todavÃ­a campos genÃ©ricos de validez directamente a `ActivoAgroV2`.

---

# Paso 12.7 â€” DocumentaciÃ³n

Estado:

ðŸŸ¢ **CERRADO**

Se actualizan:

- `docs/BITACORA.md`;
- `docs/ROADMAP_V8.md`.

La documentaciÃ³n consolida las decisiones arquitectÃ³nicas del Paso 12 y el cierre formal del Paso 11.

No se modifica cÃ³digo.

---

# Decisiones arquitectÃ³nicas consolidadas

- `ActivoAgroV2` continÃºa como identidad permanente.
- No crear `ActivoAgroV3`.
- Expediente Digital Permanente como composiciÃ³n lÃ³gica.
- PublicaciÃ³n comercial separada del expediente.
- Historial y AuditorÃ­a como capas complementarias.
- Validez separada de Confianza.
- No duplicar modelos sin necesidad demostrada.
- Identificar el GAP antes de modificar cÃ³digo.

---

# Paso 12.8 â€” GAP Arquitectura â†” CÃ³digo

## Estado

ðŸŸ¡ **PRÃ“XIMO PASO**

Objetivo:

Determinar quÃ© modificaciones mÃ­nimas son realmente necesarias para llevar las decisiones arquitectÃ³nicas del Expediente Digital Permanente al cÃ³digo existente.

La revisiÃ³n deberÃ¡ cubrir:

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

**Identificar GAP â†’ definir soluciÃ³n â†’ modificar cÃ³digo â†’ probar â†’ validar â†’ documentar â†’ versionar.**

No modificar cÃ³digo antes de cerrar el anÃ¡lisis del GAP.

No crear V3.

Mantener arquitectura V8.

---

# Estado general del Roadmap

ðŸŸ¢ Paso 9 â€” OportunidadAgroService: CERRADO

ðŸŸ¢ Paso 11 â€” Inversiones: CERRADO

ðŸŸ¢ Paso 12.1 â€” AuditorÃ­a arquitectÃ³nica: CERRADO

ðŸŸ¢ Paso 12.2 â€” Matriz Master Plan â†” Arquitectura â†” CÃ³digo: CERRADO

ðŸŸ¢ Paso 12.3 â€” Expediente Digital Permanente: CERRADO

ðŸŸ¢ Paso 12.4 â€” Ciclo de vida: CERRADO CONCEPTUALMENTE

ðŸŸ¢ Paso 12.5 â€” Historial y AuditorÃ­a: CERRADO CONCEPTUALMENTE

ðŸŸ¢ Paso 12.6 â€” Validez de datos: CERRADO CONCEPTUALMENTE

ðŸŸ¢ Paso 12.7 â€” DocumentaciÃ³n: CERRADO

ðŸŸ¡ Paso 12.8 â€” GAP Arquitectura â†” CÃ³digo: PRÃ“XIMO

---

# Regla V8

Cada evoluciÃ³n debe mantener:

`Modelo`

+

`Arquitectura`

+

`AuditorÃ­a`

+

`BitÃ¡cora`

+

`Roadmap`

+

`Pruebas`

+

`ValidaciÃ³n`

+

`Commit Git`

## PASO 12.8 â€” AuditorÃ­a GAP y cierre arquitectÃ³nico

### Estado

**CERRADO ARQUITECTÃ“NICAMENTE**

Se completÃ³ la auditorÃ­a del cÃ³digo real relacionada con el Expediente Digital Permanente del Activo Agro.

### Componentes auditados

* `ActivoAgroV2`
* `HistorialActivo`
* `AuditEvent`
* `AuditService`
* `AuditType`
* `DocumentacionActivo`
* ProducciÃ³n y ciclos productivos
* EconomÃ­a
* Participantes
* Confianza
* EvaluaciÃ³n de confianza
* Factores de confianza
* Madurez
* Servicio de confianza

Se verificÃ³ ademÃ¡s la existencia de infraestructura transversal para Evidencia, Documento, VerificaciÃ³n y Fuente.

### Resultado

No existe actualmente una entidad transversal formal de Evidencia.

Los modelos actuales contienen referencias simples a evidencias, archivos, fuentes o declaraciones, pero no una estructura comÃºn para conectar:

**Dato â†’ Evidencia â†’ VerificaciÃ³n â†’ Validez â†’ Confianza**

### GAP confirmados

* **GAP-EVID-01:** falta entidad transversal de Evidencia.
* **GAP-DOC-01:** documentaciÃ³n basada en listas simples.
* **GAP-PROD-01:** producciÃ³n sin respaldo estructurado transversal.
* **GAP-ECON-01:** economÃ­a sin evidencia estructurada.
* **GAP-PART-01:** participaciÃ³n sin registro estructurado de contribuciÃ³n, manteniendo acciones en historial/auditorÃ­a.
* **GAP-VAL-01:** falta representaciÃ³n transversal de Validez.
* **GAP-TRACE-01:** falta normalizaciÃ³n documental del uso de old/new en cambios relevantes.
* **GAP-AUD-01:** consulta de auditorÃ­a puede evolucionar para ordenar explÃ­citamente por fecha.
* **GAP-MAD-01:** algoritmo de madurez requiere futura revisiÃ³n.
* **GAP-CONF-01:** confianza reconoce evidencias conceptualmente, pero todavÃ­a no dispone de una capa real de evidencia.

### Decisiones arquitectÃ³nicas

* Mantener `ActivoAgroV2`.
* No crear `ActivoAgroV3`.
* No crear un `ExpedienteDigitalPermanenteModel`.
* El Expediente Digital Permanente serÃ¡ una composiciÃ³n lÃ³gica del Activo y sus capas de informaciÃ³n, memoria y trazabilidad.
* Crear posteriormente una Ãºnica capa transversal de Evidencia.
* Mantener separadas Evidencia, VerificaciÃ³n, Validez, Confianza, Historial y AuditorÃ­a.
* Evolucionar los mÃ³dulos existentes en lugar de duplicarlos.
* No crear modelos de evidencia especÃ­ficos por mÃ³dulo.

### Estado conceptual del Expediente

```text
ActivoAgroV2
      â”‚
      â”œâ”€â”€ Datos
      â”œâ”€â”€ DocumentaciÃ³n
      â”œâ”€â”€ ProducciÃ³n
      â”œâ”€â”€ EconomÃ­a
      â”œâ”€â”€ Participantes
      â”‚
      â”œâ”€â”€ Evidencias
      â”‚       â†“
      â”‚   VerificaciÃ³n
      â”‚       â†“
      â”‚     Validez
      â”‚
      â”œâ”€â”€ Historial
      â”œâ”€â”€ AuditorÃ­a
      â”œâ”€â”€ Confianza
      â””â”€â”€ Madurez
```

### PrÃ³ximo paso

**PASO 13 â€” DiseÃ±o tÃ©cnico de Evidencia**

Orden previsto:

1. Definir modelo conceptual final.
2. Definir campos.
3. Definir relaciones.
4. Definir tipos de evidencia.
5. Definir verificaciÃ³n.
6. Definir validez.
7. Definir persistencia.
8. Definir servicio.
9. Definir integraciÃ³n con mÃ³dulos.
10. Definir auditorÃ­a.
11. Crear tests.
12. Implementar.
13. Validar con Firestore Emulator.
14. Documentar.
15. Commit.
16. Push.

**Regla:** no implementar hasta cerrar el diseÃ±o tÃ©cnico.

# PASO 12.9 â€” Matriz Ficha Maestra V1.0 â†” Arquitectura V8 â†” CÃ³digo real

## Estado

ðŸŸ¢ **CERRADO â€” VALIDADO TÃ‰CNICAMENTE**

## Objetivo

Traducir la Ficha Maestra del Activo Agro V1 a la arquitectura existente de Agro Fields, verificando quÃ© informaciÃ³n ya existe, quÃ© capacidades requieren evoluciÃ³n y cuÃ¡les son los GAP concretos que deben resolverse sin duplicar modelos.

## Principio

**No agregar campos ni crear modelos nuevos hasta comprobar si la informaciÃ³n ya existe en la arquitectura actual.**

La referencia funcional es la Ficha Maestra.

La referencia tÃ©cnica es la arquitectura V8 y el cÃ³digo real existente.

## Resultado

La matriz confirmÃ³ que el Expediente Digital Permanente puede evolucionar sobre `ActivoAgroV2`, utilizando los mÃ³dulos existentes y una capa transversal de `Evidencia`.

Se mantiene la decisiÃ³n:

**No crear `ActivoAgroV3`.**

No se crea un modelo `ExpedienteDigitalPermanente`.

## Evidencia transversal

Durante la implementaciÃ³n posterior al GAP arquitectÃ³nico se confirmÃ³ que ya existÃ­a el modelo:

`Evidencia`

y se implementÃ³:

`EvidenciaService`

La evidencia queda como capa transversal y no como modelos especÃ­ficos por mÃ³dulo.

No se crearÃ¡n:

* `EvidenciaSuelo`;
* `EvidenciaProduccion`;
* `EvidenciaEconomia`.

## ValidaciÃ³n de suelo

Se integrÃ³ evidencia al flujo de actualizaciÃ³n de `SueloActivo`.

Flujo validado:

`Dato de suelo`
â†’ `Evidencia`
â†’ `HistorialActivo`
â†’ `AuditEvent`
â†’ `Firestore Emulator`

La integraciÃ³n fue validada mediante test de integraciÃ³n con Android Emulator + Firestore Emulator.

Resultado:

**All tests passed!**

## ValidaciÃ³n de producciÃ³n y ciclo productivo

Se integrÃ³ evidencia al registro de `CicloProductivo`.

Flujo validado:

`CicloProductivo`
â†’ `Evidencia`
â†’ `HistorialActivo`
â†’ `AuditEvent`
â†’ `Firestore Emulator`

La integraciÃ³n fue validada mediante test de integraciÃ³n con Android Emulator + Firestore Emulator.

Resultado:

**All tests passed!**

## GAP-PROD-ID-01 â€” Identidad estable del mÃ³dulo de producciÃ³n

Durante la validaciÃ³n tÃ©cnica de producciÃ³n se confirmÃ³ un GAP relacionado con la identidad del mÃ³dulo:

`ModuloProduccion.id` es opcional y algunas rutas de creaciÃ³n no establecen necesariamente un identificador estable.

Esto podÃ­a dificultar la trazabilidad profunda:

`ActivoAgroV2`
â†’ `ModuloProduccion`
â†’ `CicloProductivo`
â†’ `Evidencia`

### SoluciÃ³n implementada

Se centralizÃ³ la normalizaciÃ³n de identidad en `ActivoAgroServiceV2.crearActivo()`.

Cuando `ModuloProduccion.id` es nulo:

- se genera un identificador mediante Firestore;
- se asigna el identificador generado al mÃ³dulo;
- se completa `activoAgroId` con el ID del `ActivoAgroV2` cuando falta;
- el mÃ³dulo normalizado se persiste junto con el Activo Agro.

### ValidaciÃ³n tÃ©cnica

Se creÃ³ y ejecutÃ³:

`integration_test/activo_agro_service_produccion_id_integration_test.dart`

Resultados:

- `flutter analyze integration_test/activo_agro_service_produccion_id_integration_test.dart` â†’ **No issues found!**
- `flutter test integration_test/activo_agro_service_produccion_id_integration_test.dart` â†’ **All tests passed!**

### Estado

**GAP-PROD-ID-01 â€” RESUELTO Y VALIDADO TÃ‰CNICAMENTE.**

| GAP               | Estado                    |
| ----------------- | ------------------------- |
| GAP-EVID-01       | ðŸŸ¢ Resuelto en capa base  |
| GAP-SUELO-EVID-01 | ðŸŸ¢ Resuelto y validado    |
| GAP-PROD-01       | ðŸŸ¢ Resuelto y validado    |
| GAP-PROD-ID-01    | ðŸŸ¢ Resuelto y validado    |
| GAP-DOC-01        | ðŸŸ¢ Resuelto y validado    |
| GAP-ECON-01       | ðŸŸ¢ Resuelto y validado    |
| GAP-PART-01       | ðŸŸ¢ Mantener modelo actual |
| GAP-VAL-01        | ðŸŸ¢ Resuelto y validado    |
| GAP-TRACE-01      | ðŸŸ¢ Resuelto y validado    |
| GAP-AUD-01        | ðŸŸ¡ Mejora futura          |
| GAP-MAD-01        | ðŸŸ¡ Mejora futura          |
| GAP-CONF-01       | ðŸŸ¡ IntegraciÃ³n futura     |
| GAP-RWA-01        | ðŸŸ¡ Parcialmente resuelto  |

## GAP-ECON-01 â€” EconomÃ­a â€” RESUELTO Y VALIDADO TÃ‰CNICAMENTE

14/09/2026

Se implementÃ³ la integraciÃ³n de `EconomiaActivo` con Evidencia, HistorialActivo y
AuditEvent.

`actualizarEconomia()` conserva economÃ­a anterior y nueva, registra el `evidenciaId`
cuando corresponde y mantiene la trazabilidad de la modificaciÃ³n en Historial y
AuditorÃ­a.

Cadena validada:

`EconomÃ­a â†’ Evidencia â†’ HistorialActivo â†’ AuditEvent â†’ Firestore Emulator`

### Test de integraciÃ³n

`integration_test/activo_agro_service_economia_integration_test.dart`

Resultado:

`All tests passed!`

La prueba verifica:

- economÃ­a anterior;
- economÃ­a nueva;
- `evidenciaId`;
- trazabilidad en HistorialActivo;
- trazabilidad en AuditEvent.

**GAP-ECON-01 â€” RESUELTO Y VALIDADO TÃ‰CNICAMENTE.**


## Regla de continuidad

Los nuevos GAP detectados durante la implementaciÃ³n deberÃ¡n documentarse antes de modificarse.

Secuencia:

`GAP â†’ decisiÃ³n â†’ implementaciÃ³n â†’ test â†’ validaciÃ³n â†’ documentaciÃ³n â†’ commit`

## PrÃ³ximo paso

Continuar con la revisiÃ³n de los GAP pendientes de la matriz, priorizando aquellos que impacten directamente en la Ficha Maestra y en la trazabilidad histÃ³rica del Activo Agro.
## ðŸŽ¯ Objetivo prioritario de lanzamiento â€” Enero 2027

**Objetivo estratÃ©gico:** priorizar el lanzamiento de Agro Fields durante
**enero de 2027**.

Enero de 2027 se establece como **objetivo prioritario de planificaciÃ³n**,
pero no como una fecha rÃ­gida que justifique acelerar artificialmente el
desarrollo.

La planificaciÃ³n deberÃ¡ respetar los tiempos reales necesarios para:

- implementaciÃ³n;
- pruebas;
- estabilidad;
- resoluciÃ³n de GAPs relevantes;
- auditorÃ­a y trazabilidad;
- documentaciÃ³n;
- calidad funcional;
- dependencias tÃ©cnicas;
- preparaciÃ³n efectiva del producto para lanzamiento.

### Regla de prioridad

> **Enero 2027 es el objetivo; calidad, estabilidad y trazabilidad son condiciones.**

Por lo tanto:

- se priorizarÃ¡n las capacidades necesarias para alcanzar un lanzamiento sÃ³lido;
- se evitarÃ¡ incorporar funcionalidades secundarias que desvÃ­en innecesariamente
  el objetivo;
- no se considerarÃ¡ cerrado un trabajo sin evidencia real;
- no se omitirÃ¡n pruebas o auditorÃ­as para cumplir una fecha;
- si una tarea requiere mÃ¡s tiempo del previsto, se ajustarÃ¡ el cronograma;
- cualquier modificaciÃ³n significativa del objetivo temporal deberÃ¡ quedar
  registrada en Roadmap y BitÃ¡cora con su motivo.

**Principio rector:** avanzar con prioridad hacia enero de 2027, respetando
los tiempos reales del proyecto y sin sacrificar la calidad tÃ©cnica o
funcional de Agro Fields.
## GAP-RWA-02 â€” Derechos, relaciones jurÃ­dicas y titularidad

### Estado actual

ðŸŸ¡ **AUDITORÃA EN CURSO**

El GAP-RWA-02 continÃºa abierto como GAP general.

Se completÃ³ y validÃ³ tÃ©cnicamente el requisito:

**02.02 â€” Titular del derecho**

### 02.02 â€” Titular del derecho

ðŸŸ¢ **RESUELTO Y VALIDADO TÃ‰CNICAMENTE**

Se incorporÃ³ `RelacionJuridica` como modelo genÃ©rico asociado a `DerechoActivo`.

`ActivoAgroV2` incorpora:

`List<RelacionJuridica> relacionesJuridicas`

La relaciÃ³n conserva sujeto, tipo de sujeto, rol, estado, condiciones y temporalidad, vinculÃ¡ndose con el derecho mediante `derechoId`.

ValidaciÃ³n realizada mediante:

* `derecho_activo_model_test.dart`;
* `activo_agro_derechos_serializacion_test.dart`;
* `activo_agro_relacion_juridica_serializacion_test.dart`.

Resultado:

`00:02 +5: All tests passed!`

AnÃ¡lisis focalizado:

`flutter analyze lib/models/activos/activo_agro_model_v2.dart`

Resultado:

`No issues found!`

### 02.09 â€” Restricciones

ðŸŸ¢ **RESUELTO Y VALIDADO TÃ‰CNICAMENTE**

El requisito 02.09 se resolviÃ³ inicialmente mediante:

`DerechoActivo.condiciones`

mÃ¡s la infraestructura genÃ©rica existente de:

`Evidencia + DocumentaciÃ³n + AuditorÃ­a`

La evidencia queda vinculada al derecho mediante:

`elementoTipo = DerechoActivo`

`elementoId = derechoId`

`campoRelacionado = restricciones`

No se creÃ³ `RestriccionActivo`, ya que la matriz establece inicialmente una resoluciÃ³n basada en condiciones y evidencia/documentaciÃ³n.

ValidaciÃ³n realizada mediante:

`integration_test/activo_agro_service_derecho_restriccion_evidencia_integration_test.dart`

Resultado:

`02:06 +1: All tests passed!`

Commit:

`eca3eb2`

El cierre corresponde exclusivamente al requisito **02.09**.

GAP-RWA-02 continÃºa como **AUDITORÃA EN CURSO** hasta validar individualmente los restantes requisitos de la matriz.

### Alcance

El cierre corresponde Ãºnicamente al requisito **02.02**.

Los restantes requisitos de GAP-RWA-02 permanecen pendientes de auditorÃ­a individual.

### PrÃ³ximo criterio

Continuar con la matriz RWA-02 requisito por requisito, aplicando:

`Matriz â†’ GAP â†’ AuditorÃ­a del cÃ³digo real â†’ cambio mÃ­nimo â†’ test â†’ evidencia â†’ documentaciÃ³n â†’ commit`

No se debe marcar GAP-RWA-02 completo como resuelto hasta validar los requisitos restantes.

## GAP-RWA-02 — 02.28 Cambios regulatorios

### Estado

🟢 **02.28 RESUELTO Y VALIDADO TÉCNICAMENTE**

Durante la auditoría del requisito 02.28 se verificó que los cambios regulatorios pueden conservarse mediante el historial del Activo Agro, vinculando el evento con su norma de referencia y sus datos regulatorios relevantes.

El evento HistorialActivo conserva:

* tipoEvento = cambio_regulatorio;
* entidadRelacionada = norma;
* referenciaId = NORMA-2026-001;
* norma anterior y nueva;
* fechas de vigencia anterior y nueva;
* tipo de cambio;
* jurisdicción.

La evidencia queda vinculada al evento mediante:

* elementoTipo = HistorialActivo;
* elementoId = eventoRegulatorio.eventoId;
* campoRelacionado = cambio_regulatorio.

### Validación

Se creó y ejecutó:

integration_test/activo_agro_service_derecho_cambio_regulatorio_integration_test.dart

El test verificó:

* persistencia del Activo Agro;
* persistencia y recuperación del cambio regulatorio;
* referencia de la norma;
* datos del cambio regulatorio;
* persistencia de la evidencia;
* vinculación de la evidencia con el evento histórico;
* auditoría asociada a la creación de la evidencia.

Resultado:

01:06 +1: All tests passed!

### Auditoría arquitectónica

No fue necesario modificar:

* DerechoActivo;
* Evidencia;
* EvidenciaService;
* ActivoAgroServiceV2;
* ActivoAgroV2;
* UI.

Se reutilizó la infraestructura existente de historial, evidencia y auditoría.

### Alcance

Este cierre corresponde exclusivamente a:

**GAP-RWA-02 / requisito 02.28 — Cambios regulatorios.**

No implica el cierre completo de GAP-RWA-02.

Los demás requisitos de la matriz RWA-02 continúan sujetos a auditoría individual.

### Evidencia técnica

Test de integración:

integration_test/activo_agro_service_derecho_cambio_regulatorio_integration_test.dart

Resultado:

All tests passed

---

## Seguridad Firebase — Auditoría Firestore

### Estado

🟢 **VALIDADO TÉCNICAMENTE EN EL ALCANCE AUDITADO**

Se validaron mediante Firebase Emulator las reglas de:

* `chats`;
* `chats/{chatId}/mensajes`;
* `eventos_afectacion`.

La suite de reglas alcanzó:

**51/51 tests aprobados — 0 fallos.**

La validación incluye escenarios permitidos y prohibidos, consultas utilizadas por la aplicación, protección de participantes de chats y protección de eventos de afectación.

Este estado **no representa el cierre completo de la seguridad Firebase**. Permanecen pendientes de auditoría específica otras colecciones y Cloud Storage.

No se realizó deploy a Firebase.

Referencia documental:

`docs/BITACORA.md`

---

## Trabajo Operacional V1 — Estado

🟢 **VALIDADO TÉCNICAMENTE**

Se completó la implementación y validación de `TrabajoService` para `TrabajoOperacional V1`.

### Capacidades validadas

* creación de trabajos vinculados a un Activo Agro;
* persistencia en `trabajos`;
* generación de Auto-ID de Firestore;
* recuperación por ID;
* consulta por `activoAgroId`;
* auditoría mediante `AuditService`;
* registro en `auditoria_activos`;
* reglas Firestore específicas para `trabajos`;
* integración Firebase Auth + Firestore Emulator;
* ejecución real sobre Android Emulator.

### Evidencia

Test:

`integration_test/trabajo_service_integration_test.dart`

Resultado:

**+1: All tests passed!**

### Alcance V1

Trabajo Operacional queda técnicamente preparado como registro operativo vinculado al Activo Agro y su Expediente Digital.

Las capacidades de actualización, eliminación, reprogramación, incidentes, recursos, resultados y costos quedan como trabajo posterior y no forman parte de este cierre.

Referencia documental:

`docs/BITACORA.md`

### GAP-ID-01 — Identidad persistente y portabilidad Firestore → SQL

**Prioridad:** alta; requisito estructural previo a una migración de base de datos.

**Estado:** pendiente de auditoría y corrección.

**Objetivo:** preservar la identidad del Activo Agro y todas sus relaciones durante la evolución de Agro Fields V8 y una futura migración a SQL/PostgreSQL.

**Trabajo pendiente:**
1. Auditar el circuito `Campo → ActivoAgroV2 → persistencia`.
2. Definir la correspondencia entre ID documental de Firestore, `campoId`, `activoId` y futuras claves SQL.
3. Verificar dependencias, relaciones, historial, evidencias y auditoría.
4. Implementar el cambio mínimo que garantice una identidad persistente y recuperable.
5. Ejecutar pruebas de creación, conversión, persistencia, recuperación e integridad referencial.
6. Documentar resultados y evidencias antes de cerrar el GAP.

**Condiciones:** mantener `ActivoAgroV2`, preservar los IDs existentes, no migrar globalmente las referencias sin auditoría y no declarar la arquitectura lista para migración hasta comprobar la portabilidad.

**Criterio de aceptación:** los identificadores y las relaciones permanecen coherentes en el circuito actual y existe un mapeo explícito y verificable para SQL/PostgreSQL.

La implementación queda sujeta al resultado de la auditoría y a las pruebas correspondientes.

---

## Marketplace — Publicación sobre resumen público — Estado

🟢 **PASO 1 VALIDADO TÉCNICAMENTE** (06/11/2026, rama `gap-publicacion-resumen`, commit `0872e15`)

El marketplace ya no lee el expediente privado (`activos_agro`). Lee solo `activos_publicos`, un resumen de 13 datos publicables que nace pendiente de revisión y se ve recién cuando lo aprueba el administrador.

Evidencia: `flutter test` 80 aprobados (2 fallas conocidas de conexión), reglas 81/81 (PUB-01 a PUB-10).

Pendiente: bloquear en reglas que el dueño marque el expediente como publicado (prueba 10c), pantalla de administrador, checks de qué compartir, publicación por broker y prueba en la app real.

Paso 2 cerrado: ver sección siguiente.

Referencia documental:

`docs/BITACORA.md`

---

## Oportunidades privadas — Estado

🟢 **PASO 2 VALIDADO TÉCNICAMENTE** (06/11/2026, rama `gap-oportunidades-privadas`, commit `c1bd17b`)

`oportunidades_agro` deja de ser legible por cualquier usuario logueado: solo la leen el administrador y quien tiene el Activo. Los montos, la ubicación exacta, los documentos y las evidencias ya no quedan expuestos.

Evidencia: reglas 91/91 (OPOR-01 a OPOR-10).

Pendiente: resumen público de oportunidades cuando exista la pantalla del marketplace, y adaptar `obtenerOportunidadesActivas()`.

Paso 3 cerrado: ver sección siguiente.

Referencia documental:

`docs/BITACORA.md`

---

## Autorizaciones en las reglas — Estado

🟢 **PASO 3 VALIDADO TÉCNICAMENTE (V1)** (06/11/2026, rama `gap-autorizaciones-reglas`, commit `d11f766`)

Un encargado o profesional invitado puede trabajar sobre el Activo con una autorización activa y vigente: cargar trabajos, recursos, movimientos de stock y evidencias. No lee el expediente privado ni la auditoría.

Evidencia: `flutter test` 84 aprobados (2 fallas conocidas de conexión), reglas 110/110 (AUT-01 a AUT-19).

Pendiente: autorizaciones por lote o módulo, acceso parcial al expediente, pantalla para otorgar permisos y delegación.

Paso 4a cerrado: ver sección siguiente.

Referencia documental:

`docs/BITACORA.md`

---

## Documentos con vigencia — Estado

🟢 **PASO 4a VALIDADO TÉCNICAMENTE** (06/11/2026, rama `gap-documentos-vigencia`, commit `a718fc1`)

`DocumentoActivo` ahora guarda emisor, número, vencimiento, jurisdicción, transferibilidad (arranca en "desconocida"), marca de datos personales (se asume que sí) y ruta del archivo, y sabe si está vigente, por vencer (30 días) o vencido. Los documentos ya guardados se leen igual.

Evidencia: `flutter test` 95 aprobados (2 fallas conocidas de conexión).

Paso 4b cerrado: ver sección siguiente.

Referencia documental:

`docs/BITACORA.md`

---

## Subida de documentos a Storage — Estado

🟢 **PASO 4b VALIDADO TÉCNICAMENTE** (06/11/2026, rama `gap-documentos-storage`, commit `83b671d`)

Los documentos del expediente se suben a la carpeta privada del Activo. Sube y lee el dueño, quien cargó el expediente o quien tenga autorización en "documentación". Nadie reemplaza ni borra un documento ya subido.

Evidencia: `flutter test` 103 aprobados (2 fallas conocidas de conexión); reglas 127/127 (110 Firestore + 17 Storage, las primeras de Storage).

Pendiente: pantalla de subida, archivos de evidencias y subida sin conexión.

Paso 5 en curso: ver sección siguiente.

Referencia documental:

`docs/BITACORA.md`

---

## Migración Campo → Activo Agro V2 — Estado

🟢 **PASO 5 CERRADO** (5a y 5b: commit `9360b06`; 5c y 5d: ver sección siguiente) (06/11/2026, rama `gap-campo-migracion`, commit `9360b06`)

* 5a: la lista de chats del comprador lee el resumen público (ya no se rompe por no poder leer el expediente).
* 5b: el conversor Campo → Activo no inventa datos; el Activo migrado nace privado y conserva su ID.

Evidencia: `flutter test` 108 aprobados (2 fallas conocidas de conexión).

Próximo: **5c — migración controlada de `campos`** (previo conteo de documentos en la consola) y **5d — retiro de lo viejo** una vez comprobada la migración. Relacionado con GAP-ID-01.

Referencia documental:

`docs/BITACORA.md`

---

## Colección `campos` congelada — Estado

🟢 **PASO 5c/5d VALIDADO TÉCNICAMENTE** (06/11/2026, rama `gap-campo-migracion`, commits `67b42c5` y `65197ee`)

`campos` tenía 4 documentos de prueba: no se migraron ni se borraron. Quedó como archivo histórico de solo lectura (solo el administrador escribe) y se retiró la pantalla vieja que nadie abría.

Evidencia: `flutter test` 108 aprobados (2 fallas conocidas de conexión); reglas 134/134.

Próximo paso del plan: **Paso 6 — Producción por especie y operación protegida.**

Referencia documental:

`docs/BITACORA.md`

---

## Núcleo productivo ganadero — Estado

🟢 **PASO 6a-1 VALIDADO TÉCNICAMENTE** (10/11/2026, rama `gap-prod-01`, GAP-PROD-01, AF-083)

Existen las unidades productivas (potreros, corrales), los grupos (rodeos o lotes) y los eventos de solo agregar (alta, baja, movimiento, cambio de categoría y sanidad), con su regla en Firestore y el permiso nuevo "producción" para el encargado.

Evidencia: `flutter test` 131 aprobados (2 fallas conocidas de conexión); reglas 154/154.

Próximo: **6a-2 — servicio de eventos y cálculo de existencias**; la sanidad descuenta stock.

Referencia documental:

`docs/BITACORA.md`

---

## Servicio de producción y existencias — Estado

🟢 **PASO 6a-2 VALIDADO TÉCNICAMENTE** (10/11/2026, rama `gap-prod-01`, GAP-PROD-01)

Las existencias se calculan desde los eventos, por categoría y por unidad, y las cuentas que no cierran quedan como discrepancia. La vacuna descuenta el insumo del stock antes de guardar el evento.

Evidencia: `flutter test` 141 aprobados (2 fallas conocidas de conexión); reglas sin cambios (154/154).

Próximo: pantallas de producción y unión de la rama `gap-prod-01` a `main`.

Referencia documental:

`docs/BITACORA.md`

---

## Pantallas de producción ganadera — Estado

🟢 **PASO 6a-3 VALIDADO EN LA APP** (10/11/2026, rama `gap-prod-01-pantallas`, GAP-PROD-01)

Desde el detalle del campo, el botón "Producción" lleva a rodeos y potreros; se registran entradas, salidas, cambios de potrero, cambios de categoría y vacunas, y las cuentas que no cierran se muestran en rojo para revisar. Probado a mano con datos de prueba.

Evidencia: `flutter test` 141 aprobados (2 fallas conocidas de conexión); prueba manual en Chrome.

Próximo: botón "Corregir" un evento, archivar y cerrar desde la pantalla, y publicar las reglas nuevas en Firebase.

Referencia documental:

`docs/BITACORA.md`

---

## Reglas de Firestore en el proyecto real — Estado

🟢 **PUBLICADAS** (10/11/2026, `main` `e770b13`)

Las reglas probadas en el emulador (154/154) ya protegen el proyecto real; la app se probó a mano después de publicar y funciona.

Próximo: reglas de Storage (previa verificación de que Storage esté activado).

Referencia documental:

`docs/BITACORA.md`

---

## Storage en el proyecto real — Estado

🟢 **ACTIVADO Y PUBLICADO** (10/11/2026)

Proyecto en plan Blaze (alerta de presupuesto de USD 10), depósito en US-EAST1 sin costo y reglas de Storage publicadas. Probado subiendo un archivo.

Pendiente: App Check antes del lanzamiento.

Referencia documental:

`docs/BITACORA.md`

---

## Operación Agropecuaria Protegida — Estado

🟢 **GAP-OPER-01 CERRADO Y EN EL PROYECTO REAL** (10/11/2026, rama `gap-oper-01`, `main` = `140926f`)

Antes de entregar hacienda, granos u otro producto, el productor carga la venta: comprador, quién firma, importe, forma de pago, cheques y garantías. El sistema muestra la **lista de control antes de entregar (7 puntos)**, avisa los cheques **7 días antes** del vencimiento y marca los vencidos y rebotados. Solo lo ve el dueño (o un encargado autorizado); el broker no. Agro Fields no garantiza el pago.

* 7a-1: modelos y reglas (`061961d`)
* 7a-2: servicio y cálculos (`8100745`)
* 7a-3: pantallas, botón único para adjuntar y regla propia de Storage (`140926f`)

Evidencia: `flutter test` 184 aprobados (2 fallas conocidas de conexión); reglas 184/184; reglas de Firestore y Storage publicadas; prueba manual en Chrome con el proyecto real.

🟢 Después del lanzamiento: red de cheques entre productores (con revisión legal), bancos, SGR, aseguradoras y financiación.

Próximo: **botón "Adjuntar" en los Documentos del campo** (cierra la pantalla pendiente del paso 4b).

Referencia documental:

`docs/BITACORA.md`

---

## Pantalla de Documentos del campo — Estado

🟢 **PASO 4b COMPLETO, CON PANTALLA** (10/11/2026, rama `paso-4b-pantalla-documentos`, `main` = `68a6a25`)

Desde la ficha del campo, el botón "Documentos" muestra los documentos con su vigencia (avisa los vencidos y los que vencen en 30 días) y permite cargar uno nuevo con su archivo, usando el mismo botón "Adjuntar" de las operaciones. Probado a mano con el proyecto real.

Evidencia: `flutter test` 184 aprobados (2 fallas conocidas de conexión); prueba manual en Chrome.

Pendiente: agregar archivo a un documento existente, carga por el encargado (cambio de reglas), ver o descargar el archivo y catálogo por provincia.

Referencia documental:

`docs/BITACORA.md`

---

## Certificaciones en Documentos del campo — Estado

🟢 **GAP-CERT-01 (AF-095) VALIDADO** (12/11/2026, rama `gap-cert-01`)

Al cargar un documento de tipo "Certificación o certificado" se pregunta qué certifica y a qué animales o producción aplica. Avisa el vencimiento 30 días antes, como los demás documentos. Agro Fields no certifica.

Evidencia: `flutter test` 186 aprobados esperados (2 fallas conocidas de conexión); sin cambios en reglas.

Próximo 🔴: AF-090 ubicación del campo en el mapa, AF-092 emergencia + "disponible para recibir", AF-093 invitar al profesional, AF-089 traslado simple. También: rediseño de la pantalla de ingreso.

Referencia documental:

`docs/BITACORA.md`

---

## Pantalla de ingreso — Estado

🟢 **DISEÑO DE INGRESO VALIDADO** (12/11/2026, rama `diseno-ingreso-v8`)

Atardecer, logo dibujado, AGRO FIELDS (sin "V8" para los usuarios), lema y botón "Ingresar con Google". Probada a mano en Chrome.

Pendiente: revisar la marca en INPI/DINAPI y el dominio antes de enero.

Referencia documental:

`docs/BITACORA.md`

---

## Ubicación del campo en el mapa — Estado

🟢 **GAP-TERR-01 (AF-090) VALIDADO** (12/11/2026, rama `gap-terr-01`)

Desde la ficha del campo se marca el punto en un mapa de OpenStreetMap; queda en el historial. La ubicación exacta es privada. Es la base de Territorio, Emergencias y Transporte.

Próximo 🔴: AF-092 emergencia + "disponible para recibir", AF-093 invitar al profesional, AF-089 traslado simple.

Referencia documental:

`docs/BITACORA.md`

---

## Logo e Inicio nuevos — Estado

🟢 **DISEÑO DEL INICIO VALIDADO** (12/11/2026, rama `diseno-inicio-v8`)

Logo nuevo como imagen; Inicio con barra oscura, saludo de atardecer, resumen con datos reales, accesos en columnas y botón central para crear campo. Probado en Chrome.

Próximo 🔴: AF-092 emergencia + "disponible para recibir", AF-093 invitar al profesional, AF-089 traslado simple.

Referencia documental:

`docs/BITACORA.md`

---

## Emergencias del campo — Estado

🟢 **GAP-EMERG-01 (AF-092) VALIDADO** (12/11/2026, rama `gap-emerg-01`)

Desde la ficha del campo se registran emergencias (inundación, sequía, incendio, granizo, helada, tormenta, enfermedad o plaga) que quedan en la historia del campo como declaradas, y el dueño puede marcar su campo como "disponible para recibir" (voluntario, por ahora solo lo ve él).

Próximo 🔴: AF-093 invitar al profesional y AF-089 traslado simple.

Referencia documental:

`docs/BITACORA.md`

---

## Profesionales invitados — Estado

🟢 **GAP-PROF-01 (AF-093) VALIDADO** (12/11/2026, rama `gap-prof-01`)

El dueño invita a su agrónomo, veterinario o técnico con un código; el profesional registra visitas, recomendaciones, diagnósticos e informes (solo agregar, declarados) sin ver el resto del expediente. El dueño puede quitar el acceso. Reglas: 200/200 y publicadas.

Próximo 🔴: AF-089 traslado simple (sobre el núcleo común de transporte).

Referencia documental:

`docs/BITACORA.md`

---

## Traslados — Estado

🟢 **GAP-MOV-01 (AF-089) VALIDADO** (12/11/2026, rama `gap-mov-01`)

Traslado simple sobre el núcleo común de transporte (una colección para todas las actividades), con estados y control de coherencia declarado/recibido. Reglas 216/216 y publicadas. Probado: 50 novillos enviados, 48 recibidos → aviso rojo.

✅ **Los 5 🔴 nuevos del Concepto para enero 2027 están hechos** (AF-095, AF-090, AF-092, AF-093, AF-089).

Próximo: centrar formularios en pantallas grandes; revisar el cuadro de lanzamiento contra lo que falta (funcionamiento sin señal, inglés, ingresos/monetización, suelo).

Referencia documental:

`docs/BITACORA.md`

---

## App centrada y ficha del campo — Estado

🟢 **DISEÑO VALIDADO** (12/11/2026, rama `diseno-ancho-app`)

Toda la app centrada con ancho máximo en la compu. Ficha del campo nueva: resumen, próximo paso, módulos en columnas con descripción e historial del campo visible.

Próximo: revisar el cuadro de lanzamiento (funcionamiento sin señal, inglés, ingresos/monetización, suelo).

Referencia documental:

`docs/BITACORA.md`

---

## PLAN DE LANZAMIENTO — revisado el 12/11/2026

Comparación de los documentos "cuadro de lanzamiento" (01/10) y "camino a enero 2027" con el código real. Aprobado por Javier el 12/11/2026.

### ✅ Ya funcionando

Activo Agro y expediente (historial y auditoría) · Documentos con vigencia, archivos y certificaciones · Permisos (encargado y profesional invitado) · Marketplace con resumen público separado y chat · Producción ganadera (rodeos, potreros, altas, bajas, movimientos, categoría, sanidad) · Operaciones protegidas · Emergencias · Mapa · Traslados · Seguridad 216/216 publicada · Diseño de ingreso, Inicio y ficha.

### 🔴 Falta para enero (en este orden)

1. Agricultura (núcleo): lote, campaña, siembra, cosecha — reutiliza unidades y eventos productivos ("siembra" y "cosecha" ya preparados).
2. Monitoreo (motor común), con "fuente del dato".
3. Aplicación terrestre.
4. Stock e insumos ("Recursos y trabajos") — modelo y reglas existen; falta pantalla.
5. Economía (núcleo): gastos por categoría, mes y actividad (sin contabilidad).
6. Suelo y pesajes (pantallas sobre datos existentes).
7. Seguridad restante: `solicitudes_contacto`, `inversiones`, `publicaciones_inversion`.
8. Funcionamiento sin señal (configurar y probar).
9. Términos de uso y privacidad.
10. Plan Fundadores en dos grupos (100 de gestión + 100 inmobiliarias y brokers) y precio.
10b. Pantalla simple de aprobación de publicaciones para el admin (hoy se aprueban a mano desde la consola; con 100 inmobiliarias no da abasto).
11. Datos de demo, QA integral, Android y web publicados.
12. Inglés: 🟡 después de enero (decisión de Javier, 12/11/2026).

### 📅 Calendario

* 13–20/11: Agricultura + Monitoreo.
* 21–27/11: Aplicación terrestre + Stock e insumos.
* 28/11–04/12: Economía + Suelo + Pesajes.
* 05–11/12: Seguridad restante + Sin señal + Términos y privacidad.
* 12–18/12: Plan Fundadores y precio + Pantalla de aprobación de publicaciones + Datos de demo (+ inglés básico si alcanza).
* 19–31/12: QA integral, Android y web publicados, copias de seguridad, piloto con usuarios reales.
* Enero 2027: lanzamiento (corregir, observar, mejorar; sin módulos nuevos).

Referencia documental:

`docs/BITACORA.md`

### 👥 Usuarios Fundadores — decidido el 12/11/2026

* **Dos grupos de 100:** 100 usuarios de gestión (productores) y 100 inmobiliarias y brokers. Cada uno con 12 meses de Pro gratis.
* **Por qué los dos:** se ayudan entre sí. Cada inmobiliaria que carga un campo le abre la puerta al dueño, que después puede pasar a gestión. Inmobiliarias y brokers son el primer ingreso realista.
* **Dos zonas, no dos países enteros:** una en Paraguay y una en Argentina, para que los usuarios se crucen entre ellos (zonas a elegir).
* **Empezar por las inmobiliarias:** conseguir primero 10 a 15 inmobiliarias y brokers; cada uno trae campos y dueños.
* **Por tandas:** primero 20 (10 + 10), corregir lo que falle, después 50, después el resto.
* **Frase para cada grupo:**
  * Gestión: "Tu campo ordenado, con su historia y documentos al día".
  * Inmobiliarias y brokers: "Publicá campos con información verificada y ganá la confianza del comprador".
* **Qué medir:** productores que vuelven cada semana; inmobiliarias que cargan más de un campo.
* **Pendiente:** elegir las dos zonas; sumar 2 o 3 verificadores reales (escribanos, agrónomos, cooperativas).

Referencia: `Desktop\App\Matriz remunerativa V0.2 (12-11-2026).docx`

---

## Agricultura — Estado

🟢 **GAP-AGRO-01 VALIDADO** (12/11/2026, rama `gap-agro-01`)

Cultivos de la campaña sobre el núcleo productivo: siembra, cosecha, rendimiento calculado y aviso si la cosecha supera lo sembrado.

Próximo según el plan: **Monitoreo** (motor común).

Referencia documental:

`docs/BITACORA.md`

---

## Monitoreo — Estado

🟢 **GAP-MON-01 VALIDADO** (13/11/2026, rama `gap-mon-01`)

Monitoreo como evento productivo (plaga, maleza, enfermedad, estado del cultivo, agua), con nivel, "fuente del dato" y recomendación; aviso rojo si el último monitoreo de algo está en nivel alto. `flutter test` 222 + 2 conocidas; reglas 230/230.

Con esto quedan hechos los puntos 1 y 2 del plan (Agricultura + Monitoreo), dentro del calendario 13–20/11.

Próximo según el plan: **Aplicación terrestre**.

Referencia documental:

`docs/BITACORA.md`

---

## Aplicación terrestre — Estado

🟢 **GAP-APLI-01 VALIDADO** (13/11/2026, rama `gap-apli-01`)

Aplicación como evento productivo del cultivo: hectáreas, producto, dosis, quién aplicó, receta y condiciones (viento, temperatura, humedad del aire). Aviso antes de guardar con viento mayor a 15 km/h y aviso si se aplicaron más hectáreas que las sembradas.

Con esto quedan hechos los puntos 1, 2 y 3 del plan, adelantados al calendario (el 3 estaba previsto para 21–27/11).

Pendiente de diseño: mejorar los colores de todas las pantallas (Javier, 13/11/2026; se mostraron 3 opciones).

Próximo según el plan: **Stock e insumos** ("Recursos y trabajos"), que también conecta el descuento de producto en la aplicación.

Referencia documental:

`docs/BITACORA.md`

---

## Stock e insumos — Estado

🟢 **GAP-STOCK-01 VALIDADO** (13/11/2026, rama `gap-stock-01`)

Pantallas de stock (productos, saldo, stock bajo, entradas, consumos y ajustes con historia) y descuento del producto desde la aplicación terrestre. El stock inicial entra como movimiento: nada aparece sin rastro.

Con esto quedan hechos los puntos 1 a 4 del plan (Agricultura, Monitoreo, Aplicación terrestre, Stock e insumos), adelantados al calendario (el 4 estaba previsto para 21–27/11).

Próximo según el plan: **Economía (núcleo)**: gastos por categoría, mes y actividad, sin contabilidad.

Referencia documental:

`docs/BITACORA.md`

---

## Diseño V8 campo — Estado

🟢 **VALIDADO** (13/11/2026, unido a main `ed40b7c`). Barra con foto y logo, fondo con paisaje, tarjetas cálidas, íconos en círculo, resumen y pantallas vacías. Pendiente: Inicio y ficha del campo con el mismo estilo (en la etapa de pulido de diciembre).

---

## Economía — Estado

🟡 **GAP-ECO-01 ENTREGADO** (13/11/2026, rama `gap-eco-01`), pendiente de prueba.

Gastos por mes, categoría y actividad, en su moneda, con comprobante opcional; solo el dueño o el ámbito "economia". Sin contabilidad.

Con esto quedan hechos (o en prueba) los puntos 1 a 5 del plan, adelantados al calendario (el 5 estaba previsto para 28/11–04/12).

Próximo según el plan: **Suelo y pesajes** (pantallas sobre datos existentes).

Referencia documental:

`docs/BITACORA.md`

---

## Caso Pretto — impacto en el plan (13/11/2026)

* El punto 6 del plan (**Suelo y pesajes**) suma **AF-102**: % de mortandad del rodeo y ganancia diaria de peso, calculados con datos que ya se cargan (sin módulo nuevo).
* Para después de enero: alimentación y conversión (AF-103), identificación individual (AF-104), hitos del establecimiento (AF-105), ingresos y resultado (AF-106) 🟡; red de aliados (AF-107) y comercialización B2B (AF-108) 🟢.

Referencia: Concepto General sección 25.1; `docs/BITACORA.md`.

---

## Economía — Estado (actualizado)

✅ **GAP-ECO-01 CERRADO** (13/11/2026): probado en Chrome, unido a main y subido (main = a310f1e).

## Suelo y pesajes — Estado

✅ **GAP-SUELO-01 CERRADO** (13/11/2026): pantalla para cargar el suelo; main = 04002d7.

🟡 **GAP-PESO-01 + AF-102 ENTREGADO** (13/11/2026, rama `gap-peso-01`), pendiente de prueba y de publicar reglas: peso en el pesaje, ganancia diaria de peso y % de mortandad (últimos 12 meses), calculados con los eventos.

Con esto quedan hechos (o en prueba) los puntos 1 a 6 del plan. Siguiente: **7. Seguridad restante** (`solicitudes_contacto`, `inversiones`, `publicaciones_inversion`).

Referencia documental:

`docs/BITACORA.md`
