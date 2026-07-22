import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/activo_agro_test_data.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';


void main(){


  test(
    'Activo Agro V2 serializa correctamente',
    () {


      final activo =
      ActivoAgroTestData.crearGranjaAvicola();



      final mapa =
      activo.toMap();



      expect(
        mapa['modeloVersion'],
        2,
      );



      final recuperado =
      ActivoAgroV2.fromMap(
        mapa,
        activo.activoId,
      );



      expect(
        recuperado.nombre,
        activo.nombre,
      );


      expect(
        recuperado.producciones.length,
        1,
      );


    },
  );


}