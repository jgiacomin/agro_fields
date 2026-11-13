import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/activos/gasto_model.dart';
import 'documento_archivo_service.dart';

/// GAP-ECO-01 (13/11/2026): guarda y lee los gastos del campo.
/// Son datos de plata: los ve y carga el dueño, o quien tenga una
/// autorización en el ámbito "economia" (las reglas lo controlan).
class GastoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String coleccion = 'gastos';

  /// El id se arma en el teléfono, para que cargarlo dos veces sin señal
  /// no lo duplique (y para subir el comprobante antes de guardar).
  String nuevoId() => _db.collection(coleccion).doc().id;

  Future<void> registrarGasto(Gasto gasto) async {
    if (gasto.gastoId.trim().isEmpty) {
      throw ArgumentError('El gasto necesita su ID.');
    }
    final errores = gasto.validar();
    if (errores.isNotEmpty) throw ArgumentError(errores.join(' '));
    await _db.collection(coleccion).doc(gasto.gastoId).set(gasto.toMap());
  }

  Future<List<Gasto>> gastosDeActivo(String activoAgroId) async {
    final snapshot = await _db
        .collection(coleccion)
        .where('activoAgroId', isEqualTo: activoAgroId)
        .get();
    return snapshot.docs
        .map((doc) => Gasto.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Ruta: activos/{activoId}/gastos/{gastoId}/{archivo}. Tiene su propia
  /// regla en storage.rules (dueño o ámbito "economia"; el broker que
  /// cargó el expediente no entra).
  static String construirRuta({
    required String activoId,
    required String gastoId,
    required String nombreArchivo,
  }) =>
      'activos/$activoId/gastos/$gastoId/'
      '${DocumentoArchivoService.limpiarNombre(nombreArchivo)}';

  Future<String> subirComprobante({
    required String activoId,
    required String gastoId,
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
      gastoId: gastoId,
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
