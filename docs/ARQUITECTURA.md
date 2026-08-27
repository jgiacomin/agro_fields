\# ARQUITECTURA AGRO FIELDS
\## Estado actual
Repositorio:

Agro Fields
Commit base:

79e7095

Arquitectura documentada:

22/07/2026

Versión:

V8.0
\# 1. Principio general
Agro Fields utiliza una arquitectura orientada a separación de responsabilidades.

Screen

↓

Service

↓

Model

↓

Firebase

+
  
Core / Auditoría y Trazabilidad
(capa transversal)
Cada capa tiene una responsabilidad definida.
Reglas fundamentales:
\- Las pantallas no acceden directamente a Firebase.

\- Los servicios manejan la comunicación con datos.

\- Los modelos representan información del negocio.

\- Los modelos no contienen lógica de acceso a datos.

\- No crear archivos duplicados cuando un modelo existente pueda evolucionar.

\- Mantener trazabilidad histórica mediante Git.

\- Cada cambio importante debe quedar documentado mediante bitácora.

\-  La auditoría registra eventos y cambios relevantes sin alterar la separación principal de responsabilidades.

\# 2. Estructura actual de lib/

lib/
├── core
├── enums
├── models

├── screens

├── services

└── widgets

\# 3. Core

Ubicación:

lib/core/
core/audit

Responsabilidad:

Gestionar la auditoría transversal del ecosistema.

Registra:

- eventos;
- responsables;
- cambios;
- versiones;
- evidencias;
- trazabilidad histórica.

Responsabilidad:
Contiene elementos generales utilizados por toda la aplicación.

Actualmente:

\## core/auth
Archivo:
auth\_gate.dart
Responsabilidad:
Controlar el flujo de autenticación inicial.

Futuro:

Podrá incorporar:

\- permisos de usuario;

\- roles;

\- perfiles;

\- acceso según tipo de actor.

\## core/constants
Responsabilidad:
Valores constantes del sistema.

Ejemplos futuros:

\- configuraciones;

\- estados;

\- parámetros generales.
\## core/errors

Responsabilidad:
Manejo centralizado de errores.

\## core/theme

Responsabilidad:

Configuración visual global.
\## core/utils
Responsabilidad:
Herramientas auxiliares reutilizables.
\# 4. Models

Ubicación:

lib/models/

Responsabilidad:
Representar las entidades principales del ecosistema Agro Fields.

Los modelos no contienen:
\- acceso a Firebase;

\- lógica de negocio compleja.
Representan información del dominio.
\# 5. Modelos principales actuales
\## Activo Agro V2

Archivo:
models/activos/activo\_agro\_model\_v2.dart

Responsabilidad:
Representar la unidad principal del ecosistema.
El Activo Agro incluye:
\- identidad;

\- ubicación;

\- producción;

\- economía;

\- documentación;

\- confianza;

\- historial;

\- participantes.

\- auditoría.
No representa una publicación comercial.
Representa un activo productivo real.

\## Confianza

Archivo:
confianza\_activo\_model.dart
Responsabilidad:

Representar información relacionada al Índice de Confianza.

Base para:
\- evidencias;

\- validaciones;

\- profesionales;

\- historial;

\- trazabilidad.

\## Economía

Archivo:

economia\_activo\_model.dart

Responsabilidad:

Representar información económica del activo.

Futuro:
Integrará:
\- inversión requerida;

\- costos estimados;

\- modelo productivo;

\- ingresos proyectados;

\- escenarios posibles;

\- riesgos identificados;

\- expansión productiva;

\- expectativas declaradas por productor o propietario.

Agro Fields no garantiza rentabilidad.

La plataforma organiza información para que un inversor pueda analizar:

\- situación actual;

\- fundamentos del proyecto;

\- hipótesis productivas;

\- evolución esperada.

\## Documentación
Archivo:
documentacion\_activo\_model.dart
Responsabilidad:
Representar documentación asociada al activo.

\## Producción
Archivo:

modulo\_produccion\_model.dart

Responsabilidad:

Representar características productivas.

Futuro:
Integrará:
\- agricultura;

\- ganadería;

\- vitivinicultura;

\- proyectos mixtos;

\- ciclos productivos;

\- historial productivo;

\- expansión productiva.
\# 6. Trazabilidad productiva y económica del Activo
Responsabilidad:

Registrar la evolución histórica del Activo Agro.
La trazabilidad permitirá conocer:

\## Productiva
\- quién produce;

\- qué produce;

\- actividad desarrollada;

\- superficie utilizada;

\- ciclos productivos;

\- historial;

\- mejoras realizadas;

\- capacidad de expansión.

\## Económica

Registrar:
\- inversión inicial;

\- costos;

\- modelo económico;

\- objetivos del proyecto;

\- necesidades de capital;

\- expectativas del propietario/productor;

\- escenarios futuros.
Objetivo:
Que un inversor pueda comprender el origen, evolución y proyección del activo antes de tomar una decisión.
\# 7. Screens

Ubicación:
lib/screens/
Responsabilidad:
Interfaz de usuario.
Las pantallas muestran información y reciben acciones del usuario.

No deben:
\- consultar Firebase directamente;

\- contener reglas de negocio.

\## Módulos actuales
auth

Autenticación.

campos

Gestión inicial de activos/campos.
chat
Comunicación entre usuarios.
dashboard

