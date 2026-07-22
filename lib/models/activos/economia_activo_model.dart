import 'package:cloud_firestore/cloud_firestore.dart';


class EconomiaActivo {


  final double valorSolicitado;

  final String moneda;

  final String tipoOperacion;


  final double capitalRequerido;


  final String ingresosEstimados;

  final String costosEstimados;


  final String rentabilidadDeclarada;


  final String periodoEvaluacion;


  final Map<String,dynamic> datosEconomicos;


  final DateTime fechaActualizacion;



  EconomiaActivo({

    required this.valorSolicitado,

    required this.moneda,

    required this.tipoOperacion,

    required this.capitalRequerido,

    required this.ingresosEstimados,

    required this.costosEstimados,

    required this.rentabilidadDeclarada,

    required this.periodoEvaluacion,

    required this.datosEconomicos,

    required this.fechaActualizacion,

  });



  factory EconomiaActivo.fromMap(
      Map<String,dynamic> map
      ){

    return EconomiaActivo(

      valorSolicitado:
      (map['valorSolicitado'] ?? 0).toDouble(),


      moneda:
      map['moneda'] ?? 'USD',


      tipoOperacion:
      map['tipoOperacion'] ?? '',


      capitalRequerido:
      (map['capitalRequerido'] ?? 0).toDouble(),


      ingresosEstimados:
      map['ingresosEstimados'] ?? '',


      costosEstimados:
      map['costosEstimados'] ?? '',


      rentabilidadDeclarada:
      map['rentabilidadDeclarada'] ?? '',


      periodoEvaluacion:
      map['periodoEvaluacion'] ?? '',


      datosEconomicos:
      Map<String,dynamic>.from(
        map['datosEconomicos'] ?? {}
      ),


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

      'valorSolicitado':
      valorSolicitado,

      'moneda':
      moneda,

      'tipoOperacion':
      tipoOperacion,

      'capitalRequerido':
      capitalRequerido,

      'ingresosEstimados':
      ingresosEstimados,

      'costosEstimados':
      costosEstimados,

      'rentabilidadDeclarada':
      rentabilidadDeclarada,

      'periodoEvaluacion':
      periodoEvaluacion,

      'datosEconomicos':
      datosEconomicos,

      'fechaActualizacion':
      fechaActualizacion,

    };

  }


  factory EconomiaActivo.inicial() {

    return EconomiaActivo(

      valorSolicitado: 0,

      moneda: 'USD',

      tipoOperacion: '',

      capitalRequerido: 0,

      ingresosEstimados: '',

      costosEstimados: '',

      rentabilidadDeclarada: '',

      periodoEvaluacion: '',

      datosEconomicos: {},

      fechaActualizacion:
      DateTime.now(),

    );

  }


}