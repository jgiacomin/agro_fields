import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/dato_economico_model.dart';

void main() {
  group('DatoEconomico', () {
    test('crea un dato histórico correctamente', () {
      final dato = DatoEconomico(
        nombreDato: 'ingresos',
        valor: 150000,
        tipoTemporal: TipoTemporalEconomico.historico,
        periodo: '2025',
      );

      expect(dato.nombreDato, equals('ingresos'));
      expect(dato.valor, equals(150000));
      expect(
        dato.tipoTemporal,
        equals(TipoTemporalEconomico.historico),
      );
      expect(dato.periodo, equals('2025'));
      expect(dato.escenarioId, isNull);
    });

    test('crea un dato actual correctamente', () {
      final dato = DatoEconomico(
        nombreDato: 'valorSolicitado',
        valor: 1350000,
        tipoTemporal: TipoTemporalEconomico.actual,
        periodo: '2026',
      );

      expect(
        dato.tipoTemporal,
        equals(TipoTemporalEconomico.actual),
      );
      expect(dato.periodo, equals('2026'));
      expect(dato.escenarioId, isNull);
    });

    test('crea un dato proyectado correctamente', () {
      final dato = DatoEconomico(
        nombreDato: 'ingresosEstimados',
        valor: 210000,
        tipoTemporal: TipoTemporalEconomico.proyectado,
        periodo: '2027',
      );

      expect(
        dato.tipoTemporal,
        equals(TipoTemporalEconomico.proyectado),
      );
      expect(dato.periodo, equals('2027'));
      expect(dato.escenarioId, isNull);
    });

    test('crea un escenario correctamente', () {
      final dato = DatoEconomico(
        nombreDato: 'ingresosEstimados',
        valor: 250000,
        tipoTemporal: TipoTemporalEconomico.escenario,
        periodo: '2027',
        escenarioId: 'expansion_80_ha',
      );

      expect(
        dato.tipoTemporal,
        equals(TipoTemporalEconomico.escenario),
      );
      expect(dato.periodo, equals('2027'));
      expect(
        dato.escenarioId,
        equals('expansion_80_ha'),
      );
    });

    test('serializa y reconstruye correctamente', () {
      final original = DatoEconomico(
        nombreDato: 'rentabilidad',
        valor: '11%',
        tipoTemporal: TipoTemporalEconomico.proyectado,
        periodo: '2027-2031',
      );

      final mapa = original.toMap();
      final reconstruido = DatoEconomico.fromMap(mapa);

      expect(
        reconstruido.nombreDato,
        equals(original.nombreDato),
      );
      expect(
        reconstruido.valor,
        equals(original.valor),
      );
      expect(
        reconstruido.tipoTemporal,
        equals(original.tipoTemporal),
      );
      expect(
        reconstruido.periodo,
        equals(original.periodo),
      );
      expect(
        reconstruido.escenarioId,
        equals(original.escenarioId),
      );
    });

    test('escenario requiere escenarioId', () {
      expect(
        () => DatoEconomico(
          nombreDato: 'ingresos',
          valor: 300000,
          tipoTemporal: TipoTemporalEconomico.escenario,
          periodo: '2028',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('un dato no escenario no admite escenarioId', () {
      expect(
        () => DatoEconomico(
          nombreDato: 'ingresos',
          valor: 300000,
          tipoTemporal: TipoTemporalEconomico.proyectado,
          periodo: '2028',
          escenarioId: 'escenario_a',
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}