Panel principal.

inversiones
Visualización y participación en oportunidades.
solicitudes
Gestión de contactos.
\# 8. Services
Ubicación:
lib/services/
Responsabilidad:

Contener lógica de acceso y operaciones.
Ejemplos:
\## activo\_agro\_service\_v2.dart
Responsabilidad:

Gestionar operaciones del Activo Agro.
\## confianza\_activo\_service.dart

Responsabilidad:
Gestionar información del Índice de Confianza.
\## inversion\_service.dart

Responsabilidad:
Gestionar operaciones relacionadas a inversiones.
\## chat\_service.dart
Responsabilidad:
Gestionar comunicación entre usuarios.

Regla:
Los servicios son el puente entre aplicación y Firebase.
\# 9. Widgets

Ubicación:
lib/widgets/

Responsabilidad:

Componentes visuales reutilizables.

Ejemplo:

campo\_card.dart

Futuro:

Componentes para:

\- tarjetas de activos;

\- indicadores de confianza;

\- perfiles profesionales;

\- oportunidades de inversión.

\# 10. Evolución prevista V8

Sobre esta arquitectura crecerán:
\## Inteligencia Artificial Agro Fields
La IA será una capa transversal del ecosistema.
Participará en:

Activo Agro

↓
Información
↓

Confianza
↓

Profesionales

↓

Inversión

Funciones:
\- explicación de activos;

\- análisis inicial;

\- detección de información faltante;

\- acompañamiento al inversor;

\- comparación de oportunidades;

\- generación de resúmenes.
La IA no reemplaza:

\- profesionales;

\- análisis técnicos;

\- decisiones legales;

\- decisiones financieras.
\## Red Profesional
Integración de:

\- ingenieros agrónomos;

\- veterinarios;

\- abogados;

\- escribanos;

\- contadores;

\- especialistas.

Cada intervención quedará asociada a:

Profesional

↓

TPAF
↓
Activo Agro

\## TPAF

Credencial profesional digital.
Asociará:

\- profesional;

\- identidad;

\- intervención;

\- activo;

\- fecha;

\- validación;

\- historial.
\## Marco legal internacional
Nueva capacidad:
Analizar restricciones por:

\- país;

\- provincia/estado;

\- municipio/localidad.
El motor deberá considerar:
\- ubicación del activo;

\- nacionalidad del inversor;

\- tipo de operación;

\- normativa vigente.

Resultado:

\- operación disponible;

\- requiere revisión profesional;

\- operación restringida.

Objetivo:

Acompañar la trazabilidad legal antes de una operación.
\## Escalabilidad internacional

Agro Fields debe permitir analizar activos agropecuarios en diferentes mercados.
Ejemplos:
\- Argentina;

\- Venezuela;

\- Brasil;

\- Uruguay;

\- otros países.

Cada activo deberá mantener:

\- ubicación territorial;

\- contexto productivo;

\- marco legal aplicable;

\- profesionales disponibles;
\- índice de confianza.

Objetivo:
Crear una infraestructura internacional de confianza agropecuaria.
\# 11. Regla de crecimiento
Agro Fields crecerá evolucionando la arquitectura existente.

No se crearán versiones paralelas innecesarias.
Ejemplo:

Correcto:
Modificar:

activo\_agro\_model\_v2.dart

Incorrecto:

Crear:

activo\_agro\_model\_v3.dart
La historia del cambio queda registrada mediante Git.

\# 12. Metodología de evolución
Cada avance debe registrar:
\## Objetivo
Qué se busca construir.

\## Desarrollo

Cambios realizados.

\## Commit Git
Registro técnico del cambio.

\## Bitácora

Documentación histórica.

\## Próximo paso
Continuidad del desarrollo.
\# 13. Objetivo arquitectónico
Construir una plataforma donde:
Datos

+

Profesionales

+

Tecnología
+

IA

+
Trazabilidad
+
Auditoría
+
Marco legal
generen confianza

\# 14. Ciclo de vida del Activo Agro
El Activo Agro representa una unidad productiva viva.
No es una publicación estática.

Su información evoluciona durante todo su ciclo.

El ciclo contempla:
Creación
↓
Validación inicial
↓
Carga de información
↓

Evaluación de confianza
↓
Participación profesional
↓
Publicación comercial
↓
Contacto
↓
Negociación

↓
Inversión
↓
Seguimiento

↓
Historial
Cada etapa debe dejar registro histórico.
\## Estados futuros del Activo
El activo podrá atravesar diferentes estados:
\- borrador;

\- información incompleta;

\- activo validado;

\- publicado;

\- en análisis;

\- con profesionales participantes;

\- oportunidad de inversión;

\- activo invertido;

\- histórico.
El cambio de estado debe quedar registrado.
\# 15. Modelo de Confianza Agro Fields
La confianza es un elemento central del ecosistema.
El Índice de Confianza no representa:
\- rentabilidad garantizada;

\- valuación financiera;

\- recomendación de inversión.
Representa:

El nivel de información, respaldo y trazabilidad disponible.
El índice se construye mediante:
Información
\+

Documentación
\+

Evidencias

\+

Profesionales
\+

Historial
\+

Actualizaciones
\+

Auditoría
Factores posibles:
\## Identidad
\- propietario;

\- productor;

\- empresa;

\- participantes.
\## Información productiva

