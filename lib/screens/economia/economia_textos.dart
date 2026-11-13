import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';

/// Textos y formatos de Economía (GAP-ECO-01).

String nombreCategoriaGasto(String c) => switch (c) {
      'insumos' => 'Insumos',
      'combustible' => 'Combustible',
      'manoDeObra' => 'Mano de obra',
      'contratistas' => 'Contratistas',
      'sanidad' => 'Sanidad',
      'alquiler' => 'Alquiler',
      'fletes' => 'Fletes',
      'mantenimiento' => 'Mantenimiento',
      'impuestosServicios' => 'Impuestos y servicios',
      'otros' => 'Otros',
      _ => c,
    };

IconData iconoCategoriaGasto(String c) => switch (c) {
      'insumos' => Icons.inventory_2_outlined,
      'combustible' => Icons.local_gas_station_outlined,
      'manoDeObra' => Icons.groups_outlined,
      'contratistas' => Icons.agriculture,
      'sanidad' => Icons.vaccines_outlined,
      'alquiler' => Icons.landscape_outlined,
      'fletes' => Icons.local_shipping_outlined,
      'mantenimiento' => Icons.build_outlined,
      'impuestosServicios' => Icons.receipt_long_outlined,
      _ => Icons.more_horiz,
    };

/// Un color por categoría para las barras (paleta de la app).
Color colorCategoriaGasto(String c) => switch (c) {
      'insumos' => AgroTema.verde,
      'combustible' => AgroTema.terracota,
      'manoDeObra' => AgroTema.azul,
      'contratistas' => const Color(0xFF8A6D3B),
      'sanidad' => const Color(0xFF7B5EA7),
      'alquiler' => const Color(0xFF3E8E7E),
      'fletes' => AgroTema.dorado,
      'mantenimiento' => const Color(0xFF6B7680),
      'impuestosServicios' => const Color(0xFFB0563A),
      _ => const Color(0xFF9AA0A6),
    };

String nombreActividadGasto(String a) => switch (a) {
      'agricultura' => 'Agricultura',
      'ganaderia' => 'Ganadería',
      'general' => 'General del campo',
      _ => a,
    };

String nombreMoneda(String m) => switch (m) {
      'ARS' => 'Pesos',
      'USD' => 'Dólares',
      'PYG' => 'Guaraníes',
      _ => m,
    };

String simboloMoneda(String m) => switch (m) {
      'ARS' => r'$',
      'USD' => r'US$',
      'PYG' => '₲',
      _ => m,
    };

/// 150000 -> "$ 150.000"; 1200.5 USD -> "US$ 1.200,50"; guaraníes sin
/// decimales.
String formatoMonto(double v, String moneda) {
  final sinDecimales = moneda == 'PYG' || v == v.roundToDouble();
  final texto = sinDecimales ? v.round().toString() : v.toStringAsFixed(2);
  final partes = texto.split('.');
  final miles = partes[0]
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  final numero = partes.length == 1 ? miles : '$miles,${partes[1]}';
  return '${simboloMoneda(moneda)} $numero';
}

/// Lee un monto como lo escribe la gente: "150.000", "150000",
/// "1.200,50", "$ 2500". Devuelve null si no hay número.
double? leerMonto(String texto) {
  var t = texto.replaceAll(RegExp(r'[^0-9.,]'), '');
  if (t.isEmpty) return null;
  if (t.contains(',')) {
    t = t.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(t)) {
    t = t.replaceAll('.', '');
  }
  return double.tryParse(t);
}

const _meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio',
  'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

/// "2026-11" -> "Noviembre 2026".
String nombreMes(String mes) {
  final p = mes.split('-');
  return '${_meses[int.parse(p[1]) - 1]} ${p[0]}';
}

String mesDe(DateTime f) => '${f.year}-${f.month.toString().padLeft(2, '0')}';
