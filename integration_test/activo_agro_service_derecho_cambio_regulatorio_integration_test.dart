import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/tipo_activo.dart';
import 'package:agro_fields/models/activos/estado_activo.dart';
import 'package:agro_fields/models/activos/ubicacion_activo_model.dart';
import 'package:agro_fields/models/activos/modulo_produccion_model.dart';
import 'package:agro_fields/models/activos/economia_activo_model.dart';
import 'package:agro_fields/models/activos/documentacion_activo_model.dart';
import 'package:agro_fields/models/activos/confianza_activo_model.dart';
import 'package:agro_fields/models/activos/evaluacion_confianza_model.dart';
import 'package:agro_fields/models/activos/factor_confianza_model.dart';
import 'package:agro_fields/models/activos/historial_activo_model.dart';
import 'package:agro_fields/models/activos/evidencia_model.dart';
import 'package:agro_fields/models/activos/madurez_activo_model.dart';
import 'package:agro_fields/models/activos/suelo_activo_model.dart';

import 'package:agro_fields/services/activo_agro_service_v2.dart';
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

  test(
    'GAP-RWA-02 02.28 conserva cambio regulatorio con historial, evidencia y auditoria',
    () async {
      final db = FirebaseFirestore.instance;
      final activoService = ActivoAgroServiceV2();
      final evidenciaService = EvidenciaService();

      final fecha = DateTime(2026, 9, 17);

      final factor = FactorConfianza(
        nivel: 0,
        descripcion: '',
        evidencias: const [],
        fechaActualizacion: fecha,
      );

      final eventoRegulatorio = HistorialActivo(
        eventoId: 'evento_regulatorio_001',
        tipoEvento: 'cambio_regulatorio',
        descripcion:
            'Cambio regulatorio aplicado al Activo Agro de prueba.',
        usuarioId: 'usuario_rwa_02',
        moduloOrigen: 'juridico',
        fecha: fecha,
        entidadRelacionada: 'norma',
        referenciaId: 'NORMA-2026-001',
        datosEvento: {
          'normaAnterior': 'Norma ambiental anterior',
          'normaNueva': 'Norma ambiental actualizada',
          'fechaVigenciaAnterior': '2025-01-01',
          'fechaVigenciaNueva': '2026-09-01',
          'tipoCambio': 'modificacion',
          'jurisdiccion': 'Argentina',
        },
      );

      final activo = ActivoAgroV2(
        activoId: 'activo_rwa_02_regulatorio',
        nombre: 'Activo prueba cambio regulatorio',
        descripcion: 'Prueba GAP-RWA-02 02.28',
        tipoActivo: TipoActivo.otro,
        categorias: const ['prueba', 'rwa-02'],
        ubicacion: UbicacionActivo(
          pais: 'Argentina',
          provincia: 'Buenos Aires',
          departamento: '',
          localidad: '',
          codigoPostal: '',
          latitud: -34.9,
          longitud: -57.9,
          superficie: 1000,
          tipoZona: 'rural',
          zonaHoraria: 'America/Argentina/Buenos_Aires',
          accesoCaminos: '',
          descripcionEntorno: '',
          disponibilidadServicios: '',
          jurisdiccionLegal: 'Argentina',
          regionProductiva: '',
          monedaLocal: 'USD',
        ),
        producciones: const <ModuloProduccion>[],
        economia: EconomiaActivo(
          objetivoProyecto: '',
          etapaProyecto: '',
          inversionEsperada: 0,
          capacidadActual: '',
          capacidadProyectada: '',
          riesgosIdentificados: '',
          origenInformacion: '',
          responsableDeclaracion: '',
          valorSolicitado: 0,
          moneda: 'USD',
          tipoOperacion: '',
          capitalRequerido: 0,
          ingresosEstimados: '',
          costosEstimados: '',
          rentabilidadDeclarada: '',
          periodoEvaluacion: '',
          datosEconomicos: const [],
          fechaActualizacion: fecha,
        ),
        documentacion: DocumentacionActivo(
          documentacionCompleta: false,
          documentos: const [],
          certificaciones: const [],
          permisos: const [],
          archivos: const [],
          observaciones: '',
          fechaActualizacion: fecha,
        ),
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
        madurez: MadurezActivo(
          porcentaje: 0,
          faltantes: const [],
          etapa: 'prueba',
          nivelTecnologico: 'no_aplica',
          preparacionInversion: 'no_aplica',
        ),
        suelo: SueloActivo.inicial(),
        participantes: const [],
        propietarioId: 'usuario_propietario_rwa_02',
        publicadorId: 'usuario_publicador_rwa_02',
        tipoRelacionPropietario: 'propietario',
        estado: EstadoActivo.publicado,
        estadoPublicacion: 'publicado',
        visible: true,
        hashActivo: 'hash-rwa-02-regulatorio-001',
        versionDatos: 1,
        fechaCreacion: fecha,
        evaluacion: EvaluacionConfianza(
          nivelGeneral: 0,
          documental: factor,
          productivo: factor,
          economico: factor,
          legal: factor,
          profesional: factor,
          fortalezas: const [],
          pendientes: const [],
          resumen: '',
          responsable: '',
          fechaEvaluacion: fecha,
        ),
        creadorId: 'usuario_rwa_02',
        historial: [
          eventoRegulatorio,
        ],
         ultimaActualizacion: fecha,
      );

      final activoId = await activoService.crearActivo(activo);

      final evidencia = Evidencia(
        evidenciaId: 'evidencia_regulatoria_001',
        activoAgroId: activoId,
        moduloOrigen: 'juridico',
        elementoTipo: 'HistorialActivo',
        elementoId: eventoRegulatorio.eventoId,
        campoRelacionado: 'cambio_regulatorio',
        tipo: 'documental',
        descripcion: 'Norma que acredita el cambio regulatorio.',
        observaciones: 'Evidencia de prueba GAP-RWA-02 02.28.',
        aportanteId: 'usuario_rwa_02',
        fuenteTipo: 'normativa',
        fuenteNombre: 'Fuente normativa de prueba',
        fuenteReferencia: 'NORMA-2026-001',
        soporteTipo: 'documento',
        soporteReferencia: 'NORMA-2026-001',
        soporteNombre: 'Norma ambiental actualizada',
        fechaHecho: fecha,
        fechaRegistro: fecha,
        estadoVerificacion: 'pendiente',
        estadoValidez: 'vigente_informado',
      );

      final evidenciaId =
          await evidenciaService.crearEvidencia(
        evidencia: evidencia,
        usuarioId: 'usuario_rwa_02',
      );

      final snapshot = await db
          .collection('activos_agro')
          .doc(activoId)
          .get();

      expect(snapshot.exists, isTrue);

      final activoRecuperado =
          await activoService.obtenerActivoPorId(activoId);

      expect(activoRecuperado, isNotNull);

      final eventosRegulatorios =
          activoRecuperado!.historial.where(
        (evento) =>
            evento.tipoEvento == 'cambio_regulatorio',
      );

      expect(eventosRegulatorios, isNotEmpty);

      final eventoRecuperado =
          eventosRegulatorios.last;

      expect(
        eventoRecuperado.entidadRelacionada,
        equals('norma'),
      );

      expect(
        eventoRecuperado.referenciaId,
        equals('NORMA-2026-001'),
      );

      expect(
        eventoRecuperado.datosEvento,
        isNotNull,
      );

      expect(
        eventoRecuperado.datosEvento!['normaNueva'],
        equals('Norma ambiental actualizada'),
      );

      expect(
        eventoRecuperado.datosEvento!['tipoCambio'],
        equals('modificacion'),
      );

      final evidenciaSnapshot = await db
          .collection('evidencias')
          .doc(evidenciaId)
          .get();

      expect(evidenciaSnapshot.exists, isTrue);

      final auditoriaSnapshot = await db
          .collection('auditoria_activos')
          .where(
            'activoId',
            isEqualTo: activoId,
          )
          .get();

      expect(auditoriaSnapshot.docs, isNotEmpty);

      final tieneAuditoriaEvidencia =
          auditoriaSnapshot.docs.any(
        (doc) =>
            doc.data()['elementoAfectado'] ==
            eventoRegulatorio.eventoId ||
            doc.data()['accion'] ==
            'crear_evidencia',
      );

      expect(tieneAuditoriaEvidencia, isTrue);
    },
  );
}
