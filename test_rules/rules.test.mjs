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
  addDoc, collection, getDocs, query, where, runTransaction, writeBatch,
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
    await setDoc(doc(db, 'recursos/recurso_001'), {
    activoAgroId: 'a1',
     tipo: 'maquinaria',
    nombre: 'Tractor de prueba',
    });
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
// ------------------------- 10. PUBLICACIÓN VIEJA (RETIRADA EN EL PASO 1) -------------------------
// Estas pruebas copiaban lo que hacía la app antes del paso 1 (commit 0872e15),
// cuando el marketplace leía el expediente. Ahora publica sobre activos_publicos
// (ver pruebas PUB-01 a PUB-10). Se dejan como registro.

test('10a. RETIRADO: el feed viejo (listar activos_agro por publicado+visible) sigue rechazado para un comprador [PROHIBIDO]', async () => {
  const q = query(
    collection(como(COMPRADOR), 'activos_agro'),
    where('estadoPublicacion', '==', 'publicado'),
    where('visible', '==', true),
  );
  await assertFails(getDocs(q));
});

test('10b. RETIRADO: el feed viejo también sigue rechazado para el dueño [PROHIBIDO]', async () => {
  const q = query(
    collection(como(DUENO), 'activos_agro'),
    where('estadoPublicacion', '==', 'publicado'),
    where('visible', '==', true),
  );
  await assertFails(getDocs(q));
});

test('10c. PENDIENTE: el dueño todavía puede marcar el expediente como publicado; no afecta al marketplace, que lee activos_publicos [PERMITIDO]', async () => {
  await assertSucceeds(updateDoc(doc(como(DUENO), 'activos_agro/a1'), {
    estado: 'publicado', estadoPublicacion: 'publicado', visible: true,
  }));
});
// ------------------------- RECURSOS / INVENTARIO V1 -------------------------
test('RECURSOS-01. El dueño puede leer un recurso de su Activo [PERMITIDO]', async () => {
  await assertSucceeds(
    getDoc(doc(como(DUENO), 'recursos/recurso_001'))
  );
});
test('RECURSOS-02. Un tercero NO puede leer un recurso de un Activo ajeno [PROHIBIDO]', async () => {
  await assertFails(
    getDoc(doc(como(OTRO), 'recursos/recurso_001'))
  );
});
test('RECURSOS-03. El dueño puede crear un recurso en su Activo [PERMITIDO]', async () => {
  await assertSucceeds(
    setDoc(
      doc(como(DUENO), 'recursos/recurso_002'),
      {
        activoAgroId: 'a1',
        tipo: 'herramienta',
        nombre: 'Herramienta de prueba',
      }
    )
  );
});
test('RECURSOS-04. Un tercero NO puede crear un recurso en un Activo ajeno [PROHIBIDO]', async () => {
  await assertFails(
    setDoc(
      doc(como(OTRO), 'recursos/recurso_003'),
      {
        activoAgroId: 'a1',
        tipo: 'insumo',
        nombre: 'Insumo no autorizado',
      }
    )
  );
});
test('RECURSOS-05. El dueño NO puede modificar un recurso [PROHIBIDO]', async () => {
  await assertFails(
    updateDoc(
      doc(como(DUENO), 'recursos/recurso_001'),
      {
        nombre: 'Tractor modificado',
      }
    )
  );
});
test('RECURSOS-06. El dueño NO puede eliminar un recurso [PROHIBIDO]', async () => {
  await assertFails(
    deleteDoc(
      doc(como(DUENO), 'recursos/recurso_001')
    )
  );
});

// ------------------------- STOCK: MOVIMIENTOS_STOCK -------------------------
// Copian lo que hace movimiento_stock_service.registrarMovimiento:
// en UNA transaccion actualiza el saldo del recurso, crea el movimiento
// y crea el evento de auditoria.
const cargarRecursoConSaldo = () => cargar((db) =>
  setDoc(doc(db, 'recursos/rec_stock'), {
    activoAgroId: 'a1', tipo: 'insumo', nombre: 'Maíz', cantidadActual: 10,
  }));

const cargarMovimiento = () => cargar((db) =>
  setDoc(doc(db, 'movimientos_stock/m1'), {
    movimientoId: 'm1', activoAgroId: 'a1', recursoId: 'rec_stock', usuarioId: DUENO,
  }));

const movimientoComoLaApp = (db, { usuario = DUENO, saldoNuevo = 15, saldoGuardado = 15 } = {}) =>
  runTransaction(db, async (tx) => {
    const recursoRef = doc(db, 'recursos/rec_stock');
    const movimientoRef = doc(db, 'movimientos_stock/mov1');
    const auditoriaRef = doc(db, 'auditoria_activos/aud_mov1');
    const recurso = await tx.get(recursoRef);
    const saldoAnterior = recurso.data().cantidadActual;
    tx.update(recursoRef, {
      cantidadActual: saldoGuardado,
      ultimoMovimientoId: 'mov1',
      ultimoMovimientoAuditoriaId: 'aud_mov1',
    });
    tx.set(movimientoRef, {
      movimientoId: 'mov1', activoAgroId: 'a1', recursoId: 'rec_stock',
      tipoMovimiento: 'entrada', cantidad: 5, unidad: 'kg',
      usuarioId: usuario, auditoriaId: 'aud_mov1',
      saldoAnterior, saldoNuevo,
    });
    tx.set(auditoriaRef, {
      eventoId: 'aud_mov1', activoId: 'a1', usuarioId: usuario,
      tipo: 'modificacion', modulo: 'stock', accion: 'registrar_movimiento_stock',
      elementoAfectado: 'rec_stock', referencia: 'mov1',
    });
  });

test('STOCK-01. El dueño registra un movimiento como lo hace la app (transacción completa) [PERMITIDO]', async () => {
  await cargarRecursoConSaldo();
  await assertSucceeds(movimientoComoLaApp(como(DUENO)));
});

test('STOCK-02. Un tercero NO registra un movimiento en un Activo ajeno [PROHIBIDO]', async () => {
  await cargarRecursoConSaldo();
  await assertFails(movimientoComoLaApp(como(OTRO), { usuario: OTRO }));
});

test('STOCK-03. NO se registra un movimiento a nombre de otro usuario [PROHIBIDO]', async () => {
  await cargarRecursoConSaldo();
  await assertFails(movimientoComoLaApp(como(DUENO), { usuario: COMPRADOR }));
});

test('STOCK-04. NO se acepta un saldo del recurso distinto al del movimiento [PROHIBIDO]', async () => {
  await cargarRecursoConSaldo();
  await assertFails(movimientoComoLaApp(como(DUENO), { saldoNuevo: 15, saldoGuardado: 20 }));
});

test('STOCK-05. NO se cambia el saldo de un recurso a mano, sin movimiento [PROHIBIDO]', async () => {
  await cargarRecursoConSaldo();
  await assertFails(updateDoc(doc(como(DUENO), 'recursos/rec_stock'), {
    cantidadActual: 999,
    ultimoMovimientoId: 'no_existe',
    ultimoMovimientoAuditoriaId: 'no_existe',
  }));
});

test('STOCK-06. Un movimiento NO se edita [PROHIBIDO]', async () => {
  await cargarMovimiento();
  await assertFails(updateDoc(doc(como(DUENO), 'movimientos_stock/m1'), { saldoNuevo: 1 }));
});

test('STOCK-07. Un movimiento NO se borra [PROHIBIDO]', async () => {
  await cargarMovimiento();
  await assertFails(deleteDoc(doc(como(DUENO), 'movimientos_stock/m1')));
});

test('STOCK-08. El dueño lee un movimiento de su Activo [PERMITIDO]', async () => {
  await cargarMovimiento();
  await assertSucceeds(getDoc(doc(como(DUENO), 'movimientos_stock/m1')));
});

