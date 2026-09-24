import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/tipo_activo.dart';
import 'package:agro_fields/models/activos/ubicacion_activo_model.dart';
import 'package:agro_fields/models/activos/modulo_produccion_model.dart';
import 'package:agro_fields/models/activos/suelo_activo_model.dart';
import 'package:agro_fields/models/activos/economia_activo_model.dart';
import 'package:agro_fields/models/activos/documentacion_activo_model.dart';
import 'package:agro_fields/models/activos/confianza_activo_model.dart';
import 'package:agro_fields/models/activos/evaluacion_confianza_model.dart';
import 'package:agro_fields/models/activos/madurez_activo_model.dart';
import 'package:agro_fields/models/activos/estado_activo.dart';
import 'package:agro_fields/models/activos/participante_activo_model.dart';
import 'package:agro_fields/services/activo_agro_service_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late ActivoAgroServiceV2 activoService;

  const String usuarioId = 'usuario_test_rwa_preparacion';

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
    'Validar Preparación RWA + Madurez + Historial + Auditoría',
    (tester) async {
      final fecha = DateTime(2026, 9, 23);

      final sufijo =
          DateTime.now().millisecondsSinceEpoch.toString();

      final activoId =
          'activo-test-rwa-preparacion-$sufijo';

      // =====================================================
      // 1. CREAR ACTIVO PREPARADO PARA EVALUACIÓN
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre: 'Activo de prueba para Preparación RWA',
        descripcion:
            'Activo técnico para validar madurez y preparación para inversión.',
        tipoActivo: TipoActivo.agricola,
        categorias: [
          'agricultura',
        ],
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
          descripcionEntorno: 'Prueba técnica RWA',
          accesoCaminos: 'camino rural',
          disponibilidadServicios: '',
          jurisdiccionLegal: 'Argentina',
          zonaHoraria: 'America/Argentina/Buenos_Aires',
          monedaLocal: 'USD',
        ),
        suelo: SueloActivo.inicial(),
        producciones: [
          ModuloProduccion(
            dominio: 'agricola',
            actividad: 'produccion agricola',
            descripcion:
                'Producción de prueba para validar preparación RWA.',
            superficie: 100,
            unidad: 'hectareas',
            capacidadActual: 100,
            capacidadMaxima: 100,
            activo: true,
            datos: {},
            ciclos: [],
          ),
        ],
        economia: EconomiaActivo(
          objetivoProyecto: 'Expansión productiva',
          etapaProyecto: 'produccion',
          inversionEsperada: 250000,
          capacidadActual: '100 hectáreas',
          capacidadProyectada: '150 hectáreas',
          riesgosIdentificados: 'Riesgo climático',
          origenInformacion: 'propietario',
          responsableDeclaracion: usuarioId,
          valorSolicitado: 1200000,
          moneda: 'USD',
          tipoOperacion: 'venta',
          capitalRequerido: 250000,
          ingresosEstimados: '180000 USD anuales',
          costosEstimados: '90000 USD anuales',
          rentabilidadDeclarada: '10%',
          periodoEvaluacion: '5 años',
          datosEconomicos: [],
          fechaActualizacion: fecha,
        ),
        documentacion: DocumentacionActivo(
          documentacionCompleta: true,
          documentos: [],
          certificaciones: [],
          permisos: [],
          archivos: [],
          observaciones:
              'Documentación completa para prueba técnica.',
          fechaActualizacion: fecha,
        ),
        confianza: ConfianzaActivo(
          nivelGeneral: 0,
          identidadVerificada: false,
          documentacionCompleta: true,
          nivelDocumentacion: 100,
          cantidadEvidencias: 0,
          nivelEvidencias: 0,
          informacionProductivaCompleta: true,
          nivelProduccion: 100,
          nivelInfraestructura: 0,
          infraestructuraVerificada: false,
          cantidadInfraestructuras: 0,
          nivelTecnologia: 0,
          tecnologiaVerificada: false,
          cantidadTecnologias: 0,
          nivelInversion: 0,
          inversionDeclarada: true,
          inversionVerificada: false,
          montoInversionDeclarada: 250000,
          monedaInversion: 'USD',
          participantesVerificados: true,
          nivelGobernanza: 100,
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
        participantes: [
          ParticipanteActivo(
            usuarioId: usuarioId,
            rol: 'inversor',
            estado: 'activo',
            fechaIngreso: fecha,
          ),
        ],
        propietarioId: usuarioId,
        creadorId: usuarioId,
        publicadorId: usuarioId,
        tipoRelacionPropietario: 'propietario',
        estado: EstadoActivo.borrador,
        estadoPublicacion: 'borrador',
        visible: false,
        historial: [],
        hashActivo: 'hash-rwa-preparacion-test-$sufijo',
        versionDatos: 1,
        datos: null,
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      final activoCreado =
          await activoService.crearActivo(activo);

      expect(activoCreado, isNotNull);

      // =====================================================
      // 2. EVALUAR ACTIVO
      // =====================================================

      await activoService.evaluarActivo(activoId);

      // =====================================================
      // 3. RECUPERAR ACTIVO EVALUADO
      // =====================================================

      final activoEvaluado =
          await activoService.obtenerActivoPorId(activoId);

      expect(activoEvaluado, isNotNull);

      // =====================================================
      // 4. VALIDAR MADUREZ Y PREPARACIÓN PARA INVERSIÓN
      // =====================================================

      expect(
        activoEvaluado!.madurez.preparacionInversion,
        'avanzada',
      );

      expect(
        activoEvaluado.madurez.porcentaje,
        90,
      );

      expect(
        activoEvaluado.madurez.etapa,
        'maduro',
      );

      expect(
        activoEvaluado.madurez.nivelTecnologico,
        'alto',
      );

      expect(
        activoEvaluado.madurez.faltantes,
        contains('Evidencias'),
      );

      // =====================================================
      // 5. VALIDAR PERSISTENCIA DE MADUREZ EN FIRESTORE
      // =====================================================

      final snapshot = await firestore
          .collection('activos_agro')
          .doc(activoId)
          .get();

      expect(snapshot.exists, isTrue);

      final datosFirestore = snapshot.data();

      expect(datosFirestore, isNotNull);

      final madurezFirestore =
          Map<String, dynamic>.from(
        datosFirestore!['madurez'] as Map,
      );

      expect(
        madurezFirestore['preparacionInversion'],
        'avanzada',
      );

      expect(
        madurezFirestore['porcentaje'],
        90,
      );

      // =====================================================
      // 6. VALIDAR HISTORIAL
      // =====================================================

      final historial =
          activoEvaluado.historial;

      expect(
        historial.any(
          (evento) =>
              evento.tipoEvento ==
              'evaluacion_confianza',
        ),
        isTrue,
      );

      expect(
        historial.any(
          (evento) =>
              evento.moduloOrigen ==
              'confianza',
        ),
        isTrue,
      );

      // =====================================================
      // 7. VALIDAR AUDITORÍA
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

      final existeAuditoriaEvaluacion =
          auditoriaSnapshot.docs.any(
        (doc) {
          final data = doc.data();

          return data['modulo'] == 'confianza' &&
              data['accion'] == 'evaluar_confianza';
        },
      );

      expect(
        existeAuditoriaEvaluacion,
        isTrue,
      );
    },
  );
}