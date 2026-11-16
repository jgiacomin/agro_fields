import 'package:flutter/material.dart';

/// Textos de la Historia del territorio (AF-109). Un solo lugar para los
/// nombres que ve el usuario.

String nombreTipoCambio(String tipo) {
  switch (tipo) {
    case 'desmonte':
      return 'Desmonte';
    case 'canal':
      return 'Canal';
    case 'camino':
      return 'Camino';
    case 'drenaje':
      return 'Drenaje';
    case 'cambioUso':
      return 'Cambio de uso';
    case 'erosion':
      return 'Erosión';
    case 'recuperacion':
      return 'Recuperación';
    case 'otro':
      return 'Otro';
  }
  return 'Cambio';
}

IconData iconoTipoCambio(String tipo) {
  switch (tipo) {
    case 'desmonte':
      return Icons.forest;
    case 'canal':
    case 'drenaje':
      return Icons.water;
    case 'camino':
      return Icons.add_road;
    case 'cambioUso':
      return Icons.swap_horiz;
    case 'erosion':
      return Icons.landslide;
    case 'recuperacion':
      return Icons.eco;
  }
  return Icons.landscape;
}

String nombreFuente(String fuente) {
  switch (fuente) {
    case 'propia':
      return 'Lo sé yo';
    case 'documento':
      return 'Un documento';
    case 'imagen':
      return 'Foto o imagen satelital';
    case 'profesional':
      return 'Un profesional';
    case 'vecino':
      return 'Vecinos o dueños anteriores';
    case 'organismo':
      return 'Un organismo oficial';
    case 'otra':
      return 'Otra';
  }
  return fuente;
}

String nombreEstadoDatoTerritorio(String estado) =>
    estado == 'conDocumento' ? 'con documento' : 'declarado';

/// Cuándo pasó, en dd/mm/aaaa: "15/03/2018" o "15/03/2018 al 30/06/2018".
String periodoTexto(DateTime desde, DateTime? hasta) {
  String f(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  if (hasta == null) return f(desde);
  return '${f(desde)} al ${f(hasta)}';
}
