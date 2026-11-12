import 'package:cloud_firestore/cloud_firestore.dart';

/// AF-089 (12/11/2026): traslado simple sobre el NÚCLEO COMÚN de transporte.
///
/// Una sola colección (`movimientos`) para todas las actividades, con el
/// campo [actividad]. Lo común: origen, destino, fecha, transportista,
/// guía, estado y control de coherencia (declarado / recibido). Lo propio
/// de cada actividad va en [carga] y [unidad]. Las reglas por país
/// (SENASA, SENACSA, SNIG) quedan aparte, para después.
///
/// No se borra. Solo cambia el estado y lo recibido; si algo se cargó mal,
/// se cancela y se carga de nuevo (queda la historia).
enum EstadoMovimiento { programado, enCamino, entregado, cancelado }

class Movimiento {
  static const List<String> actividades = [
    'ganaderia',
    'agricultura',
    'apicultura',
    'piscicultura',
    'otra',
  ];

  /// Unidades sugeridas por actividad (la primera es la habitual).
  static const Map<String, List<String>> unidadesPorActividad = {
    'ganaderia': ['cabezas'],
    'agricultura': ['tn', 'kg', 'bolsas'],
    'apicultura': ['colmenas', 'kg'],
    'piscicultura': ['kg', 'unidades'],
    'otra': ['unidades', 'kg', 'tn'],
  };

  final String movimientoId;

  /// Campo de origen (el Activo que registra el traslado).
  final String activoAgroId;
  final String actividad;

  /// Destino: otro campo propio (con su id) o un lugar externo escrito.
  final String? destinoActivoId;
  final String destinoDescripcion;

  /// Qué se lleva (categoría de hacienda, grano, colmenas...).
  final String carga;
  final double cantidadDeclarada;
  final String unidad;

  /// Lo que llegó (control de coherencia). null = todavía no se anotó.
  final double? cantidadRecibida;

  final String? transportista;
  final String? patente;
  final String? guia;

  final DateTime fechaSalida;
  final DateTime? fechaEntrega;

  final EstadoMovimiento estado;

  /// Rodeo relacionado (opcional; vincular existencias queda para 🟡).
  final String? grupoId;
  final String? observaciones;

  final String cargadoPor;
  final DateTime fechaCarga;

  /// Declarado no es verificado.
  final String estadoDato;

  const Movimiento({
    required this.movimientoId,
    required this.activoAgroId,
    required this.actividad,
    this.destinoActivoId,
    required this.destinoDescripcion,
    required this.carga,
    required this.cantidadDeclarada,
    required this.unidad,
    this.cantidadRecibida,
    this.transportista,
    this.patente,
    this.guia,
    required this.fechaSalida,
    this.fechaEntrega,
    this.estado = EstadoMovimiento.programado,
    this.grupoId,
    this.observaciones,
    required this.cargadoPor,
    required this.fechaCarga,
    this.estadoDato = 'declarado',
  });

  // ---------------- CONTROL DE COHERENCIA ----------------

  /// Llegó una cantidad distinta de la declarada.
  bool get hayDiferencia =>
      cantidadRecibida != null && cantidadRecibida != cantidadDeclarada;

  /// Recibido menos declarado (negativo = faltan).
  double? get diferencia =>
      cantidadRecibida == null ? null : cantidadRecibida! - cantidadDeclarada;

  bool get terminado =>
      estado == EstadoMovimiento.entregado ||
      estado == EstadoMovimiento.cancelado;

  /// Cambios de estado permitidos (los mismos que controlan las reglas).
  static bool puedePasar(EstadoMovimiento desde, EstadoMovimiento hacia) {
    switch (desde) {
      case EstadoMovimiento.programado:
        return hacia == EstadoMovimiento.enCamino ||
            hacia == EstadoMovimiento.entregado ||
            hacia == EstadoMovimiento.cancelado;
      case EstadoMovimiento.enCamino:
        return hacia == EstadoMovimiento.entregado ||
            hacia == EstadoMovimiento.cancelado;
      case EstadoMovimiento.entregado:
      case EstadoMovimiento.cancelado:
        return false;
    }
  }

  /// Lista de problemas (vacía = se puede guardar).
  List<String> validar() {
    final errores = <String>[];
    if (!actividades.contains(actividad)) errores.add('Elegí la actividad.');
    if (carga.trim().isEmpty) errores.add('Contá qué se lleva.');
    if (cantidadDeclarada <= 0) errores.add('La cantidad tiene que ser mayor a cero.');
    if (unidad.trim().isEmpty) errores.add('Falta la unidad.');
    if (destinoDescripcion.trim().isEmpty) errores.add('Falta el destino.');
    if (cantidadRecibida != null && cantidadRecibida! < 0) {
      errores.add('Lo recibido no puede ser negativo.');
    }
    return errores;
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    final actividad = map['actividad'] as String?;
    return Movimiento(
      movimientoId: map['movimientoId'] as String? ?? '',
      activoAgroId: map['activoAgroId'] as String? ?? '',
      actividad: actividades.contains(actividad) ? actividad! : 'otra',
      destinoActivoId: map['destinoActivoId'] as String?,
      destinoDescripcion: map['destinoDescripcion'] as String? ?? '',
      carga: map['carga'] as String? ?? '',
      cantidadDeclarada: (map['cantidadDeclarada'] as num?)?.toDouble() ?? 0,
      unidad: map['unidad'] as String? ?? '',
      cantidadRecibida: (map['cantidadRecibida'] as num?)?.toDouble(),
      transportista: map['transportista'] as String?,
      patente: map['patente'] as String?,
      guia: map['guia'] as String?,
      fechaSalida: _leerFecha(map['fechaSalida']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      fechaEntrega: _leerFecha(map['fechaEntrega']),
      estado: _leerEstado(map['estado']),
      grupoId: map['grupoId'] as String?,
      observaciones: map['observaciones'] as String?,
      cargadoPor: map['cargadoPor'] as String? ?? '',
      fechaCarga: _leerFecha(map['fechaCarga']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      estadoDato: map['estadoDato'] as String? ?? 'declarado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movimientoId': movimientoId,
      'activoAgroId': activoAgroId,
      'actividad': actividad,
      'destinoActivoId': destinoActivoId,
      'destinoDescripcion': destinoDescripcion,
      'carga': carga,
      'cantidadDeclarada': cantidadDeclarada,
      'unidad': unidad,
      'cantidadRecibida': cantidadRecibida,
      'transportista': transportista,
      'patente': patente,
      'guia': guia,
      'fechaSalida': Timestamp.fromDate(fechaSalida),
      'fechaEntrega':
          fechaEntrega == null ? null : Timestamp.fromDate(fechaEntrega!),
      'estado': estado.name,
      'grupoId': grupoId,
      'observaciones': observaciones,
      'cargadoPor': cargadoPor,
      'fechaCarga': Timestamp.fromDate(fechaCarga),
      'estadoDato': estadoDato,
    };
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor);
    return null;
  }

  /// Un estado desconocido se lee como "programado" (nunca como entregado).
  static EstadoMovimiento _leerEstado(dynamic valor) {
    for (final e in EstadoMovimiento.values) {
      if (e.name == valor) return e;
    }
    return EstadoMovimiento.programado;
  }
}
