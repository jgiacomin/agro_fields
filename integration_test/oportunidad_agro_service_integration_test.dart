import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/firebase_options.dart';

import 'package:agro_fields/models/oportunidad_agro_model.dart';
import 'package:agro_fields/services/oportunidad_agro_service.dart';

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
    'Paso 9 - integra ActivoAgroV2, OportunidadAgro, consultas y auditoria',
    (tester) async {
      final activoService = ActivoAgroServiceV2();
      final oportunidadService = OportunidadAgroService();
      final auditService = AuditService();

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId = 'activo-op-emulator-$sufijo';
      final oportunidadId = 'op-linked-emulator-$sufijo';
      final oportunidadInvalidaId =
          'op-invalid-emulator-$sufijo';

      const usuarioId = 'usuario-test-001';

      final fecha = DateTime(2026, 9, 3, 10, 0);

      // =========================================================
      // 1. CREAR ACTIVO AGRO V2
      // =========================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre: 'Activo de prueba para OportunidadAgro',
        descripcion:
            'Activo técnico para validar integración con Firestore Emulator.',
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
          zonaHoraria: 'America/Argentina/Buenos_Aires',
          monedaLocal: 'ARS',
        ),
        suelo: SueloActivo.inicial(),
        producciones: [
          ModuloProduccion(
            dominio: 'agricola',
            actividad: 'produccion agricola',
            descripcion:
                'Produccion de prueba para integracion.',
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
        hashActivo: 'hash-op-emulator-$sufijo',
        versionDatos: 1,
        datos: null,
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      final activoCreado =
          await activoService.crearActivo(activo);

      expect(activoCreado, activoId);

      // =========================================================
      // 2. VERIFICAR QUE EL ACTIVO EXISTE
      // =========================================================

      final activoRecuperado =
          await activoService.obtenerActivoPorId(activoId);

      expect(activoRecuperado, isNotNull);
      expect(activoRecuperado!.activoId, activoId);
      expect(
        activoRecuperado.nombre,
        'Activo de prueba para OportunidadAgro',
      );

      // =========================================================
      // 3. CREAR OPORTUNIDAD VINCULADA AL ACTIVO
      // =========================================================

      final oportunidad = OportunidadAgro(
        oportunidadId: oportunidadId,
        creadorId: usuarioId,
        titulo: 'Oportunidad vinculada a ActivoAgro',
        descripcion:
            'Prueba de vinculacion ActivoAgroV2 + OportunidadAgro.',
        actividad: 'agricultura',
        productoServicio: 'produccion agricola',
        activoId: activoId,
        ladoMercado: 'demanda',
        tipoOportunidad: 'produccion_bajo_contrato',
        pais: 'Argentina',
        provinciaEstado: 'Buenos Aires',
        localidad: 'La Plata',
        ubicacionEspecifica: '',
        queSeNecesita: 'Produccion agricola',
        volumenRequerido: '100 toneladas',
        capacidadProductiva: '100 toneladas',
        periodicidad: 'anual',
        plazo: '12 meses',
        condiciones: 'Prueba tecnica',
        requisitos: ['Produccion'],
        participantes: [usuarioId],
        montoObjetivo: null,
        montoMinimo: null,
        inversionEstimada: null,
        costosEstimados: null,
        produccionEstimada: 100,
        precioEstimado: null,
        ingresosEstimados: null,
        resultadoEstimado: null,
        moneda: 'USD',
        periodoCalculo: 'anual',
        fuenteEconomica: 'prueba',
        documentacion: [],
        evidencias: [],
        estado: 'activa',
        confianza: 0,
        madurez: 0,
        historial: [],
        fechaCreacion: fecha,
        fechaActualizacion: fecha,
      );

      final idOportunidadCreada =
          await oportunidadService.crearOportunidad(
        oportunidad,
      );

      expect(idOportunidadCreada, oportunidadId);

      // =========================================================
      // 4. RECUPERAR OPORTUNIDAD
      // =========================================================

      final oportunidadRecuperada =
          await oportunidadService.obtenerOportunidadPorId(
        oportunidadId,
      );

      expect(oportunidadRecuperada, isNotNull);
      expect(
        oportunidadRecuperada!.oportunidadId,
        oportunidadId,
      );
      expect(
        oportunidadRecuperada.titulo,
        'Oportunidad vinculada a ActivoAgro',
      );
      expect(
        oportunidadRecuperada.estado,
        'activa',
      );
      expect(
        oportunidadRecuperada.activoId,
        activoId,
      );

      // =========================================================
      // 5. CONSULTAR OPORTUNIDADES POR ACTIVO
      // =========================================================

      final oportunidadesDelActivo =
          await oportunidadService.obtenerOportunidadesPorActivo(
        activoId,
      );

      expect(oportunidadesDelActivo, isNotEmpty);

      final encontradaPorActivo =
          oportunidadesDelActivo.any(
        (item) => item.oportunidadId == oportunidadId,
      );

      expect(encontradaPorActivo, isTrue);

      // =========================================================
      // 6. CONSULTAR OPORTUNIDADES ACTIVAS
      // =========================================================

      final oportunidadesActivas =
          await oportunidadService.obtenerOportunidadesActivas();

      expect(oportunidadesActivas, isNotEmpty);

      final encontradaEntreActivas =
          oportunidadesActivas.any(
        (item) => item.oportunidadId == oportunidadId,
      );

      expect(encontradaEntreActivas, isTrue);

      // =========================================================
      // 7. VERIFICAR AUDITORIA DEL ACTIVO
      // =========================================================

      final auditoria =
          await auditService.obtenerPorActivo(activoId);

      expect(auditoria, isNotEmpty);

      final auditoriaOportunidad =
          auditoria.where(
        (evento) =>
            evento.modulo == 'oportunidad' &&
            evento.accion == 'crear_oportunidad' &&
            evento.elementoAfectado == oportunidadId,
      );

      expect(auditoriaOportunidad, isNotEmpty);

      final eventoOportunidad =
          auditoriaOportunidad.first;

      expect(eventoOportunidad.usuarioId, usuarioId);
      expect(eventoOportunidad.referencia, oportunidadId);

      // =========================================================
      // 8. CASO NEGATIVO:
      //    NO PERMITIR OPORTUNIDAD CON ACTIVO INEXISTENTE
      // =========================================================

      final oportunidadInvalida = OportunidadAgro(
        oportunidadId: oportunidadInvalidaId,
        creadorId: usuarioId,
        titulo: 'Oportunidad invalida',
        descripcion:
            'Debe ser rechazada porque el activo no existe.',
        actividad: 'agricultura',
        productoServicio: 'produccion agricola',
        activoId: 'activo-que-no-existe-$sufijo',
        ladoMercado: 'demanda',
        tipoOportunidad: 'produccion_bajo_contrato',
        pais: 'Argentina',
        provinciaEstado: 'Buenos Aires',
        localidad: 'La Plata',
        ubicacionEspecifica: '',
        queSeNecesita: 'Produccion agricola',
        volumenRequerido: '10 toneladas',
        capacidadProductiva: '',
        periodicidad: 'anual',
        plazo: '12 meses',
        condiciones: 'Prueba negativa',
        requisitos: [],
        participantes: [usuarioId],
        montoObjetivo: null,
        montoMinimo: null,
        inversionEstimada: null,
        costosEstimados: null,
        produccionEstimada: null,
        precioEstimado: null,
        ingresosEstimados: null,
        resultadoEstimado: null,
        moneda: 'USD',
        periodoCalculo: 'anual',
        fuenteEconomica: 'prueba',
        documentacion: [],
        evidencias: [],
        estado: 'activa',
        confianza: 0,
        madurez: 0,
        historial: [],
        fechaCreacion: fecha,
        fechaActualizacion: fecha,
      );

      await expectLater(
        oportunidadService.crearOportunidad(
          oportunidadInvalida,
        ),
        throwsA(isA<Exception>()),
      );
    },
  );
}

