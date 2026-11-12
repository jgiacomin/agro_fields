import '../../models/activos/movimiento_model.dart';

/// Textos de traslados (AF-089).

String nombreActividad(String a) {
  switch (a) {
    case 'ganaderia':
      return 'Hacienda';
    case 'agricultura':
      return 'Granos / agrícola';
    case 'apicultura':
      return 'Colmenas / miel';
    case 'piscicultura':
      return 'Peces';
    case 'otra':
      return 'Otro';
  }
  return a;
}

String nombreEstadoMovimiento(EstadoMovimiento e) {
  switch (e) {
    case EstadoMovimiento.programado:
      return 'Programado';
    case EstadoMovimiento.enCamino:
      return 'En camino';
    case EstadoMovimiento.entregado:
      return 'Entregado';
    case EstadoMovimiento.cancelado:
      return 'Cancelado';
  }
}

/// Número sin ".0" si es entero (50 en vez de 50.0).
String numero(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();
