import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/firebase_options.dart';

import 'package:agro_fields/services/activo_agro_service_v2.dart';
import 'package:agro_fields/core/audit/audit_service.dart';

import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/tipo_activo.dart';
import 'package:agro_fields/models/activos/ubicacion_activo_model.dart';
import 'package:agro_fields/models/activos/modulo_produccion_model.dart';
import 'package:agro_fields/models/activos/economia_activo_model.dart';
import 'package:agro_fields/models/activos/documentacion_activo_model.dart';
import 'package:agro_fields/models/activos/confianza_activo_model.dart';
import 'package:agro_fields/models/activos/evaluacion_confianza_model.dart';
import 'package:agro_fields/models/activos/madurez_activo_model.dart';
import 'package:agro_fields/models/activos/suelo_activo_model.dart';
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
    'Paso 12.10 - actualiza suelo con historial y auditoria',
    (tester) async {
      final firestore = FirebaseFirestore.instance;
      final activoService = ActivoAgroServiceV2();
      final auditService = AuditService();

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-suelo-test-$sufijo';

      const usuarioId =
          'usuario-suelo-test-001';

      final fecha =
          DateTime(2026, 9, 8, 10, 0);

      // =========================================================
      // 1. CREAR ACTIVO AGRO V2
      // =========================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre: 'Activo de prueba para Suelo',
        descripcion:
            'Activo técnico para validar actualización de suelo.',
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
        producciones: [
          ModuloProduccion(
            dominio: 'agricola',
            actividad: 'produccion agricola',
            descripcion:
                'Producción de prueba para integración.',
            superficie: 100,
            unidad: 'hectareas',
            capacidadActual: 100,
            capacidadMaxima: 100,
            activo: true,
            datos: {},
            ciclos: [],
          ),
        ],
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
        evaluacion: EvaluacionConfianza.inicial(),
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
            'hash-suelo-test-$sufijo',
        versionDatos: 1,
        datos: null,
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      final activoCreado =
          await activoService.crearActivo(activo);

      expect(
        activoCreado,
        activoId,
      );

      // =========================================================
      // 2. VERIFICAR ACTIVO CREADO
      // =========================================================

      final activoInicial =
          await activoService.obtenerActivoPorId(
        activoId,
      );

      expect(
        activoInicial,
        isNotNull,
      );

      expect(
        activoInicial!.activoId,
        activoId,
      );

      expect(
        activoInicial.suelo.estado,
        'sin_evaluar',
      );

      // =========================================================
      // 3. CREAR NUEVA INFORMACIÓN DE SUELO
      // =========================================================

      final sueloActualizado = SueloActivo(
        estado: 'evaluado',
        textura: 'franco',
        drenaje: 'bueno',
        ph: 6.5,
        materiaOrganica: 3.2,
        evidencias: [],
        observaciones:
            'Evaluación de suelo realizada para prueba.',
        fechaEvaluacion:
            DateTime(2026, 9, 8, 10, 15),
      );

      // =========================================================
      // 4. ACTUALIZAR SUELO
      // =========================================================

      await activoService.actualizarSuelo(
        activoId,
        sueloActualizado,
      );

      // =========================================================
      // 5. VERIFICAR SUELO PERSISTIDO
      // =========================================================

      final activoDespues =
          await activoService.obtenerActivoPorId(
        activoId,
      );

      expect(
        activoDespues,
        isNotNull,
      );

      expect(
        activoDespues!.suelo.estado,
        'evaluado',
      );

      expect(
        activoDespues.suelo.textura,
        'franco',
      );

      expect(
        activoDespues.suelo.drenaje,
        'bueno',
      );

      expect(
        activoDespues.suelo.ph,
        6.5,
      );

      expect(
        activoDespues.suelo.materiaOrganica,
        3.2,
      );

      expect(
        activoDespues.suelo.observaciones,
        'Evaluación de suelo realizada para prueba.',
      );

      expect(
        activoDespues.suelo.fechaEvaluacion,
        isNotNull,
      );

      // =========================================================
      // 6. VERIFICAR HISTORIAL
      // =========================================================

      expect(
        activoDespues.historial,
        isNotEmpty,
      );

      final eventoSuelo =
          activoDespues.historial.where(
        (evento) =>
            evento.tipoEvento ==
                'actualizacion_suelo' &&
            evento.moduloOrigen == 'suelo',
      );

      expect(
        eventoSuelo,
        isNotEmpty,
      );

      final evento =
          eventoSuelo.last;

      expect(
        evento.descripcion,
        'Actualización de información del suelo',
      );

      expect(
        evento.usuarioId,
        usuarioId,
      );

      // =========================================================
      // 7. VERIFICAR AUDITORÍA
      // =========================================================

      final auditoria =
          await auditService.obtenerPorActivo(
        activoId,
      );

      expect(
        auditoria,
        isNotEmpty,
      );

      final auditoriaSuelo =
          auditoria.where(
        (evento) =>
            evento.modulo == 'suelo' &&
            evento.accion == 'actualizar_suelo',
      );

      expect(
        auditoriaSuelo,
        isNotEmpty,
      );

      final eventoAuditoria =
          auditoriaSuelo.last;

      expect(
        eventoAuditoria.activoId,
        activoId,
      );

      expect(
        eventoAuditoria.usuarioId,
        usuarioId,
      );

      expect(
        eventoAuditoria.modulo,
        'suelo',
      );

      expect(
        eventoAuditoria.accion,
        'actualizar_suelo',
      );

      expect(
        eventoAuditoria.elementoAfectado,
        activoId,
      );

      expect(
        eventoAuditoria.referencia,
        activoId,
      );

      // =========================================================
      // 8. VERIFICAR DOCUMENTO DIRECTAMENTE EN FIRESTORE
      // =========================================================

      final firestoreSnapshot =
          await firestore
              .collection('activos_agro')
              .doc(activoId)
              .get();

      expect(
        firestoreSnapshot.exists,
        true,
      );

      final data =
          firestoreSnapshot.data()!;

      final sueloData =
          data['suelo'] as Map<String, dynamic>;

      expect(
        sueloData['estado'],
        'evaluado',
      );

      expect(
        sueloData['textura'],
        'franco',
      );

      expect(
        sueloData['drenaje'],
        'bueno',
      );

      expect(
        sueloData['ph'],
        6.5,
      );

      expect(
        sueloData['materiaOrganica'],
        3.2,
      );
    },
  );
}
