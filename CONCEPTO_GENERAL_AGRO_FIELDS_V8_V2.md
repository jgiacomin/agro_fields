# AGRO FIELDS V8
## Concepto General del Sistema — V2

**Fecha de línea de base:** 30/10/2026  
**Versión:** 2.0  
**Estado:** Borrador revisado para aprobación  
**Documento de referencia estratégica del sistema**

---

## 1. Propósito e identidad

Agro Fields V8 es un sistema digital agropecuario integral que conecta gestión productiva, identidad permanente del Activo Agro, expediente digital, territorio inteligente y mercados.

Su propósito es organizar información útil y trazable para que productores, propietarios, profesionales, compradores, inversores, cooperativas y organizaciones puedan comprender mejor los activos agropecuarios, gestionar sus actividades y coordinar oportunidades.

No buscamos construir el ERP más complejo ni un simple portal de anuncios. Buscamos una herramienta buena, sencilla, confiable y ampliable, que acompañe a los usuarios desde el autoconsumo y la pequeña escala hasta operaciones productivas más complejas.

**Principio rector:** avanzar progresivamente, resolver necesidades reales y evitar complejidad innecesaria.

## 2. Corazón del sistema

### Activo Agro + Expediente Digital Permanente

El Activo Agro representa la identidad estable del bien o unidad productiva.

El Expediente Digital Permanente es la composición lógica de información, documentación, evidencias, historial, estados, relaciones y auditoría que acompaña su evolución.

**Modelo conceptual:**

`Activo → Identidad → Expediente → Evidencias → Historial → Estado → Valor`

El expediente debe permanecer aunque el activo deje de publicarse, cambie de propietario, cambie de representante comercial o atraviese distintas etapas productivas.

El Expediente Digital Permanente no debe convertirse en un segundo modelo monolítico que duplique `ActivoAgroV2`. Es una capacidad lógica y transversal vinculada a una identidad estable.

**Evolución de la identidad existente**

La evolución hacia una identidad única del Activo Agro deberá partir de una auditoría de los modelos, identificadores, colecciones y relaciones existentes.

Los registros históricos de `Campo` y `ActivoAgroV2` deberán conservarse y vincularse mediante un proceso controlado, sin generar duplicaciones ni perder evidencias, historial o referencias.

No se eliminarán modelos ni colecciones hasta demostrar la integridad de la transición.

El valor del activo se comprende mediante información trazable, comparables, productividad, costos, accesibilidad, infraestructura, territorio y riesgos. Agro Fields no impone unilateralmente un precio ni se presenta como tasador definitivo: el precio surge de la interacción entre oferta y demanda.

## 3. Principios fundamentales

1. Una identidad persistente por Activo Agro.
2. No crear otro expediente porque cambie la publicación, el propietario, el broker, el comprador, el inversor o la actividad.
3. Separar identidad, titularidad, participación, publicación y permisos.
4. El creador, propietario, publicador, aportante, verificador y administrador son funciones diferentes.
5. Archivar no significa borrar.
6. La información desconocida no equivale a cero.
7. Un dato declarado no equivale a un dato documentado o verificado profesionalmente.
8. Cada dato relevante debe conservar, cuando corresponda, fuente, fecha, responsable, método, evidencia y vigencia.
9. La confianza debe ser explicable y no representar rentabilidad, garantía ni tasación definitiva.
10. La privacidad debe estar presente desde el diseño.
11. La experiencia debe ser sencilla y progresiva.
12. La operación offline debe contemplarse desde la arquitectura.
13. Cada avance debe poder demostrarse mediante código, pruebas y evidencia.

## 4. Pilares funcionales conectados

Los módulos no deben funcionar como sistemas independientes. Deben conectarse mediante la identidad del Activo Agro, sus relaciones y los permisos correspondientes.

Las oportunidades comerciales, publicaciones, productos, necesidades de emergencia y operaciones logísticas tendrán sus propios identificadores y estados, pero deberán poder relacionarse con el activo de origen cuando corresponda.

