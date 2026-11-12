import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/ubicacion_activo_model.dart';

UbicacionActivo ubicacion({double lat = 0, double lon = 0}) {
  return UbicacionActivo.fromMap({
    'pais': 'Argentina',
    'provincia': 'Córdoba',
    'localidad': 'Cruz del Eje',
    'superficie': 120,
    'latitud': lat,
    'longitud': lon,
  });
}

void main() {
  group('UbicacionActivo - ubicación en el mapa (AF-090)', () {
    test('0 y 0 es "sin ubicación"', () {
      expect(ubicacion().tieneCoordenadas, isFalse);
    });

    test('un punto real cuenta como ubicación marcada', () {
      expect(ubicacion(lat: -30.72, lon: -64.80).tieneCoordenadas, isTrue);
    });

    test('marcar el punto no cambia el resto de la ubicación', () {
      final nueva = ubicacion().conCoordenadas(-25.30, -57.63);

      expect(nueva.latitud, -25.30);
      expect(nueva.longitud, -57.63);
      expect(nueva.provincia, 'Córdoba');
      expect(nueva.localidad, 'Cruz del Eje');
      expect(nueva.superficie, 120);
      expect(nueva.tieneCoordenadas, isTrue);
    });

    test('coordenadas imposibles: error', () {
      expect(() => ubicacion().conCoordenadas(95, 10), throwsArgumentError);
      expect(() => ubicacion().conCoordenadas(10, 200), throwsArgumentError);
    });

    test('se guarda y se lee igual', () {
      final original = ubicacion().conCoordenadas(-27.48, -58.83);
      final leida = UbicacionActivo.fromMap(original.toMap());

      expect(leida.latitud, -27.48);
      expect(leida.longitud, -58.83);
      expect(leida.tieneCoordenadas, isTrue);
    });
  });
}
