import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/evento_operacion_model.dart';
import 'package:agro_fields/models/activos/operacion_protegida_model.dart';
import 'package:agro_fields/services/control_operacion.dart';

final hoy = DateTime(2026, 11, 10);

OperacionProtegida operacion({
  double importe = 10000000,
  double? cantidad = 40,
  String? cuit = '30-12345678-9',
  String? firmante = 'Juan Perez',
  String? caracter = 'apoderado',
  String? poder,
  String? contrato,
  List<GarantiaOperacion> garantias = const [],
}) {
  return OperacionProtegida(
    operacionId: 'op1',
    activoAgroId: 'a1',
    creadoPor: 'dueno',
    fechaCreacion: DateTime(2026, 11, 1),
    producto: ProductoOperacion.hacienda,
    cantidad: cantidad,
    unidad: 'cabezas',
    importe: importe,
    moneda: 'ARS',
    formaPago: FormaPagoOperacion.cheque,
    comprador: CompradorOperacion(
      nombre: 'Frigorifico Ejemplo SA',
      identificacionFiscal: cuit,
      representanteNombre: firmante,
      representanteCaracter: caracter,
      facultadArchivoRuta: poder,
    ),
    contratoArchivoRuta: contrato,
    garantias: garantias,
  );
}

int _n = 0;

EventoOperacion cheque(
  double importe,
  DateTime vence, {
  String? id,
  String? moneda,
  String? corrige,
}) {
  return EventoOperacion(
    eventoId: id ?? 'ch${_n++}',
    operacionId: 'op1',
    activoAgroId: 'a1',
    tipo: TipoEventoOperacion.pagoAcordado,
    fechaHecho: DateTime(2026, 11, 2),
    fechaCarga: DateTime(2026, 11, 2),
    cargadoPor: 'dueno',
    medioPago: MedioPago.cheque,
    importe: importe,
    moneda: moneda,
    fechaVencimiento: vence,
    numero: '000${_n}',
    corrigeEventoId: corrige,
  );
}

EventoOperacion cobro(String pagoId, {double? importe, DateTime? fecha}) {
  return EventoOperacion(
    eventoId: 'co${_n++}',
    operacionId: 'op1',
    activoAgroId: 'a1',
    tipo: TipoEventoOperacion.cobro,
    fechaHecho: fecha ?? DateTime(2026, 11, 5),
    fechaCarga: DateTime(2026, 11, 10),
    cargadoPor: 'dueno',
    pagoEventoId: pagoId,
    importe: importe,
  );
}

EventoOperacion rechazo(String pagoId, {DateTime? fecha}) {
  return EventoOperacion(
    eventoId: 're${_n++}',
    operacionId: 'op1',
    activoAgroId: 'a1',
    tipo: TipoEventoOperacion.rechazo,
    fechaHecho: fecha ?? DateTime(2026, 11, 4),
    fechaCarga: DateTime(2026, 11, 10),
    cargadoPor: 'dueno',
    pagoEventoId: pagoId,
    motivoRechazo: 'sin fondos',
  );
}

EventoOperacion entrega(double cantidad, {String unidad = 'cabezas'}) {
  return EventoOperacion(
    eventoId: 'en${_n++}',
    operacionId: 'op1',
    activoAgroId: 'a1',
    tipo: TipoEventoOperacion.entrega,
    fechaHecho: DateTime(2026, 11, 3),
    fechaCarga: DateTime(2026, 11, 3),
    cargadoPor: 'dueno',
    cantidad: cantidad,
    unidad: unidad,
  );
}

EstadoPago estadoDe(ResultadoOperacion r, String id) =>
    r.pagos.firstWhere((p) => p.pago.eventoId == id).estado;

