import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/audit/audit_event.dart';
import '../core/audit/audit_service.dart';
import '../core/auth/admin.dart';
import '../core/theme/agro_tema.dart';
import '../models/activos/activo_agro_model_v2.dart';
import '../models/activos/documento_activo_model.dart';
import '../models/activos/operacion_protegida_model.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/campos/campos_screen.dart';
import '../screens/campos/detalle_activo_agro_screen.dart';
import '../screens/documentos/documentos_activo_screen.dart';
import '../screens/operaciones/operaciones_activo_screen.dart';
import '../screens/solicitudes/solicitudes_recibidas_screen.dart';
import 'activo_agro_service_v2.dart';
import 'admin_service.dart';
import 'control_operacion.dart';
import 'operacion_service.dart';
import 'solicitud_contacto_service.dart';

/// AF-145 (26/11/2026): un aviso de la campanita del Inicio.
class Aviso {
  final IconData icono;
  final Color color;
  final String titulo;
  final String detalle;

  /// La pantalla a la que lleva el aviso.
  final Widget Function() destino;

  const Aviso({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.detalle,
    required this.destino,
  });
}

/// AF-145 (26/11/2026): junta en un solo lugar los avisos que la app ya
/// calcula en otras pantallas. No crea datos ni colecciones nuevas: solo
/// lee lo que el usuario ya puede ver (las reglas de Firebase protegen).
///
/// - Admin: publicaciones para aprobar.
/// - Dueño o broker: consultas nuevas del Mercado.
/// - Por cada campo propio: documentos vencidos o por vencer (30 días) y
///   cheques/pagos por vencer (7 días), vencidos o rechazados.
///
/// Si una parte no se puede leer (sin señal o sin permiso), se saltea y se
/// muestran las demás.
class AvisosService {
  final AdminService _admin = AdminService();
  final SolicitudContactoService _solicitudes = SolicitudContactoService();
  final OperacionService _operaciones = OperacionService();
  final AuditService _auditoria = AuditService();

  Future<List<Aviso>> avisos(List<ActivoAgroV2> campos) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final lista = <Aviso>[];

    // 1. Admin: publicaciones para aprobar.
    if (esAdminPorUid(uid)) {
      try {
        final n = (await _admin.publicacionesPendientes()).length;
        if (n > 0) {
          lista.add(Aviso(
            icono: Icons.fact_check_outlined,
            color: AgroTema.terracota,
            titulo: n == 1
                ? 'Tenés 1 publicación para aprobar'
                : 'Tenés $n publicaciones para aprobar',
            detalle: 'Administración',
            destino: () => const AdminScreen(),
          ));
        }
      } catch (_) {}
    }

    // 1b. AF-158 (27/11/2026): avisos del Mercado cambiados hoy por otros.
    if (esAdminPorUid(uid)) {
      try {
        final hoy = DateTime.now();
        final publicados =
            await ActivoAgroServiceV2().obtenerActivosPublicados();
        final n = publicados.where((p) {
          final f = p.ultimaActualizacion;
          return p.ultimoCambioPor.isNotEmpty &&
              !esAdminPorUid(p.ultimoCambioPor) &&
              f.year == hoy.year &&
              f.month == hoy.month &&
              f.day == hoy.day;
        }).length;
        if (n > 0) {
          lista.add(Aviso(
            icono: Icons.storefront,
            color: AgroTema.azul,
            titulo: n == 1
                ? 'Hoy se cambió 1 aviso del Mercado'
                : 'Hoy se cambiaron $n avisos del Mercado',
            detalle: 'Mirar y pausar si hace falta',
            destino: () => const CamposScreen(),
          ));
        }
      } catch (_) {}
    }

    // 2. Consultas nuevas del Mercado (las que todavía no se respondieron).
    try {
      final recibidas =
          await _solicitudes.obtenerSolicitudesPropietario(uid).first;
      final nuevas = recibidas
          .where((s) => s.estado.name == 'pendiente' || s.estado.name == 'vista')
          .length;
      if (nuevas > 0) {
        lista.add(Aviso(
          icono: Icons.mark_email_unread_outlined,
          color: AgroTema.azul,
          titulo: nuevas == 1
              ? '1 consulta nueva en el Mercado'
              : '$nuevas consultas nuevas en el Mercado',
          detalle: 'Solicitudes recibidas',
          destino: () => SolicitudesRecibidasScreen(),
        ));
      }
    } catch (_) {}

