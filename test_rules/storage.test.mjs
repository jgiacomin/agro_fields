// =====================================================================
// PRUEBAS DE LAS REGLAS DE STORAGE (Agro Fields V8) - PASO 4b
// Se corren contra los emuladores de Firestore y Storage (juntos):
//   firebase emulators:start --only firestore,storage
// No tocan tu proyecto real.
// Cada prueba dice qué debe pasar: PERMITIDO o PROHIBIDO.
// =====================================================================
import { readFileSync } from 'node:fs';
import { test, before, after, beforeEach } from 'node:test';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import { doc, setDoc } from 'firebase/firestore';
import { ref, uploadBytes, getMetadata, deleteObject } from 'firebase/storage';

const DUENO = 'dueno';
const BROKER = 'broker';
const ENCARGADO = 'encargado';
const OTRO = 'otro';

const AYER = new Date(Date.now() - 24 * 60 * 60 * 1000);

const RUTA_DOC = 'activos/a1/privado/documentos/doc1/escritura.pdf';
const RUTA_PRIVADO_OTRO = 'activos/a1/privado/otros/nota.pdf';
const RUTA_PUBLICA = 'activos/a1/publico/foto.jpg';

const PDF = { contentType: 'application/pdf' };

// El emulador de Storage no siempre se vacía entre pruebas ni entre
// corridas. Las pruebas que SUBEN un archivo nuevo usan una carpeta con la
// hora de esta corrida, para no chocar con archivos viejos (no se puede
// pisar un archivo: ST-15 y ST-17).
const CORRIDA = Date.now();
const bytes = (n = 16) => new Uint8Array(n);

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-agro-rules',
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
    storage: {
      host: '127.0.0.1',
      port: 9199,
      rules: readFileSync(new URL('../storage.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.clearStorage();
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'activos_agro/a1'), {
      propietarioId: DUENO, publicadorId: BROKER, nombre: 'Campo de prueba',
    });
  });
});

const como = (uid) => env.authenticatedContext(uid).storage();
const sinSesion = () => env.unauthenticatedContext().storage();

const idAut = (permiso) => `a1__${ENCARGADO}__${permiso}__documentacion`;

const darAutorizacion = (permiso, extra = {}) =>
  env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'autorizaciones_activos', idAut(permiso)), {
      autorizacionId: idAut(permiso),
      activoId: 'a1',
      usuarioAutorizado: ENCARGADO,
      quienOtorga: DUENO,
      rol: 'encargado',
      permiso,
      ambito: { tipo: 'documentacion', referenciaId: null, descripcion: null },
      fechaInicio: AYER,
      fechaFin: null,
      estado: 'activa',
      condiciones: [],
      puedeDelegar: false,
      fechaOtorgamiento: AYER,
      ...extra,
    });
  });

const cargarArchivo = (ruta, meta = PDF) =>
  env.withSecurityRulesDisabled(async (ctx) => {
    await uploadBytes(ref(ctx.storage(), ruta), bytes(), meta);
  });

// ------------------------- DUEÑO Y TERCEROS -------------------------
// Las pruebas que SUBEN un archivo nuevo usan su propia carpeta, para no
// depender de lo que dejó la prueba anterior (no se puede pisar un archivo).
test('ST-01. El dueño sube un PDF a los documentos de su campo [PERMITIDO]', async () => {
  await assertSucceeds(uploadBytes(ref(como(DUENO), `activos/a1/privado/documentos/doc_dueno_${CORRIDA}/escritura.pdf`), bytes(), PDF));
});

test('ST-02. El dueño lee un documento de su campo [PERMITIDO]', async () => {
  await cargarArchivo(RUTA_DOC);
  await assertSucceeds(getMetadata(ref(como(DUENO), RUTA_DOC)));
});

test('ST-03. Un tercero NO lee un documento ajeno [PROHIBIDO]', async () => {
  await cargarArchivo(RUTA_DOC);
  await assertFails(getMetadata(ref(como(OTRO), RUTA_DOC)));
});

test('ST-04. Un tercero NO sube documentos a un campo ajeno [PROHIBIDO]', async () => {
  await assertFails(uploadBytes(ref(como(OTRO), RUTA_DOC), bytes(), PDF));
});

