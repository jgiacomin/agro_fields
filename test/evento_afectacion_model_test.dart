import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/evento_afectacion_model.dart';

void main() {
  test('EventoAfectacion serializa y recupera correctamente', () {
    final fechaInicio = DateTime(2026, 9, 1);
    final fechaFin = DateTime(2026, 9, 5);
    final fechaEstimacion = DateTime(2026, 9, 10);

    final evento = EventoAfectacion(
      eventoId: 'evento_001',
      activoAgroId: 'activo_001',
      tipoEvento: 'climatico',
      subtipoEvento: 'inundacion',
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      descripcion: 'Inundación de prueba',
      origen: 'declaracion_usuario',
      estado: 'registrado',
      usuarioRegistrador: 'usuario_001',
      fechaRegistro: DateTime(2026, 9, 6),
      afectaciones: [
        Afectacion(
          objetoTipo: 'ModuloProduccion',
          objetoId: 'prod_001',
          descripcion: 'Afectación de superficie productiva',
          magnitud: 40,
          unidad: 'ha',
          superficieAfectada: 40,
          porcentajeAfectado: 20,
          nivel: 'medio',
          estado: 'activa',
          consecuencias: [
            Consecuencia(
              tipoConsecuencia: 'reduccion_produccion',
              descripcion: 'Reducción estimada de producción',
              estado: 'en_evaluacion',
              fechaEstimacion: fechaEstimacion,
              referenciaProductiva: ReferenciaEntidad(
                tipo: 'CicloProductivo',
                id: 'ciclo_001',
              ),
              referenciaEconomica: ReferenciaDatoEconomico(
                nombreDato: 'ingresos_estimados',
                tipoTemporal: 'actual',
                periodo: '2026',
              ),
              impactoProductivo: ImpactoProductivo(
                tipoImpacto: 'reduccion_produccion',
                valor: 30000,
                unidad: 'kg',
                referenciaProductiva: ReferenciaEntidad(
                tipo: 'CicloProductivo',
                id: 'ciclo_001',
             ),
               estado: 'estimado',
            ),
            ),
          ],
        ),
      ],
    );

    final mapa = evento.toMap();

    final recuperado = EventoAfectacion.fromMap(mapa);

    expect(
      recuperado.eventoId,
      'evento_001',
    );

    expect(
      recuperado.activoAgroId,
      'activo_001',
    );

    expect(
      recuperado.tipoEvento,
      'climatico',
    );

    expect(
      recuperado.subtipoEvento,
      'inundacion',
    );

    expect(
      recuperado.fechaInicio,
      fechaInicio,
    );

    expect(
      recuperado.fechaFin,
      fechaFin,
    );

    expect(
      recuperado.descripcion,
      'Inundación de prueba',
    );

    expect(
      recuperado.origen,
      'declaracion_usuario',
    );

    expect(
      recuperado.estado,
      'registrado',
    );

    expect(
      recuperado.usuarioRegistrador,
      'usuario_001',
    );

    expect(
      recuperado.afectaciones.length,
      1,
    );

    final afectacion = recuperado.afectaciones.first;

    expect(
      afectacion.objetoTipo,
      'ModuloProduccion',
    );

    expect(
      afectacion.objetoId,
      'prod_001',
    );

    expect(
      afectacion.magnitud,
      40,
    );

    expect(
      afectacion.unidad,
      'ha',
    );

    expect(
      afectacion.superficieAfectada,
      40,
    );

    expect(
      afectacion.porcentajeAfectado,
      20,
    );

    expect(
      afectacion.consecuencias.length,
      1,
    );

    final consecuencia = afectacion.consecuencias.first;

    expect(
      consecuencia.tipoConsecuencia,
      'reduccion_produccion',
    );

    expect(
      consecuencia.descripcion,
      'Reducción estimada de producción',
    );

    expect(
      consecuencia.referenciaProductiva?.tipo,
      'CicloProductivo',
    );

    expect(
      consecuencia.referenciaProductiva?.id,
      'ciclo_001',
    );

    expect(
      consecuencia.referenciaEconomica?.nombreDato,
      'ingresos_estimados',
    );

    expect(
      consecuencia.referenciaEconomica?.tipoTemporal,
      'actual',
    );

    expect(
      consecuencia.referenciaEconomica?.periodo,
      '2026',
    );
    expect(
  consecuencia.impactoProductivo?.tipoImpacto,
  'reduccion_produccion',
);

expect(
  consecuencia.impactoProductivo?.valor,
  30000,
);

expect(
  consecuencia.impactoProductivo?.unidad,
  'kg',
);

expect(
  consecuencia.impactoProductivo?.referenciaProductiva?.tipo,
  'CicloProductivo',
);

expect(
  consecuencia.impactoProductivo?.referenciaProductiva?.id,
  'ciclo_001',
);

expect(
  consecuencia.impactoProductivo?.estado,
  'estimado',
);
  });
}