\- actividad;

\- superficie;

\- producción;

\- capacidad instalada.

\## Documentación

\- títulos;

\- permisos;

\- análisis;

\- certificados.
\## Validación profesional
\- intervenciones;

\- informes;

\- evaluaciones.

\## Historial

\- cambios;

\- evolución;

\- eventos relevantes.

\# 16. Expansión Productiva del Activo
Un Activo Agro puede crecer mediante nuevos proyectos.
Ejemplos:
Ganadería:
\- aumento de rodeo;

\- mejora genética;

\- incorporación tecnológica.
Agricultura:
\- nuevas hectáreas;

\- nuevos cultivos;

\- rotaciones.

Vitivinicultura:

\- nuevas variedades;

\- ampliación de bodegas;

\- desarrollo comercial.
Cada expansión deberá registrar:
\- objetivo;

\- responsable;

\- inversión necesaria;

\- plazo estimado;

\- producción esperada;

\- impacto económico;

\- profesionales involucrados.
El objetivo es que el inversor pueda comprender:
Situación actual
\+

Proyecto futuro

\+

Necesidad de capital
\+
Resultado esperado

\# 17. Modelo de inversión

La inversión dentro de Agro Fields estará vinculada al Activo Agro.

No se invierte sobre una publicación.

Se participa sobre un activo con información estructurada.

La información para un inversor podrá incluir:

\## Situación actual

\- descripción;

\- producción;

\- infraestructura;

\- ubicación.
\## Necesidad del proyecto
\- capital requerido;

\- destino de fondos;

\- plazo.

\## Proyección

\- crecimiento esperado;

\- escenarios;

\- riesgos;

\- oportunidades.

\## Seguimiento

El inversor podrá acceder a:
\- evolución del activo;

\- reportes;

\- avances;

\- cambios importantes.

\# 18. Trazabilidad legal territorial

Las operaciones agropecuarias pueden depender de múltiples niveles regulatorios.

Agro Fields deberá contemplar restricciones por:
País

↓

Provincia / Estado
↓

Departamento

↓

Municipio / Localidad
El sistema deberá identificar:

\- ubicación del activo;

\- tipo de operación;

\- características del inversor;

\- nacionalidad;

\- tipo de participación.

Ejemplos:

Un inversor extranjero puede tener:
\- límite de adquisición;

\- restricciones territoriales;

\- requisitos adicionales;

\- necesidad de autorización.

El sistema deberá:

\- detectar posibles restricciones;

\- informar condiciones;

\- solicitar revisión profesional;

\- guardar historial legal.

Agro Fields no reemplaza asesoramiento jurídico.
Actúa como sistema de prevención y trazabilidad.

\# 19. Red Profesional Agro Fields

La confianza requiere conocimiento especializado.

La red profesional podrá integrar:
\- ingenieros agrónomos;

\- veterinarios;

\- abogados;

\- escribanos;

\- contadores;

\- tasadores;

\- agrimensores;

\- consultores;

\- especialistas financieros.
Cada profesional tendrá un perfil verificable.
Información asociada:
\- identidad;

\- especialidad;

\- matrícula;

\- experiencia;

\- intervenciones;

\- reputación.

\# 20. Token Profesional Agro Fields (TPAF)

El TPAF representa una credencial digital profesional.

No es:

\- criptomoneda;

\- instrumento financiero.
Su función es acreditar:

Profesional

↓

Identidad

↓

Especialidad

↓

Intervención

↓

Activo relacionado

Cada acción profesional genera trazabilidad:
Ejemplo:

Ingeniero Agrónomo

↓

Informe productivo

↓

Activo Agro

↓

Fecha

↓
Validación

\# 21. Inteligencia Artificial Agro Fields

La inteligencia artificial será una capa transversal.

Su objetivo es mejorar comprensión y acceso a la información.

La IA podrá:
\## Para productores
\- organizar información;

\- detectar faltantes;

\- preparar activos.

\## Para inversores

\- explicar oportunidades;

\- resumir activos;

\- comparar alternativas;

\- identificar preguntas importantes.
\## Para profesionales

\- asistir análisis;

\- organizar documentación;

\- facilitar reportes.

La IA no reemplaza:
\- criterio profesional;

\- evaluación legal;

\- análisis financiero.

\# 22. Auditoría e historial del sistema

Toda modificación importante debe conservar historial.

Ejemplos:

Cambio de propietario

↓

Registro histórico

Nueva documentación

↓

Registro histórico

Nueva evaluación profesional

↓

Registro histórico

Cambio productivo

↓

Registro histórico
La trazabilidad permite reconstruir la evolución del activo.

22.1 Arquitectura de Auditoría y Trazabilidad (Audit Trail)
Objetivo
La auditoría es una capa transversal del ecosistema Agro Fields destinada a registrar eventos relevantes y conservar la evolución histórica de los activos, operaciones e interacciones.

Su objetivo es fortalecer la confianza entre las partes mediante información verificable.

Principio arquitectónico
La auditoría no representa un módulo comercial independiente.

Es una capacidad de infraestructura utilizada por diferentes componentes del ecosistema:

Activos Agro.
Inversiones.
Negociaciones.
Chat.
Profesionales.
Documentación.
Reportes.
Funcionamiento
Los servicios generan eventos de auditoría cuando ocurre una acción relevante.

