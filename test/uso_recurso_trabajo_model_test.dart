import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/uso_recurso_trabajo_model.dart';

void main() {
  test('UsoRecursoTrabajo serializa y recupera correctamente', () {
    final fechaUso = DateTime(2026, 10, 8);

    final uso = UsoRecursoTrabajo(
      usoId: 'uso_001',
      activoAgroId: 'activo_001',
      recursoId: 'recurso_001',
      trabajoId: 'trabajo_001',
      cantidadUtilizada: 150,
      unidad: 'litros',
      fechaUso: fechaUso,
      responsableId: 'usuario_001',
      observaciones: 'Uso de combustible en trabajo agrícola',
    );

    final mapa = uso.toMap();

    final recuperado = UsoRecursoTrabajo.fromMap(
      mapa,
      'uso_001',
    );

    expect(recuperado.usoId, 'uso_001');
    expect(recuperado.activoAgroId, 'activo_001');
    expect(recuperado.recursoId, 'recurso_001');
    expect(recuperado.trabajoId, 'trabajo_001');
    expect(recuperado.cantidadUtilizada, 150);
    expect(recuperado.unidad, 'litros');
    expect(recuperado.fechaUso, fechaUso);
    expect(recuperado.responsableId, 'usuario_001');
    expect(
      recuperado.observaciones,
      'Uso de combustible en trabajo agrícola',
    );
  });
}
