import 'package:cloud_firestore/cloud_firestore.dart';

import 'audit_type.dart';

class AuditEvent {
  final String eventoId;
  final String activoId;
  final String usuarioId;
  final String? rol;
  final AuditType tipo;
  final String modulo;
  final String accion;
  final DateTime fecha;
  final String? elementoAfectado;
  final String? estadoAnterior;
  final String? estadoNuevo;
  final String? referencia;
  final Map<String, dynamic>? datos;

  AuditEvent({
    required this.eventoId,
    required this.activoId,
    required this.usuarioId,
    this.rol,
    required this.tipo,
    required this.modulo,
    required this.accion,
    required this.fecha,
    this.elementoAfectado,
    this.estadoAnterior,
    this.estadoNuevo,
    this.referencia,
    this.datos,
  });

  factory AuditEvent.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return AuditEvent(
      eventoId: id,
      activoId: map['activoId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      rol: map['rol'],
      tipo: AuditType.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => AuditType.modificacion,
      ),
      modulo: map['modulo'] ?? '',
      accion: map['accion'] ?? '',
      fecha: _leerFecha(map['fecha']),
      elementoAfectado: map['elementoAfectado'],
      estadoAnterior: map['estadoAnterior'],
      estadoNuevo: map['estadoNuevo'],
      referencia: map['referencia'],
      datos: map['datos'] != null
          ? Map<String, dynamic>.from(map['datos'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventoId': eventoId,
      'activoId': activoId,
      'usuarioId': usuarioId,
      'rol': rol,
      'tipo': tipo.name,
      'modulo': modulo,
      'accion': accion,
      'fecha': Timestamp.fromDate(fecha),
      'elementoAfectado': elementoAfectado,
      'estadoAnterior': estadoAnterior,
      'estadoNuevo': estadoNuevo,
      'referencia': referencia,
      'datos': datos,
    };
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
}