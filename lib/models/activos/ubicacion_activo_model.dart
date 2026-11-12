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



  // =====================================================
  // AF-090 — UBICACIÓN EN EL MAPA (12/11/2026)
  // =====================================================

  /// Las coordenadas son posibles en el planeta.
  static bool coordenadasValidas(double latitud, double longitud) {
    return latitud >= -90 &&
        latitud <= 90 &&
        longitud >= -180 &&
        longitud <= 180;
  }

  /// El campo tiene su punto marcado en el mapa.
  /// 0 y 0 (lo que se guardaba al crear el campo) es "sin ubicación":
  /// lo desconocido no se toma como dato.
  bool get tieneCoordenadas =>
      !(latitud == 0 && longitud == 0) &&
      coordenadasValidas(latitud, longitud);

  /// Copia con el punto nuevo; el resto de la ubicación no cambia.
  UbicacionActivo conCoordenadas(double nuevaLatitud, double nuevaLongitud) {
    if (!coordenadasValidas(nuevaLatitud, nuevaLongitud)) {
      throw ArgumentError('Coordenadas fuera de rango.');
    }
    return UbicacionActivo(
      pais: pais,
      provincia: provincia,
      departamento: departamento,
      localidad: localidad,
      codigoPostal: codigoPostal,
      latitud: nuevaLatitud,
      longitud: nuevaLongitud,
      superficie: superficie,
      regionProductiva: regionProductiva,
      tipoZona: tipoZona,
      descripcionEntorno: descripcionEntorno,
      accesoCaminos: accesoCaminos,
      disponibilidadServicios: disponibilidadServicios,
      jurisdiccionLegal: jurisdiccionLegal,
      zonaHoraria: zonaHoraria,
      monedaLocal: monedaLocal,
    );
  }
}
