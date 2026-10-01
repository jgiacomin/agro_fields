import 'package:flutter_test/flutter_test.dart';
import 'package:agro_fields/models/activos/infraestructura_activo_model.dart';

void main() {
  group('InfraestructuraActivo', () {
    test('inicial crea valores por defecto', () {
      final infraestructura = InfraestructuraActivo.inicial();

      expect(infraestructura.infraestructuraId, '');
      expect(infraestructura.tipo, '');
      expect(infraestructura.nombre, '');
      expect(infraestructura.descripcion, '');
      expect(infraestructura.cantidad, 1);
      expect(infraestructura.estado, 'declarado');
      expect(infraestructura.moduloProduccionId, isNull);
    });

    test('fromMap reconstruye correctamente', () {
      final infraestructura = InfraestructuraActivo.fromMap({
        'infraestructuraId': 'infra-001',
        'tipo': 'galpon',
        'nombre': 'Galpón principal',
        'descripcion': 'Galpón para almacenamiento',
        'cantidad': 2,
        'estado': 'verificado',
        'moduloProduccionId': 'prod-001',
      });

      expect(infraestructura.infraestructuraId, 'infra-001');
      expect(infraestructura.tipo, 'galpon');
      expect(infraestructura.nombre, 'Galpón principal');
      expect(infraestructura.descripcion, 'Galpón para almacenamiento');
      expect(infraestructura.cantidad, 2);
      expect(infraestructura.estado, 'verificado');
      expect(infraestructura.moduloProduccionId, 'prod-001');
    });

    test('toMap conserva los datos', () {
      final infraestructura = InfraestructuraActivo(
        infraestructuraId: 'infra-002',
        tipo: 'pozo',
        nombre: 'Pozo norte',
        descripcion: 'Pozo de abastecimiento',
        cantidad: 1,
        estado: 'declarado',
      );

      final mapa = infraestructura.toMap();

      expect(mapa['infraestructuraId'], 'infra-002');
      expect(mapa['tipo'], 'pozo');
      expect(mapa['nombre'], 'Pozo norte');
      expect(mapa['descripcion'], 'Pozo de abastecimiento');
      expect(mapa['cantidad'], 1);
      expect(mapa['estado'], 'declarado');
      expect(mapa['moduloProduccionId'], isNull);
    });

    test('copyWith modifica solo los campos indicados', () {
      final infraestructura = InfraestructuraActivo(
        infraestructuraId: 'infra-003',
        tipo: 'riego',
        nombre: 'Sistema de riego',
        descripcion: 'Riego del lote norte',
        cantidad: 1,
        estado: 'declarado',
        moduloProduccionId: 'prod-002',
      );

      final actualizada = infraestructura.copyWith(
        estado: 'verificado',
        cantidad: 2,
      );

      expect(actualizada.infraestructuraId, 'infra-003');
      expect(actualizada.tipo, 'riego');
      expect(actualizada.nombre, 'Sistema de riego');
      expect(actualizada.descripcion, 'Riego del lote norte');
      expect(actualizada.cantidad, 2);
      expect(actualizada.estado, 'verificado');
      expect(actualizada.moduloProduccionId, 'prod-002');
    });
  });
}
