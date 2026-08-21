import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/ciclo_productivo_model.dart';

void main() {
  test('CicloProductivo serializa y recupera correctamente', () {
    final fechaInicio = DateTime(2026, 1, 1);
    final fechaFin = DateTime(2026, 6, 30);

    final ciclo = CicloProductivo(
      cicloId: 'ciclo_001',
      activoAgroId: 'activo_001',
      moduloProduccionId: 'prod_001',
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      campania: '2026',
      produccionObtenida: 3500,
      unidadProduccion: 'kg',
      observaciones: 'Ciclo productivo de prueba',
    );

    final mapa = ciclo.toMap();

    final recuperado =
        CicloProductivo.fromMap(
      mapa,
      'ciclo_001',
    );

    expect(
      recuperado.cicloId,
      'ciclo_001',
    );

    expect(
      recuperado.activoAgroId,
      'activo_001',
    );

    expect(
      recuperado.moduloProduccionId,
      'prod_001',
    );

    expect(
      recuperado.campania,
      '2026',
    );

    expect(
      recuperado.produccionObtenida,
      3500,
    );

    expect(
      recuperado.unidadProduccion,
      'kg',
    );

    expect(
      recuperado.fechaInicio,
      fechaInicio,
    );

    expect(
      recuperado.fechaFin,
      fechaFin,
    );
  });
}