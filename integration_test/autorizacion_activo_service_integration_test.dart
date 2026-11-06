import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/autorizacion_activo_model.dart';
import 'package:agro_fields/services/autorizacion_activo_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
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
  });

  testWidgets(
    'AUT persistencia - guarda y recupera autorizaciones de un Activo Agro',
    (tester) async {
      final service = AutorizacionActivoService();

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-aut-persistencia-$sufijo';

      // Activo mínimo: solo necesitamos que exista
      // y que el usuario autenticado sea su propietario.
    try {
  final ref = firestore
      .collection('activos_agro')
      .doc('aut_test');

  await ref.set({
    'propietarioId': usuarioId,
  });

  print('AUT DIAGNOSTICO: escritura simple OK');
} on FirebaseException catch (e) {
  print('AUT DIAGNOSTICO FIRESTORE');
  print('code: ${e.code}');
  print('message: ${e.message}');
  print('plugin: ${e.plugin}');
  rethrow;
}

      final fechaInicio =
          DateTime(2026, 10, 1, 10, 0);

      final fechaFin =
          DateTime(2026, 12, 31, 18, 0);

      final autorizacion = AutorizacionActivo(
        autorizacionId: '',
        activoId: activoId,
        usuarioAutorizado: usuarioId,
        quienOtorga: usuarioId,
        rol: RolAutorizacion.arrendatario,
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'modulo-produccion-01',
          descripcion: 'Módulo productivo autorizado.',
        ),
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estado: EstadoAutorizacion.activa,
        modalidadRepresentacion:
            ModalidadRepresentacion.noExclusiva,
        condiciones: const [
          'Solo información productiva autorizada.',
        ],
        puedeDelegar: false,
        fechaOtorgamiento: fechaInicio,
        motivo: 'Autorización de prueba AUT.',
      );

      // =====================================================
      // 1. GUARDAR AUTORIZACIÓN
      // =====================================================

      final autorizacionId =
          await service.guardar(autorizacion);

      expect(
        autorizacionId.isNotEmpty,
        isTrue,
      );

      // =====================================================
      // 2. VERIFICAR PERSISTENCIA DIRECTA EN FIRESTORE
      // =====================================================

      final snapshot = await firestore
          .collection('autorizaciones_activos')
          .doc(autorizacionId)
          .get();

      expect(
        snapshot.exists,
        isTrue,
      );

      final data = snapshot.data()!;

      expect(
        data['autorizacionId'],
        autorizacionId,
      );

      expect(
        data['activoId'],
        activoId,
      );

      expect(
        data['usuarioAutorizado'],
        usuarioId,
      );

      expect(
        data['quienOtorga'],
        usuarioId,
      );

      expect(
        data['rol'],
        'arrendatario',
      );

      expect(
        data['permiso'],
        'modificar',
      );

      expect(
        data['estado'],
        'activa',
      );

      final ambitoData =
          Map<String, dynamic>.from(
        data['ambito'] as Map,
      );

      expect(
        ambitoData['tipo'],
        'expedienteProductivo',
      );

      expect(
        ambitoData['referenciaId'],
        'modulo-produccion-01',
      );

      // =====================================================
      // 3. RECUPERAR POR ID
      // =====================================================

      final recuperada =
          await service.obtenerPorId(
        autorizacionId,
      );

      expect(
        recuperada,
        isNotNull,
      );

      expect(
        recuperada!.autorizacionId,
        autorizacionId,
      );

      expect(
        recuperada.activoId,
        activoId,
      );

      expect(
        recuperada.usuarioAutorizado,
        usuarioId,
      );

      expect(
        recuperada.quienOtorga,
        usuarioId,
      );

      expect(
        recuperada.permiso,
        PermisoAutorizacion.modificar,
      );

      expect(
        recuperada.estado,
        EstadoAutorizacion.activa,
      );

      expect(
        recuperada.ambito.tipo,
        TipoAmbitoAutorizacion.expedienteProductivo,
      );

      expect(
        recuperada.ambito.referenciaId,
        'modulo-produccion-01',
      );

      // =====================================================
      // 4. RECUPERAR POR ACTIVO
      // =====================================================

      final autorizaciones =
          await service.obtenerPorActivo(
        activoId,
      );

      expect(
        autorizaciones,
        hasLength(1),
      );

      expect(
        autorizaciones.first.autorizacionId,
        autorizacionId,
      );

      // =====================================================
      // 5. GUARDAR AUTORIZACIÓN GENERAL
      // =====================================================

      final autorizacionGeneral =
          autorizacion.copyWith(
        autorizacionId: '',
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
        ),
      );

      final autorizacionGeneralId =
          await service.guardar(
        autorizacionGeneral,
      );

      expect(
        autorizacionGeneralId.isNotEmpty,
        isTrue,
      );

      // =====================================================
      // 6. VERIFICAR REFERENCIA GENERAL NULL
      // =====================================================

      final generalSnapshot = await firestore
          .collection('autorizaciones_activos')
          .doc(autorizacionGeneralId)
          .get();

      expect(
        generalSnapshot.exists,
        isTrue,
      );

      final generalData =
          generalSnapshot.data()!;

      final generalAmbitoData =
          Map<String, dynamic>.from(
        generalData['ambito'] as Map,
      );

      expect(
        generalAmbitoData['tipo'],
        'expedienteProductivo',
      );

      expect(
        generalAmbitoData['referenciaId'],
        isNull,
      );

      // =====================================================
      // 7. RECUPERAR AMBAS AUTORIZACIONES
      // =====================================================

      final autorizacionesFinales =
          await service.obtenerPorActivo(
        activoId,
      );

      expect(
        autorizacionesFinales,
        hasLength(2),
      );
    },
  );
}