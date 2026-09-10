import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/evidencia_model.dart';
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
import 'package:agro_fields/services/activo_agro_service_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late ActivoAgroServiceV2 activoService;

  const String usuarioId =
      'usuario_test_documentacion';

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
    'Validar Documentación + Evidencia + Historial + Auditoría',
    (tester) async {
      final fecha = DateTime(2026, 9, 8);

      final sufijo =
          DateTime.now().millisecondsSinceEpoch.toString();

      final activoId =
          'activo-test-documentacion-$sufijo';

      // =====================================================
      // 1. CREAR ACTIVO
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre:
            'Activo de prueba para Documentación + Evidencia',
        descripcion:
            'Activo técnico para validar integración documental y trazabilidad.',
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
        suelo:
            SueloActivo.inicial(),
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
        estado:
            EstadoActivo.borrador,
        estadoPublicacion:
            'borrador',
        visible: false,
        historial: [],
        hashActivo:
            'hash-documentacion-test-$sufijo',
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
      // 2. CREAR DOCUMENTACIÓN
      // =====================================================

      final documentacion = DocumentacionActivo(
        documentacionCompleta: true,
        documentos: [
          'titulo_propiedad',
        ],
        certificaciones: [
          'certificacion_ambiental',
        ],
        permisos: [
          'permiso_explotacion',
        ],
        archivos: [
          'titulo_propiedad.pdf',
        ],
        observaciones:
            'Documentación cargada para prueba de integración.',
        fechaActualizacion: fecha,
      );

      // =====================================================
      // 3. CREAR EVIDENCIA DOCUMENTAL
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'documentacion',
        elementoTipo: 'DocumentacionActivo',
        elementoId: activoId,
        campoRelacionado:
            'documentos',
        tipo:
            'documento_propiedad',
        descripcion:
            'Evidencia documental del título de propiedad.',
        observaciones:
            'Evidencia creada para validar integración documental.',
        aportanteId: usuarioId,
        fuenteTipo: 'propietario',
        fuenteNombre:
            'Documentación del activo de prueba',
        fuenteReferencia:
            'TEST-DOCUMENTACION-001',
        soporteTipo: 'documento',
        soporteReferencia:
            'TEST-SOPORTE-DOCUMENTACION-001',
        soporteNombre:
            'Titulo de propiedad test',
        fechaHecho: fecha,
        fechaRegistro: fecha,
        estadoVerificacion:
            'informada',
        estadoValidez:
            'vigente_informado',
      );

      // =====================================================
      // 4. ACTUALIZAR DOCUMENTACIÓN + EVIDENCIA
      // =====================================================

      await activoService.actualizarDocumentacion(
        activoId,
        documentacion,
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

      // =====================================================
      // 6. VALIDAR DOCUMENTACIÓN
      // =====================================================

      expect(
        activoActualizado!
            .documentacion
            .documentacionCompleta,
        isTrue,
      );

      expect(
        activoActualizado
            .documentacion
            .documentos,
        contains('titulo_propiedad'),
      );

      expect(
        activoActualizado
            .documentacion
            .certificaciones,
        contains('certificacion_ambiental'),
      );

      expect(
        activoActualizado
            .documentacion
            .permisos,
        contains('permiso_explotacion'),
      );

      expect(
        activoActualizado
            .documentacion
            .archivos,
        contains('titulo_propiedad.pdf'),
      );

      expect(
        activoActualizado
            .documentacion
            .observaciones,
        equals(
          'Documentación cargada para prueba de integración.',
        ),
      );

      // =====================================================
      // 7. VERIFICAR EVIDENCIA EN FIRESTORE
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
        evidenciaSnapshot.docs,
        isNotEmpty,
      );

      expect(
        evidenciaSnapshot.docs.length,
        equals(1),
      );

      final evidenciaData =
          evidenciaSnapshot.docs.first.data();

      expect(
        evidenciaData['activoAgroId'],
        equals(activoId),
      );

      expect(
        evidenciaData['moduloOrigen'],
        equals('documentacion'),
      );

      expect(
        evidenciaData['elementoTipo'],
        equals('DocumentacionActivo'),
      );

      expect(
        evidenciaData['elementoId'],
        equals(activoId),
      );

      expect(
        evidenciaData['campoRelacionado'],
        equals('documentos'),
      );

      expect(
        evidenciaData['tipo'],
        equals('documento_propiedad'),
      );

      expect(
        evidenciaData['estadoVerificacion'],
        equals('informada'),
      );

      expect(
        evidenciaData['estadoValidez'],
        equals('vigente_informado'),
      );

      // =====================================================
      // 8. VERIFICAR HISTORIAL
      // =====================================================

      final eventosDocumentacion =
          activoActualizado.historial.where(
        (evento) =>
            evento.tipoEvento ==
            'actualizacion_documentacion',
      );

      expect(
        eventosDocumentacion,
        isNotEmpty,
      );

      expect(
        eventosDocumentacion.last.moduloOrigen,
        equals('documentacion'),
      );

      // =====================================================
      // 9. VERIFICAR AUDITORÍA
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
                  'documentacion' &&
              data['accion'] ==
                  'actualizar_documentacion',
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