Ejemplo:

Actualización de activo

↓

Servicio correspondiente

↓

Registro Audit Event

↓

Historial del Activo Agro

Información registrada
Cada evento podrá contener:

identificador del evento;
usuario responsable;
rol;
fecha y hora;
módulo involucrado;
acción realizada;
elemento afectado;
estado anterior;
estado nuevo;
referencia histórica.
Versionado
La información relevante no debe perderse mediante reemplazos directos.

Cada cambio importante genera un nuevo registro histórico.

Ejemplos:

Nueva documentación

↓

Evento de auditoría

↓

Historial documental

Cambio productivo

↓

Evento de auditoría

↓

Evolución productiva del activo

Arquitectura futura
Ubicación propuesta:

lib/core/audit/

Componentes:

AuditEvent
Modelo que representa un evento histórico.

AuditService
Servicio central encargado de registrar eventos.

AuditRepository
Persistencia y consulta de eventos.

AuditTypes
Clasificación de eventos.

Ejemplos:

creación;
modificación;
publicación;
validación;
negociación;
inversión;
intervención profesional.
AuditLogger
Registro uniforme desde los servicios.

Regla fundamental
Ningún módulo debe escribir directamente en auditoría.

Todos los registros deben pasar por AuditService.

Beneficios:

consistencia;
menor duplicación;
mantenimiento simplificado;
evolución futura.
22.2 Certificado de Trazabilidad Agro Fields
Concepto futuro
Agro Fields podrá generar un Certificado de Trazabilidad asociado a un Activo Agro cuando exista suficiente información histórica verificable.

El certificado representa:

historial registrado;
trazabilidad de modificaciones;
documentación asociada;
participación profesional;
evidencias disponibles.
El certificado no representa:
garantía de rentabilidad;
valuación financiera;
recomendación de inversión;
garantía productiva.
Relación dentro del ecosistema
Activo Agro V2

↓

Historial

↓

Auditoría

↓

Evidencias

↓

Índice de Confianza

↓

Certificado de Trazabilidad Agro Fields

Sobre el punto donde aparece Blockchain
En este archivo no aparece, lo cual está correcto.

Mantendría esa decisión.

No agregaría Blockchain porque no forma parte del diseño actual.

La confianza de Agro Fields está basada en:

Información

+

Evidencias

+

Profesionales

+

Historial

+

Auditoría

+

IA como asistencia
\# 23. Evolución futura de estructura
La arquitectura actual seguirá creciendo sobre:
lib/
models/
&#x20;   activos/
&#x20;   profesionales/
&#x20;   legales/
&#x20;   inversiones/

&#x20;   inteligencia/
services/
&#x20;   activo\_service

&#x20;   profesional\_service

&#x20;   legal\_service

&#x20;   ia\_service

&#x20;   trazabilidad\_service
screens/

&#x20;   profesionales/

&#x20;   analisis/

&#x20;   legales/

&#x20;   oportunidades/

Esta estructura es planificación futura.

No se crean archivos hasta existir una necesidad funcional.

\# 24. Reglas de documentación


Todo módulo nuevo debe incluir:
\## Modelo

Define la información.

\## Servicio
Gestiona operaciones.

\## Pantalla

Permite interacción.

\## Documentación

Explica propósito y funcionamiento.

\## Bitácora

Registra evolución.

\# 25. Principio final Agro Fields

Agro Fields no busca solamente conectar compradores y vendedores.

Busca construir una infraestructura digital donde:

La tierra tenga información.

La producción tenga contexto.

Los profesionales aporten respaldo.

Los inversores comprendan oportunidades.
La tecnología genere trazabilidad.

El verdadero valor del ecosistema es:

Confianza construida mediante información verificable.


## Capa de Valorización y Mercado de Activos Agro

### Objetivo

Evolucionar Agro Fields desde un sistema de registro de activos agropecuarios hacia una plataforma de identificación, evaluación, valorización y conexión de oportunidades agro.

El activo agro no será representado solamente por superficie o ubicación, sino por un conjunto de atributos verificables:

- capacidad productiva
- disponibilidad de recursos
- infraestructura
- documentación
- historial
- nivel de confianza
- potencial económico


### Diferencial estratégico

Los sistemas tradicionales muestran propiedades rurales.

Agro Fields representa activos agro productivos con información estructurada y trazabilidad.


Flujo:

Tierra
 ↓
Campo
 ↓
Activo Agro
 ↓
Activo Verificado
 ↓
Activo Valorizado
 ↓
Activo con oportunidad de mercado


### Evolución futura

Esta capa permitirá:

- búsqueda avanzada de activos
- comparación entre activos
- estimación de valor
- conexión entre propietarios e inversores
- análisis de oportunidades productivas

# EVOLUCIÓN ARQUITECTÓNICA — CONTINUIDAD DIGITAL DEL ACTIVO AGRO

## 1. Nuevo principio estratégico

Agro Fields evoluciona desde una plataforma orientada principalmente a
publicaciones, oportunidades y contacto hacia una infraestructura digital
para la continuidad de los Activos Agro.

Agro Fields administra la continuidad digital de los Activos Agro y registra
la evolución de sus:

- relaciones;
- información;
- actividades;
- documentos;
- evidencias;
- proveedores;
- profesionales;
- operadores;
- clientes;
- productores;
- inversiones;
- operaciones;
- eventos;
- historial;
- validaciones.

