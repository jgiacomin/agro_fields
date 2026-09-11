import 'package:cloud_firestore/cloud_firestore.dart';
import 'documento_activo_model.dart';

class DocumentacionActivo {


  final bool documentacionCompleta;


  final List<String> documentos;


  final List<String> certificaciones;


  final List<String> permisos;


  final List<String> archivos;

  final List<DocumentoActivo> documentosEstructurados;


  final String observaciones;


  final DateTime fechaActualizacion;



  DocumentacionActivo({

    required this.documentacionCompleta,

    required this.documentos,

    required this.certificaciones,

    required this.permisos,

    required this.archivos,

    this.documentosEstructurados = const [],

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

       documentosEstructurados:
(map['documentosEstructurados'] as List<dynamic>? ?? [])
    .map(
      (item) => DocumentoActivo.fromMap(
        Map<String, dynamic>.from(item),
        item['documentoId'] ?? '',
      ),
    )
    .toList(),
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

      'documentosEstructurados':
       documentosEstructurados
    .map((documento) => documento.toMap())
    .toList(),

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

      documentosEstructurados: const [],

    );

  }


}