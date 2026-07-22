import 'package:cloud_firestore/cloud_firestore.dart';


class DocumentacionActivo {


  final bool documentacionCompleta;


  final List<String> documentos;


  final List<String> certificaciones;


  final List<String> permisos;


  final List<String> archivos;


  final String observaciones;


  final DateTime fechaActualizacion;



  DocumentacionActivo({

    required this.documentacionCompleta,

    required this.documentos,

    required this.certificaciones,

    required this.permisos,

    required this.archivos,

    required this.observaciones,

    required this.fechaActualizacion,

  });



  factory DocumentacionActivo.fromMap(
      Map<String,dynamic> map
      ){

    return DocumentacionActivo(

      documentacionCompleta:
      map['documentacionCompleta'] ?? false,


      documentos:
      List<String>.from(
        map['documentos'] ?? []
      ),


      certificaciones:
      List<String>.from(
        map['certificaciones'] ?? []
      ),


      permisos:
      List<String>.from(
        map['permisos'] ?? []
      ),


      archivos:
      List<String>.from(
        map['archivos'] ?? []
      ),


      observaciones:
      map['observaciones'] ?? '',


      fechaActualizacion:
      map['fechaActualizacion'] is Timestamp
          ? (map['fechaActualizacion'] as Timestamp).toDate()
          : map['fechaActualizacion'] is DateTime
              ? map['fechaActualizacion']
              : DateTime.now(),

    );

  }




    Map<String,dynamic> toMap(){

    return {

      'documentacionCompleta':
      documentacionCompleta,

      'documentos':
      documentos,

      'certificaciones':
      certificaciones,

      'permisos':
      permisos,

      'archivos':
      archivos,

      'observaciones':
      observaciones,

      'fechaActualizacion':
      fechaActualizacion,

    };

  }


  factory DocumentacionActivo.inicial() {

    return DocumentacionActivo(

      documentacionCompleta: false,

      documentos: [],

      certificaciones: [],

      permisos: [],

      archivos: [],

      observaciones: '',

      fechaActualizacion:
      DateTime.now(),

    );

  }


}