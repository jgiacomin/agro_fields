import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/derecho_activo_model.dart';
import 'package:agro_fields/models/activos/evidencia_model.dart';
import 'package:agro_fields/models/activos/relacion_juridica_model.dart';
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
    'GAP-RWA-02 02.11 - registra obligaciÃ³n mediante relaciÃ³n jurÃ­dica con condiciones, evidencia, historial y auditorÃ­a',
    (tester) async {
      final firestore = FirebaseFirestore.instance;

      final activoService = ActivoAgroServiceV2();

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-rwa02-0211-$sufijo';

      final derechoId =
          'derecho-rwa02-0211-$sufijo';

      final relacionId =
          'relacion-rwa02-0211-$sufijo';

      final usuarioId =
          'usuario-rwa02-0211-$sufijo';

      final fecha =
          DateTime(2026, 9, 18, 12, 0);

      // =====================================================
      // 1. CREAR ACTIVO AGRO DE PRUEBA
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre:
            'Activo de prueba GAP-RWA-02 02.11',
        descripcion:
            'Activo Agro utilizado para validar obligaciones jurÃ­dicas.',
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
            'hash-rwa02-0211-$sufijo',
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
      // 2. CREAR DERECHO JURÃDICO BASE
      // =====================================================

      final derecho = DerechoActivo(
        derechoId: derechoId,
        activoAgroId: activoId,
        tipoDerecho: 'servidumbre',
        descripcionTipo:
            'Derecho jurÃ­dico utilizado como base de una obligaciÃ³n.',
        tipoObjeto: 'activo_completo',
        descripcionObjeto:
            'Derecho asociado al Activo Agro completo.',
        alcanceTerritorial: null,
        tipoInstrumento: 'escritura',
        identificadorInstrumento:
            'TEST-RWA02-0211-$sufijo',
        emisor: 'Entidad jurÃ­dica de prueba',
        fechaInicio: fecha,
        fechaFin: null,
        estado: 'vigente',
        condiciones: const [],
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      // =====================================================
      // 3. REGISTRAR DERECHO BASE
      // =====================================================

      await activoService.registrarDerechoActivo(
        activoId,
        derecho,
      );

      // =====================================================
      // 4. REPRESENTAR OBLIGACIÃ“N MEDIANTE RELACIÃ“N JURÃDICA
      // =====================================================

      final relacion = RelacionJuridica(
        relacionId: relacionId,
        derechoId: derechoId,
        sujetoId: usuarioId,
        tipoSujeto: 'persona',
        rol: 'obligado',
        fechaInicio: fecha,
        fechaFin: null,
        estado: 'vigente',
        condiciones: const [
          'Mantener vigente la obligaciÃ³n jurÃ­dica.',
          'Cumplir las condiciones establecidas en el instrumento.',
        ],
      );

      expect(
        relacion.relacionId,
        relacionId,
      );

      expect(
        relacion.derechoId,
        derechoId,
      );

      expect(
        relacion.rol,
        'obligado',
      );

      expect(
        relacion.condiciones,
        isNotEmpty,
      );

      // =====================================================
      // 5. CREAR EVIDENCIA DE LA OBLIGACIÃ“N
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'derecho',
        elementoTipo: 'RelacionJuridica',
        elementoId: relacionId,
        campoRelacionado: 'obligaciones',
        tipo: 'documentacion_juridica',
        descripcion:
            'Evidencia documental de la obligaciÃ³n jurÃ­dica.',
        observaciones:
            'Prueba funcional de GAP-RWA-02 02.11.',
        aportanteId: usuarioId,
        fuenteTipo: 'documento',
        fuenteNombre:
            'Documento jurÃ­dico de obligaciÃ³n de prueba',
        fuenteReferencia:
            'TEST-RWA02-0211-FUENTE-$sufijo',
        soporteTipo: 'documento',
        soporteReferencia:
            'TEST-RWA02-0211-SOPORTE-$sufijo',
        soporteNombre:
            'Documento de obligaciÃ³n jurÃ­dica de prueba',
        fechaHecho: fecha,
        fechaRegistro: fecha,
        estadoVerificacion: 'pendiente',
        estadoValidez: 'vigente_informado',
      );

      // =====================================================
      // 6. REGISTRAR RELACIÃ“N JURÃDICA / OBLIGACIÃ“N
      // =====================================================

      await activoService.registrarRelacionJuridica(
        activoId,
        relacion,
        evidencia: evidencia,
      );

      // =====================================================
      // 7. RECUPERAR EVIDENCIA GENERADA
      // =====================================================

      final evidenciaQuery = await firestore
          .collection('evidencias')
          .where(
            'activoAgroId',
            isEqualTo: activoId,
          )
          .where(
            'elementoId',
            isEqualTo: relacionId,
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
      // 8. RECUPERAR ACTIVO DESDE FIRESTORE
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
        activoRecuperado!.relacionesJuridicas.length,
        1,
      );

      final relacionRecuperada =
          activoRecuperado.relacionesJuridicas.first;

      expect(
        relacionRecuperada.relacionId,
        relacionId,
      );

      expect(
        relacionRecuperada.derechoId,
        derechoId,
      );

      expect(
        relacionRecuperada.sujetoId,
        usuarioId,
      );

      expect(
        relacionRecuperada.rol,
        'obligado',
      );

      expect(
        relacionRecuperada.estado,
        'vigente',
      );

      expect(
        relacionRecuperada.condiciones.length,
        2,
      );

      // =====================================================
      // 9. VERIFICAR PERSISTENCIA DIRECTA
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

      final relacionesData =
          List<dynamic>.from(
        activoData['relacionesJuridicas'] ?? [],
      );

      expect(
        relacionesData.length,
        1,
      );

      final relacionData =
          Map<String, dynamic>.from(
        relacionesData.first,
      );

      expect(
        relacionData['relacionId'],
        relacionId,
      );

      expect(
        relacionData['derechoId'],
        derechoId,
      );

      expect(
        relacionData['sujetoId'],
        usuarioId,
      );

      expect(
        relacionData['rol'],
        'obligado',
      );

      expect(
        relacionData['estado'],
        'vigente',
      );

      expect(
        List<dynamic>.from(
          relacionData['condiciones'] ?? [],
        ).length,
        2,
      );

      // =====================================================
      // 10. VERIFICAR EVIDENCIA
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
        'RelacionJuridica',
      );

      expect(
        evidenciaData['elementoId'],
        relacionId,
      );

      expect(
        evidenciaData['campoRelacionado'],
        'obligaciones',
      );

      // =====================================================
      // 11. VERIFICAR HISTORIAL
      // =====================================================

      expect(
        activoRecuperado.historial,
        isNotEmpty,
      );

      expect(
        activoRecuperado.historial.any(
          (evento) =>
              evento.tipoEvento ==
                  'registro_relacion_juridica' &&
              evento.referenciaId ==
                  relacionId,
        ),
        true,
      );

      // =====================================================
      // 12. VERIFICAR AUDITORÃA
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
                  'registrar_relacion_juridica' &&
              data['elementoAfectado'] ==
                  relacionId &&
              data['referencia'] ==
                  activoId,
        ),
        true,
      );

      // =====================================================
      // 13. VERIFICAR EVIDENCIA EN AUDITORÃA
      // =====================================================

      expect(
        auditorias.any(
          (data) =>
              data['modulo'] == 'derecho' &&
              data['accion'] ==
                  'registrar_relacion_juridica' &&
              data['datos'] != null &&
              data['datos']['evidenciaId'] ==
                  evidenciaId,
        ),
        true,
      );

      // =====================================================
      // 14. PRUEBA NEGATIVA:
      // DERECHO INEXISTENTE
      // =====================================================

      final relacionIncorrecta =
          RelacionJuridica(
        relacionId:
            'relacion-rwa02-0211-invalid-$sufijo',
        derechoId:
            'derecho-inexistente-$sufijo',
        sujetoId:
            usuarioId,
        tipoSujeto: 'persona',
        rol: 'obligado',
        fechaInicio: fecha,
        fechaFin: null,
        estado: 'vigente',
        condiciones: const [
          'No debe registrarse.',
        ],
      );

      expect(
        () async =>
            activoService.registrarRelacionJuridica(
          activoId,
          relacionIncorrecta,
        ),
        throwsArgumentError,
      );
    },
  );
}
