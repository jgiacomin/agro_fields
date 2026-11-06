import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/recurso_agro_model.dart';
import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';

class RecursoService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final AuditService _auditService = AuditService();

  final String coleccion = 'recursos';

  /// Crea un recurso vinculado obligatoriamente
  /// a un Activo Agro.
  Future<String> crearRecurso({
    required RecursoAgro recurso,
    required String usuarioId,
    String? rol,
  }) async {
    if (recurso.activoAgroId.isEmpty) {
      throw ArgumentError(
        'El recurso debe estar vinculado a un activoAgroId.',
      );
    }

    final recursoRef =
        _db.collection(coleccion).doc();

    final recursoId = recursoRef.id;

    final recursoGuardar = RecursoAgro(
      recursoId: recursoId,
      activoAgroId: recurso.activoAgroId,
      tipo: recurso.tipo,
      nombre: recurso.nombre,
      descripcion: recurso.descripcion,
      unidad: recurso.unidad,
      cantidadActual: recurso.cantidadActual,
      cantidadMinima: recurso.cantidadMinima,
      estado: recurso.estado,
      moduloProduccionId: recurso.moduloProduccionId,
      numeroSerie: recurso.numeroSerie,
      observaciones: recurso.observaciones,
    );

    await recursoRef.set(
      recursoGuardar.toMap(),
    );

    await _auditService.registrar(
      activoId: recurso.activoAgroId,
      usuarioId: usuarioId,
      rol: rol,
      tipo: AuditType.creacion,
      modulo: 'recursos_inventario',
      accion: 'crear_recurso',
      elementoAfectado: recursoId,
      referencia: recursoId,
      datos: {
        'tipo': recurso.tipo,
        'nombre': recurso.nombre,
        'unidad': recurso.unidad,
        'cantidadActual': recurso.cantidadActual,
        'cantidadMinima': recurso.cantidadMinima,
        'estado': recurso.estado,
        'moduloProduccionId':
            recurso.moduloProduccionId,
      },
    );

    return recursoId;
  }

  /// Obtiene un recurso por su ID.
  Future<RecursoAgro?> obtenerRecursoPorId(
    String recursoId,
  ) async {
    final snapshot = await _db
        .collection(coleccion)
        .doc(recursoId)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return RecursoAgro.fromMap(
      data,
      snapshot.id,
    );
  }

  /// Obtiene todos los recursos vinculados
  /// a un Activo Agro.
  Future<List<RecursoAgro>> obtenerRecursosPorActivo(
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
          (doc) => RecursoAgro.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }
}