import 'package:flutter/material.dart';

/// Colores y estilo de toda la app (Agro Fields V8).
///
/// Tomados de la referencia visual aprobada por Javier el 10/11/2026
/// (docs/diseno/referencia_visual_v8.png): atardecer en el campo,
/// "tierra + tecnologia + confianza".
///
/// Si hay que cambiar un color, se cambia SOLO aca.
class AgroTema {
  /// Boton principal, accion destacada, icono activo (el "V8" del logo).
  static const Color terracota = Color(0xFFD96A2B);

  /// Titulos y texto (el "AGRO FIELDS" del logo).
  static const Color pizarra = Color(0xFF2F3B46);

  /// Texto secundario.
  static const Color pizarraSuave = Color(0xFF6B7680);

  /// Fondo de las pantallas.
  static const Color crema = Color(0xFFFAF5EC);

  /// Bordes de tarjetas y campos.
  static const Color borde = Color(0xFFEDE4D3);

  /// Elegido, completo, en regla.
  static const Color verde = Color(0xFF2E6B4F);
  static const Color verdeClaro = Color(0xFFE4EFE8);

  /// Territorio, mapa, clima.
  static const Color azul = Color(0xFF4A78A8);

  /// Vencido, rechazado, error.
  static const Color rojo = Color(0xFFC0392B);
  static const Color rojoFondo = Color(0xFFFDF0EE);
  static const Color rojoBorde = Color(0xFFF2C4BE);

  static final RoundedRectangleBorder _forma =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  static ThemeData get tema {
    final colores = ColorScheme.fromSeed(
      seedColor: terracota,
      brightness: Brightness.light,
    ).copyWith(
      primary: terracota,
      onPrimary: Colors.white,
      secondary: verde,
      onSecondary: Colors.white,
      tertiary: azul,
      onTertiary: Colors.white,
      error: rojo,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: pizarra,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colores,
      scaffoldBackgroundColor: crema,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: pizarra,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: terracota,
          foregroundColor: Colors.white,
          shape: _forma,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pizarra,
          side: const BorderSide(color: borde, width: 1.2),
          shape: _forma,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: terracota),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: terracota,
        foregroundColor: Colors.white,
      ),
      dividerColor: borde,
    );
  }
}
