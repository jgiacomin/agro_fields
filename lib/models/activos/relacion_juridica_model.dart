import 'package:cloud_firestore/cloud_firestore.dart';

class RelacionJuridica {
  final String relacionId;
  final String derechoId;
  final String sujetoId;
  final String tipoSujeto;
  final String rol;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String estado;
  final List<String> condiciones;

  const RelacionJuridica({
    required this.relacionId,
    required this.derechoId,
    required this.sujetoId,
    required this.tipoSujeto,
    required this.rol,
    this.fechaInicio,
    this.fechaFin,
    required this.estado,
    this.condiciones = const [],
  });

  factory RelacionJuridica.fromMap(Map<String, dynamic> map) {
    return RelacionJuridica(
      relacionId: map['relacionId'] as String? ?? '',
      derechoId: map['derechoId'] as String? ?? '',
      sujetoId: map['sujetoId'] as String? ?? '',
      tipoSujeto: map['tipoSujeto'] as String? ?? '',
      rol: map['rol'] as String? ?? '',
      fechaInicio: _leerFecha(map['fechaInicio']),
      fechaFin: _leerFecha(map['fechaFin']),
      estado: map['estado'] as String? ?? '',
      condiciones: List<String>.from(
        map['condiciones'] ?? const [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'relacionId': relacionId,
      'derechoId': derechoId,
      'sujetoId': sujetoId,
      'tipoSujeto': tipoSujeto,
      'rol': rol,
      'fechaInicio': fechaInicio != null
          ? Timestamp.fromDate(fechaInicio!)
          : null,
      'fechaFin':
          fechaFin != null ? Timestamp.fromDate(fechaFin!) : null,
      'estado': estado,
      'condiciones': condiciones,
    };
  }

  RelacionJuridica copyWith({
    String? relacionId,
    String? derechoId,
    String? sujetoId,
    String? tipoSujeto,
    String? rol,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    List<String>? condiciones,
  }) {
    return RelacionJuridica(
      relacionId: relacionId ?? this.relacionId,
      derechoId: derechoId ?? this.derechoId,
      sujetoId: sujetoId ?? this.sujetoId,
      tipoSujeto: tipoSujeto ?? this.tipoSujeto,
      rol: rol ?? this.rol,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      condiciones: condiciones ?? this.condiciones,
    );
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor == null) return null;

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