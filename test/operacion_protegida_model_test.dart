import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/operacion_protegida_model.dart';

OperacionProtegida operacion({
  ProductoOperacion producto = ProductoOperacion.hacienda,
  String? descripcionProducto,
  double importe = 15000000,
  String moneda = 'ARS',
  double? cantidad = 40,
  String nombreComprador = 'Frigorifico Ejemplo SA',
  EstadoOperacion estado = EstadoOperacion.enCurso,
  DateTime? fechaCierre,
}) {
  return OperacionProtegida(
    operacionId: 'op1',
    activoAgroId: 'a1',
    creadoPor: 'dueno',
    fechaCreacion: DateTime(2026, 11, 10),
    producto: producto,
    descripcionProducto: descripcionProducto,
    cantidad: cantidad,
    unidad: 'cabezas',
    importe: importe,
    moneda: moneda,
    formaPago: FormaPagoOperacion.cheque,
    comprador: CompradorOperacion(
      nombre: nombreComprador,
      identificacionFiscal: '30-12345678-9',
      representanteNombre: 'Juan Perez',
      representanteCaracter: 'apoderado',
    ),
    estado: estado,
    fechaCierre: fechaCierre,
  );
}

void main() {
  group('OperacionProtegida - validar (paso 7a-1)', () {
    test('operacion completa: sin errores', () {
      expect(operacion().validar(), isEmpty);
    });

    test('sin nombre del comprador: error', () {
      expect(operacion(nombreComprador: ' ').validar(),
          contains('Falta el nombre del comprador.'));
    });

    test('importe cero: error', () {
      expect(operacion(importe: 0).validar(),
          contains('El importe tiene que ser mayor a cero.'));
    });

    test('cantidad negativa: error', () {
      expect(operacion(cantidad: -3).validar(),
          contains('La cantidad tiene que ser mayor a cero.'));
    });

    test('sin cantidad: se acepta (lo que falta queda sin informacion)', () {
      expect(operacion(cantidad: null).validar(), isEmpty);
    });

    test('producto "otro" sin describir: error', () {
      expect(operacion(producto: ProductoOperacion.otro).validar(),
          contains('Falta describir el producto.'));
    });

    test('cerrada sin fecha de cierre: error', () {
      expect(operacion(estado: EstadoOperacion.cumplida).validar(),
          contains('Una operacion cerrada necesita la fecha de cierre.'));
    });

    test('cerrada con fecha de cierre: sin errores', () {
      final op = operacion(
        estado: EstadoOperacion.cumplida,
        fechaCierre: DateTime(2026, 12, 1),
      );
      expect(op.validar(), isEmpty);
      expect(op.estaEnCurso, isFalse);
    });
  });

  group('OperacionProtegida - guardar y leer', () {
    test('ida y vuelta conserva los datos y las garantias', () {
      final original = OperacionProtegida.fromMap({
        ...operacion().toMap(),
        'garantias': [
          GarantiaOperacion(
            tipo: TipoGarantia.sgr,
            emisor: 'SGR Ejemplo',
            importe: 5000000,
            fechaVencimiento: DateTime(2027, 3, 1),
          ).toMap(),
        ],
      }, 'op1');

      final leida = OperacionProtegida.fromMap(original.toMap(), 'op1');

      expect(leida.operacionId, 'op1');
      expect(leida.activoAgroId, 'a1');
      expect(leida.producto, ProductoOperacion.hacienda);
      expect(leida.importe, 15000000);
      expect(leida.moneda, 'ARS');
      expect(leida.formaPago, FormaPagoOperacion.cheque);
      expect(leida.comprador.identificacionFiscal, '30-12345678-9');
      expect(leida.comprador.representanteCaracter, 'apoderado');
      expect(leida.garantias, hasLength(1));
      expect(leida.garantias.first.tipo, TipoGarantia.sgr);
      expect(leida.garantias.first.fechaVencimiento, DateTime(2027, 3, 1));
      expect(leida.estado, EstadoOperacion.enCurso);
    });

    test('un estado desconocido se lee "en curso" (nunca se asume cerrada)', () {
      final leida = OperacionProtegida.fromMap(
        {...operacion().toMap(), 'estado': 'inventado'},
        'op1',
      );
      expect(leida.estado, EstadoOperacion.enCurso);
    });
  });
}