test('STOCK-09. Un tercero NO lee un movimiento de un Activo ajeno [PROHIBIDO]', async () => {
  await cargarMovimiento();
  await assertFails(getDoc(doc(como(OTRO), 'movimientos_stock/m1')));
});

test('STOCK-10. El dueño lista los movimientos de su Activo [PERMITIDO]', async () => {
  await cargarMovimiento();
  const q = query(collection(como(DUENO), 'movimientos_stock'), where('activoAgroId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
});

test('STOCK-11. Un tercero NO lista los movimientos de un Activo ajeno [PROHIBIDO]', async () => {
  await cargarMovimiento();
  const q = query(collection(como(OTRO), 'movimientos_stock'), where('activoAgroId', '==', 'a1'));
  await assertFails(getDocs(q));
});

// ------------------------- PUB. PUBLICAR SOBRE EL RESUMEN PUBLICO -------------------------
// Repiten lo que hace la app: publicarActivo escribe en un mismo batch
// el expediente (activos_agro, privado) y el resumen (activos_publicos).
// El administrador aprueba desde la consola de Firebase.

const resumenDe = (estado, visible) => ({
  activoId: 'a1',
  nombre: 'Campo de prueba',
  descripcion: 'Campo para pruebas',
  tipoActivo: 'agricola',
  pais: 'Argentina',
  provincia: 'Buenos Aires',
  localidad: 'Carlos Tejedor',
  superficie: 3290,
  nivelConfianza: 40,
  madurezPorcentaje: 45,
  producciones: ['Ganadería de cría'],
  propietarioId: DUENO,
  estadoPublicacion: estado,
  visible: visible,
  ultimaActualizacion: new Date(),
});

const publicarComoLaApp = (uid) => {
  const db = como(uid);
  const batch = writeBatch(db);
  batch.update(doc(db, 'activos_agro/a1'), {
    estadoPublicacion: 'pendienteRevision',
    visible: false,
  });
  batch.set(doc(db, 'activos_publicos/a1'), resumenDe('pendienteRevision', false));
  return batch.commit();
};

const aprobarComoAdmin = () => env.withSecurityRulesDisabled(async (ctx) => {
  await updateDoc(doc(ctx.firestore(), 'activos_publicos/a1'), {
    estadoPublicacion: 'publicado',
    visible: true,
  });
});

test('PUB-01. El dueño publica como la app (expediente + resumen pendiente) [PERMITIDO]', async () => {
  await assertSucceeds(publicarComoLaApp(DUENO));
});

test('PUB-02. El broker NO puede mandar a publicar (solo el dueño) [PROHIBIDO]', async () => {
  await assertFails(publicarComoLaApp(BROKER));
});

test('PUB-03. El dueño ve su resumen pendiente [PERMITIDO]', async () => {
  await publicarComoLaApp(DUENO);
  await assertSucceeds(getDoc(doc(como(DUENO), 'activos_publicos/a1')));
});

test('PUB-04. Un comprador NO ve el resumen mientras está pendiente [PROHIBIDO]', async () => {
  await publicarComoLaApp(DUENO);
  await assertFails(getDoc(doc(como(COMPRADOR), 'activos_publicos/a1')));
});

test('PUB-05. Aprobado por el admin, el comprador lo ve en el marketplace [PERMITIDO]', async () => {
  await publicarComoLaApp(DUENO);
  await aprobarComoAdmin();
  const q = query(
    collection(como(COMPRADOR), 'activos_publicos'),
    where('estadoPublicacion', '==', 'publicado'),
    where('visible', '==', true),
  );
  await assertSucceeds(getDocs(q));
});

test('PUB-06. El comprador sigue sin poder leer el expediente privado [PROHIBIDO]', async () => {
  await publicarComoLaApp(DUENO);
  await aprobarComoAdmin();
  await assertFails(getDoc(doc(como(COMPRADOR), 'activos_agro/a1')));
});

test('PUB-07. El dueño pausa como la app y deja de verse [PERMITIDO]', async () => {
  await publicarComoLaApp(DUENO);
  await aprobarComoAdmin();
  await assertSucceeds(updateDoc(doc(como(DUENO), 'activos_publicos/a1'), {
    estadoPublicacion: 'pausado',
    visible: false,
    ultimaActualizacion: new Date(),
  }));
  await assertFails(getDoc(doc(como(COMPRADOR), 'activos_publicos/a1')));
});

test('PUB-08. El dueño NO puede hacerse visible solo [PROHIBIDO]', async () => {
  await publicarComoLaApp(DUENO);
  await assertFails(updateDoc(doc(como(DUENO), 'activos_publicos/a1'), {
    visible: true,
  }));
});

test('PUB-09. El dueño vuelve a publicar después de pausar (vuelve a revisión) [PERMITIDO]', async () => {
  await publicarComoLaApp(DUENO);
  await aprobarComoAdmin();
  await updateDoc(doc(como(DUENO), 'activos_publicos/a1'), {
    estadoPublicacion: 'pausado', visible: false,
  });
  await assertSucceeds(publicarComoLaApp(DUENO));
});

test('PUB-10. Un tercero NO puede pausar el resumen de otro [PROHIBIDO]', async () => {
  await publicarComoLaApp(DUENO);
  await aprobarComoAdmin();
  await assertFails(updateDoc(doc(como(OTRO), 'activos_publicos/a1'), {
    estadoPublicacion: 'pausado', visible: false,
  }));
});

// ------------------------- OPOR. OPORTUNIDADES PRIVADAS (PASO 2) -------------------------
// Una oportunidad guarda montos, ubicacion exacta, documentos y evidencias.
// Solo la leen el admin y quien tiene el Activo. Antes del paso 2,
// cualquier usuario logueado leia las oportunidades 'activa' completas.

const oportunidadDe = (activoId) => ({
  oportunidadId: 'o1',
  creadorId: DUENO,
  titulo: 'Busco produccion de maiz',
  activoId: activoId,
  estado: 'activa',
  montoObjetivo: 100000,
  costosEstimados: 40000,
  ubicacionEspecifica: 'Lote 4, camino vecinal km 12',
  documentacion: ['doc_privado'],
});

const cargarOportunidad = () => cargar((db) =>
  setDoc(doc(db, 'oportunidades_agro/o1'), oportunidadDe('a1')));

test('OPOR-01. El dueño lee su oportunidad [PERMITIDO]', async () => {
  await cargarOportunidad();
  await assertSucceeds(getDoc(doc(como(DUENO), 'oportunidades_agro/o1')));
});

test('OPOR-02. Un tercero NO lee una oportunidad activa ajena (con montos y documentos) [PROHIBIDO]', async () => {
  await cargarOportunidad();
  await assertFails(getDoc(doc(como(OTRO), 'oportunidades_agro/o1')));
});

test('OPOR-03. Un tercero NO lista las oportunidades activas [PROHIBIDO]', async () => {
  await cargarOportunidad();
  const q = query(collection(como(OTRO), 'oportunidades_agro'), where('estado', '==', 'activa'));
  await assertFails(getDocs(q));
});

test('OPOR-04. El dueño lista las oportunidades de su Activo [PERMITIDO]', async () => {
  await cargarOportunidad();
  const q = query(collection(como(DUENO), 'oportunidades_agro'), where('activoId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
});

test('OPOR-05. El dueño crea una oportunidad de su Activo [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(DUENO), 'oportunidades_agro/o2'), oportunidadDe('a1')));
});

test('OPOR-06. Un tercero NO crea una oportunidad en un Activo ajeno [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(OTRO), 'oportunidades_agro/o2'), oportunidadDe('a1')));
});

test('OPOR-07. Sin Activo, un usuario NO crea una oportunidad (por ahora solo el admin) [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(OTRO), 'oportunidades_agro/o2'), oportunidadDe(null)));
});

test('OPOR-08. El dueño NO puede mover una oportunidad a otro Activo [PROHIBIDO]', async () => {
  await cargarOportunidad();
  await assertFails(updateDoc(doc(como(DUENO), 'oportunidades_agro/o1'), { activoId: 'otro_activo' }));
});

test('OPOR-09. El administrador lee cualquier oportunidad [PERMITIDO]', async () => {
  await cargarOportunidad();
  await assertSucceeds(getDoc(doc(como(ADMIN), 'oportunidades_agro/o1')));
});

test('OPOR-10. El comprador tampoco lista las de un Activo ajeno filtrando por activoId [PROHIBIDO]', async () => {
  await cargarOportunidad();
  const q = query(collection(como(COMPRADOR), 'oportunidades_agro'), where('activoId', '==', 'a1'));
  await assertFails(getDocs(q));
});

// ------------------------- AUT. AUTORIZACIONES EN LAS REGLAS (PASO 3) -------------------------
// Un encargado puede trabajar sobre el Activo si el dueño le dio una
// autorización ACTIVA y VIGENTE para ese permiso y ese ámbito.
// Nombre armado del documento: activoId__usuario__permiso__ambito.

const ENCARGADO = 'encargado';
const AYER = new Date(Date.now() - 24 * 60 * 60 * 1000);
const MANANA = new Date(Date.now() + 24 * 60 * 60 * 1000);

const idAut = (permiso, ambito, usuario = ENCARGADO, activo = 'a1') =>
  `${activo}__${usuario}__${permiso}__${ambito}`;

const autorizacionDe = (permiso, ambito, extra = {}) => ({
  autorizacionId: idAut(permiso, ambito, extra.usuarioAutorizado ?? ENCARGADO, extra.activoId ?? 'a1'),
  activoId: 'a1',
  usuarioAutorizado: ENCARGADO,
  quienOtorga: DUENO,
  rol: 'encargado',
  permiso,
  ambito: { tipo: ambito, referenciaId: null, descripcion: null },
  fechaInicio: AYER,
  fechaFin: null,
  estado: 'activa',
  condiciones: [],
  puedeDelegar: false,
  fechaOtorgamiento: AYER,
  ...extra,
});

const darAutorizacion = (permiso, ambito, extra = {}) => cargar((db) =>
  setDoc(doc(db, 'autorizaciones_activos', idAut(permiso, ambito)), autorizacionDe(permiso, ambito, extra)));

const trabajoDe = (uid) => ({
  trabajoId: 't_enc', activoAgroId: 'a1', actividad: 'Siembra', estado: 'PLANIFICADO', responsableId: uid,
});

test('AUT-01. El encargado con permiso "crear trabajo" carga un trabajo [PERMITIDO]', async () => {
  await darAutorizacion('crear', 'trabajo');
  await assertSucceeds(setDoc(doc(como(ENCARGADO), 'trabajos/t_enc'), trabajoDe(ENCARGADO)));
});

test('AUT-02. Sin autorización, el encargado NO carga un trabajo [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(ENCARGADO), 'trabajos/t_enc'), trabajoDe(ENCARGADO)));
});

