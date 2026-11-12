import 'package:flutter/material.dart';

/// Logo de Agro Fields (engranaje, sol y surcos), tomado de la demo
/// aprobada el 12/11/2026. Archivo: assets/logo_agro_fields.png.
/// Se usa en la pantalla de ingreso y en el encabezado del Inicio.
class LogoAgroFields extends StatelessWidget {
  final double tamano;

  const LogoAgroFields({super.key, this.tamano = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo_agro_fields.png',
      width: tamano,
      height: tamano,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
