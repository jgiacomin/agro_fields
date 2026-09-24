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
    'GAP-RWA-02 02.19 - vincula garantía de DerechoActivo con evidencia y auditoría',
    (tester) async {
      final firestore = FirebaseFirestore.instance;
      final evidenciaService = EvidenciaService();

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-rwa02-0219-$sufijo';

      final derechoId =
          'derecho-rwa02-0219-$sufijo';

      final usuarioId =
          'usuario-rwa02-0219-$sufijo';

      final fecha =
          DateTime(2026, 9, 21, 12, 0);

      // =====================================================
      // 1. REPRESENTAR DERECHO + GARANTÍA
      // =====================================================

      final derecho = DerechoActivo(
        derechoId: derechoId,
        activoAgroId: activoId,
        tipoDerecho: 'uso',
        descripcionTipo: 'Derecho de uso sujeto a garantía.',
        tipoObjeto: 'parte_activo',
        descripcionObjeto:
            'Derecho de uso sobre un sector del activo agro.',
        alcanceTerritorial: null,
        tipoInstrumento: 'contrato',
        identificadorInstrumento:
            'TEST-RWA02-0219-CONTRATO-$sufijo',
        emisor: 'Entidad contractual de prueba',
        fechaInicio: fecha,
        fechaFin: DateTime(2031, 9, 21, 12, 0),
        estado: 'vigente',
        condiciones: [
          'Garantía contractual: fianza de cumplimiento.',
          'Monto garantizado: USD 100000.',
          'Garantía vigente durante la vigencia del derecho.',
        ],
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      expect(
        derecho.condiciones,
        contains(
          'Garantía contractual: fianza de cumplimiento.',
        ),
      );

      expect(
        derecho.condiciones,
        contains(
          'Monto garantizado: USD 100000.',
        ),
      );

      expect(
        derecho.condiciones,
        contains(
          'Garantía vigente durante la vigencia del derecho.',
        ),
      );

      // =====================================================
      // 2. CREAR EVIDENCIA DE LA GARANTÍA
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'derecho',
        elementoTipo: 'DerechoActivo',
        elementoId: derecho.derechoId,
        campoRelacionado: 'garantia',
        tipo: 'documentacion_juridica',
        descripcion:
            'Evidencia documental de la garantía contractual '
            'asociada al DerechoActivo.',
        observaciones:
            'Prueba funcional de GAP-RWA-02 02.19.',
        aportanteId: usuarioId,
        fuenteTipo: 'documento',
        fuenteNombre:
            'Garantía contractual de prueba',
        fuenteReferencia:
            'TEST-RWA02-0219-FUENTE-$sufijo',
        soporteTipo: 'documento',
        soporteReferencia:
            'TEST-RWA02-0219-SOPORTE-$sufijo',
        soporteNombre:
            'Documento de garantía contractual',
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
        'garantia',
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
        'garantia',
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