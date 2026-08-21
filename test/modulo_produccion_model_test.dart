import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/modulo_produccion_model.dart';
import '../lib/models/activos/ciclo_productivo_model.dart';

void main() {
  group('ModuloProduccion', () {
    test('serializa y recupera capacidad productiva', () {
      final modulo = ModuloProduccion(
        id: 'prod_001',
        activoAgroId: 'activo_001',
        dominio: 'produccion animal',
        actividad: 'Gallinas ponedoras',
        descripcion: 'Producción de huevos',
        superficie: 5.0,
        unidad: 'hectareas',

        capacidadActual: 5000,
        capacidadMaxima: 8000,

        activo: true,

        datos: {'cantidadAves': 5000, 'sistema': 'semi intensivo'},

        // Nuevo en V8
        ciclos: [
          CicloProductivo(
            cicloId: 'ciclo_001',
            activoAgroId: 'activo_001',
            moduloProduccionId: 'prod_001',
            fechaInicio: DateTime(2026, 1, 1),
            fechaFin: DateTime(2026, 6, 30),
            campania: '2026',
            produccionObtenida: 3500,
            unidadProduccion: 'kg',
            observaciones: 'Ciclo productivo de prueba',
          ),
        ],
      );

      final mapa = modulo.toMap();

      final recuperado = ModuloProduccion.fromMap(mapa);

      expect(recuperado.ciclos.length, 1);

      expect(recuperado.ciclos.first.cicloId, 'ciclo_001');

      expect(recuperado.ciclos.first.campania, '2026');

      expect(recuperado.ciclos.first.produccionObtenida, 3500);

      expect(recuperado.ciclos.first.unidadProduccion, 'kg');
      expect(recuperado.capacidadActual, 5000);

      expect(recuperado.capacidadMaxima, 8000);

      expect(recuperado.activo, true);

      expect(recuperado.dominio, 'produccion animal');

      expect(recuperado.actividad, 'Gallinas ponedoras');
    });

    test('mantiene compatibilidad con registros antiguos', () {
      final registroAntiguo = {
        'id': 'prod_old_001',
        'activoAgroId': 'activo_001',
        'dominio': 'agricultura',
        'actividad': 'Soja',
        'descripcion': 'Producción agrícola',
        'superficie': 100,
        'unidad': 'hectareas',
        'datos': {'campaña': '2025/2026'},
      };

      final modulo = ModuloProduccion.fromMap(registroAntiguo);

      expect(modulo.capacidadActual, isNull);

      expect(modulo.capacidadMaxima, isNull);

      expect(modulo.activo, true);

      expect(modulo.actividad, 'Soja');

      // Un registro antiguo no tiene ciclos.
      // Debe recuperarse correctamente con lista vacía.
      expect(modulo.ciclos, isEmpty);
    });
  });
}
