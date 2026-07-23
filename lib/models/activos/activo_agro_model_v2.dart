import 'package:cloud_firestore/cloud_firestore.dart';

import 'tipo_activo.dart';
import 'estado_activo.dart';

import 'ubicacion_activo_model.dart';
import 'modulo_produccion_model.dart';
import 'madurez_activo_model.dart';

import 'confianza_activo_model.dart';
import 'economia_activo_model.dart';
import 'documentacion_activo_model.dart';
import 'evaluacion_confianza_model.dart';
import 'participante_activo_model.dart';
import 'historial_activo_model.dart';


class ActivoAgroV2 {

  static const int modeloVersion = 2;


  // Identidad
  final String activoId;

  final String nombre;

  final String descripcion;



  // Clasificación
  final TipoActivo tipoActivo;

  final List<String> categorias;



  // Ubicación
  final UbicacionActivo ubicacion;



  // Producción
  final List<ModuloProduccion> producciones;



  // Economía
  final EconomiaActivo economia;



  // Documentación
  final DocumentacionActivo documentacion;



  // Confianza
  final ConfianzaActivo confianza;



  // Evaluación
  final EvaluacionConfianza evaluacion;



  // Madurez
  final MadurezActivo madurez;



  // Participantes del ecosistema
  final List<ParticipanteActivo> participantes;



  // Usuarios relacionados

  /// Dueño real del activo
  final String propietarioId;


  /// Usuario que creó el registro
  final String creadorId;


  /// Usuario que publica o administra comercialmente
  final String publicadorId;


  /// propietario, arrendatario, administrador, representante
  final String tipoRelacionPropietario;



  // Estado interno del activo
  final EstadoActivo estado;



  // Estado comercial

  /// borrador, publicado, pausado, cerrado
  final String estadoPublicacion;



  /// Permite separar existencia del activo de su exposición pública
  final bool visible;



  // Historial
  final List<HistorialActivo> historial;



  // Auditoría

  final String hashActivo;


  final int versionDatos;


  final DateTime fechaCreacion;


  final DateTime ultimaActualizacion;





  ActivoAgroV2({

    required this.activoId,

    required this.nombre,

    required this.descripcion,

    required this.tipoActivo,

    required this.categorias,

    required this.ubicacion,

    required this.producciones,

    required this.economia,

    required this.documentacion,

    required this.confianza,

    required this.evaluacion,

    required this.madurez,

    required this.participantes,

    required this.propietarioId,

    required this.creadorId,

    required this.publicadorId,

    required this.tipoRelacionPropietario,

    required this.estado,

    required this.estadoPublicacion,

    required this.visible,

    required this.historial,

    required this.hashActivo,

    required this.versionDatos,

    required this.fechaCreacion,

    required this.ultimaActualizacion,

  });





  ModuloProduccion? get produccionPrincipal {

    if(producciones.isEmpty){

      return null;

    }

    return producciones.first;

  }






  factory ActivoAgroV2.fromMap(
      Map<String,dynamic> map,
      String id,
      ){

    return ActivoAgroV2(

      activoId: id,


      nombre: map['nombre'] ?? '',


      descripcion: map['descripcion'] ?? '',



      tipoActivo:

      TipoActivo.values.firstWhere(

            (e)=>e.name == map['tipoActivo'],

        orElse: ()=>TipoActivo.otro,

      ),



      categorias:

      List<String>.from(

        map['categorias'] ?? [],

      ),



      ubicacion:

      UbicacionActivo.fromMap(

        Map<String,dynamic>.from(

          map['ubicacion'] ?? {},

        ),

      ),



      producciones:

      (map['producciones'] ?? [])

          .map<ModuloProduccion>(

            (e)=>

            ModuloProduccion.fromMap(

              Map<String,dynamic>.from(e),

            ),

      )

          .toList(),



      economia:

      EconomiaActivo.fromMap(

        Map<String,dynamic>.from(

          map['economia'] ?? {},

        ),

      ),



      documentacion:

      DocumentacionActivo.fromMap(

        Map<String,dynamic>.from(

          map['documentacion'] ?? {},

        ),

      ),



      confianza:

      ConfianzaActivo.fromMap(

        Map<String,dynamic>.from(

          map['confianza'] ?? {},

        ),

      ),



      evaluacion:

      EvaluacionConfianza.fromMap(

        Map<String,dynamic>.from(

          map['evaluacion'] ?? {},

        ),

      ),



      madurez:

      MadurezActivo.fromMap(

        Map<String,dynamic>.from(

          map['madurez'] ?? {},

        ),

      ),



      participantes:

      (map['participantes'] ?? [])

          .map<ParticipanteActivo>(

            (e)=>

            ParticipanteActivo.fromMap(

              Map<String,dynamic>.from(e),

            ),

      )

          .toList(),



      propietarioId:

      map['propietarioId'] ?? '',



      creadorId:

      map['creadorId'] ?? '',



      publicadorId:

      map['publicadorId'] ?? map['creadorId'] ?? '',



      tipoRelacionPropietario:

      map['tipoRelacionPropietario'] ?? 'propietario',



      estado:

      EstadoActivo.values.firstWhere(

            (e)=>e.name == map['estado'],

        orElse: ()=>EstadoActivo.borrador,

      ),



      estadoPublicacion:

      map['estadoPublicacion'] ?? 'borrador',



      visible:

      map['visible'] ?? false,



      historial:

      (map['historial'] ?? [])

          .map<HistorialActivo>(

            (e)=>

            HistorialActivo.fromMap(

              Map<String,dynamic>.from(e),

              e['eventoId'] ?? '',

            ),

      )

          .toList(),



      hashActivo:

      map['hashActivo'] ?? '',



      versionDatos:

      map['versionDatos'] ?? 1,



      fechaCreacion:

      _leerFecha(map['fechaCreacion']),



      ultimaActualizacion:

      _leerFecha(map['ultimaActualizacion']),


    );

  }





