class FactorConfianza {


  final int porcentaje;


  final bool respaldado;


  final String observaciones;




  FactorConfianza({

    required this.porcentaje,

    required this.respaldado,

    required this.observaciones,

  });





  factory FactorConfianza.fromMap(
      Map<String,dynamic> map){


    return FactorConfianza(

      porcentaje:
      map['porcentaje'] ?? 0,


      respaldado:
      map['respaldado'] ?? false,


      observaciones:
      map['observaciones'] ?? '',

    );


  }






  Map<String,dynamic> toMap(){


    return {

      'porcentaje':
      porcentaje,


      'respaldado':
      respaldado,


      'observaciones':
      observaciones,

    };


  }


}