
class InfraestructuraActivo {
  final String infraestructuraId;
  final String tipo;
  final String nombre;
  final String descripcion;
  final int cantidad;
  final String estado;
  final String? moduloProduccionId;

  InfraestructuraActivo({
    required this.infraestructuraId,
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    required this.cantidad,
    required this.estado,
    this.moduloProduccionId,
  });

  factory InfraestructuraActivo.inicial() {
    return InfraestructuraActivo(
      infraestructuraId: '',
      tipo: '',
      nombre: '',
      descripcion: '',
      cantidad: 1,
      estado: 'declarado',
    );
  }

  factory InfraestructuraActivo.fromMap(Map<String, dynamic> map) {
    return InfraestructuraActivo(
      infraestructuraId: map['infraestructuraId'] ?? '',
      tipo: map['tipo'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      cantidad: (map['cantidad'] as num?)?.toInt() ?? 1,
      estado: map['estado'] ?? 'declarado',
      moduloProduccionId: map['moduloProduccionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'infraestructuraId': infraestructuraId,
      'tipo': tipo,
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'estado': estado,
      'moduloProduccionId': moduloProduccionId,
    };
  }

  InfraestructuraActivo copyWith({
    String? infraestructuraId,
    String? tipo,
    String? nombre,
    String? descripcion,
    int? cantidad,
    String? estado,
    String? moduloProduccionId,
  }) {
    return InfraestructuraActivo(
      infraestructuraId: infraestructuraId ?? this.infraestructuraId,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      cantidad: cantidad ?? this.cantidad,
      estado: estado ?? this.estado,
      moduloProduccionId:
          moduloProduccionId ?? this.moduloProduccionId,
    );
  }
}
