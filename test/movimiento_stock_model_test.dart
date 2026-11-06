import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/movimiento_stock_model.dart';

void main() {
  test('MovimientoStock serializa y recupera correctamente', () {
    final fechaMovimiento = DateTime(2026, 10, 8);

    final movimiento = MovimientoStock(
      movimientoId: 'mov_001',
      activoAgroId: 'activo_001',
      recursoId: 'recurso_001',
      tipoMovimiento: 'consumo',
      cantidad: 150,
      unidad: 'litros',
      fechaMovimiento: fechaMovimiento,
      trabajoId: 'trabajo_001',
      responsableId: 'usuario_001',
      motivo: 'Carga de combustible para trabajo agrícola',
      sentido: null,
      observaciones: 'Consumo de prueba',
    );

    final mapa = movimiento.toMap();

    final recuperado = MovimientoStock.fromMap(
      mapa,
      'mov_001',
    );

    expect(recuperado.movimientoId, 'mov_001');
    expect(recuperado.activoAgroId, 'activo_001');
    expect(recuperado.recursoId, 'recurso_001');
    expect(recuperado.tipoMovimiento, 'consumo');
    expect(recuperado.cantidad, 150);
    expect(recuperado.unidad, 'litros');
    expect(recuperado.fechaMovimiento, fechaMovimiento);
    expect(recuperado.trabajoId, 'trabajo_001');
    expect(recuperado.responsableId, 'usuario_001');
    expect(
      recuperado.motivo,
      'Carga de combustible para trabajo agrícola',
    );
    expect(recuperado.sentido, isNull);
    expect(recuperado.observaciones, 'Consumo de prueba');
  });

  test('MovimientoStock serializa ajuste positivo correctamente', () {
    final fechaMovimiento = DateTime(2026, 10, 8);

    final movimiento = MovimientoStock(
      movimientoId: 'ajuste_pos_001',
      activoAgroId: 'activo_001',
      recursoId: 'recurso_001',
      tipoMovimiento: 'ajuste',
      cantidad: 50,
      unidad: 'litros',
      fechaMovimiento: fechaMovimiento,
      motivo: 'Diferencia encontrada en inventario físico',
      sentido: 'positivo',
    );

    final mapa = movimiento.toMap();

    final recuperado = MovimientoStock.fromMap(
      mapa,
      'ajuste_pos_001',
    );

    expect(recuperado.tipoMovimiento, 'ajuste');
    expect(recuperado.cantidad, 50);
    expect(recuperado.sentido, 'positivo');
    expect(
      recuperado.motivo,
      'Diferencia encontrada en inventario físico',
    );
  });

  test('MovimientoStock serializa ajuste negativo correctamente', () {
    final fechaMovimiento = DateTime(2026, 10, 8);

    final movimiento = MovimientoStock(
      movimientoId: 'ajuste_neg_001',
      activoAgroId: 'activo_001',
      recursoId: 'recurso_001',
      tipoMovimiento: 'ajuste',
      cantidad: 30,
      unidad: 'litros',
      fechaMovimiento: fechaMovimiento,
      motivo: 'Faltante detectado en inventario físico',
      sentido: 'negativo',
    );

    final mapa = movimiento.toMap();

    final recuperado = MovimientoStock.fromMap(
      mapa,
      'ajuste_neg_001',
    );

    expect(recuperado.tipoMovimiento, 'ajuste');
    expect(recuperado.cantidad, 30);
    expect(recuperado.sentido, 'negativo');
    expect(
      recuperado.motivo,
      'Faltante detectado en inventario físico',
    );
  });
}