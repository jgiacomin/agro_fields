import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/models/activos/suelo_activo_model.dart';

void main() {
  group('SueloActivo', () {
    test('serializa y recupera clasificación y propiedades técnicas', () {
      final fecha = DateTime(2026, 9, 8, 10, 15);

      final suelo = SueloActivo(
        estado: 'evaluado',
        textura: 'franco',
        drenaje: 'bueno',
        ph: 6.5,
        materiaOrganica: 3.2,
        sistemaClasificacion: 'Clasificación de Capacidad de Uso',
        clase: 'II',
        subclase: 'IIe',
        unidadTipo: 'Unidad cartográfica U-01',
        descripcionClasificacion: 'Suelo agrícola con limitaciones moderadas.',
        profundidad: '80 cm',
        salinidad: 'baja',
        fertilidad: 'media',
        nutrientes: 'N, P, K',
        pedregosidad: 'baja',
        retencionAgua: 'media',
        erosion: 'moderada',
        limitaciones: 'Riesgo de erosión hídrica.',
        evidencias: ['evidencia-suelo-001'],
        observaciones: 'Evaluación técnica del suelo.',
        fechaEvaluacion: fecha,
      );

      final map = suelo.toMap();

      expect(map['sistemaClasificacion'], 'Clasificación de Capacidad de Uso');
      expect(map['clase'], 'II');
      expect(map['subclase'], 'IIe');
      expect(map['unidadTipo'], 'Unidad cartográfica U-01');
      expect(
        map['descripcionClasificacion'],
        'Suelo agrícola con limitaciones moderadas.',
      );
      expect(map['profundidad'], '80 cm');
      expect(map['salinidad'], 'baja');
      expect(map['fertilidad'], 'media');
      expect(map['nutrientes'], 'N, P, K');
      expect(map['pedregosidad'], 'baja');
      expect(map['retencionAgua'], 'media');
      expect(map['erosion'], 'moderada');
      expect(map['limitaciones'], 'Riesgo de erosión hídrica.');

      final sueloRecuperado = SueloActivo.fromMap(map);

      expect(
        sueloRecuperado.sistemaClasificacion,
        'Clasificación de Capacidad de Uso',
      );
      expect(sueloRecuperado.clase, 'II');
      expect(sueloRecuperado.subclase, 'IIe');
      expect(sueloRecuperado.unidadTipo, 'Unidad cartográfica U-01');
      expect(
        sueloRecuperado.descripcionClasificacion,
        'Suelo agrícola con limitaciones moderadas.',
      );
      expect(sueloRecuperado.profundidad, '80 cm');
      expect(sueloRecuperado.salinidad, 'baja');
      expect(sueloRecuperado.fertilidad, 'media');
      expect(sueloRecuperado.nutrientes, 'N, P, K');
      expect(sueloRecuperado.pedregosidad, 'baja');
      expect(sueloRecuperado.retencionAgua, 'media');
      expect(sueloRecuperado.erosion, 'moderada');
      expect(sueloRecuperado.limitaciones, 'Riesgo de erosión hídrica.');

      expect(sueloRecuperado.evidencias, ['evidencia-suelo-001']);
      expect(sueloRecuperado.fechaEvaluacion, fecha);
    });

    test('copyWith conserva los datos técnicos del suelo', () {
      final suelo = SueloActivo(
        estado: 'evaluado',
        sistemaClasificacion: 'WRB',
        clase: 'Clase técnica',
        subclase: 'Subclase técnica',
        unidadTipo: 'Unidad 01',
        descripcionClasificacion: 'Descripción',
        profundidad: '100 cm',
        salinidad: 'baja',
        fertilidad: 'alta',
        nutrientes: 'N, P, K',
        pedregosidad: 'media',
        retencionAgua: 'alta',
        erosion: 'baja',
        limitaciones: 'Sin limitaciones relevantes',
        evidencias: [],
      );

      final actualizado = suelo.copyWith(ph: 6.8, estado: 'verificado');

      expect(actualizado.estado, 'verificado');
      expect(actualizado.ph, 6.8);

      expect(actualizado.sistemaClasificacion, 'WRB');
      expect(actualizado.clase, 'Clase técnica');
      expect(actualizado.subclase, 'Subclase técnica');
      expect(actualizado.unidadTipo, 'Unidad 01');
      expect(actualizado.descripcionClasificacion, 'Descripción');
      expect(actualizado.profundidad, '100 cm');
      expect(actualizado.salinidad, 'baja');
      expect(actualizado.fertilidad, 'alta');
      expect(actualizado.nutrientes, 'N, P, K');
      expect(actualizado.pedregosidad, 'media');
      expect(actualizado.retencionAgua, 'alta');
      expect(actualizado.erosion, 'baja');
      expect(actualizado.limitaciones, 'Sin limitaciones relevantes');
    });

    test('mantiene compatibilidad con suelo inicial', () {
      final suelo = SueloActivo.inicial();

      expect(suelo.estado, 'sin_evaluar');
      expect(suelo.evidencias, isEmpty);
      expect(suelo.sistemaClasificacion, isNull);
      expect(suelo.clase, isNull);
      expect(suelo.subclase, isNull);
      expect(suelo.unidadTipo, isNull);
      expect(suelo.profundidad, isNull);
      expect(suelo.limitaciones, isNull);
    });

    test('serializa fecha de evaluación como Timestamp', () {
      final fecha = DateTime(2026, 9, 8, 10, 15);

      final suelo = SueloActivo(
        estado: 'evaluado',
        evidencias: [],
        fechaEvaluacion: fecha,
      );

      final map = suelo.toMap();

      expect(map['fechaEvaluacion'], isA<Timestamp>());

      final recuperado = SueloActivo.fromMap(map);

      expect(recuperado.fechaEvaluacion, fecha);
    });
  });
}
