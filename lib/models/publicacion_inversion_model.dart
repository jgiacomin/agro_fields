class PublicacionInversion {
  final String publicacionId;
  final String campoId;
  final String propietarioId;

  final String titulo;
  final String descripcion;

  final double montoObjetivo;
  final double montoRecaudado;

  final String estado; // activa, cerrada

  final DateTime fecha;

  PublicacionInversion({
    required this.publicacionId,
    required this.campoId,
    required this.propietarioId,
    required this.titulo,
    required this.descripcion,
    required this.montoObjetivo,
    required this.montoRecaudado,
    required this.estado,
    required this.fecha,
  });

  factory PublicacionInversion.fromMap(Map<String, dynamic> map, String id) {
    return PublicacionInversion(
      publicacionId: id,
      campoId: map['campoId'] ?? '',
      propietarioId: map['propietarioId'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      montoObjetivo: (map['montoObjetivo'] ?? 0).toDouble(),
      montoRecaudado: (map['montoRecaudado'] ?? 0).toDouble(),
      estado: map['estado'] ?? 'activa',
      fecha: map['fecha'] != null
          ? map['fecha'].toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campoId': campoId,
      'propietarioId': propietarioId,
      'titulo': titulo,
      'descripcion': descripcion,
      'montoObjetivo': montoObjetivo,
      'montoRecaudado': montoRecaudado,
      'estado': estado,
      'fecha': fecha,
    };
  }
}