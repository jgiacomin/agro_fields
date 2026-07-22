import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/chat_preview_model.dart';

import 'campo_service.dart';
import 'user_service.dart';


class ChatService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  final String collection = 'chats';


  final CampoService campoService =
      CampoService();


  final UserService userService =
      UserService();



  /// 🆕 Crear sala de chat
  Future<String> crearChat({

    required String campoId,
    required String propietarioId,
    required String interesadoId,

  }) async {

    final doc = await _firestore
        .collection(collection)
        .add({

      'campoId': campoId,

      'propietarioId': propietarioId,

      'interesadoId': interesadoId,


      'participantes': [

        propietarioId,
        interesadoId,

      ],


      'estado': 'activo',


      'fechaCreacion':
          FieldValue.serverTimestamp(),

    });


    return doc.id;

  }




  /// 💬 Enviar mensaje
  Future<void> enviarMensaje(
      ChatMessage mensaje,
  ) async {


    await _firestore

        .collection(collection)

        .doc(mensaje.chatId)

        .collection('mensajes')

        .add(

          mensaje.toMap(),

        );

  }





  /// 📄 Obtener mensajes
  Stream<List<ChatMessage>> obtenerMensajes(

      String chatId,

  ) {


    return _firestore

        .collection(collection)

        .doc(chatId)

        .collection('mensajes')

        .orderBy(

          'fecha',

          descending: false,

        )

        .snapshots()

        .map((snapshot) {


          return snapshot.docs.map((doc) {


            return ChatMessage.fromMap(

              doc.data(),

              doc.id,

            );


          }).toList();


        });


  }





  /// 📬 Obtener conversaciones del usuario
  Stream<QuerySnapshot> obtenerChatsUsuario(

      String uid,

  ) {


    return _firestore

        .collection(collection)

        .where(

          'participantes',

          arrayContains: uid,

        )

        .snapshots();


  }







  /// 🌱 Obtener conversaciones con información real

  Stream<List<ChatPreviewModel>>
      obtenerChatsPreviewUsuario(

      String uid,

  ) {


    return _firestore

        .collection(collection)

        .where(

          'participantes',

          arrayContains: uid,

        )

        .snapshots()

        .asyncMap(

          (snapshot) async {


            List<ChatPreviewModel> lista = [];



            for (var doc in snapshot.docs) {


              final data =
                doc.data();



              final campo =

                  await campoService
                      .obtenerCampoPorId(

                        data['campoId'],

                      );



              if (campo == null) {

                continue;

              }





              final esPropietario =

                  data['propietarioId']
                      == uid;



              final contactoId =

                  esPropietario

                  ? data['interesadoId']

                  : data['propietarioId'];






              final contacto =

                  await userService
                      .getUsuario(

                        contactoId,

                      );



              if (contacto == null) {

                continue;

              }






              lista.add(

                ChatPreviewModel(

                  chatId:
                      doc.id,


                  campo:
                      campo,


                  contacto:
                      contacto,


                  estado:
                      data['estado'] ?? 'activo',



                  fechaCreacion:

                      data['fechaCreacion'] != null

                      ? (

                          data['fechaCreacion']

                          as Timestamp

                        )

                        .toDate()

                      :

                        DateTime.now(),


                ),

              );


            }



            return lista;


          },

        );


  }


}