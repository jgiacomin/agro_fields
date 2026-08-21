import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/activo_agro_test_data.dart';
import '../lib/models/activos/activo_agro_model_v2.dart';

void main() {
  test('Activo Agro V2 - serialización completa', () {
    print('🌱 INICIO TEST ACTIVO AGRO V2');

    // Crear activo
    final activo =
        ActivoAgroTestData.crearGranjaAvicola();

    print('Activo creado: ${activo.nombre}');

    // Convertir a Map
    final mapa = activo.toMap();

    print('Map generado:');
    print(mapa);

    // Recuperar modelo
    final activoRecuperado =
        ActivoAgroV2.fromMap(
      mapa,
      activo.activoId,
    );

    print('Activo recuperado:');
    print(activoRecuperado.nombre);
    print(activoRecuperado.tipoActivo);

    // Validaciones
    expect(
      activoRecuperado.nombre,
      activo.nombre,
    );

    expect(
      activoRecuperado.tipoActivo,
      activo.tipoActivo,
    );

    expect(
      activoRecuperado.producciones.length,
      activo.producciones.length,
    );

    print('Producciones: ${activoRecuperado.producciones.length}');
  });
}