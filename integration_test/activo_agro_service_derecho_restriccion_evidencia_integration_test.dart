import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/derecho_activo_model.dart';
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
    'GAP-RWA-02 02.09 - vincula restricción de DerechoActivo con evidencia y auditoría',
    (tester) async {
      final firestore = FirebaseFirestore.instance;
      final evidenciaService = EvidenciaService();

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-rwa02-0209-$sufijo';

      final derechoId =
          'derecho-rwa02-0209-$sufijo';

      final usuarioId =
          'usuario-rwa02-0209-$sufijo';

      final fecha =
          DateTime(2026, 9, 16, 12, 0);

      // =====================================================
      // 1. REPRESENTAR DERECHO + CONDICIÓN/RESTRICCIÓN
      // =====================================================

      final derecho = DerechoActivo(
        derechoId: derechoId,
        activoAgroId: activoId,
        tipoDerecho: 'dominio',
        descripcionTipo: null,
        tipoObjeto: 'activo_completo',
        descripcionObjeto:
            'Derecho sobre activo agro de prueba.',
        alcanceTerritorial: null,
        tipoInstrumento: 'titulo',
        identificadorInstrumento:
            'TEST-RWA02-0209-$sufijo',
        emisor: 'Entidad de prueba',
        fechaInicio: fecha,
        fechaFin: null,
        estado: 'vigente',
        condiciones: const [
          'Uso condicionado a autorización ambiental vigente.',
        ],
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      expect(
        derecho.derechoId,
        derechoId,
      );

      expect(
        derecho.condiciones,
        contains(
          'Uso condicionado a autorización ambiental vigente.',
        ),
      );

      // =====================================================
      // 2. CREAR EVIDENCIA DE LA RESTRICCIÓN
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'derecho',
        elementoTipo: 'DerechoActivo',
        elementoId: derecho.derechoId,
        campoRelacionado: 'restricciones',
        tipo: 'documentacion_juridica',
        descripcion:
            'Evidencia documental de la restricción '
            'asociada al DerechoActivo.',
        observaciones:
            'Prueba funcional de GAP-RWA-02 02.09.',
        aportanteId: usuarioId,
        fuenteTipo: 'documento',
        fuenteNombre:
            'Documento jurídico de prueba',
        fuenteReferencia:
            'TEST-RWA02-0209-FUENTE-$sufijo',
        soporteTipo: 'documento',
        soporteReferencia:
            'TEST-RWA02-0209-SOPORTE-$sufijo',
        soporteNombre:
            'Documento de restricción de prueba',
        fechaHecho: fecha,
        fechaRegistro: fecha,
        estadoVerificacion: 'pendiente',
        estadoValidez: 'vigente_informado',
      );

      final evidenciaId =
          await evidenciaService.crearEvidencia(
        evidencia: evidencia,
        usuarioId: usuarioId,
      );

      expect(
        evidenciaId.isNotEmpty,
        true,
      );

      // =====================================================
      // 3. VERIFICAR PERSISTENCIA DE LA EVIDENCIA
      // =====================================================

      final evidenciaSnapshot = await firestore
          .collection('evidencias')
          .doc(evidenciaId)
          .get();

      expect(
        evidenciaSnapshot.exists,
        true,
      );

      final evidenciaData =
          evidenciaSnapshot.data()!;

      expect(
        evidenciaData['activoAgroId'],
        activoId,
      );

      expect(
        evidenciaData['moduloOrigen'],
        'derecho',
      );

      expect(
        evidenciaData['elementoTipo'],
        'DerechoActivo',
      );

      expect(
        evidenciaData['elementoId'],
        derechoId,
      );

      expect(
        evidenciaData['campoRelacionado'],
        'restricciones',
      );

      expect(
        evidenciaData['fuenteTipo'],
        'documento',
      );

      expect(
        evidenciaData['estadoVerificacion'],
        'pendiente',
      );

      expect(
        evidenciaData['estadoValidez'],
        'vigente_informado',
      );

      // =====================================================
      // 4. RECUPERAR POR SERVICIO
      // =====================================================

      final evidenciaRecuperada =
          await evidenciaService.obtenerPorId(
        evidenciaId,
      );

      expect(
        evidenciaRecuperada,
        isNotNull,
      );

      expect(
        evidenciaRecuperada!.elementoTipo,
        'DerechoActivo',
      );

      expect(
        evidenciaRecuperada.elementoId,
        derechoId,
      );

      expect(
        evidenciaRecuperada.campoRelacionado,
        'restricciones',
      );

      // =====================================================
      // 5. VERIFICAR AUDITORÍA
      // =====================================================

      final auditoriaSnapshot = await firestore
          .collection('auditoria_activos')
          .where(
            'activoId',
            isEqualTo: activoId,
          )
          .get();

      expect(
        auditoriaSnapshot.docs,
        isNotEmpty,
      );

      final auditorias =
          auditoriaSnapshot.docs.map(
        (doc) => doc.data(),
      );

      expect(
        auditorias.any(
          (data) =>
              data['modulo'] == 'evidencia' &&
              data['accion'] == 'crear_evidencia' &&
              data['elementoAfectado'] == evidenciaId &&
              data['referencia'] == evidenciaId,
        ),
        true,
      );
    },
  );
}
