import 'package:cloud_firestore/cloud_firestore.dart';




/// Modelo de historial del Activo Agro.
///
/// Representa eventos asociados a la evolución
/// de una entidad productiva dentro de Agro Fields V8.
///
/// Complementa la trazabilidad del activo.
/// No reemplaza la auditoría.
///
/// Evolución:
/// - 79e7095 creación inicial del repositorio.
/// - V8 incorporación de trazabilidad del Activo Agro.
/// - incorporación de módulo origen del evento.

class HistorialActivo {


  final String eventoId;

  final String tipoEvento;

  final String descripcion;

  final String usuarioId;

  final String moduloOrigen;

  final DateTime fecha;

  /// Entidad relacionada con el evento.
/// Ejemplo:
/// produccion, documento, inversion, profesional.
final String? entidadRelacionada;

/// Identificador de la entidad relacionada.
/// Permite vincular el evento con otro registro.
final String? referenciaId;

/// Información adicional del evento.
/// Permite extender trazabilidad sin modificar estructura.
final Map<String,dynamic>? datosEvento;



  HistorialActivo({

    required this.eventoId,

    required this.tipoEvento,

    required this.descripcion,

    required this.usuarioId,

    required this.moduloOrigen,

    required this.fecha,

    this.entidadRelacionada,

    this.referenciaId,

    this.datosEvento,

  });



  factory HistorialActivo.fromMap(
      Map<String,dynamic> map,
      String id
      ){

    return HistorialActivo(

      eventoId: id,

      tipoEvento:
      map['tipoEvento'] ?? '',


      descripcion:
      map['descripcion'] ?? '',


      usuarioId:
      map['usuarioId'] ?? '',

      moduloOrigen:
      map['moduloOrigen'] ?? 'activo',


      fecha:
      map['fecha'] != null
          ? (map['fecha'] as Timestamp).toDate()
          : DateTime.now(),


                entidadRelacionada:
      map['entidadRelacionada'],

      referenciaId:
      map['referenciaId'],

      datosEvento:
      map['datosEvento'] != null
          ? Map<String,dynamic>.from(
              map['datosEvento'],
            )
          : null,
    );

  }




  Map<String,dynamic> toMap(){

  return {

    'eventoId':
    eventoId,


    'tipoEvento':
    tipoEvento,


    'descripcion':
    descripcion,


    'usuarioId':
    usuarioId,

    'moduloOrigen':
     moduloOrigen,

     'entidadRelacionada':
      entidadRelacionada,

     'referenciaId':
     referenciaId,

     'datosEvento':
      datosEvento,

    'fecha':
    fecha,

  };

}



}