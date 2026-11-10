import 'package:cloud_firestore/cloud_firestore.dart';

/// Evento de una Operacion Protegida (paso 7a, GAP-OPER-01): QUE PASO.
///
/// Es de SOLO AGREGAR: no se edita ni se borra. Un error se corrige con
/// otro evento que dice a cual corrige (corrigeEventoId).
///
/// El estado de cada cheque o pago (pendiente, por vencer, vencido,
/// cobrado, rechazado) NO se guarda: se calcula desde estos eventos
/// (paso 7a-2), igual que las existencias del rodeo.
///
/// El eventoId se arma en el telefono, para que cargarlo dos veces sin
/// senal no lo duplique (Concepto 8).
enum TipoEventoOperacion {
  /// Un cheque, eCheq o pago comprometido, con su vencimiento.
  pagoAcordado,

  /// Se entrego mercaderia (animales, toneladas...).
  entrega,

  /// Un pago acordado se cobro.
  cobro,

  /// Un pago acordado fue rechazado (cheque rebotado).
  rechazo,

  /// El comprador no cumplio algo.
  incumplimiento,

  /// Comentario o dato suelto.
  nota,
}

enum MedioPago {
  cheque,
  echeq,
  transferencia,
  efectivo,
  otro,
}

/// Declarado no es verificado.
enum EstadoDatoEventoOperacion {
  declarado,
  conEvidencia,
  verificado,
}

class EventoOperacion {
  // Datos comunes a todo evento.
  final String eventoId;
  final String operacionId;
  final String activoAgroId;
  final TipoEventoOperacion tipo;
  final DateTime fechaHecho;
  final DateTime fechaCarga;
  final String cargadoPor;
  final EstadoDatoEventoOperacion estadoDato;

  /// Foto del cheque, comprobante, remito... (rutas en Storage).
  final List<String> archivoRutas;
  final String? corrigeEventoId;
  final String? observaciones;

  // Pago acordado.
  final MedioPago? medioPago;
  final double? importe;
  final String? moneda;
  final DateTime? fechaVencimiento;
  final String? banco;
  final String? numero;
  final String? libradorNombre;
  final String? libradorIdentificacionFiscal;

  // Entrega.
  final double? cantidad;
  final String? unidad;

  /// Si la entrega desconto animales del rodeo, el evento de baja.
  final String? eventoProductivoId;

  // Cobro o rechazo: a que pago acordado se refiere.
  final String? pagoEventoId;
  final String? motivoRechazo;

  const EventoOperacion({
    required this.eventoId,
    required this.operacionId,
    required this.activoAgroId,
    required this.tipo,
    required this.fechaHecho,
    required this.fechaCarga,
    required this.cargadoPor,
    this.estadoDato = EstadoDatoEventoOperacion.declarado,
    this.archivoRutas = const [],
    this.corrigeEventoId,
    this.observaciones,
    this.medioPago,
    this.importe,
    this.moneda,
    this.fechaVencimiento,
    this.banco,
    this.numero,
    this.libradorNombre,
    this.libradorIdentificacionFiscal,
    this.cantidad,
    this.unidad,
    this.eventoProductivoId,
    this.pagoEventoId,
    this.motivoRechazo,
  });

  /// Revisa que el evento tenga lo minimo segun su tipo.
  /// Devuelve la lista de problemas; vacia = esta bien.
  List<String> validar() {
    final errores = <String>[];

    bool vacio(String? texto) => texto == null || texto.trim().isEmpty;

    if (vacio(operacionId)) errores.add('Falta la operacion.');
    if (vacio(activoAgroId)) errores.add('Falta el Activo.');
    if (vacio(cargadoPor)) errores.add('Falta quien lo cargo.');
    if (fechaHecho.isAfter(fechaCarga)) {
      errores.add('La fecha del hecho no puede ser posterior a la carga.');
    }
    if (importe != null && importe! <= 0) {
      errores.add('El importe tiene que ser mayor a cero.');
    }
    if (cantidad != null && cantidad! <= 0) {
      errores.add('La cantidad tiene que ser mayor a cero.');
    }

    switch (tipo) {
      case TipoEventoOperacion.pagoAcordado:
        if (medioPago == null) errores.add('Falta el medio de pago.');
        if (importe == null) errores.add('Falta el importe.');
        if (fechaVencimiento == null) {
          errores.add('Falta la fecha de vencimiento o de pago.');
        }
        if ((medioPago == MedioPago.cheque || medioPago == MedioPago.echeq) &&
            vacio(numero)) {
          errores.add('Falta el numero del cheque.');
        }
        break;
      case TipoEventoOperacion.entrega:
        if (cantidad == null) errores.add('Falta la cantidad entregada.');
        if (vacio(unidad)) errores.add('Falta la unidad (cabezas, kg...).');
        break;
      case TipoEventoOperacion.cobro:
        if (vacio(pagoEventoId)) errores.add('Falta que pago se cobro.');
        break;
      case TipoEventoOperacion.rechazo:
        if (vacio(pagoEventoId)) errores.add('Falta que pago fue rechazado.');
        if (vacio(motivoRechazo)) errores.add('Falta el motivo del rechazo.');
        break;
      case TipoEventoOperacion.incumplimiento:
      case TipoEventoOperacion.nota:
        if (vacio(observaciones)) errores.add('Falta describir lo que paso.');
        break;
    }

    return errores;
  }

