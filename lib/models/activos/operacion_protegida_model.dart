import 'package:cloud_firestore/cloud_firestore.dart';

/// Operacion Agropecuaria Protegida (paso 7a, GAP-OPER-01).
/// Concepto General Integral, seccion 6.2.
///
/// Es la ficha de un negocio del productor ANTES de entregar hacienda,
/// granos u otro producto: a quien le vende, cuanto, como le pagan y con
/// que garantias.
///
/// - Es PRIVADA: la ve el dueno del Activo o quien tenga permiso en el
///   ambito "operaciones".
/// - Se corrige mientras esta en curso. Nunca se borra: se cierra como
///   cumplida, con incumplimiento o cancelada.
/// - Lo que va pasando (cheques, entregas, cobros, rechazos) se registra
///   como EventoOperacion, que es de solo agregar.
///
/// Agro Fields NO garantiza el pago: organiza la informacion y avisa lo
/// que falta. La decision y el riesgo son de las partes.
enum ProductoOperacion {
  hacienda,
  granos,
  otro,
}

enum FormaPagoOperacion {
  contado,
  transferencia,
  cheque,
  echeq,
  mixto,
  otro,
}

enum EstadoOperacion {
  enCurso,
  cumplida,
  conIncumplimiento,
  cancelada,
}

enum TipoGarantia {
  avalBancario,
  sgr,
  seguroCredito,
  seguroCaucion,
  otra,
}

/// Quien compra y quien firma por el comprador.
class CompradorOperacion {
  /// Nombre o razon social.
  final String nombre;

  /// CUIT (Argentina), RUC (Paraguay) u otra identificacion fiscal.
  final String? identificacionFiscal;

  /// Persona que firma o acuerda en nombre del comprador.
  final String? representanteNombre;

  /// Con que caracter firma (titular, apoderado, presidente, etc.).
  final String? representanteCaracter;

  /// Poder o estatuto que muestra que puede firmar (ruta en Storage).
  final String? facultadArchivoRuta;

  const CompradorOperacion({
    required this.nombre,
    this.identificacionFiscal,
    this.representanteNombre,
    this.representanteCaracter,
    this.facultadArchivoRuta,
  });

  factory CompradorOperacion.fromMap(Map<String, dynamic> map) {
    return CompradorOperacion(
      nombre: map['nombre'] as String? ?? '',
      identificacionFiscal: map['identificacionFiscal'] as String?,
      representanteNombre: map['representanteNombre'] as String?,
      representanteCaracter: map['representanteCaracter'] as String?,
      facultadArchivoRuta: map['facultadArchivoRuta'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'identificacionFiscal': identificacionFiscal,
      'representanteNombre': representanteNombre,
      'representanteCaracter': representanteCaracter,
      'facultadArchivoRuta': facultadArchivoRuta,
    };
  }
}

/// Garantia que respalda el pago (aval, SGR, seguro).
class GarantiaOperacion {
  final TipoGarantia tipo;

  /// Banco, SGR o aseguradora que la emite.
  final String? emisor;
  final double? importe;
  final DateTime? fechaVencimiento;
  final String? descripcion;
  final String? archivoRuta;

  const GarantiaOperacion({
    required this.tipo,
    this.emisor,
    this.importe,
    this.fechaVencimiento,
    this.descripcion,
    this.archivoRuta,
  });

  factory GarantiaOperacion.fromMap(Map<String, dynamic> map) {
    return GarantiaOperacion(
      tipo: _buscar(TipoGarantia.values, map['tipo']) ?? TipoGarantia.otra,
      emisor: map['emisor'] as String?,
      importe: (map['importe'] as num?)?.toDouble(),
      fechaVencimiento: _leerFechaOpcional(map['fechaVencimiento']),
      descripcion: map['descripcion'] as String?,
      archivoRuta: map['archivoRuta'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo.name,
      'emisor': emisor,
      'importe': importe,
      'fechaVencimiento':
          fechaVencimiento != null ? Timestamp.fromDate(fechaVencimiento!) : null,
      'descripcion': descripcion,
      'archivoRuta': archivoRuta,
    };
  }
}

class OperacionProtegida {
  final String operacionId;
  final String activoAgroId;
  final String creadoPor;
  final DateTime fechaCreacion;

  // Que se vende.
  final ProductoOperacion producto;
  final String? descripcionProducto;
  final double? cantidad;

  /// cabezas, kg, toneladas, etc.
  final String? unidad;

  /// Rodeo o lote del que sale la hacienda (opcional).
  final String? grupoId;

  // Cuanto y como se paga.
  final double importe;

  /// ARS, USD, PYG...
  final String moneda;
  final FormaPagoOperacion formaPago;

  // A quien.
  final CompradorOperacion comprador;

  // Respaldo.
  final List<GarantiaOperacion> garantias;

  /// Contrato, boleto o acuerdo firmado (ruta en Storage).
  final String? contratoArchivoRuta;

