import 'package:flutter_test/flutter_test.dart';
import 'package:agro_fields/models/oportunidad_agro_model.dart';

void main() {
  test('OportunidadAgro serializa y deserializa correctamente', () {
    final fechaCreacion = DateTime(2026, 8, 27, 10, 0);
    final fechaActualizacion = DateTime(2026, 8, 27, 11, 0);

    final original = OportunidadAgro(
      oportunidadId: 'op-001',
      activoId: 'activo-001',
      creadorId: 'usuario-001',
      titulo: 'Campo agrícola en oportunidad',
      descripcion: 'Oportunidad vinculada a un Activo Agro existente.',
      tipo: 'inversion',
      montoObjetivo: 100000,
      montoMinimo: 5000,
      estado: 'borrador',
      fechaCreacion: fechaCreacion,
      fechaActualizacion: fechaActualizacion,
    );

    final mapa = original.toMap();

    final reconstruida = OportunidadAgro.fromMap(
      mapa,
      original.oportunidadId,
    );

    expect(reconstruida.oportunidadId, 'op-001');
    expect(reconstruida.activoId, 'activo-001');
    expect(reconstruida.creadorId, 'usuario-001');
    expect(reconstruida.titulo, 'Campo agrícola en oportunidad');
    expect(
      reconstruida.descripcion,
      'Oportunidad vinculada a un Activo Agro existente.',
    );
    expect(reconstruida.tipo, 'inversion');
    expect(reconstruida.montoObjetivo, 100000);
    expect(reconstruida.montoMinimo, 5000);
    expect(reconstruida.estado, 'borrador');
    expect(reconstruida.fechaCreacion, fechaCreacion);
    expect(reconstruida.fechaActualizacion, fechaActualizacion);
  });

  test('OportunidadAgro permite montos opcionales', () {
    final fecha = DateTime(2026, 8, 27);

    final oportunidad = OportunidadAgro(
      oportunidadId: 'op-002',
      activoId: 'activo-002',
      creadorId: 'usuario-002',
      titulo: 'Servicio agropecuario',
      descripcion: 'Oportunidad de servicio.',
      tipo: 'servicio',
      estado: 'borrador',
      fechaCreacion: fecha,
      fechaActualizacion: fecha,
    );

    final mapa = oportunidad.toMap();

    final reconstruida = OportunidadAgro.fromMap(
      mapa,
      oportunidad.oportunidadId,
    );

    expect(reconstruida.montoObjetivo, isNull);
    expect(reconstruida.montoMinimo, isNull);
    expect(reconstruida.tipo, 'servicio');
  });
}