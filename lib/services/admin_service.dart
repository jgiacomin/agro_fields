import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';
import '../models/aceptacion_legal_model.dart';
import '../models/activos/activo_publico_model.dart';
import '../models/plan_usuario_model.dart';
import 'encargado_service.dart' show CodigoNoValido;

/// GAP-ADMIN-01 (16/11/2026): tareas del administrador.
/// Las reglas ya dejan todo esto solo al admin; la app no agrega permisos.
class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditService _auditoria = AuditService();

  static const String coleccionPublicos = 'activos_publicos';
  static const String coleccionActivos = 'activos_agro';

  /// Cupo de cada grupo de Fundadores.
  static const int cupoFundadores = 100;

  // ---------------- PUBLICACIONES ----------------

  Future<List<ActivoPublico>> publicacionesPendientes() async {
    final q = await _db
        .collection(coleccionPublicos)
        .where('estadoPublicacion', isEqualTo: 'pendienteRevision')
        .get();
    return q.docs.map((d) => ActivoPublico.fromMap(d.data(), d.id)).toList()
      ..sort((a, b) => a.ultimaActualizacion.compareTo(b.ultimaActualizacion));
  }

  /// Aprobar: aparece en el Mercado de campos. Queda en la auditoría.
  Future<void> aprobar(ActivoPublico p, String adminId) async {
    final batch = _db.batch();
    batch.update(_db.collection(coleccionPublicos).doc(p.activoId), {
      'estadoPublicacion': 'publicado',
      'visible': true,
      'motivoRevision': null,
      'ultimaActualizacion': Timestamp.now(),
    });
    batch.update(_db.collection(coleccionActivos).doc(p.activoId), {
      'estadoPublicacion': 'publicado',
    });
    await batch.commit();
    await _auditoria.registrar(
      activoId: p.activoId,
      usuarioId: adminId,
      rol: 'administrador',
      tipo: AuditType.publicacion,
      modulo: 'admin',
      accion: 'aprobar_publicacion',
      elementoAfectado: p.activoId,
      estadoAnterior: 'pendienteRevision',
      estadoNuevo: 'publicado',
    );
  }

  /// Rechazar: no aparece; vuelve a borrador con el motivo.
  Future<void> rechazar(ActivoPublico p, String adminId, String motivo) async {
    final m = motivo.trim();
    if (m.isEmpty) throw ArgumentError('Escribí el motivo del rechazo.');
    final batch = _db.batch();
    batch.update(_db.collection(coleccionPublicos).doc(p.activoId), {
      'estadoPublicacion': 'borrador',
      'visible': false,
      'motivoRevision': m,
      'ultimaActualizacion': Timestamp.now(),
    });
    batch.update(_db.collection(coleccionActivos).doc(p.activoId), {
      'estadoPublicacion': 'borrador',
    });
    await batch.commit();
    await _auditoria.registrar(
      activoId: p.activoId,
      usuarioId: adminId,
      rol: 'administrador',
      tipo: AuditType.publicacion,
      modulo: 'admin',
      accion: 'rechazar_publicacion',
      elementoAfectado: p.activoId,
      estadoAnterior: 'pendienteRevision',
      estadoNuevo: 'borrador',
      datos: {'motivo': m},
    );
  }

  // ---------------- FUNDADORES ----------------

  /// Revisa el código pegado (null = está bien).
  static String? revisarCodigo(String codigo) {
    final c = codigo.trim();
    if (c.isEmpty) return 'Pegá el código de la persona.';
    if (c.contains('/') || c.contains(' ')) return 'El código no es válido.';
    return null;
  }

  /// Arma el plan Fundador: Pro gratis por 12 meses según el grupo.
  static PlanUsuario planFundador(
      String codigo, GrupoFundador grupo, DateTime inicio) {
    return PlanUsuario(
      usuarioId: codigo,
      plan: grupo == GrupoFundador.gestion
          ? TipoPlan.proProductor
          : TipoPlan.proBroker,
      grupoFundador: grupo,
      fechaInicio: inicio,
      fechaFin: PlanUsuario.finFundador(inicio),
    );
  }

  static Map<GrupoFundador, int> contarPorGrupo(Iterable<PlanUsuario> planes) {
    final r = {for (final g in GrupoFundador.values) g: 0};
    for (final p in planes) {
      final g = p.grupoFundador;
      if (g != null) r[g] = r[g]! + 1;
    }
    return r;
  }

  Future<List<PlanUsuario>> fundadores() async {
    final q = await _db.collection(PlanUsuario.coleccion).get();
    return q.docs
        .map((d) => PlanUsuario.fromMap(d.data(), d.id))
        .where((p) => p.esFundador)
        .toList()
      ..sort((a, b) => (b.fechaInicio ?? DateTime(2000))
          .compareTo(a.fechaInicio ?? DateTime(2000)));
  }

  Future<void> altaFundador({
    required String codigo,
    required GrupoFundador grupo,
    required String adminId,
  }) async {
    final error = revisarCodigo(codigo);
    if (error != null) throw ArgumentError(error);
    final c = codigo.trim();
    // QA 20/11/2026: el código tiene que ser de un usuario registrado
    // (si no, se gastaba un lugar de Fundador en nadie).
    final usuario = await _db.collection('usuarios').doc(c).get();
    if (!usuario.exists) throw const CodigoNoValido();
    final todos = await fundadores();
    if (todos.any((p) => p.usuarioId == c)) {
      throw StateError('Esa persona ya es Fundador.');
    }
    if ((contarPorGrupo(todos)[grupo] ?? 0) >= cupoFundadores) {
      throw StateError('Ese grupo ya tiene $cupoFundadores Fundadores.');
    }
    final plan = planFundador(c, grupo, DateTime.now());
    await _db.collection(PlanUsuario.coleccion).doc(c).set({
      ...plan.toMap(),
      'altaPor': adminId,
    });
  }

  // ---------------- PEDIDOS DE BAJA ----------------

  Future<List<SolicitudBaja>> pedidosBajaPendientes() async {
    final q = await _db
        .collection(SolicitudBaja.coleccion)
        .where('estado', isEqualTo: 'pendiente')
        .get();
    return q.docs.map((d) => SolicitudBaja.fromMap(d.data())).toList()
      ..sort((a, b) => a.fechaPedido.compareTo(b.fechaPedido));
  }

  /// QA 20/11/2026: anula un pedido de baja (era una prueba o la persona
  /// se arrepintió). No se borra: queda con el motivo, y la persona puede
  /// volver a pedir la baja más adelante.
  Future<void> anularBaja(
      String usuarioId, String adminId, String motivo) async {
    await _db.collection(SolicitudBaja.coleccion).doc(usuarioId).update({
      'estado': 'anulada',
      'motivoAnulacion': motivo,
      'fechaAnulada': Timestamp.now(),
      'anuladaPor': adminId,
    });
  }

  Future<void> completarBaja(String usuarioId, String adminId) async {
    await _db.collection(SolicitudBaja.coleccion).doc(usuarioId).update({
      'estado': 'completada',
      'fechaCompletada': Timestamp.now(),
      'completadaPor': adminId,
    });
  }
}
