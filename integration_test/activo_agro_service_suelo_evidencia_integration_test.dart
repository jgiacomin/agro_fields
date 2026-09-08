import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/suelo_activo_model.dart';
import 'package:agro_fields/models/activos/evidencia_model.dart';
import 'package:agro_fields/models/activos/tipo_activo.dart';
import 'package:agro_fields/models/activos/ubicacion_activo_model.dart';
import 'package:agro_fields/models/activos/modulo_produccion_model.dart';
import 'package:agro_fields/models/activos/economia_activo_model.dart';
import 'package:agro_fields/models/activos/documentacion_activo_model.dart';
import 'package:agro_fields/models/activos/confianza_activo_model.dart';
import 'package:agro_fields/models/activos/evaluacion_confianza_model.dart';
import 'package:agro_fields/models/activos/madurez_activo_model.dart';
import 'package:agro_fields/models/activos/estado_activo.dart';
import 'package:agro_fields/services/activo_agro_service_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late ActivoAgroServiceV2 activoService;

  const String usuarioId =
      'usuario_test_suelo_evidencia';

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firestore = FirebaseFirestore.instance;

    firestore.useFirestoreEmulator(
      '10.0.2.2',
      8080,
    );

    activoService = ActivoAgroServiceV2();
  });

  testWidgets(
    'Validar Suelo + Evidencia + Historial + Auditoría',
    (tester) async {
      final fecha = DateTime(2026, 9, 8);
      final sufijo =
          DateTime.now().millisecondsSinceEpoch.toString();

      const activoId =
          'activo-test-suelo-evidencia';

      // =====================================================
      // 1. CREAR ACTIVO
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre:
            'Activo de prueba para Suelo + Evidencia',
        descripcion:
            'Activo técnico para validar integración de suelo y evidencia.',
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
          descripcionEntorno:
              'Prueba técnica',
          accesoCaminos:
              'camino rural',
          disponibilidadServicios: '',
          jurisdiccionLegal:
              'Argentina',
          zonaHoraria:
              'America/Argentina/Buenos_Aires',
          monedaLocal: 'ARS',
        ),
        suelo: SueloActivo.inicial(),
        producciones: [
          ModuloProduccion(
            dominio: 'agricola',
            actividad:
                'produccion agricola',
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
        economia:
            EconomiaActivo.inicial(),
        documentacion:
            DocumentacionActivo.inicial(),
        confianza: ConfianzaActivo(
          nivelGeneral: 0,
          identidadVerificada: false,
          documentacionCompleta: false,
          nivelDocumentacion: 0,
          cantidadEvidencias: 0,
          nivelEvidencias: 0,
          informacionProductivaCompleta:
              false,
          nivelProduccion: 0,
          nivelInfraestructura: 0,
          infraestructuraVerificada:
              false,
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
        tipoRelacionPropietario:
            'propietario',
        estado: EstadoActivo.borrador,
        estadoPublicacion: 'borrador',
        visible: false,
        historial: [],
        hashActivo:
            'hash-suelo-evidencia-test-$sufijo',
        versionDatos: 1,
        datos: null,
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      final activoCreado =
          await activoService.crearActivo(
        activo,
      );

      expect(
        activoCreado,
        isNotNull,
      );

      // =====================================================
      // 2. CREAR DATOS DE SUELO
      // =====================================================

      final suelo = SueloActivo(
        estado: 'evaluado',
        textura: 'franco',
        drenaje: 'bueno',
        ph: 6.5,
        materiaOrganica: 3.2,
        evidencias: [],
        observaciones:
            'Evaluación de suelo realizada para prueba de integración.',
        fechaEvaluacion: fecha,
      );

      // =====================================================
      // 3. CREAR EVIDENCIA DEL SUELO
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'suelo',
        elementoTipo: 'SueloActivo',
        elementoId: activoId,
        campoRelacionado: 'ph',
        tipo: 'analisis_suelo',
        descripcion:
            'Resultado de análisis de pH del suelo.',
        observaciones:
            'Evidencia creada para validar integración.',
        aportanteId: usuarioId,
        fuenteTipo: 'tecnico',
        fuenteNombre:
            'Evaluación técnica de suelo',
        fuenteReferencia:
            'TEST-SUELO-001',
        soporteTipo: 'documento',
        soporteReferencia:
            'TEST-SOPORTE-001',
        soporteNombre:
            'Analisis de suelo test',
        fechaHecho: fecha,
        fechaRegistro: fecha,
        estadoVerificacion:
            'informada',
        estadoValidez:
            'vigente_informado',
      );

      // =====================================================
      // 4. ACTUALIZAR SUELO + EVIDENCIA
      // =====================================================

      await activoService.actualizarSuelo(
        activoId,
        suelo,
        evidencia: evidencia,
      );

      // =====================================================
      // 5. RECUPERAR ACTIVO
      // =====================================================

      final activoActualizado =
          await activoService.obtenerActivoPorId(
        activoId,
      );

      expect(
        activoActualizado,
        isNotNull,
      );

      expect(
        activoActualizado!.suelo.ph,
        equals(6.5),
      );

      expect(
        activoActualizado.suelo.materiaOrganica,
        equals(3.2),
      );

      expect(
        activoActualizado.suelo.evidencias,
        isNotEmpty,
      );

      expect(
        activoActualizado.suelo.evidencias.length,
        equals(1),
      );

      final evidenciaId =
          activoActualizado.suelo.evidencias.first;

      // =====================================================
      // 6. VERIFICAR EVIDENCIA EN FIRESTORE
      // =====================================================

      final evidenciaSnapshot =
          await firestore
              .collection('evidencias')
              .doc(evidenciaId)
              .get();

      expect(
        evidenciaSnapshot.exists,
        isTrue,
      );

      final evidenciaData =
          evidenciaSnapshot.data();

      expect(
        evidenciaData?['activoAgroId'],
        equals(activoId),
      );

      expect(
        evidenciaData?['moduloOrigen'],
        equals('suelo'),
      );

      expect(
        evidenciaData?['elementoTipo'],
        equals('SueloActivo'),
      );

      expect(
        evidenciaData?['elementoId'],
        equals(activoId),
      );

      expect(
        evidenciaData?['campoRelacionado'],
        equals('ph'),
      );

      expect(
        evidenciaData?['tipo'],
        equals('analisis_suelo'),
      );

      // =====================================================
      // 7. VERIFICAR HISTORIAL
      // =====================================================

      final eventoSuelo =
          activoActualizado.historial.where(
        (evento) =>
            evento.tipoEvento ==
            'actualizacion_suelo',
      );

      expect(
        eventoSuelo,
        isNotEmpty,
      );

      expect(
        eventoSuelo.last.moduloOrigen,
        equals('suelo'),
      );

      // =====================================================
      // 8. VERIFICAR AUDITORÍA
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
              data['modulo'] == 'suelo' &&
              data['accion'] ==
                  'actualizar_suelo',
        ),
        isTrue,
      );

      expect(
        auditorias.any(
          (data) =>
              data['modulo'] ==
                  'evidencia' &&
              data['accion'] ==
                  'crear_evidencia',
        ),
        isTrue,
      );
    },
  );
}