Cada módulo aportará información al mismo expediente lógico, respetando permisos, procedencia, historial y trazabilidad. La información no debe duplicarse innecesariamente entre módulos.

### 4.1. Gestión Productiva

Gestión agropecuaria modular y progresiva, adaptable a diferentes actividades, especies, sistemas productivos y etapas.

Debe contemplar, según corresponda:

- Establecimientos y unidades productivas.
- Lotes, parcelas y superficies.
- Campañas, ciclos y etapas.
- Labores y actividades.
- Producción y rendimientos.
- Recursos e insumos.
- Inventarios y movimientos.
- Infraestructura y maquinaria.
- Costos e información económica.
- Documentación y evidencias.

Debe permitir actividades agrícolas, ganaderas, tamberas, avícolas, apícolas, hortícolas, acuícolas, forestales y otras.

La experiencia debe adaptarse a la escala del usuario, sin exigirle completar información que todavía no necesita.

### 4.2. Expediente Digital Permanente

Es el corazón documental del Activo Agro.

Debe organizar:

- Identidad y características.
- Ubicación y superficie.
- Suelo y condiciones territoriales.
- Actividades y producción.
- Infraestructura.
- Documentación y derechos.
- Evidencias.
- Intervenciones profesionales.
- Relaciones y participantes.
- Historial de cambios.
- Estados y vigencia de información.
- Datos faltantes y necesidades de actualización.

Debe conservar la evolución del activo y permitir comprender qué información fue declarada, documentada, verificada, actualizada o quedó pendiente.

### 4.3. Territorio Inteligente

Integra información territorial para comprender mejor el contexto de cada activo.

Incluye:

- Geolocalización.
- Suelos.
- Agua.
- Clima.
- Riesgos de inundación, sequía, incendios y heladas.
- Normativa ambiental y territorial.
- Accesos y caminos.
- Infraestructura.
- Transporte y logística.

Los datos externos deben conservar fuente, fecha, cobertura, escala, metodología y limitaciones.

La clasificación local o nacional del suelo debe preservarse. WRB puede utilizarse como referencia internacional, sin reemplazar la clasificación original.

La información territorial debe presentarse con prudencia: una capa de datos no constituye por sí sola un diagnóstico profesional ni una predicción cierta.

### 4.4. Emergencia Agroganadera

Conecta necesidades y recursos durante inundaciones, sequías, incendios, heladas y otras contingencias.

Puede facilitar la identificación de:

- Campos y espacios de refugio.
- Agua y forraje.
- Capacidad disponible.
- Transporte.
- Recursos productivos.
- Necesidades de productores.
- Ofertas de colaboración.
- Redes y cooperativas.

Las necesidades y ofertas deben registrar responsable, estado, vigencia, ubicación protegida y trazabilidad.

El objetivo es facilitar la coordinación transparente y la colaboración, sin garantizar disponibilidad ni sustituir a las autoridades y servicios de emergencia.

### 4.5. Marketplace de Campos

Conecta propietarios, productores, brokers, compradores e inversores.

Debe permitir publicar activos y oportunidades mediante resúmenes autorizados del expediente.

Principios:

- El activo es permanente; la publicación es temporal.
- El expediente privado no debe exponerse directamente.
- La información pública debe estar autorizada.
- La publicación debe contar con estados y controles de revisión.
- Los cambios de titularidad o representante no deben generar otro activo.
- La información comercial debe distinguirse de la información verificada.

Agro Fields aporta información para comprender el activo, no una tasación definitiva.

### 4.6. Marketplace Agroalimentario

Conecta productores y compradores de productos agropecuarios y alimentos.

Incluye, entre otros:

- Frutas y hortalizas.
- Huevos y productos avícolas.
- Animales y productos ganaderos.
- Miel.
- Granos.
- Quesos y productos elaborados.
- Otros productos regionales.

Debe contemplar ubicación de producción, disponibilidad, presentación, cantidades, lugar de retiro y entrega.

