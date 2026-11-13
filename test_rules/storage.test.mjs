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

// ------------------------- OPERACIONES PROTEGIDAS (PASO 7a-3) -------------------------
// Carpeta propia: activos/{activo}/operaciones/{operacion}/...
// Solo el dueño o quien tenga permiso en el ámbito "operaciones". El broker NO.
const RUTA_CHEQUE = 'activos/a1/operaciones/op1/cheque.jpg';
const JPG = { contentType: 'image/jpeg' };

const idAutOper = (permiso, ambito) => `a1__${ENCARGADO}__${permiso}__${ambito}`;

const darAutorizacionEn = (permiso, ambito) =>
  env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'autorizaciones_activos', idAutOper(permiso, ambito)), {
      autorizacionId: idAutOper(permiso, ambito),
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
    });
  });

test('ST-18. El dueño sube la foto de un cheque a su operación [PERMITIDO]', async () => {
  await assertSucceeds(uploadBytes(ref(como(DUENO), `activos/a1/operaciones/op_${CORRIDA}/cheque.jpg`), bytes(), JPG));
});

test('ST-19. Quien cargó el expediente (broker) NO ve archivos de operaciones [PROHIBIDO]', async () => {
  await cargarArchivo(RUTA_CHEQUE, JPG);
  await assertFails(getMetadata(ref(como(BROKER), RUTA_CHEQUE)));
});

test('ST-20. El broker NO sube archivos a operaciones [PROHIBIDO]', async () => {
  await assertFails(uploadBytes(ref(como(BROKER), `activos/a1/operaciones/op_broker_${CORRIDA}/cheque.jpg`), bytes(), JPG));
});

test('ST-21. El encargado con "crear operaciones" sube un archivo [PERMITIDO]', async () => {
  await darAutorizacionEn('crear', 'operaciones');
  await assertSucceeds(uploadBytes(ref(como(ENCARGADO), `activos/a1/operaciones/op_enc_${CORRIDA}/contrato.pdf`), bytes(), PDF));
});

test('ST-22. Con permiso solo en documentos, el encargado NO ve operaciones [PROHIBIDO]', async () => {
  await darAutorizacionEn('ver', 'documentacion');
  await cargarArchivo(RUTA_CHEQUE, JPG);
  await assertFails(getMetadata(ref(como(ENCARGADO), RUTA_CHEQUE)));
});

test('ST-23. El dueño NO borra la foto de un cheque [PROHIBIDO]', async () => {
  await cargarArchivo(RUTA_CHEQUE, JPG);
  await assertFails(deleteObject(ref(como(DUENO), RUTA_CHEQUE)));
});

// =====================================================================
// GASTOS (GAP-ECO-01, 13/11/2026): comprobantes. Dueño o ámbito
// "economia"; el broker que cargó el expediente no entra.
// =====================================================================

const rutaComprobante = (n) => `activos/a1/gastos/g_${CORRIDA}_${n}/ticket.pdf`;

test('ST-ECO-01. El dueño sube el comprobante de un gasto [PERMITIDO]', async () => {
  await assertSucceeds(uploadBytes(ref(como(DUENO), rutaComprobante(1)), bytes(), PDF));
});

test('ST-ECO-02. El broker NO sube comprobantes de gastos [PROHIBIDO]', async () => {
  await assertFails(uploadBytes(ref(como(BROKER), rutaComprobante(2)), bytes(), PDF));
});

test('ST-ECO-03. Otro usuario NO sube comprobantes de gastos [PROHIBIDO]', async () => {
  await assertFails(uploadBytes(ref(como(OTRO), rutaComprobante(3)), bytes(), PDF));
});
