/// Clasificación temporal de un dato económico.
///
/// Importante:
/// - La naturaleza temporal NO determina si el dato está verificado.
/// - Un dato proyectado puede estar documentado o verificado como proyección.
/// - Un escenario es una hipótesis/contexto separado de una proyección.
enum TipoTemporalEconomico {
  historico,
  actual,
  proyectado,
  escenario,
}

/// Dato económico individual con clasificación temporal.
///
/// Este modelo prepara EconomíaActivo para distinguir:
/// histórico, actual, proyectado y escenario,
/// sin duplicar Evidencia, Historial ni Auditoría.
class DatoEconomico {
  final String nombreDato;
  final dynamic valor;
  final TipoTemporalEconomico tipoTemporal;
  final String periodo;
  final String? escenarioId;

  const DatoEconomico({
    required this.nombreDato,
    required this.valor,
    required this.tipoTemporal,
    required this.periodo,
    this.escenarioId,
  }) : assert(
          tipoTemporal == TipoTemporalEconomico.escenario
              ? escenarioId != null && escenarioId != ''
              : escenarioId == null,
          'escenarioId debe existir únicamente para datos de tipo escenario.',
        );

  /// Convierte el dato económico a Map para persistencia.
  Map<String, dynamic> toMap() {
    return {
      'nombreDato': nombreDato,
      'valor': valor,
      'tipoTemporal': tipoTemporal.name,
      'periodo': periodo,
      'escenarioId': escenarioId,
    };
  }

  /// Reconstruye un DatoEconomico desde Firestore/Map.
  factory DatoEconomico.fromMap(
    Map<String, dynamic> map,
  ) {
    final tipoTemporalString =
        map['tipoTemporal'] as String? ?? 'actual';

    final tipoTemporal =
        TipoTemporalEconomico.values.firstWhere(
      (tipo) => tipo.name == tipoTemporalString,
      orElse: () => TipoTemporalEconomico.actual,
    );

    return DatoEconomico(
      nombreDato:
          map['nombreDato'] as String? ?? '',
      valor:
          map['valor'],
      tipoTemporal:
          tipoTemporal,
      periodo:
          map['periodo'] as String? ?? '',
      escenarioId:
          map['escenarioId'] as String?,
    );
  }
}