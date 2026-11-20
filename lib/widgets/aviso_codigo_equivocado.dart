import 'package:flutter/material.dart';

import '../services/encargado_service.dart' show CodigoNoValido;

/// QA 20/11/2026: cartel que queda en pantalla cuando el código pegado
/// no es de ningún usuario (encargados y profesionales). Se cierra con
/// "Entendido", para que no pase desapercibido.
Future<void> mostrarCodigoEquivocado(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.error_outline, size: 40),
      title: const Text('Código equivocado'),
      content: const Text(CodigoNoValido.mensaje, style: TextStyle(height: 1.4)),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
