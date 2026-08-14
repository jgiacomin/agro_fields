import 'package:cloud_firestore/cloud_firestore.dart';

import 'audit_event.dart';
import 'audit_type.dart';

class AuditService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final String coleccion = 'auditoria_activos';

  Future<String> registrar({
    required String activoId,
    required String usuarioId,
    String? rol,
    required AuditType tipo,
    required String modulo,
    required String accion,
    String? elementoAfectado,
    String? estadoAnterior,
    String? estadoNuevo,
    String? referencia,
    Map<String, dynamic>? datos,
  }) async {
    final eventoId = _db
        .collection(coleccion)
        .doc()
        .id;

    final evento = AuditEvent(
      eventoId: eventoId,
      activoId: activoId,
      usuarioId: usuarioId,
      rol: rol,
      tipo: tipo,
      modulo: modulo,
      accion: accion,
      fecha: DateTime.now(),
      elementoAfectado: elementoAfectado,
      estadoAnterior: estadoAnterior,
      estadoNuevo: estadoNuevo,
      referencia: referencia,
      datos: datos,
    );

    await _db
        .collection(coleccion)
        .doc(eventoId)
        .set(evento.toMap());

    return eventoId;
  }

  Future<List<AuditEvent>> obtenerPorActivo(
    String activoId,
  ) async {
    final snapshot = await _db
        .collection(coleccion)
        .where(
          'activoId',
          isEqualTo: activoId,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) => AuditEvent.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }
}