  factory EventoOperacion.fromMap(Map<String, dynamic> map, String id) {
    final tipo = _buscar(TipoEventoOperacion.values, map['tipo']);
    if (tipo == null) {
      throw FormatException('TipoEventoOperacion invalido: ${map['tipo']}');
    }

    return EventoOperacion(
      eventoId: id,
      operacionId: map['operacionId'] as String? ?? '',
      activoAgroId: map['activoAgroId'] as String? ?? '',
      tipo: tipo,
      fechaHecho: _leerFecha(map['fechaHecho']),
      fechaCarga: _leerFecha(map['fechaCarga']),
      cargadoPor: map['cargadoPor'] as String? ?? '',
      estadoDato: _buscar(EstadoDatoEventoOperacion.values, map['estadoDato']) ??
          EstadoDatoEventoOperacion.declarado,
      archivoRutas:
          List<String>.from(map['archivoRutas'] as List? ?? const []),
      corrigeEventoId: map['corrigeEventoId'] as String?,
      observaciones: map['observaciones'] as String?,
      medioPago: _buscar(MedioPago.values, map['medioPago']),
      importe: (map['importe'] as num?)?.toDouble(),
      moneda: map['moneda'] as String?,
      fechaVencimiento: _leerFechaOpcional(map['fechaVencimiento']),
      banco: map['banco'] as String?,
      numero: map['numero'] as String?,
      libradorNombre: map['libradorNombre'] as String?,
      libradorIdentificacionFiscal:
          map['libradorIdentificacionFiscal'] as String?,
      cantidad: (map['cantidad'] as num?)?.toDouble(),
      unidad: map['unidad'] as String?,
      eventoProductivoId: map['eventoProductivoId'] as String?,
      pagoEventoId: map['pagoEventoId'] as String?,
      motivoRechazo: map['motivoRechazo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventoId': eventoId,
      'operacionId': operacionId,
      'activoAgroId': activoAgroId,
      'tipo': tipo.name,
      'fechaHecho': Timestamp.fromDate(fechaHecho),
      'fechaCarga': Timestamp.fromDate(fechaCarga),
      'cargadoPor': cargadoPor,
      'estadoDato': estadoDato.name,
      'archivoRutas': archivoRutas,
      'corrigeEventoId': corrigeEventoId,
      'observaciones': observaciones,
      'medioPago': medioPago?.name,
      'importe': importe,
      'moneda': moneda,
      'fechaVencimiento': fechaVencimiento != null
          ? Timestamp.fromDate(fechaVencimiento!)
          : null,
      'banco': banco,
      'numero': numero,
      'libradorNombre': libradorNombre,
      'libradorIdentificacionFiscal': libradorIdentificacionFiscal,
      'cantidad': cantidad,
      'unidad': unidad,
      'eventoProductivoId': eventoProductivoId,
      'pagoEventoId': pagoEventoId,
      'motivoRechazo': motivoRechazo,
    };
  }

  static T? _buscar<T extends Enum>(List<T> valores, dynamic valor) {
    for (final item in valores) {
      if (item.name == valor) return item;
    }
    return null;
  }

  static DateTime _leerFecha(dynamic valor) {
    return _leerFechaOpcional(valor) ?? DateTime.now();
  }

  static DateTime? _leerFechaOpcional(dynamic valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor);
    return null;
  }
}
