class MadurezActivo {

  final double porcentaje;

  final List<String> faltantes;

  final String etapa;

  final String nivelTecnologico;

  final String preparacionInversion;


  MadurezActivo({

    required this.porcentaje,

    required this.faltantes,

    required this.etapa,
      
    required this.nivelTecnologico,

    required this.preparacionInversion,

  });


  factory MadurezActivo.fromMap(
      Map<String,dynamic> map){

    return MadurezActivo(

      porcentaje:
      (map['porcentaje'] ?? 0)
          .toDouble(),

      faltantes:
      List<String>.from(
        map['faltantes'] ?? [],
      ),

      etapa: map['etapa'] ?? '',

      nivelTecnologico: map['nivelTecnologico'] ?? '',

      preparacionInversion: map['preparacionInversion'] ?? '',

    );

  }


  Map<String,dynamic> toMap(){

    return {

      'porcentaje':
      porcentaje,

      'faltantes':
      faltantes,

      'etapa': 
      etapa,

      'nivelTecnologico': 
      nivelTecnologico,

     'preparacionInversion': 
     preparacionInversion,

    };

  }

}