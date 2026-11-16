import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// GAP-OFF-01 (16/11/2026): funcionamiento sin señal.
///
/// Firebase guarda cada registro primero en el teléfono y lo manda al
/// servidor cuando hay señal. El problema era que las pantallas se quedaban
/// esperando la respuesta del servidor. Acá está la herramienta común para
/// guardar sin quedarse esperando.

/// Cómo terminó un guardado.
enum ResultadoGuardado {
  /// El servidor ya lo recibió.
  enviado,

  /// Quedó guardado en el teléfono; se manda solo cuando haya señal.
  enTelefono,
}

/// Lo que necesita señal sí o sí (descontar stock, crear un campo).
class SinSenalException implements Exception {
  final String mensaje;
  const SinSenalException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Cuánto se espera al servidor antes de dar el registro por guardado en el
/// teléfono.
const Duration esperaServidor = Duration(seconds: 2);

/// Espera la escritura como mucho [espera]. Si el servidor no contesta a
/// tiempo, la escritura sigue en marcha (Firebase ya la guardó en el
/// teléfono y la manda sola) y se devuelve [ResultadoGuardado.enTelefono].
/// Si el servidor contesta con un error (por ejemplo, una regla), el error
/// se pasa a la pantalla como siempre.
Future<ResultadoGuardado> guardarSinEsperar(
  Future<void> escritura, {
  Duration espera = esperaServidor,
}) async {
  try {
    await escritura.timeout(espera);
    return ResultadoGuardado.enviado;
  } on TimeoutException {
    // Que un error tardío no rompa la app: la escritura sigue sola.
    unawaited(escritura.catchError((Object _) {}));
    return ResultadoGuardado.enTelefono;
  }
}

/// true si el error es por falta de conexión.
bool esErrorSinSenal(Object error) {
  if (error is SinSenalException || error is TimeoutException) return true;
  if (error is FirebaseException) {
    return error.code == 'unavailable' || error.code == 'deadline-exceeded';
  }
  return false;
}

/// Comprueba que el servidor responde, leyendo [ref] directo del servidor.
/// Se usa ANTES de lo que necesita señal sí o sí, para no empezarlo sin
/// conexión. Si no hay señal, tira [SinSenalException].
Future<void> exigirSenal(
  DocumentReference<Map<String, dynamic>> ref, {
  String mensaje = 'No hay señal.',
  Duration espera = const Duration(seconds: 5),
}) async {
  try {
    await ref.get(const GetOptions(source: Source.server)).timeout(espera);
  } catch (e) {
    if (esErrorSinSenal(e)) throw SinSenalException(mensaje);
    rethrow;
  }
}

/// Texto que ve el usuario después de guardar.
String textoGuardado(ResultadoGuardado r) => r == ResultadoGuardado.enviado
    ? 'Guardado.'
    : 'Guardado en el teléfono. Se envía cuando haya señal.';

/// Muestra el aviso de guardado. Se llama con el ScaffoldMessenger tomado
/// ANTES de cerrar la pantalla, así el aviso se ve en la pantalla anterior.
void avisarGuardado(ScaffoldMessengerState mensajero, ResultadoGuardado r) {
  mensajero.showSnackBar(SnackBar(
    content: Text(textoGuardado(r)),
    duration: Duration(seconds: r == ResultadoGuardado.enviado ? 2 : 4),
  ));
}

/// Opción A (sin señal no se descuenta el stock): pregunta si se guarda el
/// registro igual, sin descontar. Devuelve true si el usuario acepta.
Future<bool> preguntarGuardarSinDescontar(BuildContext context) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: const Text('No hay señal'),
      content: const Text(
        'Para descontar el producto del stock necesitás señal.\n\n'
        '¿Querés guardar el registro igual, sin descontar? Después podés '
        'descontarlo a mano desde Stock e insumos.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(contexto).pop(true),
          child: const Text('Guardar sin descontar'),
        ),
      ],
    ),
  );
  return respuesta == true;
}
