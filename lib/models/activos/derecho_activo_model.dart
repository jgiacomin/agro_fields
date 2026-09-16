import 'package:cloud_firestore/cloud_firestore.dart';

class AlcanceTerritorial {
  final String tipoAlcance;
  final String descripcion;
  final double? superficieAfectada;
  final String? unidadSuperficie;
  final String? referenciaGeografica;

  const AlcanceTerritorial({
    required this.tipoAlcance,
    required this.descripcion,
    this.superficieAfectada,
    this.unidadSuperficie,
    this.referenciaGeografica,
  });

  factory AlcanceTerritorial.fromMap(Map<String, dynamic> map) {
    return AlcanceTerritorial(
      tipoAlcance: map['tipoAlcance'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      superficieAfectada:
          (map['superficieAfectada'] as num?)?.toDouble(),
      unidadSuperficie: map['unidadSuperficie'] as String?,
      referenciaGeografica: map['referenciaGeografica'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipoAlcance': tipoAlcance,
      'descripcion': descripcion,
      'superficieAfectada': superficieAfectada,
      'unidadSuperficie': unidadSuperficie,
      'referenciaGeografica': referenciaGeografica,
    };
  }
}

class DerechoActivo {
  final String derechoId;
  final String activoAgroId;
  final String tipoDerecho;
  final String? descripcionTipo;
  final String tipoObjeto;
  final String descripcionObjeto;
  final AlcanceTerritorial? alcanceTerritorial;
  final String tipoInstrumento;
  final String? identificadorInstrumento;
  final String? emisor;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String estado;
  final List<String> condiciones;
  final DateTime fechaCreacion;
  final DateTime ultimaActualizacion;

  const DerechoActivo({
    required this.derechoId,
    required this.activoAgroId,
    required this.tipoDerecho,
    this.descripcionTipo,
    required this.tipoObjeto,
    required this.descripcionObjeto,
    this.alcanceTerritorial,
    required this.tipoInstrumento,
    this.identificadorInstrumento,
    this.emisor,
    this.fechaInicio,
    this.fechaFin,
    required this.estado,
    this.condiciones = const [],
    required this.fechaCreacion,
    required this.ultimaActualizacion,
  });

  factory DerechoActivo.fromMap(Map<String, dynamic> map) {
    return DerechoActivo(
      derechoId: map['derechoId'] as String? ?? '',
      activoAgroId: map['activoAgroId'] as String? ?? '',
      tipoDerecho: map['tipoDerecho'] as String? ?? '',
      descripcionTipo: map['descripcionTipo'] as String?,
      tipoObjeto: map['tipoObjeto'] as String? ?? '',
      descripcionObjeto: map['descripcionObjeto'] as String? ?? '',
      alcanceTerritorial: map['alcanceTerritorial'] != null
          ? AlcanceTerritorial.fromMap(
              Map<String, dynamic>.from(
                map['alcanceTerritorial'] as Map,
              ),
            )
          : null,
      tipoInstrumento: map['tipoInstrumento'] as String? ?? '',
      identificadorInstrumento:
          map['identificadorInstrumento'] as String?,
      emisor: map['emisor'] as String?,
      fechaInicio: _leerFecha(map['fechaInicio']),
      fechaFin: _leerFecha(map['fechaFin']),
      estado: map['estado'] as String? ?? '',
      condiciones: List<String>.from(
        map['condiciones'] ?? const [],
      ),
      fechaCreacion: _leerFecha(map['fechaCreacion']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      ultimaActualizacion: _leerFecha(map['ultimaActualizacion']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'derechoId': derechoId,
      'activoAgroId': activoAgroId,
      'tipoDerecho': tipoDerecho,
      'descripcionTipo': descripcionTipo,
      'tipoObjeto': tipoObjeto,
      'descripcionObjeto': descripcionObjeto,
      'alcanceTerritorial': alcanceTerritorial?.toMap(),
      'tipoInstrumento': tipoInstrumento,
      'identificadorInstrumento': identificadorInstrumento,
      'emisor': emisor,
      'fechaInicio': fechaInicio != null
          ? Timestamp.fromDate(fechaInicio!)
          : null,
      'fechaFin':
          fechaFin != null ? Timestamp.fromDate(fechaFin!) : null,
      'estado': estado,
      'condiciones': condiciones,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'ultimaActualizacion':
          Timestamp.fromDate(ultimaActualizacion),
    };
  }

  DerechoActivo copyWith({
    String? derechoId,
    String? activoAgroId,
    String? tipoDerecho,
    String? descripcionTipo,
    String? tipoObjeto,
    String? descripcionObjeto,
    AlcanceTerritorial? alcanceTerritorial,
    String? tipoInstrumento,
    String? identificadorInstrumento,
    String? emisor,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    List<String>? condiciones,
    DateTime? fechaCreacion,
    DateTime? ultimaActualizacion,
  }) {
    return DerechoActivo(
      derechoId: derechoId ?? this.derechoId,
      activoAgroId: activoAgroId ?? this.activoAgroId,
      tipoDerecho: tipoDerecho ?? this.tipoDerecho,
      descripcionTipo: descripcionTipo ?? this.descripcionTipo,
      tipoObjeto: tipoObjeto ?? this.tipoObjeto,
      descripcionObjeto:
          descripcionObjeto ?? this.descripcionObjeto,
      alcanceTerritorial:
          alcanceTerritorial ?? this.alcanceTerritorial,
      tipoInstrumento:
          tipoInstrumento ?? this.tipoInstrumento,
      identificadorInstrumento:
          identificadorInstrumento ?? this.identificadorInstrumento,
      emisor: emisor ?? this.emisor,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      condiciones: condiciones ?? this.condiciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimaActualizacion:
          ultimaActualizacion ?? this.ultimaActualizacion,
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