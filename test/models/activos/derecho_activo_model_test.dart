import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/models/activos/derecho_activo_model.dart';
import 'package:agro_fields/models/activos/relacion_juridica_model.dart';

void main() {
  group('DerechoActivo - serialización', () {
    test('debe serializar y reconstruir correctamente', () {
      final fechaInicio = DateTime(2026, 1, 10);
      final fechaFin = DateTime(2036, 1, 10);
      final fechaCreacion = DateTime(2026, 9, 16, 10, 30);
      final ultimaActualizacion = DateTime(2026, 9, 16, 11, 45);

      final alcance = AlcanceTerritorial(
        tipoAlcance: 'superficie_parcial',
        descripcion: 'Sector norte del activo',
        superficieAfectada: 1250.50,
        unidadSuperficie: 'ha',
        referenciaGeografica: 'Parcela Norte',
      );

      final derecho = DerechoActivo(
        derechoId: 'derecho-001',
        activoAgroId: 'activo-001',
        tipoDerecho: 'dominio',
        descripcionTipo: null,
        tipoObjeto: 'activo_completo',
        descripcionObjeto: 'Dominio sobre el inmueble rural',
        alcanceTerritorial: alcance,
        tipoInstrumento: 'titulo',
        identificadorInstrumento: 'TIT-2026-001',
        emisor: 'Registro correspondiente',
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estado: 'vigente',
        condiciones: const [
          'Sujeto a restricciones legales aplicables',
          'Información pendiente de verificación documental',
        ],
        fechaCreacion: fechaCreacion,
        ultimaActualizacion: ultimaActualizacion,
      );

      final map = derecho.toMap();

      expect(map['derechoId'], 'derecho-001');
      expect(map['activoAgroId'], 'activo-001');
      expect(map['tipoDerecho'], 'dominio');
      expect(map['tipoObjeto'], 'activo_completo');
      expect(map['estado'], 'vigente');

      expect(map['fechaInicio'], isA<Timestamp>());
      expect(map['fechaFin'], isA<Timestamp>());
      expect(map['fechaCreacion'], isA<Timestamp>());
      expect(map['ultimaActualizacion'], isA<Timestamp>());

      expect(map['alcanceTerritorial'], isA<Map<String, dynamic>>());

      final alcanceMap =
          Map<String, dynamic>.from(map['alcanceTerritorial'] as Map);

      expect(alcanceMap['tipoAlcance'], 'superficie_parcial');
      expect(alcanceMap['descripcion'], 'Sector norte del activo');
      expect(alcanceMap['superficieAfectada'], 1250.50);
      expect(alcanceMap['unidadSuperficie'], 'ha');
      expect(
        alcanceMap['referenciaGeografica'],
        'Parcela Norte',
      );

      final reconstruido = DerechoActivo.fromMap(map);

      expect(reconstruido.derechoId, derecho.derechoId);
      expect(reconstruido.activoAgroId, derecho.activoAgroId);
      expect(reconstruido.tipoDerecho, derecho.tipoDerecho);
      expect(reconstruido.tipoObjeto, derecho.tipoObjeto);
      expect(
        reconstruido.descripcionObjeto,
        derecho.descripcionObjeto,
      );
      expect(
        reconstruido.tipoInstrumento,
        derecho.tipoInstrumento,
      );
      expect(
        reconstruido.identificadorInstrumento,
        derecho.identificadorInstrumento,
      );
      expect(reconstruido.emisor, derecho.emisor);
      expect(reconstruido.estado, derecho.estado);
      expect(reconstruido.condiciones, derecho.condiciones);

      expect(
        reconstruido.fechaInicio,
        fechaInicio,
      );
      expect(
        reconstruido.fechaFin,
        fechaFin,
      );
      expect(
        reconstruido.fechaCreacion,
        fechaCreacion,
      );
      expect(
        reconstruido.ultimaActualizacion,
        ultimaActualizacion,
      );

      expect(reconstruido.alcanceTerritorial, isNotNull);
      expect(
        reconstruido.alcanceTerritorial!.tipoAlcance,
        'superficie_parcial',
      );
      expect(
        reconstruido.alcanceTerritorial!.descripcion,
        'Sector norte del activo',
      );
      expect(
        reconstruido.alcanceTerritorial!.superficieAfectada,
        1250.50,
      );
      expect(
        reconstruido.alcanceTerritorial!.unidadSuperficie,
        'ha',
      );
      expect(
        reconstruido.alcanceTerritorial!.referenciaGeografica,
        'Parcela Norte',
      );
    });
  });

  group('RelacionJuridica - serialización', () {
    test('debe serializar y reconstruir correctamente', () {
      final fechaInicio = DateTime(2026, 2, 1);
      final fechaFin = DateTime(2030, 2, 1);

      final relacion = RelacionJuridica(
        relacionId: 'relacion-001',
        derechoId: 'derecho-001',
        sujetoId: 'sujeto-001',
        tipoSujeto: 'persona',
        rol: 'titular',
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estado: 'vigente',
        condiciones: const [
          'Condición contractual registrada',
        ],
      );

      final map = relacion.toMap();

      expect(map['relacionId'], 'relacion-001');
      expect(map['derechoId'], 'derecho-001');
      expect(map['sujetoId'], 'sujeto-001');
      expect(map['tipoSujeto'], 'persona');
      expect(map['rol'], 'titular');
      expect(map['estado'], 'vigente');
      expect(map['condiciones'], [
        'Condición contractual registrada',
      ]);

      expect(map['fechaInicio'], isA<Timestamp>());
      expect(map['fechaFin'], isA<Timestamp>());

      final reconstruida = RelacionJuridica.fromMap(map);

      expect(reconstruida.relacionId, relacion.relacionId);
      expect(reconstruida.derechoId, relacion.derechoId);
      expect(reconstruida.sujetoId, relacion.sujetoId);
      expect(reconstruida.tipoSujeto, relacion.tipoSujeto);
      expect(reconstruida.rol, relacion.rol);
      expect(reconstruida.estado, relacion.estado);
      expect(reconstruida.condiciones, relacion.condiciones);
      expect(reconstruida.fechaInicio, fechaInicio);
      expect(reconstruida.fechaFin, fechaFin);
    });
  });

  group('DerechoActivo - alcance territorial opcional', () {
    test('debe permitir un derecho sin alcance territorial', () {
      final derecho = DerechoActivo(
        derechoId: 'derecho-002',
        activoAgroId: 'activo-002',
        tipoDerecho: 'usufructo',
        tipoObjeto: 'activo_completo',
        descripcionObjeto: 'Uso y disfrute del activo',
        alcanceTerritorial: null,
        tipoInstrumento: 'resolucion',
        estado: 'vigente',
        fechaCreacion: DateTime(2026, 9, 16),
        ultimaActualizacion: DateTime(2026, 9, 16),
      );

      final map = derecho.toMap();

      expect(map['alcanceTerritorial'], isNull);

      final reconstruido = DerechoActivo.fromMap(map);

      expect(reconstruido.alcanceTerritorial, isNull);
      expect(reconstruido.tipoDerecho, 'usufructo');
      expect(reconstruido.estado, 'vigente');
    });
  });
}