import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/activo_agro_model_v2.dart';
import '../lib/models/activos/activo_agro_test_data.dart';
import '../lib/services/confianza_activo_service.dart';

void main() {
  group('Activo Agro - Integración completa', () {
    test('recorre producción, confianza, madurez y serialización', () {
      // =====================================================
      // 1. CREAR ACTIVO
      // =====================================================

      final activo =
          ActivoAgroTestData.crearGranjaAvicola();

      expect(activo, isA<ActivoAgroV2>());

      print('🌱 Activo: ${activo.nombre}');

      // =====================================================
      // 2. PRODUCCIÓN
      // =====================================================

      expect(
        activo.producciones,
        isNotEmpty,
      );

      final produccion =
          activo.producciones.first;

      print(
        '🌾 Producción: ${produccion.actividad}',
      );

      // =====================================================
      // 3. CICLOS PRODUCTIVOS
      // =====================================================

      expect(
        produccion.ciclos,
        isNotEmpty,
      );

      print(
        '🔄 Ciclos: ${produccion.ciclos.length}',
      );

      // =====================================================
      // 4. SERVICIO DE CONFIANZA
      // =====================================================

      final servicio =
          ConfianzaActivoService();

      final nivel =
          servicio.calcularNivel(activo);

      print(
        '🧠 Confianza: $nivel',
      );

      expect(
        nivel,
        greaterThanOrEqualTo(0),
      );

      expect(
        nivel,
        lessThanOrEqualTo(100),
      );

      // =====================================================
      // 5. MADUREZ
      // =====================================================

      final madurez =
          servicio.calcularMadurez(activo);

      print(
        '🚜 Madurez: ${madurez.porcentaje}%',
      );

      print(
        '📋 Faltantes: ${madurez.faltantes}',
      );

      expect(
        madurez.porcentaje,
        greaterThanOrEqualTo(0),
      );

      expect(
        madurez.porcentaje,
        lessThanOrEqualTo(100),
      );

      // =====================================================
      // 6. EVALUACIÓN
      // =====================================================

      final evaluacion =
          servicio.generarEvaluacion(activo);

      print(
        '🧠 Evaluación general: '
        '${evaluacion.nivelGeneral}',
      );

      expect(
        evaluacion.nivelGeneral,
        greaterThanOrEqualTo(0),
      );

      expect(
        evaluacion.nivelGeneral,
        lessThanOrEqualTo(100),
      );

      // =====================================================
      // 7. SERIALIZACIÓN
      // =====================================================

      final mapa =
          activo.toMap();

      expect(
        mapa,
        isA<Map<String, dynamic>>(),
      );

      print('💾 Serialización OK');

      // =====================================================
      // 8. RECUPERACIÓN
      // =====================================================

      final recuperado =
          ActivoAgroV2.fromMap(
        mapa,
        activo.activoId,
      );

      expect(
        recuperado.nombre,
        activo.nombre,
      );

      expect(
        recuperado.producciones.length,
        activo.producciones.length,
      );

      expect(
        recuperado.producciones.first.ciclos.length,
        produccion.ciclos.length,
      );

      print('🔄 Recuperación OK');

      // =====================================================
      // 9. RESULTADO FINAL
      // =====================================================

      print(
        '✅ INTEGRACIÓN ACTIVO AGRO OK',
      );
    });
  });
}