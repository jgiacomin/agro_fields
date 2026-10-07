import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/models/activos/autorizacion_activo_model.dart';

void main() {
  group('AutorizacionActivo - serialización', () {
    test('debe serializar y reconstruir correctamente', () {
      final fechaInicio = DateTime(2027, 1, 1);
      final fechaFin = DateTime(2027, 12, 31);
      final fechaOtorgamiento = DateTime(2026, 12, 15, 10, 30);

      final ambito = AmbitoAutorizacion(
        tipo: TipoAmbitoAutorizacion.marketplace,
        referenciaId: 'ficha-comercial-001',
        descripcion: 'Información comercial autorizada',
      );

      final evidencia = EvidenciaAutorizacion(
        tipo: 'contrato_intermediacion',
        referenciaId: 'documento-001',
        descripcion: 'Contrato comercial vigente',
      );

      final exclusividad = ExclusividadAutorizacion(
        activa: false,
        tipo: TipoExclusividadAutorizacion.venta,
        alcance: 'Venta del Activo Agro',
      );

      final autorizacion = AutorizacionActivo(
        autorizacionId: 'aut-001',
        grupoAutorizacionId: 'grupo-001',
        activoId: 'activo-001',
        usuarioAutorizado: 'broker-001',
        quienOtorga: 'propietario-001',
        rol: RolAutorizacion.broker,
        permiso: PermisoAutorizacion.compartir,
        ambito: ambito,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estado: EstadoAutorizacion.activa,
        modalidadRepresentacion:
            ModalidadRepresentacion.noExclusiva,
        exclusividad: exclusividad,
        evidenciaAutorizacion: evidencia,
        condiciones: const [
          'Solo información comercial autorizada',
          'No incluye datos privados',
        ],
        puedeDelegar: false,
        fechaOtorgamiento: fechaOtorgamiento,
        motivo: 'Intermediación comercial',
      );

      final map = autorizacion.toMap();

      expect(map['autorizacionId'], 'aut-001');
      expect(map['grupoAutorizacionId'], 'grupo-001');
      expect(map['activoId'], 'activo-001');
      expect(map['usuarioAutorizado'], 'broker-001');
      expect(map['quienOtorga'], 'propietario-001');
      expect(map['rol'], 'broker');
      expect(map['permiso'], 'compartir');
      expect(map['estado'], 'activa');
      expect(
        map['modalidadRepresentacion'],
        'noExclusiva',
      );
      expect(map['puedeDelegar'], false);
      expect(
        map['condiciones'],
        [
          'Solo información comercial autorizada',
          'No incluye datos privados',
        ],
      );
      expect(map['motivo'], 'Intermediación comercial');

      expect(map['fechaInicio'], isA<Timestamp>());
      expect(map['fechaFin'], isA<Timestamp>());
      expect(map['fechaOtorgamiento'], isA<Timestamp>());

      expect(map['ambito'], isA<Map<String, dynamic>>());

      final ambitoMap =
          Map<String, dynamic>.from(map['ambito'] as Map);

      expect(ambitoMap['tipo'], 'marketplace');
      expect(
        ambitoMap['referenciaId'],
        'ficha-comercial-001',
      );
      expect(
        ambitoMap['descripcion'],
        'Información comercial autorizada',
      );

      expect(
        map['evidenciaAutorizacion'],
        isA<Map<String, dynamic>>(),
      );

      final evidenciaMap = Map<String, dynamic>.from(
        map['evidenciaAutorizacion'] as Map,
      );

      expect(
        evidenciaMap['tipo'],
        'contrato_intermediacion',
      );
      expect(
        evidenciaMap['referenciaId'],
        'documento-001',
      );
      expect(
        evidenciaMap['descripcion'],
        'Contrato comercial vigente',
      );

      expect(
        map['exclusividad'],
        isA<Map<String, dynamic>>(),
      );

      final exclusividadMap = Map<String, dynamic>.from(
        map['exclusividad'] as Map,
      );

      expect(exclusividadMap['activa'], false);
      expect(exclusividadMap['tipo'], 'venta');
      expect(
        exclusividadMap['alcance'],
        'Venta del Activo Agro',
      );

      final reconstruida = AutorizacionActivo.fromMap(map);

      expect(
        reconstruida.autorizacionId,
        autorizacion.autorizacionId,
      );
      expect(
        reconstruida.grupoAutorizacionId,
        autorizacion.grupoAutorizacionId,
      );
      expect(
        reconstruida.activoId,
        autorizacion.activoId,
      );
      expect(
        reconstruida.usuarioAutorizado,
        autorizacion.usuarioAutorizado,
      );
      expect(
        reconstruida.quienOtorga,
        autorizacion.quienOtorga,
      );
      expect(reconstruida.rol, autorizacion.rol);
      expect(reconstruida.permiso, autorizacion.permiso);
      expect(reconstruida.estado, autorizacion.estado);
      expect(
        reconstruida.modalidadRepresentacion,
        autorizacion.modalidadRepresentacion,
      );
      expect(
        reconstruida.fechaInicio,
        fechaInicio,
      );
      expect(
        reconstruida.fechaFin,
        fechaFin,
      );
      expect(
        reconstruida.fechaOtorgamiento,
        fechaOtorgamiento,
      );
      expect(
        reconstruida.condiciones,
        autorizacion.condiciones,
      );
      expect(
        reconstruida.puedeDelegar,
        autorizacion.puedeDelegar,
      );
      expect(
        reconstruida.motivo,
        autorizacion.motivo,
      );

      expect(
        reconstruida.ambito.tipo,
        TipoAmbitoAutorizacion.marketplace,
      );
      expect(
        reconstruida.ambito.referenciaId,
        'ficha-comercial-001',
      );

      expect(
        reconstruida.evidenciaAutorizacion!.tipo,
        'contrato_intermediacion',
      );
      expect(
        reconstruida.exclusividad!.activa,
        false,
      );
      expect(
        reconstruida.exclusividad!.tipo,
        TipoExclusividadAutorizacion.venta,
      );
    });
  });

  group('AutorizacionActivo - opcionales', () {
    test('debe permitir campos opcionales en null', () {
      final autorizacion = AutorizacionActivo(
        autorizacionId: 'aut-002',
        activoId: 'activo-002',
        usuarioAutorizado: 'usuario-002',
        quienOtorga: 'propietario-002',
        rol: RolAutorizacion.inversor,
        permiso: PermisoAutorizacion.ver,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.marketplace,
        ),
        fechaInicio: DateTime(2027, 1, 1),
        estado: EstadoAutorizacion.pendiente,
        fechaOtorgamiento: DateTime(2026, 12, 20),
      );

      final map = autorizacion.toMap();

      expect(map['grupoAutorizacionId'], isNull);
      expect(map['fechaFin'], isNull);
      expect(map['modalidadRepresentacion'], isNull);
      expect(map['exclusividad'], isNull);
      expect(map['evidenciaAutorizacion'], isNull);
      expect(map['motivo'], isNull);
      expect(map['condiciones'], isEmpty);
      expect(map['puedeDelegar'], false);

      final reconstruida = AutorizacionActivo.fromMap(map);

      expect(reconstruida.grupoAutorizacionId, isNull);
      expect(reconstruida.fechaFin, isNull);
      expect(reconstruida.modalidadRepresentacion, isNull);
      expect(reconstruida.exclusividad, isNull);
      expect(reconstruida.evidenciaAutorizacion, isNull);
      expect(reconstruida.motivo, isNull);
      expect(reconstruida.condiciones, isEmpty);
      expect(reconstruida.puedeDelegar, false);
    });
  });

  group('AutorizacionActivo - copyWith', () {
    test('debe modificar solo los campos solicitados', () {
      final original = AutorizacionActivo(
        autorizacionId: 'aut-003',
        activoId: 'activo-003',
        usuarioAutorizado: 'usuario-003',
        quienOtorga: 'propietario-003',
        rol: RolAutorizacion.broker,
        permiso: PermisoAutorizacion.ver,
        ambito: const AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.marketplace,
        ),
        fechaInicio: DateTime(2027, 1, 1),
        estado: EstadoAutorizacion.pendiente,
        fechaOtorgamiento: DateTime(2026, 12, 20),
      );

      final modificada = original.copyWith(
        permiso: PermisoAutorizacion.compartir,
        estado: EstadoAutorizacion.activa,
      );

      expect(
        modificada.autorizacionId,
        original.autorizacionId,
      );
      expect(
        modificada.activoId,
        original.activoId,
      );
      expect(
        modificada.usuarioAutorizado,
        original.usuarioAutorizado,
      );
      expect(
        modificada.quienOtorga,
        original.quienOtorga,
      );
      expect(
        modificada.rol,
        original.rol,
      );
      expect(
        modificada.permiso,
        PermisoAutorizacion.compartir,
      );
      expect(
        modificada.estado,
        EstadoAutorizacion.activa,
      );
      expect(
        modificada.ambito.tipo,
        original.ambito.tipo,
      );
    });
  });

  group('AutorizacionActivo - valores inválidos', () {
    test('debe rechazar un ámbito inválido', () {
      expect(
        () => AutorizacionActivo.fromMap({
          'autorizacionId': 'aut-invalid-ambito',
          'activoId': 'activo-001',
          'usuarioAutorizado': 'usuario-001',
          'quienOtorga': 'propietario-001',
          'rol': 'broker',
          'permiso': 'ver',
          'ambito': {
            'tipo': 'ambito_inexistente',
          },
          'fechaInicio': Timestamp.fromDate(
            DateTime(2027, 1, 1),
          ),
          'estado': 'activa',
          'fechaOtorgamiento': Timestamp.fromDate(
            DateTime(2026, 12, 20),
          ),
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('debe rechazar un rol inválido', () {
      expect(
        () => AutorizacionActivo.fromMap({
          'autorizacionId': 'aut-invalid-rol',
          'activoId': 'activo-001',
          'usuarioAutorizado': 'usuario-001',
          'quienOtorga': 'propietario-001',
          'rol': 'rol_inexistente',
          'permiso': 'ver',
          'ambito': {
            'tipo': 'marketplace',
          },
          'fechaInicio': Timestamp.fromDate(
            DateTime(2027, 1, 1),
          ),
          'estado': 'activa',
          'fechaOtorgamiento': Timestamp.fromDate(
            DateTime(2026, 12, 20),
          ),
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('debe rechazar un permiso inválido', () {
      expect(
        () => AutorizacionActivo.fromMap({
          'autorizacionId': 'aut-invalid-permiso',
          'activoId': 'activo-001',
          'usuarioAutorizado': 'usuario-001',
          'quienOtorga': 'propietario-001',
          'rol': 'broker',
          'permiso': 'permiso_inexistente',
          'ambito': {
            'tipo': 'marketplace',
          },
          'fechaInicio': Timestamp.fromDate(
            DateTime(2027, 1, 1),
          ),
          'estado': 'activa',
          'fechaOtorgamiento': Timestamp.fromDate(
            DateTime(2026, 12, 20),
          ),
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('debe rechazar un estado inválido', () {
      expect(
        () => AutorizacionActivo.fromMap({
          'autorizacionId': 'aut-invalid-estado',
          'activoId': 'activo-001',
          'usuarioAutorizado': 'usuario-001',
          'quienOtorga': 'propietario-001',
          'rol': 'broker',
          'permiso': 'ver',
          'ambito': {
            'tipo': 'marketplace',
          },
          'fechaInicio': Timestamp.fromDate(
            DateTime(2027, 1, 1),
          ),
          'estado': 'estado_inexistente',
          'fechaOtorgamiento': Timestamp.fromDate(
            DateTime(2026, 12, 20),
          ),
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('debe rechazar una modalidad de representación inválida', () {
      expect(
        () => AutorizacionActivo.fromMap({
          'autorizacionId': 'aut-invalid-modalidad',
          'activoId': 'activo-001',
          'usuarioAutorizado': 'usuario-001',
          'quienOtorga': 'propietario-001',
          'rol': 'broker',
          'permiso': 'ver',
          'ambito': {
            'tipo': 'marketplace',
          },
          'fechaInicio': Timestamp.fromDate(
            DateTime(2027, 1, 1),
          ),
          'estado': 'activa',
          'modalidadRepresentacion': 'modalidad_inexistente',
          'fechaOtorgamiento': Timestamp.fromDate(
            DateTime(2026, 12, 20),
          ),
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('debe rechazar una exclusividad con tipo inválido', () {
      expect(
        () => AutorizacionActivo.fromMap({
          'autorizacionId': 'aut-invalid-exclusividad',
          'activoId': 'activo-001',
          'usuarioAutorizado': 'usuario-001',
          'quienOtorga': 'propietario-001',
          'rol': 'broker',
          'permiso': 'ver',
          'ambito': {
            'tipo': 'marketplace',
          },
          'fechaInicio': Timestamp.fromDate(
            DateTime(2027, 1, 1),
          ),
          'estado': 'activa',
          'exclusividad': {
            'activa': true,
            'tipo': 'tipo_inexistente',
            'alcance': 'Venta',
          },
          'fechaOtorgamiento': Timestamp.fromDate(
            DateTime(2026, 12, 20),
          ),
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
