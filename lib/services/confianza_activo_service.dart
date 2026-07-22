import '../models/activos/activo_agro_model_v2.dart';


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