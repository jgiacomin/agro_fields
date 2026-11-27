import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';
import '../models/activos/activo_agro_model_v2.dart';

/// Lo que se ve antes de confirmar: de qué campo es el código.
class CodigoPosesion {
  final String codigo;
  final String activoId;
  final String nombreCampo;
  final String lugar;
  final DateTime vence;
  final bool usado;

  const CodigoPosesion({
    required this.codigo,
    required this.activoId,
    required this.nombreCampo,
    required this.lugar,
    required this.vence,
    required this.usado,
  });

  bool get vencido => vence.isBefore(DateTime.now());
}

/// El código no existe, ya se usó o venció: mensaje claro para el dueño.
class CodigoPosesionNoValido implements Exception {
  final String mensaje;
  const CodigoPosesionNoValido(this.mensaje);

  @override
  String toString() => mensaje;
}

/// AF-038 F (27/11/2026): "El dueño toma posesión".
/// El broker que cargó un campo sin dueño genera un código de un solo uso
/// (vence en 7 días). El dueño lo canjea y queda como dueño del campo; el
/// broker sigue como quien lo cargó. Las reglas de Firebase validan todo.
class PosesionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditService _auditoria = AuditService();

  static const String coleccion = 'codigos_posesion';

  // Sin letras ni números que se confunden (0/O, 1/I/L).
  static const String _letras = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  static String _nuevoCodigo() {
    final r = Random.secure();
    return List.generate(8, (_) => _letras[r.nextInt(_letras.length)]).join();
  }

  /// "AF-7K3P9QXM" se guarda sin guion y en mayúsculas.
  static String normalizar(String texto) {
    final limpio = texto.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    // Los códigos tienen 8 caracteres; "AF" adelante es solo el prefijo.
    return limpio.length == 10 && limpio.startsWith('AF')
        ? limpio.substring(2)
        : limpio;
  }

  static String mostrar(String codigo) => 'AF-$codigo';

  /// El broker genera el código para el campo que cargó (sin dueño).
  Future<String> generar(ActivoAgroV2 activo, String brokerId) async {
    final codigo = _nuevoCodigo();
    final u = activo.ubicacion;
    final lugar = [u.localidad, u.provincia]
        .where((x) => x.trim().isNotEmpty)
        .join(', ');
    await _db.collection(coleccion).doc(codigo).set({
      'activoId': activo.activoId,
      'creadoPor': brokerId,
      'fecha': Timestamp.now(),
      'vence': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      'nombreCampo': activo.nombre,
      'lugar': lugar,
    });
    try {
      await _auditoria.registrar(
        activoId: activo.activoId,
        usuarioId: brokerId,
        tipo: AuditType.modificacion,
        modulo: 'activo',
        accion: 'generar_codigo_posesion',
        elementoAfectado: activo.activoId,
      );
    } catch (_) {}
    return codigo;
  }

  /// El dueño busca el código antes de confirmar.
  Future<CodigoPosesion> buscar(String texto) async {
    final codigo = normalizar(texto);
    if (codigo.length < 6) {
      throw const CodigoPosesionNoValido('Revisá el código: está incompleto.');
    }
    final d = await _db.collection(coleccion).doc(codigo).get();
    final m = d.data();
    if (!d.exists || m == null) {
      throw const CodigoPosesionNoValido(
          'Ese código no existe. Pedile al broker que te lo mande de nuevo.');
    }
    final vence = m['vence'];
    final c = CodigoPosesion(
      codigo: codigo,
      activoId: m['activoId'] ?? '',
      nombreCampo: m['nombreCampo'] ?? 'Campo',
      lugar: m['lugar'] ?? '',
      vence: vence is Timestamp ? vence.toDate() : DateTime.now(),
      usado: (m['usadoPor'] ?? '').toString().isNotEmpty,
    );
    if (c.usado) {
      throw const CodigoPosesionNoValido('Ese código ya se usó.');
    }
    if (c.vencido) {
      throw const CodigoPosesionNoValido(
          'Ese código venció. Pedile al broker uno nuevo.');
    }
    return c;
  }

  /// El dueño confirma: queda como dueño y el aviso del Mercado pasa a
  /// su nombre (si está publicado).
  Future<void> tomarPosesion(CodigoPosesion c, String duenoId) async {
    final ahora = Timestamp.now();
    final batch = _db.batch();
    batch.update(_db.collection(coleccion).doc(c.codigo), {
      'usadoPor': duenoId,
      'usadoEn': ahora,
    });
    batch.update(_db.collection('activos_agro').doc(c.activoId), {
      'propietarioId': duenoId,
      'codigoPosesion': c.codigo,
      'ultimaActualizacion': ahora,
    });
    // El aviso público solo se puede leer si está publicado; si no, se
    // actualiza la próxima vez que se publique.
    try {
      final pub =
          await _db.collection('activos_publicos').doc(c.activoId).get();
      if (pub.exists) {
        batch.update(_db.collection('activos_publicos').doc(c.activoId), {
          'propietarioId': duenoId,
          'ultimaActualizacion': ahora,
        });
      }
    } catch (_) {}
    await batch.commit();
    try {
      await _auditoria.registrar(
        activoId: c.activoId,
        usuarioId: duenoId,
        tipo: AuditType.modificacion,
        modulo: 'activo',
        accion: 'tomar_posesion',
        elementoAfectado: c.activoId,
        referencia: c.codigo,
      );
    } catch (_) {}
  }
}
