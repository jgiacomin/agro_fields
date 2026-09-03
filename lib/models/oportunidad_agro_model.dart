import 'package:cloud_firestore/cloud_firestore.dart';

class OportunidadAgro {
  // =====================================================
  // IDENTIDAD
  // =====================================================

  final String oportunidadId;
  final String creadorId;

  final String titulo;
  final String descripcion;

  final String actividad;
  final String productoServicio;

  // =====================================================
  // RELACIÓN CON ACTIVO AGRO
  // =====================================================

  /// Una oportunidad puede existir sin un Activo Agro.
  final String? activoId;

  // =====================================================
  // MERCADO
  // =====================================================

  /// Ejemplos conceptuales:
  /// demanda, oferta, inversion, servicio, proyecto, asociacion
  final String ladoMercado;

  /// Ejemplos:
  /// produccion_bajo_contrato, compra_produccion,
  /// venta_produccion, arrendamiento, etc.
  final String tipoOportunidad;

  // =====================================================
  // UBICACIÓN
  // =====================================================

  final String pais;
  final String provinciaEstado;
  final String localidad;
  final String ubicacionEspecifica;

  // =====================================================
  // NECESIDAD / CONDICIONES
  // =====================================================

  final String queSeNecesita;
  final String volumenRequerido;
  final String capacidadProductiva;
  final String periodicidad;
  final String plazo;
  final String condiciones;

  // =====================================================
  // REQUISITOS
  // =====================================================

  final List<String> requisitos;

  // =====================================================
  // PARTICIPANTES
  // =====================================================

  /// Referencias de participantes.
  /// La estructura evolucionará junto con el sistema
  /// de participantes y permisos de Agro Fields.
  final List<String> participantes;

  // =====================================================
  // INFORMACIÓN ECONÓMICA
  // =====================================================

  final double? montoObjetivo;
  final double? montoMinimo;

  final double? inversionEstimada;
  final double? costosEstimados;
  final double? produccionEstimada;
  final double? precioEstimado;
  final double? ingresosEstimados;
  final double? resultadoEstimado;

  final String moneda;
  final String periodoCalculo;
  final String fuenteEconomica;

  // =====================================================
  // DOCUMENTACIÓN / EVIDENCIAS
  // =====================================================

  final List<String> documentacion;
  final List<String> evidencias;

  // =====================================================
  // EVOLUCIÓN
  // =====================================================

  /// Ejemplos:
  /// borrador, publicada, en_evaluacion, activa,
  /// pausada, concretada, cerrada, cancelada
  final String estado;

  /// Nivel actual de confianza de la información.
  final double confianza;

  /// Nivel de avance de la oportunidad.
  final double madurez;

  // =====================================================
  // HISTORIAL
  // =====================================================

  /// Referencias/eventos de evolución de la oportunidad.
  final List<Map<String, dynamic>> historial;

