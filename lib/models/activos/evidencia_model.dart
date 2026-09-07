import 'package:cloud_firestore/cloud_firestore.dart';

class Evidencia {
  final String evidenciaId;
  final String activoAgroId;

  final String? moduloOrigen;
  final String? elementoTipo;
  final String? elementoId;
  final String? campoRelacionado;

  final String tipo;
  final String descripcion;
  final String? observaciones;

  final String? aportanteId;

  final String? fuenteTipo;
  final String? fuenteNombre;
  final String? fuenteReferencia;

  final String? soporteTipo;
  final String? soporteReferencia;
  final String? soporteNombre;

  final DateTime? fechaHecho;
  final DateTime fechaRegistro;

  final String estadoVerificacion;
  final String? verificadorId;
  final DateTime? fechaVerificacion;
  final String? observacionVerificacion;
  final String? referenciaVerificacion;

  final String estadoValidez;

  Evidencia({
    required this.evidenciaId,
    required this.activoAgroId,
    this.moduloOrigen,
    this.elementoTipo,
    this.elementoId,
    this.campoRelacionado,
    required this.tipo,
    required this.descripcion,
    this.observaciones,
    this.aportanteId,
    this.fuenteTipo,
    this.fuenteNombre,
    this.fuenteReferencia,
    this.soporteTipo,
    this.soporteReferencia,
    this.soporteNombre,
    this.fechaHecho,
    required this.fechaRegistro,
    required this.estadoVerificacion,
    this.verificadorId,
    this.fechaVerificacion,
    this.observacionVerificacion,
    this.referenciaVerificacion,
    required this.estadoValidez,
  });

  factory Evidencia.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return Evidencia(
      evidenciaId: id,
      activoAgroId: map['activoAgroId'] ?? '',
      moduloOrigen: map['moduloOrigen'],
      elementoTipo: map['elementoTipo'],
      elementoId: map['elementoId'],
      campoRelacionado: map['campoRelacionado'],
      tipo: map['tipo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      observaciones: map['observaciones'],
      aportanteId: map['aportanteId'],
      fuenteTipo: map['fuenteTipo'],
      fuenteNombre: map['fuenteNombre'],
      fuenteReferencia: map['fuenteReferencia'],
      soporteTipo: map['soporteTipo'],
      soporteReferencia: map['soporteReferencia'],
      soporteNombre: map['soporteNombre'],
      fechaHecho: _leerFecha(map['fechaHecho']),
      fechaRegistro: _leerFecha(
        map['fechaRegistro'],
      ) ?? DateTime.now(),
      estadoVerificacion:
          map['estadoVerificacion'] ?? 'pendiente',
      verificadorId: map['verificadorId'],
      fechaVerificacion:
          _leerFecha(map['fechaVerificacion']),
      observacionVerificacion:
          map['observacionVerificacion'],
      referenciaVerificacion:
          map['referenciaVerificacion'],
      estadoValidez:
          map['estadoValidez'] ?? 'sin_informacion',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'evidenciaId': evidenciaId,
      'activoAgroId': activoAgroId,
      'moduloOrigen': moduloOrigen,
      'elementoTipo': elementoTipo,
      'elementoId': elementoId,
      'campoRelacionado': campoRelacionado,
      'tipo': tipo,
      'descripcion': descripcion,
      'observaciones': observaciones,
      'aportanteId': aportanteId,
      'fuenteTipo': fuenteTipo,
      'fuenteNombre': fuenteNombre,
      'fuenteReferencia': fuenteReferencia,
      'soporteTipo': soporteTipo,
      'soporteReferencia': soporteReferencia,
      'soporteNombre': soporteNombre,
      'fechaHecho': fechaHecho != null
          ? Timestamp.fromDate(fechaHecho!)
          : null,
      'fechaRegistro':
          Timestamp.fromDate(fechaRegistro),
      'estadoVerificacion':
          estadoVerificacion,
      'verificadorId': verificadorId,
      'fechaVerificacion': fechaVerificacion != null
          ? Timestamp.fromDate(fechaVerificacion!)
          : null,
      'observacionVerificacion':
          observacionVerificacion,
      'referenciaVerificacion':
          referenciaVerificacion,
      'estadoValidez': estadoValidez,
    };
  }

  Evidencia copyWith({
    String? evidenciaId,
    String? activoAgroId,
    String? moduloOrigen,
    String? elementoTipo,
    String? elementoId,
    String? campoRelacionado,
    String? tipo,
    String? descripcion,
    String? observaciones,
    String? aportanteId,
    String? fuenteTipo,
    String? fuenteNombre,
    String? fuenteReferencia,
    String? soporteTipo,
    String? soporteReferencia,
    String? soporteNombre,
    DateTime? fechaHecho,
    DateTime? fechaRegistro,
    String? estadoVerificacion,
    String? verificadorId,
    DateTime? fechaVerificacion,
    String? observacionVerificacion,
    String? referenciaVerificacion,
    String? estadoValidez,
  }) {
    return Evidencia(
      evidenciaId: evidenciaId ?? this.evidenciaId,
      activoAgroId: activoAgroId ?? this.activoAgroId,
      moduloOrigen: moduloOrigen ?? this.moduloOrigen,
      elementoTipo: elementoTipo ?? this.elementoTipo,
      elementoId: elementoId ?? this.elementoId,
      campoRelacionado:
          campoRelacionado ?? this.campoRelacionado,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      observaciones:
          observaciones ?? this.observaciones,
      aportanteId: aportanteId ?? this.aportanteId,
      fuenteTipo: fuenteTipo ?? this.fuenteTipo,
      fuenteNombre: fuenteNombre ?? this.fuenteNombre,
      fuenteReferencia:
          fuenteReferencia ?? this.fuenteReferencia,
      soporteTipo: soporteTipo ?? this.soporteTipo,
      soporteReferencia:
          soporteReferencia ?? this.soporteReferencia,
      soporteNombre: soporteNombre ?? this.soporteNombre,
      fechaHecho: fechaHecho ?? this.fechaHecho,
      fechaRegistro:
          fechaRegistro ?? this.fechaRegistro,
      estadoVerificacion:
          estadoVerificacion ??
              this.estadoVerificacion,
      verificadorId:
          verificadorId ?? this.verificadorId,
      fechaVerificacion:
          fechaVerificacion ?? this.fechaVerificacion,
      observacionVerificacion:
          observacionVerificacion ??
              this.observacionVerificacion,
      referenciaVerificacion:
          referenciaVerificacion ??
              this.referenciaVerificacion,
      estadoValidez:
          estadoValidez ?? this.estadoValidez,
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