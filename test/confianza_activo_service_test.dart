import 'package:flutter_test/flutter_test.dart';

import '../lib/services/confianza_activo_service.dart';
import '../lib/models/activos/activo_agro_test_data.dart';

void main() {
  group('ConfianzaActivoService', () {
   test('genera evaluación de confianza del activo', () {
  final activo =
      ActivoAgroTestData.crearGranjaAvicola();

  final service =
      ConfianzaActivoService();

  final evaluacion =
      service.generarEvaluacion(activo);

  print(
    '🧠 Nivel general: ${evaluacion.nivelGeneral}',
  );

  print(
    '📄 Documental: ${evaluacion.documental.nivel}',
  );

  print(
    '🌱 Productivo: ${evaluacion.productivo.nivel}',
  );

  print(
    '💰 Económico: ${evaluacion.economico.nivel}',
  );

  print(
    '⚖️ Legal: ${evaluacion.legal.nivel}',
  );

  print(
    '👥 Profesional: ${evaluacion.profesional.nivel}',
  );

  print(
    '💪 Fortalezas: ${evaluacion.fortalezas}',
  );

  print(
    '📋 Pendientes: ${evaluacion.pendientes}',
  );

  print(
    '📝 Resumen: ${evaluacion.resumen}',
  );

  expect(
    evaluacion.nivelGeneral,
    greaterThanOrEqualTo(0),
  );

  expect(
    evaluacion.nivelGeneral,
    lessThanOrEqualTo(100),
  );

  expect(
    evaluacion.resumen,
    isNotEmpty,
  );

  expect(
    evaluacion.responsable,
    isNotEmpty,
  );
});
  });
}