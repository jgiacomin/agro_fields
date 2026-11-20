import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/legal/textos_legales.dart';
import '../core/utils/guardado_offline.dart';
import '../models/aceptacion_legal_model.dart';

/// GAP-LEGAL-01 (16/11/2026): aceptación de términos y pedido de baja.
/// Las reglas de Firestore controlan que cada uno solo toque lo suyo.
class LegalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// true = ya aceptó la versión vigente; false = falta aceptar;
  /// null = no se pudo saber (sin señal). Con null la app deja pasar y
  /// vuelve a revisar la próxima vez: nadie queda trabado en el campo.
  Future<bool?> aceptoVersionVigente(String usuarioId) async {
    try {
      final doc = await _db
          .collection(AceptacionLegal.coleccion)
          .doc(AceptacionLegal.construirId(usuarioId, versionLegal))
          .get()
          .timeout(const Duration(seconds: 6));
      return doc.exists;
    } catch (e) {
      if (esErrorSinSenal(e)) return null;
      rethrow;
    }
  }

  Future<ResultadoGuardado> registrarAceptacion(String usuarioId) {
    final aceptacion = AceptacionLegal(
      usuarioId: usuarioId,
      version: versionLegal,
      fecha: DateTime.now(),
      plataforma: kIsWeb ? 'web' : defaultTargetPlatform.name,
    );
    return guardarSinEsperar(_db
        .collection(AceptacionLegal.coleccion)
        .doc(aceptacion.id)
        .set(aceptacion.toMap()));
  }

  /// El pedido de baja de este usuario, si ya lo hizo.
  Future<SolicitudBaja?> pedidoDeBaja(String usuarioId) async {
    final doc = await _db
        .collection(SolicitudBaja.coleccion)
        .doc(usuarioId)
        .get();
    final datos = doc.data();
    return datos == null ? null : SolicitudBaja.fromMap(datos);
  }

  /// Registra el pedido de baja (opción A: lo completa el administrador
  /// dentro de 30 días). Si ya había uno, no se crea otro.
  Future<void> pedirBaja(SolicitudBaja pedido) async {
    final errores = pedido.validar();
    if (errores.isNotEmpty) throw ArgumentError(errores.join(' '));
    final ya = await pedidoDeBaja(pedido.usuarioId);
    // QA 20/11/2026: si el pedido anterior se anuló, se puede pedir de nuevo.
    if (ya != null && ya.estado != 'anulada') {
      throw StateError('Ya pediste la baja de tu cuenta.');
    }
    await _db
        .collection(SolicitudBaja.coleccion)
        .doc(pedido.usuarioId)
        .set(pedido.toMap());
  }
}
