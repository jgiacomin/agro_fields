import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/firebase_options.dart';

import 'package:agro_fields/models/activos/evidencia_model.dart';
import 'package:agro_fields/services/evidencia_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.useFirestoreEmulator(
      '10.0.2.2',
      8080,
    );
  });

  testWidgets(
    'Paso 12.10 - registra y recupera evidencia con auditoría',
    (tester) async {
      final firestore = FirebaseFirestore.instance;
      final evidenciaService = EvidenciaService();

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-evidencia-test-$sufijo';

      final usuarioId =
          'usuario-evidencia-test-$sufijo';

      final fechaHecho =
          DateTime(2026, 9, 8, 10, 0);

      final fechaRegistro =
          DateTime(2026, 9, 8, 10, 30);

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'suelo',
        elementoTipo: 'ActivoAgroV2',
        elementoId: activoId,
        campoRelacionado: 'ph',
        tipo: 'medicion',
        descripcion: 'Medición de pH realizada para integración.',
        observaciones: 'Evidencia creada para prueba.',
        aportanteId: usuarioId,
        fuenteTipo: 'profesional',
        fuenteNombre: 'Profesional de prueba',
        fuenteReferencia: 'referencia-test-$sufijo',
        soporteTipo: 'registro',
        soporteReferencia: 'soporte-test-$sufijo',
        soporteNombre: 'Registro de medición',
        fechaHecho: fechaHecho,
        fechaRegistro: fechaRegistro,
        estadoVerificacion: 'pendiente',
        estadoValidez: 'vigente_informado',
      );

      final evidenciaId =
          await evidenciaService.crearEvidencia(
        evidencia: evidencia,
        usuarioId: usuarioId,
      );

      expect(evidenciaId.isNotEmpty, true);

      // 1. Verificar que la evidencia quedó persistida.
      final evidenciaSnapshot = await firestore
          .collection('evidencias')
          .doc(evidenciaId)
          .get();

      expect(evidenciaSnapshot.exists, true);

      final evidenciaData =
          evidenciaSnapshot.data()!;

      expect(
        evidenciaData['evidenciaId'],
        evidenciaId,
      );

      expect(
        evidenciaData['activoAgroId'],
        activoId,
      );

      expect(
        evidenciaData['moduloOrigen'],
        'suelo',
      );

      expect(
        evidenciaData['campoRelacionado'],
        'ph',
      );

      expect(
        evidenciaData['estadoVerificacion'],
        'pendiente',
      );

      expect(
        evidenciaData['estadoValidez'],
        'vigente_informado',
      );

      // 2. Recuperar la evidencia por ID mediante el servicio.
      final evidenciaRecuperada =
          await evidenciaService.obtenerPorId(
        evidenciaId,
      );

      expect(evidenciaRecuperada, isNotNull);

      expect(
        evidenciaRecuperada!.evidenciaId,
        evidenciaId,
      );

      expect(
        evidenciaRecuperada.activoAgroId,
        activoId,
      );

      expect(
        evidenciaRecuperada.moduloOrigen,
        'suelo',
      );

      expect(
        evidenciaRecuperada.campoRelacionado,
        'ph',
      );

      // 3. Recuperar evidencias por ActivoAgro.
      final evidenciasDelActivo =
          await evidenciaService.obtenerPorActivo(
        activoId,
      );

      expect(
        evidenciasDelActivo.length,
        1,
      );

      expect(
        evidenciasDelActivo.first.evidenciaId,
        evidenciaId,
      );

      // 4. Verificar que la creación generó auditoría.
      final auditoriaSnapshot = await firestore
          .collection('auditoria_activos')
          .where(
            'activoId',
            isEqualTo: activoId,
          )
          .get();

      expect(
        auditoriaSnapshot.docs.length,
        1,
      );

      final auditoriaData =
          auditoriaSnapshot.docs.first.data();

      expect(
        auditoriaData['activoId'],
        activoId,
      );

      expect(
        auditoriaData['usuarioId'],
        usuarioId,
      );

      expect(
        auditoriaData['modulo'],
        'evidencia',
      );

      expect(
        auditoriaData['accion'],
        'crear_evidencia',
      );

      expect(
        auditoriaData['elementoAfectado'],
        evidenciaId,
      );

      expect(
        auditoriaData['referencia'],
        evidenciaId,
      );
    },
  );
}
