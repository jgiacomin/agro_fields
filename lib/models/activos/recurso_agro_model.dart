class RecursoAgro {
  final String recursoId;
  final String activoAgroId;

  final String tipo;
  final String nombre;
  final String descripcion;

  final String unidad;
  final double cantidadActual;
  final double cantidadMinima;

  final String estado;

  final String? moduloProduccionId;
  final String? numeroSerie;
  final String? observaciones;

  const RecursoAgro({
    required this.recursoId,
    required this.activoAgroId,
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    required this.unidad,
    required this.cantidadActual,
    required this.cantidadMinima,
    required this.estado,
    this.moduloProduccionId,
    this.numeroSerie,
    this.observaciones,
  });

  factory RecursoAgro.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return RecursoAgro(
      recursoId: id,
      activoAgroId: map['activoAgroId'] as String? ?? '',
      tipo: map['tipo'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      unidad: map['unidad'] as String? ?? '',
      cantidadActual:
          (map['cantidadActual'] as num?)?.toDouble() ?? 0,
      cantidadMinima:
          (map['cantidadMinima'] as num?)?.toDouble() ?? 0,
      estado: map['estado'] as String? ?? 'disponible',
      moduloProduccionId:
          map['moduloProduccionId'] as String?,
      numeroSerie: map['numeroSerie'] as String?,
      observaciones: map['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recursoId': recursoId,
      'activoAgroId': activoAgroId,
      'tipo': tipo,
      'nombre': nombre,
      'descripcion': descripcion,
      'unidad': unidad,
      'cantidadActual': cantidadActual,
      'cantidadMinima': cantidadMinima,
      'estado': estado,
      'moduloProduccionId': moduloProduccionId,
      'numeroSerie': numeroSerie,
      'observaciones': observaciones,
    };
  }
}