test('AUT-03. Una autorización revocada NO sirve [PROHIBIDO]', async () => {
  await darAutorizacion('crear', 'trabajo', { estado: 'revocada' });
  await assertFails(setDoc(doc(como(ENCARGADO), 'trabajos/t_enc'), trabajoDe(ENCARGADO)));
});

test('AUT-04. Una autorización vencida NO sirve [PROHIBIDO]', async () => {
  await darAutorizacion('crear', 'trabajo', { fechaFin: new Date(Date.now() - 60 * 60 * 1000) });
  await assertFails(setDoc(doc(como(ENCARGADO), 'trabajos/t_enc'), trabajoDe(ENCARGADO)));
});

test('AUT-05. Una autorización que empieza mañana todavía NO sirve [PROHIBIDO]', async () => {
  await darAutorizacion('crear', 'trabajo', { fechaInicio: MANANA });
  await assertFails(setDoc(doc(como(ENCARGADO), 'trabajos/t_enc'), trabajoDe(ENCARGADO)));
});

test('AUT-06. El permiso "ver" NO alcanza para crear [PROHIBIDO]', async () => {
  await darAutorizacion('ver', 'trabajo');
  await assertFails(setDoc(doc(como(ENCARGADO), 'trabajos/t_enc'), trabajoDe(ENCARGADO)));
});

test('AUT-07. Con "ver trabajo", el encargado lista los trabajos del Activo [PERMITIDO]', async () => {
  await darAutorizacion('ver', 'trabajo');
  await cargar((db) => setDoc(doc(db, 'trabajos/t1'), trabajoDe(DUENO)));
  const q = query(collection(como(ENCARGADO), 'trabajos'), where('activoAgroId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
});

test('AUT-08. El encargado registra stock como la app (ver + crear en recursos e inventario) [PERMITIDO]', async () => {
  await darAutorizacion('ver', 'recursosInventario');
  await darAutorizacion('crear', 'recursosInventario');
  await cargarRecursoConSaldo();
  await assertSucceeds(movimientoComoLaApp(como(ENCARGADO), { usuario: ENCARGADO }));
});

test('AUT-09. El encargado NO registra stock a nombre del dueño [PROHIBIDO]', async () => {
  await darAutorizacion('ver', 'recursosInventario');
  await darAutorizacion('crear', 'recursosInventario');
  await cargarRecursoConSaldo();
  await assertFails(movimientoComoLaApp(como(ENCARGADO), { usuario: DUENO }));
});

test('AUT-10. El encargado sube una evidencia con "crear evidencias" [PERMITIDO]', async () => {
  await darAutorizacion('crear', 'evidencias');
  await assertSucceeds(setDoc(doc(como(ENCARGADO), 'evidencias/e_enc'), { activoAgroId: 'a1', tipo: 'foto' }));
});

test('AUT-11. Autorizado en trabajos, el encargado NO lee el expediente privado [PROHIBIDO]', async () => {
  await darAutorizacion('ver', 'trabajo');
  await assertFails(getDoc(doc(como(ENCARGADO), 'activos_agro/a1')));
});

test('AUT-12. El encargado NO lee la auditoría del Activo [PROHIBIDO]', async () => {
  await darAutorizacion('crear', 'trabajo');
  await assertFails(getDoc(doc(como(ENCARGADO), 'auditoria_activos/au1')));
});

test('AUT-13. Una autorización para un lote puntual NO cuenta en V1 [PROHIBIDO]', async () => {
  await darAutorizacion('crear', 'trabajo', { ambito: { tipo: 'trabajo', referenciaId: 'lote-1', descripcion: null } });
  await assertFails(setDoc(doc(como(ENCARGADO), 'trabajos/t_enc'), trabajoDe(ENCARGADO)));
});

test('AUT-14. El dueño da una autorización con el nombre armado [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(DUENO), 'autorizaciones_activos', idAut('crear', 'trabajo')),
    autorizacionDe('crear', 'trabajo')));
});

test('AUT-15. NO se guarda una autorización con un nombre al azar [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'autorizaciones_activos/x7Gk2azar'),
    autorizacionDe('crear', 'trabajo', { autorizacionId: 'x7Gk2azar' })));
});

test('AUT-16. El encargado NO se da una autorización a sí mismo [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(ENCARGADO), 'autorizaciones_activos', idAut('crear', 'trabajo')),
    autorizacionDe('crear', 'trabajo', { quienOtorga: ENCARGADO })));
});

