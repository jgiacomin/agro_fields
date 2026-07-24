# CATALOGOS_CENTRALIZADOS.md

## Agro Fields V8

**Documento:** Motor de Catálogos Centralizados  
**Versión:** 1.0  
**Estado:** En definición

---

# 1. Objetivo

Definir un sistema centralizado de catálogos que permita mantener información estructurada, consistente y reutilizable en todo el ecosistema Agro Fields V8.

Los catálogos evitarán datos escritos directamente en código y permitirán evolución del sistema sin modificar la lógica principal.

---

# 2. Principios

## 2.1 Datos estructurados centralizados

Los valores utilizados por la plataforma no deben estar escritos directamente en múltiples pantallas o módulos.

Ejemplo:

Incorrecto:
Ejemplo:

Incorrecto:

Un módulo guarda:

"Campo agrícola"

Otro módulo guarda:

"Campo Agricola"

Otro módulo guarda:

"Campo"

Resultado:

- datos duplicados;
- búsquedas inconsistentes;
- dificultad para análisis.

Correcto:

Todos los módulos consumen el mismo catálogo centralizado.

## 2.2 Configuración desacoplada

Los valores de los catálogos no deben estar fijos dentro de las pantallas o modelos.

La aplicación debe poder incorporar nuevos valores sin necesidad de publicar una nueva versión.

---

# 3. Catálogos principales

---

# 3.1 Tipos de activos agropecuarios

## Agrícolas

- Campo agrícola.
- Chacra.
- Quinta.
- Plantación.
- Invernadero.
- Vivero.
- Huerta productiva.

## Ganaderos

- Campo ganadero.
- Feedlot.
- Cabaña ganadera.
- Tambo.
- Granja ganadera.

## Mixtos

- Campo mixto.
- Establecimiento agropecuario integral.

## Forestales

- Forestación.
- Bosque productivo.
- Vivero forestal.

## Especializados

- Viñedo.
- Olivar.
- Frutícola.
- Apícola.
- Avícola.
- Porcícola.
- Cunícola.
- Acuicultura.

## Producciones alternativas

- Criadero de chinchillas.
- Criadero de ranas toro.
- Criadero de peces.
- Piscicultura.
- Salmonicultura.
- Truchicultura.
- Producción de hongos.
- Producción de lombrices.
- Otros emprendimientos productivos.

---

# 3.2 Actividades productivas

## Agricultura

- Soja.
- Maíz.
- Trigo.
- Girasol.
- Algodón.
- Arroz.
- Cebada.
- Sorgo.
- Maní.
- Caña de azúcar.

## Ganadería

- Bovinos carne.
- Bovinos leche.
- Ovinos.
- Caprinos.
- Porcinos.
- Equinos.
- Avicultura.

## Especialidades

- Vitivinicultura.
- Fruticultura.
- Olivicultura.
- Apicultura.
- Acuicultura.
- Forestación.

---

# 3.3 Tipos de operación

- Venta.
- Alquiler.
- Arrendamiento.
- Inversión.
- Asociación productiva.
- Permuta.
- Participación societaria.
- Búsqueda de inversor.

---

# 3.4 Estados del activo

- Disponible.
- Reservado.
- En negociación.
- Vendido.
- Alquilado.
- Suspendido.
- Archivado.

---

# 3.5 Características productivas

- Riego.
- Electricidad.
- Galpones.
- Corrales.
- Silos.
- Caminos internos.
- Vivienda.
- Maquinaria.
- Instalaciones productivas.
- Automatización.

---

# 3.6 Ubicaciones

Debe permitir adaptación internacional:

- País.
- Provincia/Estado.
- Departamento/Municipio.
- Localidad.
- Zona productiva.

---

# 3.7 Monedas

Ejemplos:

- ARS.
- USD.
- EUR.
- BRL.
- CLP.
- UYU.

---

# 3.8 Unidades

Superficie:

- Hectáreas.
- Acres.

Producción:

- Toneladas.
- Kilogramos.
- Litros.
- Cabezas.
- Unidades.

---

# 3.9 Profesiones y participantes

- Ingeniero agrónomo.
- Veterinario.
- Arquitecto.
- Contador.
- Abogado.
- Tasador rural.
- Corredor inmobiliario.
- Productor.
- Inversor.
- Empresa.

---

# 4. Arquitectura futura

Los catálogos podrán almacenarse en:

- Firestore.
- Servicios externos.
- Panel administrativo.

Estructura prevista:

---
---

# 5. Catálogo de cultivos

El sistema deberá contemplar cultivos productivos clasificados por categoría.

## Cereales

- Trigo.
- Maíz.
- Arroz.
- Cebada.
- Sorgo.

## Oleaginosas

- Soja.
- Girasol.
- Colza.
- Maní.

## Cultivos regionales

- Algodón.
- Yerba mate.
- Caña de azúcar.

## Frutales

- Vid.
- Olivo.
- Nogal.
- Pecán.
- Cítricos.

---

# 6. Catálogo de especies animales

## Bovinos

- Carne.
- Leche.

## Ovinos

- Carne.
- Lana.

## Avícolas

- Pollos parrilleros.
- Gallinas ponedoras.
- Reproductoras.

## Acuícolas

- Trucha.
- Salmón.
- Tilapia.
- Camarones.

## Producciones especiales

- Chinchilla.
- Conejos.
- Rana toro.

---

# 7. Evolución futura

Los catálogos podrán evolucionar hacia:

- gestión dinámica;
- administración desde panel interno;
- configuración por país;
- versionado histórico;
- reglas específicas por mercado;
- auditoría de cambios.

---

# 8. Relación con Inteligencia Artificial

La calidad y consistencia de los catálogos permitirá:

- clasificación automática de activos;
- búsquedas inteligentes;
- comparación entre oportunidades;
- análisis productivo;
- recomendaciones futuras;
- evaluación de confianza del activo.

---

# 9. Estado actual

Este documento define la arquitectura futura del ecosistema.

No modifica el alcance actual del MVP.

Su objetivo es asegurar:

- calidad de datos;
- consistencia;
- escalabilidad;
- trazabilidad.

### 2) Agregar al final la relación con IA

Porque es uno de los motivos principales del catálogo.

Al final:

```md
---

# 5. Relación con Inteligencia Artificial

La estructura de catálogos permitirá:

- clasificación automática de activos;
- búsquedas inteligentes;
- comparación de oportunidades;
- análisis productivo;
- recomendaciones futuras;
- evaluación de confianza del activo.

---

# 6. Estado actual

Este documento define la arquitectura futura del sistema.

No modifica el alcance actual del MVP.

Su objetivo es asegurar:

- calidad de datos;
- consistencia;
- escalabilidad;
- trazabilidad.
