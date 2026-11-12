/// Textos de las emergencias (AF-092). Un solo lugar para los nombres.

/// Qué pasó: se elige tocando. Cada uno sabe si es climático o sanitario.
const List<String> tiposEmergencia = [
  'inundacion',
  'sequia',
  'incendio',
  'granizo',
  'helada',
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
