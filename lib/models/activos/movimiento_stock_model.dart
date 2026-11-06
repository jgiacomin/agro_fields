class MovimientoStock {
  final String movimientoId;
  final String activoAgroId;
  final String recursoId;

  final String tipoMovimiento;
  final double cantidad;
  final String unidad;

  final DateTime fechaMovimiento;

  final String? trabajoId;
  final String? responsableId;
  final String? motivo;
  final String? sentido;
  final String? observaciones;

  const MovimientoStock({
    required this.movimientoId,
    required this.activoAgroId,
    required this.recursoId,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.unidad,
    required this.fechaMovimiento,
    this.trabajoId,
    this.responsableId,
    this.motivo,
    this.sentido,
    this.observaciones,
  });

  factory MovimientoStock.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return MovimientoStock(
      movimientoId: id,
      activoAgroId: map['activoAgroId'] as String? ?? '',
      recursoId: map['recursoId'] as String? ?? '',
      tipoMovimiento: map['tipoMovimiento'] as String? ?? '',
      cantidad: (map['cantidad'] as num?)?.toDouble() ?? 0,
      unidad: map['unidad'] as String? ?? '',
      fechaMovimiento:
          DateTime.parse(map['fechaMovimiento'] as String),
      trabajoId: map['trabajoId'] as String?,
      responsableId: map['responsableId'] as String?,
      motivo: map['motivo'] as String?,
      sentido: map['sentido'] as String?,
      observaciones: map['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movimientoId': movimientoId,
      'activoAgroId': activoAgroId,
      'recursoId': recursoId,
      'tipoMovimiento': tipoMovimiento,
      'cantidad': cantidad,
      'unidad': unidad,
      'fechaMovimiento': fechaMovimiento.toIso8601String(),
      'trabajoId': trabajoId,
      'responsableId': responsableId,
      'motivo': motivo,
      'sentido': sentido,
      'observaciones': observaciones,
    };
  }
}
