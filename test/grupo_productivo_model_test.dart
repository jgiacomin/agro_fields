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
}
