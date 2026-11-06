class UsoRecursoTrabajo {
  final String usoId;
  final String activoAgroId;
  final String recursoId;
  final String trabajoId;

  final double cantidadUtilizada;
  final String unidad;

  final DateTime fechaUso;

  final String? responsableId;
  final String? observaciones;

  const UsoRecursoTrabajo({
    required this.usoId,
    required this.activoAgroId,
    required this.recursoId,
    required this.trabajoId,
    required this.cantidadUtilizada,
    required this.unidad,
    required this.fechaUso,
    this.responsableId,
    this.observaciones,
  });

  factory UsoRecursoTrabajo.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return UsoRecursoTrabajo(
      usoId: id,
      activoAgroId: map['activoAgroId'] as String? ?? '',
      recursoId: map['recursoId'] as String? ?? '',
      trabajoId: map['trabajoId'] as String? ?? '',
      cantidadUtilizada:
          (map['cantidadUtilizada'] as num?)?.toDouble() ?? 0,
      unidad: map['unidad'] as String? ?? '',
      fechaUso: DateTime.parse(map['fechaUso'] as String),
      responsableId: map['responsableId'] as String?,
      observaciones: map['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usoId': usoId,
      'activoAgroId': activoAgroId,
      'recursoId': recursoId,
      'trabajoId': trabajoId,
      'cantidadUtilizada': cantidadUtilizada,
      'unidad': unidad,
      'fechaUso': fechaUso.toIso8601String(),
      'responsableId': responsableId,
      'observaciones': observaciones,
    };
  }
}
