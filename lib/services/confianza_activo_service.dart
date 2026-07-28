import '../models/activos/activo_agro_model_v2.dart';
import '../models/activos/evaluacion_confianza_model.dart';
import '../models/activos/factor_confianza_model.dart';



class ConfianzaActivoService {


  int calcularNivel(ActivoAgroV2 activo) {


    int puntos = 0;



    // =====================================================
    // Identidad
    // Peso: 20%
    // =====================================================

    if(
      activo.nombre.isNotEmpty &&
      activo.ubicacion.provincia.isNotEmpty &&
      activo.ubicacion.localidad.isNotEmpty
    ){

      puntos += 20;

    }





    // =====================================================
    // Producción
    // Peso: 20%
    // =====================================================

    if(
      activo.producciones.isNotEmpty
    ){

      puntos += 20;

    }





    // =====================================================
    // Economía
    // Peso: 15%
    // =====================================================

    if(
      activo.economia.valorSolicitado > 0 ||
      activo.economia.capitalRequerido > 0
    ){

      puntos += 15;

    }





    // =====================================================
    // Documentación
    // Peso: 20%
    // =====================================================

    if(
      activo.documentacion.documentacionCompleta
    ){

      puntos += 20;

    }





    // =====================================================
    // Evidencias
    // Peso: 10%
    //
    // Pendiente:
    // incorporar modelo propio de evidencias
    // =====================================================

    // puntos += 10;





    // =====================================================
    // Participantes
    // Peso: 10%
    // =====================================================

    if(
      activo.participantes.isNotEmpty
    ){

      puntos += 10;

    }





    // =====================================================
    // Historial
    // Peso: 5%
    // =====================================================

    if(
      activo.historial.isNotEmpty
    ){

      puntos += 5;

    }





    if(puntos > 100){

      puntos = 100;

    }


    return puntos;

  }


  EvaluacionConfianza generarEvaluacion(
      ActivoAgroV2 activo) {


    final FactorConfianza documental =
    FactorConfianza(
      nivel:
      activo.documentacion.documentacionCompleta
          ? 90
          : 40,

      descripcion:
      "Estado documental del activo",

      evidencias: [],

      fechaActualizacion:
      DateTime.now(),
    );
        final FactorConfianza productivo =
    FactorConfianza(
      nivel:
      activo.producciones.isNotEmpty
          ? 80
          : 30,

      descripcion:
      "Estado de información productiva del activo",

      evidencias: [],

      fechaActualizacion:
      DateTime.now(),
    );
    final FactorConfianza economico =
    FactorConfianza(
      nivel:
      activo.economia.valorSolicitado > 0 ||
      activo.economia.capitalRequerido > 0
          ? 70
          : 30,

      descripcion:
      "Nivel de información económica del activo",

      evidencias: [],

      fechaActualizacion:
      DateTime.now(),
    );
    final FactorConfianza legal =
    FactorConfianza(
      nivel:
      activo.documentacion.documentacionCompleta
          ? 60
          : 20,

      descripcion:
      "Nivel de información legal disponible del activo",

      evidencias: [],

      fechaActualizacion:
      DateTime.now(),
    );
    final FactorConfianza profesional =
    FactorConfianza(
      nivel:
      activo.participantes.isNotEmpty
          ? 50
          : 0,

      descripcion:
      "Participación de personas relacionadas con el activo",

      evidencias: [],

      fechaActualizacion:
      DateTime.now(),
    );
    final int nivelGeneral =
    (
      documental.nivel +
      productivo.nivel +
      economico.nivel +
      legal.nivel +
      profesional.nivel
    ) ~/ 5;


    return EvaluacionConfianza(

      nivelGeneral:
      nivelGeneral,

      documental:
      documental,

      productivo:
      productivo,

      economico:
      economico,

      legal:
      legal,

      profesional:
      profesional,

      fortalezas: [],

      pendientes: [],

      resumen:
      nivelTexto(nivelGeneral),

      responsable:
      "Sistema Agro Fields",

      fechaEvaluacion:
      DateTime.now(),

    );



   
  }



  String nivelTexto(int nivel){


    if(nivel >= 80){

      return "Activo con alta confianza";

    }


    if(nivel >= 50){

      return "Activo con información parcial";

    }


    return "Activo en construcción";

  }


}