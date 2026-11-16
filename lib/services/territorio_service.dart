import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/activos/cambio_territorio_model.dart';
import 'documento_archivo_service.dart';

/// AF-109 (16/11/2026): guarda y lee la Historia del territorio.
/// Lo cargan el dueño o quien tenga autorización en el ámbito "territorio";
/// lo ve además el profesional invitado (las reglas lo controlan).
/// No se edita ni se borra: los errores se corrigen con otro registro.
class TerritorioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// El id se arma en el teléfono: guardar dos veces no duplica, y se puede
  /// subir el archivo antes de guardar.
  String nuevoId() => _db.collection(CambioTerritorio.coleccion).doc().id;

  Future<void> registrar(CambioTerritorio cambio) async {
    final errores = cambio.validar();
    if (errores.isNotEmpty) throw ArgumentError(errores.join(' '));
    await _db
        .collection(CambioTerritorio.coleccion)
        .doc(cambio.cambioId)
        .set(cambio.toMap());
  }

  /// Todos los registros del campo (incluidos los corregidos).
  /// Para mostrar, usar [CambioTerritorio.vigentes].
  Future<List<CambioTerritorio>> delCampo(String activoId) async {
    final consulta = await _db
        .collection(CambioTerritorio.coleccion)
        .where('activoAgroId', isEqualTo: activoId)
        .get();
    return consulta.docs
        .map((d) => CambioTerritorio.fromMap(d.data()))
        .toList();
  }

  /// Ruta: activos/{activoId}/territorio/{cambioId}/{archivo}. Tiene su
  /// propia regla en storage.rules (dueño o ámbito "territorio").
  static String construirRuta({
    required String activoId,
    required String cambioId,
    required String nombreArchivo,
  }) =>
      'activos/$activoId/territorio/$cambioId/'
      '${DocumentoArchivoService.limpiarNombre(nombreArchivo)}';

  Future<String> subirArchivo({
    required String activoId,
    required String cambioId,
    required String nombreArchivo,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final error = DocumentoArchivoService.validar(
      contentType: contentType,
      tamanioBytes: bytes.length,
    );
    if (error != null) throw ArgumentError(error);
    final ruta = construirRuta(
      activoId: activoId,
      cambioId: cambioId,
      nombreArchivo:
          '${DateTime.now().millisecondsSinceEpoch}_$nombreArchivo',
    );
    await FirebaseStorage.instance.ref(ruta).putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );
    return ruta;
  }
}