El objetivo no es solamente publicar un activo.

El objetivo es construir y mantener su identidad, información, relaciones y
evolución a lo largo del tiempo.

---

## 2. Principio de continuidad

Un Activo Agro no debe considerarse finalizado cuando termina:

- una publicación;
- una consulta;
- una negociación;
- una operación comercial;
- una venta;
- una inversión;
- un cambio de propietario.

El activo físico continúa existiendo.

Por lo tanto, su identidad digital y su expediente deben poder continuar
evolucionando.

Conceptualmente:

ACTIVO FÍSICO
        ↓
IDENTIDAD DIGITAL
        ↓
EXPEDIENTE
        ↓
HISTORIA
        ↓
CONTINUIDAD

La información actual representa solamente el estado presente.

El historial representa la evolución del activo.

---

## 3. Expediente Permanente del Activo Agro

El Expediente Permanente representa conceptualmente la memoria digital
acumulada del Activo Agro.

No constituye necesariamente un nuevo modelo independiente.

Debe evolucionar sobre la arquitectura existente de ActivoAgroV2 y sus
módulos relacionados.

El expediente debe permitir conservar y relacionar:

- identidad;
- ubicación;
- producción;
- suelo;
- infraestructura;
- economía;
- documentación;
- evidencias;
- confianza;
- madurez;
- actividades;
- relaciones;
- proveedores;
- profesionales;
- operadores;
- clientes;
- inversiones;
- operaciones;
- eventos;
- historial;
- auditoría.

Principio:

> El activo físico permanece; el expediente digital acumula su historia.

---

## 4. Evolución de las relaciones con el Activo

La relación entre una persona, organización o entidad y un Activo Agro no
debe interpretarse únicamente como una propiedad estática.

Debe poder representar una relación durante un período determinado.

Conceptualmente:

USUARIO / ORGANIZACIÓN
        ↓
RELACIÓN
        ↓
ACTIVO AGRO

Las relaciones pueden incluir, entre otras:

- propietario;
- comprador;
- inversor;
- productor;
- administrador;
- publicador;
- representante;
- proveedor;
- profesional;
- operador;
- cliente;
- interesado;
- arrendatario;
- otros roles definidos posteriormente.

La arquitectura deberá permitir que una relación:

- comience;
- permanezca activa;
- cambie;
- finalice;
- sea reemplazada por otra relación;

sin destruir la historia anterior.

---

## 5. Cambio de propietario

Una operación de venta o transferencia no debe eliminar la historia del
Activo Agro.

Conceptualmente:

ACTIVO AGRO
    │
    ├── Propietario A
    │      └── período 1
    │
    ├── Transferencia
    │
    ├── Propietario B
    │      └── período 2
    │
    └── Propietario C
           └── período 3

El nuevo responsable deberá poder acceder al expediente que corresponda al
activo y continuar su evolución, de acuerdo con los permisos y reglas de
seguridad definidos por el sistema.

La historia de las relaciones anteriores deberá conservarse.

---

## 6. Continuidad posterior a una operación

La arquitectura contempla que Agro Fields continúe aportando valor después
de una operación comercial.

Flujo conceptual:

PUBLICACIÓN
    ↓
OPORTUNIDAD
    ↓
CONTACTO
    ↓
NEGOCIACIÓN
    ↓
OPERACIÓN
    ↓
ADQUISICIÓN / INVERSIÓN
    ↓
NUEVO RESPONSABLE
    ↓
SEGUIMIENTO
    ↓
ACTUALIZACIONES
    ↓
NUEVOS EVENTOS
    ↓
NUEVA HISTORIA

La operación comercial no representa necesariamente el final de la
relación entre Agro Fields y el Activo Agro.

Representa una nueva etapa de su continuidad digital.

---

## 7. Información generada durante la vida del activo

La arquitectura deberá contemplar que el Activo Agro genere nueva
información durante toda su existencia.

Ejemplos:

- incorporación de un nuevo proveedor;
- contratación de un profesional;
- cambio de operador;
- incorporación de un cliente;
- nueva actividad productiva;
- nueva evaluación de suelo;
- nuevo documento;
- nueva evidencia;
- nueva inversión;
- mantenimiento;
- mejora de infraestructura;
- cambio de producción;
- nueva validación;
- cambio de responsable;
- evento relevante.

Cada incorporación deberá poder formar parte del expediente y, cuando
corresponda, generar trazabilidad e historial.

---

## 8. Clientes y recorrido de relaciones

La arquitectura deberá contemplar también la evolución de las relaciones
comerciales vinculadas al Activo Agro.

Un cliente no debe reducirse necesariamente a un campo `clienteId`.

Puede existir una evolución:

INTERESADO
    ↓
CONTACTO
    ↓
CLIENTE
    ↓
COMPRADOR / INVERSOR
    ↓
RELACIÓN POSTERIOR

La plataforma deberá poder conservar el recorrido de las relaciones
relevantes cuando exista fundamento funcional y autorización para hacerlo.

Este concepto deberá definirse posteriormente en detalle antes de crear
nuevos modelos o estructuras de persistencia.

---

## 9. Carga de información — Principio Mobile First

La continuidad digital solamente será efectiva si incorporar nueva
información resulta suficientemente sencillo para el usuario.

Principio:

> Cargar información debe ser simple, rápido y posible desde el celular.

La arquitectura UX deberá priorizar:

- formularios cortos;
- pasos reducidos;
- selección antes que escritura cuando sea posible;
- reutilización de información existente;
- carga progresiva;
- posibilidad de completar posteriormente;
- incorporación sencilla de documentos y evidencias;
- actualización contextual desde el propio activo.

No se debe exigir al usuario completar todo el expediente nuevamente cada
vez que quiera actualizar una parte.

El usuario deberá poder incorporar solamente la información nueva o
modificada.

Conceptualmente:

ACTIVO EXISTENTE
      ↓
¿QUÉ QUIERO ACTUALIZAR?
      ↓
MÓDULO / INFORMACIÓN
      ↓
CARGA SIMPLE
      ↓
GUARDAR
      ↓
HISTORIAL
      ↓
AUDITORÍA

---

## 10. Consulta de información — Principio de simplicidad

La complejidad interna del expediente no debe trasladarse al usuario.

Principio:

> El expediente puede ser complejo por dentro, pero debe ser simple de
> consultar.

La consulta deberá priorizar:

- información relevante;
- resumen del activo;
- estado actual;
- indicadores;
- alertas;
- documentación disponible;
- evidencias;
- relaciones actuales;
- últimos eventos;
- historial;
- acceso al detalle cuando sea necesario.

Conceptualmente:

ACTIVO
  ↓
RESUMEN CLARO
  ↓
INFORMACIÓN RELEVANTE
  ↓
DETALLE
  ↓
HISTORIAL

La navegación deberá permitir comprender rápidamente el estado del activo
sin obligar al usuario a recorrer todo el expediente.

---

## 11. Experiencia de usuario

La aplicación móvil constituye el principal punto de interacción cotidiana
con la continuidad digital del Activo Agro.

La experiencia deberá buscar:

- navegación clara;
- jerarquía visual;
- acciones evidentes;
- acceso rápido a información relevante;
- actualización desde el contexto del activo;
- mínimo esfuerzo para tareas frecuentes;
- consistencia visual;
- sensación de continuidad;
- recuperación rápida del estado del activo.

La interfaz no debe intentar mostrar toda la complejidad del sistema al
mismo tiempo.

Debe presentar la información progresivamente.

Principio:

> Complejidad estructural interna; simplicidad de uso externa.

---

## 12. Arquitectura funcional de continuidad

El circuito conceptual de evolución del Activo Agro será:

ACTIVO AGRO
    ↓
EXPEDIENTE
    ↓
INFORMACIÓN
    ↓
RELACIONES
    ↓
ACTIVIDADES
    ↓
DOCUMENTOS / EVIDENCIAS
    ↓
EVENTOS
    ↓
HISTORIAL
    ↓
AUDITORÍA
    ↓
CONOCIMIENTO

Cada módulo deberá incorporarse respetando la arquitectura existente.

---

## 13. Arquitectura técnica

Se mantiene la regla:

SCREEN
   ↓
SERVICE
   ↓
MODEL
   ↓
FIREBASE / FIRESTORE

Y transversalmente:

AUDITORÍA
TRAZABILIDAD
SEGURIDAD
GOBERNANZA

La evolución de la continuidad digital no implica crear una nueva versión
estructural de ActivoAgro.

Regla vigente:

> NO CREAR ACTIVOAGROV3.

La evolución debe realizarse sobre ActivoAgroV2 y los modelos especializados
correspondientes.

---

## 14. Principio de evolución

Antes de implementar una nueva funcionalidad:

1. documentar la necesidad;
2. revisar qué componentes existentes pueden resolverla;
3. identificar el GAP;
4. determinar si corresponde evolucionar un modelo existente;
5. determinar si corresponde crear un nuevo modelo especializado;
6. definir persistencia;
7. definir servicio;
8. definir interfaz;
9. definir historial;
10. definir auditoría;
11. definir pruebas;
12. implementar;
13. validar;
14. documentar;
15. versionar en Git.

No implementar funcionalidades únicamente porque sean técnicamente
interesantes.

Primero debe existir una decisión funcional y arquitectónica.

---

## 15. Principio rector

Agro Fields no administra solamente publicaciones.

Agro Fields administra la continuidad digital de los Activos Agro.

La plataforma debe permitir que un activo pueda:

- nacer digitalmente;
- ser documentado;
- ser publicado;
- generar oportunidades;
- relacionarse con usuarios;
- ser adquirido;
- cambiar de responsable;
- incorporar nuevos proveedores;
- incorporar profesionales;
- incorporar operadores;
- incorporar clientes;
- registrar inversiones;
- generar nuevas actividades;
- incorporar nueva información;
- evolucionar;
- conservar su historia.

La publicación es solamente una etapa dentro de la vida digital del activo.

El expediente y su continuidad constituyen el núcleo de largo plazo.

---

## 16. Principio de producto

La arquitectura debe perseguir simultáneamente tres objetivos:

### Cargar fácil

La incorporación de nueva información debe ser sencilla, especialmente
desde el celular.

### Consultar fácil

La información acumulada debe ser rápidamente comprensible.

### Continuar fácil

El usuario debe encontrar razones para seguir utilizando Agro Fields
durante la vida del activo, no solamente durante una operación comercial.

Por lo tanto:

