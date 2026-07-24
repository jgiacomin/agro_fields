# CATALOGOS_CENTRALIZADOS.md

## Agro Fields V8

**Documento:** Motor de Catálogos Centralizados  
**Versión:** 1.0  
**Estado:** En definición  

---

# 1. Objetivo

Definir una arquitectura de catálogos centralizados que permita administrar información estructurada del ecosistema Agro Fields V8 de forma consistente, escalable y reutilizable.

Los catálogos tienen como objetivo:

- evitar valores duplicados dentro del código;
- mejorar la calidad de datos;
- permitir búsquedas eficientes;
- facilitar análisis estadísticos;
- preparar la información para inteligencia artificial futura;
- permitir adaptación por país y mercado.

---

# 2. Principios

## 2.1 Datos estructurados centralizados

Los valores utilizados por la plataforma no deben estar escritos directamente en múltiples pantallas o módulos.

Ejemplo:

Incorrecto:

---

## 2.2 Configuración desacoplada

Los catálogos deben poder evolucionar sin modificar constantemente el código principal.

Permite:

- agregar nuevas categorías;
- incorporar países;
- adaptar mercados;
- actualizar clasificaciones;
- mantener datos históricos.

---

# 3. Catálogo de tipos de activos

## 3.1 Activos agrícolas

Ejemplos:

- Campo agrícola.
- Campo mixto.
- Campo experimental.
- Producción extensiva.
- Producción intensiva.

---

## 3.2 Activos ganaderos

Ejemplos:

- Cría bovina.
- Invernada.
- Feedlot.
- Tambo.
- Ovinos.
- Caprinos.
- Porcinos.
- Equinos.

---

## 3.3 Activos avícolas

Ejemplos:

- Granja avícola.
- Producción de huevos.
- Pollos parrilleros.
- Incubadora.
- Reproductoras.

Datos específicos futuros:

- cantidad de aves;
- capacidad instalada;
- automatización;
- ciclos productivos.

---

## 3.4 Acuicultura

Ejemplos:

- Criadero de truchas.
- Criadero de salmones.
- Piscicultura.
- Tilapia.
- Camarones.
- Otras especies acuáticas.

Datos específicos futuros:

- capacidad de estanques;
- volumen de agua;
- calidad del agua;
- ciclos productivos.

---

## 3.5 Producciones especiales

Ejemplos:

- Criadero de chinchillas.
- Cunicultura.
- Rana toro.
- Apicultura.
- Caracoles.
- Hongos.
- Viveros.
- Hidroponía.

---

## 3.6 Forestales

Ejemplos:

- Forestación.
- Bosques implantados.
- Producción maderera.
- Viveros forestales.

---

## 3.7 Producciones frutícolas y regionales

Ejemplos:

- Viñedos.
- Olivares.
- Frutales.
- Nogales.
- Pecanes.
- Cítricos.

---

# 4. Catálogo de actividades productivas

Valores principales:

- Agricultura.
- Ganadería.
- Avicultura.
- Acuicultura.
- Forestal.
- Frutícola.
- Vitivinícola.
- Hortícola.
- Apicultura.
- Producciones alternativas.
- Agroindustria.

---

# 5. Catálogo de cultivos

Ejemplos:

## Cereales

- Trigo.
- Maíz.
- Arroz.
- Cebada.

## Oleaginosas

- Soja.
- Girasol.
- Colza.

## Cultivos regionales

- Algodón.
- Yerba mate.
- Caña de azúcar.

## Frutales

- Vid.
- Olivo.
- Nogal.
- Pecán.

---

# 6. Catálogo de especies animales

## Bovinos

- Carne.
- Leche.

## Ovinos

- Carne.
- Lana.

## Avícolas

- Pollos.
- Gallinas ponedoras.

## Acuícolas

- Trucha.
- Salmón.
- Tilapia.

## Especiales

- Chinchilla.
- Conejos.
- Rana toro.

---

# 7. Catálogo de ubicación

Incluye:

- Países.
- Provincias.
- Estados.
- Departamentos.
- Regiones productivas.
- Zonas agroecológicas.

---

# 8. Catálogo económico

Incluye:

## Monedas

Ejemplos:

- ARS.
- USD.
- EUR.
- BRL.

## Unidades

Ejemplos:

- Hectáreas.
- Acres.
- Metros cuadrados.

## Tipos de operación

- Venta.
- Alquiler.
- Arrendamiento.
- Asociación.
- Inversión.

---

# 9. Catálogo de profesionales

Ejemplos:

- Ingeniero agrónomo.
- Veterinario.
- Arquitecto.
- Contador.
- Abogado.
- Técnico agropecuario.
- Consultor ambiental.

---

# 10. Catálogo de estados operativos

Ejemplos:

- Borrador.
- Disponible.
- Publicado.
- En evaluación.
- Reservado.
- En negociación.
- Vendido.
- Cerrado.

---

# 11. Arquitectura prevista

Modelo conceptual:

---

# 12. Evolución futura

Los catálogos podrán evolucionar hacia:

- gestión dinámica;
- administración remota;
- configuración por país;
- versionado histórico;
- reglas específicas por mercado.

---

# 13. Relación con Inteligencia Artificial

La calidad de los catálogos permitirá:

- clasificación automática de activos;
- mejores búsquedas;
- comparación entre oportunidades;
- análisis productivo;
- recomendaciones;
- evaluación de confianza.

---

# 14. Estado actual

Este documento define la arquitectura futura del ecosistema.

No modifica el alcance actual del MVP.

Su objetivo es asegurar que Agro Fields V8 pueda crecer manteniendo:

- calidad de información;
- consistencia;
- escalabilidad;
- trazabilidad.