import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/services/busqueda_lugar.dart';

/// QA (18/11/2026, mejora de AF-090): ubicar el campo sin buscarlo a mano.
void main() {
  group('coordenadasDesdeTexto', () {
    test('coordenadas con punto decimal, separadas por coma o espacio', () {
      for (final texto in ['-35.392, -62.420', '-35.392 -62.420', '-35.392,-62.420']) {
        final p = coordenadasDesdeTexto(texto);
        expect(p, isNotNull, reason: texto);
        expect(p!.latitude, closeTo(-35.392, 0.0001));
        expect(p.longitude, closeTo(-62.420, 0.0001));
      }
    });

    test('coordenadas con coma decimal', () {
      for (final texto in ['-35,392; -62,420', '-35,392 -62,420', '-35,392, -62,420']) {
        final p = coordenadasDesdeTexto(texto);
        expect(p, isNotNull, reason: texto);
        expect(p!.latitude, closeTo(-35.392, 0.0001));
        expect(p.longitude, closeTo(-62.420, 0.0001));
      }
    });

    test('link de Google Maps con @ o con ?q=', () {
      final a = coordenadasDesdeTexto(
          'https://www.google.com/maps/place/Campo/@-35.3921,-62.4205,15z/data=x');
      expect(a!.latitude, closeTo(-35.3921, 0.0001));
      expect(a.longitude, closeTo(-62.4205, 0.0001));

      final b = coordenadasDesdeTexto('https://maps.google.com/?q=-25.2637,-57.5759');
      expect(b!.latitude, closeTo(-25.2637, 0.0001));
      expect(b.longitude, closeTo(-57.5759, 0.0001));
    });

    test('texto sin coordenadas, link corto o números fuera de rango: null', () {
      expect(coordenadasDesdeTexto('Carlos Tejedor'), isNull);
      expect(coordenadasDesdeTexto('https://maps.app.goo.gl/abc123'), isNull);
      expect(coordenadasDesdeTexto('-135.5, -62.4'), isNull);
      expect(coordenadasDesdeTexto(''), isNull);
    });
  });

  group('consultaDesdeUbicacion', () {
    test('une lo cargado, sin repetir y salteando lo vacío', () {
      expect(
        consultaDesdeUbicacion(
          localidad: 'Carlos Tejedor',
          departamento: 'Carlos Tejedor',
          provincia: 'Buenos Aires',
          pais: 'Argentina',
        ),
        'Carlos Tejedor, Buenos Aires, Argentina',
      );
      expect(consultaDesdeUbicacion(provincia: 'Itapúa', pais: 'Paraguay'),
          'Itapúa, Paraguay');
      expect(consultaDesdeUbicacion(), '');
    });
  });
}
