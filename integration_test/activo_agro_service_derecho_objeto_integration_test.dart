import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/derecho_activo_model.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late ActivoAgroServiceV2 activoService;

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
    'GAP-RWA-02 02.04 - persiste y recupera Objeto del Derecho',
    (tester) async {
      final fecha = DateTime(2026, 9, 16, 12, 0);

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-rwa02-0204-$sufijo';

      final derechoId =
          'derecho-rwa02-0204-$sufijo';

      const tipoDerechoEsperado =
          'dominio';

      final derecho = DerechoActivo(
        derechoId: derechoId,
        activoAgroId: activoId,
        tipoDerecho: tipoDerechoEsperado,
        descripcionTipo: 'Derecho de dominio',
        tipoObjeto: 'activo_completo',
        descripcionObjeto:
            'Derecho sobre activo agro de prueba.',
        alcanceTerritorial: null,
        tipoInstrumento: 'titulo',
        identificadorInstrumento:
            'TEST-RWA02-0204-$sufijo',
        emisor: 'Entidad de prueba',
        fechaInicio: fecha,
        fechaFin: null,
        estado: 'vigente',
        condiciones: const [],
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre: 'Activo de prueba para Objeto del Derecho',
        descripcion:
            'Activo tÃ©cnico para validar GAP-RWA-02 02.04.',
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
          descripcionEntorno: 'Prueba tÃ©cnica',
          accesoCaminos: 'camino rural',
          disponibilidadServicios: '',
          jurisdiccionLegal: 'Argentina',
          zonaHoraria:
              'America/Argentina/Buenos_Aires',
          monedaLocal: 'ARS',
        ),
        suelo: SueloActivo.inicial(),
        derechos: [
          derecho,
        ],
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
        evaluacion: EvaluacionConfianza.inicial(),
        madurez: MadurezActivo(
          porcentaje: 0,
          faltantes: [],
          etapa: '',
          nivelTecnologico: '',
          preparacionInversion: '',
        ),
        participantes: [],
        propietarioId: 'usuario-rwa02-0204-$sufijo',
        creadorId: 'usuario-rwa02-0204-$sufijo',
        publicadorId: 'usuario-rwa02-0204-$sufijo',
        tipoRelacionPropietario: 'propietario',
        estado: EstadoActivo.borrador,
        estadoPublicacion: 'borrador',
        visible: false,
        historial: [],
        hashActivo:
            'hash-rwa02-0204-$sufijo',
        versionDatos: 1,
        datos: null,
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );

      // 1. Validar representaciÃ³n antes de persistir.
      expect(
        activo.derechos,
        hasLength(1),
      );

      expect(
        activo.derechos.first.tipoDerecho,
        tipoDerechoEsperado,
      );
           const tipoObjetoEsperado = 'activo_completo';

const descripcionObjetoEsperada =
    'Derecho sobre activo agro de prueba.';

expect(
  activo.derechos.first.tipoObjeto,
  tipoObjetoEsperado,
);

expect(
  activo.derechos.first.descripcionObjeto,
  descripcionObjetoEsperada,
);
      // 2. Crear Activo Agro.
      final activoCreado =
          await activoService.crearActivo(activo);

      expect(
        activoCreado,
        isNotNull,
      );

      // 3. Verificar persistencia directa en Firestore.
      final snapshot = await firestore
          .collection('activos_agro')
          .doc(activoId)
          .get();

      expect(
        snapshot.exists,
        isTrue,
      );

      final datosFirestore =
          snapshot.data()!;

      final derechosFirestore =
          List<Map<String, dynamic>>.from(
        (datosFirestore['derechos'] ?? [])
            .map(
              (e) => Map<String, dynamic>.from(e),
            ),
      );

      expect(
        derechosFirestore,
        hasLength(1),
      );

      expect(
        derechosFirestore.first['tipoDerecho'],
        tipoDerechoEsperado,
      );
     expect(
  derechosFirestore.first['tipoObjeto'],
  tipoObjetoEsperado,
);

expect(
  derechosFirestore.first['descripcionObjeto'],
  descripcionObjetoEsperada,
);
      // 4. Recuperar mediante el Service.
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

      // 5. Verificar reconstrucciÃ³n de DerechoActivo.
      final derechoRecuperado =
          activoRecuperado.derechos.first;

      expect(
        derechoRecuperado.derechoId,
        derechoId,
      );

      expect(
        derechoRecuperado.activoAgroId,
        activoId,
      );

      expect(
        derechoRecuperado.tipoDerecho,
        tipoDerechoEsperado,
      );

      expect(
        derechoRecuperado.descripcionTipo,
        'Derecho de dominio',
      );
      expect(
  derechoRecuperado.tipoObjeto,
  tipoObjetoEsperado,
);

expect(
  derechoRecuperado.descripcionObjeto,
  descripcionObjetoEsperada,
);
    },
  );
}
