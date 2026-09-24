import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/derecho_activo_model.dart';
import 'package:agro_fields/models/activos/evidencia_model.dart';
import 'package:agro_fields/services/activo_agro_service_v2.dart';
import 'package:agro_fields/models/activos/ubicacion_activo_model.dart';
import 'package:agro_fields/models/activos/economia_activo_model.dart';
import 'package:agro_fields/models/activos/documentacion_activo_model.dart';
import 'package:agro_fields/models/activos/confianza_activo_model.dart';
import 'package:agro_fields/models/activos/evaluacion_confianza_model.dart';
import 'package:agro_fields/models/activos/madurez_activo_model.dart';
import 'package:agro_fields/models/activos/suelo_activo_model.dart';
import 'package:agro_fields/models/activos/tipo_activo.dart';
import 'package:agro_fields/models/activos/estado_activo.dart';

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
    'GAP-RWA-02 02.10 - registra carga jurÃ­dica en ActivoAgroV2 con evidencia, historial y auditorÃ­a',
    (tester) async {
      final firestore = FirebaseFirestore.instance;

      final activoService = ActivoAgroServiceV2();


      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-rwa02-0210-$sufijo';

      final derechoId =
          'derecho-rwa02-0210-$sufijo';

      final usuarioId =
          'usuario-rwa02-0210-$sufijo';

      final fecha =
          DateTime(2026, 9, 18, 12, 0);

      // =====================================================
      // 1. CREAR ACTIVO AGRO DE PRUEBA
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre:
            'Activo de prueba GAP-RWA-02 02.10',
        descripcion:
            'Activo Agro utilizado para validar el registro de cargas jurÃ­dicas.',
        tipoActivo: TipoActivo.otro,
        categorias: const [],
        ubicacion: UbicacionActivo.fromMap(
          const {},
        ),
        producciones: const [],
        economia: EconomiaActivo.fromMap(
          const {},
        ),
        documentacion:
            DocumentacionActivo.fromMap(
          const {},
        ),
        confianza:
            ConfianzaActivo.fromMap(
          const {},
        ),
        evaluacion:
            EvaluacionConfianza.fromMap(
          const {},
        ),
        madurez:
            MadurezActivo.fromMap(
          const {},
        ),
        suelo:
            SueloActivo.fromMap(
          const {},
        ),
        participantes: const [],
        derechos: const [],
        relacionesJuridicas: const [],
        propietarioId: usuarioId,
        creadorId: usuarioId,
        publicadorId: usuarioId,
        tipoRelacionPropietario:
            'propietario',
        estado: EstadoActivo.borrador,
        estadoPublicacion: 'borrador',
        visible: false,
        historial: const [],
        hashActivo:
            'hash-rwa02-0210-$sufijo',
        versionDatos: 1,
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      final activoCreadoId =
          await activoService.crearActivo(
        activo,
      );

      expect(
        activoCreadoId,
        activoId,
      );

      // =====================================================
      // 2. REPRESENTAR CARGA JURÃDICA
      // =====================================================

      final carga = DerechoActivo(
        derechoId: derechoId,
        activoAgroId: activoId,
        tipoDerecho: 'hipoteca',
        descripcionTipo:
            'Carga hipotecaria de prueba.',
        tipoObjeto: 'activo_completo',
        descripcionObjeto:
            'Carga que afecta al Activo Agro completo.',
        alcanceTerritorial: null,
        tipoInstrumento: 'escritura',
        identificadorInstrumento:
            'TEST-RWA02-0210-$sufijo',
        emisor: 'Entidad financiera de prueba',
        fechaInicio: fecha,
        fechaFin: null,
        estado: 'vigente',
        condiciones: const [
          'Carga registrada para prueba funcional.',
        ],
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      expect(
        carga.derechoId,
        derechoId,
      );

      expect(
        carga.tipoDerecho,
        'hipoteca',
      );

      // =====================================================
      // 3. CREAR EVIDENCIA DE LA CARGA
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'derecho',
        elementoTipo: 'DerechoActivo',
        elementoId: derechoId,
        campoRelacionado: 'cargas',
        tipo: 'documentacion_juridica',
        descripcion:
            'Evidencia documental de la carga hipotecaria.',
        observaciones:
            'Prueba funcional de GAP-RWA-02 02.10.',
        aportanteId: usuarioId,
        fuenteTipo: 'documento',
        fuenteNombre:
            'Documento jurÃ­dico de prueba de carga',
        fuenteReferencia:
            'TEST-RWA02-0210-FUENTE-$sufijo',
        soporteTipo: 'documento',
        soporteReferencia:
            'TEST-RWA02-0210-SOPORTE-$sufijo',
        soporteNombre:
            'Documento de carga hipotecaria de prueba',
        fechaHecho: fecha,
        fechaRegistro: fecha,
        estadoVerificacion: 'pendiente',
        estadoValidez: 'vigente_informado',
      );



      // =====================================================
      // 4. REGISTRAR LA CARGA EN EL ACTIVO
      // =====================================================

      await activoService.registrarDerechoActivo(
        activoId,
        carga,
        evidencia: evidencia,
      );
 final evidenciaQuery = await firestore
    .collection('evidencias')
    .where(
      'activoAgroId',
      isEqualTo: activoId,
    )
    .where(
      'elementoId',
      isEqualTo: derechoId,
    )
    .get();

expect(
  evidenciaQuery.docs,
  isNotEmpty,
);

expect(
  evidenciaQuery.docs.length,
  1,
);

final evidenciaId =
    evidenciaQuery.docs.first.id;
      // =====================================================
      // 5. RECUPERAR ACTIVO DESDE FIRESTORE
      // =====================================================

      final activoRecuperado =
          await activoService.obtenerActivoPorId(
        activoId,
      );

      expect(
        activoRecuperado,
        isNotNull,
      );

      expect(
        activoRecuperado!.derechos.length,
        1,
      );

      final cargaRecuperada =
          activoRecuperado.derechos.first;

      expect(
        cargaRecuperada.derechoId,
        derechoId,
      );

      expect(
        cargaRecuperada.activoAgroId,
        activoId,
      );

      expect(
        cargaRecuperada.tipoDerecho,
        'hipoteca',
      );

      expect(
        cargaRecuperada.tipoObjeto,
        'activo_completo',
      );

      expect(
        cargaRecuperada.estado,
        'vigente',
      );

      // =====================================================
      // 6. VERIFICAR PERSISTENCIA DIRECTA
      // =====================================================

      final activoSnapshot = await firestore
          .collection('activos_agro')
          .doc(activoId)
          .get();

      expect(
        activoSnapshot.exists,
        true,
      );

      final activoData =
          activoSnapshot.data()!;

      final derechosData =
          List<dynamic>.from(
        activoData['derechos'] ?? [],
      );

      expect(
        derechosData.length,
        1,
      );

      final derechoData =
          Map<String, dynamic>.from(
        derechosData.first,
      );

      expect(
        derechoData['derechoId'],
        derechoId,
      );

      expect(
        derechoData['activoAgroId'],
        activoId,
      );

      expect(
        derechoData['tipoDerecho'],
        'hipoteca',
      );

      expect(
        derechoData['tipoObjeto'],
        'activo_completo',
      );

      // =====================================================
      // 7. VERIFICAR EVIDENCIA
      // =====================================================

      final evidenciaSnapshot =
          await firestore
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
        'cargas',
      );

      // =====================================================
      // 8. VERIFICAR HISTORIAL DEL ACTIVO
      // =====================================================

      expect(
        activoRecuperado.historial,
        isNotEmpty,
      );

      expect(
        activoRecuperado.historial.any(
          (evento) =>
              evento.tipoEvento ==
                  'registro_derecho_activo' &&
              evento.referenciaId ==
                  derechoId,
        ),
        true,
      );

      // =====================================================
      // 9. VERIFICAR AUDITORÃA DEL REGISTRO DE CARGA
      // =====================================================

      final auditoriaSnapshot =
          await firestore
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
              data['modulo'] == 'derecho' &&
              data['accion'] ==
                  'registrar_derecho_activo' &&
              data['elementoAfectado'] ==
                  derechoId &&
              data['referencia'] ==
                  activoId,
        ),
        true,
      );

      // =====================================================
      // 10. VERIFICAR EVIDENCIA EN LA AUDITORÃA
      // =====================================================

      expect(
        auditorias.any(
          (data) =>
              data['modulo'] == 'derecho' &&
              data['accion'] ==
                  'registrar_derecho_activo' &&
              data['datos'] != null &&
              data['datos']['evidenciaId'] ==
                  evidenciaId,
        ),
        true,
      );

      // =====================================================
      // 11. PRUEBA NEGATIVA:
      // DERECHO DE OTRO ACTIVO
      // =====================================================

      final derechoIncorrecto =
          DerechoActivo(
        derechoId:
            'derecho-rwa02-0210-invalid-$sufijo',
        activoAgroId:
            'otro-activo-$sufijo',
        tipoDerecho: 'hipoteca',
        descripcionTipo:
            'Carga incompatible de prueba.',
        tipoObjeto: 'activo_completo',
        descripcionObjeto:
            'No debe registrarse en este activo.',
        alcanceTerritorial: null,
        tipoInstrumento: 'escritura',
        identificadorInstrumento:
            'TEST-RWA02-0210-INVALID-$sufijo',
        emisor: 'Entidad de prueba',
        fechaInicio: fecha,
        fechaFin: null,
        estado: 'vigente',
        condiciones: const [],
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      expect(
        () async =>
            activoService.registrarDerechoActivo(
          activoId,
          derechoIncorrecto,
        ),
        throwsArgumentError,
      );
    },
  );
}
