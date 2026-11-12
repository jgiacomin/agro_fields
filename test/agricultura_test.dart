import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/evento_productivo_model.dart';
import 'package:agro_fields/models/activos/grupo_productivo_model.dart';
import 'package:agro_fields/services/calculo_agricola.dart';

EventoProductivo evento(
  TipoEventoProductivo tipo, {
  double? ha,
  double? cantidad,
  String? unidad,
  String? lote = 'lote3',
  double? humedad,
  DateTime? fecha,
}) {
  return EventoProductivo(
    eventoId: 'e_${tipo.name}_${ha}_$cantidad',
    activoAgroId: 'a1',
    grupoId: 'g1',
    unidadId: lote,
    tipo: tipo,
    fechaHecho: fecha ?? DateTime(2026, 11, 1),
    fechaCarga: DateTime(2026, 11, 12),
    cargadoPor: 'u1',
    superficieHa: ha,
    cantidadObtenida: cantidad,
    unidadMedida: unidad,
    humedad: humedad,
  );
}

void main() {
  group('Agricultura (GAP-AGRO-01)', () {
    test('el cultivo de la campaña se guarda y se lee igual', () {
      final g = GrupoProductivo(
        grupoId: 'g1',
        activoAgroId: 'a1',
        actividad: 'agricultura',
        nombre: 'Soja 2026/27 - Lote 3',
        creadoPor: 'u1',
        fechaCreacion: DateTime(2026, 11, 12),
        cultivo: 'soja',
        campania: '2026/27',
        material: 'DM 46i20',
        unidadInicialId: 'lote3',
      );
      final leido = GrupoProductivo.fromMap(g.toMap(), 'g1');
      expect(leido.esAgricola, isTrue);
      expect(leido.cultivo, 'soja');
      expect(leido.campania, '2026/27');
      expect(leido.material, 'DM 46i20');
    });

    test('un rodeo viejo (sin datos agrícolas) se lee igual', () {
      final viejo = GrupoProductivo.fromMap(
          {'activoAgroId': 'a1', 'actividad': 'ganaderia', 'nombre': 'Rodeo 1'},
          'g0');
      expect(viejo.esAgricola, isFalse);
      expect(viejo.cultivo, isNull);
    });

    test('siembra y cosecha se guardan y se leen igual', () {
      final c = evento(TipoEventoProductivo.cosecha,
          ha: 100, cantidad: 350, unidad: 'tn', humedad: 13.5);
      final leido = EventoProductivo.fromMap(c.toMap(), c.eventoId);
      expect(leido.superficieHa, 100);
      expect(leido.cantidadObtenida, 350);
      expect(leido.unidadMedida, 'tn');
      expect(leido.humedad, 13.5);
    });

    test('controles: sin hectáreas, sin lote o sin unidad no se guarda', () {
      expect(evento(TipoEventoProductivo.siembra, ha: 100).validar(), isEmpty);
      expect(evento(TipoEventoProductivo.siembra, ha: 0).validar(), isNotEmpty);
      expect(evento(TipoEventoProductivo.siembra, ha: 100, lote: null).validar(),
          isNotEmpty);
      expect(
          evento(TipoEventoProductivo.cosecha, ha: 100, cantidad: 300)
              .validar(),
          isNotEmpty);
      expect(
          evento(TipoEventoProductivo.cosecha,
                  ha: 100, cantidad: 300, unidad: 'tn', humedad: 120)
              .validar(),
          isNotEmpty);
    });

    test('kg y quintales se pasan a toneladas', () {
      expect(evento(TipoEventoProductivo.cosecha, cantidad: 3500, unidad: 'kg').toneladas, 3.5);
      expect(evento(TipoEventoProductivo.cosecha, cantidad: 35, unidad: 'qq').toneladas, 3.5);
    });

    test('el rendimiento se calcula, no se escribe', () {
      final r = calcularResumenCultivo([
        evento(TipoEventoProductivo.siembra, ha: 100, fecha: DateTime(2026, 11, 1)),
        evento(TipoEventoProductivo.cosecha, ha: 60, cantidad: 210, unidad: 'tn',
            fecha: DateTime(2027, 4, 10)),
        evento(TipoEventoProductivo.cosecha, ha: 40, cantidad: 1300, unidad: 'qq',
            fecha: DateTime(2027, 4, 12)),
      ]);
      expect(r.haSembradas, 100);
      expect(r.haCosechadas, 100);
      expect(r.toneladas, 340);
      expect(r.rendimiento, 3.4);
      expect(r.ultimaCosecha, DateTime(2027, 4, 12));
    });

    test('sembrado sin cosechar: en curso y sin rendimiento', () {
      final r = calcularResumenCultivo(
          [evento(TipoEventoProductivo.siembra, ha: 80)]);
      expect(r.enCurso, isTrue);
      expect(r.rendimiento, isNull);
    });
  });
}
