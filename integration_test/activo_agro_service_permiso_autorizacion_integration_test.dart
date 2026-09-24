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
    'GAP-RWA-02 02.14 - registra permiso/autorización con evidencia, historial y auditoría',
    (tester) async {
      final firestore = FirebaseFirestore.instance;
      final activoService = ActivoAgroServiceV2();

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-rwa02-0214-$sufijo';

      final derechoId =
          'derecho-rwa02-0214-$sufijo';

      final usuarioId =
          'usuario-rwa02-0214-$sufijo';

      final fecha =
          DateTime(2026, 9, 21, 12, 0);

      // =====================================================
      // 1. CREAR ACTIVO BASE
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre:
            'Activo de prueba para Permiso/Autorización',
        descripcion:
            'Activo técnico para validar GAP-RWA-02 02.14.',
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
          descripcionEntorno: 'Prueba técnica',
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
          nivelTecnologia: 0,
          tecnologiaVerificada: false,
          cantidadTecnologias: 0,
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
            'hash-rwa02-0214-$sufijo',
        versionDatos: 1,
        datos: null,
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      await activoService.crearActivo(activo);

      // =====================================================
      // 2. REPRESENTAR PERMISO / AUTORIZACIÓN
      // =====================================================

      final derecho = DerechoActivo(
        derechoId: derechoId,
        activoAgroId: activoId,
        tipoDerecho: 'autorizacion',
        descripcionTipo:
            'Autorización administrativa',
        tipoObjeto: 'actividad_productiva',
        descripcionObjeto:
            'Autorización para actividad productiva '
            'sobre el Activo Agro.',
        alcanceTerritorial: null,
        tipoInstrumento: 'permiso_administrativo',
        identificadorInstrumento:
            'PERM-TEST-RWA02-0214-$sufijo',
        emisor:
            'Organismo competente de prueba',
        fechaInicio: fecha,
        fechaFin:
            DateTime(2028, 9, 21, 12, 0),
        estado: 'vigente',
        condiciones: const [
          'Cumplir las condiciones establecidas '
              'en el permiso.',
        ],
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      // =====================================================
      // 3. CREAR EVIDENCIA DEL PERMISO
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'derecho',
        elementoTipo: 'DerechoActivo',
        elementoId: derechoId,
        campoRelacionado: 'permiso_autorizacion',
        tipo: 'documentacion_juridica',
        descripcion:
            'Documento que acredita el permiso '
            'o autorización.',
        observaciones:
            'Prueba funcional GAP-RWA-02 02.14.',
        aportanteId: usuarioId,
        fuenteTipo: 'documento',
        fuenteNombre:
            'Instrumento administrativo de prueba',
        fuenteReferencia:
            'FUENTE-RWA02-0214-$sufijo',
        soporteTipo: 'documento',
        soporteReferencia:
            'SOPORTE-RWA02-0214-$sufijo',
        soporteNombre:
            'Permiso administrativo de prueba',
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
        'autorizacion',
      );

      expect(
        derechoFirestore['tipoInstrumento'],
        'permiso_administrativo',
      );

      expect(
        derechoFirestore[
            'identificadorInstrumento'],
        'PERM-TEST-RWA02-0214-$sufijo',
      );

      expect(
        derechoFirestore['estado'],
        'vigente',
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
        'permiso_autorizacion',
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
      // 8. VERIFICAR AUDITORÍA
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