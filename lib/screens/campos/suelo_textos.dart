import '../../models/activos/suelo_activo_model.dart';

/// GAP-SUELO-01 (13/11/2026): opciones y cuentas de la pantalla de suelo.
/// Los valores se guardan en minúscula con guion bajo ("franco_arenoso"),
/// así la ficha los muestra claros ("Franco arenoso") sin traducir.

const List<String> texturasSuelo = [
  'arenoso',
  'franco_arenoso',
  'franco',
  'franco_limoso',
  'franco_arcilloso',
  'arcilloso',
];

const List<String> drenajesSuelo = ['bueno', 'moderado', 'malo_anegable'];

const List<String> salinidadesSuelo = ['sin_sales', 'leve', 'moderada', 'alta'];

const List<String> erosionesSuelo = ['sin_erosion', 'leve', 'moderada', 'severa'];

const List<String> profundidadesSuelo = [
  'profundo',
  'moderado',
  'somero',
  'muy_somero',
];

/// Clases de capacidad de uso (I a VIII), el sistema que usan INTA y
/// la mayoría de los mapas de suelo de la región.
const List<String> clasesCapacidadUso = [
  'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII',
];

const String sistemaCapacidadUso = 'capacidad_de_uso';

/// "franco_arenoso" -> "Franco arenoso".
String textoOpcion(String valor) {
  final t = valor.replaceAll('_', ' ');
  return t[0].toUpperCase() + t.substring(1);
}

/// Lee un número como lo escribe la gente: "6,5", "6.5", " 3 ".
/// Vacío -> null (queda "Sin información"). Devuelve double.nan si
/// escribió algo que no es número.
double? leerDecimal(String texto) {
  final t = texto.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t) ?? double.nan;
}

/// Revisa lo cargado. Devuelve la lista de problemas (vacía si está bien).
List<String> validarSuelo({double? ph, double? materiaOrganica}) {
  final errores = <String>[];
  if (ph != null && (ph.isNaN || ph < 0 || ph > 14)) {
    errores.add('El pH tiene que ser un número entre 0 y 14.');
  }
  if (materiaOrganica != null &&
      (materiaOrganica.isNaN || materiaOrganica < 0 || materiaOrganica > 100)) {
    errores.add('La materia orgánica tiene que ser un % entre 0 y 100.');
  }
  return errores;
}

String? _limpio(String? t) {
  final v = (t ?? '').trim();
  return v.isEmpty ? null : v;
}

/// Arma el suelo nuevo a partir del anterior y de lo que cargó el usuario.
/// Lo que la pantalla no muestra (subclase, fertilidad, evidencias, etc.)
/// se conserva tal cual. Lo que el usuario dejó vacío queda vacío.
/// Estado: "declarado" si cargó algo (lo dice el usuario, nadie lo
/// verificó todavía); si no cargó nada, se mantiene el anterior.
SueloActivo armarSuelo({
  required SueloActivo anterior,
  required DateTime ahora,
  String? textura,
  String? drenaje,
  double? ph,
  double? materiaOrganica,
  String? profundidad,
  String? salinidad,
  String? erosion,
  String? clase,
  String? limitaciones,
  String? observaciones,
}) {
  final lim = _limpio(limitaciones);
  final obs = _limpio(observaciones);
  final cargoAlgo = textura != null ||
      drenaje != null ||
      ph != null ||
      materiaOrganica != null ||
      profundidad != null ||
      salinidad != null ||
      erosion != null ||
      clase != null ||
      lim != null ||
      obs != null;

  return SueloActivo(
    estado: cargoAlgo ? 'declarado' : anterior.estado,
    textura: textura,
    drenaje: drenaje,
    ph: ph,
    materiaOrganica: materiaOrganica,
    sistemaClasificacion: clase != null
        ? sistemaCapacidadUso
        : anterior.sistemaClasificacion,
    clase: clase,
    subclase: anterior.subclase,
    unidadTipo: anterior.unidadTipo,
    descripcionClasificacion: anterior.descripcionClasificacion,
    profundidad: profundidad,
    salinidad: salinidad,
    fertilidad: anterior.fertilidad,
    nutrientes: anterior.nutrientes,
    pedregosidad: anterior.pedregosidad,
    retencionAgua: anterior.retencionAgua,
    erosion: erosion,
    limitaciones: lim,
    evidencias: anterior.evidencias,
    observaciones: obs,
    fechaEvaluacion: cargoAlgo ? ahora : anterior.fechaEvaluacion,
  );
}
