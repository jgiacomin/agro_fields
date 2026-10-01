// =====================================================================
// PRUEBAS DE LAS REGLAS DE FIRESTORE (Agro Fields V8)
// Se corren contra el emulador. No tocan tu proyecto real.
// Cada prueba dice qué debe pasar: PERMITIDO o PROHIBIDO.
// =====================================================================
import { readFileSync } from 'node:fs';
import { test, before, after, beforeEach } from 'node:test';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, setDoc, updateDoc, deleteDoc,
  addDoc, collection, getDocs, query, where,
} from 'firebase/firestore';

const ADMIN = 'RtUPcWdZHuQMNsDrza7firR2X2j1'; // tu UID
const DUENO = 'dueno';
const BROKER = 'broker';       // quien cargó el expediente (publicador)
const COMPRADOR = 'comprador';
const OTRO = 'otro';           // un usuario cualquiera sin relación

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-agro-rules',
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => {
  await env.cleanup();
});

// Antes de cada prueba se limpian los datos y se cargan los mismos de ejemplo.
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'usuarios/user1'), { uid: 'user1', nombre: 'Ana', rol: 'Comprador' });
    await setDoc(doc(db, 'activos_agro/a1'), { propietarioId: DUENO, publicadorId: BROKER, nombre: 'Campo de prueba' });
    await setDoc(doc(db, 'activos_publicos/p1'), { propietarioId: DUENO, estadoPublicacion: 'publicado', visible: true });
    await setDoc(doc(db, 'activos_publicos/p2'), { propietarioId: DUENO, estadoPublicacion: 'pendienteRevision', visible: false });
    await setDoc(doc(db, 'evidencias/e1'), { activoAgroId: 'a1', tipo: 'foto' });
    await setDoc(doc(db, 'auditoria_activos/au1'), { activoId: 'a1', usuarioId: DUENO, accion: 'crear' });
    await setDoc(doc(db, 'hashes_activos/h1'), { creadoPor: DUENO, fecha: new Date() });
    await setDoc(doc(db, 'chats/c1'), { propietarioId: DUENO, interesadoId: COMPRADOR, campoId: 'a1' });
    await setDoc(doc(db, 'chats/c1/mensajes/m1'), { senderId: COMPRADOR, text: 'hola' });
  });
});

const como = (uid) => env.authenticatedContext(uid).firestore();
const sinSesion = () => env.unauthenticatedContext().firestore();

// ------------------------- 1. SIN SESIÓN -------------------------
test('1. Sin iniciar sesión no se puede leer nada [PROHIBIDO]', async () => {
  await assertFails(getDoc(doc(sinSesion(), 'activos_publicos/p1')));
});

// ------------------------- 2. USUARIOS Y ROL -------------------------
test('2a. Un usuario nuevo se crea como Comprador [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como('nuevo'), 'usuarios/nuevo'), { uid: 'nuevo', nombre: 'Nuevo', rol: 'Comprador' }));
});

test('2b. Un usuario nuevo NO puede crearse como Administrador [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como('nuevo'), 'usuarios/nuevo'), { uid: 'nuevo', nombre: 'Nuevo', rol: 'Administrador' }));
});

test('2c. Un usuario NO puede cambiarse el rol [PROHIBIDO]', async () => {
  await assertFails(updateDoc(doc(como('user1'), 'usuarios/user1'), { rol: 'Administrador' }));
});

test('2d. Un usuario SÍ puede cambiar su nombre [PERMITIDO]', async () => {
  await assertSucceeds(updateDoc(doc(como('user1'), 'usuarios/user1'), { nombre: 'Ana María' }));
});

// ------------------------- 3. EXPEDIENTE PRIVADO -------------------------
test('3a. El dueño lee su expediente [PERMITIDO]', async () => {
  await assertSucceeds(getDoc(doc(como(DUENO), 'activos_agro/a1')));
});

test('3b. Quien lo cargó (broker) lee el expediente [PERMITIDO]', async () => {
  await assertSucceeds(getDoc(doc(como(BROKER), 'activos_agro/a1')));
});

test('3c. Un tercero NO lee el expediente [PROHIBIDO]', async () => {
  await assertFails(getDoc(doc(como(OTRO), 'activos_agro/a1')));
});

