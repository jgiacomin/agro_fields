# ARQUITECTURA ACTUAL — AGRO FIELDS V8

**Proyecto:** Agro Fields
**Versión:** V8
**Fecha de referencia:** 20/08/2026
**Estado:** MVP funcional + evolución arquitectónica V8

---

# 1. Propósito

Este documento representa el mapa técnico actual del proyecto Agro Fields.

Su objetivo es permitir comprender rápidamente:

- qué componentes existen;
- dónde se encuentran;
- qué responsabilidad tiene cada módulo;
- cómo se relacionan entre sí;
- qué componentes están consolidados;
- qué componentes se encuentran en evolución;
- qué módulos están pendientes de implementación.

Este documento funciona como referencia técnica compacta.

No reemplaza:

- `docs/ROADMAP_V8.md`
- `docs/AUDITORIA_V8.md`
- `docs/BITACORA.md`
- documentación específica de arquitectura.

---

# 2. Principio arquitectónico principal

La aplicación sigue como regla general:

```text
SCREEN
   ↓
SERVICE
   ↓
MODEL
   ↓
FIREBASE / FIRESTORE
Las pantallas no deben acceder directamente a Firestore para operaciones de negocio.

Los servicios son responsables de:

comunicación con Firebase;
operaciones de negocio;
transformación de información;
validaciones;
actualización de entidades;
generación de trazabilidad cuando corresponda.

Los modelos son responsables de representar las entidades y su serialización.

3. Estructura actual de lib
lib/
│
├── firebase_options.dart
├── lib.code-workspace
├── main.dart
│
├── core/
│   ├── audit/
│   │   ├── audit_event.dart
│   │   ├── audit_service.dart
│   │   └── audit_type.dart
│   │
│   ├── auth/
│   │   └── auth_gate.dart
│   │
│   ├── constants/
│   ├── errors/
│   ├── theme/
│   └── utils/
│
├── enums/
│   └── solicitud_estado.dart
│
├── models/
│   │
│   ├── campo_model.dart
│   ├── chat_model.dart
│   ├── chat_preview_model.dart
│   ├── chat_room_model.dart
│   ├── inversion_model.dart
│   ├── produccion_activo_model.dart
│   ├── publicacion_inversion_model.dart
│   ├── solicitud_contacto_model.dart
│   └── user_model.dart
│
│   └── activos/
│       ├── activo_agro_model_v2.dart
│       ├── activo_agro_serializacion_test.dart
│       ├── activo_agro_test_data.dart
│       ├── confianza_activo_model.dart
│       ├── documentacion_activo_model.dart
│       ├── economia_activo_model.dart
│       ├── estado_activo.dart
│       ├── evaluacion_confianza_model.dart
│       ├── factor_confianza_model.dart
│       ├── historial_activo_model.dart
│       ├── madurez_activo_model.dart
│       ├── modulo_produccion_model.dart
│       ├── participante_activo_model.dart
│       ├── tipo_activo.dart
│       └── ubicacion_activo_model.dart
│
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   │
│   ├── campos/
│   │   ├── campos_screen.dart
│   │   ├── crear_activo_agro_screen.dart
│   │   ├── crear_campo_screen.dart
│   │   ├── detalle_activo_agro_screen.dart
│   │   ├── detalle_campo_screen.dart
│   │   └── mis_activos_screen.dart
│   │
│   ├── chat/
│   │   ├── chat_page.dart
│   │   ├── chat_room_screen.dart
│   │   └── chat_screen.dart
│   │
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   │
│   ├── inversiones/
│   │   ├── feed_inversion_screen.dart
│   │   └── invertir_screen.dart
│   │
│   └── solicitudes/
│       └── solicitudes_recibidas_screen.dart
│
├── services/
│   ├── activo_agro_service_v2.dart
│   ├── auth_service.dart
│   ├── campo_service.dart
│   ├── campo_to_activo_service.dart
│   ├── chat_service.dart
│   ├── confianza_activo_service.dart
│   ├── inversion_service.dart
│   ├── publicacion_inversion_service.dart
│   ├── solicitud_contacto_service.dart
│   └── user_service.dart
│
└── widgets/
    └── campo_card.dart
4. Núcleo conceptual del sistema

El núcleo actual de Agro Fields es:

                    ACTIVO AGRO V2
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
      UBICACIÓN        PRODUCCIÓN        ECONOMÍA
          │                │                │
          └────────────────┼────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
   DOCUMENTACIÓN     PARTICIPANTES      MADUREZ
          │                │                │
          └────────────────┼────────────────┘
                           │
                           ▼
                    CONFIANZA V8
                           │
          ┌────────────────┼────────────────┐
          │        │       │       │       │
          ▼        ▼       ▼       ▼       ▼
      DOCUMENTAL PRODUCTIVO ECONÓMICO LEGAL PROFESIONAL
                           │
                           ▼
                       HISTORIAL
                           │
                           ▼
                       AUDITORÍA
5. Activo Agro V2

Archivo:

lib/models/activos/activo_agro_model_v2.dart

Entidad principal del ecosistema productivo.

Representa la unidad productiva principal.

Conceptualmente contiene o relaciona:

ActivoAgroV2
│
├── Identidad
├── Clasificación
├── Ubicación
├── Producción
├── Economía
├── Documentación
├── Confianza
├── Participantes
├── Historial
└── Madurez

El modelo mantiene la evolución sobre ActivoAgroV2.

No se establece actualmente la necesidad de:

activo_agro_model_v3.dart
6. Ubicación

Archivo:

lib/models/activos/ubicacion_activo_model.dart

Clase:

UbicacionActivo

Responsabilidad:

Representar la ubicación territorial del activo.

Actualmente contempla información como:

país;
provincia;
departamento;
localidad;
código postal;
latitud;
longitud;
superficie;
región productiva;
jurisdicción legal;
zona horaria;
moneda local.

Objetivo V8:

Preparar el activo para:

análisis territorial;
análisis legal;
internacionalización;
comparación de mercados;
restricciones jurisdiccionales.

Evolución futura:

País
  ↓
Provincia / Estado
  ↓
Departamento
  ↓
Municipio / Localidad
  ↓
Zona productiva
  ↓
Marco legal aplicable
7. Producción

Archivo:

lib/models/activos/modulo_produccion_model.dart

Clase:

ModuloProduccion

Responsabilidad:

Representar una actividad o módulo productivo perteneciente al Activo Agro.

Actualmente contiene:

id;
activoAgroId;
dominio;
actividad;
descripcion;
superficie;
unidad;
datos.

Mantiene compatibilidad histórica con:

tipoProduccion

mediante:

tipoProduccion
      ↓
dominio + actividad
Evolución pendiente

El módulo debe evolucionar hacia:

ciclos productivos;
historial productivo;
capacidad actual;
capacidad máxima estimada;
recursos;
limitantes;
expansión;
mejoras;
intervenciones profesionales.

Modelo conceptual:

Activo Agro
     ↓
Modulo Produccion
     ↓
Ciclo productivo
     ↓
Producción obtenida
     ↓
Historial
     ↓
Capacidad futura

No se prevé crear:

modulo_produccion_model_v2.dart

salvo que una futura incompatibilidad estructural lo justifique.

8. Economía

Archivo:

lib/models/activos/economia_activo_model.dart

Responsabilidad:

Representar la situación económica del activo y su proyecto productivo.

Actualmente contempla información relacionada con:

valor solicitado;
moneda;
tipo de operación;
capital requerido;
ingresos estimados;
costos estimados;
rentabilidad declarada;
período de evaluación;
datos económicos.

También incorpora conceptos V8:

objetivo del proyecto;
etapa del proyecto;
inversión esperada;
capacidad actual;
capacidad proyectada;
riesgos identificados;
origen de información;
responsable de la declaración.

Principio:

Agro Fields registra información declarada.

No garantiza:

rentabilidad;
resultados financieros;
retorno de inversión.

Evolución futura:

Situación actual
      ↓
Necesidad de capital
      ↓
Inversión
      ↓
Expansión
      ↓
Resultado esperado
      ↓
Seguimiento
9. Documentación

Archivo:

lib/models/activos/documentacion_activo_model.dart

Clase:

DocumentacionActivo

Responsabilidad:

Representar documentos, permisos, certificaciones y archivos asociados al activo.

Actualmente contempla:

documentación;
certificaciones;
permisos;
archivos;
observaciones;
fecha de actualización.

Evolución V8:

Documento
   ↓
Tipo
   ↓
Fecha
   ↓
Origen
   ↓
Responsable
   ↓
Validación
   ↓
Evidencia
   ↓
Confianza

La IA puede:

clasificar;
resumir;
detectar faltantes;
detectar inconsistencias.

La IA no realiza validación legal definitiva.

10. Confianza

Archivo:

lib/models/activos/confianza_activo_model.dart

Clase:

ConfianzaActivo

Representa el estado de confianza asociado al activo.

Actualmente contiene factores relacionados con:

Identidad
identidad verificada.
Documentación
documentación completa;
nivel documental.
Evidencias
cantidad de evidencias;
nivel de evidencias.
Producción
información productiva completa;
nivel de producción.
Infraestructura
nivel;
verificación;
cantidad.
Tecnología
nivel;
verificación;
cantidad.
Inversión
nivel;
declaración;
verificación;
monto;
moneda.
Participantes
participantes verificados.
Gobernanza
nivel de gobernanza.
Control
última verificación;
última evaluación;
observaciones.

La confianza debe evolucionar hacia un sistema multidimensional.

11. Evaluación de Confianza

Archivo:

lib/models/activos/evaluacion_confianza_model.dart

Clase:

EvaluacionConfianza

Representa una evaluación estructurada de confianza.

Factores actuales:

FactorConfianza
├── documental
├── productivo
├── economico
├── legal
└── profesional

Además contiene:

nivel general;
fortalezas;
pendientes;
resumen;
responsable;
fecha de evaluación.

Flujo conceptual:

Información
    +
Evidencias
    +
Validaciones
    +
Profesionales
    +
Historial
        ↓
Evaluación de Confianza
        ↓
Nivel general

La IA puede asistir en el análisis.

La IA no asigna por sí misma una confianza definitiva.

12. Factor de Confianza

Archivo:

lib/models/activos/factor_confianza_model.dart

Representa un factor individual de confianza.

Factores oficiales previstos:

Documental
Productivo
Económico
Legal
Profesional

Cada factor debe poder expresar:

nivel;
porcentaje o puntuación;
respaldo;
observaciones.

La definición definitiva de metodología de cálculo queda sujeta a evolución V8.

13. Participantes

Archivo:

lib/models/activos/participante_activo_model.dart

Representa personas, organizaciones y actores relacionados con el activo.

Relaciones actuales:

propietario;
usuario relacionado;
estado;
fecha de ingreso.

Evolución futura:

identidad;
tipo de relación;
responsabilidad;
permisos;
validación;
profesionales;
auditores;
inversores;
especialistas.

Modelo:

Activo Agro
     ↓
Participante
     ↓
Rol
     ↓
Responsabilidad
     ↓
Intervenciones
14. Historial del Activo

Archivo:

lib/models/activos/historial_activo_model.dart

Clase:

HistorialActivo

Responsabilidad:

Registrar la evolución funcional del Activo Agro.

Actualmente contiene:

eventoId;
tipoEvento;
descripcion;
usuarioId;
moduloOrigen;
fecha;
entidadRelacionada;
referenciaId;
datosEvento.

Permite vincular eventos con otras entidades.

Ejemplo:

HistorialActivo
    ↓
entidadRelacionada = produccion
    ↓
referenciaId = ID del módulo productivo
Diferencia con Auditoría
Historial

Representa evolución funcional:

cambios productivos;
cambios económicos;
publicaciones;
modificaciones;
eventos del ciclo de vida.
Auditoría

Representa trazabilidad técnica:

usuario;
fecha;
módulo;
acción;
información modificada;
valores anteriores;
valores nuevos;
evidencias.

Modelo:

Acción
   ↓
Evento de dominio
   ↓
Auditoría
   ↓
Historial del Activo
   ↓
Confianza
15. Madurez

Archivo:

lib/models/activos/madurez_activo_model.dart

Representa el grado de evolución del activo.

Actualmente contempla:

etapa del activo;
nivel tecnológico;
preparación para inversión.

Objetivo:

Representar:

estado de desarrollo;
incorporación tecnológica;
preparación futura.

Integraciones futuras:

Madurez
├── Confianza
├── Producción
├── Analytics
└── Marketplace

Pendiente:

Historial de madurez.

Debe permitir registrar:

cambio de etapa;
cambio tecnológico;
cambio de preparación;
fecha;
responsable;
evento asociado.
16. Auditoría técnica

Ubicación:

lib/core/audit/

Componentes:

audit_event.dart
audit_service.dart
audit_type.dart

Responsabilidad:

Registrar acciones técnicas del sistema.

La auditoría es transversal.

Debe permitir evolucionar hacia:

Usuario
   ↓
Acción
   ↓
Módulo
   ↓
Entidad
   ↓
Cambio
   ↓
Fecha
   ↓
Evidencia

La auditoría no reemplaza el historial funcional.

17. Marco legal

Estado:

PENDIENTE

No existe todavía un módulo legal completo.

Objetivo futuro:

Ubicación
    +
Tipo de operación
    +
Superficie
    +
Nacionalidad del inversor
    +
Restricciones
        ↓
Marco Legal Aplicable
        ↓
Evaluación

Resultados posibles:

PERMITIDO


REQUIERE REVISIÓN PROFESIONAL


RESTRINGIDO

Debe contemplar jurisdicciones internacionales.

18. Servicios actuales
Activo Agro
activo_agro_service_v2.dart

Responsabilidades actuales:

crear activos;
consultar activos;
buscar por propietario;
buscar por publicador;
publicar;
pausar;
actualizar;
actualizar confianza.

Debe continuar evolucionando con:

historial automático;
auditoría;
permisos;
eventos económicos;
eventos legales;
validaciones profesionales.
Campo
campo_service.dart

Gestiona operaciones relacionadas con el modelo Campo.

Campo → Activo Agro
campo_to_activo_service.dart

Convierte información de Campo en Activo Agro.

Actualmente incorpora:

ubicación;
economía;
propietario;
historial de creación;
publicación;
versión del modelo.

Flujo:

Campo
  ↓
CampoToActivoService
  ↓
ActivoAgroV2
Confianza
confianza_activo_service.dart

Gestiona información relacionada con la confianza del activo.

Evolución prevista:

factores;
evaluaciones;
evidencias;
historial;
validaciones profesionales.
Inversiones
inversion_service.dart
publicacion_inversion_service.dart

Gestionan:

inversiones;
publicaciones de inversión;
interacción con oportunidades.
Contacto
solicitud_contacto_service.dart

Gestiona solicitudes entre participantes.

Chat
chat_service.dart

Gestiona:

conversaciones;
mensajes;
salas;
comunicación comprador-propietario.

Flujo validado:

Comprador
   ↓
Solicitud de contacto
   ↓
Conversación
   ↓
Propietario
   ↓
Respuesta
   ↓
Firestore
Autenticación
auth_service.dart
user_service.dart

Responsabilidades:

autenticación;
usuarios;
información de participantes del sistema.
19. Pantallas actuales
Autenticación
screens/auth/
└── login_screen.dart
Campos / Activos
screens/campos/
├── campos_screen.dart
├── crear_activo_agro_screen.dart
├── crear_campo_screen.dart
├── detalle_activo_agro_screen.dart
├── detalle_campo_screen.dart
└── mis_activos_screen.dart
Chat
screens/chat/
├── chat_page.dart
├── chat_room_screen.dart
└── chat_screen.dart
Dashboard
screens/dashboard/
└── dashboard_screen.dart
Inversiones
screens/inversiones/
├── feed_inversion_screen.dart
└── invertir_screen.dart
Solicitudes
screens/solicitudes/
└── solicitudes_recibidas_screen.dart
20. Modelos generales

Actualmente existen modelos fuera de activos/:

campo_model.dart
chat_model.dart
chat_preview_model.dart
chat_room_model.dart
inversion_model.dart
produccion_activo_model.dart
publicacion_inversion_model.dart
solicitud_contacto_model.dart
user_model.dart

Estos representan funcionalidades generales del MVP y deberán continuar integrándose progresivamente con el núcleo V8 cuando corresponda.

21. Estados y tipos

Actualmente existen:

models/activos/estado_activo.dart
models/activos/tipo_activo.dart
enums/solicitud_estado.dart

Estos elementos deben tender progresivamente hacia catálogos y estructuras centralizadas conforme avance la arquitectura V8.

22. Datos de prueba

Archivo:

lib/models/activos/activo_agro_test_data.dart

Responsabilidad:

Crear datos controlados para pruebas del modelo Activo Agro.

Ejemplo conceptual:

crearGranjaAvicola()
       ↓
ActivoAgroV2

Los datos de prueba deben mantenerse compatibles con la evolución del modelo.

23. Pruebas del Activo Agro

Archivo actual:

lib/models/activos/activo_agro_serializacion_test.dart

Existe además una estructura de tests fuera de lib/.

Prueba conceptual actual:

ActivoAgroTestData
        ↓
ActivoAgroV2
        ↓
toMap()
        ↓
Map
        ↓
fromMap()
        ↓
ActivoAgroV2

Objetivo:

Verificar que el modelo pueda:

construirse;
serializarse;
recuperarse;
mantener sus datos principales.
Evolución recomendada

La prueba deberá crecer progresivamente para validar:

identidad;
ubicación;
economía;
producción;
documentación;
confianza;
participantes;
historial;
madurez.
24. Firebase / Firestore

Firebase representa actualmente la capa de persistencia.

Los servicios funcionan como intermediarios:

Screen
   ↓
Service
   ↓
Model
   ↓
Firestore

Los modelos implementan conversión mediante:

fromMap()
toMap()

Debe mantenerse especial atención a la compatibilidad histórica de Firestore.

Cuando se incorporan nuevos campos:

Campo nuevo
    ↓
fromMap()
    ↓
valor por defecto

De esta manera se evita romper registros existentes.

25. Compatibilidad histórica

La evolución V8 debe mantener compatibilidad con datos existentes.

Ejemplo:

tipoProduccion
      ↓
dominio + actividad

Otro principio:

Campo nuevo
      ↓
fromMap()
      ↓
default

La creación de una nueva versión de modelo debe ser excepcional.

Primero se debe intentar evolucionar el modelo existente.

26. Flujo de creación del Activo Agro

Actualmente existen dos caminos principales.

Desde Campo
Campo
   ↓
CampoToActivoService
   ↓
ActivoAgroV2
   ↓
Firestore
Creación manual
Usuario propietario
   ↓
Crear Activo Agro
   ↓
crear_activo_agro_screen.dart
   ↓
ActivoAgroServiceV2
   ↓
Firestore

La creación debe generar progresivamente:

identidad;
ubicación;
economía inicial;
participante propietario;
historial inicial;
estado;
versión del modelo.
27. Publicación

El Activo Agro y su publicación comercial son conceptos separados.

ACTIVO AGRO
     │
     ├── Existe como entidad
     │
     └── Puede publicarse
             ↓
         PUBLICACIÓN

Esto permite separar:

existencia del activo;
información productiva;
publicación comercial;
oportunidad de inversión.
28. Inversión

Flujo conceptual:

Activo Agro
     ↓
Proyecto productivo
     ↓
Necesidad de capital
     ↓
Publicación de inversión
     ↓
Inversor
     ↓
Solicitud / contacto
     ↓
Chat

La trazabilidad económica debe evolucionar para registrar:

objetivo;
inversión necesaria;
plazo;
expansión;
resultado esperado;
seguimiento.
29. Comunicación

Flujo actual validado:

Comprador
   ↓
Solicitud de contacto
   ↓
Conversación
   ↓
Propietario
   ↓
Mensaje
   ↓
Firestore

Estado:

Solicitud:      OK
Conversación:   OK
Mensajes:       OK
Listado:        OK
Respuesta:      OK
Enter:          OK
30. Red Profesional futura

Arquitectura prevista:

Profesional
     ↓
Intervención
     ↓
Entidad
     ↓
Validación
     ↓
Historial
     ↓
Confianza

Las intervenciones profesionales podrán relacionarse con:

producción;
documentación;
legal;
inversión;
auditoría;
confianza.
31. Inteligencia Artificial

La IA será una capa de asistencia.

Puede utilizar información del sistema para:

detectar información faltante;
explicar resultados;
identificar inconsistencias;
sugerir documentación;
resumir información;
analizar evolución;
asistir en evaluaciones.

La IA no debe:

inventar datos;
validar legalmente;
garantizar rentabilidad;
asignar confianza definitiva sin respaldo.

Principio:

DATOS VERIFICABLES
       +
EVIDENCIAS
       +
VALIDACIONES
       ↓
INFORMACIÓN PARA IA
       ↓
ASISTENCIA
32. Arquitectura de trazabilidad

La trazabilidad V8 se construye mediante:

Información
     +
Evidencias
     +
Participantes
     +
Historial
     +
Auditoría
     +
Validaciones
     ↓
CONFIANZA

Diferenciación:

HISTORIAL
= evolución funcional


AUDITORÍA
= trazabilidad técnica
33. Estado actual de módulos
Módulo	Estado	Evolución
ActivoAgroV2	🟢	consolidación
Ubicación	🟢	jurisdicción internacional
Producción	🟡	ciclos + historial + capacidad
Economía	🟡	trazabilidad de inversión
Documentación	🟡	evidencia verificable
Confianza	🟡	evaluación multidimensional
FactorConfianza	🟢	metodología oficial
EvaluacionConfianza	🟢	evolución de criterios
Participantes	🟢	profesionales y auditores
Historial	🟢	eventos especializados
Madurez	🟢	historial de madurez
Auditoría	🟢	integración transversal
Chat	🟢	evolución funcional
Solicitudes	🟢	evolución funcional
Inversiones	🟢	seguimiento
Marco Legal	🔴	pendiente
Red Profesional	🔜	futura
Analytics	🔜	futura
IA	🔜	futura
IoT	🔜	futura
Digital Twin	🔜	futura
Blockchain	🔜	futura
34. Prioridad técnica inmediata

La prioridad actual del núcleo Activo Agro V2 es:

1. Producción
       ↓
2. Economía
       ↓
3. Confianza
       ↓
4. Evidencias
       ↓
5. Profesionales
       ↓
6. Marco Legal
Producción

Analizar:

ciclos;
historial;
capacidad;
expansión.
Economía

Analizar:

inversión;
trazabilidad;
seguimiento;
expansión.
Confianza

Analizar:

factores;
metodología;
evidencias;
profesionales;
auditorías.
35. Regla de evolución de código

Antes de crear un nuevo modelo o servicio:

analizar el existente;
comprobar compatibilidad;
extender si es posible;
mantener fromMap() compatible;
actualizar toMap();
actualizar tests;
actualizar documentación;
registrar auditoría;
registrar bitácora;
realizar commit.

No crear versiones paralelas solamente para agregar campos.

36. Regla de trazabilidad del desarrollo

Cada evolución importante debe mantener relación:

CÓDIGO
   ↓
TEST
   ↓
AUDITORÍA
   ↓
BITÁCORA
   ↓
ROADMAP
   ↓
COMMIT

El objetivo es poder reconstruir:

qué cambió;
por qué;
cuándo;
quién lo realizó;
qué impacto tuvo;
cómo fue validado.
37. Estado arquitectónico general

Agro Fields V8 posee actualmente una base funcional con:

autenticación;
usuarios;
Campo;
Activo Agro V2;
producción;
economía;
documentación;
confianza;
participantes;
historial;
madurez;
inversiones;
publicaciones;
solicitudes de contacto;
chat;
auditoría técnica;
persistencia Firebase / Firestore.

La arquitectura está preparada conceptualmente para incorporar progresivamente:

profesionales;
marco legal;
analytics;
inteligencia artificial;
IoT;
Digital Twin;
blockchain;
internacionalización;
gobernanza de datos;
escalabilidad.
38. Referencia de trabajo

Este documento debe utilizarse como mapa rápido antes de modificar un módulo.

Ante cualquier cambio se debe preguntar:

¿Dónde pertenece?


¿Quién lo consume?


¿Qué modelo afecta?


¿Qué servicio lo gestiona?


¿Debe generar historial?


¿Debe generar auditoría?


¿Afecta confianza?


¿Afecta inversión?


¿Rompe compatibilidad Firestore?


¿Existe un test?


¿Debe actualizarse Roadmap / Bitácora / Auditoría?
39. Principio final

Agro Fields V8 no debe evolucionar como una colección de funcionalidades aisladas.

El sistema debe evolucionar como un ecosistema conectado:

USUARIO
   ↓
ACTIVO AGRO
   ↓
PRODUCCIÓN
   ↓
ECONOMÍA
   ↓
DOCUMENTACIÓN
   ↓
PARTICIPANTES
   ↓
MADUREZ
   ↓
HISTORIAL
   ↓
AUDITORÍA
   ↓
CONFIANZA
   ↓
INVERSIÓN
   ↓
MERCADO
   ↓
PROFESIONALES
   ↓
MARCO LEGAL
   ↓
IA / ANALYTICS / FUTURAS CAPAS

Este documento constituye el mapa arquitectónico operativo actual de Agro Fields V8.
Arquitectura actual — Agro Fields V8

Fecha de referencia: 20/08/2026

AGRO FIELDS
│       │   ├── producción
│       │   ├── inversión
│       │   ├── publicación
│       │   ├── solicitud
│       │   └── chat
│       │
│       └── activos/
│           │
│           ├── ActivoAgroV2
│           │
│           ├── Ubicación
│           ├── Economía
│           ├── Producción
│           ├── Confianza
│           ├── Evaluación de Confianza
│           ├── Factor de Confianza
│           ├── Documentación
│           ├── Participantes
│           ├── Historial
│           ├── Madurez
│           ├── Estado
│           └── Tipo de Activo
│
├── SERVICIOS
│   └── services/
│       │
│       ├── Activo Agro
│       │   ├── activo_agro_service_v2
│       │   └── campo_to_activo_service
│       │
│       ├── Campo
│       │   └── campo_service
│       │
│       ├── Confianza
│       │   └── confianza_activo_service
│       │
│       ├── Inversión
│       │   ├── inversion_service
│       │   └── publicacion_inversion_service
│       │
│       ├── Comunicación
│       │   ├── chat_service
│       │   └── solicitud_contacto_service
│       │
│       └── Usuarios / Auth
│           ├── auth_service
│           └── user_service
│
├── CORE TRANSVERSAL
│   └── core/
│       │
│       ├── audit/
│       │   ├── audit_event
│       │   ├── audit_service
│       │   └── audit_type
│       │
│       ├── auth/
│       │   └── auth_gate
│       │
│       ├── constants/
│       ├── errors/
│       ├── theme/
│       └── utils/
│
├── ENUMS
│   └── enums/
│       └── solicitud_estado
│
├── FIREBASE
│   └── Firebase / Firestore
│       ↑
│       │
│       └── accedido principalmente mediante Services
│
├── TESTS
│   └── test/
│       └── pruebas automatizadas
│
└── DOCUMENTACIÓN
    └── docs/
        ├── Arquitectura
        ├── Auditorías
        ├── Bitácora
        └── Roadmap V8
1. Núcleo actual: Activo Agro V2

El centro del modelo actualmente queda así:

                    ACTIVO AGRO V2
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
   Identidad         Ubicación          Estado
       │                 │                 │
       └─────────────────┼─────────────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
          Producción            Economía
              │                     │
              └──────────┬──────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
          Documentación         Participantes
              │                     │
              └──────────┬──────────┘
                         │
                  Confianza
                         │
          ┌──────────────┼──────────────┐
          │              │              │
       Factores      Evaluación      Evidencias
          │              │
          └──────────────┼──────────────┘
                         │
                     Historial
                         │
                      Madurez

Esto es importante porque ya no estamos ante un simple modelo Campo.

El Campo sigue existiendo:

Campo
  │
  └── CampoToActivoService
            │
            ▼
       ActivoAgroV2

Por lo tanto, actualmente hay una transición arquitectónica:

MODELO HISTÓRICO
Campo
  │
  ▼
Publicación


             ↓ evolución ↓


MODELO V8
Activo Agro
  │
  ├── producción
  ├── economía
  ├── documentación
  ├── participantes
  ├── confianza
  ├── historial
  ├── madurez
  └── inversión
2. Flujo técnico actual

La regla arquitectónica que veo en tu código es:

SCREEN
   │
   ▼
SERVICE
   │
   ▼
MODEL
   │
   ▼
FIRESTORE

Por ejemplo:

crear_activo_agro_screen
          │
          ▼
campo_to_activo_service
          │
          ▼
ActivoAgroV2
          │
          ▼
activo_agro_service_v2
          │
          ▼
Firestore

Y para confianza:

Screen / proceso
      │
      ▼
confianza_activo_service
      │
      ▼
ConfianzaActivo
      │
      ├── EvaluacionConfianza
      │       └── FactorConfianza
      │
      ▼
Firestore

Esto coincide con la arquitectura que venimos auditando.

3. Trazabilidad actual

Acá hay una evolución importante que ya quedó bastante clara con los archivos que me pasaste.

Tenés dos conceptos distintos:

Historial funcional
HistorialActivo

Registra:

evento;
tipo;
descripción;
usuario;
módulo origen;
fecha;
entidad relacionada;
referencia;
datos adicionales.

Por ejemplo:

Activo Agro
   │
   └── Historial
          │
          ├── producción creada
          ├── documento agregado
          ├── inversión modificada
          └── publicación realizada
Auditoría técnica

Está separada en:

core/audit/
├── audit_event.dart
├── audit_service.dart
└── audit_type.dart

Por lo tanto:

ACCIÓN
  │
  ▼
EVENTO DE DOMINIO
  │
  ├──────────────► HistorialActivo
  │
  └──────────────► AuditService

Esta separación es correcta y conviene conservarla.

4. Producción actual

El modelo que me pasaste confirma:

ModuloProduccion

ya tiene identidad:

id
activoAgroId

y estructura base:

dominio
actividad
descripcion
superficie
unidad
datos

Además mantiene compatibilidad:

tipoProduccion
      │
      ▼
dominio + actividad

Por lo tanto, no veo motivo para crear ModuloProduccionV2.

La evolución natural sigue siendo:

ModuloProduccion
      │
      ├── datos actuales
      │
      ├── ciclos productivos
      ├── historial productivo
      ├── capacidad
      ├── expansión
      └── intervenciones profesionales
5. Confianza actual

Acá hay algo muy bueno: ya tenés dos niveles que no deberían mezclarse.

ConfianzaActivo
        │
        │ estado / indicadores
        ▼
EvaluacionConfianza
        │
        ├── documental
        ├── productivo
        ├── económico
        ├── legal
        └── profesional
                 │
                 ▼
          FactorConfianza

Es decir:

ConfianzaActivo

Representa el estado de confianza asociado al activo.

Tiene además:

identidad;
documentación;
evidencias;
producción;
infraestructura;
tecnología;
inversión;
participantes;
gobernanza;
fechas de evaluación.
EvaluacionConfianza

Representa una evaluación estructurada.

Eso nos permite posteriormente tener:

Activo
 │
 ├── confianza actual
 │
 └── evaluaciones históricas
        ├── evaluación 01
        ├── evaluación 02
        ├── evaluación 03
        └── ...

Y ahí aparece una evolución muy importante que todavía está pendiente:

EvaluacionConfianza
        │
        ▼
Historial de evaluaciones
6. Arquitectura de inversión

Actualmente:

Activo Agro
     │
     └── Economía
           │
           ├── capital requerido
           ├── ingresos
           ├── costos
           ├── rentabilidad declarada
           └── proyecto
                    │
                    ▼
              Inversión
                    │
             ┌──────┴──────┐
             │             │
        Publicación     Inversor

Servicios:

inversion_service
publicacion_inversion_service

Esto indica que la inversión ya está separándose del simple dato económico del activo.

Esa separación también conviene mantenerla.

7. Comunicación actual

Ya existe otro subsistema:

SOLICITUD DE CONTACTO
        │
        ▼
CONVERSACIÓN
        │
        ▼
CHAT
        │
        ▼
FIRESTORE

Con:

solicitud_contacto_service
chat_service

y modelos:

solicitud_contacto_model
chat_model
chat_preview_model
chat_room_model

Esto ya está funcionando según la auditoría del 13/08.

Por lo tanto, no debemos tocarlo innecesariamente mientras trabajamos sobre Activo Agro.

8. Arquitectura transversal

Actualmente tenés:

                    CORE
                     │
       ┌─────────────┼─────────────┐
       │             │             │
      Auth         Audit         Utils
       │             │
       │       ┌─────┼─────┐
       │       │     │     │
       │     Event Service Type
       │
       └─────────────┐
                     │
                Aplicación

Esto es especialmente importante porque la auditoría ya no debería volver a implementarse dentro de cada módulo.

Por ejemplo, no queremos:

ModuloProduccion
   └── auditoría propia


Confianza
   └── auditoría propia


Inversión
   └── auditoría propia

Queremos:

Módulos
   │
   ▼
core/audit
   │
   ▼
Auditoría transversal
9. Arquitectura actual vs arquitectura objetivo

Para que yo no mezcle lo implementado con el Plan Maestro, voy a trabajar desde ahora con tres estados:

🟢 Implementado

Existe código y forma parte de la arquitectura actual.

🟡 Parcial

Existe estructura/base pero falta evolución.

🔵 Roadmap V8

Está definido arquitectónicamente pero todavía no necesariamente implementado.

Aplicado a lo que tenemos:
Área	Estado
ActivoAgroV2	🟢
Ubicación avanzada	🟢
Producción base	🟢
Producción histórica	🟡
Economía base	🟢
Trazabilidad económica	🟡
Confianza	🟢
Evaluación de confianza	🟢
Factores de confianza	🟢
Historial	🟢
Auditoría transversal	🟢
Historial de madurez	🟡
Documentación	🟢
Validación profesional	🔵
Marco legal	🔵
Integración profesional	🔵
IA aplicada a confianza	🔵
Expansión internacional	🔵
10. Y algo importante: el test

El test que me pasaste:

activo_agro_serializacion_test.dart

ya nos da una primera prueba arquitectónica:

TestData
   │
   ▼
ActivoAgroV2
   │
   ▼
toMap()
   │
   ▼
Firestore Map
   │
   ▼
fromMap()
   │
   ▼
ActivoAgroV2

Eso significa que podemos usar una metodología mucho más eficiente.

Cuando me pases un modelo nuevo, no necesito que me vuelvas a pegar toda la auditoría V8.

Voy a contrastarlo contra este mapa:

                 ARQUITECTURA ACTUAL
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
       MODELOS        SERVICES        CORE
          │              │              │
          └──────────────┼──────────────┘
                         ▼
                      FIREBASE
                         │
                         ▼
                    TRAZABILIDAD
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
          HISTORIAL              AUDITORÍA
              │
              ▼
           CONFIANZA
              │
              ▼
       EVALUACIÓN V8
Entonces sí: ya tenemos nuestro mapa base de trabajo.
