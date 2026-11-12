import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/movimiento_model.dart';

Movimiento traslado({double declarada = 50, double? recibida, String carga = 'Novillos'}) {
  return Movimiento(
    movimientoId: 'mov_1',
    activoAgroId: 'a1',
    actividad: 'ganaderia',
    destinoDescripcion: 'Feedlot Los Aromos',
    carga: carga,
    cantidadDeclarada: declarada,
    unidad: 'cabezas',
    cantidadRecibida: recibida,
    transportista: 'Transporte Pérez',
    guia: 'DTe 12345',
    fechaSalida: DateTime(2026, 11, 12),
    cargadoPor: 'u1',
    fechaCarga: DateTime(2026, 11, 12),
  );
}

void main() {
  group('Movimiento - traslado simple (AF-089)', () {
    test('se guarda y se lee igual', () {
      final leido = Movimiento.fromMap(traslado(recibida: 50).toMap());
      expect(leido.actividad, 'ganaderia');
      expect(leido.carga, 'Novillos');
      expect(leido.cantidadDeclarada, 50);
      expect(leido.cantidadRecibida, 50);
      expect(leido.guia, 'DTe 12345');
      expect(leido.fechaSalida, DateTime(2026, 11, 12));
      expect(leido.estado, EstadoMovimiento.programado);
      expect(leido.estadoDato, 'declarado');
    });

    test('control de coherencia: avisa si llegó distinto de lo declarado', () {
      expect(traslado().hayDiferencia, isFalse);
      expect(traslado(recibida: 50).hayDiferencia, isFalse);
      expect(traslado(recibida: 48).hayDiferencia, isTrue);
      expect(traslado(recibida: 48).diferencia, -2);
    });

    test('cambios de estado permitidos', () {
      expect(Movimiento.puedePasar(EstadoMovimiento.programado, EstadoMovimiento.enCamino), isTrue);
      expect(Movimiento.puedePasar(EstadoMovimiento.enCamino, EstadoMovimiento.entregado), isTrue);
      expect(Movimiento.puedePasar(EstadoMovimiento.entregado, EstadoMovimiento.cancelado), isFalse);
      expect(Movimiento.puedePasar(EstadoMovimiento.cancelado, EstadoMovimiento.programado), isFalse);
      expect(Movimiento.puedePasar(EstadoMovimiento.enCamino, EstadoMovimiento.programado), isFalse);
    });

    test('no se guarda sin carga ni con cantidad cero', () {
      expect(traslado().validar(), isEmpty);
      expect(traslado(carga: ' ').validar(), isNotEmpty);
      expect(traslado(declarada: 0).validar(), isNotEmpty);
    });

    test('lo desconocido no se asume: estado raro = programado, actividad rara = otra', () {
      final mapa = traslado().toMap()
        ..['estado'] = 'teletransportado'
        ..['actividad'] = 'astronautica';
      final leido = Movimiento.fromMap(mapa);
      expect(leido.estado, EstadoMovimiento.programado);
      expect(leido.actividad, 'otra');
    });
  });
}
