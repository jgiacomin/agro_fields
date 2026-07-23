import 'package:cloud_firestore/cloud_firestore.dart';

import 'factor_confianza_model.dart';


class EvaluacionConfianza {


  final int nivelGeneral;


  final FactorConfianza documental;


  final FactorConfianza productivo;


  final FactorConfianza economico;


  final FactorConfianza legal;


  final FactorConfianza profesional;


  final List<String> fortalezas;


  final List<String> pendientes;


  final String resumen;


  final String responsable;


  final DateTime fechaEvaluacion;



  EvaluacionConfianza({

    required this.nivelGeneral,

    required this.documental,

    required this.productivo,

    required this.economico,

    required this.legal,

    required this.profesional,

    required this.fortalezas,

    required this.pendientes,

    required this.resumen,

    required this.responsable,

    required this.fechaEvaluacion,

  });



  factory EvaluacionConfianza.fromMap(
      Map<String,dynamic> map){


    return EvaluacionConfianza(

      nivelGeneral:
      map['nivelGeneral'] ?? 0,


      documental:
      FactorConfianza.fromMap(
        map['documental'] ?? {}
      ),


      productivo:
      FactorConfianza.fromMap(
        map['productivo'] ?? {}
      ),


      economico:
      FactorConfianza.fromMap(
        map['economico'] ?? {}
      ),


      legal:
      FactorConfianza.fromMap(
        map['legal'] ?? {}
      ),


      profesional:
      FactorConfianza.fromMap(
        map['profesional'] ?? {}
      ),



      fortalezas:
      List<String>.from(
        map['fortalezas'] ?? []
      ),



      pendientes:
      List<String>.from(
        map['pendientes'] ?? []
      ),



      resumen:
      map['resumen'] ?? '',



      responsable:
      map['responsable'] ?? '',



      fechaEvaluacion:
      map['fechaEvaluacion'] is Timestamp
          ? (map['fechaEvaluacion'] as Timestamp).toDate()
          : map['fechaEvaluacion'] is DateTime
              ? map['fechaEvaluacion']
              : DateTime.now(),

    );

  }





  Map<String,dynamic> toMap(){


    return {


      'nivelGeneral':
      nivelGeneral,


      'documental':
      documental.toMap(),


      'productivo':
      productivo.toMap(),


      'economico':
      economico.toMap(),


      'legal':
      legal.toMap(),


      'profesional':
      profesional.toMap(),



      'fortalezas':
      fortalezas,



      'pendientes':
      pendientes,



      'resumen':
      resumen,



      'responsable':
      responsable,



      'fechaEvaluacion':
      fechaEvaluacion,

    };

  }






  factory EvaluacionConfianza.inicial(){


    return EvaluacionConfianza(


      nivelGeneral: 0,


      documental:
      FactorConfianza.inicial(),


      productivo:
      FactorConfianza.inicial(),


      economico:
      FactorConfianza.inicial(),


      legal:
      FactorConfianza.inicial(),


      profesional:
      FactorConfianza.inicial(),



      fortalezas: [],


      pendientes: [],


      resumen: '',


      responsable: '',


      fechaEvaluacion:
      DateTime.now(),


    );


  }


}
