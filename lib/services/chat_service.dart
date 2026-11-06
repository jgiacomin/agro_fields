import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/chat_preview_model.dart';
import '../models/activos/activo_agro_model_v2.dart';
import '../models/activos/activo_publico_model.dart';
import '../models/campo_model.dart';

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

          final esDueno =
              data['propietarioId'] == uid;

          // 1. Buscar primero en Campos V1 (sistema anterior).
          //    Si las reglas no dejan leerlo, se sigue buscando.
          Campo? campo;
          try {
            campo = await campoService.obtenerCampoPorId(
              campoId,
            );
          } on FirebaseException {
            campo = null;
          }

          // 2. Si no es un Campo V1, buscar el Activo Agro V2:
          //    - el dueño lee su expediente;
          //    - el interesado lee SOLO el resumen público (paso 1:
          //      el expediente privado no se comparte).
          // 3. Si no se encuentra nada (por ejemplo, la publicación se
          //    pausó), la conversación se muestra igual, sin datos del campo.
          ActivoAgroV2? activo;
          ActivoPublico? resumen;

          if (campo == null) {
            try {
              if (esDueno) {
                activo = await activoService.obtenerActivoPorId(
                  campoId,
                );
              } else {
                final resumenDoc = await _firestore
                    .collection('activos_publicos')
                    .doc(campoId)
                    .get();

                if (resumenDoc.exists && resumenDoc.data() != null) {
                  resumen = ActivoPublico.fromMap(
                    resumenDoc.data()!,
                    resumenDoc.id,
                  );
                }
              }
            } on FirebaseException {
              activo = null;
              resumen = null;
            }
          }

          // 4. Determinar el otro participante
          final contactoId = esDueno
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
              resumen: resumen,
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