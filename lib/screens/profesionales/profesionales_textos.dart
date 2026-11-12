/// Textos de profesionales e intervenciones (AF-093).

String nombreTipoIntervencion(String tipo) {
  switch (tipo) {
    case 'visita':
      return 'Visita al campo';
    case 'recomendacion':
      return 'Recomendación';
    case 'diagnostico':
      return 'Diagnóstico';
    case 'informe':
      return 'Informe';
    case 'otro':
      return 'Otro';
  }
  return 'Intervención';
}

/// Código acortado para mostrar (los últimos 6 caracteres).
String codigoCorto(String codigo) =>
    codigo.length <= 6 ? codigo : '…${codigo.substring(codigo.length - 6)}';
