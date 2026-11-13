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

  /// Control de coherencia: se cosechó más superficie de la que figura
  /// sembrada (por ejemplo, falta cargar la siembra). No se bloquea:
  /// se avisa, igual que en los traslados.
  bool get cosechaSinSiembraSuficiente => haCosechadas > haSembradas;
}

/// Corregir no es borrar: un evento corregido queda en la historia, pero
/// para los cálculos vale solo la última corrección (corrigeEventoId).
/// Devuelve los ids de los eventos que fueron corregidos por otro.
Set<String> idsCorregidos(Iterable<EventoProductivo> eventos) {
  return {
    for (final e in eventos)
      if (e.corrigeEventoId != null && e.corrigeEventoId!.isNotEmpty)
        e.corrigeEventoId!,
  };
}

/// Los eventos que valen hoy (los que nadie corrigió).
List<EventoProductivo> eventosVigentes(Iterable<EventoProductivo> eventos) {
  final corregidos = idsCorregidos(eventos);
  return eventos.where((e) => !corregidos.contains(e.eventoId)).toList();
}

ResumenCultivo calcularResumenCultivo(Iterable<EventoProductivo> todos) {
  final eventos = eventosVigentes(todos);
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

/// GAP-MON-01 (13/11/2026): alertas del monitoreo.
/// Por cada cosa que se mira (plaga, maleza...), vale el último monitoreo
/// (sin contar los corregidos). Si ese último dice "alto", hay alerta.
/// Así, un monitoreo nuevo con nivel más bajo apaga la alerta, sin borrar
/// la historia. Devuelve los monitoreos en alerta, el más nuevo primero.
List<EventoProductivo> alertasMonitoreo(Iterable<EventoProductivo> todos) {
  final ultimos = <String, EventoProductivo>{};
  for (final e in eventosVigentes(todos)) {
    if (e.tipo != TipoEventoProductivo.monitoreo) continue;
    final clave = e.objetivoMonitoreo ?? 'otro';
    final previo = ultimos[clave];
    if (previo == null || e.fechaHecho.isAfter(previo.fechaHecho)) {
      ultimos[clave] = e;
    }
  }
  return ultimos.values.where((e) => e.nivel == 'alto').toList()
    ..sort((a, b) => b.fechaHecho.compareTo(a.fechaHecho));
}
