import '../models/campo_model.dart';

import '../models/activos/activo_agro_model_v2.dart';
import '../models/activos/tipo_activo.dart';
import '../models/activos/estado_activo.dart';

import '../models/activos/ubicacion_activo_model.dart';
import '../models/activos/suelo_activo_model.dart';

import '../models/activos/confianza_activo_model.dart';
import '../models/activos/economia_activo_model.dart';
import '../models/activos/documentacion_activo_model.dart';
import '../models/activos/evaluacion_confianza_model.dart';
import '../models/activos/madurez_activo_model.dart';
import '../models/activos/historial_activo_model.dart';
import '../models/activos/participante_activo_model.dart';
import 'package:agro_fields/models/activos/factor_confianza_model.dart';

/// Convierte un Campo del sistema anterior (colección `campos`) en un
/// Activo Agro V2, conservando su identidad (mismo ID).
///
/// Regla (Concepto General §3.6 y §3.7): no se inventan datos. Lo que el
/// Campo no tenía queda vacío o como faltante, y el "verificado" del
/// sistema anterior NO cuenta como verificación (no tiene evidencia).
/// El Activo migrado nace PRIVADO (borrador): para volver al marketplace
/// el dueño lo publica de nuevo y pasa por revisión (paso 1).
class CampoToActivoService {

  /// Zona horaria según el país. Si no se conoce, queda vacía.
  static String zonaHorariaDe(String pais) {
    switch (pais.trim().toLowerCase()) {
      case 'argentina':
        return 'America/Argentina/Buenos_Aires';
      case 'paraguay':
        return 'America/Asuncion';
      default:
        return '';
    }
  }

  /// Moneda según el país. Si no se conoce, queda vacía.
  static String monedaDe(String pais) {
    switch (pais.trim().toLowerCase()) {
      case 'argentina':
        return 'ARS';
      case 'paraguay':
        return 'PYG';
      default:
        return '';
    }
  }

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

        tipoZona: '',

        zonaHoraria: zonaHorariaDe(campo.pais),

        accesoCaminos: '',

        descripcionEntorno: '',

        disponibilidadServicios: '',

        jurisdiccionLegal: '',

        regionProductiva: '',

        monedaLocal: monedaDe(campo.pais),
      ),

      // El Campo no tenía datos de producción: no se inventan.
      producciones: [],

      economia: EconomiaActivo(
        objetivoProyecto: '',

        etapaProyecto: 'inicial',

        inversionEsperada: 0,

        capacidadActual: '',

        capacidadProyectada: '',

        riesgosIdentificados: '',

        origenInformacion: 'sistema_anterior_campos',

        responsableDeclaracion: campo.propietarioId,

        valorSolicitado: 0,

        moneda: '',

        tipoOperacion: '',

        capitalRequerido: 0,

        ingresosEstimados: '',

        costosEstimados: '',

        rentabilidadDeclarada: '',

        periodoEvaluacion: '',

        datosEconomicos: [],

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
        nivelGeneral: 0,

        // =====================================================
        // IDENTIDAD
        // =====================================================
        identidadVerificada: false,

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

        monedaInversion: '',

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

        observaciones: campo.verificado
            ? 'Migrado desde Campos V1. Figuraba como verificado en el '
                'sistema anterior, sin evidencia: queda como dato declarado.'
            : 'Migrado desde Campos V1.',
      ),

      evaluacion: EvaluacionConfianza(
        nivelGeneral: 0,

        documental: FactorConfianza.inicial(),

        productivo: FactorConfianza.inicial(),

        economico: FactorConfianza.inicial(),

        legal: FactorConfianza.inicial(),

        profesional: FactorConfianza.inicial(),

        fortalezas: ['Campo registrado'],

        pendientes: [
          'Ubicación en el mapa',
          'Producción',
          'Documentación',
          'Verificación',
        ],

        resumen: 'Evaluación inicial',

        responsable: "Sistema",

        fechaEvaluacion: DateTime.now(),
      ),

      madurez: MadurezActivo(
        porcentaje: 10,

        // La latitud y longitud quedan en 0 porque el modelo de ubicación
        // todavía no admite "sin dato": se marca como faltante.
        faltantes: ['Ubicación en el mapa', 'Producción', 'Documentación'],

        etapa: 'inicial',

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

      tipoRelacionPropietario: campo.tipoRelacion,

      // Nace privado: se publica de nuevo con revisión (paso 1).
      estadoPublicacion: 'borrador',

      visible: false,

      versionDatos: ActivoAgroV2.modeloVersion,

      estado: EstadoActivo.borrador,

      historial: [
        HistorialActivo(
          eventoId: 'migracion_${campo.campoId}',

          tipoEvento: 'migracion_desde_campo',

          descripcion:
              'Activo generado desde campos/${campo.campoId} '
              '(sistema anterior), conservando su identidad',

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