  static DateTime _leerFecha(dynamic valor){

  if(valor is Timestamp){

    return valor.toDate();

  }


  if(valor is DateTime){

    return valor;

  }


  if(valor is String){

    return DateTime.tryParse(valor)
        ?? DateTime.now();

  }


  return DateTime.now();

}




  Map<String,dynamic> toMap(){

    return {


      'modeloVersion':
      modeloVersion,


      'nombre':
      nombre,


      'descripcion':
      descripcion,


      'tipoActivo':
      tipoActivo.name,


      'categorias':
      categorias,


      'ubicacion':
      ubicacion.toMap(),


      'producciones':
      producciones.map((e)=>e.toMap()).toList(),


      'economia':
      economia.toMap(),


      'documentacion':
      documentacion.toMap(),


      'confianza':
      confianza.toMap(),


      'evaluacion':
      evaluacion.toMap(),


      'madurez':
      madurez.toMap(),


      'participantes':
      participantes.map((e)=>e.toMap()).toList(),


      'propietarioId':
      propietarioId,


      'creadorId':
      creadorId,


      'publicadorId':
      publicadorId,


      'tipoRelacionPropietario':
      tipoRelacionPropietario,


      'estado':
      estado.name,


      'estadoPublicacion':
      estadoPublicacion,


      'visible':
      visible,


      'historial':
      historial.map((e)=>e.toMap()).toList(),


      'hashActivo':
      hashActivo,


      'versionDatos':
      versionDatos,


      'fechaCreacion':
      Timestamp.fromDate(fechaCreacion),


      'ultimaActualizacion':
      Timestamp.fromDate(ultimaActualizacion),


    };

  }






  ActivoAgroV2 copyWith({

    String? nombre,

    String? descripcion,

    TipoActivo? tipoActivo,

    List<String>? categorias,

    UbicacionActivo? ubicacion,

    List<ModuloProduccion>? producciones,

    EconomiaActivo? economia,

    DocumentacionActivo? documentacion,

    ConfianzaActivo? confianza,

    EvaluacionConfianza? evaluacion,

    MadurezActivo? madurez,

    List<ParticipanteActivo>? participantes,

    EstadoActivo? estado,

    String? estadoPublicacion,

    bool? visible,

  }){


    return ActivoAgroV2(

      activoId: activoId,

      nombre: nombre ?? this.nombre,

      descripcion: descripcion ?? this.descripcion,

      tipoActivo: tipoActivo ?? this.tipoActivo,

      categorias: categorias ?? this.categorias,

      ubicacion: ubicacion ?? this.ubicacion,

      producciones: producciones ?? this.producciones,

      economia: economia ?? this.economia,

      documentacion: documentacion ?? this.documentacion,

      confianza: confianza ?? this.confianza,

      evaluacion: evaluacion ?? this.evaluacion,

      madurez: madurez ?? this.madurez,

      participantes: participantes ?? this.participantes,

      propietarioId: propietarioId,

      creadorId: creadorId,

      publicadorId: publicadorId,

      tipoRelacionPropietario: tipoRelacionPropietario,

      estado: estado ?? this.estado,

      estadoPublicacion:
      estadoPublicacion ?? this.estadoPublicacion,

      visible:
      visible ?? this.visible,

      historial: historial,

      hashActivo: hashActivo,

      versionDatos: versionDatos,

      fechaCreacion: fechaCreacion,

      ultimaActualizacion: DateTime.now(),

    );

  }

}
