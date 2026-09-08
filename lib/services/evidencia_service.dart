import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/evidencia_model.dart';
import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';

class EvidenciaService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final AuditService _auditService = AuditService();

  final String coleccion = 'evidencias';

  /// Crea una evidencia vinculada a un ActivoAgro.
  ///
  /// Guarda la evidencia en Firestore y registra
  /// la creación en la auditoría del activo.
  Future<String> crearEvidencia({
    required Evidencia evidencia,
    required String usuarioId,
    String? rol,
  }) async {
    if (evidencia.activoAgroId.isEmpty) {
      throw ArgumentError(
        'La evidencia debe estar vinculada a un activoAgroId.',
      );
    }

    final evidenciaRef =
        _db.collection(coleccion).doc();

    final evidenciaId = evidenciaRef.id;

    final evidenciaGuardar = evidencia.copyWith(
      evidenciaId: evidenciaId,
    );

    await evidenciaRef.set(
      evidenciaGuardar.toMap(),
    );

    await _auditService.registrar(
      activoId: evidencia.activoAgroId,
      usuarioId: usuarioId,
      rol: rol,
      tipo: AuditType.creacion,
      modulo: 'evidencia',
      accion: 'crear_evidencia',
      elementoAfectado: evidenciaId,
      referencia: evidenciaId,
      datos: {
        'tipo': evidencia.tipo,
        'moduloOrigen': evidencia.moduloOrigen,
        'elementoTipo': evidencia.elementoTipo,
        'elementoId': evidencia.elementoId,
        'campoRelacionado': evidencia.campoRelacionado,
        'estadoVerificacion':
            evidencia.estadoVerificacion,
        'estadoValidez':
            evidencia.estadoValidez,
      },
    );

    return evidenciaId;
  }

  /// Obtiene una evidencia por su ID.
  Future<Evidencia?> obtenerPorId(
    String evidenciaId,
  ) async {
    final snapshot = await _db
        .collection(coleccion)
        .doc(evidenciaId)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return Evidencia.fromMap(
      data,
      snapshot.id,
    );
  }

  /// Obtiene todas las evidencias vinculadas a un ActivoAgro.
  Future<List<Evidencia>> obtenerPorActivo(
    String activoAgroId,
  ) async {
    if (activoAgroId.isEmpty) {
      throw ArgumentError(
        'El activoAgroId no puede estar vacío.',
      );
    }

    final snapshot = await _db
        .collection(coleccion)
        .where(
          'activoAgroId',
          isEqualTo: activoAgroId,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) => Evidencia.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }
}


