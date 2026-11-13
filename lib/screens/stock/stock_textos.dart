import 'package:flutter/material.dart';

/// Textos del stock (GAP-STOCK-01).

String nombreTipoRecurso(String? t) => switch (t) {
      'semilla' => 'Semilla',
      'fertilizante' => 'Fertilizante',
      'agroquimico' => 'Agroquímico',
      'veterinario' => 'Veterinario',
      'combustible' => 'Combustible',
      'alimento' => 'Alimento',
      'otro' => 'Otro',
      _ => (t == null || t.isEmpty)
          ? 'Sin tipo'
          : t[0].toUpperCase() + t.substring(1),
    };

/// Nombre largo de la unidad, para elegirla.
String nombreUnidadStock(String u) => switch (u) {
      'l' => 'Litros',
      'kg' => 'Kilos',
      'unidades' => 'Unidades',
      'dosis' => 'Dosis',
      'bolsas' => 'Bolsas',
      _ => u,
    };

/// Abreviatura para mostrar al lado del número.
String unidadCorta(String u) => switch (u) {
      'unidades' => 'u.',
      _ => u,
    };

String nombreTipoMovimiento(String t) => switch (t) {
      'entrada' => 'Entrada',
      'salida' => 'Salida',
      'consumo' => 'Consumo',
      'ajuste' => 'Ajuste',
      _ => t,
    };

/// 1500 -> "1.500"; 2.5 -> "2,5".
String numeroStock(double v) {
  final entero = v == v.roundToDouble();
  final partes = (entero ? v.toInt().toString() : v.toStringAsFixed(2))
      .split('.');
  final miles = partes[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  if (partes.length == 1) return miles;
  final dec = partes[1].replaceAll(RegExp(r'0+$'), '');
  return dec.isEmpty ? miles : '$miles,$dec';
}

/// Toma el número aunque venga con la unidad ("200 l", "2,5").
double? leerNumero(String texto) {
  final m = RegExp(r'\d+([.,]\d+)?').firstMatch(texto);
  if (m == null) return null;
  return double.tryParse(m.group(0)!.replaceAll(',', '.'));
}

/// Mensaje claro para los errores del servicio de stock.
String mensajeErrorStock(Object e) {
  final t = e.toString();
  if (t.contains('por debajo de cero')) {
    return 'No alcanza el stock para ese movimiento.';
  }
  if (t.contains('permission-denied')) {
    return 'No tenés permiso para cargar stock en este campo.';
  }
  return 'No se pudo guardar: $t';
}

/// Ícono de cada tipo de producto (diseño V8 campo).
IconData iconoTipoRecurso(String? t) => switch (t) {
      'semilla' => Icons.grass,
      'fertilizante' => Icons.science_outlined,
      'agroquimico' => Icons.water_drop_outlined,
      'veterinario' => Icons.vaccines_outlined,
      'combustible' => Icons.local_gas_station_outlined,
      'alimento' => Icons.grain,
      _ => Icons.inventory_2_outlined,
    };