test('ST-05. Sin sesión no se lee nada [PROHIBIDO]', async () => {
  await cargarArchivo(RUTA_DOC);
  await assertFails(getMetadata(ref(sinSesion(), RUTA_DOC)));
});

// ------------------------- AUTORIZACIONES (documentacion) -------------------------
test('ST-06. El encargado con "crear documentacion" sube un documento [PERMITIDO]', async () => {
  await darAutorizacion('crear');
  await assertSucceeds(uploadBytes(ref(como(ENCARGADO), `activos/a1/privado/documentos/doc_encargado_${CORRIDA}/escritura.pdf`), bytes(), PDF));
});

test('ST-07. El encargado con "ver documentacion" lee un documento [PERMITIDO]', async () => {
  await darAutorizacion('ver');
  await cargarArchivo(RUTA_DOC);
  await assertSucceeds(getMetadata(ref(como(ENCARGADO), RUTA_DOC)));
});

test('ST-08. El permiso "ver" NO alcanza para subir [PROHIBIDO]', async () => {
  await darAutorizacion('ver');
  await assertFails(uploadBytes(ref(como(ENCARGADO), RUTA_DOC), bytes(), PDF));
});

test('ST-09. Una autorización revocada NO sirve [PROHIBIDO]', async () => {
  await darAutorizacion('ver', { estado: 'revocada' });
  await cargarArchivo(RUTA_DOC);
  await assertFails(getMetadata(ref(como(ENCARGADO), RUTA_DOC)));
});

test('ST-10. Una autorización vencida NO sirve [PROHIBIDO]', async () => {
  await darAutorizacion('ver', { fechaFin: new Date(Date.now() - 60 * 60 * 1000) });
  await cargarArchivo(RUTA_DOC);
  await assertFails(getMetadata(ref(como(ENCARGADO), RUTA_DOC)));
});

test('ST-11. Con permiso de documentos, el encargado NO lee otra parte de la carpeta privada [PROHIBIDO]', async () => {
  await darAutorizacion('ver');
  await cargarArchivo(RUTA_PRIVADO_OTRO);
  await assertFails(getMetadata(ref(como(ENCARGADO), RUTA_PRIVADO_OTRO)));
});

// ------------------------- TIPO, TAMAÑO Y BORRADO -------------------------
test('ST-12. NO se sube un archivo que no es PDF ni imagen [PROHIBIDO]', async () => {
  await assertFails(uploadBytes(ref(como(DUENO), 'activos/a1/privado/documentos/doc1/nota.txt'),
    bytes(), { contentType: 'text/plain' }));
});

test('ST-13. NO se sube un archivo de 20 MB o más [PROHIBIDO]', async () => {
  await assertFails(uploadBytes(ref(como(DUENO), RUTA_DOC), bytes(20 * 1024 * 1024), PDF));
});

test('ST-14. El dueño NO borra un documento desde la app [PROHIBIDO]', async () => {
  await cargarArchivo(RUTA_DOC);
  await assertFails(deleteObject(ref(como(DUENO), RUTA_DOC)));
});

test('ST-15. El encargado NO reemplaza un documento ya subido [PROHIBIDO]', async () => {
  await darAutorizacion('crear');
  await cargarArchivo(RUTA_DOC);
  await assertFails(uploadBytes(ref(como(ENCARGADO), RUTA_DOC), bytes(), PDF));
});

// ------------------------- RESUMEN PÚBLICO (sin cambios) -------------------------
test('ST-16. Un usuario logueado ve una foto del resumen público [PERMITIDO]', async () => {
  await cargarArchivo(RUTA_PUBLICA, { contentType: 'image/jpeg' });
  await assertSucceeds(getMetadata(ref(como(OTRO), RUTA_PUBLICA)));
});

test('ST-17. El dueño tampoco reemplaza un documento ya subido [PROHIBIDO]', async () => {
  await cargarArchivo(RUTA_DOC);
  await assertFails(uploadBytes(ref(como(DUENO), RUTA_DOC), bytes(), PDF));
});
