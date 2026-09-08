import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/ciclo_productivo_model.dart';
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
      'usuario_test_produccion_ciclo';

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
    'Validar Ciclo Productivo + Evidencia + Historial + Auditoría',
    (tester) async {
      final fecha = DateTime(2026, 9, 8);

      final sufijo =
          DateTime.now().millisecondsSinceEpoch.toString();

      const activoId =
          'activo-test-produccion-ciclo';

      const moduloProduccionId =
          'modulo-produccion-test-001';

      const cicloId =
          'ciclo-productivo-test-001';

      // =====================================================
      // 1. CREAR ACTIVO
      // =====================================================

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre:
            'Activo de prueba para Ciclo Productivo',
        descripcion:
            'Activo técnico para validar integración de producción y ciclo.',
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
            id: moduloProduccionId,
            activoAgroId: activoId,
            dominio: 'agricola',
            actividad:
                'produccion agricola',
            descripcion:
                'Producción agrícola de prueba.',
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
            'hash-produccion-ciclo-test-$sufijo',
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
      // 2. CREAR CICLO PRODUCTIVO
      // =====================================================

      final ciclo = CicloProductivo(
        cicloId: cicloId,
        activoAgroId: activoId,
        moduloProduccionId:
            moduloProduccionId,
        fechaInicio:
            DateTime(2026, 1, 1),
        fechaFin:
            DateTime(2026, 5, 30),
        campania: '2026',
        produccionObtenida: 3000,
        unidadProduccion: 'kg/ha',
        observaciones:
            'Ciclo productivo de prueba.',
      );

      // =====================================================
      // 3. CREAR EVIDENCIA
      // =====================================================

      final evidencia = Evidencia(
        evidenciaId: '',
        activoAgroId: activoId,
        moduloOrigen: 'produccion',
        elementoTipo: 'CicloProductivo',
        elementoId: cicloId,
        campoRelacionado:
            'produccionObtenida',
        tipo: 'registro_produccion',
        descripcion:
            'Evidencia del rendimiento productivo declarado.',
        observaciones:
            'Evidencia creada para validar integración.',
        aportanteId: usuarioId,
        fuenteTipo: 'productor',
        fuenteNombre:
            'Registro productivo de prueba',
        fuenteReferencia:
            'TEST-PRODUCCION-001',
        soporteTipo: 'documento',
        soporteReferencia:
            'TEST-SOPORTE-PRODUCCION-001',
        soporteNombre:
            'Registro de producción test',
        fechaHecho: fecha,
        fechaRegistro: fecha,
        estadoVerificacion:
            'informada',
        estadoValidez:
            'vigente_informado',
      );

      // =====================================================
      // 4. REGISTRAR CICLO + EVIDENCIA
      // =====================================================

      await activoService.registrarCicloProductivo(
        activoId,
        moduloProduccionId,
        ciclo,
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
      // 6. VALIDAR MÓDULO DE PRODUCCIÓN
      // =====================================================

      final moduloActualizado =
          activoActualizado!
              .producciones
              .firstWhere(
        (modulo) =>
            modulo.id ==
            moduloProduccionId,
      );

      expect(
        moduloActualizado.ciclos,
        isNotEmpty,
      );

      expect(
        moduloActualizado.ciclos.length,
        equals(1),
      );

      // =====================================================
      // 7. VALIDAR CICLO PRODUCTIVO
      // =====================================================

      final cicloRecuperado =
          moduloActualizado.ciclos.first;

      expect(
        cicloRecuperado.cicloId,
        equals(cicloId),
      );

      expect(
        cicloRecuperado.activoAgroId,
        equals(activoId),
      );

      expect(
        cicloRecuperado.moduloProduccionId,
        equals(moduloProduccionId),
      );

      expect(
        cicloRecuperado.campania,
        equals('2026'),
      );

      expect(
        cicloRecuperado.produccionObtenida,
        equals(3000),
      );

      expect(
        cicloRecuperado.unidadProduccion,
        equals('kg/ha'),
      );

      // =====================================================
      // 8. VERIFICAR EVIDENCIA EN FIRESTORE
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
        equals('produccion'),
      );

      expect(
        evidenciaData['elementoTipo'],
        equals('CicloProductivo'),
      );

      expect(
        evidenciaData['elementoId'],
        equals(cicloId),
      );

      expect(
        evidenciaData['campoRelacionado'],
        equals('produccionObtenida'),
      );

      expect(
        evidenciaData['tipo'],
        equals('registro_produccion'),
      );

      // =====================================================
      // 9. VERIFICAR HISTORIAL
      // =====================================================

      final eventosCiclo =
          activoActualizado.historial.where(
        (evento) =>
            evento.tipoEvento ==
            'registro_ciclo_productivo',
      );

      expect(
        eventosCiclo,
        isNotEmpty,
      );

      expect(
        eventosCiclo.last.moduloOrigen,
        equals('produccion'),
      );

      // =====================================================
      // 10. VERIFICAR AUDITORÍA
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
                  'produccion' &&
              data['accion'] ==
                  'registrar_ciclo_productivo',
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