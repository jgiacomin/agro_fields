import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/economia_activo_model.dart';
import 'package:agro_fields/models/activos/dato_economico_model.dart';
import 'package:agro_fields/models/activos/documentacion_activo_model.dart';
import 'package:agro_fields/models/activos/confianza_activo_model.dart';
import 'package:agro_fields/models/activos/evaluacion_confianza_model.dart';
import 'package:agro_fields/models/activos/estado_activo.dart';
import 'package:agro_fields/models/activos/evento_afectacion_model.dart';
import 'package:agro_fields/models/activos/evidencia_model.dart';
import 'package:agro_fields/models/activos/madurez_activo_model.dart';
import 'package:agro_fields/models/activos/modulo_produccion_model.dart';
import 'package:agro_fields/models/activos/tipo_activo.dart';
import 'package:agro_fields/models/activos/ubicacion_activo_model.dart';
import 'package:agro_fields/models/activos/suelo_activo_model.dart';
import 'package:agro_fields/services/activo_agro_service_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late ActivoAgroServiceV2 activoService;

  const String usuarioId =
      'usuario_test_evento_afectacion';

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
    'CLIMA-01 - registra EventoAfectacion + Afectacion + Consecuencia + Evidencia + Historial + AuditorÃ­a',
    (tester) async {
      final fecha =
          DateTime(2026, 9, 24, 10, 0);

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-test-evento-afectacion-$sufijo';

      final eventoId =
          'evento-afectacion-test-$sufijo';

      final moduloProduccionId =
          'modulo-produccion-evento-afectacion-$sufijo';

      // =====================================================
      // 1. CREAR ACTIVO â€” EVENTO AFECTACION
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre:
            'Activo de prueba para EventoAfectacion',
        descripcion:
            'Activo tÃ©cnico para validar CLIMA-01.',
        tipoActivo:
            TipoActivo.agricola,
        categorias: [
          'agricultura',
        ],
        ubicacion:
            UbicacionActivo(
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
              'Prueba tÃ©cnica CLIMA-01',
          accesoCaminos:
              'camino rural',
          disponibilidadServicios: '',
          jurisdiccionLegal:
              'Argentina',
          zonaHoraria:
              'America/Argentina/Buenos_Aires',
          monedaLocal: 'ARS',
        ),
        suelo:
            SueloActivo.inicial(),
        producciones: [
          ModuloProduccion(
            id: moduloProduccionId,
            activoAgroId: activoId,
            dominio: 'agricola',
            actividad:
                'produccion agricola',
            descripcion:
                'ProducciÃ³n agrÃ­cola de prueba para CLIMA-01.',
            superficie: 100,
            unidad: 'hectareas',
            capacidadActual: 100,
            capacidadMaxima: 100,
            activo: true,
            datos: {
              'cultivo': 'soja',
            },
            ciclos: [],
          ),
        ],
        economia:
    EconomiaActivo(
  objetivoProyecto:
      'EvaluaciÃ³n de impacto econÃ³mico',
  etapaProyecto:
      'produccion',
  inversionEsperada:
      0,
  capacidadActual:
      '',
  capacidadProyectada:
      '',
  riesgosIdentificados:
      'Riesgo climÃ¡tico',
  origenInformacion:
      'productor',
  responsableDeclaracion:
      usuarioId,
  valorSolicitado:
      0,
  moneda:
      'USD',
  tipoOperacion:
      '',
  capitalRequerido:
      0,
  ingresosEstimados:
      '',
  costosEstimados:
      '',
  rentabilidadDeclarada:
      '',
  periodoEvaluacion:
      '2025',
  datosEconomicos: [
    DatoEconomico(
      nombreDato:
          'ingresosHistoricos',
      valor:
          150000,
      tipoTemporal:
          TipoTemporalEconomico.historico,
      periodo:
          '2025',
    ),
  ],
  fechaActualizacion:
      fecha,
  ),
        documentacion:
            DocumentacionActivo.inicial(),
        confianza:
            ConfianzaActivo(
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
        madurez:
            MadurezActivo(
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
        estado:
            EstadoActivo.borrador,
        estadoPublicacion:
            'borrador',
        visible: false,
        historial: [],
        hashActivo:
            'hash-evento-afectacion-test-$sufijo',
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
        equals(activoId),
      );
      final economiaActualizada =
    EconomiaActivo(
  objetivoProyecto:
      'Prueba econÃ³mica CLIMA-01',
  etapaProyecto:
      'actual',
  inversionEsperada:
      0,
  capacidadActual:
      '100 hectÃ¡reas',
  capacidadProyectada:
      '100 hectÃ¡reas',
  riesgosIdentificados:
      'Riesgo climÃ¡tico',
  origenInformacion:
      'prueba',
  responsableDeclaracion:
      usuarioId,
  valorSolicitado:
      0,
  moneda:
      'USD',
  tipoOperacion:
      'prueba',
  capitalRequerido:
      0,
  ingresosEstimados:
      '210000 USD anuales',
  costosEstimados:
      '100000 USD anuales',
  rentabilidadDeclarada:
      '11%',
  periodoEvaluacion:
      '2027',
  datosEconomicos: [
    DatoEconomico(
      nombreDato:
          'ingresosProyectados',
      valor:
          210000,
      tipoTemporal:
          TipoTemporalEconomico.proyectado,
      periodo:
          '2027',
    ),
  ],
  fechaActualizacion:
      fecha,
);

await activoService.actualizarEconomia(
  activoId,
  economiaActualizada,
);

      // =====================================================
      // 2. CREAR EVENTO AFECTACION
      // =====================================================

      final evento =
          EventoAfectacion(
        eventoId: eventoId,
        activoAgroId: activoId,
        tipoEvento: 'climatico',
        subtipoEvento: 'granizo',
        fechaInicio:
            DateTime(2026, 9, 20, 15, 0),
        fechaFin:
            DateTime(2026, 9, 20, 17, 0),
        descripcion:
            'Evento climÃ¡tico de prueba para CLIMA-01.',
        origen: 'registro_productor',
        estado: 'registrado',
        usuarioRegistrador:
            usuarioId,
        fechaRegistro: fecha,
        afectaciones: [
          Afectacion(
            objetoTipo: 'ModuloProduccion',
            objetoId: moduloProduccionId,
            descripcion:
                'AfectaciÃ³n de superficie productiva por granizo.',
            magnitud: 30,
            unidad: 'ha',
            superficieAfectada: 30,
            porcentajeAfectado: 30,
            nivel: 'medio',
            estado: 'activa',
            consecuencias: [
             Consecuencia(
             tipoConsecuencia:
       'reduccion_produccion',
  descripcion:
      'ReducciÃ³n estimada de producciÃ³n por afectaciÃ³n climÃ¡tica.',
  estado: 'en_evaluacion',
  impactoProductivo: ImpactoProductivo(
    tipoImpacto: 'reduccion_produccion',
    valor: 30000,
    unidad: 'kg',
    referenciaProductiva: ReferenciaEntidad(
      tipo: 'CicloProductivo',
      id: 'ciclo_001',
    ),
    estado: 'estimado',
  ),
  referenciaEconomica:
    ReferenciaDatoEconomico(
  nombreDato:
      'ingresosHistoricos',
  tipoTemporal:
      'historico',
  periodo:
      '2025',
),
),
            ],
          ),
        ],
      );

      // =====================================================
      // 3. CREAR EVIDENCIA â€” EVENTO AFECTACION
      // =====================================================

      final evidencia =
          Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'afectacion',
        elementoTipo: 'EventoAfectacion',
        elementoId: eventoId,
        campoRelacionado: 'evento',
        tipo: 'registro_evento',
        descripcion:
            'Evidencia del evento climÃ¡tico registrado.',
        observaciones:
            'Evidencia creada para validar CLIMA-01.',
        aportanteId: usuarioId,
        fuenteTipo: 'productor',
        fuenteNombre:
            'Registro climÃ¡tico de prueba',
        fuenteReferencia:
            'TEST-CLIMA-01-$sufijo',
        soporteTipo: 'registro',
        soporteReferencia:
            'TEST-SOPORTE-CLIMA-01-$sufijo',
        soporteNombre:
            'Registro de evento climÃ¡tico',
        fechaHecho:
            DateTime(2026, 9, 20, 16, 0),
        fechaRegistro: fecha,
        estadoVerificacion:
            'informada',
        estadoValidez:
            'vigente_informado',
      );

      // =====================================================
      // 4. REGISTRAR EVENTO + EVIDENCIA
      // =====================================================

      await activoService.registrarEventoAfectacion(
        activoId,
        evento,
        evidencia: evidencia,
      );

      // =====================================================
      // 5. VERIFICAR EVENTO EN FIRESTORE
      // =====================================================

      final eventoSnapshot =
          await firestore
              .collection('eventos_afectacion')
              .doc(eventoId)
              .get();

      expect(
        eventoSnapshot.exists,
        isTrue,
      );

      final eventoData =
          eventoSnapshot.data()!;

      expect(
        eventoData['eventoId'],
        equals(eventoId),
      );

      expect(
        eventoData['activoAgroId'],
        equals(activoId),
      );

      expect(
        eventoData['tipoEvento'],
        equals('climatico'),
      );

      expect(
        eventoData['subtipoEvento'],
        equals('granizo'),
      );

      // =====================================================
      // 6. VERIFICAR AFECTACION â€” MODULO PRODUCCION
      // =====================================================

      final afectacionesData =
          eventoData['afectaciones']
              as List<dynamic>;

      expect(
        afectacionesData.length,
        equals(1),
      );

      final afectacionData =
          Map<String, dynamic>.from(
        afectacionesData.first as Map,
      );

      expect(
        afectacionData['objetoTipo'],
        equals('ModuloProduccion'),
      );

      expect(
        afectacionData['objetoId'],
        equals(moduloProduccionId),
      );

      expect(
        afectacionData['magnitud'],
        equals(30),
      );

      expect(
        afectacionData['unidad'],
        equals('ha'),
      );

      expect(
        afectacionData['superficieAfectada'],
        equals(30),
      );

      expect(
        afectacionData['porcentajeAfectado'],
        equals(30),
      );

      expect(
        afectacionData['nivel'],
        equals('medio'),
      );

      expect(
        afectacionData['estado'],
        equals('activa'),
      );

      // =====================================================
      // 7. VERIFICAR CONSECUENCIA â€” AFECTACION
      // =====================================================

      final consecuenciasData =
          afectacionData['consecuencias']
              as List<dynamic>;

      expect(
        consecuenciasData.length,
        equals(1),
      );

      final consecuenciaData =
          Map<String, dynamic>.from(
        consecuenciasData.first as Map,
      );

      expect(
        consecuenciaData['tipoConsecuencia'],
        equals('reduccion_produccion'),
      );

      expect(
        consecuenciaData['descripcion'],
        equals(
          'ReducciÃ³n estimada de producciÃ³n por afectaciÃ³n climÃ¡tica.',
        ),
      );

      expect(
        consecuenciaData['estado'],
        equals('en_evaluacion'),
      );
            final impactoProductivoData =
          Map<String, dynamic>.from(
        consecuenciaData['impactoProductivo'] as Map,
      );

      expect(
        impactoProductivoData['tipoImpacto'],
        equals('reduccion_produccion'),
      );

      expect(
        impactoProductivoData['valor'],
        equals(30000),
      );

      expect(
        impactoProductivoData['unidad'],
        equals('kg'),
      );

      expect(
        impactoProductivoData['estado'],
        equals('estimado'),
      );

      final referenciaProductivaData =
          Map<String, dynamic>.from(
        impactoProductivoData['referenciaProductiva']
            as Map,
      );

      expect(
        referenciaProductivaData['tipo'],
        equals('CicloProductivo'),
      );

            final referenciaEconomicaData =
          Map<String, dynamic>.from(
        consecuenciaData['referenciaEconomica']
            as Map,
      );

      expect(
        referenciaEconomicaData['nombreDato'],
        equals('ingresosHistoricos'),
      );

      expect(
        referenciaEconomicaData['tipoTemporal'],
        equals('historico'),
      );

      expect(
        referenciaEconomicaData['periodo'],
        equals('2025'),
      );

      expect(
        referenciaEconomicaData['escenarioId'],
        isNull,
      );

      expect(
        referenciaProductivaData['id'],
        equals('ciclo_001'),
      );

      // =====================================================
      // 8. VERIFICAR EVIDENCIA â€” VINCULO CON EVENTO
      // =====================================================

      final evidenciaSnapshot =
          await firestore
              .collection('evidencias')
              .where(
                'activoAgroId',
                isEqualTo: activoId,
              )
              .get();

      expect(
        evidenciaSnapshot.docs.length,
        equals(1),
      );

      final evidenciaData =
          evidenciaSnapshot.docs.first.data();

      expect(
        evidenciaData['elementoTipo'],
        equals('EventoAfectacion'),
      );

      expect(
        evidenciaData['elementoId'],
        equals(eventoId),
      );

      expect(
        evidenciaData['moduloOrigen'],
        equals('afectacion'),
      );

      // =====================================================
      // 9. VERIFICAR HISTORIAL â€” EVENTO AFECTACION
      // =====================================================

      final activoActualizado =
          await activoService.obtenerActivoPorId(
        activoId,
      );

      expect(
        activoActualizado,
        isNotNull,
      );

      final eventosHistorial =
          activoActualizado!.historial.where(
        (historial) =>
            historial.tipoEvento ==
            'registro_evento_afectacion',
      );

      expect(
        eventosHistorial,
        isNotEmpty,
      );

      final historialEvento =
          eventosHistorial.last;

      expect(
        historialEvento.entidadRelacionada,
        equals('EventoAfectacion'),
      );

      expect(
        historialEvento.referenciaId,
        equals(eventoId),
      );

      expect(
        historialEvento.datosEvento!['eventoId'],
        equals(eventoId),
      );

      expect(
        historialEvento.datosEvento!['tieneEvidencia'],
        isTrue,
      );

      expect(
        historialEvento.datosEvento!['evidenciaId'],
        isNotNull,
      );

      // =====================================================
      // 10. VERIFICAR AUDITORIA â€” EVENTO AFECTACION
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
              data['modulo'] ==
                  'afectacion' &&
              data['accion'] ==
                  'registrar_evento_afectacion' &&
              data['elementoAfectado'] ==
                  eventoId,
        ),
        isTrue,
      );

      // =====================================================
      // 11. VERIFICAR AUDITORIA â€” EVIDENCIA
      // =====================================================

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
