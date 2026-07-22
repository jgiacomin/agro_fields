import 'campo_model.dart';
import 'user_model.dart';


class ChatPreviewModel {

  final String chatId;

  final Campo campo;

  final UserModel contacto;

  final String estado;

  final DateTime fechaCreacion;


  ChatPreviewModel({

    required this.chatId,

    required this.campo,

    required this.contacto,

    required this.estado,

    required this.fechaCreacion,

  });

}