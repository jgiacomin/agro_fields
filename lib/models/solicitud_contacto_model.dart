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

  /// GAP-MERC-01 Parte C (24/11/2026): lo que el interesado elige
  /// compartir con el dueño (el dueño no puede leer su cuenta).
  final String interesadoNombre;
  final String? interesadoTelefono;
  final String? mensaje;




  SolicitudContacto({

    required this.solicitudId,

    required this.campoId,

    required this.interesadoId,

    required this.propietarioId,

    required this.tipoInteres,

    required this.estado,

    this.chatId,

    required this.fechaCreacion,
    this.interesadoNombre = '',
    this.interesadoTelefono,
    this.mensaje,
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
      interesadoNombre: map['interesadoNombre'] as String? ?? '',
      interesadoTelefono: map['interesadoTelefono'] as String?,
      mensaje: map['mensaje'] as String?,


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
      'interesadoNombre':
          interesadoNombre,
      'interesadoTelefono':
          interesadoTelefono,
      'mensaje':
          mensaje,


    };


  }



}