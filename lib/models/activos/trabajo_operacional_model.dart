import 'package:cloud_firestore/cloud_firestore.dart';

class TrabajoOperacional {
  static const String estadoPlanificado = 'PLANIFICADO';
  static const String estadoEnEjecucion = 'EN_EJECUCION';
  static const String estadoRealizado = 'REALIZADO';
  static const String estadoCancelado = 'CANCELADO';

  final String trabajoId;
  final String activoAgroId;
  final String? moduloProduccionId;
  final String? cicloId;

  final String familiaActividad;
  final String tipoActividad;
  final String descripcion;
  final String? objetivo;

  final DateTime fechaInicioPlanificada;
  final DateTime? fechaFinPlanificada;

  final String estadoTrabajo;

  final DateTime? fechaInicioReal;
  final DateTime? fechaFinReal;

  final String? responsableId;

  final String? objetoTipo;
  final String? objetoId;

  final double? cantidadAlcance;
  final String? unidadAlcance;

  final String? observaciones;

  final String creadoPor;
  final DateTime fechaCreacion;
  final DateTime ultimaActualizacion;

  TrabajoOperacional({
    required this.trabajoId,
    required this.activoAgroId,
    this.moduloProduccionId,
    this.cicloId,
    required this.familiaActividad,
    required this.tipoActividad,
    required this.descripcion,
    this.objetivo,
    required this.fechaInicioPlanificada,
    this.fechaFinPlanificada,
    required this.estadoTrabajo,
    this.fechaInicioReal,
    this.fechaFinReal,
    this.responsableId,
    this.objetoTipo,
    this.objetoId,
    this.cantidadAlcance,
    this.unidadAlcance,
    this.observaciones,
    required this.creadoPor,
    required this.fechaCreacion,
    required this.ultimaActualizacion,
  });

  factory TrabajoOperacional.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return TrabajoOperacional(
      trabajoId: id,
      activoAgroId: map['activoAgroId'] ?? '',
      moduloProduccionId: map['moduloProduccionId'],
      cicloId: map['cicloId'],
      familiaActividad: map['familiaActividad'] ?? '',
      tipoActividad: map['tipoActividad'] ?? '',
      descripcion: map['descripcion'] ?? '',
      objetivo: map['objetivo'],
      fechaInicioPlanificada:
          _leerFecha(map['fechaInicioPlanificada']) ?? DateTime.now(),
      fechaFinPlanificada:
          _leerFecha(map['fechaFinPlanificada']),
      estadoTrabajo:
          map['estadoTrabajo'] ?? estadoPlanificado,
      fechaInicioReal:
          _leerFecha(map['fechaInicioReal']),
      fechaFinReal:
          _leerFecha(map['fechaFinReal']),
      responsableId: map['responsableId'],
      objetoTipo: map['objetoTipo'],
      objetoId: map['objetoId'],
      cantidadAlcance:
          _leerDouble(map['cantidadAlcance']),
      unidadAlcance: map['unidadAlcance'],
      observaciones: map['observaciones'],
      creadoPor: map['creadoPor'] ?? '',
      fechaCreacion:
          _leerFecha(map['fechaCreacion']) ?? DateTime.now(),
      ultimaActualizacion:
          _leerFecha(map['ultimaActualizacion']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trabajoId': trabajoId,
      'activoAgroId': activoAgroId,
      'moduloProduccionId': moduloProduccionId,
      'cicloId': cicloId,
      'familiaActividad': familiaActividad,
      'tipoActividad': tipoActividad,
      'descripcion': descripcion,
      'objetivo': objetivo,
      'fechaInicioPlanificada':
          Timestamp.fromDate(fechaInicioPlanificada),
      'fechaFinPlanificada': fechaFinPlanificada != null
          ? Timestamp.fromDate(fechaFinPlanificada!)
          : null,
      'estadoTrabajo': estadoTrabajo,
      'fechaInicioReal': fechaInicioReal != null
          ? Timestamp.fromDate(fechaInicioReal!)
          : null,
      'fechaFinReal': fechaFinReal != null
          ? Timestamp.fromDate(fechaFinReal!)
          : null,
      'responsableId': responsableId,
      'objetoTipo': objetoTipo,
      'objetoId': objetoId,
      'cantidadAlcance': cantidadAlcance,
      'unidadAlcance': unidadAlcance,
      'observaciones': observaciones,
      'creadoPor': creadoPor,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'ultimaActualizacion':
          Timestamp.fromDate(ultimaActualizacion),
    };
  }

  TrabajoOperacional copyWith({
    String? trabajoId,
    String? activoAgroId,
    String? moduloProduccionId,
    String? cicloId,
    String? familiaActividad,
    String? tipoActividad,
    String? descripcion,
    String? objetivo,
    DateTime? fechaInicioPlanificada,
    DateTime? fechaFinPlanificada,
    String? estadoTrabajo,
    DateTime? fechaInicioReal,
    DateTime? fechaFinReal,
    String? responsableId,
    String? objetoTipo,
    String? objetoId,
    double? cantidadAlcance,
    String? unidadAlcance,
    String? observaciones,
    String? creadoPor,
    DateTime? fechaCreacion,
    DateTime? ultimaActualizacion,
  }) {
    return TrabajoOperacional(
      trabajoId: trabajoId ?? this.trabajoId,
      activoAgroId: activoAgroId ?? this.activoAgroId,
      moduloProduccionId:
          moduloProduccionId ?? this.moduloProduccionId,
      cicloId: cicloId ?? this.cicloId,
      familiaActividad:
          familiaActividad ?? this.familiaActividad,
      tipoActividad: tipoActividad ?? this.tipoActividad,
      descripcion: descripcion ?? this.descripcion,
      objetivo: objetivo ?? this.objetivo,
      fechaInicioPlanificada:
          fechaInicioPlanificada ?? this.fechaInicioPlanificada,
      fechaFinPlanificada:
          fechaFinPlanificada ?? this.fechaFinPlanificada,
      estadoTrabajo:
          estadoTrabajo ?? this.estadoTrabajo,
      fechaInicioReal:
          fechaInicioReal ?? this.fechaInicioReal,
      fechaFinReal:
          fechaFinReal ?? this.fechaFinReal,
      responsableId:
          responsableId ?? this.responsableId,
      objetoTipo: objetoTipo ?? this.objetoTipo,
      objetoId: objetoId ?? this.objetoId,
      cantidadAlcance:
          cantidadAlcance ?? this.cantidadAlcance,
      unidadAlcance:
          unidadAlcance ?? this.unidadAlcance,
      observaciones:
          observaciones ?? this.observaciones,
      creadoPor: creadoPor ?? this.creadoPor,
      fechaCreacion:
          fechaCreacion ?? this.fechaCreacion,
      ultimaActualizacion:
          ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor == null) return null;
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor);
    return null;
  }

  static double? _leerDouble(dynamic valor) {
    if (valor == null) return null;
    if (valor is num) return valor.toDouble();
    if (valor is String) return double.tryParse(valor);
    return null;
  }
}
