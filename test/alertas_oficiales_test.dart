import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/screens/emergencias/emergencias_textos.dart';

/// AF-111 (18/11/2026): boton "Ver alertas oficiales" segun el pais.
void main() {
  group('alertaOficialPara', () {
    test('Argentina lleva al SMN, como sea que se haya escrito', () {
      for (final p in ['Argentina', 'argentina ', 'Rep. Argentina', 'AR']) {
        expect(alertaOficialPara(p)?.url, 'https://www.smn.gob.ar/', reason: p);
      }
    });

    test('Paraguay lleva a la DMH', () {
      for (final p in ['Paraguay', 'PARAGUAY', 'py']) {
        expect(alertaOficialPara(p)?.url, 'https://www.meteorologia.gov.py/',
            reason: p);
      }
    });

    test('otro pais o vacio: no se muestra el boton', () {
      expect(alertaOficialPara('Uruguay'), isNull);
      expect(alertaOficialPara(''), isNull);
      expect(alertaOficialPara(null), isNull);
    });
  });
}