test('AUT-17. El dueño revoca una autorización y deja de servir [PERMITIDO]', async () => {
  await darAutorizacion('crear', 'trabajo');
  await assertSucceeds(updateDoc(doc(como(DUENO), 'autorizaciones_activos', idAut('crear', 'trabajo')),
    { estado: 'revocada' }));
  await assertFails(setDoc(doc(como(ENCARGADO), 'trabajos/t_enc'), trabajoDe(ENCARGADO)));
});

test('AUT-18. El dueño NO puede cambiarle el permiso a una autorización existente [PROHIBIDO]', async () => {
  await darAutorizacion('ver', 'trabajo');
  await assertFails(updateDoc(doc(como(DUENO), 'autorizaciones_activos', idAut('ver', 'trabajo')),
    { permiso: 'crear' }));
});

test('AUT-19. Una autorización de otro Activo NO sirve para este [PROHIBIDO]', async () => {
  await cargar((db) => setDoc(doc(db, 'autorizaciones_activos', idAut('crear', 'trabajo', ENCARGADO, 'otro_activo')),
    autorizacionDe('crear', 'trabajo', { activoId: 'otro_activo' })));
  await assertFails(setDoc(doc(como(ENCARGADO), 'trabajos/t_enc'), trabajoDe(ENCARGADO)));
});

// ------------------------- CAMPOS. ARCHIVO HISTÓRICO CONGELADO (PASO 5) -------------------------
// La colección vieja "campos" solo tenía datos de prueba. No se migra ni se
// borra: se puede leer lo que ya existe, pero nadie escribe desde la app.

const campoViejo = (estado = 'disponible') => ({
  propietarioId: DUENO, publicadorId: DUENO, tipoRelacion: 'propietario',
  nombre: 'Campo viejo', hectareas: 10, estadoPublicacion: estado,
});

const cargarCampoViejo = (estado) => cargar((db) =>
  setDoc(doc(db, 'campos/c_viejo'), campoViejo(estado)));

test('CAMPOS-01. El dueño lee su campo viejo [PERMITIDO]', async () => {
  await cargarCampoViejo('pausado');
  await assertSucceeds(getDoc(doc(como(DUENO), 'campos/c_viejo')));
});

test('CAMPOS-02. Un usuario logueado lee un campo viejo disponible (chats viejos) [PERMITIDO]', async () => {
  await cargarCampoViejo('disponible');
  await assertSucceeds(getDoc(doc(como(COMPRADOR), 'campos/c_viejo')));
});

test('CAMPOS-03. NO se crean campos nuevos en la colección vieja [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'campos/c_nuevo'), campoViejo()));
});

test('CAMPOS-04. El dueño NO modifica un campo viejo [PROHIBIDO]', async () => {
  await cargarCampoViejo('disponible');
  await assertFails(updateDoc(doc(como(DUENO), 'campos/c_viejo'), { nombre: 'Cambiado' }));
});

test('CAMPOS-05. El dueño NO borra un campo viejo (archivar no es borrar) [PROHIBIDO]', async () => {
  await cargarCampoViejo('disponible');
  await assertFails(deleteDoc(doc(como(DUENO), 'campos/c_viejo')));
});

test('CAMPOS-06. Un tercero NO lee un campo viejo que no estaba disponible [PROHIBIDO]', async () => {
  await cargarCampoViejo('pausado');
  await assertFails(getDoc(doc(como(OTRO), 'campos/c_viejo')));
});

test('CAMPOS-07. El administrador sí puede corregir un campo viejo [PERMITIDO]', async () => {
  await cargarCampoViejo('disponible');
  await assertSucceeds(updateDoc(doc(como(ADMIN), 'campos/c_viejo'), { nombre: 'Corregido' }));
});

// ------------------------- PROD. PRODUCCION (PASO 6a, GAP-PROD-01) -------------------------
// Unidades (donde), grupos (que) y eventos (que paso), colgados del Activo.
// Los ve y carga el dueño o quien tenga permiso en el ámbito "produccion".
// Los eventos son de solo agregar.

const HOY = new Date();

const unidadDe = (uid, extra = {}) => ({
  unidadId: 'u1', activoAgroId: 'a1', tipo: 'potrero', nombre: 'Potrero 1',
  superficieHa: null, capacidad: null, estado: 'activa', creadoPor: uid, fechaCreacion: HOY, ...extra,
});

const grupoDe = (uid, extra = {}) => ({
  grupoId: 'g1', activoAgroId: 'a1', actividad: 'ganaderia', nombre: 'Rodeo de cría',
  etapa: 'cria', tenencia: 'propios', modoIdentificacion: 'porLote', estado: 'activo',
  creadoPor: uid, fechaCreacion: HOY, ...extra,
});

const eventoProdDe = (uid, extra = {}) => ({
  eventoId: 'ev1', activoAgroId: 'a1', grupoId: 'g1', tipo: 'alta', cantidad: 10,
  categoria: 'ternero', origen: 'compra', fechaHecho: HOY, fechaCarga: HOY,
  cargadoPor: uid, estadoDato: 'declarado', evidenciaIds: [], ...extra,
});

const cargarUnidad = () => cargar((db) => setDoc(doc(db, 'unidades_productivas/u1'), unidadDe(DUENO)));
const cargarGrupo = () => cargar((db) => setDoc(doc(db, 'grupos_productivos/g1'), grupoDe(DUENO)));
const cargarEventoProd = () => cargar((db) => setDoc(doc(db, 'eventos_productivos/ev1'), eventoProdDe(DUENO)));

test('PROD-01. El dueño crea un potrero en su Activo [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(DUENO), 'unidades_productivas/u1'), unidadDe(DUENO)));
});

test('PROD-02. Un tercero NO crea un potrero en un Activo ajeno [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(OTRO), 'unidades_productivas/u1'), unidadDe(OTRO)));
});

test('PROD-03. NO se crea una unidad a nombre de otro usuario [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'unidades_productivas/u1'), unidadDe(OTRO)));
});

