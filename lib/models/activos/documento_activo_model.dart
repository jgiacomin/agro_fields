import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentoActivo {
  final String documentoId;
  final String tipo;
  final String descripcion;
  final DateTime? fecha;
  final String estado;
  final String? responsableId;
  final List<String> evidenciaIds;
  final String? observaciones;

  DocumentoActivo({
    required this.documentoId,
    required this.tipo,
    required this.descripcion,
    this.fecha,
    required this.estado,
    this.responsableId,
    required this.evidenciaIds,
    this.observaciones,
  });

  factory DocumentoActivo.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return DocumentoActivo(
      documentoId: id,
      tipo: map['tipo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fecha: _leerFecha(map['fecha']),
      estado: map['estado'] ?? 'pendiente',
      responsableId: map['responsableId'],
      evidenciaIds: List<String>.from(
        map['evidenciaIds'] ?? [],
      ),
      observaciones: map['observaciones'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentoId': documentoId,
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha': fecha != null
          ? Timestamp.fromDate(fecha!)
          : null,
      'estado': estado,
      'responsableId': responsableId,
      'evidenciaIds': evidenciaIds,
      'observaciones': observaciones,
    };
  }

  DocumentoActivo copyWith({
    String? documentoId,
    String? tipo,
    String? descripcion,
    DateTime? fecha,
    String? estado,
    String? responsableId,
    List<String>? evidenciaIds,
    String? observaciones,
  }) {
    return DocumentoActivo(
      documentoId: documentoId ?? this.documentoId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      responsableId: responsableId ?? this.responsableId,
      evidenciaIds: evidenciaIds ?? this.evidenciaIds,
      observaciones: observaciones ?? this.observaciones,
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
