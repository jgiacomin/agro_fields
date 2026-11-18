import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// QA (18/11/2026, mejora de AF-090): ayuda para ubicar el campo en el
/// mapa sin tener que buscarlo a mano.
///
/// 1. [coordenadasDesdeTexto]: entiende coordenadas pegadas o un link de
///    Google Maps. No usa internet.
/// 2. [buscarLugar]: busca un pueblo con el buscador gratuito de
///    OpenStreetMap (Nominatim). Se usa poco (una vez al abrir el mapa o
///    cuando el usuario busca), dentro de lo que permite ese servicio.
///
/// Solo sirve para mover el mapa: la ubicación se guarda recién cuando
/// el usuario toca el lugar y aprieta "Guardar ubicación".

/// Lee coordenadas de un texto. Acepta:
/// - "-35.39, -62.42" o "-35.39 -62.42" (punto decimal)
/// - "-35,39; -62,42", "-35,39 -62,42" o "-35,39, -62,42" (coma decimal)
/// - links de Google Maps con "@-35.39,-62.42" o "?q=-35.39,-62.42"
/// Devuelve null si no encuentra coordenadas válidas.
LatLng? coordenadasDesdeTexto(String texto) {
  final t = texto.trim();
  if (t.isEmpty) return null;

  final patrones = [
    // Link de Google Maps: .../@-35.39,-62.42,15z
    RegExp(r'@(-?\d{1,3}\.\d+),(-?\d{1,3}\.\d+)'),
    // Link con ?q= o &ll= o &query=
    RegExp(r'[?&](?:q|ll|query)=(-?\d{1,3}\.\d+),\s*(-?\d{1,3}\.\d+)'),
    // Punto decimal, separados por coma, punto y coma o espacio
    RegExp(r'(-?\d{1,3}\.\d+)\s*[,;\s]\s*(-?\d{1,3}\.\d+)'),
    // Coma decimal, separados por punto y coma o espacio
    RegExp(r'(-?\d{1,3},\d+)\s*[;\s]\s*(-?\d{1,3},\d+)'),
    // Coma decimal, separados por coma y espacio ("-35,39, -62,42")
    RegExp(r'(-?\d{1,3},\d+),\s+(-?\d{1,3},\d+)'),
  ];

  for (final patron in patrones) {
    final m = patron.firstMatch(t);
    if (m == null) continue;
    final lat = double.tryParse(m.group(1)!.replaceAll(',', '.'));
    final lng = double.tryParse(m.group(2)!.replaceAll(',', '.'));
    if (lat == null || lng == null) continue;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) continue;
    return LatLng(lat, lng);
  }
  return null;
}

/// Arma el texto para buscar el pueblo del campo con lo que se cargó al
/// crearlo (localidad, departamento, provincia y país; lo vacío se saltea).
String consultaDesdeUbicacion({
  String localidad = '',
  String departamento = '',
  String provincia = '',
  String pais = '',
}) {
  final partes = <String>[];
  for (final p in [localidad, departamento, provincia, pais]) {
    final limpio = p.trim();
    if (limpio.isEmpty) continue;
    // "Carlos Tejedor, Carlos Tejedor" no suma: se pone una sola vez.
    if (partes.any((x) => x.toLowerCase() == limpio.toLowerCase())) continue;
    partes.add(limpio);
  }
  return partes.join(', ');
}

/// Busca un lugar por nombre (pueblo, ciudad, paraje) y devuelve su punto
/// aproximado, o null si no lo encuentra o no hay señal.
Future<LatLng?> buscarLugar(String consulta) async {
  final q = consulta.trim();
  if (q.isEmpty) return null;
  try {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': q,
      'format': 'json',
      'limit': '1',
      'accept-language': 'es',
    });
    final respuesta = await http
        .get(uri, headers: {'User-Agent': 'AgroFields/1.0 (com.agrofields.app)'})
        .timeout(const Duration(seconds: 8));
    if (respuesta.statusCode != 200) return null;
    final lista = jsonDecode(respuesta.body);
    if (lista is! List || lista.isEmpty) return null;
    final primero = lista.first as Map<String, dynamic>;
    final lat = double.tryParse('${primero['lat']}');
    final lng = double.tryParse('${primero['lon']}');
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  } catch (_) {
    return null;
  }
}
