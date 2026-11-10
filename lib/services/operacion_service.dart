import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/evento_operacion_model.dart';
import '../models/activos/operacion_protegida_model.dart';
import 'control_operacion.dart';

/// Servicio de Operaciones Protegidas (paso 7a-2, GAP-OPER-01).
///
/// Guarda y lee operaciones y sus eventos. Las reglas de Firestore (paso
/// 7a-1) deciden quien puede: el dueno del Activo o quien tenga permiso
/// en el ambito "operaciones".
///
/// - La operacion se corrige mientras esta en curso. Nunca se borra: se
///   cierra como cumplida, con incumplimiento o cancelada.
/// - Los eventos son de solo agregar: un error se corrige con otro evento.
class OperacionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String coleccionOperaciones = 'operaciones_protegidas';
  static const String coleccionEventos = 'eventos_operacion';

  /// Datos que nunca cambian despues de crear la operacion (las reglas
  /// tambien lo impiden).
  static const List<String> _camposFijos = [
    'operacionId',
    'activoAgroId',
    'creadoPor',
    'fechaCreacion',
  ];

  /// ID armado en el telefono: funciona sin senal y cargar dos veces lo
  /// mismo no lo duplica.
  String nuevoIdOperacion() => _db.collection(coleccionOperaciones).doc().id;
  String nuevoIdEvento() => _db.collection(coleccionEventos).doc().id;

  // ---------------------------------------------------------------
  // OPERACIONES
  // ---------------------------------------------------------------

  Future<void> crearOperacion(OperacionProtegida operacion) async {
    if (operacion.operacionId.trim().isEmpty) {
      throw ArgumentError('La operacion necesita su ID.');
    }
    if (!operacion.estaEnCurso) {
      throw ArgumentError('Una operacion nueva tiene que nacer en curso.');
    }
    _revisarOperacion(operacion);

    await _db
        .collection(coleccionOperaciones)
        .doc(operacion.operacionId)
        .set(operacion.toMap());
  }

  /// Corrige los datos de una operacion en curso (comprador, importe,
  /// garantias, archivos...). No cambia el Activo ni quien la creo.
  Future<void> corregirOperacion(OperacionProtegida operacion) async {
    if (!operacion.estaEnCurso) {
      throw ArgumentError(
          'Para cerrar la operacion usar cerrarOperacion.');
    }
    _revisarOperacion(operacion);

    final datos = operacion.toMap()
      ..removeWhere((clave, _) => _camposFijos.contains(clave));

    await _db
        .collection(coleccionOperaciones)
        .doc(operacion.operacionId)
        .update(datos);
  }

  /// Cerrar no es borrar: la operacion y sus eventos quedan.
  Future<void> cerrarOperacion({
    required String operacionId,
    required EstadoOperacion estado,
    DateTime? fechaCierre,
  }) async {
    if (estado == EstadoOperacion.enCurso) {
      throw ArgumentError('Elegir como se cierra: cumplida, con '
          'incumplimiento o cancelada.');
    }

    await _db.collection(coleccionOperaciones).doc(operacionId).update({
      'estado': estado.name,
      'fechaCierre': Timestamp.fromDate(fechaCierre ?? DateTime.now()),
    });
  }

  Future<List<OperacionProtegida>> operacionesDeActivo(
      String activoAgroId) async {
    final snapshot = await _db
        .collection(coleccionOperaciones)
        .where('activoAgroId', isEqualTo: activoAgroId)
        .get();

    final operaciones = snapshot.docs
        .map((doc) => OperacionProtegida.fromMap(doc.data(), doc.id))
        .toList();

    // Las mas nuevas primero.
    operaciones.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    return operaciones;
  }

  // ---------------------------------------------------------------
  // EVENTOS
  // ---------------------------------------------------------------

  /// Registra un evento (cheque, entrega, cobro, rechazo...).
  /// Antes lo revisa con EventoOperacion.validar().
  Future<void> registrarEvento(EventoOperacion evento) async {
    if (evento.eventoId.trim().isEmpty) {
      throw ArgumentError('El evento necesita su ID.');
    }
    final errores = evento.validar();
    if (errores.isNotEmpty) {
      throw ArgumentError(errores.join(' '));
    }

    await _db
        .collection(coleccionEventos)
        .doc(evento.eventoId)
        .set(evento.toMap());
  }

  Future<List<EventoOperacion>> eventosDeOperacion({
    required String activoAgroId,
    required String operacionId,
  }) async {
    // Se filtra tambien por Activo: las reglas lo necesitan para listar.
    final snapshot = await _db
        .collection(coleccionEventos)
        .where('activoAgroId', isEqualTo: activoAgroId)
        .where('operacionId', isEqualTo: operacionId)
        .get();

    final eventos = snapshot.docs
        .map((doc) => EventoOperacion.fromMap(doc.data(), doc.id))
        .toList();

    eventos.sort((a, b) => a.fechaHecho.compareTo(b.fechaHecho));
    return eventos;
  }

  /// Estado de pagos, totales y lista de control, calculados desde los
  /// eventos.
  Future<ResultadoOperacion> resumenDeOperacion(
      OperacionProtegida operacion) async {
    final eventos = await eventosDeOperacion(
      activoAgroId: operacion.activoAgroId,
      operacionId: operacion.operacionId,
    );
    return calcularOperacion(operacion, eventos);
  }

  void _revisarOperacion(OperacionProtegida operacion) {
    final errores = operacion.validar();
    if (errores.isNotEmpty) {
      throw ArgumentError(errores.join(' '));
    }
  }
}
