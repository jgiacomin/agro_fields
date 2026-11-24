import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// GAP-MERC-01 Parte B (24/11/2026): fotos del campo en el Mercado.
///
/// Las fotos son de la PUBLICACIÓN, no del expediente. Van a la carpeta
/// pública del campo en Storage:
///   activos/{activoId}/publico/fotos/{archivo}.jpg
/// Las Storage Rules dejan subir y quitar solo al dueño, y verlas a otros
/// usuarios solo si el campo está aprobado en el Mercado.
/// Antes de subir, cada foto se achica (lado mayor 1600 px, JPG) para que
/// cargue rápido con poca señal.
class FotoMercadoService {
  final FirebaseStorage _storage;

  FotoMercadoService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  static const int maxFotos = 6;
  static const int ladoMaximo = 1600;

  /// Mismo límite que las Storage Rules (la foto ya achicada pesa mucho menos).
  static const int tamanioMaximoBytes = 10 * 1024 * 1024;

  static String carpeta(String activoId) => 'activos/$activoId/publico/fotos';

  /// Links ya pedidos (para no pedirlos de nuevo en cada pantalla).
  static final Map<String, String> _urls = {};

  /// Achica la foto: la endereza, deja el lado mayor en 1600 px y la
  /// guarda como JPG. Devuelve null si no se pudo leer (formato raro).
  static Uint8List? achicar(Uint8List bytes) {
    final imagen = img.decodeImage(bytes);
    if (imagen == null) return null;
    final derecha = img.bakeOrientation(imagen);
    final apaisada = derecha.width >= derecha.height;
    final mayor = apaisada ? derecha.width : derecha.height;
    final chica = mayor <= ladoMaximo
        ? derecha
        : apaisada
            ? img.copyResize(derecha, width: ladoMaximo)
            : img.copyResize(derecha, height: ladoMaximo);
    return Uint8List.fromList(img.encodeJpg(chica, quality: 80));
  }

  /// Achica y sube una foto. Devuelve su ruta en Storage.
  Future<String> subir({
    required String activoId,
    required String nombreArchivo,
    required Uint8List bytes,
  }) async {
    final chica = achicar(bytes);
    if (chica == null) {
      throw ArgumentError('No se pudo leer la foto. Usá una foto JPG o PNG.');
    }
    if (chica.length >= tamanioMaximoBytes) {
      throw ArgumentError('La foto es demasiado grande.');
    }
    final base = nombreArchivo
        .split('.')
        .first
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final ruta = '${carpeta(activoId)}/'
        '${DateTime.now().millisecondsSinceEpoch}_'
        '${base.isEmpty ? 'foto' : base}.jpg';
    await _storage
        .ref(ruta)
        .putData(chica, SettableMetadata(contentType: 'image/jpeg'));
    return ruta;
  }

  /// Quita una foto de Storage (solo el dueño; las reglas lo controlan).
  Future<void> quitar(String ruta) async {
    _urls.remove(ruta);
    await _storage.ref(ruta).delete();
  }

  /// Link para mostrar la foto (lo controlan las Storage Rules).
  Future<String> url(String ruta) async {
    final guardado = _urls[ruta];
    if (guardado != null) return guardado;
    final nuevo = await _storage.ref(ruta).getDownloadURL();
    _urls[ruta] = nuevo;
    return nuevo;
  }

  /// Fotos que ya tiene la publicación del campo (lo lee el dueño).
  static Future<List<String>> fotosPublicadas(String activoId) async {
    final doc = await FirebaseFirestore.instance
        .collection('activos_publicos')
        .doc(activoId)
        .get();
    final fotos = doc.data()?['fotos'];
    return fotos is List ? fotos.whereType<String>().toList() : <String>[];
  }
}

/// Muestra una foto del Mercado a partir de su ruta en Storage.
class FotoDelMercado extends StatelessWidget {
  final String ruta;
  final double alto;
  final double? ancho;

  const FotoDelMercado({
    super.key,
    required this.ruta,
    this.alto = 180,
    this.ancho,
  });

  @override
  Widget build(BuildContext context) {
    final vacio = Container(
      height: alto,
      width: ancho,
      color: const Color(0xFFEDE4D3),
      alignment: Alignment.center,
      child: const Icon(Icons.photo_outlined, color: Color(0xFF6B7680)),
    );
    return FutureBuilder<String>(
      future: FotoMercadoService().url(ruta),
      builder: (context, foto) {
        if (!foto.hasData) return vacio;
        return Image.network(
          foto.data!,
          height: alto,
          width: ancho ?? double.infinity,
          fit: BoxFit.cover,
          // En Chrome, si el almacenamiento no da permiso (CORS), se
          // muestra igual con una imagen común del navegador.
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          errorBuilder: (_, __, ___) => vacio,
        );
      },
    );
  }
}
