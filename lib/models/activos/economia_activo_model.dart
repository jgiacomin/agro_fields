import 'package:cloud_firestore/cloud_firestore.dart';


class EconomiaActivo {


  // ==========================
  // NUEVA TRAZABILIDAD ECONÓMICA V8
  // ==========================


  /// Objetivo general declarado del proyecto
  final String objetivoProyecto;


  /// Etapa actual del proyecto
  /// Ejemplo:
  /// idea, inicial, producción, expansión
  final String etapaProyecto;


  /// Capital esperado para desarrollar el proyecto
  final double inversionEsperada;


  /// Capacidad productiva actual declarada
  final String capacidadActual;


  /// Capacidad productiva proyectada
  final String capacidadProyectada;


  /// Riesgos identificados por el responsable
  final String riesgosIdentificados;


  /// Fuente de la información económica
  /// productor, propietario, profesional, auditoría
  final String origenInformacion;


  /// Persona responsable de declarar la información
  final String responsableDeclaracion;




  // ==========================
  // CAMPOS ECONÓMICOS EXISTENTES
  // ==========================


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

    required this.objetivoProyecto,

    required this.etapaProyecto,

    required this.inversionEsperada,

    required this.capacidadActual,

    required this.capacidadProyectada,

    required this.riesgosIdentificados,

    required this.origenInformacion,

    required this.responsableDeclaracion,


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


      objetivoProyecto:
      map['objetivoProyecto'] ?? '',


      etapaProyecto:
      map['etapaProyecto'] ?? '',


      inversionEsperada:
      (map['inversionEsperada'] ?? 0).toDouble(),


      capacidadActual:
      map['capacidadActual'] ?? '',


      capacidadProyectada:
      map['capacidadProyectada'] ?? '',


      riesgosIdentificados:
      map['riesgosIdentificados'] ?? '',


      origenInformacion:
      map['origenInformacion'] ?? '',


      responsableDeclaracion:
      map['responsableDeclaracion'] ?? '',




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


      // Nueva trazabilidad V8

      'objetivoProyecto':
      objetivoProyecto,


      'etapaProyecto':
      etapaProyecto,


      'inversionEsperada':
      inversionEsperada,


      'capacidadActual':
      capacidadActual,


      'capacidadProyectada':
      capacidadProyectada,


      'riesgosIdentificados':
      riesgosIdentificados,


      'origenInformacion':
      origenInformacion,


      'responsableDeclaracion':
      responsableDeclaracion,




      // Economía existente

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





  factory EconomiaActivo.inicial(){

    return EconomiaActivo(


      objetivoProyecto:
      '',


      etapaProyecto:
      'inicial',


      inversionEsperada:
      0,


      capacidadActual:
      '',


      capacidadProyectada:
      '',


      riesgosIdentificados:
      '',


      origenInformacion:
      'productor',


      responsableDeclaracion:
      '',




      valorSolicitado:
      0,


      moneda:
      'USD',


      tipoOperacion:
      '',


      capitalRequerido:
      0,


      ingresosEstimados:
      '',


      costosEstimados:
      '',


      rentabilidadDeclarada:
      '',


      periodoEvaluacion:
      '',


      datosEconomicos:
      {},


      fechaActualizacion:
      DateTime.now(),

    );

  }


}