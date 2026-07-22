import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/solicitud_estado.dart';


class SolicitudContacto {


  final String solicitudId;

  final String campoId;

  final String interesadoId;

  final String propietarioId;

  final String tipoInteres;

  final SolicitudEstado estado;

  final String? chatId;

  final DateTime fechaCreacion;




  SolicitudContacto({

    required this.solicitudId,

    required this.campoId,

    required this.interesadoId,

    required this.propietarioId,

    required this.tipoInteres,

    required this.estado,

    this.chatId,

    required this.fechaCreacion,

  });






  factory SolicitudContacto.fromMap(
      Map<String,dynamic> map,
      String id,
  ) {


    return SolicitudContacto(

      solicitudId: id,


      campoId:
          map['campoId'] ?? '',


      interesadoId:
          map['interesadoId'] ?? '',


      propietarioId:
          map['propietarioId'] ?? '',


      tipoInteres:
          map['tipoInteres'] ?? 'compra',



      estado:
          SolicitudEstado.values.firstWhere(

            (e) =>
                e.name ==
                (map['estado'] ?? 'pendiente'),

            orElse: () =>
                SolicitudEstado.pendiente,

          ),



      chatId:
          map['chatId'],



      fechaCreacion:

          map['fechaCreacion'] != null

          ? (map['fechaCreacion'] as Timestamp)
              .toDate()

          : DateTime.now(),


    );


  }







  Map<String,dynamic> toMap() {


    return {


      'campoId':
          campoId,


      'interesadoId':
          interesadoId,


      'propietarioId':
          propietarioId,


      'tipoInteres':
          tipoInteres,


      'estado':
          estado.name,



      'chatId':
          chatId,



      'fechaCreacion':
          fechaCreacion,


    };


  }



}