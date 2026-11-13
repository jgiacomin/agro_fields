import '../models/activos/evento_productivo_model.dart';
import 'calculo_existencias.dart';

/// GAP-PESO-01 + AF-102 (13/11/2026): indicadores del rodeo.
///
/// Igual que las existencias, NO se escriben a mano: salen de los eventos
/// que ya se cargan (pesajes, entradas y salidas por muerte). Así siempre
/// se puede explicar de dónde sale cada número.
///
/// No usa Firebase: recibe la lista de eventos y devuelve el resultado.

/// Ganancia diaria de peso entre los dos últimos pesajes comparables.
class GananciaDiaria {
  final double pesoInicialKg;
  final double pesoFinalKg;
  final DateTime desde;
  final DateTime hasta;
  final int dias;

  /// Categoría de los pesajes comparados (null = rodeo entero).
  final String? categoria;

  const GananciaDiaria({
    required this.pesoInicialKg,
    required this.pesoFinalKg,
    required this.desde,
    required this.hasta,
    required this.dias,
    this.categoria,
  });

  /// Puede dar negativa (los animales perdieron peso): no se esconde.
  double get kgPorDia => (pesoFinalKg - pesoInicialKg) / dias;
}

/// Mortandad de un período: muertes ÷ (animales al empezar + entradas).
class Mortandad {
  final int muertes;
  final int animalesBase;
  final DateTime desde;
  final DateTime hasta;

  const Mortandad({
    required this.muertes,
    required this.animalesBase,
    required this.desde,
    required this.hasta,
  });

  double get porcentaje => muertes * 100 / animalesBase;

  /// Más muertes que animales: los datos no cierran (falta cargar una
  /// entrada o hay un error). No se muestra un % mayor a 100: se avisa.
  bool get paraRevisar => muertes > animalesBase;
}

/// Saca los eventos que otro evento corrigió (el original no se borra,
/// pero no cuenta). Los que tienen errores tampoco cuentan.
List<EventoProductivo> _vigentes(List<EventoProductivo> eventos) {
  final corregidos = {
    for (final e in eventos)
      if (e.corrigeEventoId != null) e.corrigeEventoId!,
  };
  return eventos
      .where((e) => !corregidos.contains(e.eventoId) && e.validar().isEmpty)
      .toList();
}

DateTime _dia(DateTime f) => DateTime(f.year, f.month, f.day);

int _orden(EventoProductivo a, EventoProductivo b) {
  final porFecha = a.fechaHecho.compareTo(b.fechaHecho);
  if (porFecha != 0) return porFecha;
  return a.fechaCarga.compareTo(b.fechaCarga);
}

/// Compara el último pesaje con el anterior de la MISMA categoría (o los
/// dos sin categoría): mezclar terneros con novillos daría un número falso.
/// Devuelve null si no hay dos pesajes comparables o si son del mismo día.
GananciaDiaria? calcularGananciaDiaria(List<EventoProductivo> eventos) {
  final pesajes = _vigentes(eventos)
      .where((e) => e.tipo == TipoEventoProductivo.pesaje)
      .toList()
    ..sort(_orden);
  if (pesajes.length < 2) return null;

  final ultimo = pesajes.last;
  EventoProductivo? anterior;
  for (var i = pesajes.length - 2; i >= 0; i--) {
    if (pesajes[i].categoria == ultimo.categoria) {
      anterior = pesajes[i];
      break;
    }
  }
  if (anterior == null) return null;

  final dias = _dia(ultimo.fechaHecho).difference(_dia(anterior.fechaHecho)).inDays;
  if (dias < 1) return null;

  return GananciaDiaria(
    pesoInicialKg: anterior.pesoPromedioKg!,
    pesoFinalKg: ultimo.pesoPromedioKg!,
    desde: anterior.fechaHecho,
    hasta: ultimo.fechaHecho,
    dias: dias,
    categoria: ultimo.categoria,
  );
}

/// Mortandad entre [desde] y [hasta] (incluidos).
/// Base = animales que había al empezar + los que entraron en el período.
/// Devuelve null si no hubo animales en el período (no se puede dividir).
Mortandad? calcularMortandad(
  List<EventoProductivo> eventos, {
  required DateTime desde,
  required DateTime hasta,
}) {
  final vigentes = _vigentes(eventos);
  final inicio = _dia(desde);
  final fin = _dia(hasta).add(const Duration(days: 1));

  bool enPeriodo(EventoProductivo e) =>
      !e.fechaHecho.isBefore(inicio) && e.fechaHecho.isBefore(fin);

  final alEmpezar = calcularExistencias(
    vigentes.where((e) => e.fechaHecho.isBefore(inicio)).toList(),
  ).totalCabezas;

  var entradas = 0;
  var muertes = 0;
  for (final e in vigentes.where(enPeriodo)) {
    if (e.tipo == TipoEventoProductivo.alta) entradas += e.cantidad!;
    if (e.tipo == TipoEventoProductivo.baja && e.motivo == MotivoBaja.muerte) {
      muertes += e.cantidad!;
    }
  }

  final base = alEmpezar + entradas;
  if (base <= 0) return null;

  return Mortandad(
    muertes: muertes,
    animalesBase: base,
    desde: desde,
    hasta: hasta,
  );
}
