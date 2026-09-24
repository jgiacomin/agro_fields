import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/evento_afectacion_model.dart';

void main() {
  test('ImpactoProductivo serializa y recupera correctamente', () {
    final impacto = ImpactoProductivo(
      tipoImpacto: 'reduccion_produccion',
      valor: 30000,
      unidad: 'kg',
      referenciaProductiva: ReferenciaEntidad(
        tipo: 'CicloProductivo',
        id: 'ciclo_001',
      ),
      estado: 'estimado',
    );

    final mapa = impacto.toMap();

    final recuperado =
        ImpactoProductivo.fromMap(mapa);

    expect(
      recuperado.tipoImpacto,
      'reduccion_produccion',
    );

    expect(
      recuperado.valor,
      30000,
    );

    expect(
      recuperado.unidad,
      'kg',
    );

    expect(
      recuperado.referenciaProductiva?.tipo,
      'CicloProductivo',
    );

    expect(
      recuperado.referenciaProductiva?.id,
      'ciclo_001',
    );

    expect(
      recuperado.estado,
      'estimado',
    );
  });
}