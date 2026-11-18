import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/grupo_productivo_model.dart';

void main() {
  final fecha = DateTime(2026, 11, 10);

  group('GrupoProductivo (paso 6a, GAP-PROD-01)', () {
    test('se guarda y se lee igual', () {
      final grupo = GrupoProductivo(
        grupoId: 'g1',
        activoAgroId: 'a1',
        actividad: 'ganaderia',
        nombre: 'Rodeo de cria',
        etapa: EtapaGanadera.cria,
        tenencia: TenenciaAnimales.propios,
        unidadInicialId: 'u1',
        creadoPor: 'dueno',
        fechaCreacion: fecha,
      );

      final leido = GrupoProductivo.fromMap(grupo.toMap(), 'g1');

      expect(leido.actividad, 'ganaderia');
      expect(leido.etapa, EtapaGanadera.cria);
      expect(leido.tenencia, TenenciaAnimales.propios);
      expect(leido.unidadInicialId, 'u1');
      expect(leido.estado, EstadoGrupoProductivo.activo);
    });

    test('por defecto: identificacion por lote y tenencia desconocida', () {
      final leido = GrupoProductivo.fromMap({
        'activoAgroId': 'a1',
        'actividad': 'ganaderia',
        'nombre': 'Lote nuevo',
      }, 'g2');

      expect(leido.modoIdentificacion, ModoIdentificacion.porLote);
      expect(leido.tenencia, TenenciaAnimales.desconocida);
      expect(leido.etapa, isNull);
    });

    test('el registro por animal queda preparado', () {
      final grupo = GrupoProductivo(
        grupoId: 'g3',
        activoAgroId: 'a1',
        actividad: 'ganaderia',
        nombre: 'Toros',
        modoIdentificacion: ModoIdentificacion.porAnimal,
        creadoPor: 'dueno',
        fechaCreacion: fecha,
      );

      expect(grupo.toMap()['modoIdentificacion'], 'porAnimal');
    });

    test('las 7 categorias base de ganaderia', () {
      expect(categoriasGanaderasBase, [
        'vaca',
        'vaquillona',
        'toro',
        'ternero',
        'ternera',
        'novillito',
        'novillo',
      ]);
    });
  });

  group('GAP-PROD-02 - aves y peces (18/11/2026)', () {
    final fecha = DateTime(2026, 11, 18);

    test('las categorias sugeridas cambian segun la actividad', () {
      expect(categoriasBasePara('avicultura'), contains('parrilleros'));
      expect(categoriasBasePara('piscicultura'), contains('alevines'));
      expect(categoriasBasePara('ganaderia'), contains('vaca'));
      // Un grupo viejo o una actividad desconocida usa las de ganaderia.
      expect(categoriasBasePara(''), categoriasGanaderasBase);
    });

    test('un lote de aves se guarda y se lee igual, y no es ganadero', () {
      final grupo = GrupoProductivo(
        grupoId: 'g2',
        activoAgroId: 'a1',
        actividad: 'avicultura',
        nombre: 'Galpon 1 parrilleros',
        unidadInicialId: 'galpon1',
        creadoPor: 'dueno',
        fechaCreacion: fecha,
      );

      final leido = GrupoProductivo.fromMap(grupo.toMap(), 'g2');

      expect(leido.actividad, 'avicultura');
      expect(leido.etapa, isNull);
      expect(leido.tenencia, TenenciaAnimales.desconocida);
      expect(leido.esGanadero, isFalse);
      expect(leido.esAgricola, isFalse);
    });

    test('ganaderia y grupos viejos sin actividad siguen siendo rodeos', () {
      GrupoProductivo con(String actividad) => GrupoProductivo(
            grupoId: 'g',
            activoAgroId: 'a1',
            actividad: actividad,
            nombre: 'x',
            creadoPor: 'dueno',
            fechaCreacion: fecha,
          );
      expect(con('ganaderia').esGanadero, isTrue);
      expect(con('').esGanadero, isTrue);
      expect(con('piscicultura').esGanadero, isFalse);
    });

    test('la app ofrece las tres actividades con animales', () {
      expect(actividadesAnimales, ['ganaderia', 'avicultura', 'piscicultura']);
    });
  });
}
