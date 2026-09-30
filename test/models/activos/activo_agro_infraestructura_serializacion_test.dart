import 'package:flutter_test/flutter_test.dart';

import '../../../lib/models/activos/activo_agro_model_v2.dart';
import '../../../lib/models/activos/factor_confianza_model.dart';
import '../../../lib/models/activos/confianza_activo_model.dart';
import '../../../lib/models/activos/documentacion_activo_model.dart';
import '../../../lib/models/activos/economia_activo_model.dart';
import '../../../lib/models/activos/evaluacion_confianza_model.dart';
import '../../../lib/models/activos/estado_activo.dart';
import '../../../lib/models/activos/historial_activo_model.dart';
import '../../../lib/models/activos/infraestructura_activo_model.dart';
import '../../../lib/models/activos/madurez_activo_model.dart';
import '../../../lib/models/activos/modulo_produccion_model.dart';
import '../../../lib/models/activos/participante_activo_model.dart';
import '../../../lib/models/activos/suelo_activo_model.dart';
import '../../../lib/models/activos/tipo_activo.dart';
import '../../../lib/models/activos/ubicacion_activo_model.dart';

void main() {
  final fecha = DateTime(2026, 9, 25);
  final factor = FactorConfianza(
  nivel: 0,
  descripcion: '',
  evidencias: const [],
  fechaActualizacion: fecha,
   );

  test('serializa y recupera infraestructura de ActivoAgroV2', () {
    final infraestructura = InfraestructuraActivo(
      infraestructuraId: 'infra-001',
      tipo: 'galpon',
      nombre: 'Galpón principal',
      descripcion: 'Galpón destinado al almacenamiento',
      cantidad: 1,
      estado: 'declarado',
    );

    final activo = ActivoAgroV2(
      activoId: 'activo_001',
      nombre: 'Activo de prueba infraestructura',
      descripcion: 'Activo utilizado para prueba de infraestructura',
      tipoActivo: TipoActivo.otro,
      categorias: const ['prueba'],
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
        jurisdiccionLegal: '',
        regionProductiva: '',
        monedaLocal: 'USD',
      ),
      producciones: const <ModuloProduccion>[],
      infraestructura: [infraestructura],
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
      madurez: MadurezActivo(
        porcentaje: 0,
        faltantes: const [],
        etapa: '',
        nivelTecnologico: '',
        preparacionInversion: '',
      ),
      suelo: SueloActivo.inicial(),
      participantes: const <ParticipanteActivo>[],
      derechos: const [],
      propietarioId: 'usuario_001',
      creadorId: 'usuario_001',
      publicadorId: 'usuario_001',
      tipoRelacionPropietario: 'propietario',
      estado: EstadoActivo.borrador,
      estadoPublicacion: 'borrador',
      visible: false,
      historial: const <HistorialActivo>[],
      hashActivo: 'hash-infra-01',
      versionDatos: 1,
      fechaCreacion: fecha,
      ultimaActualizacion: fecha,
    );

    final map = activo.toMap();

    expect(map['infraestructura'], isA<List>());
    expect(map['infraestructura'], hasLength(1));

    final recuperado = ActivoAgroV2.fromMap(
      map,
      'activo_001',
    );

    expect(recuperado.infraestructura, hasLength(1));

    final infraestructuraRecuperada =
        recuperado.infraestructura.first;

    expect(
      infraestructuraRecuperada.infraestructuraId,
      'infra-001',
    );
    expect(infraestructuraRecuperada.tipo, 'galpon');
    expect(infraestructuraRecuperada.nombre, 'Galpón principal');
    expect(
      infraestructuraRecuperada.descripcion,
      'Galpón destinado al almacenamiento',
    );
    expect(infraestructuraRecuperada.cantidad, 1);
    expect(infraestructuraRecuperada.estado, 'declarado');
    expect(infraestructuraRecuperada.moduloProduccionId, isNull);
  });
}