test('PROD-04. El dueño lista las unidades de su Activo [PERMITIDO]', async () => {
  await cargarUnidad();
  const q = query(collection(como(DUENO), 'unidades_productivas'), where('activoAgroId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
});

test('PROD-05. Un tercero NO lista las unidades de un Activo ajeno [PROHIBIDO]', async () => {
  await cargarUnidad();
  const q = query(collection(como(OTRO), 'unidades_productivas'), where('activoAgroId', '==', 'a1'));
  await assertFails(getDocs(q));
});

test('PROD-06. El dueño archiva un potrero (archivar no es borrar) [PERMITIDO]', async () => {
  await cargarUnidad();
  await assertSucceeds(updateDoc(doc(como(DUENO), 'unidades_productivas/u1'), { estado: 'archivada' }));
});

test('PROD-07. Una unidad NO se pasa a otro Activo [PROHIBIDO]', async () => {
  await cargarUnidad();
  await assertFails(updateDoc(doc(como(DUENO), 'unidades_productivas/u1'), { activoAgroId: 'a2' }));
});

test('PROD-08. Una unidad NO se borra [PROHIBIDO]', async () => {
  await cargarUnidad();
  await assertFails(deleteDoc(doc(como(DUENO), 'unidades_productivas/u1')));
});

test('PROD-09. El dueño crea un rodeo en su Activo [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(DUENO), 'grupos_productivos/g1'), grupoDe(DUENO)));
});

test('PROD-10. La tenencia de un rodeo NO se cambia a mano (va con un evento) [PROHIBIDO]', async () => {
  await cargarGrupo();
  await assertFails(updateDoc(doc(como(DUENO), 'grupos_productivos/g1'), { tenencia: 'hoteleria' }));
});

test('PROD-11. El dueño registra un alta de 10 terneros [PERMITIDO]', async () => {
  await cargarGrupo();
  await assertSucceeds(setDoc(doc(como(DUENO), 'eventos_productivos/ev1'), eventoProdDe(DUENO)));
});

test('PROD-12. Un evento NO se edita [PROHIBIDO]', async () => {
  await cargarGrupo();
  await cargarEventoProd();
  await assertFails(updateDoc(doc(como(DUENO), 'eventos_productivos/ev1'), { cantidad: 100 }));
});

test('PROD-13. Un evento NO se borra [PROHIBIDO]', async () => {
  await cargarGrupo();
  await cargarEventoProd();
  await assertFails(deleteDoc(doc(como(DUENO), 'eventos_productivos/ev1')));
});

test('PROD-14. NO se registra un evento con un rodeo de otro Activo [PROHIBIDO]', async () => {
  await cargar(async (db) => {
    await setDoc(doc(db, 'activos_agro/a2'), { propietarioId: OTRO, nombre: 'Campo ajeno' });
    await setDoc(doc(db, 'grupos_productivos/g2'), grupoDe(OTRO, { grupoId: 'g2', activoAgroId: 'a2' }));
  });
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev1'), eventoProdDe(DUENO, { grupoId: 'g2' })));
});

test('PROD-15. NO se registra un evento de un tipo inventado [PROHIBIDO]', async () => {
  await cargarGrupo();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev1'), eventoProdDe(DUENO, { tipo: 'inventado' })));
});

test('PROD-16. NO se registra una cantidad negativa [PROHIBIDO]', async () => {
  await cargarGrupo();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev1'), eventoProdDe(DUENO, { cantidad: -5 })));
});

test('PROD-17. NO se registra un evento a nombre de otro usuario [PROHIBIDO]', async () => {
  await cargarGrupo();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev1'), eventoProdDe(ENCARGADO)));
});

test('PROD-18. El encargado con "crear produccion" registra un evento [PERMITIDO]', async () => {
  await cargarGrupo();
  await darAutorizacion('crear', 'produccion');
  await assertSucceeds(setDoc(doc(como(ENCARGADO), 'eventos_productivos/ev1'), eventoProdDe(ENCARGADO)));
});

test('PROD-19. Con permiso solo en trabajos, el encargado NO registra eventos [PROHIBIDO]', async () => {
  await cargarGrupo();
  await darAutorizacion('crear', 'trabajo');
  await assertFails(setDoc(doc(como(ENCARGADO), 'eventos_productivos/ev1'), eventoProdDe(ENCARGADO)));
});

test('PROD-20. Con "ver produccion" el encargado lista los eventos pero NO crea [PERMITIDO + PROHIBIDO]', async () => {
  await cargarGrupo();
  await cargarEventoProd();
  await darAutorizacion('ver', 'produccion');
  const q = query(collection(como(ENCARGADO), 'eventos_productivos'), where('activoAgroId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
  await assertFails(setDoc(doc(como(ENCARGADO), 'eventos_productivos/ev2'), eventoProdDe(ENCARGADO, { eventoId: 'ev2' })));
});

// ------------------------- OPER. OPERACIONES PROTEGIDAS (PASO 7a, GAP-OPER-01) -------------------------
// La ficha del negocio (operaciones_protegidas) y lo que va pasando
// (eventos_operacion). Datos de plata: SOLO el dueño o quien tenga permiso
// en el ámbito "operaciones". Quien cargó el expediente (broker) NO entra.
// La operación se corrige en curso; cerrada queda fija. Los eventos son de solo agregar.

const AHORA_OPER = new Date();

const operacionDe = (uid, extra = {}) => ({
  operacionId: 'op1', activoAgroId: 'a1', creadoPor: uid, fechaCreacion: AHORA_OPER,
  producto: 'hacienda', descripcionProducto: null, cantidad: 40, unidad: 'cabezas', grupoId: null,
  importe: 15000000, moneda: 'ARS', formaPago: 'cheque',
  comprador: { nombre: 'Frigorifico Ejemplo SA', identificacionFiscal: '30-12345678-9',
    representanteNombre: 'Juan Perez', representanteCaracter: 'apoderado', facultadArchivoRuta: null },
  garantias: [], contratoArchivoRuta: null, estado: 'enCurso', fechaCierre: null, observaciones: null,
  ...extra,
});

const eventoOperDe = (uid, extra = {}) => ({
  eventoId: 'eo1', operacionId: 'op1', activoAgroId: 'a1', tipo: 'pagoAcordado',
  fechaHecho: AHORA_OPER, fechaCarga: AHORA_OPER, cargadoPor: uid, estadoDato: 'declarado',
  archivoRutas: [], medioPago: 'cheque', importe: 5000000, moneda: 'ARS',
  fechaVencimiento: MANANA, banco: 'Banco Ejemplo', numero: '00012345', ...extra,
});

const cargarOperacion = (extra = {}) =>
  cargar((db) => setDoc(doc(db, 'operaciones_protegidas/op1'), operacionDe(DUENO, extra)));
const cargarEventoOper = () =>
  cargar((db) => setDoc(doc(db, 'eventos_operacion/eo1'), eventoOperDe(DUENO)));

test('OPER-01. El dueño crea una operación protegida en su Activo [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(DUENO), 'operaciones_protegidas/op1'), operacionDe(DUENO)));
});

test('OPER-02. Quien cargó el expediente (broker) NO crea ni lee operaciones [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(BROKER), 'operaciones_protegidas/op1'), operacionDe(BROKER)));
  await cargarOperacion();
  await assertFails(getDoc(doc(como(BROKER), 'operaciones_protegidas/op1')));
});

test('OPER-03. Un tercero NO crea una operación en un Activo ajeno [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(OTRO), 'operaciones_protegidas/op1'), operacionDe(OTRO)));
});

test('OPER-04. NO se crea una operación a nombre de otro usuario [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'operaciones_protegidas/op1'), operacionDe(ENCARGADO)));
});

test('OPER-05. Una operación NO nace cerrada [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'operaciones_protegidas/op1'), operacionDe(DUENO, { estado: 'cumplida' })));
});

test('OPER-06. NO se crea una operación con importe cero [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'operaciones_protegidas/op1'), operacionDe(DUENO, { importe: 0 })));
});

