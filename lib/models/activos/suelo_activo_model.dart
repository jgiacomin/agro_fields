import 'package:cloud_firestore/cloud_firestore.dart';

class SueloActivo {
  final String estado;

  final String? textura;
  final String? drenaje;

  final double? ph;
  final double? materiaOrganica;

  // Clasificación técnica del suelo
  final String? sistemaClasificacion;
  final String? clase;
  final String? subclase;
  final String? unidadTipo;
  final String? descripcionClasificacion;

  // Propiedades y limitaciones del suelo
  final String? profundidad;
  final String? salinidad;
  final String? fertilidad;
  final String? nutrientes;
  final String? pedregosidad;
  final String? retencionAgua;
  final String? erosion;
  final String? limitaciones;

  final List<String> evidencias;

  final String? observaciones;

  final DateTime? fechaEvaluacion;

  SueloActivo({
    required this.estado,
    this.textura,
    this.drenaje,
    this.ph,
    this.materiaOrganica,
    this.sistemaClasificacion,
    this.clase,
    this.subclase,
    this.unidadTipo,
    this.descripcionClasificacion,
    this.profundidad,
    this.salinidad,
    this.fertilidad,
    this.nutrientes,
    this.pedregosidad,
    this.retencionAgua,
    this.erosion,
    this.limitaciones,
    required this.evidencias,

    this.observaciones,
    this.fechaEvaluacion,
  });

  factory SueloActivo.inicial() {
    return SueloActivo(estado: 'sin_evaluar', evidencias: []);
  }

  factory SueloActivo.fromMap(Map<String, dynamic> map) {
    return SueloActivo(
      estado: map['estado'] ?? 'sin_evaluar',
      textura: map['textura'],
      drenaje: map['drenaje'],
      ph: (map['ph'] as num?)?.toDouble(),
      materiaOrganica: (map['materiaOrganica'] as num?)?.toDouble(),
      sistemaClasificacion: map['sistemaClasificacion'],
      clase: map['clase'],
      subclase: map['subclase'],
      unidadTipo: map['unidadTipo'],
      descripcionClasificacion: map['descripcionClasificacion'],
      profundidad: map['profundidad'],
      salinidad: map['salinidad'],
      fertilidad: map['fertilidad'],
      nutrientes: map['nutrientes'],
      pedregosidad: map['pedregosidad'],
      retencionAgua: map['retencionAgua'],
      erosion: map['erosion'],
      limitaciones: map['limitaciones'],
      evidencias: List<String>.from(map['evidencias'] ?? []),
      observaciones: map['observaciones'],
      fechaEvaluacion: _leerFecha(map['fechaEvaluacion']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'estado': estado,
      'textura': textura,
      'drenaje': drenaje,
      'ph': ph,
      'materiaOrganica': materiaOrganica,
      'sistemaClasificacion': sistemaClasificacion,
      'clase': clase,
      'subclase': subclase,
      'unidadTipo': unidadTipo,
      'descripcionClasificacion': descripcionClasificacion,
      'profundidad': profundidad,
      'salinidad': salinidad,
      'fertilidad': fertilidad,
      'nutrientes': nutrientes,
      'pedregosidad': pedregosidad,
      'retencionAgua': retencionAgua,
      'erosion': erosion,
      'limitaciones': limitaciones,
      'evidencias': evidencias,
      'observaciones': observaciones,
      'fechaEvaluacion': fechaEvaluacion != null
          ? Timestamp.fromDate(fechaEvaluacion!)
          : null,
    };
  }

  SueloActivo copyWith({
    String? estado,
    String? textura,
    String? drenaje,
    double? ph,
    double? materiaOrganica,
    String? sistemaClasificacion,
    String? clase,
    String? subclase,
    String? unidadTipo,
    String? descripcionClasificacion,
    String? profundidad,
    String? salinidad,
    String? fertilidad,
    String? nutrientes,
    String? pedregosidad,
    String? retencionAgua,
    String? erosion,
    String? limitaciones,
    List<String>? evidencias,
    String? observaciones,
    DateTime? fechaEvaluacion,
  }) {
    return SueloActivo(
      estado: estado ?? this.estado,
      textura: textura ?? this.textura,
      drenaje: drenaje ?? this.drenaje,
      ph: ph ?? this.ph,
      materiaOrganica: materiaOrganica ?? this.materiaOrganica,
      sistemaClasificacion: sistemaClasificacion ?? this.sistemaClasificacion,
      clase: clase ?? this.clase,
      subclase: subclase ?? this.subclase,
      unidadTipo: unidadTipo ?? this.unidadTipo,
      descripcionClasificacion:
          descripcionClasificacion ?? this.descripcionClasificacion,
      profundidad: profundidad ?? this.profundidad,
      salinidad: salinidad ?? this.salinidad,
      fertilidad: fertilidad ?? this.fertilidad,
      nutrientes: nutrientes ?? this.nutrientes,
      pedregosidad: pedregosidad ?? this.pedregosidad,
      retencionAgua: retencionAgua ?? this.retencionAgua,
      erosion: erosion ?? this.erosion,
      limitaciones: limitaciones ?? this.limitaciones,
      evidencias: evidencias ?? this.evidencias,
      observaciones: observaciones ?? this.observaciones,
      fechaEvaluacion: fechaEvaluacion ?? this.fechaEvaluacion,
    );
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }

    if (valor is DateTime) {
      return valor;
    }

    if (valor is String) {
      return DateTime.tryParse(valor);
    }

    return null;
  }
}
