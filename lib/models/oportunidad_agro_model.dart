import 'package:cloud_firestore/cloud_firestore.dart';

class OportunidadAgro {
  final String oportunidadId;
  final String activoId;
  final String creadorId;

  final String titulo;
  final String descripcion;
  final String tipo;

  final double? montoObjetivo;
  final double? montoMinimo;

  final String estado;

  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  OportunidadAgro({
    required this.oportunidadId,
    required this.activoId,
    required this.creadorId,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    this.montoObjetivo,
    this.montoMinimo,
    required this.estado,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory OportunidadAgro.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return OportunidadAgro(
      oportunidadId: id,
      activoId: map['activoId'] ?? '',
      creadorId: map['creadorId'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      tipo: map['tipo'] ?? 'inversion',
      montoObjetivo: _leerDouble(map['montoObjetivo']),
      montoMinimo: _leerDouble(map['montoMinimo']),
      estado: map['estado'] ?? 'borrador',
      fechaCreacion: _leerFecha(map['fechaCreacion']),
      fechaActualizacion: _leerFecha(map['fechaActualizacion']),
    );
  }

  static double? _leerDouble(dynamic valor) {
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

  static DateTime _leerFecha(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }

    if (valor is DateTime) {
      return valor;
    }

    if (valor is String) {
      return DateTime.tryParse(valor) ?? DateTime.now();
    }

    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'activoId': activoId,
      'creadorId': creadorId,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'montoObjetivo': montoObjetivo,
      'montoMinimo': montoMinimo,
      'estado': estado,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
    };
  }
}