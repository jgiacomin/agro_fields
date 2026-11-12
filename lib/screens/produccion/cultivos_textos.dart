/// Textos de agricultura (GAP-AGRO-01).

String nombreCultivo(String? c) {
  switch (c) {
    case 'soja':
      return 'Soja';
    case 'maiz':
      return 'Maíz';
    case 'trigo':
      return 'Trigo';
    case 'girasol':
      return 'Girasol';
    case 'sorgo':
      return 'Sorgo';
    case 'algodon':
      return 'Algodón';
    case 'arroz':
      return 'Arroz';
    case 'pastura':
      return 'Pastura';
    case 'otro':
      return 'Otro';
  }
  if (c == null || c.isEmpty) return 'Cultivo';
  return c[0].toUpperCase() + c.substring(1);
}

/// Campaña sugerida: de julio en adelante, "año/año+1"; antes, "año-1/año".
String campaniaSugerida([DateTime? hoy]) {
  final f = hoy ?? DateTime.now();
  final inicio = f.month >= 7 ? f.year : f.year - 1;
  final fin = (inicio + 1) % 100;
  return '$inicio/${fin.toString().padLeft(2, '0')}';
}

/// 3.4 -> "3,4"; 340 -> "340".
String numeroAgro(double v) {
  final t = v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  return t.replaceAll('.', ',');
}
