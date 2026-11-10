import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Sube los archivos de los documentos del expediente (escrituras,
/// permisos, etc.) a la carpeta PRIVADA del Activo en Storage.
///
/// Ruta: activos/{activoId}/privado/documentos/{documentoId}/{archivo}
///
/// Las Storage Rules dejan subir al dueño, a quien cargó el expediente y a
/// quien tenga una autorización "crear" en el ámbito "documentacion".
/// Después de subir, la ruta devuelta se guarda en
/// DocumentoActivo.archivoRuta.
class DocumentoArchivoService {
  final FirebaseStorage _storage;

  DocumentoArchivoService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Mismo límite que las Storage Rules.
  static const int tamanioMaximoBytes = 20 * 1024 * 1024;

  /// Arma la ruta del archivo dentro de la carpeta privada del Activo.
  static String construirRuta({
    required String activoId,
    required String documentoId,
    required String nombreArchivo,
  }) {
    return 'activos/$activoId/privado/documentos/$documentoId/'
        '${limpiarNombre(nombreArchivo)}';
  }

  /// Deja el nombre del archivo solo con letras, números, punto, guion y
  /// guion bajo, para que no rompa la ruta.
  static String limpiarNombre(String nombre) {
    final limpio = nombre.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return limpio.isEmpty ? 'archivo' : limpio;
  }

  /// Revisa el archivo antes de subirlo. Devuelve el motivo del rechazo,
  /// o null si está bien. Las mismas reglas las vuelven a revisar las
  /// Storage Rules.
  static String? validar({
    required String contentType,
    required int tamanioBytes,
  }) {
    final esPdf = contentType == 'application/pdf';
    final esImagen = contentType.startsWith('image/');

    if (!esPdf && !esImagen) {
      return 'Solo se pueden subir archivos PDF o imágenes.';
    }

    if (tamanioBytes <= 0) {
      return 'El archivo está vacío.';
    }

    if (tamanioBytes >= tamanioMaximoBytes) {
      return 'El archivo debe pesar menos de 20 MB.';
    }

    return null;
  }

  /// Sube el archivo y devuelve su ruta en Storage.
  Future<String> subirArchivo({
    required String activoId,
    required String documentoId,
    required String nombreArchivo,
    required Uint8List bytes,
    required String contentType,
  }) async {
    if (activoId.trim().isEmpty || documentoId.trim().isEmpty) {
      throw ArgumentError(
        'El Activo Agro y el documento son obligatorios.',
      );
    }

    final error = validar(
      contentType: contentType,
      tamanioBytes: bytes.length,
    );

    if (error != null) {
      throw ArgumentError(error);
    }

    final ruta = construirRuta(
      activoId: activoId,
      documentoId: documentoId,
      nombreArchivo: nombreArchivo,
    );

    await _storage.ref(ruta).putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );

    return ruta;
  }

  // =====================================================
  // PASO 7a-3 — ARCHIVOS DE OPERACIONES PROTEGIDAS
  // Foto del cheque, contrato, poder del firmante.
  // Van a una carpeta APARTE de la privada, con su propia regla en
  // storage.rules: solo el dueño o quien tenga autorización en el ámbito
  // "operaciones" (quien cargó el expediente no entra).
  // =====================================================

  /// Ruta: activos/{activoId}/operaciones/{operacionId}/{archivo}
  static String construirRutaOperacion({
    required String activoId,
    required String operacionId,
    required String nombreArchivo,
  }) {
    return 'activos/$activoId/operaciones/$operacionId/'
        '${limpiarNombre(nombreArchivo)}';
  }

  /// Sube un archivo de una operación y devuelve su ruta en Storage.
  /// Al nombre se le agrega la hora, porque un archivo subido no se
  /// puede pisar (las reglas lo impiden) y se pueden subir varios.
  Future<String> subirArchivoOperacion({
    required String activoId,
    required String operacionId,
    required String nombreArchivo,
    required Uint8List bytes,
    required String contentType,
  }) async {
    if (activoId.trim().isEmpty || operacionId.trim().isEmpty) {
      throw ArgumentError(
        'El Activo Agro y la operación son obligatorios.',
      );
    }

    final error = validar(
      contentType: contentType,
      tamanioBytes: bytes.length,
    );

    if (error != null) {
      throw ArgumentError(error);
    }

    final ruta = construirRutaOperacion(
      activoId: activoId,
      operacionId: operacionId,
      nombreArchivo:
          '${DateTime.now().millisecondsSinceEpoch}_$nombreArchivo',
    );

    await _storage.ref(ruta).putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );

    return ruta;
  }

  /// Link temporal para ver o descargar el archivo (lo controlan las
  /// Storage Rules: solo quien puede leerlo).
  Future<String> obtenerUrlDescarga(String ruta) {
    return _storage.ref(ruta).getDownloadURL();
  }
}
