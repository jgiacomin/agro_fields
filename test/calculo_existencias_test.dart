import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/evento_productivo_model.dart';
import 'package:agro_fields/services/calculo_existencias.dart';

int _dia = 0;

/// Arma un evento; cada uno pasa un dia despues del anterior.
EventoProductivo ev(
  String id,
  TipoEventoProductivo tipo, {
  int? cantidad,
  String? categoria,
  String? categoriaNueva,
  String? unidad,
  String? desde,
  String? hacia,
  DateTime? fecha,
}) {
  _dia++;
  final hecho = fecha ?? DateTime(2026, 1, 1).add(Duration(days: _dia));
  return EventoProductivo(
    eventoId: id,
    activoAgroId: 'a1',
    grupoId: 'g1',
    tipo: tipo,
    fechaHecho: hecho,
    fechaCarga: DateTime(2026, 11, 10),
    cargadoPor: 'dueno',
    unidadId: unidad,
    cantidad: cantidad,
    categoria: categoria,
    categoriaNueva: categoriaNueva,
    origen: tipo == TipoEventoProductivo.alta ? OrigenAlta.compra : null,
    motivo: tipo == TipoEventoProductivo.baja ? MotivoBaja.venta : null,
    unidadOrigenId: desde,
    unidadDestinoId: hacia,
    tratamiento: tipo == TipoEventoProductivo.sanidad ? 'Aftosa' : null,
  );
}

void main() {
  group('calcularExistencias (paso 6a-2, GAP-PROD-01)', () {
    test('sin eventos: no hay animales', () {
      final r = calcularExistencias([]);
      expect(r.totalCabezas, 0);
      expect(r.porUnidad, isEmpty);
      expect(r.hayDiscrepancias, isFalse);
    });

    test('alta, muerte y cambio de categoria en el mismo potrero', () {
      final r = calcularExistencias([
        ev('e1', TipoEventoProductivo.alta,
            cantidad: 10, categoria: 'ternero', unidad: 'p1'),
        ev('e2', TipoEventoProductivo.baja,
            cantidad: 1, categoria: 'ternero', unidad: 'p1'),
        ev('e3', TipoEventoProductivo.cambioCategoria,
            cantidad: 3, categoria: 'ternero', categoriaNueva: 'novillito',
            unidad: 'p1'),
      ]);

      expect(r.porCategoria, {'ternero': 6, 'novillito': 3});
      expect(r.porUnidad, {
        'p1': {'ternero': 6, 'novillito': 3},
      });
      expect(r.totalCabezas, 9);
      expect(r.hayDiscrepancias, isFalse);
    });

    test('un movimiento cambia de potrero sin cambiar el total', () {
      final r = calcularExistencias([
        ev('e1', TipoEventoProductivo.alta,
            cantidad: 20, categoria: 'vaca', unidad: 'p1'),
        ev('e2', TipoEventoProductivo.movimiento,
            cantidad: 8, categoria: 'vaca', desde: 'p1', hacia: 'p2'),
      ]);

      expect(r.porUnidad, {
        'p1': {'vaca': 12},
        'p2': {'vaca': 8},
      });
      expect(r.porCategoria, {'vaca': 20});
    });

    test('sin unidad en el evento: se usa donde arranco el grupo', () {
      final r = calcularExistencias(
        [ev('e1', TipoEventoProductivo.alta, cantidad: 5, categoria: 'toro')],
        unidadInicialId: 'corral1',
      );

      expect(r.porUnidad, {
        'corral1': {'toro': 5},
      });
    });

    test('sin unidad y sin lugar inicial: queda "sin ubicacion"', () {
      final r = calcularExistencias(
        [ev('e1', TipoEventoProductivo.alta, cantidad: 5, categoria: 'toro')],
      );

      expect(r.porUnidad.keys, [sinUbicacion]);
    });

    test('vender mas de los que hay: NO se esconde, queda la discrepancia', () {
      final r = calcularExistencias([
        ev('e1', TipoEventoProductivo.alta,
            cantidad: 10, categoria: 'novillo', unidad: 'p1'),
        ev('e2', TipoEventoProductivo.baja,
            cantidad: 12, categoria: 'novillo', unidad: 'p1'),
      ]);

      expect(r.porCategoria, {'novillo': -2});
      expect(r.hayDiscrepancias, isTrue);
      expect(r.discrepancias.single.eventoId, 'e2');
    });

    test('se cuentan en el orden en que pasaron, no en el que se cargaron', () {
      final r = calcularExistencias([
        // La venta se cargo primero en la lista pero paso despues.
        ev('venta', TipoEventoProductivo.baja,
            cantidad: 4, categoria: 'vaca', unidad: 'p1',
            fecha: DateTime(2026, 3, 1)),
        ev('compra', TipoEventoProductivo.alta,
            cantidad: 10, categoria: 'vaca', unidad: 'p1',
            fecha: DateTime(2026, 2, 1)),
      ]);

      expect(r.porCategoria, {'vaca': 6});
      expect(r.hayDiscrepancias, isFalse);
    });

    test('la sanidad no cambia las existencias', () {
      final r = calcularExistencias([
        ev('e1', TipoEventoProductivo.alta,
            cantidad: 10, categoria: 'vaca', unidad: 'p1'),
        ev('e2', TipoEventoProductivo.sanidad, cantidad: 10),
      ]);

      expect(r.porCategoria, {'vaca': 10});
      expect(r.hayDiscrepancias, isFalse);
    });

    test('un evento incompleto no se cuenta y queda como discrepancia', () {
      final r = calcularExistencias([
        ev('e1', TipoEventoProductivo.alta, cantidad: 10, unidad: 'p1'),
      ]);

      expect(r.totalCabezas, 0);
      expect(r.discrepancias.single.eventoId, 'e1');
    });
  });
}
