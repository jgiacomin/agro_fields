/// AF-092 (12/11/2026): marca voluntaria "Mi campo puede recibir en una
/// emergencia". La decide el dueño. En el lanzamiento solo la ve el dueño;
/// mostrarla a otros productores queda para después (🟡), con su permiso.
class DisponibilidadRecepcion {
  /// Recursos que se pueden marcar.
  static const List<String> recursosPosibles = [
    'hacienda',
    'granos',
    'maquinaria',
    'otro',
  ];

  final bool activa;

  /// Qué puede recibir (ver [recursosPosibles]).
  final List<String> recursos;

  /// Nota libre de capacidad (ej.: "300 cabezas, 2 potreros con agua").
  final String? capacidad;

  final DateTime? fechaActualizacion;

  const DisponibilidadRecepcion({
    required this.activa,
    this.recursos = const [],
    this.capacidad,
    this.fechaActualizacion,
  });

  factory DisponibilidadRecepcion.fromMap(Map<String, dynamic> map) {
    final recursos = (map['recursos'] as List<dynamic>? ?? [])
        .whereType<String>()
        .where(recursosPosibles.contains)
        .toList();
    return DisponibilidadRecepcion(
      // Sin dato claro, no se asume que el campo está disponible.
      activa: map['activa'] == true,
      recursos: recursos,
      capacidad: map['capacidad'] as String?,
      fechaActualizacion: _leerFecha(map['fechaActualizacion']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activa': activa,
      'recursos': recursos,
      'capacidad': capacidad,
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor);
    return null;
  }
}
