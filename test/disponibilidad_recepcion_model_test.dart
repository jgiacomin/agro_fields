import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/disponibilidad_recepcion_model.dart';
import 'package:agro_fields/models/activos/evento_afectacion_model.dart';

void main() {
  group('DisponibilidadRecepcion (AF-092)', () {
    test('se guarda y se lee igual', () {
      final original = DisponibilidadRecepcion(
        activa: true,
        recursos: const ['hacienda', 'granos'],
        capacidad: '300 cabezas',
        fechaActualizacion: DateTime(2026, 11, 12),
      );

      final leida = DisponibilidadRecepcion.fromMap(original.toMap());

      expect(leida.activa, isTrue);
      expect(leida.recursos, ['hacienda', 'granos']);
      expect(leida.capacidad, '300 cabezas');
      expect(leida.fechaActualizacion, DateTime(2026, 11, 12));
    });

    test('sin dato claro no se asume disponible', () {
      final vacia = DisponibilidadRecepcion.fromMap({});
      expect(vacia.activa, isFalse);
      expect(vacia.recursos, isEmpty);
    });

    test('un recurso desconocido se descarta', () {
      final leida = DisponibilidadRecepcion.fromMap({
        'activa': true,
        'recursos': ['hacienda', 'naves_espaciales'],
      });
      expect(leida.recursos, ['hacienda']);
    });
  });

  group('EventoAfectacion - fechas de Firestore (AF-092)', () {
    test('lee la fecha real guardada como Timestamp', () {
      final evento = EventoAfectacion.fromMap({
        'eventoId': 'emer_1',
        'activoAgroId': 'activo_1',
        'tipoEvento': 'climatico',
        'subtipoEvento': 'inundacion',
        'fechaInicio': Timestamp.fromDate(DateTime(2026, 3, 15)),
        'fechaFin': Timestamp.fromDate(DateTime(2026, 3, 20)),
        'descripcion': 'Inundación',
        'origen': 'declaracion_usuario',
        'estado': 'declarado',
        'usuarioRegistrador': 'u1',
        'fechaRegistro': Timestamp.fromDate(DateTime(2026, 3, 16)),
      });

      expect(evento.fechaInicio, DateTime(2026, 3, 15));
      expect(evento.fechaFin, DateTime(2026, 3, 20));
      expect(evento.fechaRegistro, DateTime(2026, 3, 16));
    });
  });
}
