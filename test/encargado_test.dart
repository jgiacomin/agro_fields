import 'package:agro_fields/models/activos/autorizacion_activo_model.dart';
import 'package:agro_fields/models/activos/permisos_encargado.dart';
import 'package:agro_fields/services/encargado_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// GAP-ENC-01: áreas del encargado (sin Firebase).
void main() {
  final ahora = DateTime(2026, 11, 16, 12);

  AutorizacionActivo aut(
    PermisoAutorizacion permiso,
    TipoAmbitoAutorizacion ambito, {
    String usuario = 'enc1',
    String activo = 'a1',
    EstadoAutorizacion estado = EstadoAutorizacion.activa,
    RolAutorizacion rol = RolAutorizacion.encargado,
    DateTime? fin,
  }) =>
      AutorizacionActivo(
        autorizacionId: '',
        activoId: activo,
        usuarioAutorizado: usuario,
        quienOtorga: 'dueno',
        rol: rol,
        permiso: permiso,
        ambito: AmbitoAutorizacion(tipo: ambito, descripcion: 'La Esperanza'),
        fechaInicio: DateTime(2026, 11, 1),
        fechaFin: fin,
        estado: estado,
        fechaOtorgamiento: DateTime(2026, 11, 1),
      );

  List<AutorizacionActivo> area(AreaEncargado a, {EstadoAutorizacion estado = EstadoAutorizacion.activa}) => [
        for (final (p, t) in permisosPorArea[a]!) aut(p, t, estado: estado),
      ];

  test('ENC-T1. Cada área tiene permisos y nombre', () {
    for (final a in AreaEncargado.values) {
      expect(permisosPorArea[a], isNotEmpty);
      expect(nombreArea(a), isNotEmpty);
    }
  });

  test('ENC-T2. Un área cuenta solo si están TODOS sus permisos', () {
    final produccion = area(AreaEncargado.produccion);
    expect(areasHabilitadas(produccion, ahora), {AreaEncargado.produccion});
    expect(areasHabilitadas(produccion.take(2), ahora), isEmpty);
  });

  test('ENC-T3. Revocadas o vencidas no cuentan', () {
    expect(areasHabilitadas(area(AreaEncargado.gastos, estado: EstadoAutorizacion.revocada), ahora), isEmpty);
    final vencidas = [
      for (final (p, t) in permisosPorArea[AreaEncargado.gastos]!) aut(p, t, fin: DateTime(2026, 11, 10)),
    ];
    expect(areasHabilitadas(vencidas, ahora), isEmpty);
  });

  test('ENC-T4. Las invitaciones de profesional no se cuentan como encargado', () {
    final prof = aut(PermisoAutorizacion.crear, TipoAmbitoAutorizacion.expedienteProductivo,
        rol: RolAutorizacion.profesional);
    expect(esAutorizacionEncargado(prof), isFalse);
    expect(agruparEncargados([prof], ahora), isEmpty);
  });

  test('ENC-T5. Agrupa por campo y usuario, con sus áreas', () {
    final lista = [
      ...area(AreaEncargado.produccion),
      ...area(AreaEncargado.traslados),
      aut(PermisoAutorizacion.ver, TipoAmbitoAutorizacion.economia, usuario: 'enc2'),
    ];
    final grupos = agruparEncargados(lista, ahora);
    expect(grupos.length, 2);
    final enc1 = grupos.firstWhere((g) => g.usuarioId == 'enc1');
    expect(enc1.areas, {AreaEncargado.produccion, AreaEncargado.traslados});
    expect(enc1.nombreActivo, 'La Esperanza');
    final enc2 = grupos.firstWhere((g) => g.usuarioId == 'enc2');
    expect(enc2.activo, isFalse);
  });

  test('ENC-T6. Revisión del código pegado', () {
    expect(EncargadoService.revisarCodigo('', 'dueno'), isNotNull);
    expect(EncargadoService.revisarCodigo('dueno', 'dueno'), isNotNull);
    expect(EncargadoService.revisarCodigo('a b', 'dueno'), isNotNull);
    expect(EncargadoService.revisarCodigo(' XoXo11mcLzV4 ', 'dueno'), isNull);
  });
}
