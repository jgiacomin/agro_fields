import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/recurso_agro_model.dart';
import 'package:agro_fields/screens/stock/stock_textos.dart';

RecursoAgro producto({double actual = 100, double minimo = 20}) => RecursoAgro(
      recursoId: 'r1',
      activoAgroId: 'a1',
      tipo: 'agroquimico',
      nombre: 'Glifosato 66%',
      descripcion: '',
      unidad: 'l',
      cantidadActual: actual,
      cantidadMinima: minimo,
      estado: 'disponible',
    );

void main() {
  group('Stock e insumos (GAP-STOCK-01)', () {
    test('stock bajo: en el mínimo o debajo', () {
      expect(producto(actual: 100, minimo: 20).stockBajo, isFalse);
      expect(producto(actual: 20, minimo: 20).stockBajo, isTrue);
      expect(producto(actual: 5, minimo: 20).stockBajo, isTrue);
    });

    test('sin mínimo cargado nunca avisa', () {
      expect(producto(actual: 0, minimo: 0).stockBajo, isFalse);
    });

    test('un recurso viejo (sin datos de stock) se lee igual', () {
      final viejo = RecursoAgro.fromMap(
          {'activoAgroId': 'a1', 'tipo': 'herramienta', 'nombre': 'Pala'},
          'r0');
      expect(viejo.cantidadActual, 0);
      expect(viejo.stockBajo, isFalse);
      expect(nombreTipoRecurso(viejo.tipo), 'Herramienta');
    });

    test('tipos y unidades de la pantalla tienen nombre claro', () {
      for (final t in tiposRecursoStock) {
        expect(nombreTipoRecurso(t), isNot('Sin tipo'));
      }
      for (final u in unidadesStock) {
        expect(nombreUnidadStock(u), isNotEmpty);
      }
      expect(nombreTipoRecurso(null), 'Sin tipo');
    });

    test('números: entiende la unidad y muestra miles con punto', () {
      expect(leerNumero('200 l'), 200);
      expect(leerNumero('2,5'), 2.5);
      expect(leerNumero('mucho'), isNull);
      expect(numeroStock(1500), '1.500');
      expect(numeroStock(2.5), '2,5');
      expect(numeroStock(1234567.25), '1.234.567,25');
    });

    test('errores del servicio en lenguaje claro', () {
      expect(
          mensajeErrorStock(StateError(
              'El movimiento dejaría el stock por debajo de cero.')),
          'No alcanza el stock para ese movimiento.');
    });
  });
}