test('3d. Un tercero NO puede listar expedientes ajenos [PROHIBIDO]', async () => {
  const q = query(collection(como(OTRO), 'activos_agro'), where('propietarioId', '==', DUENO));
  await assertFails(getDocs(q));
});

test('3e. El dueño lista sus propios expedientes [PERMITIDO]', async () => {
  const q = query(collection(como(DUENO), 'activos_agro'), where('propietarioId', '==', DUENO));
  await assertSucceeds(getDocs(q));
});

test('3f. Nadie borra un expediente desde la app [PROHIBIDO]', async () => {
  await assertFails(deleteDoc(doc(como(DUENO), 'activos_agro/a1')));
});

test('3g. El dueño NO puede cederle el expediente a otro cambiando propietarioId [PROHIBIDO]', async () => {
  await assertFails(updateDoc(doc(como(DUENO), 'activos_agro/a1'), { propietarioId: OTRO }));
});

// ------------------------- 4. MARKETPLACE (RESUMEN PÚBLICO) -------------------------
test('4a. Un comprador lee un resumen publicado [PERMITIDO]', async () => {
  await assertSucceeds(getDoc(doc(como(COMPRADOR), 'activos_publicos/p1')));
});

test('4b. Un comprador NO lee un resumen pendiente de revisión [PROHIBIDO]', async () => {
  await assertFails(getDoc(doc(como(COMPRADOR), 'activos_publicos/p2')));
});

test('4c. El marketplace lista los publicados y visibles [PERMITIDO]', async () => {
  const q = query(
    collection(como(COMPRADOR), 'activos_publicos'),
    where('estadoPublicacion', '==', 'publicado'),
    where('visible', '==', true),
  );
  await assertSucceeds(getDocs(q));
});

test('4d. El dueño pide revisión (pendienteRevision) [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(DUENO), 'activos_publicos/a1'), {
    propietarioId: DUENO, estadoPublicacion: 'pendienteRevision', visible: false,
  }));
});

test('4e. El dueño NO puede publicar directo [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'activos_publicos/a1'), {
    propietarioId: DUENO, estadoPublicacion: 'publicado', visible: true,
  }));
});

test('4f. Un tercero NO puede pedir publicar el activo de otro [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(OTRO), 'activos_publicos/a1'), {
    propietarioId: OTRO, estadoPublicacion: 'pendienteRevision', visible: false,
  }));
});

test('4g. El administrador aprueba la publicación [PERMITIDO]', async () => {
  await assertSucceeds(updateDoc(doc(como(ADMIN), 'activos_publicos/p2'), {
    estadoPublicacion: 'publicado', visible: true,
  }));
});

// ------------------------- 5. AUDITORÍA Y EVIDENCIAS -------------------------
test('5a. El dueño agrega un evento de auditoría [PERMITIDO]', async () => {
  await assertSucceeds(addDoc(collection(como(DUENO), 'auditoria_activos'), {
    activoId: 'a1', usuarioId: DUENO, accion: 'editar',
  }));
});

test('5b. Un evento de auditoría NO se edita [PROHIBIDO]', async () => {
  await assertFails(updateDoc(doc(como(DUENO), 'auditoria_activos/au1'), { accion: 'otra' }));
});

test('5c. Un evento de auditoría NO se borra [PROHIBIDO]', async () => {
  await assertFails(deleteDoc(doc(como(DUENO), 'auditoria_activos/au1')));
});

test('5d. El dueño lista las evidencias de su activo [PERMITIDO]', async () => {
  const q = query(collection(como(DUENO), 'evidencias'), where('activoAgroId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
});

test('5e. Un tercero NO lista las evidencias de otro [PROHIBIDO]', async () => {
  const q = query(collection(como(OTRO), 'evidencias'), where('activoAgroId', '==', 'a1'));
  await assertFails(getDocs(q));
});

test('5f. Una evidencia NO se borra [PROHIBIDO]', async () => {
  await assertFails(deleteDoc(doc(como(DUENO), 'evidencias/e1')));
});

// ------------------------- 6. DUPLICADOS (HASHES) -------------------------
test('6a. Se puede preguntar por un hash puntual [PERMITIDO]', async () => {
  await assertSucceeds(getDoc(doc(como(OTRO), 'hashes_activos/h1')));
});

test('6b. NO se puede listar todos los hashes [PROHIBIDO]', async () => {
  await assertFails(getDocs(collection(como(OTRO), 'hashes_activos')));
});

test('6c. Se registra un hash nuevo con solo los datos permitidos [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(OTRO), 'hashes_activos/h2'), { creadoPor: OTRO, fecha: new Date() }));
});

test('6d. NO se guarda un hash con datos de más (ej: activoId) [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(OTRO), 'hashes_activos/h3'), { creadoPor: OTRO, fecha: new Date(), activoId: 'a1' }));
});

