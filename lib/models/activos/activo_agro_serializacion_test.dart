import 'activo_agro_test_data.dart';
import 'activo_agro_model_v2.dart';


void main(){


  print("🌱 INICIO TEST ACTIVO AGRO V2");


  // Crear activo
  final activo =
      ActivoAgroTestData.crearGranjaAvicola();



  print(
    "Activo creado: ${activo.nombre}"
  );



  // Convertir a mapa

  final mapa =
      activo.toMap();



  print(
    "Map generado:"
  );


  print(mapa);



  // Recuperar modelo


  final activoRecuperado =
      ActivoAgroV2.fromMap(
        mapa,
        activo.activoId,
      );



  print(
    "Activo recuperado:"
  );


  print(
    activoRecuperado.nombre
  );


  print(
    activoRecuperado.tipoActivo
  );


  print(
    activoRecuperado.producciones.length
  );


}