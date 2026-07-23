import 'package:cloud_firestore/cloud_firestore.dart';

class Campo {
  final String campoId;

  // Personas involucradas
  final String propietarioId;
  final String publicadorId;
  final String tipoRelacion;

  // Datos del campo
  final String pais;
  final String provincia;
  final String departamento;
  final String localidad;
  final String codigoPostal;

  final String nombre;
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

  required this.pais,
  required this.provincia,
  required this.departamento,
  required this.localidad,
  required this.codigoPostal,

  required this.nombre,
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

  pais: map['pais'] ?? '',
  provincia: map['provincia'] ?? '',
  departamento: map['departamento'] ?? '',
  localidad: map['localidad'] ?? '',
  codigoPostal: map['codigoPostal'] ?? '',

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
      
      'pais': pais,

      'provincia': provincia,

      'departamento': departamento,

       'codigoPostal': codigoPostal,

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
  required String pais,
  required String provincia,
  required String departamento,
  required String localidad,
  required double hectareas,
}) 
{

  return '${nombre.trim().toLowerCase()}|'
      '${pais.trim().toLowerCase()}|'
      '${provincia.trim().toLowerCase()}|'
      '${departamento.trim().toLowerCase()}|'
      '${localidad.trim().toLowerCase()}|'
      '${hectareas.toString()}';
}

}