    // 3 y 4. Por cada campo propio: documentos y cheques.
    for (final campo in campos) {
      // AF-158: lo que otros cambiaron en los campos del responsable (7
      // días): el dueño, o el broker que lo cargó si todavía no hay dueño.
      if (campo.contactoMercadoId == uid) {
        try {
          final c = await _avisoDeCambios(campo, uid);
          if (c != null) lista.add(c);
        } catch (_) {}
      }
      lista.addAll(_avisosDeDocumentos(campo));
      try {
        lista.addAll(await _avisosDeCheques(campo));
      } catch (_) {}
    }
    return lista;
  }

  /// AF-158 (27/11/2026): el último cambio que hizo otra persona (broker,
  /// admin, profesional o encargado) en los últimos 7 días. Lee el registro
  /// del campo (auditoría), que el dueño ya puede leer.
  Future<Aviso?> _avisoDeCambios(ActivoAgroV2 campo, String uid) async {
    final desde = DateTime.now().subtract(const Duration(days: 7));
    final eventos = (await _auditoria.obtenerPorActivo(campo.activoId))
        .where((e) =>
            e.usuarioId.isNotEmpty &&
            e.usuarioId != uid &&
            e.fecha.isAfter(desde))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    if (eventos.isEmpty) return null;
    final ultimo = eventos.first;
    final mas = eventos.length - 1;
    return Aviso(
      icono: Icons.edit_note,
      color: AgroTema.terracota,
      titulo: '${_quien(ultimo, campo)} ${_queHizo(ultimo.accion)}',
      detalle: [
        campo.nombre,
        _cuando(ultimo.fecha),
        if (mas == 1) '1 cambio más',
        if (mas > 1) '$mas cambios más',
      ].join(' · '),
      destino: () => DetalleActivoAgroScreen(activo: campo),
    );
  }

  static String _quien(AuditEvent e, ActivoAgroV2 campo) {
    final rol = esAdminPorUid(e.usuarioId)
        ? 'administrador'
        : e.usuarioId == campo.publicadorId
            ? 'broker'
            : '';
    final nombre = e.datos?['quien'];
    if (nombre is String && nombre.trim().isNotEmpty) {
      return rol.isEmpty ? nombre.trim() : '${nombre.trim()} ($rol)';
    }
    if (rol == 'administrador') return 'El administrador';
    if (rol == 'broker') return 'El broker';
    return 'Un profesional o encargado';
  }

  static String _queHizo(String accion) {
    switch (accion) {
      case 'guardar_ofertas':
        return 'cambió el precio';
      case 'editar_datos_campo':
        return 'editó los datos del campo';
      case 'publicar_activo':
        return 'cambió el aviso del Mercado';
      default:
        return 'hizo un cambio';
    }
  }

  static String _cuando(DateTime f) {
    final hoy = DateTime.now();
    final dia = DateTime(f.year, f.month, f.day);
    final dias = DateTime(hoy.year, hoy.month, hoy.day).difference(dia).inDays;
    if (dias <= 0) return 'hoy';
    if (dias == 1) return 'ayer';
    return 'hace $dias días';
  }

  List<Aviso> _avisosDeDocumentos(ActivoAgroV2 campo) {
    var vencidos = 0;
    var porVencer = 0;
    for (final d in campo.documentacion.documentosEstructurados) {
      if (d.archivado) continue; // los archivados no avisan
      final e = d.estadoVigencia();
      if (e == EstadoVigenciaDocumento.vencido) vencidos++;
      if (e == EstadoVigenciaDocumento.porVencer) porVencer++;
    }
    final r = <Aviso>[];
    Widget pantalla() => DocumentosActivoScreen(
        activoAgroId: campo.activoId, nombreActivo: campo.nombre);
    if (vencidos > 0) {
      r.add(Aviso(
        icono: Icons.description_outlined,
        color: AgroTema.rojo,
        titulo: vencidos == 1
            ? '1 documento vencido'
            : '$vencidos documentos vencidos',
        detalle: campo.nombre,
        destino: pantalla,
      ));
    }
    if (porVencer > 0) {
      r.add(Aviso(
        icono: Icons.description_outlined,
        color: AgroTema.dorado,
        titulo: porVencer == 1
            ? '1 documento por vencer'
            : '$porVencer documentos por vencer',
        detalle: campo.nombre,
        destino: pantalla,
      ));
    }
    return r;
  }

  Future<List<Aviso>> _avisosDeCheques(ActivoAgroV2 campo) async {
    final ops = await _operaciones.operacionesDeActivo(campo.activoId);
    var porVencer = 0;
    var vencidos = 0;
    var rechazados = 0;
    for (final op in ops) {
      // Solo las operaciones que siguen abiertas.
      if (op.estado == EstadoOperacion.cumplida ||
          op.estado == EstadoOperacion.cancelada) {
        continue;
      }
      final resultado = await _operaciones.resumenDeOperacion(op);
      for (final p in resultado.pagos) {
        if (p.estado == EstadoPago.porVencer) porVencer++;
        if (p.estado == EstadoPago.vencido) vencidos++;
        if (p.estado == EstadoPago.rechazado) rechazados++;
      }
    }
    final r = <Aviso>[];
    Widget pantalla() => OperacionesActivoScreen(
        activoAgroId: campo.activoId, nombreActivo: campo.nombre);
    if (rechazados > 0) {
      r.add(Aviso(
        icono: Icons.money_off,
        color: AgroTema.rojo,
        titulo: rechazados == 1
            ? '1 cheque rechazado'
            : '$rechazados cheques rechazados',
        detalle: campo.nombre,
        destino: pantalla,
      ));
    }
    if (vencidos > 0) {
      r.add(Aviso(
        icono: Icons.payments_outlined,
        color: AgroTema.rojo,
        titulo: vencidos == 1
            ? '1 pago vencido sin cobrar'
            : '$vencidos pagos vencidos sin cobrar',
        detalle: campo.nombre,
        destino: pantalla,
      ));
    }
    if (porVencer > 0) {
      r.add(Aviso(
        icono: Icons.payments_outlined,
        color: AgroTema.dorado,
        titulo: porVencer == 1
            ? '1 cheque o pago por vencer (7 días)'
            : '$porVencer cheques o pagos por vencer (7 días)',
        detalle: campo.nombre,
        destino: pantalla,
      ));
    }
    return r;
  }
}
