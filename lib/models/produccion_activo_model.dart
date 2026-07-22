import 'package:cloud_firestore/cloud_firestore.dart';


class ProduccionActivo {


  final String actividadPrincipal;

  final List<String> actividadesSecundarias;


  // Información productiva
  final String descripcionProduccion;

  final String capacidadProductiva;


  // Infraestructura
  final List<String> infraestructura;


  // Equipamiento
  final List<String> equipamiento;


  // Datos técnicos futuros
  final Map<String,dynamic> datosTecnicos;


  final DateTime fechaActualizacion;



  ProduccionActivo({

    required this.actividadPrincipal,

    required this.actividadesSecundarias,

    required this.descripcionProduccion,

    required this.capacidadProductiva,

    required this.infraestructura,

    required this.equipamiento,

    required this.datosTecnicos,

    required this.fechaActualizacion,

  });



  factory ProduccionActivo.fromMap(
      Map<String,dynamic> map
      ){

    return ProduccionActivo(

      actividadPrincipal:
      map['actividadPrincipal'] ?? '',


      actividadesSecundarias:
      List<String>.from(
        map['actividadesSecundarias'] ?? []
      ),


      descripcionProduccion:
      map['descripcionProduccion'] ?? '',


      capacidadProductiva:
      map['capacidadProductiva'] ?? '',


      infraestructura:
      List<String>.from(
        map['infraestructura'] ?? []
      ),


      equipamiento:
      List<String>.from(
        map['equipamiento'] ?? []
      ),


      datosTecnicos:
      Map<String,dynamic>.from(
        map['datosTecnicos'] ?? {}
      ),


      fechaActualizacion:
      map['fechaActualizacion'] != null
          ? (map['fechaActualizacion'] as Timestamp)
              .toDate()
          : DateTime.now(),

    );

  }



    Map<String,dynamic> toMap(){

    return {

      'actividadPrincipal':
      actividadPrincipal,

      'actividadesSecundarias':
      actividadesSecundarias,

      'descripcionProduccion':
      descripcionProduccion,

      'capacidadProductiva':
      capacidadProductiva,

      'infraestructura':
      infraestructura,

      'equipamiento':
      equipamiento,

      'datosTecnicos':
      datosTecnicos,

      'fechaActualizacion':
      fechaActualizacion,

    };

  }


  factory ProduccionActivo.inicial() {

    return ProduccionActivo(

      actividadPrincipal: '',

      actividadesSecundarias: [],

      descripcionProduccion: '',

      capacidadProductiva: '',

      infraestructura: [],

      equipamiento: [],

      datosTecnicos: {},

      fechaActualizacion:
      DateTime.now(),

    );

  }


}