  // =====================================================
  // FECHAS
  // =====================================================

  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  OportunidadAgro({
    required this.oportunidadId,
    required this.creadorId,
    required this.titulo,
    required this.descripcion,
    required this.actividad,
    required this.productoServicio,
    this.activoId,
    required this.ladoMercado,
    required this.tipoOportunidad,
    required this.pais,
    required this.provinciaEstado,
    required this.localidad,
    required this.ubicacionEspecifica,
    required this.queSeNecesita,
    required this.volumenRequerido,
    required this.capacidadProductiva,
    required this.periodicidad,
    required this.plazo,
    required this.condiciones,
    required this.requisitos,
    required this.participantes,
    this.montoObjetivo,
    this.montoMinimo,
    this.inversionEstimada,
    this.costosEstimados,
    this.produccionEstimada,
    this.precioEstimado,
    this.ingresosEstimados,
    this.resultadoEstimado,
    required this.moneda,
    required this.periodoCalculo,
    required this.fuenteEconomica,
    required this.documentacion,
    required this.evidencias,
    required this.estado,
    required this.confianza,
    required this.madurez,
    required this.historial,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  // =====================================================
  // FROM MAP
  // =====================================================

  factory OportunidadAgro.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return OportunidadAgro(
      oportunidadId: id,

      creadorId:
          map['creadorId'] ?? '',

      titulo:
          map['titulo'] ?? '',

      descripcion:
          map['descripcion'] ?? '',

      actividad:
          map['actividad'] ?? '',

      productoServicio:
          map['productoServicio'] ?? '',

      activoId:
          map['activoId'],

      ladoMercado:
          map['ladoMercado'] ?? 'demanda',

      tipoOportunidad:
          map['tipoOportunidad'] ??
              map['tipo'] ??
              'general',

      pais:
          map['pais'] ?? '',

      provinciaEstado:
          map['provinciaEstado'] ?? '',

      localidad:
          map['localidad'] ?? '',

      ubicacionEspecifica:
          map['ubicacionEspecifica'] ?? '',

      queSeNecesita:
          map['queSeNecesita'] ?? '',

      volumenRequerido:
          map['volumenRequerido'] ?? '',

      capacidadProductiva:
          map['capacidadProductiva'] ?? '',

      periodicidad:
          map['periodicidad'] ?? '',

      plazo:
          map['plazo'] ?? '',

      condiciones:
          map['condiciones'] ?? '',

      requisitos:
          List<String>.from(
            map['requisitos'] ?? [],
          ),

      participantes:
          List<String>.from(
            map['participantes'] ?? [],
          ),

      montoObjetivo:
          _leerDouble(
            map['montoObjetivo'],
          ),

      montoMinimo:
          _leerDouble(
            map['montoMinimo'],
          ),

      inversionEstimada:
          _leerDouble(
            map['inversionEstimada'],
          ),

      costosEstimados:
          _leerDouble(
            map['costosEstimados'],
          ),

      produccionEstimada:
          _leerDouble(
            map['produccionEstimada'],
          ),

      precioEstimado:
          _leerDouble(
            map['precioEstimado'],
          ),

      ingresosEstimados:
          _leerDouble(
            map['ingresosEstimados'],
          ),

      resultadoEstimado:
          _leerDouble(
            map['resultadoEstimado'],
          ),

      moneda:
          map['moneda'] ?? 'USD',

      periodoCalculo:
          map['periodoCalculo'] ?? '',

      fuenteEconomica:
          map['fuenteEconomica'] ?? '',

      documentacion:
          List<String>.from(
            map['documentacion'] ?? [],
          ),

      evidencias:
          List<String>.from(
            map['evidencias'] ?? [],
          ),

      estado:
          map['estado'] ?? 'borrador',

      confianza:
          _leerDouble(
            map['confianza'],
          ) ??
          0,

      madurez:
          _leerDouble(
            map['madurez'],
          ) ??
          0,

      historial:
          (map['historial'] ?? [])
              .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e),
              )
              .toList(),

      fechaCreacion:
          _leerFecha(
            map['fechaCreacion'],
          ),

      fechaActualizacion:
          _leerFecha(
            map['fechaActualizacion'],
          ),
    );
  }

  // =====================================================
  // LECTURA DE NÚMEROS
  // =====================================================

  static double? _leerDouble(
    dynamic valor,
  ) {
    if (valor == null) {
      return null;
    }

    if (valor is num) {
      return valor.toDouble();
    }

    if (valor is String) {
      return double.tryParse(valor);
    }

    return null;
  }

  // =====================================================
  // LECTURA DE FECHAS
  // =====================================================

  static DateTime _leerFecha(
    dynamic valor,
  ) {
    if (valor is Timestamp) {
      return valor.toDate();
    }

    if (valor is DateTime) {
      return valor;
    }

    if (valor is String) {
      return DateTime.tryParse(valor) ??
          DateTime.now();
    }

    return DateTime.now();
  }

  // =====================================================
  // TO MAP
  // =====================================================

  Map<String, dynamic> toMap() {
    return {
      'creadorId': creadorId,

      'titulo': titulo,
      'descripcion': descripcion,

      'actividad': actividad,
      'productoServicio': productoServicio,

      'activoId': activoId,

      'ladoMercado': ladoMercado,
      'tipoOportunidad': tipoOportunidad,

      'pais': pais,
      'provinciaEstado': provinciaEstado,
      'localidad': localidad,
      'ubicacionEspecifica': ubicacionEspecifica,

      'queSeNecesita': queSeNecesita,
      'volumenRequerido': volumenRequerido,
      'capacidadProductiva': capacidadProductiva,
      'periodicidad': periodicidad,
      'plazo': plazo,
      'condiciones': condiciones,

      'requisitos': requisitos,

      'participantes': participantes,

      'montoObjetivo': montoObjetivo,
      'montoMinimo': montoMinimo,

      'inversionEstimada': inversionEstimada,
      'costosEstimados': costosEstimados,
      'produccionEstimada': produccionEstimada,
      'precioEstimado': precioEstimado,
      'ingresosEstimados': ingresosEstimados,
      'resultadoEstimado': resultadoEstimado,

      'moneda': moneda,
      'periodoCalculo': periodoCalculo,
      'fuenteEconomica': fuenteEconomica,

      'documentacion': documentacion,
      'evidencias': evidencias,

      'estado': estado,

      'confianza': confianza,
      'madurez': madurez,

      'historial': historial,

      'fechaCreacion':
          Timestamp.fromDate(
        fechaCreacion,
      ),

      'fechaActualizacion':
          Timestamp.fromDate(
        fechaActualizacion,
      ),
    };
  }
}