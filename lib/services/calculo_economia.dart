import '../models/activos/gasto_model.dart';

/// GAP-ECO-01 (13/11/2026): resumen de gastos. Igual que el stock y las
/// existencias, nada se escribe a mano: todo se calcula con los gastos
/// cargados. Los totales van SEPARADOS por moneda (no se convierte).

/// Los ids de los gastos que fueron corregidos por otro.
Set<String> gastosCorregidos(Iterable<Gasto> gastos) => {
      for (final g in gastos)
        if (g.esCorreccion) g.corrigeGastoId!,
    };

/// Los gastos que valen hoy: sin los corregidos y sin las anulaciones.
List<Gasto> gastosVigentes(Iterable<Gasto> gastos) {
  final corregidos = gastosCorregidos(gastos);
  return gastos
      .where((g) => !corregidos.contains(g.gastoId) && !g.anula)
      .toList();
}

class ResumenGastos {
  /// moneda -> total
  final Map<String, double> totalPorMoneda;

  /// moneda -> categoría -> total
  final Map<String, Map<String, double>> porCategoria;

  /// moneda -> actividad -> total
  final Map<String, Map<String, double>> porActividad;

  /// Los gastos del período, el más nuevo primero.
  final List<Gasto> gastos;

  const ResumenGastos({
    required this.totalPorMoneda,
    required this.porCategoria,
    required this.porActividad,
    required this.gastos,
  });

  bool get vacio => gastos.isEmpty;
}

/// Resumen de un mes ("2026-11"), con los gastos vigentes.
ResumenGastos resumenDelMes(Iterable<Gasto> todos, String mes) {
  final delMes = gastosVigentes(todos).where((g) => g.mes == mes).toList()
    ..sort((a, b) => b.fecha.compareTo(a.fecha));
  final total = <String, double>{};
  final cat = <String, Map<String, double>>{};
  final act = <String, Map<String, double>>{};
  for (final g in delMes) {
    total[g.moneda] = (total[g.moneda] ?? 0) + g.monto;
    final c = cat.putIfAbsent(g.moneda, () => {});
    c[g.categoria] = (c[g.categoria] ?? 0) + g.monto;
    final a = act.putIfAbsent(g.moneda, () => {});
    a[g.actividad] = (a[g.actividad] ?? 0) + g.monto;
  }
  return ResumenGastos(
    totalPorMoneda: total,
    porCategoria: cat,
    porActividad: act,
    gastos: delMes,
  );
}

/// "2026-11" -> "2026-10" (delta -1) o "2026-12" (delta +1).
String moverMes(String mes, int delta) {
  final partes = mes.split('-');
  final fecha =
      DateTime(int.parse(partes[0]), int.parse(partes[1]) + delta, 1);
  return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
}
