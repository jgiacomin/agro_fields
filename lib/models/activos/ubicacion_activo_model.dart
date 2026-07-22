class UbicacionActivo {


  // ==========================
  // IDENTIDAD TERRITORIAL
  // ==========================

  final String pais;

  final String provincia;

  final String departamento;

  final String localidad;

  final String codigoPostal;



  // ==========================
  // COORDENADAS
  // ==========================

  final double latitud;

  final double longitud;


  final double superficie;



  // ==========================
  // CONTEXTO PRODUCTIVO
  // ==========================

  final String regionProductiva;

  final String tipoZona;

  final String descripcionEntorno;



  // ==========================
  // INFRAESTRUCTURA
  // ==========================

  final String accesoCaminos;

  final String disponibilidadServicios;



  // ==========================
  // CONTEXTO INTERNACIONAL
  // ==========================

  final String jurisdiccionLegal;

  final String zonaHoraria;

  final String monedaLocal;



  UbicacionActivo({

    required this.pais,

    required this.provincia,

    required this.departamento,

    required this.localidad,

    required this.codigoPostal,


    required this.latitud,

    required this.longitud,

    required this.superficie,


    required this.regionProductiva,

    required this.tipoZona,

    required this.descripcionEntorno,


    required this.accesoCaminos,

    required this.disponibilidadServicios,


    required this.jurisdiccionLegal,

    required this.zonaHoraria,

    required this.monedaLocal,

  });





  factory UbicacionActivo.fromMap(
      Map<String,dynamic> map){

    return UbicacionActivo(


      pais:
      map['pais'] ?? '',


      provincia:
      map['provincia'] ?? '',


      departamento:
      map['departamento'] ?? '',


      localidad:
      map['localidad'] ?? '',


      codigoPostal:
      map['codigoPostal'] ?? '',



      latitud:
      (map['latitud'] ?? 0).toDouble(),


      longitud:
      (map['longitud'] ?? 0).toDouble(),


      superficie:
      (map['superficie'] ?? 0).toDouble(),



      regionProductiva:
      map['regionProductiva'] ?? '',


      tipoZona:
      map['tipoZona'] ?? '',


      descripcionEntorno:
      map['descripcionEntorno'] ?? '',



      accesoCaminos:
      map['accesoCaminos'] ?? '',


      disponibilidadServicios:
      map['disponibilidadServicios'] ?? '',



      jurisdiccionLegal:
      map['jurisdiccionLegal'] ?? '',


      zonaHoraria:
      map['zonaHoraria'] ?? '',


      monedaLocal:
      map['monedaLocal'] ?? '',

    );

  }





  Map<String,dynamic> toMap(){

    return {


      'pais':
      pais,


      'provincia':
      provincia,


      'departamento':
      departamento,


      'localidad':
      localidad,


      'codigoPostal':
      codigoPostal,



      'latitud':
      latitud,


      'longitud':
      longitud,


      'superficie':
      superficie,



      'regionProductiva':
      regionProductiva,


      'tipoZona':
      tipoZona,


      'descripcionEntorno':
      descripcionEntorno,



      'accesoCaminos':
      accesoCaminos,


      'disponibilidadServicios':
      disponibilidadServicios,



      'jurisdiccionLegal':
      jurisdiccionLegal,


      'zonaHoraria':
      zonaHoraria,


      'monedaLocal':
      monedaLocal,

    };

  }


}