Las cooperativas y redes de productores podrán facilitar la coordinación para completar pedidos y ampliar oportunidades comerciales.

### 4.7. Logística y transporte

Conecta producción, establecimientos, mercados y compradores.

Debe evolucionar progresivamente para organizar:

- Origen y destino.
- Distancias y rutas.
- Transitabilidad.
- Tipo de transporte.
- Capacidad.
- Costos.
- Retiro y entrega.
- Seguimiento de operaciones.

A futuro podrá estudiarse la coordinación multimodal e intermodal, incluyendo transporte ferroviario, cuando existan casos de uso y datos suficientes.

### 4.8. Trazabilidad y comercio exterior

Organiza información productiva, documental y logística para facilitar la trazabilidad y la comercialización.

Puede incluir:

- Relación Activo → Lote → Cosecha → Producto → Entrega.
- Documentación reutilizable.
- Requisitos por producto y destino.
- Vencimientos.
- Faltantes.
- Estados de trámites.
- Evidencias y responsables.

La simplificación y coordinación de exportaciones MERCOSUR constituye una línea estratégica a estudiar, con fuentes oficiales y validación profesional.

Agro Fields no reemplaza organismos públicos, certificaciones, despachantes ni asesoramiento legal o técnico.

## 5. Seguros y protección agropecuaria

Se establece como línea estratégica futura, pendiente de evaluación.

Se estudiarán posibles alianzas con aseguradoras autorizadas y productores asesores matriculados.

Entre las áreas de interés:

- Seguros agrícolas.
- Seguros ganaderos.
- Seguros forestales.
- Infraestructura.
- Maquinaria y equipamiento.
- Almacenamiento y silo bolsa.
- Coberturas multirriesgo.

El expediente y la información territorial podrían servir como soporte documental para estas actividades.

Agro Fields no asumirá el rol de aseguradora ni de intermediario sin el correspondiente marco legal y operativo.

Esta línea no desplaza las prioridades del núcleo del sistema.

## 6. Usuarios, participantes y relaciones

El sistema podrá vincular:

- Productores.
- Propietarios.
- Administradores.
- Encargados.
- Brokers.
- Profesionales.
- Compradores.
- Inversores.
- Cooperativas.
- Transportistas.
- Organizaciones.
- Aseguradoras y asesores habilitados.

Un participante puede relacionarse con uno o varios activos, con permisos diferenciados.

Las autorizaciones deben contemplar recurso, acción, alcance, vigencia y posibilidad de revocación.

La identidad del activo no debe depender de quién lo administra o publica.

## 7. Arquitectura y tecnología

Primera etapa tecnológica:

- Flutter Web.
- Android.
- Firebase Authentication.
- Cloud Firestore.
- Firebase Storage.
- Firestore Rules.
- Storage Rules.

Se mantiene el principio arquitectónico:

`Screen → Service → Model → Firebase`

Las reglas de negocio deben permanecer organizadas en servicios y modelos, evitando que la interfaz asuma responsabilidades que no le corresponden.

La arquitectura debe conservar identificadores, relaciones, historial y evidencias.

Se mantendrá una orientación que permita evaluar PostgreSQL y SQL en el futuro, sin migraciones prematuras ni complejidad innecesaria.

## 8. Offline-first

La conectividad rural puede ser limitada.

Por eso, las operaciones prioritarias deben contemplar:

- Registro local.
- Consulta de información disponible.
- Conservación de operaciones pendientes.
- Sincronización posterior.
- Resolución de conflictos.
- Control de duplicados.
- Integridad de información.
- Manejo de errores y recuperación.

No se debe asumir que utilizar Firebase resuelve automáticamente todos los problemas de sincronización offline.

## 9. Seguridad y privacidad

La información debe clasificarse según su sensibilidad y finalidad.

Se distinguen:

- Información pública autorizada.
- Información privada del expediente.
- Información compartida selectivamente.
- Información restringida por rol o autorización.

