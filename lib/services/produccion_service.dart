import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/evento_productivo_model.dart';
import '../models/activos/grupo_productivo_model.dart';
import '../models/activos/movimiento_stock_model.dart';
import '../models/activos/unidad_productiva_model.dart';
import 'calculo_existencias.dart';
import 'movimiento_stock_service.dart';

/// Servicio de produccion (paso 6a-2, GAP-PROD-01).
///
/// Guarda y lee unidades productivas, grupos y eventos. Las reglas de
/// Firestore (paso 6a-1) deciden quien puede: el dueno o quien tenga
/// permiso en el ambito "produccion".
///
/// - Unidades y grupos no se borran: se archivan o se cierran.
/// - Los eventos son de solo agregar: un error se corrige con otro evento.
class ProduccionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String coleccionUnidades = 'unidades_productivas';
  static const String coleccionGrupos = 'grupos_productivos';
  static const String coleccionEventos = 'eventos_productivos';

  /// ID armado en el telefono: funciona sin senal y cargar dos veces el
  /// mismo evento no lo duplica.
  String nuevoIdUnidad() => _db.collection(coleccionUnidades).doc().id;
  String nuevoIdGrupo() => _db.collection(coleccionGrupos).doc().id;
  String nuevoIdEvento() => _db.collection(coleccionEventos).doc().id;

  // ---------------------------------------------------------------
  // UNIDADES PRODUCTIVAS
  // ---------------------------------------------------------------

  Future<void> crearUnidad(UnidadProductiva unidad) async {
    if (unidad.unidadId.trim().isEmpty ||
        unidad.activoAgroId.trim().isEmpty) {
      throw ArgumentError('La unidad necesita su ID y su Activo.');
    }
    if (unidad.nombre.trim().isEmpty) {
      throw ArgumentError('La unidad necesita un nombre.');
    }
    if (unidad.estaArchivada) {
      throw ArgumentError('Una unidad nueva no puede nacer archivada.');
    }

    await _db
        .collection(coleccionUnidades)
        .doc(unidad.unidadId)
        .set(unidad.toMap());
  }

  /// Archivar no es borrar: la unidad y su historia quedan.
  Future<void> archivarUnidad(String unidadId) async {
    await _db.collection(coleccionUnidades).doc(unidadId).update({
      'estado': EstadoUnidadProductiva.archivada.name,
    });
  }

  Future<List<UnidadProductiva>> unidadesDeActivo(String activoAgroId) async {
    final snapshot = await _db
        .collection(coleccionUnidades)
        .where('activoAgroId', isEqualTo: activoAgroId)
        .get();

    return snapshot.docs
        .map((doc) => UnidadProductiva.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ---------------------------------------------------------------
  // GRUPOS PRODUCTIVOS
  // ---------------------------------------------------------------

  Future<void> crearGrupo(GrupoProductivo grupo) async {
    if (grupo.grupoId.trim().isEmpty || grupo.activoAgroId.trim().isEmpty) {
      throw ArgumentError('El grupo necesita su ID y su Activo.');
    }
    if (grupo.nombre.trim().isEmpty) {
      throw ArgumentError('El grupo necesita un nombre.');
    }
    if (grupo.estado != EstadoGrupoProductivo.activo) {
      throw ArgumentError('Un grupo nuevo tiene que nacer activo.');
    }

    await _db
        .collection(coleccionGrupos)
        .doc(grupo.grupoId)
        .set(grupo.toMap());
  }

  /// Cerrar no es borrar: el grupo y sus eventos quedan.
  Future<void> cerrarGrupo(String grupoId) async {
    await _db.collection(coleccionGrupos).doc(grupoId).update({
      'estado': EstadoGrupoProductivo.cerrado.name,
    });
  }

  Future<List<GrupoProductivo>> gruposDeActivo(String activoAgroId) async {
    final snapshot = await _db
        .collection(coleccionGrupos)
        .where('activoAgroId', isEqualTo: activoAgroId)
        .get();

    return snapshot.docs
        .map((doc) => GrupoProductivo.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ---------------------------------------------------------------
  // EVENTOS PRODUCTIVOS
  // ---------------------------------------------------------------

  /// Registra un evento. Antes lo revisa con EventoProductivo.validar().
  Future<void> registrarEvento(EventoProductivo evento) async {
    _revisar(evento);

    await _db
        .collection(coleccionEventos)
        .doc(evento.eventoId)
        .set(evento.toMap());
  }

  /// Registra una vacuna o tratamiento que usa un insumo del stock.
  /// GAP-STOCK-01 (13/11/2026): también una aplicación terrestre que
  /// descuenta el producto aplicado.
  ///
  /// 1. Descuenta el insumo con MovimientoStockService (que controla que el
  ///    stock no quede por debajo de cero y deja su auditoria).
  /// 2. Recien despues guarda el evento, con el numero de ese movimiento.
  ///
  /// Si no hay insumo suficiente, no se guarda nada.
  /// El movimiento lleva el ID del evento en las observaciones, para poder
  /// unirlos aunque el segundo paso falle por falta de senal.
  Future<String> registrarSanidadConStock({
    required EventoProductivo evento,
    required String recursoId,
    required double cantidadInsumo,
    required String unidadInsumo,
    required String usuarioId,
    String? rol,
  }) async {
    if (evento.tipo != TipoEventoProductivo.sanidad &&
        evento.tipo != TipoEventoProductivo.aplicacion) {
      throw ArgumentError(
          'Solo una sanidad o una aplicación descuentan stock.');
    }
    _revisar(evento);

    final movimiento = MovimientoStock(
      movimientoId: '',
      activoAgroId: evento.activoAgroId,
      recursoId: recursoId,
      tipoMovimiento: 'consumo',
      cantidad: cantidadInsumo,
      unidad: unidadInsumo,
      fechaMovimiento: evento.fechaHecho,
      trabajoId: evento.trabajoId,
      responsableId: usuarioId,
      motivo: '${evento.tipo.name}: ${evento.tratamiento}',
      observaciones: 'eventoProductivoId: ${evento.eventoId}',
    );

    final movimientoId = await MovimientoStockService().registrarMovimiento(
      movimiento: movimiento,
      usuarioId: usuarioId,
      rol: rol,
    );

    final eventoConStock = EventoProductivo.fromMap({
      ...evento.toMap(),
      'recursoId': recursoId,
      'movimientoStockId': movimientoId,
    }, evento.eventoId);

    await _db
        .collection(coleccionEventos)
        .doc(eventoConStock.eventoId)
        .set(eventoConStock.toMap());

    return movimientoId;
  }

  Future<List<EventoProductivo>> eventosDeGrupo({
    required String activoAgroId,
    required String grupoId,
  }) async {
    final snapshot = await _db
        .collection(coleccionEventos)
        .where('activoAgroId', isEqualTo: activoAgroId)
        .where('grupoId', isEqualTo: grupoId)
        .get();

    final eventos = snapshot.docs
        .map((doc) => EventoProductivo.fromMap(doc.data(), doc.id))
        .toList();

    eventos.sort((a, b) => a.fechaHecho.compareTo(b.fechaHecho));
    return eventos;
  }

  /// Cuantos animales hay de cada categoria y donde, calculado desde los
  /// eventos del grupo.
  Future<ResultadoExistencias> existenciasDeGrupo(GrupoProductivo grupo) async {
    final eventos = await eventosDeGrupo(
      activoAgroId: grupo.activoAgroId,
      grupoId: grupo.grupoId,
    );

    return calcularExistencias(
      eventos,
      unidadInicialId: grupo.unidadInicialId,
    );
  }

  void _revisar(EventoProductivo evento) {
    if (evento.eventoId.trim().isEmpty) {
      throw ArgumentError('El evento necesita su ID.');
    }
    final errores = evento.validar();
    if (errores.isNotEmpty) {
      throw ArgumentError(errores.join(' '));
    }
  }
}