test('OPER-07. El dueño lista las operaciones de su Activo [PERMITIDO]', async () => {
  await cargarOperacion();
  const q = query(collection(como(DUENO), 'operaciones_protegidas'), where('activoAgroId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
});

test('OPER-08. Un tercero NO lista las operaciones de un Activo ajeno [PROHIBIDO]', async () => {
  await cargarOperacion();
  const q = query(collection(como(OTRO), 'operaciones_protegidas'), where('activoAgroId', '==', 'a1'));
  await assertFails(getDocs(q));
});

test('OPER-09. El dueño corrige el importe mientras está en curso [PERMITIDO]', async () => {
  await cargarOperacion();
  await assertSucceeds(updateDoc(doc(como(DUENO), 'operaciones_protegidas/op1'), { importe: 16000000 }));
});

test('OPER-10. Una operación NO se pasa a otro Activo [PROHIBIDO]', async () => {
  await cargarOperacion();
  await assertFails(updateDoc(doc(como(DUENO), 'operaciones_protegidas/op1'), { activoAgroId: 'a2' }));
});

test('OPER-11. El dueño cierra la operación como cumplida [PERMITIDO]', async () => {
  await cargarOperacion();
  await assertSucceeds(updateDoc(doc(como(DUENO), 'operaciones_protegidas/op1'), { estado: 'cumplida', fechaCierre: AHORA_OPER }));
});

test('OPER-12. Una operación cerrada NO se modifica [PROHIBIDO]', async () => {
  await cargarOperacion({ estado: 'cumplida', fechaCierre: AHORA_OPER });
  await assertFails(updateDoc(doc(como(DUENO), 'operaciones_protegidas/op1'), { importe: 1 }));
});

test('OPER-13. Una operación NO se borra [PROHIBIDO]', async () => {
  await cargarOperacion();
  await assertFails(deleteDoc(doc(como(DUENO), 'operaciones_protegidas/op1')));
});

test('OPER-14. El dueño registra un cheque acordado [PERMITIDO]', async () => {
  await cargarOperacion();
  await assertSucceeds(setDoc(doc(como(DUENO), 'eventos_operacion/eo1'), eventoOperDe(DUENO)));
});

test('OPER-15. Un evento de operación NO se edita [PROHIBIDO]', async () => {
  await cargarOperacion();
  await cargarEventoOper();
  await assertFails(updateDoc(doc(como(DUENO), 'eventos_operacion/eo1'), { importe: 1 }));
});

test('OPER-16. Un evento de operación NO se borra [PROHIBIDO]', async () => {
  await cargarOperacion();
  await cargarEventoOper();
  await assertFails(deleteDoc(doc(como(DUENO), 'eventos_operacion/eo1')));
});

test('OPER-17. NO se registra un evento con una operación de otro Activo [PROHIBIDO]', async () => {
  await cargar(async (db) => {
    await setDoc(doc(db, 'activos_agro/a2'), { propietarioId: OTRO, nombre: 'Campo ajeno' });
    await setDoc(doc(db, 'operaciones_protegidas/op2'), operacionDe(OTRO, { operacionId: 'op2', activoAgroId: 'a2' }));
  });
  await assertFails(setDoc(doc(como(DUENO), 'eventos_operacion/eo1'), eventoOperDe(DUENO, { operacionId: 'op2' })));
});

test('OPER-18. NO se registran eventos en una operación cancelada [PROHIBIDO]', async () => {
  await cargarOperacion({ estado: 'cancelada', fechaCierre: AHORA_OPER });
  await assertFails(setDoc(doc(como(DUENO), 'eventos_operacion/eo1'), eventoOperDe(DUENO)));
});

test('OPER-19. NO se registra un evento de un tipo inventado [PROHIBIDO]', async () => {
  await cargarOperacion();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_operacion/eo1'), eventoOperDe(DUENO, { tipo: 'inventado' })));
});

test('OPER-20. NO se registra un importe negativo [PROHIBIDO]', async () => {
  await cargarOperacion();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_operacion/eo1'), eventoOperDe(DUENO, { importe: -5 })));
});

test('OPER-21. NO se registra un evento a nombre de otro usuario [PROHIBIDO]', async () => {
  await cargarOperacion();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_operacion/eo1'), eventoOperDe(ENCARGADO)));
});

test('OPER-22. El encargado con "crear operaciones" registra un evento [PERMITIDO]', async () => {
  await cargarOperacion();
  await darAutorizacion('crear', 'operaciones');
  await assertSucceeds(setDoc(doc(como(ENCARGADO), 'eventos_operacion/eo1'), eventoOperDe(ENCARGADO)));
});

test('OPER-23. Con permiso solo en producción, el encargado NO ve las operaciones [PROHIBIDO]', async () => {
  await cargarOperacion();
  await darAutorizacion('ver', 'produccion');
  await assertFails(getDoc(doc(como(ENCARGADO), 'operaciones_protegidas/op1')));
});

test('OPER-24. Con "ver operaciones" el encargado lista los eventos pero NO crea [PERMITIDO + PROHIBIDO]', async () => {
  await cargarOperacion();
  await cargarEventoOper();
  await darAutorizacion('ver', 'operaciones');
  const q = query(collection(como(ENCARGADO), 'eventos_operacion'), where('activoAgroId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
  await assertFails(setDoc(doc(como(ENCARGADO), 'eventos_operacion/eo2'), eventoOperDe(ENCARGADO, { eventoId: 'eo2' })));
});

// =====================================================================
// PROF. PROFESIONALES INVITADOS (AF-093, GAP-PROF-01, 12/11/2026)
// Invitación = autorización "crear" en "expedienteProductivo" con rol
// profesional. El profesional registra intervenciones (solo agregar) y
// NO lee el expediente.
// =====================================================================

const PROFESIONAL = 'profesional';

const invitarProfesional = (extra = {}) => cargar((db) =>
  setDoc(doc(db, 'autorizaciones_activos', idAut('crear', 'expedienteProductivo', PROFESIONAL)),
    autorizacionDe('crear', 'expedienteProductivo', {
      usuarioAutorizado: PROFESIONAL, rol: 'profesional', motivo: 'invitacion_profesional', ...extra,
    })));

const intervencionDe = (uid, extra = {}) => ({
  intervencionId: 'iv1', activoAgroId: 'a1', profesionalId: uid, profesionalNombre: 'Ing. Pérez',
  tipo: 'visita', descripcion: 'Recorrida del lote 3', fecha: new Date(), estado: 'declarado',
  fechaRegistro: new Date(), ...extra,
});

const cargarIntervencion = () => cargar((db) =>
  setDoc(doc(db, 'intervenciones_profesionales/iv1'), intervencionDe(PROFESIONAL)));

test('PROF-01. El profesional invitado registra una intervención [PERMITIDO]', async () => {
  await invitarProfesional();
  await assertSucceeds(setDoc(doc(como(PROFESIONAL), 'intervenciones_profesionales/iv1'), intervencionDe(PROFESIONAL)));
});

test('PROF-02. Sin invitación NO registra intervenciones [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(PROFESIONAL), 'intervenciones_profesionales/iv1'), intervencionDe(PROFESIONAL)));
});

test('PROF-03. Con la invitación revocada NO registra [PROHIBIDO]', async () => {
  await invitarProfesional({ estado: 'revocada' });
  await assertFails(setDoc(doc(como(PROFESIONAL), 'intervenciones_profesionales/iv1'), intervencionDe(PROFESIONAL)));
});

test('PROF-04. NO registra a nombre de otro profesional [PROHIBIDO]', async () => {
  await invitarProfesional();
  await assertFails(setDoc(doc(como(PROFESIONAL), 'intervenciones_profesionales/iv1'), intervencionDe(OTRO)));
});

test('PROF-05. NO registra un tipo inventado ni sin descripción [PROHIBIDO]', async () => {
  await invitarProfesional();
  await assertFails(setDoc(doc(como(PROFESIONAL), 'intervenciones_profesionales/iv1'), intervencionDe(PROFESIONAL, { tipo: 'magia' })));
  await assertFails(setDoc(doc(como(PROFESIONAL), 'intervenciones_profesionales/iv1'), intervencionDe(PROFESIONAL, { descripcion: '' })));
});

test('PROF-06. NO se carga como verificada [PROHIBIDO]', async () => {
  await invitarProfesional();
  await assertFails(setDoc(doc(como(PROFESIONAL), 'intervenciones_profesionales/iv1'), intervencionDe(PROFESIONAL, { estado: 'verificado' })));
});

test('PROF-07. Una intervención NO se edita ni se borra [PROHIBIDO]', async () => {
  await invitarProfesional();
  await cargarIntervencion();
  await assertFails(updateDoc(doc(como(PROFESIONAL), 'intervenciones_profesionales/iv1'), { descripcion: 'otra cosa' }));
  await assertFails(deleteDoc(doc(como(DUENO), 'intervenciones_profesionales/iv1')));
});

test('PROF-08. El dueño ve las intervenciones de su campo [PERMITIDO]', async () => {
  await cargarIntervencion();
  const q = query(collection(como(DUENO), 'intervenciones_profesionales'), where('activoAgroId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
});

test('PROF-09. Otro usuario NO ve las intervenciones [PROHIBIDO]', async () => {
  await cargarIntervencion();
  await assertFails(getDoc(doc(como(OTRO), 'intervenciones_profesionales/iv1')));
  const q = query(collection(como(OTRO), 'intervenciones_profesionales'), where('activoAgroId', '==', 'a1'));
  await assertFails(getDocs(q));
});

test('PROF-10. El profesional ve SUS intervenciones del campo [PERMITIDO]', async () => {
  await invitarProfesional();
  await cargarIntervencion();
  const q = query(collection(como(PROFESIONAL), 'intervenciones_profesionales'),
    where('activoAgroId', '==', 'a1'), where('profesionalId', '==', PROFESIONAL));
  await assertSucceeds(getDocs(q));
});

test('PROF-11. El profesional NO lee el expediente del campo [PROHIBIDO]', async () => {
  await invitarProfesional();
  await assertFails(getDoc(doc(como(PROFESIONAL), 'activos_agro/a1')));
});

test('PROF-12. El profesional lista SUS invitaciones [PERMITIDO]', async () => {
  await invitarProfesional();
  const q = query(collection(como(PROFESIONAL), 'autorizaciones_activos'), where('usuarioAutorizado', '==', PROFESIONAL));
  await assertSucceeds(getDocs(q));
});

test('PROF-13. El profesional NO lista las autorizaciones de un campo [PROHIBIDO]', async () => {
  await invitarProfesional();
  const q = query(collection(como(PROFESIONAL), 'autorizaciones_activos'), where('activoId', '==', 'a1'));
  await assertFails(getDocs(q));
});

test('PROF-14. El dueño lista las autorizaciones de su campo [PERMITIDO]', async () => {
  await invitarProfesional();
  const q = query(collection(como(DUENO), 'autorizaciones_activos'), where('activoId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
});

test('PROF-15. Otro usuario NO lista las autorizaciones del campo [PROHIBIDO]', async () => {
  await invitarProfesional();
  const q = query(collection(como(OTRO), 'autorizaciones_activos'), where('activoId', '==', 'a1'));
  await assertFails(getDocs(q));
});

test('PROF-16. El dueño invita a un profesional con el nombre armado [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(DUENO), 'autorizaciones_activos', idAut('crear', 'expedienteProductivo', PROFESIONAL)),
    autorizacionDe('crear', 'expedienteProductivo', { usuarioAutorizado: PROFESIONAL, rol: 'profesional' })));
});

// =====================================================================
// MOV. TRASLADOS (AF-089, GAP-MOV-01, 12/11/2026)
// Una colección para todas las actividades. Dueño o autorizado en
// "movimientos". Solo cambia estado y lo recibido; no se borra.
// =====================================================================

const trasladoDe = (uid, extra = {}) => ({
  movimientoId: 'mv1', activoAgroId: 'a1', actividad: 'ganaderia',
  destinoActivoId: null, destinoDescripcion: 'Feedlot Los Aromos',
  carga: 'Novillos', cantidadDeclarada: 50, unidad: 'cabezas', cantidadRecibida: null,
  transportista: 'Transporte Pérez', patente: 'AB123CD', guia: 'DTe 12345',
  fechaSalida: new Date(), fechaEntrega: null, estado: 'programado',
  grupoId: null, observaciones: null, cargadoPor: uid, fechaCarga: new Date(),
  estadoDato: 'declarado', ...extra,
});

const cargarTraslado = (extra = {}) => cargar((db) =>
  setDoc(doc(db, 'movimientos/mv1'), trasladoDe(DUENO, extra)));

test('MOV-01. El dueño registra un traslado [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(DUENO), 'movimientos/mv1'), trasladoDe(DUENO)));
});

test('MOV-02. Otro usuario NO registra traslados en un campo ajeno [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(OTRO), 'movimientos/mv1'), trasladoDe(OTRO)));
});

test('MOV-03. El broker (quien cargó el expediente) NO ve ni carga traslados [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(BROKER), 'movimientos/mv1'), trasladoDe(BROKER)));
  await cargarTraslado();
  await assertFails(getDoc(doc(como(BROKER), 'movimientos/mv1')));
});

test('MOV-04. NO se registra a nombre de otro usuario [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'movimientos/mv1'), trasladoDe(ENCARGADO)));
});

