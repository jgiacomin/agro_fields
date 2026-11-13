import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/evento_productivo_model.dart';
import 'package:agro_fields/services/calculo_agricola.dart';

EventoProductivo monitoreo({
  String id = 'm1',
  String? objetivo = 'plaga',
  String? nivel = 'alto',
  String? fuente = 'recorrida',
  String? visto = 'Chinche verde',
  DateTime? fecha,
  String? corrige,
}) {
  return EventoProductivo(
    eventoId: id,
    activoAgroId: 'a1',
    grupoId: 'g1',
    unidadId: 'lote3',
    tipo: TipoEventoProductivo.monitoreo,
    fechaHecho: fecha ?? DateTime(2026, 11, 10),
    fechaCarga: DateTime(2026, 11, 13),
    cargadoPor: 'u1',
    observaciones: visto,
    objetivoMonitoreo: objetivo,
    nivel: nivel,
    fuenteDato: fuente,
    corrigeEventoId: corrige,
  );
}

void main() {
  group('Monitoreo (GAP-MON-01)', () {
    test('se guarda y se lee igual', () {
      final m = EventoProductivo(
        eventoId: 'm1',
        activoAgroId: 'a1',
        grupoId: 'g1',
        tipo: TipoEventoProductivo.monitoreo,
        fechaHecho: DateTime(2026, 11, 10),
        fechaCarga: DateTime(2026, 11, 13),
        cargadoPor: 'u1',
        observaciones: 'Yuyo colorado en manchones',
        objetivoMonitoreo: 'maleza',
        nivel: 'medio',
        fuenteDato: 'dron',
        recomendacion: 'Aplicar antes de que semille',
      );
      final leido = EventoProductivo.fromMap(m.toMap(), 'm1');
      expect(leido.tipo, TipoEventoProductivo.monitoreo);
      expect(leido.objetivoMonitoreo, 'maleza');
      expect(leido.nivel, 'medio');
      expect(leido.fuenteDato, 'dron');
      expect(leido.recomendacion, 'Aplicar antes de que semille');
      expect(leido.observaciones, 'Yuyo colorado en manchones');
    });

    test('un evento viejo (sin datos de monitoreo) se lee igual', () {
      final viejo = EventoProductivo.fromMap({
        'activoAgroId': 'a1',
        'grupoId': 'g1',
        'tipo': 'siembra',
        'superficieHa': 100,
      }, 'e0');
      expect(viejo.nivel, isNull);
      expect(viejo.fuenteDato, isNull);
    });

    test('controles: falta qué se miró, qué se vio, nivel o fuente', () {
      expect(monitoreo().validar(), isEmpty);
      expect(monitoreo(objetivo: null).validar(), isNotEmpty);
      expect(monitoreo(objetivo: 'ovni').validar(), isNotEmpty);
      expect(monitoreo(visto: '  ').validar(), isNotEmpty);
      expect(monitoreo(nivel: null).validar(), isNotEmpty);
      expect(monitoreo(nivel: 'gravisimo').validar(), isNotEmpty);
      expect(monitoreo(fuente: null).validar(), isNotEmpty);
      expect(monitoreo(fuente: 'me dijeron').validar(), isNotEmpty);
    });

    test('alerta: el último monitoreo en nivel alto', () {
      final alertas = alertasMonitoreo([
        monitoreo(id: 'p1', nivel: 'bajo', fecha: DateTime(2026, 11, 1)),
        monitoreo(id: 'p2', nivel: 'alto', fecha: DateTime(2026, 11, 10)),
        monitoreo(
            id: 'm1',
            objetivo: 'maleza',
            nivel: 'medio',
            fecha: DateTime(2026, 11, 9)),
      ]);
      expect(alertas.map((e) => e.eventoId), ['p2']);
    });

    test('un monitoreo nuevo más bajo apaga la alerta (sin borrar nada)', () {
      final alertas = alertasMonitoreo([
        monitoreo(id: 'p1', nivel: 'alto', fecha: DateTime(2026, 11, 1)),
        monitoreo(id: 'p2', nivel: 'bajo', fecha: DateTime(2026, 11, 10)),
      ]);
      expect(alertas, isEmpty);
    });

    test('un monitoreo corregido no cuenta para la alerta', () {
      final alertas = alertasMonitoreo([
        monitoreo(id: 'p1', nivel: 'alto'),
        monitoreo(id: 'p2', nivel: 'bajo', corrige: 'p1'),
      ]);
      expect(alertas, isEmpty);
    });

    test('el monitoreo no cambia el resumen del cultivo', () {
      final r = calcularResumenCultivo([monitoreo()]);
      expect(r.haSembradas, 0);
      expect(r.haCosechadas, 0);
      expect(r.rendimiento, isNull);
    });
  });
}
