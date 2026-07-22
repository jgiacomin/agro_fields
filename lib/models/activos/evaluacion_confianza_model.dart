import 'package:cloud_firestore/cloud_firestore.dart';


class EvaluacionConfianza {


  final int nivelGeneral;


  final List<String> fortalezas;


  final List<String> pendientes;


  final String resumen;


  final DateTime fechaEvaluacion;



  EvaluacionConfianza({

    required this.nivelGeneral,

    required this.fortalezas,

    required this.pendientes,

    required this.resumen,

    required this.fechaEvaluacion,

  });



  factory EvaluacionConfianza.fromMap(
      Map<String,dynamic> map
      ){

    return EvaluacionConfianza(

      nivelGeneral:
      map['nivelGeneral'] ?? 0,


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

      'fortalezas':
      fortalezas,

      'pendientes':
      pendientes,

      'resumen':
      resumen,

      'fechaEvaluacion':
      fechaEvaluacion,

    };

  }


  factory EvaluacionConfianza.inicial() {

    return EvaluacionConfianza(

      nivelGeneral: 0,

      fortalezas: [],

      pendientes: [],

      resumen: '',

      fechaEvaluacion:
      DateTime.now(),

    );

  }


}