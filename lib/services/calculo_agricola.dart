import '../models/activos/evento_productivo_model.dart';

/// GAP-AGRO-01 (12/11/2026): resumen de un cultivo de la campaña.
/// Igual que las existencias de hacienda, NADA se escribe a mano: todo se
/// calcula sumando los eventos de siembra y cosecha del grupo.
class ResumenCultivo {
  final double haSembradas;
  final double haCosechadas;

  /// Toneladas cosechadas (kg y qq pasados a tn).
  final double toneladas;

  /// tn/ha sobre lo cosechado. null si todavía no hay cosecha.
  final double? rendimiento;

  final DateTime? ultimaSiembra;
  final DateTime? ultimaCosecha;

  const ResumenCultivo({
    required this.haSembradas,
    required this.haCosechadas,
    required this.toneladas,
    required this.rendimiento,
    this.ultimaSiembra,
    this.ultimaCosecha,
  });

  /// Sembrado y sin cosechar todavía.
  bool get enCurso => haSembradas > 0 && haCosechadas == 0;
}

ResumenCultivo calcularResumenCultivo(Iterable<EventoProductivo> eventos) {
  var sembradas = 0.0;
  var cosechadas = 0.0;
  var toneladas = 0.0;
  DateTime? ultimaSiembra;
  DateTime? ultimaCosecha;

  for (final e in eventos) {
    if (e.tipo == TipoEventoProductivo.siembra && e.superficieHa != null) {
      sembradas += e.superficieHa!;
      if (ultimaSiembra == null || e.fechaHecho.isAfter(ultimaSiembra)) {
        ultimaSiembra = e.fechaHecho;
      }
    }
    if (e.tipo == TipoEventoProductivo.cosecha) {
      if (e.superficieHa != null) cosechadas += e.superficieHa!;
      final tn = e.toneladas;
      if (tn != null) toneladas += tn;
      if (ultimaCosecha == null || e.fechaHecho.isAfter(ultimaCosecha)) {
        ultimaCosecha = e.fechaHecho;
      }
    }
  }

  return ResumenCultivo(
    haSembradas: sembradas,
    haCosechadas: cosechadas,
    toneladas: toneladas,
    rendimiento: cosechadas > 0 ? toneladas / cosechadas : null,
    ultimaSiembra: ultimaSiembra,
    ultimaCosecha: ultimaCosecha,
  );
}
