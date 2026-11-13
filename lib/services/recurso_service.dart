import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/movimiento_stock_model.dart';
import '../models/activos/recurso_agro_model.dart';
import 'movimiento_stock_service.dart';
import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';

class RecursoService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final AuditService _auditService = AuditService();

  final String coleccion = 'recursos';

  /// Crea un recurso vinculado obligatoriamente
  /// a un Activo Agro.
  Future<String> crearRecurso({
    required RecursoAgro recurso,
    required String usuarioId,
    String? rol,
  }) async {
    if (recurso.activoAgroId.isEmpty) {
      throw ArgumentError(
        'El recurso debe estar vinculado a un activoAgroId.',
      );
    }

    final recursoRef =
        _db.collection(coleccion).doc();

    final recursoId = recursoRef.id;

    final recursoGuardar = RecursoAgro(
      recursoId: recursoId,
      activoAgroId: recurso.activoAgroId,
      tipo: recurso.tipo,
      nombre: recurso.nombre,
      descripcion: recurso.descripcion,
      unidad: recurso.unidad,
      cantidadActual: recurso.cantidadActual,
      cantidadMinima: recurso.cantidadMinima,
      estado: recurso.estado,
      moduloProduccionId: recurso.moduloProduccionId,
      numeroSerie: recurso.numeroSerie,
      observaciones: recurso.observaciones,
    );

    await recursoRef.set(
      recursoGuardar.toMap(),
    );

    await _auditService.registrar(
      activoId: recurso.activoAgroId,
      usuarioId: usuarioId,
      rol: rol,
      tipo: AuditType.creacion,
      modulo: 'recursos_inventario',
      accion: 'crear_recurso',
      elementoAfectado: recursoId,
      referencia: recursoId,
      datos: {
        'tipo': recurso.tipo,
        'nombre': recurso.nombre,
        'unidad': recurso.unidad,
        'cantidadActual': recurso.cantidadActual,
        'cantidadMinima': recurso.cantidadMinima,
        'estado': recurso.estado,
        'moduloProduccionId':
            recurso.moduloProduccionId,
      },
    );

    return recursoId;
  }

  /// Obtiene un recurso por su ID.
  Future<RecursoAgro?> obtenerRecursoPorId(
    String recursoId,
  ) async {
    final snapshot = await _db
        .collection(coleccion)
        .doc(recursoId)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return RecursoAgro.fromMap(
      data,
      snapshot.id,
    );
  }

  /// Obtiene todos los recursos vinculados
  /// a un Activo Agro.
  Future<List<RecursoAgro>> obtenerRecursosPorActivo(
    String activoAgroId,
  ) async {
    if (activoAgroId.isEmpty) {
      throw ArgumentError(
        'El activoAgroId no puede estar vacío.',
      );
    }

    final snapshot = await _db
        .collection(coleccion)
        .where(
          'activoAgroId',
          isEqualTo: activoAgroId,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) => RecursoAgro.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }
}

/// GAP-STOCK-01 (13/11/2026): un movimiento con el saldo que dejó.
class MovimientoConSaldo {
  final MovimientoStock movimiento;
  final double? saldoNuevo;

  const MovimientoConSaldo(this.movimiento, this.saldoNuevo);
}

/// GAP-STOCK-01: el stock inicial también entra como movimiento.
/// El producto nace con saldo 0 y, si hay cantidad inicial, se registra
/// una "entrada" (con su auditoría), así cada litro o kilo queda trazado
/// desde el primer día.
extension RecursoStockInicial on RecursoService {
  Future<String> crearRecursoConStockInicial({
    required RecursoAgro recurso,
    required double cantidadInicial,
    required String usuarioId,
    String? rol,
  }) async {
    if (recurso.nombre.trim().isEmpty) {
      throw ArgumentError('El producto necesita un nombre.');
    }
    if (!cantidadInicial.isFinite || cantidadInicial < 0) {
      throw ArgumentError('La cantidad inicial no puede ser negativa.');
    }

    final recursoId = await crearRecurso(
      recurso: RecursoAgro(
        recursoId: '',
        activoAgroId: recurso.activoAgroId,
        tipo: recurso.tipo,
        nombre: recurso.nombre.trim(),
        descripcion: recurso.descripcion,
        unidad: recurso.unidad,
        cantidadActual: 0,
        cantidadMinima: recurso.cantidadMinima,
        estado: recurso.estado,
        moduloProduccionId: recurso.moduloProduccionId,
        numeroSerie: recurso.numeroSerie,
        observaciones: recurso.observaciones,
      ),
      usuarioId: usuarioId,
      rol: rol,
    );

    if (cantidadInicial > 0) {
      await MovimientoStockService().registrarMovimiento(
        movimiento: MovimientoStock(
          movimientoId: '',
          activoAgroId: recurso.activoAgroId,
          recursoId: recursoId,
          tipoMovimiento: 'entrada',
          cantidad: cantidadInicial,
          unidad: recurso.unidad,
          fechaMovimiento: DateTime.now(),
          responsableId: usuarioId,
          motivo: 'Stock inicial',
        ),
        usuarioId: usuarioId,
        rol: rol,
      );
    }

    return recursoId;
  }

  /// La historia de movimientos de un producto, el más nuevo primero.
  Future<List<MovimientoConSaldo>> movimientosDeRecurso({
    required String activoAgroId,
    required String recursoId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('movimientos_stock')
        .where('activoAgroId', isEqualTo: activoAgroId)
        .where('recursoId', isEqualTo: recursoId)
        .get();

    final lista = snapshot.docs
        .map((doc) => MovimientoConSaldo(
              MovimientoStock.fromMap(doc.data(), doc.id),
              (doc.data()['saldoNuevo'] as num?)?.toDouble(),
            ))
        .toList()
      ..sort((a, b) => b.movimiento.fechaMovimiento
          .compareTo(a.movimiento.fechaMovimiento));
    return lista;
  }
}