// ------------------------- 7. CHAT -------------------------
test('7a. Un participante lee los mensajes [PERMITIDO]', async () => {
  await assertSucceeds(getDoc(doc(como(COMPRADOR), 'chats/c1/mensajes/m1')));
});

test('7b. Un tercero NO lee los mensajes [PROHIBIDO]', async () => {
  await assertFails(getDoc(doc(como(OTRO), 'chats/c1/mensajes/m1')));
});

test('7c. Un participante envía un mensaje con su propio ID [PERMITIDO]', async () => {
  await assertSucceeds(addDoc(collection(como(DUENO), 'chats/c1/mensajes'), { senderId: DUENO, text: 'buenas' }));
});

test('7d. NO se puede enviar un mensaje haciéndose pasar por otro [PROHIBIDO]', async () => {
  await assertFails(addDoc(collection(como(DUENO), 'chats/c1/mensajes'), { senderId: COMPRADOR, text: 'trampa' }));
});

// =====================================================================
// 8 y 9. PRUEBAS NUEVAS: CHATS y EVENTOS_AFECTACION
// =====================================================================

const cargar = (fn) =>
  env.withSecurityRulesDisabled(async (ctx) => fn(ctx.firestore()));

// Un chat tal cual lo crea ChatService.crearChat (con "participantes").
const chatComoLoCreaLaApp = () => ({
  campoId: 'a1',
  propietarioId: DUENO,
  interesadoId: COMPRADOR,
  participantes: [DUENO, COMPRADOR],
  estado: 'activo',
  fechaCreacion: new Date(),
});

// Un evento con los campos del modelo EventoAfectacion.
const eventoDeEjemplo = (usuario) => ({
  eventoId: 'ev1',
  activoAgroId: 'a1',
  usuarioRegistrador: usuario,
  tipoEvento: 'ejemplo',
  subtipoEvento: 'ejemplo',
  fechaInicio: new Date(),
  fechaFin: null,
  descripcion: 'evento de prueba',
  origen: 'manual',
  estado: 'activo',
  afectaciones: [],
});

// ------------------------- 8. CHATS -------------------------
test('8a. Un participante lee su chat [PERMITIDO]', async () => {
  await assertSucceeds(getDoc(doc(como(COMPRADOR), 'chats/c1')));
});

test('8b. Un tercero NO lee el chat [PROHIBIDO]', async () => {
  await assertFails(getDoc(doc(como(OTRO), 'chats/c1')));
});

test('8c. Un interesado crea un chat como lo hace la app [PERMITIDO]', async () => {
  await assertSucceeds(addDoc(collection(como(COMPRADOR), 'chats'), chatComoLoCreaLaApp()));
});

test('8d. Un tercero NO puede crear un chat entre otros dos [PROHIBIDO]', async () => {
  await assertFails(addDoc(collection(como(OTRO), 'chats'), chatComoLoCreaLaApp()));
});

test('8e. Buscar si el chat ya existe (la consulta de crearChat) [PERMITIDO]', async () => {
  const q = query(
    collection(como(COMPRADOR), 'chats'),
    where('campoId', '==', 'a1'),
    where('propietarioId', '==', DUENO),
    where('interesadoId', '==', COMPRADOR),
  );
  await assertSucceeds(getDocs(q));
});

test('8f. Listar mis chats COMO LO HACE LA APP (participantes array-contains) [PERMITIDO]', async () => {
  await cargar((db) => setDoc(doc(db, 'chats/c2'), chatComoLoCreaLaApp()));
  const q = query(collection(como(COMPRADOR), 'chats'), where('participantes', 'array-contains', COMPRADOR));
  await assertSucceeds(getDocs(q));
});

