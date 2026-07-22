import 'package:cloud_firestore/cloud_firestore.dart';


class ConfianzaActivo {


  final int nivelGeneral;


  // Identidad
  final bool identidadVerificada;


  // Documentación
  final bool documentacionCompleta;


  // Evidencias
  final int cantidadEvidencias;


  // Información técnica
  final bool informacionProductivaCompleta;


  // Personas relacionadas
  final bool participantesVerificados;


  // Control
  final DateTime ultimaVerificacion;


  final String observaciones;



  ConfianzaActivo({

    required this.nivelGeneral,

    required this.identidadVerificada,

    required this.documentacionCompleta,

    required this.cantidadEvidencias,

    required this.informacionProductivaCompleta,

    required this.participantesVerificados,

    required this.ultimaVerificacion,

    required this.observaciones,

  });



  factory ConfianzaActivo.fromMap(
      Map<String,dynamic> map
      ){

    return ConfianzaActivo(

      nivelGeneral:
      map['nivelGeneral'] ?? 0,


      identidadVerificada:
      map['identidadVerificada'] ?? false,


      documentacionCompleta:
      map['documentacionCompleta'] ?? false,


      cantidadEvidencias:
      map['cantidadEvidencias'] ?? 0,


      informacionProductivaCompleta:
      map['informacionProductivaCompleta'] ?? false,


      participantesVerificados:
      map['participantesVerificados'] ?? false,


      ultimaVerificacion:
      map['ultimaVerificacion'] is Timestamp
          ? (map['ultimaVerificacion'] as Timestamp).toDate()
          : map['ultimaVerificacion'] is DateTime
              ? map['ultimaVerificacion']
              : DateTime.now(),


      observaciones:
      map['observaciones'] ?? '',

    );

  }



  Map<String,dynamic> toMap(){

    return {

      'nivelGeneral': nivelGeneral,

      'identidadVerificada':
      identidadVerificada,

      'documentacionCompleta':
      documentacionCompleta,

      'cantidadEvidencias':
      cantidadEvidencias,

      'informacionProductivaCompleta':
      informacionProductivaCompleta,

      'participantesVerificados':
      participantesVerificados,

      'ultimaVerificacion':
      ultimaVerificacion,

      'observaciones':
      observaciones,

    };

  }

}