import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/chat_preview_model.dart';
import '../models/activos/activo_agro_model_v2.dart';

import 'campo_service.dart';
import 'activo_agro_service_v2.dart';
import 'user_service.dart';


class ChatService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  final String collection = 'chats';


  final CampoService campoService =
      CampoService();

      final ActivoAgroServiceV2 activoService =
    ActivoAgroServiceV2();


  final UserService userService =
      UserService();



  /// 🆕 Crear o recuperar sala de chat
Future<String> crearChat({

  required String campoId,
  required String propietarioId,
  required String interesadoId,

}) async {

  // Buscar si ya existe una conversación
  // para este campo + propietario + interesado.
  final existente = await _firestore
      .collection(collection)
      .where(
        'campoId',
        isEqualTo: campoId,
      )
      .where(
        'propietarioId',
        isEqualTo: propietarioId,
      )
      .where(
        'interesadoId',
        isEqualTo: interesadoId,
      )
      .limit(1)
      .get();

  // Si ya existe, reutilizamos ese chat.
  if (existente.docs.isNotEmpty) {
    return existente.docs.first.id;
  }

  // Si no existe, creamos uno nuevo.
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
  Stream<List<ChatPreviewModel>> obtenerChatsPreviewUsuario(
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
        final List<ChatPreviewModel> lista = [];

        for (final doc in snapshot.docs) {
          final data = doc.data();

          final campoId = data['campoId'];

          if (campoId == null) {
            continue;
          }

          // 1. Buscar primero en Campos V1
          final campo = await campoService.obtenerCampoPorId(
            campoId,
          );

          // 2. Si no existe, buscar en Activos Agro V2
          ActivoAgroV2? activo;

          if (campo == null) {
            activo = await activoService.obtenerActivoPorId(
              campoId,
            );
          }

          // 3. Si no existe en ninguno de los dos sistemas,
          // no podemos construir correctamente el preview.
          if (campo == null && activo == null) {
            continue;
          }

          // 4. Determinar el otro participante
          final esPropietario =
              data['propietarioId'] == uid;

          final contactoId = esPropietario
              ? data['interesadoId']
              : data['propietarioId'];

          if (contactoId == null) {
            continue;
          }

          final contacto = await userService.getUsuario(
            contactoId,
          );

          if (contacto == null) {
            continue;
          }

          // 5. Fecha de creación
          final fechaCreacion =
              data['fechaCreacion'] != null
                  ? (data['fechaCreacion'] as Timestamp).toDate()
                  : DateTime.now();

          // 6. Crear preview
          lista.add(
            ChatPreviewModel(
              chatId: doc.id,
              campo: campo,
              activo: activo,
              contacto: contacto,
              estado: data['estado'] ?? 'activo',
              fechaCreacion: fechaCreacion,
            ),
          );
        }

        return lista;
      },
    );
  }
}