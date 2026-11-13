import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/evento_productivo_model.dart';
import 'package:agro_fields/services/calculo_agricola.dart';

EventoProductivo aplicacion({
  String id = 'a1',
  double? ha = 80,
  String? lote = 'lote3',
  String? producto = 'Glifosato 66%',
  String? dosis = '2 l/ha',
  double? viento,
  double? temperatura,
  double? humedadAmbiente,
}) {
  return EventoProductivo(
    eventoId: id,
    activoAgroId: 'act1',
    grupoId: 'g1',
    unidadId: lote,
    tipo: TipoEventoProductivo.aplicacion,
    fechaHecho: DateTime(2026, 11, 10),
    fechaCarga: DateTime(2026, 11, 13),
    cargadoPor: 'u1',
    superficieHa: ha,
    tratamiento: producto,
    dosis: dosis,
    vientoKmh: viento,
    temperatura: temperatura,
    humedadAmbiente: humedadAmbiente,
  );
}

EventoProductivo siembra(double ha) => EventoProductivo(
      eventoId: 's1',
      activoAgroId: 'act1',
      grupoId: 'g1',
      unidadId: 'lote3',
      tipo: TipoEventoProductivo.siembra,
      fechaHecho: DateTime(2026, 10, 20),
      fechaCarga: DateTime(2026, 11, 13),
      cargadoPor: 'u1',
      superficieHa: ha,
    );

void main() {
  group('Aplicación terrestre (GAP-APLI-01)', () {
    test('se guarda y se lee igual', () {
      final a = EventoProductivo(
        eventoId: 'a1',
        activoAgroId: 'act1',
        grupoId: 'g1',
        unidadId: 'lote3',
        tipo: TipoEventoProductivo.aplicacion,
        fechaHecho: DateTime(2026, 11, 10),
        fechaCarga: DateTime(2026, 11, 13),
        cargadoPor: 'u1',
        superficieHa: 80,
        tratamiento: 'Glifosato 66%',
        dosis: '2 l/ha',
        responsable: 'Contratista Pérez',
        recetaNumero: 'RA-1234',
        vientoKmh: 8,
        temperatura: 24,
        humedadAmbiente: 65,
      );
      final leido = EventoProductivo.fromMap(a.toMap(), 'a1');
      expect(leido.tipo, TipoEventoProductivo.aplicacion);
      expect(leido.tratamiento, 'Glifosato 66%');
      expect(leido.dosis, '2 l/ha');
      expect(leido.responsable, 'Contratista Pérez');
      expect(leido.recetaNumero, 'RA-1234');
      expect(leido.vientoKmh, 8);
      expect(leido.temperatura, 24);
      expect(leido.humedadAmbiente, 65);
    });

    test('controles: hectáreas, lote, producto y dosis', () {
      expect(aplicacion().validar(), isEmpty);
      expect(aplicacion(ha: 0).validar(), isNotEmpty);
      expect(aplicacion(lote: null).validar(), isNotEmpty);
      expect(aplicacion(producto: ' ').validar(), isNotEmpty);
      expect(aplicacion(dosis: null).validar(), isNotEmpty);
    });

    test('controles: condiciones imposibles no se guardan', () {
      expect(aplicacion(viento: -1).validar(), isNotEmpty);
      expect(aplicacion(temperatura: 80).validar(), isNotEmpty);
      expect(aplicacion(humedadAmbiente: 120).validar(), isNotEmpty);
      expect(
          aplicacion(viento: 10, temperatura: -2, humedadAmbiente: 90)
              .validar(),
          isEmpty);
    });

    test('viento alto: avisa con más de 15 km/h (no bloquea)', () {
      expect(vientoAlto(null), isFalse);
      expect(vientoAlto(15), isFalse);
      expect(vientoAlto(16), isTrue);
      expect(aplicacion(viento: 25).validar(), isEmpty);
    });

    test('aviso si se aplicaron más hectáreas de las sembradas', () {
      expect(
          aplicacionesQueSuperanSembrado([siembra(100), aplicacion(ha: 80)]),
          isEmpty);
      expect(
          aplicacionesQueSuperanSembrado([siembra(60), aplicacion(ha: 80)])
              .map((e) => e.eventoId),
          ['a1']);
    });

    test('la aplicación no cambia el resumen del cultivo', () {
      final r = calcularResumenCultivo([siembra(100), aplicacion()]);
      expect(r.haSembradas, 100);
      expect(r.haCosechadas, 0);
    });
  });
}
