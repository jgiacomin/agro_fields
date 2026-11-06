import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/autorizacion_activo_model.dart';

class AutorizacionActivoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String coleccion = 'autorizaciones_activos';

  /// Guarda una autorización concreta en Firestore.
  Future<String> guardar(
    AutorizacionActivo autorizacion,
  ) async {
    if (autorizacion.activoId.trim().isEmpty) {
      throw ArgumentError(
        'La autorización debe estar vinculada a un Activo Agro.',
      );
    }

    if (autorizacion.usuarioAutorizado.trim().isEmpty) {
      throw ArgumentError(
        'La autorización debe identificar al usuario autorizado.',
      );
    }

    final autorizacionRef = autorizacion.autorizacionId.trim().isEmpty
        ? _db.collection(coleccion).doc()
        : _db.collection(coleccion).doc(
            autorizacion.autorizacionId,
          );

    final autorizacionId = autorizacionRef.id;

    final autorizacionGuardar = autorizacion.autorizacionId == autorizacionId
        ? autorizacion
        : autorizacion.copyWith(
            autorizacionId: autorizacionId,
          );

    await autorizacionRef.set(
      autorizacionGuardar.toMap(),
    );

    return autorizacionId;
  }

  /// Obtiene una autorización por su ID.
  Future<AutorizacionActivo?> obtenerPorId(
    String autorizacionId,
  ) async {
    if (autorizacionId.trim().isEmpty) {
      throw ArgumentError(
        'El autorizacionId no puede estar vacío.',
      );
    }

    final snapshot = await _db
        .collection(coleccion)
        .doc(autorizacionId)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return AutorizacionActivo.fromMap(data);
  }

  /// Obtiene todas las autorizaciones de un Activo Agro.
  Future<List<AutorizacionActivo>> obtenerPorActivo(
    String activoId,
  ) async {
    if (activoId.trim().isEmpty) {
      throw ArgumentError(
        'El activoId no puede estar vacío.',
      );
    }

    final snapshot = await _db
        .collection(coleccion)
        .where(
          'activoId',
          isEqualTo: activoId,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) => AutorizacionActivo.fromMap(
            doc.data(),
          ),
        )
        .toList();
  }
}