void main() {
  group('Estado de los pagos (paso 7a-2)', () {
    test('cheque que vence en un mes: pendiente', () {
      final r = calcularOperacion(
          operacion(), [cheque(5000000, DateTime(2026, 12, 10), id: 'c1')],
          hoy: hoy);
      expect(estadoDe(r, 'c1'), EstadoPago.pendiente);
      expect(r.alertas, isEmpty);
    });

    test('cheque que vence en 7 dias: por vencer (aviso)', () {
      final r = calcularOperacion(
          operacion(), [cheque(5000000, DateTime(2026, 11, 17), id: 'c1')],
          hoy: hoy);
      expect(estadoDe(r, 'c1'), EstadoPago.porVencer);
      expect(r.alertas, hasLength(1));
    });

    test('cheque que vence en 8 dias: todavia pendiente', () {
      final r = calcularOperacion(
          operacion(), [cheque(5000000, DateTime(2026, 11, 18), id: 'c1')],
          hoy: hoy);
      expect(estadoDe(r, 'c1'), EstadoPago.pendiente);
    });

    test('cheque que vence hoy: por vencer, no vencido', () {
      final r = calcularOperacion(
          operacion(), [cheque(5000000, hoy, id: 'c1')],
          hoy: hoy);
      expect(estadoDe(r, 'c1'), EstadoPago.porVencer);
    });

    test('cheque que vencio ayer sin cobrar: vencido', () {
      final r = calcularOperacion(
          operacion(), [cheque(5000000, DateTime(2026, 11, 9), id: 'c1')],
          hoy: hoy);
      expect(estadoDe(r, 'c1'), EstadoPago.vencido);
    });

    test('cheque cobrado (cobro sin importe = todo): cobrado', () {
      final r = calcularOperacion(operacion(), [
        cheque(5000000, DateTime(2026, 11, 5), id: 'c1'),
        cobro('c1'),
      ], hoy: hoy);
      expect(estadoDe(r, 'c1'), EstadoPago.cobrado);
      expect(r.totalCobrado, 5000000);
      expect(r.faltaCobrar, 5000000);
    });

    test('cobro parcial: sigue sin estar cobrado', () {
      final r = calcularOperacion(operacion(), [
        cheque(5000000, DateTime(2026, 11, 9), id: 'c1'),
        cobro('c1', importe: 2000000),
      ], hoy: hoy);
      expect(estadoDe(r, 'c1'), EstadoPago.vencido);
      expect(r.pagos.first.falta, 3000000);
    });

    test('cheque rechazado: rechazado y cuenta como rechazado', () {
      final r = calcularOperacion(operacion(), [
        cheque(5000000, DateTime(2026, 11, 4), id: 'c1'),
        rechazo('c1'),
      ], hoy: hoy);
      expect(estadoDe(r, 'c1'), EstadoPago.rechazado);
      expect(r.pagos.first.motivoRechazo, 'sin fondos');
      expect(r.totalRechazado, 5000000);
      expect(r.alertas, hasLength(1));
    });

    test('rechazado y despues pagado: cobrado', () {
      final r = calcularOperacion(operacion(), [
        cheque(5000000, DateTime(2026, 11, 3), id: 'c1'),
        rechazo('c1', fecha: DateTime(2026, 11, 4)),
        cobro('c1', fecha: DateTime(2026, 11, 8)),
      ], hoy: hoy);
      expect(estadoDe(r, 'c1'), EstadoPago.cobrado);
      expect(r.totalRechazado, 0);
    });
  });

  group('Discrepancias (no se esconden)', () {
    test('cobro de un pago que no existe', () {
      final r = calcularOperacion(operacion(), [cobro('no_existe')], hoy: hoy);
      expect(r.hayDiscrepancias, isTrue);
      expect(r.totalCobrado, 0);
    });

    test('cobrar mas de lo acordado', () {
      final r = calcularOperacion(operacion(), [
        cheque(5000000, DateTime(2026, 11, 5), id: 'c1'),
        cobro('c1', importe: 6000000),
      ], hoy: hoy);
      expect(r.discrepancias.map((d) => d.descripcion),
          contains('Se cobro mas de lo acordado en ese pago.'));
    });

    test('pago en otra moneda: no se suma', () {
      final r = calcularOperacion(operacion(), [
        cheque(5000, DateTime(2026, 12, 5), id: 'c1', moneda: 'USD'),
      ], hoy: hoy);
      expect(r.pagos, isEmpty);
      expect(r.hayDiscrepancias, isTrue);
    });

    test('se entrego mas de lo acordado', () {
      final r = calcularOperacion(
          operacion(cantidad: 40), [entrega(30), entrega(15)],
          hoy: hoy);
      expect(r.totalEntregado, 45);
      expect(r.discrepancias.map((d) => d.descripcion),
          contains('Se entrego mas de lo acordado en la operacion.'));
    });

    test('evento de otra operacion: no se cuenta', () {
      final ajeno = EventoOperacion.fromMap(
          {...cheque(1, DateTime(2026, 12, 1)).toMap(), 'operacionId': 'op2'},
          'x1');
      final r = calcularOperacion(operacion(), [ajeno], hoy: hoy);
      expect(r.pagos, isEmpty);
      expect(r.hayDiscrepancias, isTrue);
    });
  });

  group('Correcciones', () {
    test('un cheque corregido deja de contar; cuenta el nuevo', () {
      final r = calcularOperacion(operacion(), [
        cheque(5000000, DateTime(2026, 12, 1), id: 'c1'),
        cheque(4000000, DateTime(2026, 12, 1), id: 'c2', corrige: 'c1'),
      ], hoy: hoy);
      expect(r.pagos, hasLength(1));
      expect(r.totalAcordado, 4000000);
    });
  });

  group('Lista de control antes de entregar', () {
    test('operacion con lo minimo: falta poder, contrato, pagos y garantia',
        () {
      final r = calcularOperacion(operacion(), const [], hoy: hoy);
      expect(r.puntosTotales, 7);
      expect(r.puntosCompletos, 3); // CUIT, firmante, sin problemas
      expect(r.sinPagoAcordado, 10000000);
    });

    test('operacion completa: 7 de 7', () {
      final r = calcularOperacion(
        operacion(
          poder: 'activos/a1/privado/operaciones/op1/poder.pdf',
          contrato: 'activos/a1/privado/operaciones/op1/boleto.pdf',
          garantias: const [GarantiaOperacion(tipo: TipoGarantia.sgr)],
        ),
        [
          cheque(5000000, DateTime(2026, 12, 10)),
          cheque(5000000, DateTime(2027, 1, 10)),
        ],
        hoy: hoy,
      );
      expect(r.puntosCompletos, 7);
      expect(r.sinPagoAcordado, 0);
    });

    test('un cheque rechazado deja de cubrir y marca problema', () {
      final r = calcularOperacion(operacion(importe: 5000000), [
        cheque(5000000, DateTime(2026, 11, 4), id: 'c1'),
        rechazo('c1'),
      ], hoy: hoy);
      final items = {for (final i in r.listaControl) i.punto: i};
      expect(items[PuntoControl.pagosCubrenImporte]!.completo, isFalse);
      expect(items[PuntoControl.sinProblemas]!.completo, isFalse);
    });

    test('sin CUIT: el punto dice que falta', () {
      final r = calcularOperacion(operacion(cuit: null), const [], hoy: hoy);
      final item = r.listaControl
          .firstWhere((i) => i.punto == PuntoControl.identificacionComprador);
      expect(item.completo, isFalse);
      expect(item.queFalta, 'Cargar el CUIT o RUC del comprador.');
    });
  });
}
