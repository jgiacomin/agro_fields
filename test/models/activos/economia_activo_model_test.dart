import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/dato_economico_model.dart';
import 'package:agro_fields/models/activos/economia_activo_model.dart';

void main() {
  group('EconomiaActivo - datos económicos temporales', () {
        test('legacy con contenido no se clasifica automáticamente', () {
      final mapaLegacy = <String, dynamic>{
        'objetivoProyecto': 'Proyecto legacy',
        'etapaProyecto': 'producción',
        'inversionEsperada': 500000,
        'capacidadActual': '100 ha',
        'capacidadProyectada': '150 ha',
        'riesgosIdentificados': 'Clima',
        'origenInformacion': 'productor',
        'responsableDeclaracion': 'responsable-01',
        'valorSolicitado': 1000000,
        'moneda': 'USD',
        'tipoOperacion': 'venta',
        'capitalRequerido': 200000,
        'ingresosEstimados': '150000',
        'costosEstimados': '80000',
        'rentabilidadDeclarada': '10%',
        'periodoEvaluacion': '2026-2030',
        'datosEconomicos': {
          'ingresos': 150000,
          'rentabilidad': '10%',
        },
        'fechaActualizacion': DateTime(2026, 9, 15),
      };

      final economia = EconomiaActivo.fromMap(mapaLegacy);

      expect(economia.datosEconomicos, isEmpty);
    });
    test('serializa y reconstruye los cuatro tipos temporales', () {
      final economia = EconomiaActivo(
        objetivoProyecto: 'Producción agropecuaria',
        etapaProyecto: 'producción',
        inversionEsperada: 500000,
        capacidadActual: '100 ha',
        capacidadProyectada: '180 ha',
        riesgosIdentificados: 'Clima',
        origenInformacion: 'productor',
        responsableDeclaracion: 'responsable-01',
        valorSolicitado: 1350000,
        moneda: 'USD',
        tipoOperacion: 'venta',
        capitalRequerido: 300000,
        ingresosEstimados: '210000',
        costosEstimados: '120000',
        rentabilidadDeclarada: '11%',
        periodoEvaluacion: '2026-2030',
        datosEconomicos: [
          DatoEconomico(
            nombreDato: 'ingresosHistoricos',
            valor: 150000,
            tipoTemporal: TipoTemporalEconomico.historico,
            periodo: '2025',
          ),
          DatoEconomico(
            nombreDato: 'valorActual',
            valor: 1350000,
            tipoTemporal: TipoTemporalEconomico.actual,
            periodo: '2026',
          ),
          DatoEconomico(
            nombreDato: 'ingresosProyectados',
            valor: 210000,
            tipoTemporal: TipoTemporalEconomico.proyectado,
            periodo: '2027',
          ),
          DatoEconomico(
            nombreDato: 'ingresosEscenarioExpansion',
            valor: 250000,
            tipoTemporal: TipoTemporalEconomico.escenario,
            periodo: '2027',
            escenarioId: 'expansion_80_ha',
          ),
        ],
        fechaActualizacion: DateTime(2026, 9, 15),
      );

      final mapa = economia.toMap();
      final reconstruida = EconomiaActivo.fromMap(mapa);

      expect(reconstruida.datosEconomicos.length, equals(4));

      expect(
        reconstruida.datosEconomicos[0].tipoTemporal,
        equals(TipoTemporalEconomico.historico),
      );

      expect(
        reconstruida.datosEconomicos[1].tipoTemporal,
        equals(TipoTemporalEconomico.actual),
      );

      expect(
        reconstruida.datosEconomicos[2].tipoTemporal,
        equals(TipoTemporalEconomico.proyectado),
      );

      expect(
        reconstruida.datosEconomicos[3].tipoTemporal,
        equals(TipoTemporalEconomico.escenario),
      );

      expect(
        reconstruida.datosEconomicos[3].escenarioId,
        equals('expansion_80_ha'),
      );
    });

        test('EconomiaActivo.inicial crea lista económica vacía', () {
      final economia = EconomiaActivo.inicial();

      expect(economia.datosEconomicos, isEmpty);
    });

    test('reconstruye datosEconomicos legacy vacío como lista vacía', () {
      final mapaLegacy = <String, dynamic>{
        'objetivoProyecto': 'Proyecto legacy',
        'etapaProyecto': 'inicial',
        'inversionEsperada': 0,
        'capacidadActual': '',
        'capacidadProyectada': '',
        'riesgosIdentificados': '',
        'origenInformacion': 'productor',
        'responsableDeclaracion': '',
        'valorSolicitado': 0,
        'moneda': 'USD',
        'tipoOperacion': '',
        'capitalRequerido': 0,
        'ingresosEstimados': '',
        'costosEstimados': '',
        'rentabilidadDeclarada': '',
        'periodoEvaluacion': '',
        'datosEconomicos': {},
        'fechaActualizacion': DateTime(2026, 9, 15),
      };

      final economia = EconomiaActivo.fromMap(mapaLegacy);

      expect(economia.datosEconomicos, isEmpty);
    });
  });
}