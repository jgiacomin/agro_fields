import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/derecho_activo_model.dart';
import 'package:agro_fields/models/activos/evidencia_model.dart';
import 'package:agro_fields/models/activos/tipo_activo.dart';
import 'package:agro_fields/models/activos/ubicacion_activo_model.dart';
import 'package:agro_fields/models/activos/suelo_activo_model.dart';
import 'package:agro_fields/models/activos/economia_activo_model.dart';
import 'package:agro_fields/models/activos/documentacion_activo_model.dart';
import 'package:agro_fields/models/activos/confianza_activo_model.dart';
import 'package:agro_fields/models/activos/evaluacion_confianza_model.dart';
import 'package:agro_fields/models/activos/madurez_activo_model.dart';
import 'package:agro_fields/models/activos/estado_activo.dart';
import 'package:agro_fields/services/activo_agro_service_v2.dart';

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
    'GAP-RWA-02 02.18 - contraprestacion vinculada a DerechoActivo con evidencia, historial y auditoria',
    (tester) async {
      final firestore = FirebaseFirestore.instance;
      final activoService = ActivoAgroServiceV2();

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-rwa02-0218-$sufijo';

      final derechoId =
          'derecho-rwa02-0218-$sufijo';

      final usuarioId =
          'usuario-rwa02-0218-$sufijo';

      final fecha =
          DateTime(2026, 9, 21, 10, 0);

      // =====================================================
      // 1. CREAR ACTIVO BASE
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre:
            'Activo de prueba para Contraprestacion',
        descripcion:
            'Activo tecnico para validar GAP-RWA-02 02.18.',
        tipoActivo: TipoActivo.agricola,
        categorias: ['agricultura'],
        ubicacion: UbicacionActivo(
          pais: 'Argentina',
          provincia: 'Buenos Aires',
          departamento: 'La Plata',
          localidad: 'La Plata',
          codigoPostal: '1900',
          latitud: 0,
          longitud: 0,
          superficie: 100,
          regionProductiva: 'agricola',
          tipoZona: 'rural',
          descripcionEntorno: 'Prueba tecnica',
          accesoCaminos: 'camino rural',
          disponibilidadServicios: '',
          jurisdiccionLegal: 'Argentina',
          zonaHoraria:
              'America/Argentina/Buenos_Aires',
          monedaLocal: 'ARS',
        ),
        suelo: SueloActivo.inicial(),
        derechos: [],
        producciones: [],
        economia: EconomiaActivo.inicial(),
        documentacion: DocumentacionActivo.inicial(),
        confianza: ConfianzaActivo(
          nivelGeneral: 0,
          identidadVerificada: false,
          documentacionCompleta: false,
          nivelDocumentacion: 0,
          cantidadEvidencias: 0,
          nivelEvidencias: 0,
          informacionProductivaCompleta: false,
          nivelProduccion: 0,
          nivelInfraestructura: 0,
          infraestructuraVerificada: false,
          cantidadInfraestructuras: 0,
          cantidadTecnologias: 0,
          nivelTecnologia: 0,
          tecnologiaVerificada: false,
          nivelInversion: 0,
          inversionDeclarada: false,
          inversionVerificada: false,
          montoInversionDeclarada: 0,
          monedaInversion: 'USD',
          participantesVerificados: false,
          nivelGobernanza: 0,
          ultimaVerificacion: fecha,
          ultimaEvaluacion: fecha,
          observaciones: '',
        ),
        evaluacion:
            EvaluacionConfianza.inicial(),
        madurez: MadurezActivo(
          porcentaje: 0,
          faltantes: [],
          etapa: '',
          nivelTecnologico: '',
          preparacionInversion: '',
        ),
        participantes: [],
        propietarioId: usuarioId,
        creadorId: usuarioId,
        publicadorId: usuarioId,
        tipoRelacionPropietario: 'propietario',
        estado: EstadoActivo.borrador,
        estadoPublicacion: 'borrador',
        visible: false,
        historial: [],
        hashActivo:
            'hash-rwa02-0218-$sufijo',
        versionDatos: 1,
        datos: null,
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      await activoService.crearActivo(activo);

      // =====================================================
      // 2. REPRESENTAR DERECHO CON CONTRAPRESTACION
      // =====================================================

      final derecho = DerechoActivo(
        derechoId: derechoId,
        activoAgroId: activoId,
        tipoDerecho: 'uso',
        descripcionTipo: 'Derecho de uso',
        tipoObjeto: 'parte_activo',
        descripcionObjeto:
            'Derecho de uso sujeto a contraprestacion economica.',
        alcanceTerritorial: null,
        tipoInstrumento: 'contrato',
        identificadorInstrumento:
            'TEST-RWA02-0218-CONTRATO-$sufijo',
        emisor: 'Entidad contractual de prueba',
        fechaInicio: fecha,
        fechaFin:
            DateTime(2031, 9, 21, 10, 0),
        estado: 'vigente',
        condiciones: [
          'Canon anual: USD 50000.',
          'Contraprestacion exigible durante la vigencia del derecho.',
        ],
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      expect(derecho.derechoId, derechoId);
      expect(derecho.activoAgroId, activoId);
      expect(
        derecho.condiciones,
        contains('Canon anual: USD 50000.'),
      );

      // =====================================================
      // 3. CREAR EVIDENCIA ESPECIFICA
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'derecho',
        elementoTipo: 'DerechoActivo',
        elementoId: derechoId,
        campoRelacionado: 'contraprestacion',
        tipo: 'documentacion_juridica',
        descripcion:
            'Evidencia documental de la contraprestacion economica asociada al DerechoActivo.',
        observaciones:
            'Canon anual de USD 50000 utilizado para validar 02.18.',
        aportanteId: usuarioId,
        fuenteTipo: 'documento',
        fuenteNombre:
            'Contrato con contraprestacion de prueba',
        fuenteReferencia:
            'TEST-RWA02-0218-FUENTE-$sufijo',
        soporteTipo: 'documento',
        soporteReferencia:
            'TEST-RWA02-0218-SOPORTE-$sufijo',
        soporteNombre:
            'Contrato contraprestacion test',
        fechaHecho: fecha,
        fechaRegistro: fecha,
        estadoVerificacion: 'pendiente',
        estadoValidez: 'vigente_informado',
      );

      // =====================================================
      // 4. REGISTRAR DERECHO + EVIDENCIA MEDIANTE SERVICE
      // =====================================================

      await activoService.registrarDerechoActivo(
        activoId,
        derecho,
        evidencia: evidencia,
      );

      // =====================================================
      // 5. VERIFICAR DERECHO PERSISTIDO
      // =====================================================

      final activoSnapshot = await firestore
          .collection('activos_agro')
          .doc(activoId)
          .get();

      expect(
        activoSnapshot.exists,
        isTrue,
      );

      final activoData =
          activoSnapshot.data()!;

      final derechosFirestore =
          List<Map<String, dynamic>>.from(
        (activoData['derechos'] ?? []).map(
          (e) => Map<String, dynamic>.from(e),
        ),
      );

      expect(
        derechosFirestore,
        hasLength(1),
      );

      final derechoFirestore =
          derechosFirestore.first;

      expect(
        derechoFirestore['derechoId'],
        derechoId,
      );

      expect(
        derechoFirestore['tipoDerecho'],
        'uso',
      );

      expect(
        derechoFirestore['tipoInstrumento'],
        'contrato',
      );

      expect(
        derechoFirestore['identificadorInstrumento'],
        'TEST-RWA02-0218-CONTRATO-$sufijo',
      );

      expect(
        derechoFirestore['estado'],
        'vigente',
      );

      final condicionesFirestore =
          List<String>.from(
        derechoFirestore['condiciones'] ?? const [],
      );

      expect(
        condicionesFirestore,
        contains('Canon anual: USD 50000.'),
      );

      expect(
        condicionesFirestore,
        contains(
          'Contraprestacion exigible durante la vigencia del derecho.',
        ),
      );

      // =====================================================
      // 6. VERIFICAR EVIDENCIA
      // =====================================================

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
        hasLength(1),
      );

      final evidenciaData =
          evidenciaQuery.docs.first.data();

      expect(
        evidenciaData['elementoTipo'],
        'DerechoActivo',
      );

      expect(
        evidenciaData['campoRelacionado'],
        'contraprestacion',
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
      // 7. VERIFICAR HISTORIAL
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
        activoRecuperado!.derechos,
        hasLength(1),
      );

      expect(
        activoRecuperado.derechos.first.derechoId,
        derechoId,
      );

      expect(
        activoRecuperado.derechos.first.condiciones,
        contains('Canon anual: USD 50000.'),
      );

      expect(
        activoRecuperado.historial.any(
          (evento) =>
              evento.tipoEvento ==
                  'registro_derecho_activo' &&
              evento.referenciaId ==
                  derechoId &&
              evento.entidadRelacionada ==
                  'DerechoActivo',
        ),
        isTrue,
      );

      // =====================================================
      // 8. VERIFICAR AUDITORIA
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
              data['modulo'] == 'derecho' &&
              data['accion'] ==
                  'registrar_derecho_activo' &&
              data['elementoAfectado'] ==
                  derechoId &&
              data['referencia'] ==
                  activoId &&
              data['estadoNuevo'] ==
                  'vigente',
        ),
        isTrue,
      );
    },
  );
}
