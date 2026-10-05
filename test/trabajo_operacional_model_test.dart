import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/trabajo_operacional_model.dart';

void main() {
  test('TrabajoOperacional serializa y recupera correctamente', () {
    final fechaInicioPlanificada = DateTime(2026, 10, 5, 8, 0);
    final fechaFinPlanificada = DateTime(2026, 10, 5, 12, 0);
    final fechaInicioReal = DateTime(2026, 10, 5, 8, 15);
    final fechaFinReal = DateTime(2026, 10, 5, 11, 45);
    final fechaCreacion = DateTime(2026, 10, 4, 18, 30);
    final ultimaActualizacion = DateTime(2026, 10, 5, 11, 45);

    final trabajo = TrabajoOperacional(
      trabajoId: 'trabajo_001',
      activoAgroId: 'activo_001',
      moduloProduccionId: 'prod_001',
      cicloId: 'ciclo_001',
      familiaActividad: 'PRODUCCIÓN',
      tipoActividad: 'SIEMBRA',
      descripcion: 'Siembra de lote productivo',
      objetivo: 'Implantar cultivo en el lote planificado',
      fechaInicioPlanificada: fechaInicioPlanificada,
      fechaFinPlanificada: fechaFinPlanificada,
      estadoTrabajo: TrabajoOperacional.estadoRealizado,
      fechaInicioReal: fechaInicioReal,
      fechaFinReal: fechaFinReal,
      responsableId: 'usuario_001',
      objetoTipo: 'PARCELA',
      objetoId: 'parcela_001',
      cantidadAlcance: 200,
      unidadAlcance: 'ha',
      observaciones: 'Trabajo realizado dentro de la ventana prevista',
      creadoPor: 'usuario_001',
      fechaCreacion: fechaCreacion,
      ultimaActualizacion: ultimaActualizacion,
    );

    final mapa = trabajo.toMap();

    final recuperado = TrabajoOperacional.fromMap(
      mapa,
      'trabajo_001',
    );

    expect(
      recuperado.trabajoId,
      'trabajo_001',
    );

    expect(
      recuperado.activoAgroId,
      'activo_001',
    );

    expect(
      recuperado.moduloProduccionId,
      'prod_001',
    );

    expect(
      recuperado.cicloId,
      'ciclo_001',
    );

    expect(
      recuperado.familiaActividad,
      'PRODUCCIÓN',
    );

    expect(
      recuperado.tipoActividad,
      'SIEMBRA',
    );

    expect(
      recuperado.descripcion,
      'Siembra de lote productivo',
    );

    expect(
      recuperado.objetivo,
      'Implantar cultivo en el lote planificado',
    );

    expect(
      recuperado.fechaInicioPlanificada,
      fechaInicioPlanificada,
    );

    expect(
      recuperado.fechaFinPlanificada,
      fechaFinPlanificada,
    );

    expect(
      recuperado.estadoTrabajo,
      TrabajoOperacional.estadoRealizado,
    );

    expect(
      recuperado.fechaInicioReal,
      fechaInicioReal,
    );

    expect(
      recuperado.fechaFinReal,
      fechaFinReal,
    );

    expect(
      recuperado.responsableId,
      'usuario_001',
    );

    expect(
      recuperado.objetoTipo,
      'PARCELA',
    );

    expect(
      recuperado.objetoId,
      'parcela_001',
    );

    expect(
      recuperado.cantidadAlcance,
      200,
    );

    expect(
      recuperado.unidadAlcance,
      'ha',
    );

    expect(
      recuperado.observaciones,
      'Trabajo realizado dentro de la ventana prevista',
    );

    expect(
      recuperado.creadoPor,
      'usuario_001',
    );

    expect(
      recuperado.fechaCreacion,
      fechaCreacion,
    );

    expect(
      recuperado.ultimaActualizacion,
      ultimaActualizacion,
    );
  });
}
