import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/activo_agro_test_data.dart';

void main() {
  group('Activo Agro - preparación del servicio', () {
    test('activo de prueba preparado para el servicio', () {
      final activo =
          ActivoAgroTestData.crearGranjaAvicola();

      expect(
        activo.activoId,
        isNotEmpty,
      );

      expect(
        activo.nombre,
        'Granja Avícola Los Tilos',
      );

      expect(
        activo.producciones,
        isNotEmpty,
      );

      expect(
        activo.producciones.first.ciclos,
        isNotEmpty,
      );

      print(
        '🌱 Activo preparado: ${activo.nombre}',
      );

      print(
        '🌾 Producciones: ${activo.producciones.length}',
      );

      print(
        '🔄 Ciclos: '
        '${activo.producciones.first.ciclos.length}',
      );

      print(
        '✅ Modelo preparado para ActivoAgroServiceV2',
      );
    });
  });
}