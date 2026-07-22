class Inversion {
  final String inversionId;
  final String inversorId;
  final String publicacionId;

  final double monto;
  final double porcentaje;

  final String estado; // activa, finalizada, cancelada

  final DateTime fecha;

  Inversion({
    required this.inversionId,
    required this.inversorId,
    required this.publicacionId,
    required this.monto,
    required this.porcentaje,
    required this.estado,
    required this.fecha,
  });

  factory Inversion.fromMap(Map<String, dynamic> map, String id) {
    return Inversion(
      inversionId: id,
      inversorId: map['inversorId'] ?? '',
      publicacionId: map['publicacionId'] ?? '',
      monto: (map['monto'] ?? 0).toDouble(),
      porcentaje: (map['porcentaje'] ?? 0).toDouble(),
      estado: map['estado'] ?? 'activa',
      fecha: map['fecha'] != null
          ? map['fecha'].toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inversorId': inversorId,
      'publicacionId': publicacionId,
      'monto': monto,
      'porcentaje': porcentaje,
      'estado': estado,
      'fecha': fecha,
    };
  }
}