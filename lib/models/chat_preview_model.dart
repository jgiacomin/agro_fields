import 'campo_model.dart';
import 'user_model.dart';

import 'activos/activo_agro_model_v2.dart';


class ChatPreviewModel {

  final String chatId;


  /// Campo del sistema anterior.
  final Campo? campo;


  /// Activo Agro del sistema V2.
  final ActivoAgroV2? activo;


  final UserModel contacto;


  final String estado;


  final DateTime fechaCreacion;



  ChatPreviewModel({

    required this.chatId,

    this.campo,

    this.activo,

    required this.contacto,

    required this.estado,

    required this.fechaCreacion,

  });



  /// Nombre del activo/campo que se muestra en la conversación.
  String get nombreActivo {

    if (activo != null) {

      return activo!.nombre;

    }


    if (campo != null) {

      return campo!.nombre;

    }


    return 'Activo sin nombre';

  }



  /// Provincia del campo o activo.
  String get provincia {

    if (campo != null) {

      return campo!.provincia;

    }


    if (activo != null) {

      return activo!.ubicacion.provincia;

    }


    return '';

  }



  /// Superficie en hectáreas.
  double get hectareas {

    if (campo != null) {

      return campo!.hectareas.toDouble();

    }


    if (activo != null) {

      return activo!.produccionPrincipal
              ?.superficie ??
          0;

    }


    return 0;

  }

}