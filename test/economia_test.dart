import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/gasto_model.dart';
import 'package:agro_fields/screens/economia/economia_textos.dart';
import 'package:agro_fields/services/calculo_economia.dart';

Gasto gasto({
  String id = 'g1',
  double monto = 150000,
  String moneda = 'ARS',
  String categoria = 'combustible',
  String actividad = 'agricultura',
  DateTime? fecha,
  String? corrige,
}) {
  return Gasto(
    gastoId: id,
    activoAgroId: 'a1',
    fecha: fecha ?? DateTime(2026, 11, 10),
    fechaCarga: DateTime(2026, 11, 13),
    cargadoPor: 'u1',
    monto: monto,
    moneda: moneda,
    categoria: categoria,
    actividad: actividad,
    corrigeGastoId: corrige,
  );
}

void main() {
  group('Economía (GAP-ECO-01)', () {
    test('un gasto se guarda y se lee igual', () {
      final g = Gasto(
        gastoId: 'g1',
        activoAgroId: 'a1',
        fecha: DateTime(2026, 11, 10),
        fechaCarga: DateTime(2026, 11, 13),
        cargadoPor: 'u1',
        monto: 1200.5,
        moneda: 'USD',
        categoria: 'fletes',
        actividad: 'ganaderia',
        grupoId: 'rodeo1',
        proveedor: 'Transporte Pérez',
        comprobanteRuta: 'activos/a1/gastos/g1/ticket.pdf',
      );
      final l = Gasto.fromMap(g.toMap(), 'g1');
      expect(l.monto, 1200.5);
      expect(l.moneda, 'USD');
      expect(l.categoria, 'fletes');
      expect(l.grupoId, 'rodeo1');
      expect(l.comprobanteRuta, 'activos/a1/gastos/g1/ticket.pdf');
      expect(l.mes, '2026-11');
    });

    test('controles: monto, moneda, categoría, actividad y fecha', () {
      expect(gasto().validar(), isEmpty);
      expect(gasto(monto: 0).validar(), isNotEmpty);
      expect(gasto(monto: -5).validar(), isNotEmpty);
      expect(gasto(moneda: 'EUR').validar(), isNotEmpty);
      expect(gasto(categoria: 'vacaciones').validar(), isNotEmpty);
      expect(gasto(actividad: 'mineria').validar(), isNotEmpty);
      expect(gasto(fecha: DateTime(2026, 12, 1)).validar(), isNotEmpty);
      expect(gasto(monto: 0, corrige: 'g0').validar(), isEmpty);
    });

    test('resumen del mes: totales separados por moneda', () {
      final r = resumenDelMes([
        gasto(id: 'a', monto: 100000),
        gasto(id: 'b', monto: 50000, categoria: 'insumos'),
        gasto(id: 'c', monto: 800, moneda: 'USD', categoria: 'insumos'),
        gasto(id: 'd', monto: 99999, fecha: DateTime(2026, 10, 30)),
      ], '2026-11');
      expect(r.totalPorMoneda, {'ARS': 150000, 'USD': 800});
      expect(r.porCategoria['ARS'], {'combustible': 100000, 'insumos': 50000});
      expect(r.porActividad['ARS'], {'agricultura': 150000});
      expect(r.gastos.length, 3);
    });

    test('corregir no es borrar: vale la corrección; monto 0 anula', () {
      final todos = [
        gasto(id: 'g1', monto: 100000),
        gasto(id: 'g2', monto: 80000, corrige: 'g1'),
        gasto(id: 'g3', monto: 5000, categoria: 'otros'),
        gasto(id: 'g4', monto: 0, categoria: 'otros', corrige: 'g3'),
      ];
      final r = resumenDelMes(todos, '2026-11');
      expect(r.totalPorMoneda, {'ARS': 80000});
      expect(r.gastos.map((g) => g.gastoId), ['g2']);
    });

    test('meses: moverse para atrás y adelante (cambio de año)', () {
      expect(moverMes('2026-01', -1), '2025-12');
      expect(moverMes('2026-12', 1), '2027-01');
      expect(nombreMes('2026-11'), 'Noviembre 2026');
    });

    test('montos: se leen como los escribe la gente y se muestran claros', () {
      expect(leerMonto('150.000'), 150000);
      expect(leerMonto('150000'), 150000);
      expect(leerMonto(r'$ 2500'), 2500);
      expect(leerMonto('1.200,50'), 1200.5);
      expect(leerMonto('12.5'), 12.5);
      expect(leerMonto('mucho'), isNull);
      expect(formatoMonto(150000, 'ARS'), r'$ 150.000');
      expect(formatoMonto(1200.5, 'USD'), r'US$ 1.200,50');
      expect(formatoMonto(1500000.4, 'PYG'), '₲ 1.500.000');
    });
  });
}
