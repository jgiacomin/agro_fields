import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/trabajo_operacional_model.dart';
import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';

class TrabajoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final AuditService _auditService = AuditService();

  final String coleccion = 'trabajos';

  /// Crea un trabajo operacional vinculado
  /// obligatoriamente a un Activo Agro.
  Future<String> crearTrabajo({
    required TrabajoOperacional trabajo,
    required String usuarioId,
    String? rol,
  }) async {
    if (trabajo.activoAgroId.isEmpty) {
      throw ArgumentError('El trabajo debe estar vinculado a un activoAgroId.');
    }

    final trabajoRef = _db.collection(coleccion).doc();

    final trabajoId = trabajoRef.id;

    final trabajoGuardar = trabajo.copyWith(trabajoId: trabajoId);

    await trabajoRef.set(trabajoGuardar.toMap());

    await _auditService.registrar(
      activoId: trabajo.activoAgroId,
      usuarioId: usuarioId,
      rol: rol,
      tipo: AuditType.creacion,
      modulo: 'trabajo_operacional',
      accion: 'crear_trabajo',
      elementoAfectado: trabajoId,
      referencia: trabajoId,
      datos: {
        'familiaActividad': trabajo.familiaActividad,
        'tipoActividad': trabajo.tipoActividad,
        'descripcion': trabajo.descripcion,
        'moduloProduccionId': trabajo.moduloProduccionId,
        'cicloId': trabajo.cicloId,
        'estadoTrabajo': trabajo.estadoTrabajo,
        'responsableId': trabajo.responsableId,
        'objetoTipo': trabajo.objetoTipo,
        'objetoId': trabajo.objetoId,
      },
    );

    return trabajoId;
  }

  /// Obtiene un trabajo operacional por su ID.
  Future<TrabajoOperacional?> obtenerTrabajoPorId(String trabajoId) async {
    final snapshot = await _db.collection(coleccion).doc(trabajoId).get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return TrabajoOperacional.fromMap(data, snapshot.id);
  }

  /// Obtiene todos los trabajos vinculados
  /// a un Activo Agro.
  Future<List<TrabajoOperacional>> obtenerTrabajosPorActivo(
    String activoAgroId,
  ) async {
    if (activoAgroId.isEmpty) {
      throw ArgumentError('El activoAgroId no puede estar vacío.');
    }

    final snapshot = await _db
        .collection(coleccion)
        .where('activoAgroId', isEqualTo: activoAgroId)
        .get();

    return snapshot.docs
        .map((doc) => TrabajoOperacional.fromMap(doc.data(), doc.id))
        .toList();
  }
}
