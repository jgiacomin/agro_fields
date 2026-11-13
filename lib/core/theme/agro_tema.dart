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

  /// Diseño V8 campo (13/11/2026, demo de Javier): extremos del degradé
  /// de los botones y fondo suave de los íconos en círculo.
  static const Color terracotaVivo = Color(0xFFEC7C34);
  static const Color terracotaOscuro = Color(0xFFC2541F);
  static const Color terracotaClaro = Color(0xFFFBE4D3);

  /// Dorado del atardecer: línea bajo la barra y detalles de los títulos.
  static const Color dorado = Color(0xFFE3A53A);

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
      // Diseño V8 campo: las pantallas son transparentes y dejan ver el
      // fondo común (crema + paisaje abajo) que pone main.dart.
      scaffoldBackgroundColor: Colors.transparent,
      // Diseño V8 campo (13/11/2026): barra oscura con línea dorada abajo.
      appBarTheme: const AppBarTheme(
        backgroundColor: pizarra,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        shape: Border(bottom: BorderSide(color: dorado, width: 3)),
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
