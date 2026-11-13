import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/evento_productivo_model.dart';
import 'package:agro_fields/services/calculo_rodeo.dart';

/// GAP-PESO-01 + AF-102 (13/11/2026): pesaje, ganancia diaria y mortandad.

EventoProductivo ev(
  String id,
  TipoEventoProductivo tipo,
  DateTime fecha, {
  int? cantidad,
  String? categoria,
  double? peso,
  MotivoBaja? motivo,
  OrigenAlta? origen,
  String? corrige,
}) {
  return EventoProductivo(
    eventoId: id,
    activoAgroId: 'a1',
    grupoId: 'g1',
    tipo: tipo,
    fechaHecho: fecha,
    fechaCarga: fecha,
    cargadoPor: 'dueno',
    cantidad: cantidad,
    categoria: categoria,
    pesoPromedioKg: peso,
    motivo: motivo,
    origen: origen,
    corrigeEventoId: corrige,
  );
}

EventoProductivo pesaje(String id, DateTime f, double kg, {String? cat = 'novillo'}) =>
    ev(id, TipoEventoProductivo.pesaje, f, peso: kg, categoria: cat);

EventoProductivo alta(String id, DateTime f, int n) => ev(
    id, TipoEventoProductivo.alta, f,
    cantidad: n, categoria: 'novillo', origen: OrigenAlta.compra);

EventoProductivo muerte(String id, DateTime f, int n) => ev(
    id, TipoEventoProductivo.baja, f,
    cantidad: n, categoria: 'novillo', motivo: MotivoBaja.muerte);

void main() {
  group('Pesaje (validar)', () {
    test('con peso está bien; cantidad y categoría son opcionales', () {
      final e = ev('p', TipoEventoProductivo.pesaje, DateTime(2026, 11, 1), peso: 320);
      expect(e.validar(), isEmpty);
    });

    test('sin peso, con 0 o con más de 2000 kg no se acepta', () {
      final f = DateTime(2026, 11, 1);
      expect(ev('p', TipoEventoProductivo.pesaje, f).validar(), isNotEmpty);
      expect(ev('p', TipoEventoProductivo.pesaje, f, peso: 0).validar(), isNotEmpty);
      expect(ev('p', TipoEventoProductivo.pesaje, f, peso: 3200).validar(), isNotEmpty);
    });

    test('el peso se guarda y se lee', () {
      final e = pesaje('p', DateTime(2026, 11, 1), 318.5);
      final leido = EventoProductivo.fromMap(e.toMap(), 'p');
      expect(leido.pesoPromedioKg, 318.5);
    });
  });

  group('Ganancia diaria de peso', () {
    test('entre los dos últimos pesajes de la misma categoría', () {
      final g = calcularGananciaDiaria([
        pesaje('p1', DateTime(2026, 9, 1), 250),
        pesaje('p2', DateTime(2026, 10, 1), 280),
        pesaje('p3', DateTime(2026, 10, 31), 304),
      ])!;
      expect(g.dias, 30);
      expect(g.kgPorDia, closeTo(0.8, 0.0001));
      expect(g.categoria, 'novillo');
    });

    test('no mezcla categorías', () {
      final g = calcularGananciaDiaria([
        pesaje('p1', DateTime(2026, 9, 1), 250),
        pesaje('t1', DateTime(2026, 10, 1), 150, cat: 'ternero'),
        pesaje('p2', DateTime(2026, 10, 11), 270),
      ])!;
      expect(g.pesoInicialKg, 250);
      expect(g.dias, 40);
    });

    test('con un solo pesaje o el mismo día no hay número', () {
      expect(calcularGananciaDiaria([pesaje('p1', DateTime(2026, 9, 1), 250)]), isNull);
      expect(
        calcularGananciaDiaria([
          pesaje('p1', DateTime(2026, 9, 1, 8), 250),
          pesaje('p2', DateTime(2026, 9, 1, 17), 251),
        ]),
        isNull,
      );
    });

    test('si bajaron de peso, da negativo (no se esconde)', () {
      final g = calcularGananciaDiaria([
        pesaje('p1', DateTime(2026, 9, 1), 300),
        pesaje('p2', DateTime(2026, 9, 11), 290),
      ])!;
      expect(g.kgPorDia, closeTo(-1, 0.0001));
    });

    test('un pesaje corregido no cuenta', () {
      final g = calcularGananciaDiaria([
        pesaje('p1', DateTime(2026, 9, 1), 250),
        pesaje('p2', DateTime(2026, 9, 11), 2900), // error de tipeo
        ev('p3', TipoEventoProductivo.pesaje, DateTime(2026, 9, 11),
            peso: 290, categoria: 'novillo', corrige: 'p2'),
      ])!;
      expect(g.pesoFinalKg, 290);
    });
  });

  group('Mortandad', () {
    final desde = DateTime(2026, 1, 1);
    final hasta = DateTime(2026, 12, 31);

    test('muertes sobre los que había más los que entraron', () {
      final m = calcularMortandad([
        alta('a1', DateTime(2025, 6, 1), 90),
        alta('a2', DateTime(2026, 3, 1), 10),
        muerte('m1', DateTime(2026, 5, 1), 2),
        muerte('m2', DateTime(2026, 8, 1), 1),
      ], desde: desde, hasta: hasta)!;
      expect(m.animalesBase, 100);
      expect(m.muertes, 3);
      expect(m.porcentaje, closeTo(3, 0.0001));
    });

    test('las muertes de antes del período no cuentan', () {
      final m = calcularMortandad([
        alta('a1', DateTime(2025, 1, 1), 50),
        muerte('m1', DateTime(2025, 6, 1), 5),
      ], desde: desde, hasta: hasta)!;
      expect(m.animalesBase, 45);
      expect(m.muertes, 0);
    });

    test('las ventas no son muertes', () {
      final m = calcularMortandad([
        alta('a1', DateTime(2026, 2, 1), 20),
        ev('v1', TipoEventoProductivo.baja, DateTime(2026, 4, 1),
            cantidad: 5, categoria: 'novillo', motivo: MotivoBaja.venta),
      ], desde: desde, hasta: hasta)!;
      expect(m.muertes, 0);
    });

    test('más muertes que animales queda para revisar', () {
      final m = calcularMortandad([
        alta('a1', DateTime(2026, 2, 1), 10),
        muerte('m1', DateTime(2026, 4, 1), 12),
      ], desde: desde, hasta: hasta)!;
      expect(m.paraRevisar, isTrue);
    });

    test('sin animales no hay número', () {
      expect(calcularMortandad([], desde: desde, hasta: hasta), isNull);
    });
  });
}
