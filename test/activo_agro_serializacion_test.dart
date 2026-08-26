import 'package:flutter_test/flutter_test.dart';
import '../lib/models/activos/activo_agro_test_data.dart';
import '../lib/models/activos/activo_agro_model_v2.dart';
import '../lib/models/activos/suelo_activo_model.dart';

void main() {
  test('Activo Agro V2 - serialización y SueloActivo', () {
    print('🌱 INICIO TEST ACTIVO AGRO V2');
  // =====================================================
  // 1. CREAR ACTIVO DE PRUEBA
  // =====================================================

  final activo = ActivoAgroTestData.crearGranjaAvicola();

  print('✅ Activo creado: ${activo.nombre}');

  // =====================================================
  // 2. VERIFICAR SUELO INICIAL
  // =====================================================

  print('\n🌱 VERIFICANDO SUELO INICIAL');

  if (activo.suelo.estado != 'sin_evaluar') {
    throw Exception(
      '❌ Error: el suelo inicial no tiene estado "sin_evaluar"',
    );
  }

  print('✅ Suelo inicial correcto');
  print('   Estado: ${activo.suelo.estado}');

  // =====================================================
  // 3. SERIALIZAR ACTIVO
  // =====================================================

  print('\n📦 SERIALIZANDO ACTIVO');

  final mapa = activo.toMap();

  if (!mapa.containsKey('suelo')) {
    throw Exception(
      '❌ Error: el mapa no contiene el campo "suelo"',
    );
  }

  print('✅ Campo "suelo" presente en el mapa');
  print('   Suelo serializado: ${mapa['suelo']}');

  // =====================================================
  // 4. DESERIALIZAR ACTIVO
  // =====================================================

  print('\n🔄 DESERIALIZANDO ACTIVO');

  final activoRecuperado = ActivoAgroV2.fromMap(
    mapa,
    activo.activoId,
  );

  print('✅ Activo recuperado: ${activoRecuperado.nombre}');

  // =====================================================
  // 5. VERIFICAR IDENTIDAD BÁSICA
  // =====================================================

  if (activoRecuperado.activoId != activo.activoId) {
    throw Exception(
      '❌ Error: activoId no coincide después de la deserialización',
    );
  }

  if (activoRecuperado.nombre != activo.nombre) {
    throw Exception(
      '❌ Error: nombre no coincide después de la deserialización',
    );
  }

  print('✅ Identidad del activo conservada');

  // =====================================================
  // 6. VERIFICAR SUELO DESERIALIZADO
  // =====================================================

  print('\n🌱 VERIFICANDO SUELO RECUPERADO');

  final sueloRecuperado = activoRecuperado.suelo;

  if (sueloRecuperado.estado != activo.suelo.estado) {
    throw Exception(
      '❌ Error: estado del suelo no coincide',
    );
  }

  if (sueloRecuperado.textura != activo.suelo.textura) {
    throw Exception(
      '❌ Error: textura del suelo no coincide',
    );
  }

  if (sueloRecuperado.drenaje != activo.suelo.drenaje) {
    throw Exception(
      '❌ Error: drenaje del suelo no coincide',
    );
  }

  if (sueloRecuperado.ph != activo.suelo.ph) {
    throw Exception(
      '❌ Error: pH del suelo no coincide',
    );
  }

  if (sueloRecuperado.materiaOrganica !=
      activo.suelo.materiaOrganica) {
    throw Exception(
      '❌ Error: materia orgánica del suelo no coincide',
    );
  }

  if (sueloRecuperado.evidencias.length !=
      activo.suelo.evidencias.length) {
    throw Exception(
      '❌ Error: evidencias del suelo no coinciden',
    );
  }

  if (sueloRecuperado.observaciones !=
      activo.suelo.observaciones) {
    throw Exception(
      '❌ Error: observaciones del suelo no coinciden',
    );
  }

  if (sueloRecuperado.fechaEvaluacion !=
      activo.suelo.fechaEvaluacion) {
    throw Exception(
      '❌ Error: fecha de evaluación del suelo no coincide',
    );
  }

  print('✅ Suelo recuperado correctamente');
  print('   Estado: ${sueloRecuperado.estado}');
  print('   Textura: ${sueloRecuperado.textura}');
  print('   Drenaje: ${sueloRecuperado.drenaje}');
  print('   pH: ${sueloRecuperado.ph}');
  print(
    '   Materia orgánica: ${sueloRecuperado.materiaOrganica}',
  );
  print(
    '   Evidencias: ${sueloRecuperado.evidencias.length}',
  );
  print(
    '   Observaciones: ${sueloRecuperado.observaciones}',
  );
  print(
    '   Fecha evaluación: ${sueloRecuperado.fechaEvaluacion}',
  );

  // =====================================================
  // 7. PRUEBA CON DATOS DE SUELO COMPLETOS
  // =====================================================

  print('\n🧪 VERIFICANDO SUELO CON DATOS COMPLETOS');

  final sueloCompleto = SueloActivo(
    estado: 'evaluado',
    textura: 'franco',
    drenaje: 'bueno',
    ph: 6.5,
    materiaOrganica: 3.2,
    evidencias: [
      'analisis_suelo_001',
      'informe_tecnico_001',
    ],
    observaciones: 'Suelo de prueba con datos completos',
    fechaEvaluacion: DateTime(2026, 8, 26),
  );

  final activoConSueloCompleto = activo.copyWith(
    suelo: sueloCompleto,
  );

  final mapaCompleto = activoConSueloCompleto.toMap();

  final activoCompletoRecuperado = ActivoAgroV2.fromMap(
    mapaCompleto,
    activoConSueloCompleto.activoId,
  );

  final sueloCompletoRecuperado =
      activoCompletoRecuperado.suelo;

  if (sueloCompletoRecuperado.estado != 'evaluado') {
    throw Exception(
      '❌ Error: estado del suelo completo no se conservó',
    );
  }

  if (sueloCompletoRecuperado.textura != 'franco') {
    throw Exception(
      '❌ Error: textura del suelo completo no se conservó',
    );
  }

  if (sueloCompletoRecuperado.drenaje != 'bueno') {
    throw Exception(
      '❌ Error: drenaje del suelo completo no se conservó',
    );
  }

  if (sueloCompletoRecuperado.ph != 6.5) {
    throw Exception(
      '❌ Error: pH del suelo completo no se conservó',
    );
  }

  if (sueloCompletoRecuperado.materiaOrganica != 3.2) {
    throw Exception(
      '❌ Error: materia orgánica no se conservó',
    );
  }

  if (sueloCompletoRecuperado.evidencias.length != 2) {
    throw Exception(
      '❌ Error: evidencias del suelo completo no se conservaron',
    );
  }

  if (sueloCompletoRecuperado.observaciones !=
      'Suelo de prueba con datos completos') {
    throw Exception(
      '❌ Error: observaciones del suelo completo no se conservaron',
    );
  }

  if (sueloCompletoRecuperado.fechaEvaluacion !=
      DateTime(2026, 8, 26)) {
    throw Exception(
      '❌ Error: fecha de evaluación no se conservó',
    );
  }

  print('✅ Suelo completo serializado y recuperado correctamente');

  // =====================================================
  // RESULTADO FINAL
  // =====================================================

  print('\n==========================================');
  print('🟢 TEST ACTIVO AGRO V2: APROBADO');
  print('🟢 INTEGRACIÓN SUELOACTIVO: APROBADA');
  print('🟢 SERIALIZACIÓN: APROBADA');
  print('🟢 DESERIALIZACIÓN: APROBADA');
   print('==========================================');
  });
}

