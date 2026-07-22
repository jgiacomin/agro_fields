import 'package:cloud_firestore/cloud_firestore.dart';

class Campo {
  final String campoId;

  // Personas involucradas
  final String propietarioId;
  final String publicadorId;
  final String tipoRelacion;

  // Datos del campo
  final String nombre;
  final String provincia;
  final String localidad;
  final double hectareas;
  final String descripcion;

  // Estado comercial
  final String estadoPublicacion;

  // Confianza
  final bool verificado;

  // Control interno
  final String hashCampo;
  final DateTime fechaCreacion;


  Campo({
    required this.campoId,

    required this.propietarioId,
    required this.publicadorId,
    required this.tipoRelacion,

    required this.nombre,
    required this.provincia,
    required this.localidad,
    required this.hectareas,
    required this.descripcion,

    required this.estadoPublicacion,

    required this.verificado,

    required this.hashCampo,
    required this.fechaCreacion,
  });


  factory Campo.fromMap(Map<String, dynamic> map, String id) {
    return Campo(
      campoId: id,

      propietarioId: map['propietarioId'] ?? '',
      publicadorId: map['publicadorId'] ?? '',
      tipoRelacion: map['tipoRelacion'] ?? 'propietario',

      nombre: map['nombre'] ?? '',
      provincia: map['provincia'] ?? '',
      localidad: map['localidad'] ?? '',

      hectareas: (map['hectareas'] ?? 0).toDouble(),

      descripcion: map['descripcion'] ?? '',

      estadoPublicacion:
          map['estadoPublicacion'] ?? 'disponible',

      verificado:
          map['verificado'] ?? false,

      hashCampo:
          map['hashCampo'] ?? '',

      fechaCreacion:
          map['fechaCreacion'] != null
              ? (map['fechaCreacion'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }


  Map<String, dynamic> toMap() {
    return {

      'propietarioId': propietarioId,

      'publicadorId': publicadorId,

      'tipoRelacion': tipoRelacion,


      'nombre': nombre,

      'provincia': provincia,

      'localidad': localidad,

      'hectareas': hectareas,

      'descripcion': descripcion,


      'estadoPublicacion': estadoPublicacion,

      'verificado': verificado,


      'hashCampo': hashCampo,

      'fechaCreacion': fechaCreacion,
    };
  }


  static String generateHash({
    required String nombre,
    required String provincia,
    required String localidad,
    required double hectareas,
  }) {

    return '${nombre.trim().toLowerCase()}|'
        '${provincia.trim().toLowerCase()}|'
        '${localidad.trim().toLowerCase()}|'
        '${hectareas.toString()}';
  }
}