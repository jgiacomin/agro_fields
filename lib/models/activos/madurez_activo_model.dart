class MadurezActivo {

  final double porcentaje;

  final List<String> faltantes;


  MadurezActivo({

    required this.porcentaje,

    required this.faltantes,

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

    );

  }


  Map<String,dynamic> toMap(){

    return {

      'porcentaje':
      porcentaje,

      'faltantes':
      faltantes,

    };

  }

}