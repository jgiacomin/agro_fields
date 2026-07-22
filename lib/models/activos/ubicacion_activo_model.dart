class UbicacionActivo {

  final String pais;

  final String provincia;

  final String localidad;

  final double latitud;

  final double longitud;

  final double superficie;


  UbicacionActivo({

    required this.pais,

    required this.provincia,

    required this.localidad,

    required this.latitud,

    required this.longitud,

    required this.superficie,

  });


  factory UbicacionActivo.fromMap(
      Map<String,dynamic> map){

    return UbicacionActivo(

      pais: map['pais'] ?? '',

      provincia: map['provincia'] ?? '',

      localidad: map['localidad'] ?? '',

      latitud:
      (map['latitud'] ?? 0).toDouble(),

      longitud:
      (map['longitud'] ?? 0).toDouble(),

      superficie:
      (map['superficie'] ?? 0).toDouble(),

    );

  }


  Map<String,dynamic> toMap(){

    return {

      'pais': pais,

      'provincia': provincia,

      'localidad': localidad,

      'latitud': latitud,

      'longitud': longitud,

      'superficie': superficie,

    };

  }

}