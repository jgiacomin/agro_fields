import 'package:agro_fields/models/activos/cambio_territorio_model.dart';
import 'package:agro_fields/screens/territorio/territorio_textos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// AF-109: Historia del territorio (modelo y textos, sin Firebase).
void main() {
  final hoy = DateTime(2026, 11, 16);

  CambioTerritorio cambio({
    String id = 'c1',
    String tipo = 'desmonte',
    DateTime? desde,
    DateTime? hasta,
    String descripcion = 'Se desmontaron 80 ha',
    String fuente = 'propia',
    String? archivoRuta,
    String? estadoDato,
    String? corrige,
  }) {
    return CambioTerritorio(
      cambioId: id,
      activoAgroId: 'a1',
      tipo: tipo,
      fechaDesde: desde ?? DateTime(2018, 3, 15),
      fechaHasta: hasta,
      descripcion: descripcion,
      fuente: fuente,
      archivoRuta: archivoRuta,
      estadoDato: estadoDato ?? CambioTerritorio.estadoSegunArchivo(archivoRuta),
      corrigeCambioId: corrige,
      cargadoPor: 'dueno',
      fechaCarga: hoy,
    );
  }

  test('TERR-T1. Un cambio completo se puede guardar', () {
    expect(cambio().validar(hoy: hoy), isEmpty);
  });

  test('TERR-T2. Sin archivo queda declarado; con archivo, con documento', () {
    expect(CambioTerritorio.estadoSegunArchivo(null), 'declarado');
    expect(CambioTerritorio.estadoSegunArchivo('  '), 'declarado');
    expect(CambioTerritorio.estadoSegunArchivo('activos/a1/territorio/c1/x.pdf'),
        'conDocumento');
  });

  test('TERR-T3. No se puede marcar "con documento" sin archivo', () {
    expect(cambio(estadoDato: 'conDocumento').validar(hoy: hoy), isNotEmpty);
    expect(cambio(estadoDato: 'verificado').validar(hoy: hoy), isNotEmpty);
  });

  test('TERR-T4. Tipo o fuente inventados, o sin descripción, no se guarda', () {
    expect(cambio(tipo: 'mina').validar(hoy: hoy), isNotEmpty);
    expect(cambio(fuente: 'rumor').validar(hoy: hoy), isNotEmpty);
    expect(cambio(descripcion: '   ').validar(hoy: hoy), isNotEmpty);
  });

  test('TERR-T5. Fechas: no futuras y "hasta" no antes de "desde"', () {
    expect(cambio(desde: DateTime(2027, 1, 1)).validar(hoy: hoy), isNotEmpty);
    expect(
      cambio(desde: DateTime(2018, 3, 15), hasta: DateTime(2017, 1, 1))
          .validar(hoy: hoy),
      isNotEmpty,
    );
    expect(
      cambio(desde: DateTime(2018, 3, 15), hasta: DateTime(2018, 6, 30))
          .validar(hoy: hoy),
      isEmpty,
    );
    // Hoy mismo vale.
    expect(cambio(desde: hoy).validar(hoy: hoy), isEmpty);
  });

  test('TERR-T6. Vigentes: saca los corregidos y ordena del más nuevo al más viejo', () {
    final viejo = cambio(id: 'c1', desde: DateTime(2010));
    final mal = cambio(id: 'c2', desde: DateTime(2015));
    final arreglo = cambio(id: 'c3', desde: DateTime(2016), corrige: 'c2');
    final vigentes = CambioTerritorio.vigentes([viejo, mal, arreglo]);
    expect(vigentes.map((c) => c.cambioId), ['c3', 'c1']);
  });

  test('TERR-T7. Ida y vuelta por Firestore conserva los datos', () {
    final original = cambio(
      hasta: DateTime(2018, 6, 30),
      archivoRuta: 'activos/a1/territorio/c1/plano.pdf',
      corrige: 'c0',
    );
    final mapa = original.toMap();
    expect(mapa['fechaDesde'], isA<Timestamp>());
    final leido = CambioTerritorio.fromMap(mapa);
    expect(leido.tipo, 'desmonte');
    expect(leido.fechaHasta, DateTime(2018, 6, 30));
    expect(leido.estadoDato, 'conDocumento');
    expect(leido.corrigeCambioId, 'c0');
    expect(leido.validar(hoy: hoy), isEmpty);
  });

  test('TERR-T8. Datos raros se leen con cuidado (nunca como más de lo que son)', () {
    final leido = CambioTerritorio.fromMap({
      'cambioId': 'c9',
      'activoAgroId': 'a1',
      'tipo': 'inventado',
      'fuente': 'inventada',
      'estadoDato': 'verificado',
      'descripcion': 'x',
      'fechaDesde': '2019-01-01',
      'cargadoPor': 'dueno',
    });
    expect(leido.tipo, 'otro');
    expect(leido.fuente, 'otra');
    expect(leido.estadoDato, 'declarado');
    expect(leido.fechaDesde, DateTime(2019, 1, 1));
  });

  test('TERR-T9. Textos: todos los tipos y fuentes tienen nombre', () {
    for (final t in CambioTerritorio.tipos) {
      expect(nombreTipoCambio(t), isNot('Cambio'));
    }
    for (final f in CambioTerritorio.fuentes) {
      expect(nombreFuente(f), isNot(f));
    }
    expect(periodoTexto(DateTime(2018, 3, 5), null), '05/03/2018');
    expect(periodoTexto(DateTime(2018, 3, 5), DateTime(2018, 6, 30)),
        '05/03/2018 al 30/06/2018');
  });
}
