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

  /// AF-146 (27/11/2026): "¿Cómo están las hectáreas?" (declarado por quien
  /// carga el campo; 0 = sin dato).
  final double haLimpias;
  final double haAgricolas;
  final double haGanaderas;
  final double haMonte;

  bool get tieneDistribucion =>
      haLimpias > 0 || haAgricolas > 0 || haGanaderas > 0 || haMonte > 0;

  static double _num(dynamic v) => v is num ? v.toDouble() : 0;



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
    this.haLimpias = 0,
    this.haAgricolas = 0,
    this.haGanaderas = 0,
    this.haMonte = 0,

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

      haLimpias: _num(map['haLimpias']),
      haAgricolas: _num(map['haAgricolas']),
      haGanaderas: _num(map['haGanaderas']),
      haMonte: _num(map['haMonte']),

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

      'haLimpias': haLimpias,
      'haAgricolas': haAgricolas,
      'haGanaderas': haGanaderas,
      'haMonte': haMonte,

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
      haLimpias: haLimpias,
      haAgricolas: haAgricolas,
      haGanaderas: haGanaderas,
      haMonte: haMonte,
    );
  }
}
