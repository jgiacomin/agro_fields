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



La estructura principal es:



Screen



↓



Service



↓



Model



↓



Firebase





Cada capa tiene una responsabilidad definida.





Reglas fundamentales:



\- Las pantallas no acceden directamente a Firebase.

\- Los servicios manejan la comunicación con datos.

\- Los modelos representan información del negocio.

\- Los modelos no contienen lógica de acceso a datos.

\- No crear archivos duplicados cuando un modelo existente pueda evolucionar.

\- Mantener trazabilidad histórica mediante Git.

\- Cada cambio importante debe quedar documentado mediante bitácora.





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



\+



Profesionales



\+



Tecnología



\+



IA



\+



Trazabilidad



\+



Marco legal



generen confianza para conectar oportunidades agropecuarias con inversores.