test('MOV-05. NO se registra con actividad inventada, cantidad cero o sin destino [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'movimientos/mv1'), trasladoDe(DUENO, { actividad: 'astronautica' })));
  await assertFails(setDoc(doc(como(DUENO), 'movimientos/mv1'), trasladoDe(DUENO, { cantidadDeclarada: 0 })));
  await assertFails(setDoc(doc(como(DUENO), 'movimientos/mv1'), trasladoDe(DUENO, { destinoDescripcion: '' })));
});

test('MOV-06. NO se registra ya entregado ni como verificado [PROHIBIDO]', async () => {
  await assertFails(setDoc(doc(como(DUENO), 'movimientos/mv1'), trasladoDe(DUENO, { estado: 'entregado' })));
  await assertFails(setDoc(doc(como(DUENO), 'movimientos/mv1'), trasladoDe(DUENO, { estadoDato: 'verificado' })));
});

test('MOV-07. El dueño marca "en camino" y después "entregado" con lo recibido [PERMITIDO]', async () => {
  await cargarTraslado();
  await assertSucceeds(updateDoc(doc(como(DUENO), 'movimientos/mv1'),
    { estado: 'enCamino', actualizadoPor: DUENO, fechaActualizacion: new Date() }));
  await assertSucceeds(updateDoc(doc(como(DUENO), 'movimientos/mv1'),
    { estado: 'entregado', cantidadRecibida: 48, fechaEntrega: new Date(), actualizadoPor: DUENO, fechaActualizacion: new Date() }));
});

test('MOV-08. NO se cambia la cantidad declarada ni el destino [PROHIBIDO]', async () => {
  await cargarTraslado();
  await assertFails(updateDoc(doc(como(DUENO), 'movimientos/mv1'),
    { cantidadDeclarada: 10, actualizadoPor: DUENO }));
  await assertFails(updateDoc(doc(como(DUENO), 'movimientos/mv1'),
    { destinoDescripcion: 'Otro lugar', actualizadoPor: DUENO }));
});

test('MOV-09. Un traslado entregado o cancelado ya NO cambia [PROHIBIDO]', async () => {
  await cargarTraslado({ estado: 'entregado' });
  await assertFails(updateDoc(doc(como(DUENO), 'movimientos/mv1'),
    { estado: 'cancelado', actualizadoPor: DUENO, fechaActualizacion: new Date() }));
});

test('MOV-10. NO se anota una cantidad recibida negativa [PROHIBIDO]', async () => {
  await cargarTraslado();
  await assertFails(updateDoc(doc(como(DUENO), 'movimientos/mv1'),
    { estado: 'entregado', cantidadRecibida: -3, fechaEntrega: new Date(), actualizadoPor: DUENO, fechaActualizacion: new Date() }));
});

test('MOV-11. Un traslado NO se borra [PROHIBIDO]', async () => {
  await cargarTraslado();
  await assertFails(deleteDoc(doc(como(DUENO), 'movimientos/mv1')));
});

test('MOV-12. El dueño lista los traslados de su campo [PERMITIDO]', async () => {
  await cargarTraslado();
  const q = query(collection(como(DUENO), 'movimientos'), where('activoAgroId', '==', 'a1'));
  await assertSucceeds(getDocs(q));
});

test('MOV-13. Otro usuario NO lista los traslados del campo [PROHIBIDO]', async () => {
  await cargarTraslado();
  const q = query(collection(como(OTRO), 'movimientos'), where('activoAgroId', '==', 'a1'));
  await assertFails(getDocs(q));
});

test('MOV-14. El encargado con "crear movimientos" registra un traslado [PERMITIDO]', async () => {
  await darAutorizacion('crear', 'movimientos');
  await assertSucceeds(setDoc(doc(como(ENCARGADO), 'movimientos/mv1'), trasladoDe(ENCARGADO)));
});

