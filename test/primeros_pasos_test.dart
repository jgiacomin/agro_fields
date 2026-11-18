import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/screens/campos/primeros_pasos.dart';

/// QA Grupo B (18/11/2026): "Primeros pasos" en la ficha del campo.
void main() {
  group('EstadoPrimerosPasos', () {
    test('campo recién creado: 0 de 5', () {
      final e = EstadoPrimerosPasos.calcular(
        tieneMapa: false,
        documentos: 0,
        estadoSuelo: 'sin_evaluar',
        lugares: 0,
        animalesOCultivos: 0,
      );
      expect(e.cantidadHechos, 0);
      expect(e.completos, isFalse);
    });

    test('se tilda cada paso según sus datos', () {
      final e = EstadoPrimerosPasos.calcular(
        tieneMapa: true,
        documentos: 1,
        estadoSuelo: 'declarado',
        lugares: 0,
        animalesOCultivos: 0,
      );
      expect(e.hecho(PasoInicial.mapa), isTrue);
      expect(e.hecho(PasoInicial.documento), isTrue);
      expect(e.hecho(PasoInicial.suelo), isTrue);
      expect(e.hecho(PasoInicial.lugares), isFalse);
      expect(e.hecho(PasoInicial.animalesOCultivos), isFalse);
      expect(e.cantidadHechos, 3);
    });

    test('suelo "sin_evaluar" o vacío no cuenta como cargado', () {
      for (final estado in ['sin_evaluar', '']) {
        final e = EstadoPrimerosPasos.calcular(
          tieneMapa: false,
          documentos: 0,
          estadoSuelo: estado,
          lugares: 0,
          animalesOCultivos: 0,
        );
        expect(e.hecho(PasoInicial.suelo), isFalse, reason: estado);
      }
    });

    test('con los 5 pasos está completo (la tarjeta desaparece)', () {
      final e = EstadoPrimerosPasos.calcular(
        tieneMapa: true,
        documentos: 2,
        estadoSuelo: 'declarado',
        lugares: 6,
        animalesOCultivos: 3,
      );
      expect(e.cantidadHechos, 5);
      expect(e.completos, isTrue);
    });

    test('cada paso tiene su texto y su ayuda', () {
      for (final paso in PasoInicial.values) {
        expect(textoPaso(paso), isNotEmpty);
        expect(ayudaPaso(paso), isNotEmpty);
      }
    });
  });
}
