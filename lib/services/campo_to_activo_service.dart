import '../models/campo_model.dart';

import '../models/activos/activo_agro_model_v2.dart';
import '../models/activos/tipo_activo.dart';
import '../models/activos/estado_activo.dart';

import '../models/activos/ubicacion_activo_model.dart';
import '../models/activos/modulo_produccion_model.dart';
import '../models/activos/suelo_activo_model.dart';


import '../models/activos/confianza_activo_model.dart';
import '../models/activos/economia_activo_model.dart';
import '../models/activos/documentacion_activo_model.dart';
import '../models/activos/evaluacion_confianza_model.dart';
import '../models/activos/madurez_activo_model.dart';
import '../models/activos/historial_activo_model.dart';
import '../models/activos/participante_activo_model.dart';
import 'package:agro_fields/models/activos/factor_confianza_model.dart';

class CampoToActivoService {
  ActivoAgroV2 convertir(Campo campo) {
    return ActivoAgroV2(
      activoId: campo.campoId,

      nombre: campo.nombre,

      descripcion: campo.descripcion,

      tipoActivo: TipoActivo.otro,

      categorias: ['campo', 'agropecuario'],

      ubicacion: UbicacionActivo(
        pais: campo.pais,

        provincia: campo.provincia,

        departamento: campo.departamento,

        localidad: campo.localidad,

        codigoPostal: campo.codigoPostal,

        latitud: 0,

        longitud: 0,

        superficie: campo.hectareas,

        tipoZona: 'rural',

        zonaHoraria: 'America/Argentina/Buenos_Aires',

        accesoCaminos: '',

        descripcionEntorno: '',

        disponibilidadServicios: '',

        jurisdiccionLegal: '',

        regionProductiva: campo.provincia,

        monedaLocal: 'ARS',
      ),

      producciones: [
        ModuloProduccion(
          dominio: 'agropecuario',

          actividad: 'agricultura',

          descripcion: 'Producción inicial',

          superficie: campo.hectareas,

          unidad: 'hectáreas',

          datos: {
            'capacidadProductiva': '',

            'infraestructura': [],

            'equipamiento': [],
          },
           ciclos: [],
        ),
      ],

      economia: EconomiaActivo(
        objetivoProyecto: '',

        etapaProyecto: 'inicial',

        inversionEsperada: 0,

        capacidadActual: '',

        capacidadProyectada: '',

        riesgosIdentificados: '',

        origenInformacion: 'productor',

        responsableDeclaracion: campo.propietarioId,

        valorSolicitado: 0,

        moneda: 'USD',

        tipoOperacion: '',

        capitalRequerido: 0,

        ingresosEstimados: '',

        costosEstimados: '',

        rentabilidadDeclarada: '',

        periodoEvaluacion: '',

        datosEconomicos: {},

        fechaActualizacion: DateTime.now(),
      ),

      documentacion: DocumentacionActivo(
        documentacionCompleta: false,

        documentos: [],

        certificaciones: [],

        permisos: [],

        archivos: [],

        observaciones: '',

        fechaActualizacion: DateTime.now(),
      ),

      suelo: SueloActivo.inicial(),

      confianza: ConfianzaActivo(
        nivelGeneral: campo.verificado ? 50 : 0,

        // =====================================================
        // IDENTIDAD
        // =====================================================
        identidadVerificada: campo.verificado,

        // =====================================================
        // DOCUMENTACIÓN
        // =====================================================
        documentacionCompleta: false,

        nivelDocumentacion: 0,

        // =====================================================
        // EVIDENCIAS
        // =====================================================
        cantidadEvidencias: 0,

        nivelEvidencias: 0,

        // =====================================================
        // PRODUCCIÓN
        // =====================================================
        informacionProductivaCompleta: false,

        nivelProduccion: 0,

        // =====================================================
        // INFRAESTRUCTURA
        // =====================================================
        nivelInfraestructura: 0,

        infraestructuraVerificada: false,

        cantidadInfraestructuras: 0,

        // =====================================================
        // TECNOLOGÍA
        // =====================================================
        nivelTecnologia: 0,

        tecnologiaVerificada: false,

        cantidadTecnologias: 0,

        // =====================================================
        // INVERSIÓN
        // =====================================================
        nivelInversion: 0,

        inversionDeclarada: false,

        inversionVerificada: false,

        montoInversionDeclarada: 0,

        monedaInversion: 'USD',

        // =====================================================
        // PARTICIPANTES
        // =====================================================
        participantesVerificados: false,

        // =====================================================
        // GOBERNANZA
        // =====================================================
        nivelGobernanza: 0,

        // =====================================================
        // CONTROL
        // =====================================================
        ultimaVerificacion: DateTime.now(),

        ultimaEvaluacion: DateTime.now(),

        observaciones: '',
      ),

      evaluacion: EvaluacionConfianza(
        nivelGeneral: campo.verificado ? 50 : 0,

        documental: FactorConfianza.inicial(),

        productivo: FactorConfianza.inicial(),

        economico: FactorConfianza.inicial(),

        legal: FactorConfianza.inicial(),

        profesional: FactorConfianza.inicial(),

        fortalezas: ['Campo registrado'],

        pendientes: ['Documentación', 'Verificación'],

        resumen: 'Evaluación inicial',

        responsable: "Sistema",

        fechaEvaluacion: DateTime.now(),
      ),

      madurez: MadurezActivo(
        porcentaje: campo.verificado ? 50 : 10,

        faltantes: ['Documentación'],

        etapa: campo.verificado ? 'validado' : 'inicial',

        nivelTecnologico: 'bajo',

        preparacionInversion: 'inicial',
      ),

      participantes: [
        ParticipanteActivo(
          usuarioId: campo.propietarioId,

          rol: 'propietario',

          estado: 'activo',

          fechaIngreso: campo.fechaCreacion,
        ),
      ],

      propietarioId: campo.propietarioId,

      creadorId: campo.publicadorId,

      publicadorId: campo.publicadorId,

      tipoRelacionPropietario: 'propietario',

      estadoPublicacion: campo.estadoPublicacion,

      visible: campo.estadoPublicacion == 'publicado',

      versionDatos: ActivoAgroV2.modeloVersion,

      estado: campo.estadoPublicacion == 'publicado'
          ? EstadoActivo.publicado
          : EstadoActivo.borrador,

      historial: [
        HistorialActivo(
          eventoId: 'creacion_${campo.campoId}',

          tipoEvento: 'creacion',

          descripcion: 'Activo generado desde Campo',

          usuarioId: campo.publicadorId,

          moduloOrigen: 'campo',

          fecha: campo.fechaCreacion,
        ),
      ],

      hashActivo: campo.hashCampo,

      fechaCreacion: campo.fechaCreacion,

      ultimaActualizacion: DateTime.now(),
    );
  }
}
