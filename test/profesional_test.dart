import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/autorizacion_activo_model.dart';
import 'package:agro_fields/models/activos/intervencion_profesional_model.dart';
import 'package:agro_fields/services/profesional_service.dart';

IntervencionProfesional intervencion({String tipo = 'visita', String desc = 'Recorrida'}) {
  return IntervencionProfesional(
    intervencionId: 'int_1',
    activoAgroId: 'a1',
    profesionalId: 'p1',
    profesionalNombre: 'Ing. Pérez',
    tipo: tipo,
    descripcion: desc,
    fecha: DateTime(2026, 11, 10),
    fechaRegistro: DateTime(2026, 11, 12),
  );
}

AutorizacionActivo autorizacion({
  RolAutorizacion rol = RolAutorizacion.profesional,
  PermisoAutorizacion permiso = PermisoAutorizacion.crear,
  TipoAmbitoAutorizacion ambito = TipoAmbitoAutorizacion.expedienteProductivo,
}) {
  return AutorizacionActivo(
    autorizacionId: 'x',
    activoId: 'a1',
    usuarioAutorizado: 'p1',
    quienOtorga: 'd1',
    rol: rol,
    permiso: permiso,
    ambito: AmbitoAutorizacion(tipo: ambito, descripcion: 'La Tranquera'),
    fechaInicio: DateTime(2026, 11, 1),
    estado: EstadoAutorizacion.activa,
    fechaOtorgamiento: DateTime(2026, 11, 1),
  );
}

void main() {
  group('IntervencionProfesional (AF-093)', () {
    test('se guarda y se lee igual, siempre como declarada', () {
      final leida = IntervencionProfesional.fromMap(intervencion().toMap());
      expect(leida.tipo, 'visita');
      expect(leida.descripcion, 'Recorrida');
      expect(leida.profesionalNombre, 'Ing. Pérez');
      expect(leida.fecha, DateTime(2026, 11, 10));
      expect(leida.estado, 'declarado');
    });

    test('lee la fecha guardada como Timestamp', () {
      final mapa = intervencion().toMap()
        ..['fecha'] = Timestamp.fromDate(DateTime(2026, 3, 1));
      expect(IntervencionProfesional.fromMap(mapa).fecha, DateTime(2026, 3, 1));
    });

    test('un tipo desconocido se lee como "otro"', () {
      final mapa = intervencion().toMap()..['tipo'] = 'magia';
      expect(IntervencionProfesional.fromMap(mapa).tipo, 'otro');
    });

    test('sin descripción o con tipo inventado no se puede guardar', () {
      expect(intervencion().validar(), isEmpty);
      expect(intervencion(desc: '  ').validar(), isNotEmpty);
      expect(intervencion(tipo: 'magia').validar(), isNotEmpty);
    });
  });

  group('ProfesionalService.esInvitacionProfesional (AF-093)', () {
    test('profesional + crear + expediente productivo: sí', () {
      expect(ProfesionalService.esInvitacionProfesional(autorizacion()), isTrue);
    });

    test('un encargado u otro permiso: no', () {
      expect(
        ProfesionalService.esInvitacionProfesional(
            autorizacion(rol: RolAutorizacion.encargado)),
        isFalse,
      );
      expect(
        ProfesionalService.esInvitacionProfesional(
            autorizacion(permiso: PermisoAutorizacion.ver)),
        isFalse,
      );
    });
  });
}