test('MOV-15. Con permiso solo en producción, el encargado NO ve los traslados [PROHIBIDO]', async () => {
  await cargarTraslado();
  await darAutorizacion('ver', 'produccion');
  await assertFails(getDoc(doc(como(ENCARGADO), 'movimientos/mv1')));
});

test('MOV-16. El encargado con "modificar movimientos" marca entregado a su nombre [PERMITIDO]', async () => {
  await cargarTraslado();
  await darAutorizacion('modificar', 'movimientos');
  await assertSucceeds(updateDoc(doc(como(ENCARGADO), 'movimientos/mv1'),
    { estado: 'entregado', cantidadRecibida: 50, fechaEntrega: new Date(), actualizadoPor: ENCARGADO, fechaActualizacion: new Date() }));
});

// =====================================================================
// AGRO. AGRICULTURA (GAP-AGRO-01, 12/11/2026)
// Reutiliza grupos y eventos productivos: siembra y cosecha.
// =====================================================================

const cargarCultivo = () => cargar((db) =>
  setDoc(doc(db, 'grupos_productivos/cul1'), {
    grupoId: 'cul1', activoAgroId: 'a1', actividad: 'agricultura', nombre: 'Soja 2026/27',
    cultivo: 'soja', campania: '2026/27', estado: 'activo', creadoPor: DUENO, fechaCreacion: new Date(),
  }));

const eventoAgroDe = (extra = {}) => ({
  eventoId: 'ev_agro', activoAgroId: 'a1', grupoId: 'cul1', unidadId: 'lote3',
  tipo: 'siembra', fechaHecho: new Date(), fechaCarga: new Date(), cargadoPor: DUENO,
  estadoDato: 'declarado', superficieHa: 100, ...extra,
});

test('AGRO-01. El dueño crea un cultivo de la campaña [PERMITIDO]', async () => {
  await assertSucceeds(setDoc(doc(como(DUENO), 'grupos_productivos/cul1'), {
    grupoId: 'cul1', activoAgroId: 'a1', actividad: 'agricultura', nombre: 'Soja 2026/27',
    cultivo: 'soja', campania: '2026/27', estado: 'activo', creadoPor: DUENO, fechaCreacion: new Date(),
  }));
});

test('AGRO-02. El dueño registra una siembra [PERMITIDO]', async () => {
  await cargarCultivo();
  await assertSucceeds(setDoc(doc(como(DUENO), 'eventos_productivos/ev_agro'), eventoAgroDe()));
});

test('AGRO-03. El dueño registra una cosecha en toneladas [PERMITIDO]', async () => {
  await cargarCultivo();
  await assertSucceeds(setDoc(doc(como(DUENO), 'eventos_productivos/ev_agro'),
    eventoAgroDe({ tipo: 'cosecha', cantidadObtenida: 350.5, unidadMedida: 'tn', humedad: 13.5 })));
});

test('AGRO-04. NO se registran hectáreas en cero o negativas [PROHIBIDO]', async () => {
  await cargarCultivo();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_agro'), eventoAgroDe({ superficieHa: 0 })));
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_agro'), eventoAgroDe({ superficieHa: -5 })));
});

test('AGRO-05. NO se registra una cosecha negativa, unidad inventada o humedad imposible [PROHIBIDO]', async () => {
  await cargarCultivo();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_agro'),
    eventoAgroDe({ tipo: 'cosecha', cantidadObtenida: -1, unidadMedida: 'tn' })));
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_agro'),
    eventoAgroDe({ tipo: 'cosecha', cantidadObtenida: 10, unidadMedida: 'bolsones' })));
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_agro'),
    eventoAgroDe({ tipo: 'cosecha', cantidadObtenida: 10, unidadMedida: 'tn', humedad: 140 })));
});

test('AGRO-06. Otro usuario NO registra siembras en un campo ajeno [PROHIBIDO]', async () => {
  await cargarCultivo();
  await assertFails(setDoc(doc(como(OTRO), 'eventos_productivos/ev_agro'), eventoAgroDe({ cargadoPor: OTRO })));
});

test('AGRO-07. Una siembra NO se edita ni se borra [PROHIBIDO]', async () => {
  await cargarCultivo();
  await cargar((db) => setDoc(doc(db, 'eventos_productivos/ev_agro'), eventoAgroDe()));
  await assertFails(updateDoc(doc(como(DUENO), 'eventos_productivos/ev_agro'), { superficieHa: 200 }));
  await assertFails(deleteDoc(doc(como(DUENO), 'eventos_productivos/ev_agro')));
});

test('AGRO-08. El encargado con "crear producción" registra una cosecha [PERMITIDO]', async () => {
  await cargarCultivo();
  await darAutorizacion('crear', 'produccion');
  await assertSucceeds(setDoc(doc(como(ENCARGADO), 'eventos_productivos/ev_agro'),
    eventoAgroDe({ tipo: 'cosecha', cantidadObtenida: 300, unidadMedida: 'tn', cargadoPor: ENCARGADO })));
});

// =====================================================================
// MON. MONITOREO (GAP-MON-01, 13/11/2026)
// Un monitoreo es un evento productivo más: solo agregar.
// =====================================================================

const monitoreoDe = (extra = {}) => eventoAgroDe({
  eventoId: 'ev_mon', tipo: 'monitoreo', superficieHa: null,
  objetivoMonitoreo: 'plaga', nivel: 'alto', fuenteDato: 'recorrida',
  observaciones: 'Chinche verde en el borde del lote', ...extra,
});

test('MON-01. El dueño registra un monitoreo [PERMITIDO]', async () => {
  await cargarCultivo();
  await assertSucceeds(setDoc(doc(como(DUENO), 'eventos_productivos/ev_mon'), monitoreoDe()));
});

test('MON-02. NO se registra un monitoreo sin nivel, sin fuente o sin qué se miró [PROHIBIDO]', async () => {
  await cargarCultivo();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_mon'), monitoreoDe({ nivel: null })));
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_mon'), monitoreoDe({ fuenteDato: null })));
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_mon'), monitoreoDe({ objetivoMonitoreo: null })));
});

test('MON-03. NO se aceptan nivel, fuente u objetivo inventados [PROHIBIDO]', async () => {
  await cargarCultivo();
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_mon'), monitoreoDe({ nivel: 'gravisimo' })));
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_mon'), monitoreoDe({ fuenteDato: 'me dijeron' })));
  await assertFails(setDoc(doc(como(DUENO), 'eventos_productivos/ev_mon'), monitoreoDe({ objetivoMonitoreo: 'ovni' })));
});

test('MON-04. Otro usuario NO registra monitoreos en un campo ajeno [PROHIBIDO]', async () => {
  await cargarCultivo();
  await assertFails(setDoc(doc(como(OTRO), 'eventos_productivos/ev_mon'), monitoreoDe({ cargadoPor: OTRO })));
});

test('MON-05. Un monitoreo NO se edita ni se borra [PROHIBIDO]', async () => {
  await cargarCultivo();
  await cargar((db) => setDoc(doc(db, 'eventos_productivos/ev_mon'), monitoreoDe()));
  await assertFails(updateDoc(doc(como(DUENO), 'eventos_productivos/ev_mon'), { nivel: 'bajo' }));
  await assertFails(deleteDoc(doc(como(DUENO), 'eventos_productivos/ev_mon')));
});

test('MON-06. El encargado con "crear producción" registra un monitoreo [PERMITIDO]', async () => {
  await cargarCultivo();
  await darAutorizacion('crear', 'produccion');
  await assertSucceeds(setDoc(doc(como(ENCARGADO), 'eventos_productivos/ev_mon'),
    monitoreoDe({ cargadoPor: ENCARGADO, fuenteDato: 'dron' })));
});
