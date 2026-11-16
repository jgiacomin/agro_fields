import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/autorizacion_activo_model.dart';
import '../models/activos/permisos_encargado.dart';
import 'autorizacion_activo_service.dart';

/// GAP-ENC-01 (16/11/2026): invitar encargados al campo, quitarles el
/// acceso y listar los campos donde uno es encargado. Reutiliza las
/// autorizaciones del paso 3 (las reglas ya existen).
class EncargadoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AutorizacionActivoService _autorizaciones = AutorizacionActivoService();

  static const String motivoInvitacion = 'invitacion_encargado';

  /// Revisa el código pegado (null = está bien).
  static String? revisarCodigo(String codigo, String duenoId) {
    final c = codigo.trim();
    if (c.isEmpty) return 'Pegá el código del encargado.';
    if (c == duenoId) return 'Ese es tu propio código.';
    if (c.contains('/') || c.contains(' ')) return 'El código no es válido.';
    return null;
  }

  /// El dueño invita (o actualiza) a un encargado con las áreas elegidas.
  /// Las áreas que se destildan quedan revocadas (no se borran).
  Future<void> invitar({
    required String activoId,
    required String nombreActivo,
    required String duenoId,
    required String codigoEncargado,
    required Set<AreaEncargado> areas,
  }) async {
    final error = revisarCodigo(codigoEncargado, duenoId);
    if (error != null) throw ArgumentError(error);
    if (areas.isEmpty) throw ArgumentError('Elegí al menos una tarea.');
    final codigo = codigoEncargado.trim();

    // Un minuto antes: si el reloj del celular está adelantado, igual
    // queda vigente para las reglas.
    final ahora = DateTime.now().subtract(const Duration(minutes: 1));

    final previas = (await _autorizaciones.obtenerPorActivo(activoId))
        .where((a) => esAutorizacionEncargado(a) && a.usuarioAutorizado == codigo)
        .toList();

    for (final area in AreaEncargado.values) {
      for (final (permiso, ambito) in permisosPorArea[area]!) {
        final previa = previas
            .where((a) => a.permiso == permiso && a.ambito.tipo == ambito)
            .firstOrNull;
        if (areas.contains(area)) {
          await _autorizaciones.guardar(AutorizacionActivo(
            autorizacionId: '',
            activoId: activoId,
            usuarioAutorizado: codigo,
            quienOtorga: duenoId,
            rol: RolAutorizacion.encargado,
            permiso: permiso,
            ambito: AmbitoAutorizacion(tipo: ambito, descripcion: nombreActivo),
            fechaInicio: ahora,
            estado: EstadoAutorizacion.activa,
            fechaOtorgamiento: previa?.fechaOtorgamiento ?? ahora,
            motivo: motivoInvitacion,
          ));
        } else if (previa != null && previa.estado == EstadoAutorizacion.activa) {
          await _autorizaciones.guardar(previa.copyWith(
            estado: EstadoAutorizacion.revocada,
            fechaFin: DateTime.now(),
          ));
        }
      }
    }
  }

  /// Encargados de un campo (lo consulta el dueño).
  Future<List<EncargadoDelCampo>> encargadosDelCampo(String activoId) async {
    final lista = await _autorizaciones.obtenerPorActivo(activoId);
    return agruparEncargados(lista, DateTime.now());
  }

  /// El dueño quita todo el acceso. No se borra: queda "revocada".
  Future<void> revocarTodo(EncargadoDelCampo e) async {
    for (final a in e.autorizaciones) {
      if (a.estado != EstadoAutorizacion.activa) continue;
      await _autorizaciones.guardar(a.copyWith(
        estado: EstadoAutorizacion.revocada,
        fechaFin: DateTime.now(),
      ));
    }
  }

  /// Campos donde el usuario es encargado, con sus áreas habilitadas.
  Future<List<EncargadoDelCampo>> camposComoEncargado(String uid) async {
    final consulta = await _db
        .collection(_autorizaciones.coleccion)
        .where('usuarioAutorizado', isEqualTo: uid)
        .get();
    final auts = consulta.docs.map((d) => AutorizacionActivo.fromMap(d.data()));
    return agruparEncargados(auts, DateTime.now()).where((e) => e.activo).toList();
  }
}
