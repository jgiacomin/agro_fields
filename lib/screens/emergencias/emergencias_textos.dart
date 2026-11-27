/// Textos de las emergencias (AF-092). Un solo lugar para los nombres.

/// Qué pasó: se elige tocando. Cada uno sabe si es climático o sanitario.
const List<String> tiposEmergencia = [
  'inundacion',
  'sequia',
  'incendio',
  'granizo',
  'helada',
  // Caso 25.28 (27/11/2026): olas de calor de hasta 45 °C.
  'calor_extremo',
  'tormenta',
  'enfermedad_plaga',
  'otro',
];

String nombreTipoEmergencia(String? tipo) {
  switch (tipo) {
    case 'inundacion':
      return 'Inundación';
    case 'sequia':
      return 'Sequía';
    case 'incendio':
      return 'Incendio';
    case 'granizo':
      return 'Granizo';
    case 'helada':
      return 'Helada';
    case 'calor_extremo':
      return 'Calor extremo';
    case 'tormenta':
      return 'Tormenta o viento';
    case 'enfermedad_plaga':
      return 'Enfermedad o plaga';
    case 'otro':
      return 'Otro';
  }
  return 'Emergencia';
}

/// Grupo del evento: climático, sanitario u otro.
String grupoEmergencia(String tipo) {
  if (tipo == 'enfermedad_plaga') return 'sanitario';
  if (tipo == 'otro') return 'otro';
  return 'climatico';
}

const List<String> gravedades = ['leve', 'medio', 'grave'];

String nombreGravedad(String nivel) {
  switch (nivel) {
    case 'leve':
      return 'Leve';
    case 'medio':
      return 'Media';
    case 'grave':
      return 'Grave';
  }
  return nivel;
}

String nombreRecurso(String recurso) {
  switch (recurso) {
    case 'hacienda':
      return 'Hacienda';
    case 'granos':
      return 'Granos';
    case 'maquinaria':
      return 'Maquinaria';
    case 'otro':
      return 'Otro';
  }
  return recurso;
}

/// AF-111 (18/11/2026): página oficial de alertas según el país del campo.
/// Agro Fields no genera alertas: solo lleva a la del organismo oficial.
/// Devuelve null si el país no tiene página cargada todavía.
class AlertaOficial {
  final String organismo;
  final String url;

  const AlertaOficial(this.organismo, this.url);
}

AlertaOficial? alertaOficialPara(String? pais) {
  // El país se escribe a mano al crear el campo: se acepta "Argentina",
  // "argentina", "Rep. Argentina", "AR", etc.
  final p = (pais ?? '').trim().toLowerCase();
  if (p.contains('argentin') || p == 'ar') {
    return const AlertaOficial(
        'Servicio Meteorológico Nacional (SMN)', 'https://www.smn.gob.ar/');
  }
  if (p.contains('paraguay') || p == 'py') {
    return const AlertaOficial('Dirección de Meteorología e Hidrología (DMH)',
        'https://www.meteorologia.gov.py/');
  }
  return null;
}