  // Estado.
  final EstadoOperacion estado;
  final DateTime? fechaCierre;
  final String? observaciones;

  const OperacionProtegida({
    required this.operacionId,
    required this.activoAgroId,
    required this.creadoPor,
    required this.fechaCreacion,
    required this.producto,
    required this.importe,
    required this.moneda,
    required this.formaPago,
    required this.comprador,
    this.descripcionProducto,
    this.cantidad,
    this.unidad,
    this.grupoId,
    this.garantias = const [],
    this.contratoArchivoRuta,
    this.estado = EstadoOperacion.enCurso,
    this.fechaCierre,
    this.observaciones,
  });

  bool get estaEnCurso => estado == EstadoOperacion.enCurso;

  /// Revisa que la operacion tenga lo minimo.
  /// Devuelve la lista de problemas; vacia = esta bien.
  ///
  /// Ojo: esto NO es la lista de control antes de entregar (eso va en
  /// el paso 7a-2). Aca solo se pide lo indispensable para guardarla.
  List<String> validar() {
    final errores = <String>[];

    bool vacio(String? texto) => texto == null || texto.trim().isEmpty;

    if (vacio(activoAgroId)) errores.add('Falta el Activo.');
    if (vacio(creadoPor)) errores.add('Falta quien la cargo.');
    if (vacio(comprador.nombre)) errores.add('Falta el nombre del comprador.');
    if (importe <= 0) errores.add('El importe tiene que ser mayor a cero.');
    if (vacio(moneda)) errores.add('Falta la moneda.');
    if (cantidad != null && cantidad! <= 0) {
      errores.add('La cantidad tiene que ser mayor a cero.');
    }
    if (producto == ProductoOperacion.otro && vacio(descripcionProducto)) {
      errores.add('Falta describir el producto.');
    }
    if (!estaEnCurso && fechaCierre == null) {
      errores.add('Una operacion cerrada necesita la fecha de cierre.');
    }

    return errores;
  }

  factory OperacionProtegida.fromMap(Map<String, dynamic> map, String id) {
    return OperacionProtegida(
      operacionId: id,
      activoAgroId: map['activoAgroId'] as String? ?? '',
      creadoPor: map['creadoPor'] as String? ?? '',
      fechaCreacion: _leerFecha(map['fechaCreacion']),
      producto: _buscar(ProductoOperacion.values, map['producto']) ??
          ProductoOperacion.otro,
      descripcionProducto: map['descripcionProducto'] as String?,
      cantidad: (map['cantidad'] as num?)?.toDouble(),
      unidad: map['unidad'] as String?,
      grupoId: map['grupoId'] as String?,
      importe: (map['importe'] as num?)?.toDouble() ?? 0,
      moneda: map['moneda'] as String? ?? '',
      formaPago: _buscar(FormaPagoOperacion.values, map['formaPago']) ??
          FormaPagoOperacion.otro,
      comprador: CompradorOperacion.fromMap(
        Map<String, dynamic>.from(map['comprador'] as Map? ?? const {}),
      ),
      garantias: (map['garantias'] as List? ?? const [])
          .map((g) =>
              GarantiaOperacion.fromMap(Map<String, dynamic>.from(g as Map)))
          .toList(),
      contratoArchivoRuta: map['contratoArchivoRuta'] as String?,
      // Un estado desconocido se lee "en curso": nunca se asume cerrada.
      estado: _buscar(EstadoOperacion.values, map['estado']) ??
          EstadoOperacion.enCurso,
      fechaCierre: _leerFechaOpcional(map['fechaCierre']),
      observaciones: map['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'operacionId': operacionId,
      'activoAgroId': activoAgroId,
      'creadoPor': creadoPor,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'producto': producto.name,
      'descripcionProducto': descripcionProducto,
      'cantidad': cantidad,
      'unidad': unidad,
      'grupoId': grupoId,
      'importe': importe,
      'moneda': moneda,
      'formaPago': formaPago.name,
      'comprador': comprador.toMap(),
      'garantias': garantias.map((g) => g.toMap()).toList(),
      'contratoArchivoRuta': contratoArchivoRuta,
      'estado': estado.name,
      'fechaCierre':
          fechaCierre != null ? Timestamp.fromDate(fechaCierre!) : null,
      'observaciones': observaciones,
    };
  }
}

T? _buscar<T extends Enum>(List<T> valores, dynamic valor) {
  for (final item in valores) {
    if (item.name == valor) return item;
  }
  return null;
}

DateTime _leerFecha(dynamic valor) {
  return _leerFechaOpcional(valor) ?? DateTime.now();
}

DateTime? _leerFechaOpcional(dynamic valor) {
  if (valor is Timestamp) return valor.toDate();
  if (valor is DateTime) return valor;
  if (valor is String) return DateTime.tryParse(valor);
  return null;
}
