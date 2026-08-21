import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/activo_agro_model_v2.dart';
import '../lib/models/activos/modulo_produccion_model.dart';
import '../lib/models/activos/ciclo_productivo_model.dart';

void main() {
  test(
    'Activo Agro V2 integra producción y ciclos productivos',
    () {
      final ciclo = CicloProductivo(
        cicloId: 'ciclo_001',
        activoAgroId: 'activo_001',
        moduloProduccionId: 'prod_001',
        fechaInicio: DateTime(2026, 1, 1),
        fechaFin: DateTime(2026, 6, 30),
        campania: '2026',
        produccionObtenida: 12000,
        unidadProduccion: 'kg',
        observaciones: 'Ciclo de prueba',
      );

      final modulo = ModuloProduccion(
        id: 'prod_001',
        activoAgroId: 'activo_001',
        dominio: 'agricultura',
        actividad: 'Soja',
        descripcion: 'Producción de soja',
        superficie: 100,
        unidad: 'hectareas',
        capacidadActual: 100,
        capacidadMaxima: 150,
        activo: true,
        datos: {
          'campania': '2026',
        },
        ciclos: [
          ciclo,
        ],
      );

      final mapaModulo = modulo.toMap();

      final moduloRecuperado =
          ModuloProduccion.fromMap(mapaModulo);

      expect(
        moduloRecuperado.ciclos.length,
        1,
      );

      expect(
        moduloRecuperado.ciclos.first.cicloId,
        'ciclo_001',
      );

      expect(
        moduloRecuperado.ciclos.first.produccionObtenida,
        12000,
      );

      expect(
        moduloRecuperado.ciclos.first.unidadProduccion,
        'kg',
      );
    },
  );
}