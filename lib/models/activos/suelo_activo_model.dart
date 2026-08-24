import 'package:cloud_firestore/cloud_firestore.dart';

class SueloActivo {
  final String estado;

  final String? textura;
  final String? drenaje;

  final double? ph;
  final double? materiaOrganica;

  final List<String> evidencias;

  final String? observaciones;

  final DateTime? fechaEvaluacion;

  SueloActivo({
    required this.estado,
    this.textura,
    this.drenaje,
    this.ph,
    this.materiaOrganica,
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
