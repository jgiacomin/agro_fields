# ROLES_Y_PERMISOS.md

## Agro Fields V8

**Documento:** Gestión de Roles y Permisos  
**Versión:** 1.0  
**Estado:** En definición  

---

# 1. Objetivo

Definir un modelo flexible de usuarios, roles y permisos que permita controlar el acceso y las responsabilidades dentro del ecosistema Agro Fields V8.

El sistema debe permitir evolucionar desde un MVP inicial hacia un ecosistema con múltiples tipos de participantes, organizaciones y niveles de acceso.

---

# 2. Principios

## 2.1 Separación entre usuario y rol

Un usuario no debe estar limitado a una única función dentro del ecosistema.

Una misma persona puede participar con diferentes roles según el contexto.

Ejemplo:

Un usuario puede ser:

- Productor.
- Inversor.
- Profesional.
- Administrador.

---

## 2.2 Permisos configurables

Los permisos no deben depender exclusivamente del código.

La arquitectura debe permitir:

- agregar nuevos roles;
- modificar permisos;
- adaptar reglas por país;
- incorporar nuevos módulos.

---

## 2.3 Trazabilidad

Toda acción relevante debe quedar asociada a:

- usuario responsable;
- fecha;
- acción realizada;
- elemento afectado.

---

# 3. Roles principales

## 3.1 Productor

Representa al propietario o responsable de una actividad productiva.

Puede:

- crear activos;
- administrar información productiva;
- actualizar datos;
- gestionar documentación;
- participar en operaciones.

---

## 3.2 Inversor

Representa usuarios interesados en oportunidades agropecuarias.

Puede:

- consultar activos disponibles;
- guardar oportunidades;
- participar en procesos de inversión;
- recibir información relevante.

---

## 3.3 Profesional

Usuarios con conocimientos especializados.

Ejemplos:

- Ingeniero agrónomo.
- Veterinario.
- Tasador rural.
- Consultor.
- Técnico agropecuario.

Puede:

- realizar evaluaciones;
- emitir informes;
- aportar certificaciones;
- participar en análisis del activo.

---

## 3.4 Empresa

Representa organizaciones con múltiples usuarios asociados.

Puede:

- administrar activos;
- asignar integrantes;
- gestionar operaciones;
- representar una organización productiva.

---

## 3.5 Administrador

Rol de gestión del ecosistema.

Puede:

- administrar usuarios;
- configurar parámetros;
- gestionar catálogos;
- revisar auditorías;
- administrar permisos.

---

# 4. Permisos del sistema

Los permisos representan acciones específicas.

Ejemplos:

## Activos

- Crear activo.
- Editar activo.
- Visualizar activo.
- Archivar activo.
- Publicar activo.

---

## Evaluaciones

- Crear evaluación.
- Modificar evaluación.
- Aprobar información.
- Consultar historial.

---

## Usuarios

- Crear usuarios.
- Modificar perfiles.
- Asignar roles.
- Gestionar organizaciones.

---

## Configuración

- Administrar catálogos.
- Modificar parámetros.
- Gestionar reglas del sistema.

---

# 5. Modelo futuro de permisos

La arquitectura podrá evolucionar hacia:

- permisos por módulo;
- permisos por organización;
- permisos por país;
- permisos por suscripción;
- permisos temporales.

---

# 6. Auditoría de acciones

Toda operación crítica deberá registrar:

- usuario;
- rol utilizado;
- fecha y hora;
- acción;
- información modificada.

Ejemplo:

Usuario: