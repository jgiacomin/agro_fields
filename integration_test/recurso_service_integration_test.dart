import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/recurso_agro_model.dart';
import 'package:agro_fields/services/recurso_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late RecursoService recursoService;
  late String usuarioId;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAuth.instance.useAuthEmulator(
      '10.0.2.2',
      9099,
    );

    final credential =
        await FirebaseAuth.instance.signInAnonymously();

    final user = credential.user;

    if (user == null) {
      throw Exception(
        'No se pudo crear el usuario anónimo del test',
      );
    }

    usuarioId = user.uid;

    firestore = FirebaseFirestore.instance;

    firestore.useFirestoreEmulator(
      '10.0.2.2',
      8080,
    );

    recursoService = RecursoService();
  });

  testWidgets(
    'RecursoService crea, recupera, lista y audita un recurso',
    (tester) async {
     final sufijo =
    DateTime.now().millisecondsSinceEpoch.toString();

final activoAgroId =
    'activo-test-recurso-$sufijo';

await firestore
    .collection('activos_agro')
    .doc(activoAgroId)
    .set({
  'propietarioId': usuarioId,
  'publicadorId': usuarioId,
  'nombre': 'Activo Agro de prueba',
});

      final recurso = RecursoAgro(
        recursoId: '',
        activoAgroId: activoAgroId,
        tipo: 'maquinaria',
        nombre: 'Tractor de prueba',
        descripcion:
            'Tractor agrícola para prueba de integración',
        unidad: 'unidad',
        cantidadActual: 1,
        cantidadMinima: 0,
        estado: 'disponible',
        moduloProduccionId: 'produccion-test-001',
        numeroSerie: 'TRAC-TEST-$sufijo',
        observaciones:
            'Prueba de integración Firestore Emulator',
      );

      // 1. Crear recurso.
      final recursoId =
          await recursoService.crearRecurso(
        recurso: recurso,
        usuarioId: usuarioId,
        rol: 'productor',
      );

      expect(
        recursoId,
        isNotEmpty,
      );

      // 2. Verificar persistencia directa.
      final recursoSnapshot =
          await firestore
              .collection('recursos')
              .doc(recursoId)
              .get();

      expect(
        recursoSnapshot.exists,
        isTrue,
      );

      final recursoData =
          recursoSnapshot.data()!;

      expect(
        recursoData['activoAgroId'],
        equals(activoAgroId),
      );

      expect(
        recursoData['tipo'],
        equals('maquinaria'),
      );

      expect(
        recursoData['nombre'],
        equals('Tractor de prueba'),
      );

      // 3. Recuperar mediante Service.
      final recuperado =
          await recursoService.obtenerRecursoPorId(
        recursoId,
      );

      expect(
        recuperado,
        isNotNull,
      );

      expect(
        recuperado!.recursoId,
        equals(recursoId),
      );

      expect(
        recuperado.activoAgroId,
        equals(activoAgroId),
      );

      expect(
        recuperado.cantidadActual,
        equals(1),
      );

      expect(
        recuperado.estado,
        equals('disponible'),
      );

      // 4. Listar recursos del Activo.
      final recursosDelActivo =
          await recursoService.obtenerRecursosPorActivo(
        activoAgroId,
      );

      expect(
        recursosDelActivo,
        isNotEmpty,
      );

      expect(
        recursosDelActivo.any(
          (item) => item.recursoId == recursoId,
        ),
        isTrue,
      );

      // 5. Verificar auditoría.
      final auditoria =
          await firestore
              .collection('auditoria_activos')
              .where(
                'activoId',
                isEqualTo: activoAgroId,
              )
              .get();

      expect(
        auditoria.docs,
        isNotEmpty,
      );

      final eventoAuditoria =
          auditoria.docs.first.data();

      expect(
        eventoAuditoria['modulo'],
        equals('recursos_inventario'),
      );

      expect(
        eventoAuditoria['accion'],
        equals('crear_recurso'),
      );

      expect(
        eventoAuditoria['elementoAfectado'],
        equals(recursoId),
      );

      expect(
        eventoAuditoria['referencia'],
        equals(recursoId),
      );

      expect(
        eventoAuditoria['usuarioId'],
        equals(usuarioId),
      );
    },
  );
}