import 'ciclo_productivo_model.dart';

class ModuloProduccion {
  /// Identificador del módulo productivo
  final String? id;

  /// Referencia al Activo Agro V2
  final String? activoAgroId;

  final String dominio;

  final String actividad;

  final String descripcion;

  final double? superficie;

  final String? unidad;

  final Map<String, dynamic> datos;

  final double? capacidadActual;
  final double? capacidadMaxima;
  final bool activo;
  final List<CicloProductivo> ciclos;

  ModuloProduccion({
    this.id,

    this.activoAgroId,

    required this.dominio,

    required this.actividad,

    required this.descripcion,

    this.superficie,

    this.unidad,

    this.capacidadActual,

    this.capacidadMaxima,

    this.activo = true,

    required this.datos,

    required this.ciclos,
  });

  factory ModuloProduccion.fromMap(Map<String, dynamic> map) {
    return ModuloProduccion(
      id: map['id'],

      activoAgroId: map['activoAgroId'],

      // Compatibilidad con versión anterior
      dominio: map['dominio'] ?? map['tipoProduccion'] ?? '',

      actividad: map['actividad'] ?? map['tipoProduccion'] ?? '',

      descripcion: map['descripcion'] ?? '',

      superficie: map['superficie'] != null
          ? (map['superficie']).toDouble()
          : null,

      unidad: map['unidad'],

      capacidadActual: map['capacidadActual'] != null
          ? (map['capacidadActual'] as num).toDouble()
          : null,

      capacidadMaxima: map['capacidadMaxima'] != null
          ? (map['capacidadMaxima'] as num).toDouble()
          : null,

      activo: map['activo'] ?? true,

      datos: Map<String, dynamic>.from(map['datos'] ?? {}),

      ciclos: (map['ciclos'] as List<dynamic>? ?? [])
          .map(
            (item) => CicloProductivo.fromMap(
              Map<String, dynamic>.from(item),
              item['cicloId'] ?? '',
            ),
          )
          .toList(),
    );
  }
  ModuloProduccion copyWith({
  String? id,
  String? activoAgroId,
  String? dominio,
  String? actividad,
  String? descripcion,
  double? superficie,
  String? unidad,
  double? capacidadActual,
  double? capacidadMaxima,
  bool? activo,
  Map<String, dynamic>? datos,
  List<CicloProductivo>? ciclos,
})
{
  return ModuloProduccion(
    id: id ?? this.id,
    activoAgroId: activoAgroId ?? this.activoAgroId,
    dominio: dominio ?? this.dominio,
    actividad: actividad ?? this.actividad,
    descripcion: descripcion ?? this.descripcion,
    superficie: superficie ?? this.superficie,
    unidad: unidad ?? this.unidad,
    capacidadActual: capacidadActual ?? this.capacidadActual,
    capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
    activo: activo ?? this.activo,
    datos: datos ?? this.datos,
    ciclos: ciclos ?? this.ciclos,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'activoAgroId': activoAgroId,

      'dominio': dominio,

      'actividad': actividad,

      'descripcion': descripcion,

      'superficie': superficie,

      'unidad': unidad,

      'capacidadActual': capacidadActual,

      'capacidadMaxima': capacidadMaxima,

      'activo': activo,

      'datos': datos,

      'ciclos': ciclos.map((ciclo) => ciclo.toMap()).toList(),
    };
  }
}
