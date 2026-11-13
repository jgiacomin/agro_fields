import 'package:agro_fields/models/activos/suelo_activo_model.dart';
import 'package:agro_fields/screens/campos/suelo_textos.dart';
import 'package:flutter_test/flutter_test.dart';

/// GAP-SUELO-01 (13/11/2026): cuentas de la pantalla de suelo.
void main() {
  group('leerDecimal', () {
    test('acepta coma y punto', () {
      expect(leerDecimal('6,5'), 6.5);
      expect(leerDecimal('6.5'), 6.5);
      expect(leerDecimal(' 3 '), 3);
    });

    test('vacío es sin información', () {
      expect(leerDecimal(''), isNull);
      expect(leerDecimal('   '), isNull);
    });

    test('texto que no es número', () {
      expect(leerDecimal('mucho')!.isNaN, isTrue);
    });
  });

  group('validarSuelo', () {
    test('valores normales y vacíos están bien', () {
      expect(validarSuelo(ph: 6.5, materiaOrganica: 3.2), isEmpty);
      expect(validarSuelo(), isEmpty);
    });

    test('pH fuera de 0 a 14', () {
      expect(validarSuelo(ph: 15), isNotEmpty);
      expect(validarSuelo(ph: -1), isNotEmpty);
      expect(validarSuelo(ph: double.nan), isNotEmpty);
    });

    test('materia orgánica fuera de 0 a 100', () {
      expect(validarSuelo(materiaOrganica: 120), isNotEmpty);
    });
  });

  group('armarSuelo', () {
    final ahora = DateTime(2026, 11, 13);
    final anterior = SueloActivo(
      estado: 'sin_evaluar',
      evidencias: const ['ev1'],
      subclase: 'e',
      fertilidad: 'media',
      textura: 'arenoso',
    );

    test('lo cargado queda declarado y con fecha', () {
      final s = armarSuelo(
        anterior: anterior,
        ahora: ahora,
        textura: 'franco',
        ph: 6.5,
        clase: 'II',
      );
      expect(s.estado, 'declarado');
      expect(s.textura, 'franco');
      expect(s.ph, 6.5);
      expect(s.clase, 'II');
      expect(s.sistemaClasificacion, sistemaCapacidadUso);
      expect(s.fechaEvaluacion, ahora);
    });

    test('conserva lo que la pantalla no muestra', () {
      final s = armarSuelo(anterior: anterior, ahora: ahora, drenaje: 'bueno');
      expect(s.evidencias, ['ev1']);
      expect(s.subclase, 'e');
      expect(s.fertilidad, 'media');
    });

    test('lo que se borra queda vacío', () {
      final s = armarSuelo(anterior: anterior, ahora: ahora, drenaje: 'bueno');
      expect(s.textura, isNull);
    });

    test('sin cargar nada no cambia el estado ni la fecha', () {
      final s = armarSuelo(
        anterior: anterior,
        ahora: ahora,
        limitaciones: '  ',
      );
      expect(s.estado, 'sin_evaluar');
      expect(s.fechaEvaluacion, isNull);
      expect(s.limitaciones, isNull);
    });
  });

  test('textoOpcion muestra claro', () {
    expect(textoOpcion('franco_arenoso'), 'Franco arenoso');
    expect(textoOpcion('malo_anegable'), 'Malo anegable');
  });
}
