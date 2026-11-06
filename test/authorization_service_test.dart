import 'package:flutter_test/flutter_test.dart';
import 'package:agro_fields/models/activos/autorizacion_activo_model.dart';
import 'package:agro_fields/services/authorization_service.dart';

void main() {
  group('AuthorizationService', () {
    const service = AuthorizationService();

    final fechaInicio = DateTime(2026, 10, 1);
    final fechaFin = DateTime(2026, 12, 31);

    AutorizacionActivo crearAutorizacion({
      String usuarioId = 'usuario-b',
      String activoId = 'activo-001',
      PermisoAutorizacion permiso = PermisoAutorizacion.modificar,
      TipoAmbitoAutorizacion tipoAmbito =
          TipoAmbitoAutorizacion.expedienteProductivo,
      String? referenciaId = 'activo-001',
      EstadoAutorizacion estado = EstadoAutorizacion.activa,
      DateTime? inicio,
      DateTime? fin,
    }) {
      return AutorizacionActivo(
        autorizacionId: 'aut-001',
        activoId: activoId,
        usuarioAutorizado: usuarioId,
        quienOtorga: 'usuario-a',
        rol: RolAutorizacion.arrendatario,
        permiso: permiso,
        ambito: AmbitoAutorizacion(
          tipo: tipoAmbito,
          referenciaId: referenciaId,
        ),
        fechaInicio: inicio ?? fechaInicio,
        fechaFin: fin ?? fechaFin,
        estado: estado,
        fechaOtorgamiento: inicio ?? fechaInicio,
      );
    }

    test('permite autorización activa, vigente y compatible', () {
      final autorizacion = crearAutorizacion();

      final resultado = service.evaluar(
        usuarioId: 'usuario-b',
        activoId: 'activo-001',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'activo-001',
        ),
        fechaHora: DateTime(2026, 10, 15),
        autorizaciones: [autorizacion],
      );

      expect(resultado.permitido, isTrue);
      expect(resultado.autorizacionAplicada, same(autorizacion));
    });

    test('deniega usuario diferente', () {
      final resultado = service.evaluar(
        usuarioId: 'usuario-c',
        activoId: 'activo-001',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'activo-001',
        ),
        fechaHora: DateTime(2026, 10, 15),
        autorizaciones: [crearAutorizacion()],
      );

      expect(resultado.permitido, isFalse);
    });

    test('deniega permiso diferente', () {
      final resultado = service.evaluar(
        usuarioId: 'usuario-b',
        activoId: 'activo-001',
        permiso: PermisoAutorizacion.ver,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'activo-001',
        ),
        fechaHora: DateTime(2026, 10, 15),
        autorizaciones: [crearAutorizacion()],
      );

      expect(resultado.permitido, isFalse);
    });

    test('deniega ámbito diferente', () {
      final resultado = service.evaluar(
        usuarioId: 'usuario-b',
        activoId: 'activo-001',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.economia,
          referenciaId: 'activo-001',
        ),
        fechaHora: DateTime(2026, 10, 15),
        autorizaciones: [crearAutorizacion()],
      );

      expect(resultado.permitido, isFalse);
    });

    test('deniega autorización pendiente', () {
      final resultado = service.evaluar(
        usuarioId: 'usuario-b',
        activoId: 'activo-001',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'activo-001',
        ),
        fechaHora: DateTime(2026, 10, 15),
        autorizaciones: [
          crearAutorizacion(
            estado: EstadoAutorizacion.pendiente,
          ),
        ],
      );

      expect(resultado.permitido, isFalse);
    });

    test('deniega autorización vencida', () {
      final resultado = service.evaluar(
        usuarioId: 'usuario-b',
        activoId: 'activo-001',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'activo-001',
        ),
        fechaHora: DateTime(2027, 1, 1),
        autorizaciones: [crearAutorizacion()],
      );

      expect(resultado.permitido, isFalse);
    });

    test('deniega antes de la fecha de inicio', () {
      final resultado = service.evaluar(
        usuarioId: 'usuario-b',
        activoId: 'activo-001',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'activo-001',
        ),
        fechaHora: DateTime(2026, 9, 30),
        autorizaciones: [crearAutorizacion()],
      );

      expect(resultado.permitido, isFalse);
    });

    test('deniega referencia incompatible', () {
      final resultado = service.evaluar(
        usuarioId: 'usuario-b',
        activoId: 'activo-001',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'activo-002',
        ),
        fechaHora: DateTime(2026, 10, 15),
        autorizaciones: [crearAutorizacion()],
      );

      expect(resultado.permitido, isFalse);
    });

    test(
      'permite ámbito del mismo tipo cuando autorización no tiene referencia específica',
      () {
        final resultado = service.evaluar(
          usuarioId: 'usuario-b',
          activoId: 'activo-001',
          permiso: PermisoAutorizacion.modificar,
          ambito: const AmbitoAutorizacion(
            tipo: TipoAmbitoAutorizacion.expedienteProductivo,
            referenciaId: 'modulo-produccion-01',
          ),
          fechaHora: DateTime(2026, 10, 15),
          autorizaciones: [
            crearAutorizacion(
              referenciaId: null,
            ),
          ],
        );

        expect(resultado.permitido, isTrue);
      },
    );

    test('deniega usuario vacío', () {
      final resultado = service.evaluar(
        usuarioId: '',
        activoId: 'activo-001',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'activo-001',
        ),
        fechaHora: DateTime(2026, 10, 15),
        autorizaciones: [crearAutorizacion()],
      );

      expect(resultado.permitido, isFalse);
    });

    test('deniega Activo Agro vacío', () {
      final resultado = service.evaluar(
        usuarioId: 'usuario-b',
        activoId: '',
        permiso: PermisoAutorizacion.modificar,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          referenciaId: 'activo-001',
        ),
        fechaHora: DateTime(2026, 10, 15),
        autorizaciones: [crearAutorizacion()],
      );

      expect(resultado.permitido, isFalse);
    });
  });
}
