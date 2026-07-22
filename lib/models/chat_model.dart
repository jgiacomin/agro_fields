import 'package:cloud_firestore/cloud_firestore.dart';


/// 💬 Modelo de conversación

class ChatModel {

  final String chatId;

  final String campoId;

  final String propietarioId;

  final String interesadoId;

  final String estado;

  final DateTime fechaCreacion;


  ChatModel({

    required this.chatId,

    required this.campoId,

    required this.propietarioId,

    required this.interesadoId,

    required this.estado,

    required this.fechaCreacion,

  });



  factory ChatModel.fromMap(
      Map<String, dynamic> map,
      String id,
  ) {

    return ChatModel(

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
              ? (map['fechaCreacion'] as Timestamp).toDate()
              : DateTime.now(),

    );

  }



  Map<String,dynamic> toMap(){

    return {

      'campoId':
          campoId,


      'propietarioId':
          propietarioId,


      'interesadoId':
          interesadoId,


      'estado':
          estado,


      'fechaCreacion':
          fechaCreacion,

    };

  }

}





/// 📨 Modelo de mensaje dentro del chat

class ChatMessage {

  final String messageId;

  final String chatId;


  final String senderId;


  final String text;


  final DateTime fecha;



  ChatMessage({

    required this.messageId,

    required this.chatId,

    required this.senderId,

    required this.text,

    required this.fecha,

  });



  factory ChatMessage.fromMap(
      Map<String,dynamic> map,
      String id,
  ){

    return ChatMessage(

      messageId: id,


      chatId:
          map['chatId'] ?? '',


      senderId:
          map['senderId'] ?? '',


      text:
          map['text'] ?? '',


      fecha:
          map['fecha'] != null
              ? (map['fecha'] as Timestamp).toDate()
              : DateTime.now(),

    );

  }



  Map<String,dynamic> toMap(){

    return {

      'chatId':
          chatId,


      'senderId':
          senderId,


      'text':
          text,


      'fecha':
          fecha,

    };

  }

}