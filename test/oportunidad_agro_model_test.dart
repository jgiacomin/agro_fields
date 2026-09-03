import 'package:flutter_test/flutter_test.dart';
import 'package:agro_fields/models/oportunidad_agro_model.dart';

void main() {
  test('OportunidadAgro serializa y deserializa correctamente', () {
    final fechaCreacion = DateTime(2026, 8, 27, 10, 0);
    final fechaActualizacion = DateTime(2026, 8, 27, 11, 0);

    final original = OportunidadAgro(
      oportunidadId: 'op-001',
      creadorId: 'usuario-001',
      titulo: 'Campo agrícola en oportunidad',
      descripcion: 'Oportunidad vinculada a un Activo Agro existente.',
      actividad: 'agricultura',
      productoServicio: 'producción agrícola',
      activoId: 'activo-001',
      ladoMercado: 'oferta',
      tipoOportunidad: 'inversion',
      pais: 'Argentina',
      provinciaEstado: 'Buenos Aires',
      localidad: 'La Plata',
      ubicacionEspecifica: 'Zona rural',
      queSeNecesita: 'Capital para producción',
      volumenRequerido: '100 hectáreas',
      capacidadProductiva: 'Producción agrícola',
      periodicidad: 'anual',
      plazo: '12 meses',
      condiciones: 'Condiciones a definir',
      requisitos: ['Capital', 'Documentación'],
      participantes: ['usuario-001'],
      montoObjetivo: 100000,
      montoMinimo: 5000,
      inversionEstimada: 90000,
      costosEstimados: 80000,
      produccionEstimada: 500,
      precioEstimado: 200,
      ingresosEstimados: 100000,
      resultadoEstimado: 20000,
      moneda: 'USD',
      periodoCalculo: 'anual',
      fuenteEconomica: 'estimación inicial',
      documentacion: ['documento-001'],
      evidencias: ['evidencia-001'],
      estado: 'borrador',
      confianza: 0,
      madurez: 0,
      historial: [],
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
    expect(reconstruida.actividad, 'agricultura');
    expect(reconstruida.productoServicio, 'producción agrícola');
    expect(reconstruida.ladoMercado, 'oferta');
    expect(reconstruida.tipoOportunidad, 'inversion');
    expect(reconstruida.pais, 'Argentina');
    expect(reconstruida.provinciaEstado, 'Buenos Aires');
    expect(reconstruida.localidad, 'La Plata');

    expect(reconstruida.montoObjetivo, 100000);
    expect(reconstruida.montoMinimo, 5000);
    expect(reconstruida.inversionEstimada, 90000);
    expect(reconstruida.costosEstimados, 80000);
    expect(reconstruida.produccionEstimada, 500);
    expect(reconstruida.precioEstimado, 200);
    expect(reconstruida.ingresosEstimados, 100000);
    expect(reconstruida.resultadoEstimado, 20000);

    expect(reconstruida.moneda, 'USD');
    expect(reconstruida.estado, 'borrador');
    expect(reconstruida.confianza, 0);
    expect(reconstruida.madurez, 0);

    expect(reconstruida.requisitos, ['Capital', 'Documentación']);
    expect(reconstruida.participantes, ['usuario-001']);
    expect(reconstruida.documentacion, ['documento-001']);
    expect(reconstruida.evidencias, ['evidencia-001']);

    expect(reconstruida.fechaCreacion, fechaCreacion);
    expect(reconstruida.fechaActualizacion, fechaActualizacion);
  });

  test('OportunidadAgro permite montos opcionales', () {
    final fecha = DateTime(2026, 8, 27);

    final oportunidad = OportunidadAgro(
      oportunidadId: 'op-002',
      creadorId: 'usuario-002',
      titulo: 'Servicio agropecuario',
      descripcion: 'Oportunidad de servicio.',
      actividad: 'servicios',
      productoServicio: 'servicio agropecuario',
      ladoMercado: 'demanda',
      tipoOportunidad: 'servicio',
      pais: 'Argentina',
      provinciaEstado: 'Buenos Aires',
      localidad: 'La Plata',
      ubicacionEspecifica: '',
      queSeNecesita: 'Servicio',
      volumenRequerido: '',
      capacidadProductiva: '',
      periodicidad: '',
      plazo: '',
      condiciones: '',
      requisitos: [],
      participantes: [],
      moneda: 'USD',
      periodoCalculo: '',
      fuenteEconomica: '',
      documentacion: [],
      evidencias: [],
      estado: 'borrador',
      confianza: 0,
      madurez: 0,
      historial: [],
      fechaCreacion: fecha,
      fechaActualizacion: fecha,
    );

    final mapa = oportunidad.toMap();

    final reconstruida = OportunidadAgro.fromMap(
      mapa,
      oportunidad.oportunidadId,
    );

    expect(reconstruida.activoId, isNull);
    expect(reconstruida.montoObjetivo, isNull);
    expect(reconstruida.montoMinimo, isNull);
    expect(reconstruida.tipoOportunidad, 'servicio');
  });
}