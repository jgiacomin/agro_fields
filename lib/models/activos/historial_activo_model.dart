import 'package:cloud_firestore/cloud_firestore.dart';


class HistorialActivo {


  final String eventoId;

  final String tipoEvento;

  final String descripcion;

  final String usuarioId;

  final DateTime fecha;



  HistorialActivo({

    required this.eventoId,

    required this.tipoEvento,

    required this.descripcion,

    required this.usuarioId,

    required this.fecha,

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


      fecha:
      map['fecha'] != null
          ? (map['fecha'] as Timestamp).toDate()
          : DateTime.now(),

    );

  }




  Map<String,dynamic> toMap(){

    return {

      'tipoEvento':
      tipoEvento,


      'descripcion':
      descripcion,


      'usuarioId':
      usuarioId,


      'fecha':
      fecha,

    };

  }


}