> La plataforma no debe ser solamente un lugar donde se publica un activo.

> Debe convertirse en el lugar donde su información, relaciones y evolución
> continúan siendo gestionadas.

---

## 17. Estado de implementación

Esta sección define una evolución arquitectónica.

No implica que todos los componentes descritos estén implementados.

Cada componente deberá clasificarse posteriormente como:

🟢 EXISTENTE

🟡 PARCIAL

⚪ DEFINIDO / FUTURO

🔴 FALTA DEFINIR

La implementación deberá realizarse progresivamente sobre la arquitectura
V8 y sin romper los componentes consolidados.

---

# 18. AUDITORÍA ARQUITECTÓNICA — PASO 1

## Objetivo

Auditar la arquitectura existente antes de incorporar nuevas funcionalidades
relacionadas con la continuidad digital del Activo Agro.

El objetivo es determinar qué capacidades ya existen, qué pueden evolucionar
y qué necesidades todavía constituyen un GAP arquitectónico.

## Resultado de la auditoría

La arquitectura actual ya contiene componentes fundamentales para construir
la continuidad digital del Activo Agro.

El núcleo existente está representado por:

ActivoAgroV2
- información del activo;
- ubicación;
- producción;
- economía;
- documentación;
- confianza;
- madurez;
- suelo;
- participantes;
- historial.

La arquitectura transversal incorpora además:

- auditoría;
- trazabilidad;
- seguridad;
- gobernanza.

Por lo tanto, la evolución no requiere crear una nueva versión del Activo
Agro.

Regla:

> NO CREAR ACTIVOAGROV3.

La evolución debe realizarse sobre ActivoAgroV2 y sus módulos especializados.

## Hallazgo 1 — Participantes

Existe actualmente:

`ParticipanteActivo`

Este modelo representa una relación básica entre un usuario y un Activo Agro
mediante:

- usuarioId;
- rol;
- estado;
- fechaIngreso.

La auditoría determina que este componente constituye una base válida para
evolucionar el concepto de relaciones del activo.

No se crea un modelo paralelo en esta etapa.

## Hallazgo 2 — Relaciones

La arquitectura futura deberá distinguir conceptualmente entre:

PERSONA / ORGANIZACIÓN
        ↓
RELACIÓN
        ↓
ACTIVO AGRO

Una relación no debe considerarse solamente un dato estático.

Debe poder:

- comenzar;
- permanecer activa;
- cambiar;
- finalizar;
- ser reemplazada;
- conservar su historia.

Las relaciones podrán representar, entre otras:

- propietario;
- productor;
- comprador;
- inversor;
- proveedor;
- profesional;
- operador;
- administrador;
- cliente;
- arrendatario;
- representante;
- interesado;
- otros roles que posteriormente sean definidos.

La relación histórica no deberá eliminarse cuando deje de estar activa.

## Hallazgo 3 — Historial

Existe actualmente:

`HistorialActivo`

El modelo ya contempla:

- tipoEvento;
- descripción;
- usuarioId;
- móduloOrigen;
- fecha;
- entidadRelacionada;
- referenciaId;
- datosEvento.

Esta estructura constituye una base adecuada para registrar la evolución del
activo y de sus relaciones.

No se modificará todavía el modelo.

Primero deberá definirse el modelo conceptual de relaciones y los eventos que
deben producir trazabilidad.

## Hallazgo 4 — Continuidad del activo

El Activo Agro debe ser considerado una entidad digital viva.

Una publicación, consulta, negociación, inversión, venta o cambio de
responsable no representa necesariamente el final de la vida digital del
activo.

Conceptualmente:

ACTIVO FÍSICO
        ↓
IDENTIDAD DIGITAL
        ↓
EXPEDIENTE
        ↓
RELACIONES
        ↓
ACTIVIDADES
        ↓
EVENTOS
        ↓
HISTORIAL
        ↓
CONTINUIDAD

El expediente debe acumular la evolución del activo sin destruir la
información histórica.

## Hallazgo 5 — Nuevas relaciones durante la vida del activo

Durante la vida de un Activo Agro podrán aparecer nuevas relaciones y nueva
información.

Ejemplos:

- incorporación de un proveedor;
- contratación de un profesional;
- cambio de operador;
- incorporación de un cliente;
- cambio de productor;
- cambio de propietario;
- nueva inversión;
- nueva actividad;
- nueva documentación;
- nueva evidencia;
- nueva evaluación;
- mantenimiento;
- mejora de infraestructura.

Estas incorporaciones deberán poder formar parte del expediente y generar
historial cuando corresponda.

## Hallazgo 6 — Clientes

La auditoría confirma que el recorrido de los clientes debe formar parte de
la arquitectura conceptual.

No se implementará todavía un simple `clienteId` como solución definitiva.

Deberá analizarse el recorrido de la relación, por ejemplo:

INTERESADO
    ↓
CONTACTO
    ↓
RELACIÓN COMERCIAL
    ↓
CLIENTE
    ↓
COMPRADOR / INVERSOR
    ↓
RELACIÓN POSTERIOR

Este recorrido deberá diseñarse posteriormente considerando permisos,
privacidad, trazabilidad y utilidad funcional.

## Hallazgo 7 — Mobile First

La continuidad digital solamente será útil si la incorporación de
información es sencilla.

La arquitectura deberá priorizar:

