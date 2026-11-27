import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';

/// Un usuario habilitado para publicar directo (para la lista del admin).
class Habilitado {
  final String usuarioId;
  final String nombre;
  final DateTime? fecha;

  const Habilitado({
    required this.usuarioId,
    required this.nombre,
    this.fecha,
  });
}

/// PUB-DIRECTO (27/11/2026): el admin aprueba una vez a un dueño, broker o
/// inmobiliaria y desde ahí publica y cambia sus avisos sin revisión.
/// Un documento por usuario en `publicadores_habilitados` (ID = usuario).
/// Las reglas de Firebase dejan escribirlo solo al admin.
class HabilitacionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditService _auditoria = AuditService();

  static const String coleccion = 'publicadores_habilitados';

  /// ¿Este usuario puede publicar directo? Sin señal o sin permiso: no.
  Future<bool> estaHabilitado(String usuarioId) async {
    if (usuarioId.isEmpty) return false;
    try {
      final d = await _db.collection(coleccion).doc(usuarioId).get();
      return d.exists;
    } catch (_) {
      return false;
    }
  }

  Future<void> habilitar(String usuarioId, String adminId) async {
    await _db.collection(coleccion).doc(usuarioId).set({
      'habilitadoPor': adminId,
      'fecha': Timestamp.now(),
    });
    await _auditoria.registrar(
      activoId: '',
      usuarioId: adminId,
      rol: 'administrador',
      tipo: AuditType.modificacion,
      modulo: 'admin',
      accion: 'habilitar_publicador',
      elementoAfectado: usuarioId,
    );
  }

  Future<void> quitar(String usuarioId, String adminId) async {
    await _db.collection(coleccion).doc(usuarioId).delete();
    await _auditoria.registrar(
      activoId: '',
      usuarioId: adminId,
      rol: 'administrador',
      tipo: AuditType.modificacion,
      modulo: 'admin',
      accion: 'quitar_publicador',
      elementoAfectado: usuarioId,
    );
  }

  /// Para el admin: todos los habilitados, con su nombre.
  Future<List<Habilitado>> habilitados() async {
    final q = await _db.collection(coleccion).get();
    final lista = <Habilitado>[];
    for (final d in q.docs) {
      var nombre = d.id;
      try {
        final u = await _db.collection('usuarios').doc(d.id).get();
        final n = u.data()?['nombre'];
        if (n is String && n.trim().isNotEmpty) nombre = n;
      } catch (_) {}
      final f = d.data()['fecha'];
      lista.add(Habilitado(
        usuarioId: d.id,
        nombre: nombre,
        fecha: f is Timestamp ? f.toDate() : null,
      ));
    }
    lista.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    return lista;
  }
}
