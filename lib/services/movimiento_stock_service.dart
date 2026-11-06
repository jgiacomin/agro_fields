import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/movimiento_stock_model.dart';
import '../models/activos/trabajo_operacional_model.dart';
import '../core/audit/audit_event.dart';
import '../core/audit/audit_type.dart';

class MovimientoStockService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String coleccionRecursos = 'recursos';
  final String coleccionMovimientos = 'movimientos_stock';
  final String coleccionTrabajos = 'trabajos';
  final String coleccionAuditoria = 'auditoria_activos';

  /// Registra un movimiento, actualiza el saldo y audita
  /// la operación dentro de una única transacción.
  Future<String> registrarMovimiento({
    required MovimientoStock movimiento,
    required String usuarioId,
    String? rol,
  }) async {
    if (usuarioId.trim().isEmpty) {
      throw ArgumentError('El usuarioId es obligatorio.');
    }

    if (movimiento.activoAgroId.trim().isEmpty ||
        movimiento.recursoId.trim().isEmpty) {
      throw ArgumentError(
        'El Activo Agro y el recurso son obligatorios.',
      );
    }

    if (!movimiento.cantidad.isFinite ||
        movimiento.cantidad <= 0) {
      throw ArgumentError(
        'La cantidad debe ser mayor que cero y finita.',
      );
    }

    const tiposValidos = {
      'entrada',
      'salida',
      'consumo',
      'ajuste',
    };

    if (!tiposValidos.contains(movimiento.tipoMovimiento)) {
      throw ArgumentError('Tipo de movimiento no válido.');
    }

    if (movimiento.tipoMovimiento == 'ajuste') {
      if (movimiento.sentido != 'positivo' &&
          movimiento.sentido != 'negativo') {
        throw ArgumentError(
          'El ajuste requiere sentido positivo o negativo.',
        );
      }

      if (movimiento.motivo == null ||
          movimiento.motivo!.trim().isEmpty) {
        throw ArgumentError(
          'El ajuste requiere un motivo.',
        );
      }
    } else if (movimiento.sentido != null) {
      throw ArgumentError(
        'El sentido solo se permite en los ajustes.',
      );
    }

    if (movimiento.trabajoId != null &&
        movimiento.trabajoId!.trim().isEmpty) {
      throw ArgumentError('El trabajoId no puede estar vacío.');
    }

    final recursoRef =
        _db.collection(coleccionRecursos).doc(movimiento.recursoId);

    final movimientoRef =
        _db.collection(coleccionMovimientos).doc();

    final auditoriaRef =
        _db.collection(coleccionAuditoria).doc();

    final trabajoRef = movimiento.trabajoId == null
        ? null
        : _db
            .collection(coleccionTrabajos)
            .doc(movimiento.trabajoId!);

    return _db.runTransaction<String>((transaction) async {
      // Primero se leen todos los documentos necesarios.
      final recursoSnapshot = await transaction.get(recursoRef);

      if (!recursoSnapshot.exists) {
        throw StateError('El recurso no existe.');
      }

      final recursoData = recursoSnapshot.data();

      if (recursoData == null) {
        throw StateError('No se pudieron leer los datos del recurso.');
      }

      if (recursoData['activoAgroId'] != movimiento.activoAgroId) {
        throw StateError(
          'El recurso no pertenece al Activo Agro indicado.',
        );
      }

      final unidadRecurso = recursoData['unidad'];

      if (unidadRecurso != movimiento.unidad) {
        throw StateError(
          'La unidad del movimiento no coincide con la del recurso.',
        );
      }

      final trabajoSnapshot = trabajoRef == null
          ? null
          : await transaction.get(trabajoRef);

      if (trabajoSnapshot != null) {
        if (!trabajoSnapshot.exists) {
          throw StateError('El trabajo asociado no existe.');
        }

        final trabajoData = trabajoSnapshot.data();

        if (trabajoData == null) {
          throw StateError(
            'No se pudieron leer los datos del trabajo.',
          );
        }

        final trabajo = TrabajoOperacional.fromMap(
          trabajoData,
          trabajoSnapshot.id,
        );

        if (trabajo.activoAgroId != movimiento.activoAgroId) {
          throw StateError(
            'El trabajo y el recurso pertenecen a distintos activos.',
          );
        }
      }

      final cantidadActual =
          (recursoData['cantidadActual'] as num?)?.toDouble();

      if (cantidadActual == null ||
          !cantidadActual.isFinite ||
          cantidadActual < 0) {
        throw StateError('El saldo actual del recurso no es válido.');
      }

      double variacion;

      switch (movimiento.tipoMovimiento) {
        case 'entrada':
          variacion = movimiento.cantidad;
          break;
        case 'salida':
        case 'consumo':
          variacion = -movimiento.cantidad;
          break;
        case 'ajuste':
          variacion = movimiento.sentido == 'positivo'
              ? movimiento.cantidad
              : -movimiento.cantidad;
          break;
        default:
          throw StateError('Tipo de movimiento no válido.');
      }

      final nuevoSaldo = cantidadActual + variacion;

      if (!nuevoSaldo.isFinite || nuevoSaldo < 0) {
        throw StateError(
          'El movimiento dejaría el stock por debajo de cero.',
        );
      }

      final movimientoGuardar = MovimientoStock(
        movimientoId: movimientoRef.id,
        activoAgroId: movimiento.activoAgroId,
        recursoId: movimiento.recursoId,
        tipoMovimiento: movimiento.tipoMovimiento,
        cantidad: movimiento.cantidad,
        unidad: movimiento.unidad,
        fechaMovimiento: movimiento.fechaMovimiento,
        trabajoId: movimiento.trabajoId,
        responsableId: movimiento.responsableId,
        motivo: movimiento.motivo,
        sentido: movimiento.sentido,
        observaciones: movimiento.observaciones,
      );

      final evento = AuditEvent(
        eventoId: auditoriaRef.id,
        activoId: movimiento.activoAgroId,
        usuarioId: usuarioId,
        rol: rol,
        tipo: AuditType.modificacion,
        modulo: 'recursos_inventario',
        accion: 'registrar_movimiento_stock',
        fecha: DateTime.now(),
        elementoAfectado: movimiento.recursoId,
        estadoAnterior: cantidadActual.toString(),
        estadoNuevo: nuevoSaldo.toString(),
        referencia: movimientoRef.id,
        datos: {
          'recursoId': movimiento.recursoId,
          'movimientoId': movimientoRef.id,
          'tipoMovimiento': movimiento.tipoMovimiento,
          'cantidad': movimiento.cantidad,
          'unidad': movimiento.unidad,
          'trabajoId': movimiento.trabajoId,
          'responsableId': movimiento.responsableId,
          'motivo': movimiento.motivo,
          'sentido': movimiento.sentido,
        },
      );

            // Las tres escrituras se confirman juntas o ninguna se aplica.
      transaction.update(recursoRef, {
        'cantidadActual': nuevoSaldo,
        'ultimoMovimientoId': movimientoRef.id,
        'ultimoMovimientoAuditoriaId': auditoriaRef.id,
      });

      transaction.set(movimientoRef, {
        ...movimientoGuardar.toMap(),
        'usuarioId': usuarioId,
        'auditoriaId': auditoriaRef.id,
        'saldoAnterior': cantidadActual,
        'saldoNuevo': nuevoSaldo,
      });

      transaction.set(
        auditoriaRef,
        evento.toMap(),
      );
        
      return movimientoRef.id;
    });
  }
}