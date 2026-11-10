import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/evento_operacion_model.dart';

final hecho = DateTime(2026, 11, 9);
final carga = DateTime(2026, 11, 10);

EventoOperacion evento(
  TipoEventoOperacion tipo, {
  MedioPago? medioPago,
  double? importe,
  DateTime? fechaVencimiento,
  String? numero,
  double? cantidad,
  String? unidad,
  String? pagoEventoId,
  String? motivoRechazo,
  String? observaciones,
  DateTime? fechaHecho,
}) {
  return EventoOperacion(
    eventoId: 'eo1',
    operacionId: 'op1',
    activoAgroId: 'a1',
    tipo: tipo,
    fechaHecho: fechaHecho ?? hecho,
    fechaCarga: carga,
    cargadoPor: 'dueno',
    medioPago: medioPago,
    importe: importe,
    fechaVencimiento: fechaVencimiento,
    numero: numero,
    cantidad: cantidad,
    unidad: unidad,
    pagoEventoId: pagoEventoId,
    motivoRechazo: motivoRechazo,
    observaciones: observaciones,
  );
}

EventoOperacion chequeCompleto() => evento(
      TipoEventoOperacion.pagoAcordado,
      medioPago: MedioPago.cheque,
      importe: 5000000,
      fechaVencimiento: DateTime(2027, 1, 15),
      numero: '00012345',
    );

void main() {
  group('EventoOperacion - validar (paso 7a-1)', () {
    test('cheque completo: sin errores (el vencimiento puede ser futuro)', () {
      expect(chequeCompleto().validar(), isEmpty);
    });

    test('cheque sin numero: error', () {
      final e = evento(
        TipoEventoOperacion.pagoAcordado,
        medioPago: MedioPago.cheque,
        importe: 5000000,
        fechaVencimiento: DateTime(2027, 1, 15),
      );
      expect(e.validar(), contains('Falta el numero del cheque.'));
    });

    test('transferencia sin numero: se acepta', () {
      final e = evento(
        TipoEventoOperacion.pagoAcordado,
        medioPago: MedioPago.transferencia,
        importe: 5000000,
        fechaVencimiento: DateTime(2026, 11, 20),
      );
      expect(e.validar(), isEmpty);
    });

    test('pago sin importe ni vencimiento: errores', () {
      final errores = evento(
        TipoEventoOperacion.pagoAcordado,
        medioPago: MedioPago.efectivo,
      ).validar();
      expect(errores, contains('Falta el importe.'));
      expect(errores, contains('Falta la fecha de vencimiento o de pago.'));
    });

    test('importe negativo: error', () {
      final e = evento(
        TipoEventoOperacion.pagoAcordado,
        medioPago: MedioPago.efectivo,
        importe: -1,
        fechaVencimiento: DateTime(2026, 11, 20),
      );
      expect(e.validar(), contains('El importe tiene que ser mayor a cero.'));
    });

    test('entrega completa: sin errores', () {
      final e = evento(TipoEventoOperacion.entrega,
          cantidad: 40, unidad: 'cabezas');
      expect(e.validar(), isEmpty);
    });

    test('entrega sin unidad: error', () {
      final e = evento(TipoEventoOperacion.entrega, cantidad: 40);
      expect(e.validar(), contains('Falta la unidad (cabezas, kg...).'));
    });

    test('cobro sin decir que pago: error', () {
      expect(evento(TipoEventoOperacion.cobro).validar(),
          contains('Falta que pago se cobro.'));
    });

    test('rechazo sin motivo: error', () {
      final e = evento(TipoEventoOperacion.rechazo, pagoEventoId: 'eo1');
      expect(e.validar(), contains('Falta el motivo del rechazo.'));
    });

    test('rechazo completo: sin errores', () {
      final e = evento(TipoEventoOperacion.rechazo,
          pagoEventoId: 'eo1', motivoRechazo: 'sin fondos');
      expect(e.validar(), isEmpty);
    });

    test('incumplimiento sin describir: error', () {
      expect(evento(TipoEventoOperacion.incumplimiento).validar(),
          contains('Falta describir lo que paso.'));
    });

    test('hecho posterior a la carga: error', () {
      final e = evento(TipoEventoOperacion.nota,
          observaciones: 'x', fechaHecho: DateTime(2026, 12, 1));
      expect(e.validar(),
          contains('La fecha del hecho no puede ser posterior a la carga.'));
    });
  });

  group('EventoOperacion - guardar y leer', () {
    test('ida y vuelta conserva los datos del cheque', () {
      final leido =
          EventoOperacion.fromMap(chequeCompleto().toMap(), 'eo1');
      expect(leido.tipo, TipoEventoOperacion.pagoAcordado);
      expect(leido.medioPago, MedioPago.cheque);
      expect(leido.importe, 5000000);
      expect(leido.numero, '00012345');
      expect(leido.fechaVencimiento, DateTime(2027, 1, 15));
      expect(leido.estadoDato, EstadoDatoEventoOperacion.declarado);
    });

    test('un tipo inventado no se acepta', () {
      expect(
        () => EventoOperacion.fromMap(
            {...chequeCompleto().toMap(), 'tipo': 'inventado'}, 'eo1'),
        throwsFormatException,
      );
    });
  });
}
