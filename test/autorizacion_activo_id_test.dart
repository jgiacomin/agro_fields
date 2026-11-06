import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/autorizacion_activo_model.dart';

void main() {
  group('AutorizacionActivo.construirId - nombre armado (paso 3)', () {
    test('autorizacion para el ambito entero', () {
      final id = AutorizacionActivo.construirId(
        activoId: 'a1',
        usuarioAutorizado: 'encargado',
        permiso: PermisoAutorizacion.crear,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.trabajo,
        ),
      );

      // Es el mismo nombre que buscan las Firestore Rules.
      expect(id, 'a1__encargado__crear__trabajo');
    });

    test('autorizacion para una referencia puntual agrega la referencia', () {
      final id = AutorizacionActivo.construirId(
        activoId: 'a1',
        usuarioAutorizado: 'encargado',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'modulo-01',
        ),
      );

      expect(id, 'a1__encargado__modificar__expedienteProductivo__modulo-01');
    });

    test('la misma autorizacion siempre da el mismo nombre (no se duplica)', () {
      String armar() => AutorizacionActivo.construirId(
            activoId: 'a1',
            usuarioAutorizado: 'u1',
            permiso: PermisoAutorizacion.ver,
            ambito: const AmbitoAutorizacion(
              tipo: TipoAmbitoAutorizacion.recursosInventario,
            ),
          );

      expect(armar(), armar());
    });

    test('existen los roles encargado y profesional', () {
      expect(RolAutorizacion.values, contains(RolAutorizacion.encargado));
      expect(RolAutorizacion.values, contains(RolAutorizacion.profesional));
    });
  });
}