- carga rápida;
- formularios cortos;
- selección antes que escritura;
- reutilización de datos;
- carga progresiva;
- actualización desde el propio activo;
- incorporación sencilla de documentos y evidencias.

El usuario no deberá reconstruir todo el activo para actualizar una sola
parte.

## Hallazgo 8 — Consulta

La complejidad interna del expediente no debe trasladarse al usuario.

La aplicación deberá permitir:

ACTIVO
    ↓
RESUMEN
    ↓
INFORMACIÓN RELEVANTE
    ↓
DETALLE
    ↓
HISTORIAL

La navegación móvil deberá priorizar comprensión rápida, acciones claras y
acceso progresivo al detalle.

## Decisión arquitectónica del Paso 1

La auditoría determina que:

1. ActivoAgroV2 continúa siendo el núcleo.
2. ParticipanteActivo continúa siendo un componente existente.
3. HistorialActivo continúa siendo el componente histórico existente.
4. No se crean modelos duplicados en esta etapa.
5. El concepto de relación debe evolucionar antes de implementar nuevos
   componentes.
6. Los clientes deben analizarse como relaciones con recorrido histórico,
   no solamente como un identificador.
7. La continuidad digital debe convertirse en principio transversal.
8. La carga y consulta desde el celular son requisitos arquitectónicos.
9. La trazabilidad debe conservar la evolución sin destruir relaciones
   anteriores.
10. La siguiente etapa será definir el GAP exacto y el modelo conceptual de
    relaciones.

## Estado

PASO 1 — AUDITORÍA DE ARQUITECTURA EXISTENTE

Estado: COMPLETADO.

Próximo paso:

PASO 2 — DEFINICIÓN DEL GAP ARQUITECTÓNICO Y MODELO CONCEPTUAL DE RELACIONES.

# 19. AUDITORÍA ARQUITECTÓNICA — PASO 2

## Objetivo

Definir el GAP arquitectónico existente para evolucionar Agro Fields desde
la representación del Activo Agro hacia la presentación estructurada de
proyectos y oportunidades agropecuarias.

## Hallazgo

La arquitectura actual permite representar información estructurada del
Activo Agro, incluyendo producción, suelo, economía, documentación,
confianza, madurez, participantes e historial.

El GAP identificado es la capacidad conceptual de representar una
oportunidad concreta vinculada a un Activo Agro.

## Principio

La Oportunidad Agro no reemplaza al Activo Agro.

Representa una posibilidad de participación, inversión, expansión,
desarrollo o transformación vinculada a un activo o proyecto determinado.

Conceptualmente:

ACTIVO AGRO
+
PROYECTO / NECESIDAD
+
CONDICIONES
+
INFORMACIÓN
+
CONFIANZA
↓
OPORTUNIDAD AGRO

## Catálogo de oportunidades

Agro Fields podrá presentar las oportunidades mediante una experiencia de
catálogo orientada a usuarios interesados e inversores.

El catálogo constituye una vista de exploración sobre oportunidades
estructuradas y no debe convertirse en una duplicación de la información
del Activo Agro.

Conceptualmente:

CATÁLOGO
↓
OPORTUNIDAD
↓
ACTIVO AGRO
↓
EXPEDIENTE

## Información conceptual de una oportunidad

Una oportunidad podrá incluir posteriormente:

- activo relacionado;
- objetivo;
- tipo de oportunidad;
- necesidad identificada;
- inversión requerida;
- destino de fondos;
- plazo;
- estado;
- condiciones;
- potencial;
- riesgos;
- información disponible;
- documentación;
- evidencias;
- nivel de confianza;
- responsables;
- fecha de actualización.

Estos elementos son conceptuales y no implican todavía la creación de un
nuevo modelo.

## Tipos posibles de oportunidad

Entre otras:

- adquisición de activo;
- expansión productiva;
- incorporación de infraestructura;
- desarrollo de nueva actividad;
- proyecto productivo;
- necesidad de capital;
- participación en inversión;
- transformación o mejora del activo.

La clasificación definitiva se realizará posteriormente mediante análisis
funcional.

## Principio para inversores

La plataforma debe permitir comprender:

- qué activo existe;
- qué situación presenta;
- qué oportunidad se propone;
- qué necesidad existe;
- qué información está respaldada;
- qué información falta;
- qué riesgos requieren análisis;
- qué profesionales participaron.

Agro Fields no garantiza rentabilidad ni reemplaza el análisis profesional,
legal o financiero.

## Decisión arquitectónica

1. ActivoAgroV2 continúa siendo el núcleo.
2. La oportunidad estará vinculada al Activo Agro.
3. El catálogo será una forma de consulta y presentación.
4. No se duplicará innecesariamente la información del activo.
5. No se crea ActivoAgroV3.
6. No se implementará todavía un nuevo modelo sin definir previamente
   sus responsabilidades y relaciones.
7. La información de la oportunidad deberá poder vincularse con el
   expediente del activo.
8. La confianza y trazabilidad del activo deberán acompañar la presentación
   de la oportunidad.

## Estado

PASO 2 — DEFINICIÓN DEL GAP ARQUITECTÓNICO Y MODELO CONCEPTUAL

Estado: COMPLETADO.

Próximo paso:

PASO 3 — DISEÑO FUNCIONAL DE LA OPORTUNIDAD Y CATÁLOGO.