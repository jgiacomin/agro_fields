import 'package:cloud_firestore/cloud_firestore.dart';


class ChatRoom {


  final String chatId;

  final String campoId;

  final String propietarioId;

  final String interesadoId;

  final String estado;

  final DateTime fechaCreacion;



  ChatRoom({

    required this.chatId,

    required this.campoId,

    required this.propietarioId,

    required this.interesadoId,

    required this.estado,

    required this.fechaCreacion,

  });




  factory ChatRoom.fromMap(
      Map<String,dynamic> map,
      String id,
  ){


    return ChatRoom(

      chatId: id,

      campoId:
        map['campoId'] ?? '',


      propietarioId:
        map['propietarioId'] ?? '',


      interesadoId:
        map['interesadoId'] ?? '',


      estado:
        map['estado'] ?? 'activo',


      fechaCreacion:

        map['fechaCreacion'] != null

        ? (map['fechaCreacion'] as Timestamp)
            .toDate()

        : DateTime.now(),


    );


  }


}