test('8g. Listar mis chats filtrando por interesadoId (alternativa) [PERMITIDO]', async () => {
  await cargar((db) => setDoc(doc(db, 'chats/c2'), chatComoLoCreaLaApp()));
  const q = query(collection(como(COMPRADOR), 'chats'), where('interesadoId', '==', COMPRADOR));
  await assertSucceeds(getDocs(q));
});

// ------------------------- 9. EVENTOS_AFECTACION -------------------------
test('9a. El dueño registra un evento en su Activo [PERMITIDO]', async () => {
  await assertSucceeds(addDoc(collection(como(DUENO), 'eventos_afectacion'), eventoDeEjemplo(DUENO)));
});

test('9b. Un tercero NO registra un evento en un Activo ajeno [PROHIBIDO]', async () => {
  await assertFails(addDoc(collection(como(OTRO), 'eventos_afectacion'), eventoDeEjemplo(OTRO)));
});

test('9c. Nadie borra un evento [PROHIBIDO]', async () => {
  await cargar((db) => setDoc(doc(db, 'eventos_afectacion/ev1'), eventoDeEjemplo(DUENO)));
  await assertFails(deleteDoc(doc(como(DUENO), 'eventos_afectacion/ev1')));
});

test('9d. Un tercero NO modifica un evento ajeno [PROHIBIDO]', async () => {
  await cargar((db) => setDoc(doc(db, 'eventos_afectacion/ev1'), eventoDeEjemplo(DUENO)));
  await assertFails(updateDoc(doc(como(OTRO), 'eventos_afectacion/ev1'), { descripcion: 'cambiado' }));
});

test('9e. El dueño NO modifica un evento (la Rule dice "de solo agregar") [PROHIBIDO]', async () => {
  await cargar((db) => setDoc(doc(db, 'eventos_afectacion/ev1'), eventoDeEjemplo(DUENO)));
  await assertFails(updateDoc(doc(como(DUENO), 'eventos_afectacion/ev1'), { descripcion: 'cambiado' }));
});

test('9f. El dueño NO puede mover un evento a otro Activo [PROHIBIDO]', async () => {
  await cargar((db) => setDoc(doc(db, 'eventos_afectacion/ev1'), eventoDeEjemplo(DUENO)));
  await assertFails(updateDoc(doc(como(DUENO), 'eventos_afectacion/ev1'), { activoAgroId: 'otroActivo' }));
});

test('9g. Un tercero NO lista los eventos de un Activo ajeno [PROHIBIDO]', async () => {
  const q = query(collection(como(OTRO), 'eventos_afectacion'), where('activoAgroId', '==', 'a1'));
  await assertFails(getDocs(q));
});
// ------------------------- 8h-8k. CHATS: candado de "participantes" -------------------------
test('8h. NO se puede crear un chat con un tercero metido en participantes [PROHIBIDO]', async () => {
  await assertFails(addDoc(collection(como(COMPRADOR), 'chats'), {
    ...chatComoLoCreaLaApp(), participantes: [DUENO, COMPRADOR, 'victima'],
  }));
});

test('8i. NO se puede crear un chat con participantes que no coinciden [PROHIBIDO]', async () => {
  await assertFails(addDoc(collection(como(COMPRADOR), 'chats'), {
    ...chatComoLoCreaLaApp(), participantes: [COMPRADOR, 'victima'],
  }));
});

test('8j. Un participante NO puede cambiar participantes [PROHIBIDO]', async () => {
  await cargar((db) => setDoc(doc(db, 'chats/c2'), chatComoLoCreaLaApp()));
  await assertFails(updateDoc(doc(como(COMPRADOR), 'chats/c2'), { participantes: [COMPRADOR, 'victima'] }));
});

test('8k. Un tercero NO lista los chats de otro usando participantes [PROHIBIDO]', async () => {
  await cargar((db) => setDoc(doc(db, 'chats/c2'), chatComoLoCreaLaApp()));
  const q = query(collection(como(OTRO), 'chats'), where('participantes', 'array-contains', COMPRADOR));
  await assertFails(getDocs(q));
});
