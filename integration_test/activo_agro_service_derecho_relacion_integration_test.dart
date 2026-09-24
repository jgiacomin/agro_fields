import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/derecho_activo_model.dart';
import 'package:agro_fields/models/activos/relacion_juridica_model.dart';
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
    'GAP-RWA-02 02.02/02.05/02.06/02.07/02.08 - persiste y recupera relación jurídica, alcance, instrumento, vigencia y estado',
    (tester) async {
      final fechaInicio = DateTime(2026, 9, 16, 12, 0);
      final fechaFin = DateTime(2036, 9, 16, 12, 0);

      final sufijo =
          DateTime.now().microsecondsSinceEpoch.toString();

      final activoId =
          'activo-rwa02-relacion-$sufijo';

      final derechoId =
          'derecho-rwa02-relacion-$sufijo';

      final relacionId =
          'relacion-rwa02-relacion-$sufijo';

      final sujetoId =
          'sujeto-rwa02-relacion-$sufijo';

      final alcanceTerritorial = AlcanceTerritorial(
        tipoAlcance: 'parcial',
        descripcion:
            'Sector rural identificado para el derecho de prueba.',
        superficieAfectada: 75.5,
        unidadSuperficie: 'ha',
        referenciaGeografica:
            'Lote de prueba - referencia geográfica técnica',
      );

      final derecho = DerechoActivo(
        derechoId: derechoId,
        activoAgroId: activoId,
        tipoDerecho: 'uso',
        descripcionTipo: 'Derecho de uso de prueba',
        tipoObjeto: 'parte_activo',
        descripcionObjeto:
            'Sector determinado del Activo Agro de prueba.',
        alcanceTerritorial: alcanceTerritorial,
        tipoInstrumento: 'contrato',
        identificadorInstrumento:
            'TEST-RWA02-INSTRUMENTO-$sufijo',
        emisor: 'Entidad jurídica de prueba',
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estado: 'vigente',
        condiciones: const [
          'Uso conforme a las condiciones del instrumento.',
        ],
        fechaCreacion: fechaInicio,
        ultimaActualizacion: fechaInicio,
      );

      final relacion = RelacionJuridica(
        relacionId: relacionId,
        derechoId: derechoId,
        sujetoId: sujetoId,
        tipoSujeto: 'persona_juridica',
        rol: 'titular',
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estado: 'vigente',
        condiciones: const [
          'Relación jurídica vigente para el período de prueba.',
        ],
      );

      final activo = ActivoAgroV2(
        activoId: activoId,
        nombre: 'Activo de prueba para relación jurídica',
        descripcion:
            'Activo técnico para validar GAP-RWA-02 02.02, 02.05, 02.06, 02.07 y 02.08.',
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
        derechos: [
          derecho,
        ],
        relacionesJuridicas: [
          relacion,
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
          ultimaVerificacion: fechaInicio,
          ultimaEvaluacion: fechaInicio,
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
        propietarioId:
            'usuario-rwa02-relacion-$sufijo',
        creadorId:
            'usuario-rwa02-relacion-$sufijo',
        publicadorId:
            'usuario-rwa02-relacion-$sufijo',
        tipoRelacionPropietario: 'propietario',
        estado: EstadoActivo.borrador,
        estadoPublicacion: 'borrador',
        visible: false,
        historial: [],
        hashActivo:
            'hash-rwa02-relacion-$sufijo',
        versionDatos: 1,
        datos: null,
        fechaCreacion: fechaInicio,
        ultimaActualizacion: fechaInicio,
      );

      // 1. Validar representación antes de persistir.
      expect(
        activo.derechos,
        hasLength(1),
      );

      expect(
        activo.relacionesJuridicas,
        hasLength(1),
      );

      expect(
        activo.derechos.first.alcanceTerritorial,
        isNotNull,
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

      final relacionesFirestore =
          List<Map<String, dynamic>>.from(
        (datosFirestore['relacionesJuridicas'] ?? [])
            .map(
              (e) => Map<String, dynamic>.from(e),
            ),
      );

      expect(
        derechosFirestore,
        hasLength(1),
      );

      expect(
        relacionesFirestore,
        hasLength(1),
      );

      final derechoFirestore =
          derechosFirestore.first;

      final relacionFirestore =
          relacionesFirestore.first;

      // 4. Validar derecho, alcance, instrumento, vigencia y estado.
      expect(
        derechoFirestore['tipoDerecho'],
        'uso',
      );

      expect(
        derechoFirestore['tipoObjeto'],
        'parte_activo',
      );

      expect(
        derechoFirestore['tipoInstrumento'],
        'contrato',
      );

      expect(
        derechoFirestore['identificadorInstrumento'],
        'TEST-RWA02-INSTRUMENTO-$sufijo',
      );

      expect(
        derechoFirestore['emisor'],
        'Entidad jurídica de prueba',
      );

      expect(
        derechoFirestore['estado'],
        'vigente',
      );

      expect(
        derechoFirestore['fechaInicio'],
        isNotNull,
      );

      expect(
        derechoFirestore['fechaFin'],
        isNotNull,
      );

      final alcanceFirestore =
          Map<String, dynamic>.from(
        derechoFirestore['alcanceTerritorial'],
      );

      expect(
        alcanceFirestore['tipoAlcance'],
        'parcial',
      );

      expect(
        alcanceFirestore['descripcion'],
        'Sector rural identificado para el derecho de prueba.',
      );

      expect(
        alcanceFirestore['superficieAfectada'],
        75.5,
      );

      expect(
        alcanceFirestore['unidadSuperficie'],
        'ha',
      );

      expect(
        alcanceFirestore['referenciaGeografica'],
        'Lote de prueba - referencia geográfica técnica',
      );

      // 5. Validar relación jurídica.
      expect(
        relacionFirestore['relacionId'],
        relacionId,
      );

      expect(
        relacionFirestore['derechoId'],
        derechoId,
      );

      expect(
        relacionFirestore['sujetoId'],
        sujetoId,
      );

      expect(
        relacionFirestore['tipoSujeto'],
        'persona_juridica',
      );

      expect(
        relacionFirestore['rol'],
        'titular',
      );

      expect(
        relacionFirestore['estado'],
        'vigente',
      );

      expect(
        relacionFirestore['fechaInicio'],
        isNotNull,
      );

      expect(
        relacionFirestore['fechaFin'],
        isNotNull,
      );

      // 6. Recuperar mediante el Service.
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

      expect(
        activoRecuperado.relacionesJuridicas,
        hasLength(1),
      );

      // 7. Verificar reconstrucción de DerechoActivo.
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
        'uso',
      );

      expect(
        derechoRecuperado.tipoObjeto,
        'parte_activo',
      );

      expect(
        derechoRecuperado.tipoInstrumento,
        'contrato',
      );

      expect(
        derechoRecuperado.identificadorInstrumento,
        'TEST-RWA02-INSTRUMENTO-$sufijo',
      );

      expect(
        derechoRecuperado.emisor,
        'Entidad jurídica de prueba',
      );

      expect(
        derechoRecuperado.fechaInicio,
        fechaInicio,
      );

      expect(
        derechoRecuperado.fechaFin,
        fechaFin,
      );

      expect(
        derechoRecuperado.estado,
        'vigente',
      );

      expect(
        derechoRecuperado.alcanceTerritorial,
        isNotNull,
      );

      final alcanceRecuperado =
          derechoRecuperado.alcanceTerritorial!;

      expect(
        alcanceRecuperado.tipoAlcance,
        'parcial',
      );

      expect(
        alcanceRecuperado.descripcion,
        'Sector rural identificado para el derecho de prueba.',
      );

      expect(
        alcanceRecuperado.superficieAfectada,
        75.5,
      );

      expect(
        alcanceRecuperado.unidadSuperficie,
        'ha',
      );

      expect(
        alcanceRecuperado.referenciaGeografica,
        'Lote de prueba - referencia geográfica técnica',
      );

      // 8. Verificar reconstrucción de RelacionJuridica.
      final relacionRecuperada =
          activoRecuperado.relacionesJuridicas.first;

      expect(
        relacionRecuperada.relacionId,
        relacionId,
      );

      expect(
        relacionRecuperada.derechoId,
        derechoId,
      );

      expect(
        relacionRecuperada.sujetoId,
        sujetoId,
      );

      expect(
        relacionRecuperada.tipoSujeto,
        'persona_juridica',
      );

      expect(
        relacionRecuperada.rol,
        'titular',
      );

      expect(
        relacionRecuperada.fechaInicio,
        fechaInicio,
      );

      expect(
        relacionRecuperada.fechaFin,
        fechaFin,
      );

      expect(
        relacionRecuperada.estado,
        'vigente',
      );

      expect(
        relacionRecuperada.condiciones,
        contains(
          'Relación jurídica vigente para el período de prueba.',
        ),
      );
    },
  );
}