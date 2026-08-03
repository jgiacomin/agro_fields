class ModuloProduccion {

  /// Identificador del módulo productivo
  final String? id;

  /// Referencia al Activo Agro V2
  final String? activoAgroId;


  final String dominio;

  final String actividad;

  final String descripcion;

  final double? superficie;

  final String? unidad;

  final Map<String,dynamic> datos;




  ModuloProduccion({

  this.id,

  this.activoAgroId,

  required this.dominio,

  required this.actividad,

  required this.descripcion,

  this.superficie,

  this.unidad,

  required this.datos,

});







  factory ModuloProduccion.fromMap(
      Map<String,dynamic> map){


    return ModuloProduccion(



          id:
  map['id'],

  activoAgroId:
  map['activoAgroId'],

      // Compatibilidad con versión anterior

      dominio:

      map['dominio']

      ??

      map['tipoProduccion']

      ??

      '',





      actividad:

      map['actividad']

      ??

      map['tipoProduccion']

      ??

      '',






      descripcion:

      map['descripcion']

      ??

      '',






      superficie:

      map['superficie'] != null

      ?

      (map['superficie']).toDouble()

      :

      null,






      unidad:

      map['unidad'],







      datos:

      Map<String,dynamic>.from(

        map['datos'] ?? {},

      ),




    );


  }








  Map<String,dynamic> toMap(){


    return {

      'id':
      id,

    'activoAgroId':
     activoAgroId,

      'dominio':

      dominio,



      'actividad':

      actividad,



      'descripcion':

      descripcion,



      'superficie':

      superficie,



      'unidad':

      unidad,



      'datos':

      datos,



    };


  }



}