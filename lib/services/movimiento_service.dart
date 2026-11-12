import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/movimiento_model.dart';

/// AF-089: traslados (colección única `movimientos`).
class MovimientoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String coleccion = 'movimientos';

  Future<void> registrar(Movimiento m) async {
    final errores = m.validar();
    if (errores.isNotEmpty) throw ArgumentError(errores.join(' '));
    if (m.estado != EstadoMovimiento.programado &&
        m.estado != EstadoMovimiento.enCamino) {
      throw ArgumentError('Un traslado nuevo empieza programado o en camino.');
    }
    await _db.collection(coleccion).doc(m.movimientoId).set(m.toMap());
  }

  /// Traslados de un campo, los más recientes primero.
  Future<List<Movimiento>> delCampo(String activoId) async {
    final consulta = await _db
        .collection(coleccion)
        .where('activoAgroId', isEqualTo: activoId)
        .get();
    return consulta.docs.map((d) => Movimiento.fromMap(d.data())).toList()
      ..sort((a, b) => b.fechaSalida.compareTo(a.fechaSalida));
  }

  /// Cambia el estado (y, al entregar, anota lo recibido).
  /// Solo toca los campos que las reglas permiten cambiar.
  Future<void> cambiarEstado({
    required Movimiento movimiento,
    required EstadoMovimiento nuevo,
    required String usuarioId,
    double? cantidadRecibida,
  }) async {
    if (!Movimiento.puedePasar(movimiento.estado, nuevo)) {
      throw ArgumentError('Ese cambio de estado no está permitido.');
    }
    if (cantidadRecibida != null && cantidadRecibida < 0) {
      throw ArgumentError('Lo recibido no puede ser negativo.');
    }
    final ahora = DateTime.now();
    await _db.collection(coleccion).doc(movimiento.movimientoId).update({
      'estado': nuevo.name,
      if (nuevo == EstadoMovimiento.entregado) ...{
        'fechaEntrega': Timestamp.fromDate(ahora),
        'cantidadRecibida': cantidadRecibida,
      },
      'actualizadoPor': usuarioId,
      'fechaActualizacion': Timestamp.fromDate(ahora),
    });
  }
}