La ubicación pública debe ser aproximada cuando corresponda. La dirección exacta y los datos sensibles requieren autorización y una finalidad justificada.

El aportante de información no equivale a un verificador.

Los permisos deben validarse en los servicios y en las reglas de seguridad, no solamente ocultando botones en la interfaz.

Las operaciones relevantes deben conservar trazabilidad y auditoría.

## 10. Confianza y madurez

La confianza y la madurez describen la calidad, el respaldo, la completitud y la evolución de la información del activo.

No representan:

- Rentabilidad.
- Garantía comercial.
- Tasación definitiva.
- Certificación estatal.
- Recomendación de inversión.

Los cálculos deben ser explicables, coherentes y centralizados.

La falta de información debe mostrarse como tal y no convertirse automáticamente en un valor positivo o negativo.

## 11. Internacionalización

Agro Fields debe contemplar español e inglés desde el diseño.

La interfaz deberá localizar:

- Fechas.
- Números.
- Monedas.
- Unidades.
- Terminología técnica.
- Formularios.
- Errores.
- Estados.
- Ayuda.

La localización no debe alterar los datos técnicos originales.

La expansión a otros países requiere revisar normativa, catálogos, unidades y prácticas productivas locales.

## 12. Alcance y evolución

El desarrollo será progresivo.

**Primera prioridad: consolidar el núcleo**

1. Identidad del Activo Agro.
2. Expediente Digital Permanente.
3. Seguridad, privacidad y permisos.
4. Evidencias e historial.
5. Gestión Productiva esencial.
6. Experiencia sencilla y offline-first.

La consolidación de este núcleo incluye auditar y resolver la relación entre los modelos e identificadores existentes, sin perder información ni anticipar migraciones que todavía no estén justificadas.

**Evolución posterior**

7. Territorio Inteligente.
8. Marketplace de Campos.
9. Marketplace Agroalimentario.
10. Logística y transporte.
11. Emergencias Agroganaderas.
12. Trazabilidad y comercio exterior.

La inteligencia artificial avanzada, analítica predictiva, valoración, seguros, integraciones complejas y expansión internacional quedan sujetas a evaluación de necesidad, viabilidad, costo y riesgo.

## 13. Criterios de éxito

Agro Fields deberá demostrar progresivamente que:

- El mismo activo conserva identidad e historial aunque cambien titularidad, actividad o publicación.
- Los usuarios comprenden qué información está declarada, respaldada, verificada, vencida o ausente.
- Los permisos protegen la información privada.
- Las operaciones prioritarias funcionan con conectividad limitada.
- Los módulos se conectan mediante el Activo Agro y sus relaciones.
- La información puede reutilizarse sin duplicar expedientes.
- Los avances técnicos se demuestran con código, pruebas y evidencias.
- El sistema puede crecer sin perder sencillez ni confiabilidad.

## 14. Gobierno documental y técnico

Este documento constituye la referencia estratégica de trabajo de Agro Fields V8, versión 2.0, con línea de base al 30/10/2026.

Su función es orientar los demás documentos:

- **Matriz General V2:** traduce el concepto en requisitos, prioridades, dependencias y GAP.
- **Bitácora V2:** registra hechos, auditorías, decisiones, pruebas y evidencias.
- **Roadmap V2:** organiza etapas, dependencias y criterios de salida.
- **Arquitectura y código:** materializan las decisiones aprobadas.

Ninguno de estos documentos reemplaza la verificación del código real ni las pruebas.

Los estados técnicos deben reflejar evidencia comprobable. No se declarará una función implementada o validada solamente porque esté descrita en un documento.

---

**Principio de trabajo**

Matriz → GAP → Auditoría → Código real → Cambio mínimo → Test → Evidencia → Historial → Auditoría → Bitácora → Roadmap → Commit.

**Visión:** conectar con confianza y crecer con datos.

**Agro Fields V8 — Territorio inteligente: gestión, expediente, mercado.
