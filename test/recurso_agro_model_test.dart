import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/recurso_agro_model.dart';

void main() {
  test('RecursoAgro serializa y recupera correctamente', () {
    final recurso = RecursoAgro(
      recursoId: 'recurso_001',
      activoAgroId: 'activo_001',
      tipo: 'maquinaria',
      nombre: 'Tractor',
      descripcion: 'Tractor agrícola de prueba',
      unidad: 'unidad',
      cantidadActual: 1,
      cantidadMinima: 0,
      estado: 'disponible',
      moduloProduccionId: 'prod_001',
      numeroSerie: 'TRAC-001',
      observaciones: 'Recurso de prueba',
    );

    final mapa = recurso.toMap();

    final recuperado = RecursoAgro.fromMap(
      mapa,
      'recurso_001',
    );

    expect(recuperado.recursoId, 'recurso_001');
    expect(recuperado.activoAgroId, 'activo_001');
    expect(recuperado.tipo, 'maquinaria');
    expect(recuperado.nombre, 'Tractor');
    expect(recuperado.descripcion, 'Tractor agrícola de prueba');
    expect(recuperado.unidad, 'unidad');
    expect(recuperado.cantidadActual, 1);
    expect(recuperado.cantidadMinima, 0);
    expect(recuperado.estado, 'disponible');
    expect(recuperado.moduloProduccionId, 'prod_001');
    expect(recuperado.numeroSerie, 'TRAC-001');
    expect(recuperado.observaciones, 'Recurso de prueba');
  });
}
