import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/evento_productivo_model.dart';

final hecho = DateTime(2026, 11, 9);
final carga = DateTime(2026, 11, 10);

EventoProductivo evento(
  TipoEventoProductivo tipo, {
  int? cantidad = 10,
  String? categoria = 'ternero',
  String? categoriaNueva,
  OrigenAlta? origen,
  MotivoBaja? motivo,
  String? desde,
  String? hacia,
  String? tratamiento,
  DateTime? fechaHecho,
}) {
  return EventoProductivo(
    eventoId: 'ev1',
    activoAgroId: 'a1',
    grupoId: 'g1',
    tipo: tipo,
    fechaHecho: fechaHecho ?? hecho,
    fechaCarga: carga,
    cargadoPor: 'dueno',
    cantidad: cantidad,
    categoria: categoria,
    categoriaNueva: categoriaNueva,
    origen: origen,
    motivo: motivo,
    unidadOrigenId: desde,
    unidadDestinoId: hacia,
    tratamiento: tratamiento,
  );
}

void main() {
  group('EventoProductivo - los 5 del lanzamiento (paso 6a)', () {
    test('alta completa: sin errores', () {
      final e = evento(TipoEventoProductivo.alta, origen: OrigenAlta.compra);
      expect(e.validar(), isEmpty);
    });

    test('alta sin origen: error', () {
      expect(evento(TipoEventoProductivo.alta).validar(),
          contains('Falta el origen del alta.'));
    });

    test('baja sin motivo: error', () {
      expect(evento(TipoEventoProductivo.baja).validar(),
          contains('Falta el motivo de la baja.'));
    });

    test('cantidad cero o negativa: error', () {
      final e = evento(TipoEventoProductivo.alta,
          cantidad: 0, origen: OrigenAlta.nacimiento);
      expect(e.validar(), contains('La cantidad tiene que ser mayor a cero.'));
    });

    test('movimiento a la misma unidad: error', () {
      final e = evento(TipoEventoProductivo.movimiento, desde: 'u1', hacia: 'u1');
      expect(e.validar(),
          contains('El origen y el destino son la misma unidad.'));
    });

    test('movimiento completo: sin errores', () {
      final e = evento(TipoEventoProductivo.movimiento, desde: 'u1', hacia: 'u2');
      expect(e.validar(), isEmpty);
    });

    test('cambio de categoria a la misma: error', () {
      final e = evento(TipoEventoProductivo.cambioCategoria,
          categoriaNueva: 'ternero');
      expect(e.validar(),
          contains('La categoria nueva es igual a la anterior.'));
    });

    test('cambio de categoria ternero a novillito: sin errores', () {
      final e = evento(TipoEventoProductivo.cambioCategoria,
          categoriaNueva: 'novillito');
      expect(e.validar(), isEmpty);
    });

    test('sanidad sin tratamiento: error', () {
      expect(evento(TipoEventoProductivo.sanidad).validar(),
          contains('Falta el tratamiento o vacuna.'));
    });

    test('sanidad con tratamiento: sin errores', () {
      final e = evento(TipoEventoProductivo.sanidad,
          cantidad: null, categoria: null, tratamiento: 'Aftosa');
      expect(e.validar(), isEmpty);
    });

    test('la fecha del hecho no puede ser posterior a la carga', () {
      final e = evento(TipoEventoProductivo.alta,
          origen: OrigenAlta.compra, fechaHecho: DateTime(2026, 12, 1));
      expect(e.validar(),
          contains('La fecha del hecho no puede ser posterior a la carga.'));
    });
  });

  group('EventoProductivo - guardado y tipos', () {
    test('se guarda y se lee igual', () {
      final e = evento(TipoEventoProductivo.alta, origen: OrigenAlta.compra);
      final leido = EventoProductivo.fromMap(e.toMap(), 'ev1');

      expect(leido.tipo, TipoEventoProductivo.alta);
      expect(leido.cantidad, 10);
      expect(leido.categoria, 'ternero');
      expect(leido.origen, OrigenAlta.compra);
      expect(leido.fechaHecho, hecho);
      expect(leido.estadoDato, EstadoDatoEvento.declarado);
    });

    test('el movimiento de stock de una vacuna se guarda (paso 6a-2)', () {
      final leido = EventoProductivo.fromMap({
        'tipo': 'sanidad',
        'tratamiento': 'Aftosa',
        'recursoId': 'r1',
        'movimientoStockId': 'mov1',
      }, 'ev4');

      expect(leido.movimientoStockId, 'mov1');
      expect(leido.toMap()['movimientoStockId'], 'mov1');
    });

    test('declarado no es verificado: por defecto queda declarado', () {
      final leido = EventoProductivo.fromMap({'tipo': 'baja'}, 'ev2');
      expect(leido.estadoDato, EstadoDatoEvento.declarado);
    });

    test('un tipo desconocido no se acepta', () {
      expect(() => EventoProductivo.fromMap({'tipo': 'inventado'}, 'ev3'),
          throwsFormatException);
    });

    test('los 5 tipos del lanzamiento; pesaje queda preparado', () {
      expect(tiposEventoLanzamiento.length, 5);
      expect(evento(TipoEventoProductivo.sanidad).esDelLanzamiento, isTrue);
      expect(evento(TipoEventoProductivo.pesaje).esDelLanzamiento, isFalse);
    });
  });
}
