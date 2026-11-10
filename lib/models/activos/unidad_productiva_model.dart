import 'package:cloud_firestore/cloud_firestore.dart';

/// Unidad productiva (paso 6a, GAP-PROD-01): DONDE se produce.
/// Un potrero, un corral, un lote agricola, un galpon, un estanque...
///
/// Pertenece al Activo Agro (activoAgroId). Puede apoyarse, si se quiere,
/// en una infraestructura que ya existe (infraestructuraId).
///
/// Regla: lo desconocido NO es cero. Si no se sabe la superficie o la
/// capacidad, quedan en null (vacio), nunca en 0.
/// Una unidad no se borra: se archiva.
enum TipoUnidadProductiva {
  potrero,
  corral,
  lote,
  galpon,
  tambo,
  invernadero,
  estanque,
  apiario,
  otro,
}

enum EstadoUnidadProductiva {
  activa,
  archivada,
}

class UnidadProductiva {
  final String unidadId;
  final String activoAgroId;

  final TipoUnidadProductiva tipo;
  final String nombre;

  /// Hectareas. null = no se sabe.
  final double? superficieHa;

  /// Cabezas, colmenas, etc. que entran. null = no se sabe.
  final int? capacidad;

  final String? infraestructuraId;
  final String? moduloProduccionId;

  final EstadoUnidadProductiva estado;

  final String creadoPor;
  final DateTime fechaCreacion;

  final String? observaciones;

  const UnidadProductiva({
    required this.unidadId,
    required this.activoAgroId,
    required this.tipo,
    required this.nombre,
    required this.creadoPor,
    required this.fechaCreacion,
    this.superficieHa,
    this.capacidad,
    this.infraestructuraId,
    this.moduloProduccionId,
    this.estado = EstadoUnidadProductiva.activa,
    this.observaciones,
  });

  bool get estaArchivada => estado == EstadoUnidadProductiva.archivada;

  factory UnidadProductiva.fromMap(Map<String, dynamic> map, String id) {
    return UnidadProductiva(
      unidadId: id,
      activoAgroId: map['activoAgroId'] as String? ?? '',
      tipo: _tipoDesde(map['tipo']),
      nombre: map['nombre'] as String? ?? '',
      superficieHa: (map['superficieHa'] as num?)?.toDouble(),
      capacidad: (map['capacidad'] as num?)?.toInt(),
      infraestructuraId: map['infraestructuraId'] as String?,
      moduloProduccionId: map['moduloProduccionId'] as String?,
      estado: map['estado'] == EstadoUnidadProductiva.archivada.name
          ? EstadoUnidadProductiva.archivada
          : EstadoUnidadProductiva.activa,
      creadoPor: map['creadoPor'] as String? ?? '',
      fechaCreacion: _leerFecha(map['fechaCreacion']),
      observaciones: map['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unidadId': unidadId,
      'activoAgroId': activoAgroId,
      'tipo': tipo.name,
      'nombre': nombre,
      'superficieHa': superficieHa,
      'capacidad': capacidad,
      'infraestructuraId': infraestructuraId,
      'moduloProduccionId': moduloProduccionId,
      'estado': estado.name,
      'creadoPor': creadoPor,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'observaciones': observaciones,
    };
  }

  /// Archivar no es borrar: la unidad y su historia quedan.
  UnidadProductiva archivar() {
    return UnidadProductiva(
      unidadId: unidadId,
      activoAgroId: activoAgroId,
      tipo: tipo,
      nombre: nombre,
      superficieHa: superficieHa,
      capacidad: capacidad,
      infraestructuraId: infraestructuraId,
      moduloProduccionId: moduloProduccionId,
      estado: EstadoUnidadProductiva.archivada,
      creadoPor: creadoPor,
      fechaCreacion: fechaCreacion,
      observaciones: observaciones,
    );
  }

  static TipoUnidadProductiva _tipoDesde(dynamic valor) {
    for (final tipo in TipoUnidadProductiva.values) {
      if (tipo.name == valor) return tipo;
    }
    return TipoUnidadProductiva.otro;
  }

  static DateTime _leerFecha(dynamic valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor) ?? DateTime.now();
    return DateTime.now();
  }
}
