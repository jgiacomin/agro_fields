import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/unidad_productiva_model.dart';

void main() {
  final fecha = DateTime(2026, 11, 10);

  group('UnidadProductiva (paso 6a, GAP-PROD-01)', () {
    test('se guarda y se lee igual', () {
      final unidad = UnidadProductiva(
        unidadId: 'u1',
        activoAgroId: 'a1',
        tipo: TipoUnidadProductiva.potrero,
        nombre: 'Potrero 1',
        superficieHa: 45.5,
        capacidad: 60,
        infraestructuraId: 'inf1',
        creadoPor: 'dueno',
        fechaCreacion: fecha,
      );

      final leida = UnidadProductiva.fromMap(unidad.toMap(), 'u1');

      expect(leida.tipo, TipoUnidadProductiva.potrero);
      expect(leida.nombre, 'Potrero 1');
      expect(leida.superficieHa, 45.5);
      expect(leida.capacidad, 60);
      expect(leida.infraestructuraId, 'inf1');
      expect(leida.estado, EstadoUnidadProductiva.activa);
      expect(leida.fechaCreacion, fecha);
    });

    test('lo desconocido no es cero: sin superficie ni capacidad quedan vacias', () {
      final leida = UnidadProductiva.fromMap({
        'activoAgroId': 'a1',
        'tipo': 'corral',
        'nombre': 'Corral',
      }, 'u2');

      expect(leida.superficieHa, isNull);
      expect(leida.capacidad, isNull);
    });

    test('un tipo desconocido se lee como "otro"', () {
      final leida = UnidadProductiva.fromMap({'tipo': 'nave_espacial'}, 'u3');
      expect(leida.tipo, TipoUnidadProductiva.otro);
    });

    test('archivar no es borrar: conserva todos los datos', () {
      final unidad = UnidadProductiva(
        unidadId: 'u1',
        activoAgroId: 'a1',
        tipo: TipoUnidadProductiva.potrero,
        nombre: 'Potrero 1',
        superficieHa: 45.5,
        creadoPor: 'dueno',
        fechaCreacion: fecha,
      );

      final archivada = unidad.archivar();

      expect(archivada.estaArchivada, isTrue);
      expect(archivada.nombre, 'Potrero 1');
      expect(archivada.superficieHa, 45.5);
      expect(archivada.toMap()['estado'], 'archivada');
    });
  });
}
