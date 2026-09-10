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
      'usuario_test_economia';

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
    'Validar Economía + Evidencia + Historial + Auditoría',
    (tester) async {
      final fecha = DateTime(2026, 9, 8);

      final sufijo =
          DateTime.now().millisecondsSinceEpoch.toString();

      final activoId =
          'activo-test-economia-$sufijo';

      // =====================================================
      // 1. CREAR ACTIVO
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre:
            'Activo de prueba para Economía + Evidencia',
        descripcion:
            'Activo técnico para validar integración económica y trazabilidad.',
        tipoActivo:
            TipoActivo.agricola,
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
          descripcionEntorno:
              'Prueba técnica',
          accesoCaminos:
              'camino rural',
          disponibilidadServicios: '',
          jurisdiccionLegal:
              'Argentina',
          zonaHoraria:
              'America/Argentina/Buenos_Aires',
          monedaLocal:
              'USD',
        ),
        suelo:
            SueloActivo.inicial(),
        producciones: [
          ModuloProduccion(
            dominio:
                'agricola',
            actividad:
                'produccion agricola',
            descripcion:
                'Producción de prueba para integración.',
            superficie:
                100,
            unidad:
                'hectareas',
            capacidadActual:
                100,
            capacidadMaxima:
                100,
            activo:
                true,
            datos: {},
            ciclos: [],
          ),
        ],
        economia: EconomiaActivo(
          objetivoProyecto:
              'Expansión productiva',
          etapaProyecto:
              'produccion',
          inversionEsperada:
              250000,
          capacidadActual:
              '100 hectáreas',
          capacidadProyectada:
              '150 hectáreas',
          riesgosIdentificados:
              'Riesgo climático',
          origenInformacion:
              'propietario',
          responsableDeclaracion:
              usuarioId,
          valorSolicitado:
              1200000,
          moneda:
              'USD',
          tipoOperacion:
              'venta',
          capitalRequerido:
              250000,
          ingresosEstimados:
              '180000 USD anuales',
          costosEstimados:
              '90000 USD anuales',
          rentabilidadDeclarada:
              '10%',
          periodoEvaluacion:
              '5 años',
          datosEconomicos: {},
          fechaActualizacion:
              fecha,
        ),
        documentacion:
            DocumentacionActivo.inicial(),
        confianza: ConfianzaActivo(
          nivelGeneral:
              0,
          identidadVerificada:
              false,
          documentacionCompleta:
              false,
          nivelDocumentacion:
              0,
          cantidadEvidencias:
              0,
          nivelEvidencias:
              0,
          informacionProductivaCompleta:
              false,
          nivelProduccion:
              0,
          nivelInfraestructura:
              0,
          infraestructuraVerificada:
              false,
          cantidadInfraestructuras:
              0,
          nivelTecnologia:
              0,
          tecnologiaVerificada:
              false,
          cantidadTecnologias:
              0,
          nivelInversion:
              0,
          inversionDeclarada:
              false,
          inversionVerificada:
              false,
          montoInversionDeclarada:
              0,
          monedaInversion:
              'USD',
          participantesVerificados:
              false,
          nivelGobernanza:
              0,
          ultimaVerificacion:
              fecha,
          ultimaEvaluacion:
              fecha,
          observaciones:
              '',
        ),
        evaluacion:
            EvaluacionConfianza.inicial(),
        madurez: MadurezActivo(
          porcentaje:
              0,
          faltantes: [],
          etapa:
              '',
          nivelTecnologico:
              '',
          preparacionInversion:
              '',
        ),
        participantes: [],
        propietarioId:
            usuarioId,
        creadorId:
            usuarioId,
        publicadorId:
            usuarioId,
        tipoRelacionPropietario:
            'propietario',
        estado:
            EstadoActivo.borrador,
        estadoPublicacion:
            'borrador',
        visible:
            false,
        historial: [],
        hashActivo:
            'hash-economia-test-$sufijo',
        versionDatos:
            1,
        datos:
            null,
        fechaCreacion:
            fecha,
        ultimaActualizacion:
            fecha,
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
      // 2. CREAR EVIDENCIA ECONÓMICA
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId:
            '',
        activoAgroId:
            activoId,
        moduloOrigen:
            'economia',
        elementoTipo:
            'EconomiaActivo',
        elementoId:
            activoId,
        campoRelacionado:
            'valorSolicitado',
        tipo:
            'valoracion_economica',
        descripcion:
            'Evidencia económica del valor solicitado.',
        observaciones:
            'Evidencia creada para validar integración económica.',
        aportanteId:
            usuarioId,
        fuenteTipo:
            'propietario',
        fuenteNombre:
            'Declaración económica del activo de prueba',
        fuenteReferencia:
            'TEST-ECONOMIA-001',
        soporteTipo:
            'documento',
        soporteReferencia:
            'TEST-SOPORTE-ECONOMIA-001',
        soporteNombre:
            'Informe económico test',
        fechaHecho:
            fecha,
        fechaRegistro:
            fecha,
        estadoVerificacion:
            'informada',
        estadoValidez:
            'vigente_informado',
      );

      // =====================================================
      // 3. ACTUALIZAR ECONOMÍA + EVIDENCIA
      // =====================================================

      final economiaActualizada =
          EconomiaActivo(
        objetivoProyecto:
            'Expansión productiva',
        etapaProyecto:
            'expansion',
        inversionEsperada:
            300000,
        capacidadActual:
            '100 hectáreas',
        capacidadProyectada:
            '180 hectáreas',
        riesgosIdentificados:
            'Riesgo climático',
        origenInformacion:
            'propietario',
        responsableDeclaracion:
            usuarioId,
        valorSolicitado:
            1350000,
        moneda:
            'USD',
        tipoOperacion:
            'venta',
        capitalRequerido:
            300000,
        ingresosEstimados:
            '210000 USD anuales',
        costosEstimados:
            '100000 USD anuales',
        rentabilidadDeclarada:
            '11%',
        periodoEvaluacion:
            '5 años',
        datosEconomicos: {},
        fechaActualizacion:
            fecha,
      );

      await activoService.actualizarEconomia(
        activoId,
        economiaActualizada,
        evidencia:
            evidencia,
      );

      // =====================================================
      // 4. RECUPERAR ACTIVO
      // =====================================================

      final activoRecuperado =
          await activoService.obtenerActivoPorId(
        activoId,
      );

      expect(
        activoRecuperado,
        isNotNull,
      );

      // =====================================================
      // 5. VALIDAR ECONOMÍA
      // =====================================================

      expect(
        activoRecuperado!
            .economia
            .objetivoProyecto,
        equals(
            'Expansión productiva'),
      );

      expect(
        activoRecuperado
            .economia
            .etapaProyecto,
        equals('expansion'),
      );

      expect(
        activoRecuperado
            .economia
            .inversionEsperada,
        equals(300000),
      );

      expect(
        activoRecuperado
            .economia
            .valorSolicitado,
        equals(1350000),
      );

      expect(
        activoRecuperado
            .economia
            .capitalRequerido,
        equals(300000),
      );

      expect(
        activoRecuperado
            .economia
            .ingresosEstimados,
        equals(
            '210000 USD anuales'),
      );

      expect(
        activoRecuperado
            .economia
            .rentabilidadDeclarada,
        equals('11%'),
      );

      // =====================================================
      // 6. VERIFICAR EVIDENCIA EN FIRESTORE
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
        equals('economia'),
      );

      expect(
        evidenciaData['elementoTipo'],
        equals('EconomiaActivo'),
      );

      expect(
        evidenciaData['elementoId'],
        equals(activoId),
      );

      expect(
        evidenciaData['campoRelacionado'],
        equals('valorSolicitado'),
      );

      expect(
        evidenciaData['tipo'],
        equals('valoracion_economica'),
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
      // 7. VERIFICAR HISTORIAL
      // =====================================================

      final eventosEconomia =
          activoRecuperado.historial.where(
        (evento) =>
            evento.tipoEvento ==
            'actualizacion_economia',
      );

      expect(
        eventosEconomia,
        isNotEmpty,
      );

      expect(
        eventosEconomia.last.moduloOrigen,
        equals('economia'),
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
              data['modulo'] ==
                  'economia' &&
              data['accion'] ==
                  'actualizar_economia',
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