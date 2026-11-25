import 'campo_model.dart';
import 'user_model.dart';

import 'activos/activo_agro_model_v2.dart';
import 'activos/activo_publico_model.dart';


class ChatPreviewModel {

  final String chatId;


  /// Campo del sistema anterior.
  final Campo? campo;


  /// Activo Agro del sistema V2.
  final ActivoAgroV2? activo;

  /// Resumen público del Activo: es lo que ve quien NO es el dueño
  /// (el comprador o interesado no puede leer el expediente privado).
  final ActivoPublico? resumen;


  final UserModel contacto;


  final String estado;


  final DateTime fechaCreacion;



  ChatPreviewModel({

    required this.chatId,

    this.campo,

    this.activo,

    this.resumen,

    required this.contacto,

    required this.estado,

    required this.fechaCreacion,

  });



  /// Nombre del activo/campo que se muestra en la conversación.
  String get nombreActivo {

    if (activo != null) {

      return activo!.nombre;

    }


    if (resumen != null) {

      return resumen!.nombre;

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


    if (resumen != null) {

      return resumen!.provincia;

    }


    return '';

  }



  /// Superficie en hectáreas.
  double get hectareas {

    if (campo != null) {

      return campo!.hectareas.toDouble();

    }


    if (activo != null) {

      // QA 25/11/2026: superficie total del campo (antes tomaba la de la
      // actividad principal y mostraba 0).
      return activo!.ubicacion.superficie;

    }


    if (resumen != null) {

      return resumen!.superficie;

    }


    return 0;

  }


  /// QA 25/11/2026: "Saladillo, Buenos Aires" (localidad y provincia).
  String get ubicacionTexto {
    String localidad = '';
    if (campo != null) {
      localidad = campo!.localidad;
    } else if (activo != null) {
      localidad = activo!.ubicacion.localidad;
    } else if (resumen != null) {
      localidad = resumen!.localidad;
    }
    return [localidad, provincia]
        .where((t) => t.trim().isNotEmpty)
        .join(', ');
  }
}
