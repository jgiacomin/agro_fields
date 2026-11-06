import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/activo_agro_test_data.dart';
import 'package:agro_fields/models/activos/activo_publico_model.dart';

void main() {
  group('ActivoPublico - resumen del marketplace', () {
    test('nace pendiente de revisión y no visible', () {
      final activo = ActivoAgroTestData.crearGranjaAvicola();

      final resumen = ActivoPublico.desdeActivo(activo);

      expect(resumen.activoId, activo.activoId);
      expect(resumen.estadoPublicacion, 'pendienteRevision');
      expect(resumen.visible, isFalse);
      expect(resumen.propietarioId, activo.propietarioId);
    });

    test('copia solo los datos publicables', () {
      final activo = ActivoAgroTestData.crearGranjaAvicola();

      final resumen = ActivoPublico.desdeActivo(activo);

      expect(resumen.nombre, activo.nombre);
      expect(resumen.localidad, activo.ubicacion.localidad);
      expect(resumen.provincia, activo.ubicacion.provincia);
      expect(resumen.superficie, activo.ubicacion.superficie);
      expect(resumen.nivelConfianza, activo.confianza.nivelGeneral);
      expect(resumen.madurezPorcentaje, activo.madurez.porcentaje);
      expect(
        resumen.producciones,
        activo.producciones.map((p) => p.actividad).toList(),
      );
    });

    test('el mapa NO lleva datos privados del expediente', () {
      final activo = ActivoAgroTestData.crearGranjaAvicola();

      final mapa = ActivoPublico.desdeActivo(activo).toMap();

      expect(
        mapa.keys.toSet(),
        {
          'activoId',
          'nombre',
          'descripcion',
          'tipoActivo',
          'pais',
          'provincia',
          'localidad',
          'superficie',
          'nivelConfianza',
          'madurezPorcentaje',
          'producciones',
          'propietarioId',
          'estadoPublicacion',
          'visible',
          'ultimaActualizacion',
        },
      );

      for (final privado in [
        'economia',
        'documentacion',
        'suelo',
        'historial',
        'participantes',
        'derechos',
        'relacionesJuridicas',
        'publicadorId',
        'creadorId',
        'datos',
      ]) {
        expect(mapa.containsKey(privado), isFalse, reason: privado);
      }
    });

    test('se guarda y se recupera igual', () {
      final activo = ActivoAgroTestData.crearGranjaAvicola();
      final original = ActivoPublico.desdeActivo(activo);

      final recuperado =
          ActivoPublico.fromMap(original.toMap(), original.activoId);

      expect(recuperado.nombre, original.nombre);
      expect(recuperado.superficie, original.superficie);
      expect(recuperado.producciones, original.producciones);
      expect(recuperado.estadoPublicacion, original.estadoPublicacion);
      expect(recuperado.visible, original.visible);
    });
  });
}
