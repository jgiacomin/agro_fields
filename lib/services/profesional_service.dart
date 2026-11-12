import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/autorizacion_activo_model.dart';
import '../models/activos/intervencion_profesional_model.dart';
import 'autorizacion_activo_service.dart';

/// AF-093 (12/11/2026): invitar profesionales al campo y registrar sus
/// intervenciones. Reutiliza las autorizaciones del paso 3:
///   rol profesional + permiso "crear" + ámbito "expedienteProductivo".
/// El nombre del campo viaja en la descripción del ámbito, porque el
/// profesional no puede leer el expediente.
class ProfesionalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AutorizacionActivoService _autorizaciones =
      AutorizacionActivoService();

  static const String motivoInvitacion = 'invitacion_profesional';
  static const String coleccionIntervenciones = 'intervenciones_profesionales';

  /// Es una invitación de profesional (y no otra autorización).
  static bool esInvitacionProfesional(AutorizacionActivo a) =>
      a.rol == RolAutorizacion.profesional &&
      a.permiso == PermisoAutorizacion.crear &&
      a.ambito.tipo == TipoAmbitoAutorizacion.expedienteProductivo &&
      (a.ambito.referenciaId == null || a.ambito.referenciaId!.isEmpty);

  /// El dueño invita al profesional pegando su código.
  Future<void> invitarProfesional({
    required String activoId,
    required String nombreActivo,
    required String duenoId,
    required String codigoProfesional,
  }) async {
    final codigo = codigoProfesional.trim();
    if (codigo.isEmpty) {
      throw ArgumentError('Pegá el código del profesional.');
    }
    if (codigo == duenoId) {
      throw ArgumentError('Ese es tu propio código.');
    }
    if (codigo.contains('/') || codigo.contains(' ')) {
      throw ArgumentError('El código no es válido.');
    }

    // Un minuto antes: si el reloj del celular está adelantado, la
    // autorización igual queda vigente para las reglas.
    final ahora = DateTime.now().subtract(const Duration(minutes: 1));

    await _autorizaciones.guardar(
      AutorizacionActivo(
        autorizacionId: '',
        activoId: activoId,
        usuarioAutorizado: codigo,
        quienOtorga: duenoId,
        rol: RolAutorizacion.profesional,
        permiso: PermisoAutorizacion.crear,
        ambito: AmbitoAutorizacion(
          tipo: TipoAmbitoAutorizacion.expedienteProductivo,
          descripcion: nombreActivo,
        ),
        fechaInicio: ahora,
        estado: EstadoAutorizacion.activa,
        fechaOtorgamiento: ahora,
        motivo: motivoInvitacion,
      ),
    );
  }

  /// Profesionales invitados a un campo (lo consulta el dueño).
  Future<List<AutorizacionActivo>> profesionalesDelCampo(
      String activoId) async {
    final lista = await _autorizaciones.obtenerPorActivo(activoId);
    return lista.where(esInvitacionProfesional).toList()
      ..sort((a, b) => b.fechaOtorgamiento.compareTo(a.fechaOtorgamiento));
  }

  /// El dueño quita el acceso. No se borra: queda "revocada" (historial).
  Future<void> revocar(AutorizacionActivo autorizacion) async {
    await _autorizaciones.guardar(
      autorizacion.copyWith(
        estado: EstadoAutorizacion.revocada,
        fechaFin: DateTime.now(),
      ),
    );
  }

  /// Campos donde el usuario fue invitado como profesional (activas).
  Future<List<AutorizacionActivo>> camposComoProfesional(String uid) async {
    final consulta = await _db
        .collection(_autorizaciones.coleccion)
        .where('usuarioAutorizado', isEqualTo: uid)
        .get();
    final ahora = DateTime.now();
    return consulta.docs
        .map((d) => AutorizacionActivo.fromMap(d.data()))
        .where(esInvitacionProfesional)
        .where((a) =>
            a.estado == EstadoAutorizacion.activa &&
            (a.fechaFin == null || a.fechaFin!.isAfter(ahora)))
        .toList();
  }

  Future<void> registrarIntervencion(IntervencionProfesional i) async {
    final errores = i.validar();
    if (errores.isNotEmpty) throw ArgumentError(errores.join(' '));
    await _db
        .collection(coleccionIntervenciones)
        .doc(i.intervencionId)
        .set(i.toMap());
  }

  /// Intervenciones de un campo. El profesional pasa su uid y ve solo las
  /// suyas; el dueño no lo pasa y ve todas. Las más recientes primero.
  Future<List<IntervencionProfesional>> intervencionesDelCampo(
    String activoId, {
    String? profesionalId,
  }) async {
    Query<Map<String, dynamic>> q = _db
        .collection(coleccionIntervenciones)
        .where('activoAgroId', isEqualTo: activoId);
    if (profesionalId != null) {
      q = q.where('profesionalId', isEqualTo: profesionalId);
    }
    final consulta = await q.get();
    return consulta.docs
        .map((d) => IntervencionProfesional.fromMap(d.data()))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }
}
