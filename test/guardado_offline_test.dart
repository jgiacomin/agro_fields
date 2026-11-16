import 'dart:async';

import 'package:agro_fields/core/utils/guardado_offline.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// GAP-OFF-01: guardar sin quedarse esperando (sin Firebase de verdad).
void main() {
  const corto = Duration(milliseconds: 50);

  test('OFF-T1. Si el servidor contesta a tiempo: enviado', () async {
    final r = await guardarSinEsperar(Future<void>.value(), espera: corto);
    expect(r, ResultadoGuardado.enviado);
  });

  test('OFF-T2. Si el servidor no contesta: queda en el teléfono (no se cuelga)', () async {
    final nuncaTermina = Completer<void>().future;
    final r = await guardarSinEsperar(nuncaTermina, espera: corto);
    expect(r, ResultadoGuardado.enTelefono);
  });

  test('OFF-T3. Si el servidor rechaza (ej.: una regla), el error llega a la pantalla', () async {
    expect(
      guardarSinEsperar(Future<void>.error(StateError('rechazado')), espera: corto),
      throwsA(isA<StateError>()),
    );
  });

  test('OFF-T4. Un error que llega tarde no rompe la app', () async {
    final tarde = Completer<void>();
    final r = await guardarSinEsperar(tarde.future, espera: corto);
    expect(r, ResultadoGuardado.enTelefono);
    tarde.completeError(StateError('tarde'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
  });

  test('OFF-T5. Reconoce los errores por falta de señal', () {
    expect(esErrorSinSenal(const SinSenalException('x')), isTrue);
    expect(esErrorSinSenal(TimeoutException('x')), isTrue);
    expect(
      esErrorSinSenal(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable')),
      isTrue,
    );
    expect(
      esErrorSinSenal(FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied')),
      isFalse,
    );
    expect(esErrorSinSenal(StateError('otro')), isFalse);
  });

  test('OFF-T6. Textos para el usuario', () {
    expect(textoGuardado(ResultadoGuardado.enviado), 'Guardado.');
    expect(textoGuardado(ResultadoGuardado.enTelefono), contains('cuando haya señal'));
  });
}
