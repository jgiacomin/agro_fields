import 'package:cloud_firestore/cloud_firestore.dart';

/// GAP-ECO-01 (13/11/2026): un gasto del campo (gestión diaria).
///
/// No es contabilidad: no lleva IVA, factura ni balance. Es para saber
/// cuánto se gastó, en qué y en qué actividad, mes a mes.
///
/// No confundir con EconomiaActivo, que es el resumen económico del
/// expediente (inversión, capital, rentabilidad declarada). Los gastos
/// diarios van acá; al expediente solo irán totales (🟡 después).
///
/// Es de SOLO AGREGAR: no se edita ni se borra. Un error se corrige con
/// otro gasto que dice a cuál corrige (corrigeGastoId). Una corrección con
/// monto 0 anula el gasto (queda en la historia).
///
/// Cada gasto queda en la moneda en que se pagó: no se convierte.
class Gasto {
  final String gastoId;
  final String activoAgroId;

  /// Cuándo se hizo el gasto.
  final DateTime fecha;

  /// Cuándo se cargó en la app.
  final DateTime fechaCarga;
  final String cargadoPor;

  final double monto;

  /// ARS, USD o PYG.
  final String moneda;

  /// Una de [categoriasGasto].
  final String categoria;

  /// agricultura, ganaderia o general.
  final String actividad;

  /// Cultivo o rodeo al que corresponde (opcional).
  final String? grupoId;
  final String? proveedor;
  final String? descripcion;

  /// Foto o PDF del comprobante en Storage (opcional).
  final String? comprobanteRuta;

  /// Si es una corrección, el gasto que corrige.
  final String? corrigeGastoId;

  const Gasto({
    required this.gastoId,
    required this.activoAgroId,
    required this.fecha,
    required this.fechaCarga,
    required this.cargadoPor,
    required this.monto,
    required this.moneda,
    required this.categoria,
    required this.actividad,
    this.grupoId,
    this.proveedor,
    this.descripcion,
    this.comprobanteRuta,
    this.corrigeGastoId,
  });

  bool get esCorreccion =>
      corrigeGastoId != null && corrigeGastoId!.trim().isNotEmpty;

  /// Corrección con monto 0: el gasto original queda anulado.
  bool get anula => esCorreccion && monto == 0;

  /// "2026-11" (para agrupar por mes).
  String get mes =>
      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';

  List<String> validar() {
    final errores = <String>[];
    if (activoAgroId.trim().isEmpty) errores.add('Falta el campo.');
    if (cargadoPor.trim().isEmpty) errores.add('Falta quién lo cargó.');
    if (!monto.isFinite || monto < 0 || (monto == 0 && !esCorreccion)) {
      errores.add('El monto tiene que ser mayor a cero.');
    }
    if (!monedasGasto.contains(moneda)) errores.add('Falta la moneda.');
    if (!categoriasGasto.contains(categoria)) {
      errores.add('Falta la categoría.');
    }
    if (!actividadesGasto.contains(actividad)) {
      errores.add('Falta la actividad.');
    }
    if (fecha.isAfter(fechaCarga)) {
      errores.add('La fecha del gasto no puede ser posterior a hoy.');
    }
    return errores;
  }

  factory Gasto.fromMap(Map<String, dynamic> map, String id) {
    return Gasto(
      gastoId: id,
      activoAgroId: map['activoAgroId'] as String? ?? '',
      fecha: _leerFecha(map['fecha']),
      fechaCarga: _leerFecha(map['fechaCarga']),
      cargadoPor: map['cargadoPor'] as String? ?? '',
      monto: (map['monto'] as num?)?.toDouble() ?? 0,
      moneda: map['moneda'] as String? ?? '',
      categoria: map['categoria'] as String? ?? '',
      actividad: map['actividad'] as String? ?? '',
      grupoId: map['grupoId'] as String?,
      proveedor: map['proveedor'] as String?,
      descripcion: map['descripcion'] as String?,
      comprobanteRuta: map['comprobanteRuta'] as String?,
      corrigeGastoId: map['corrigeGastoId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'gastoId': gastoId,
        'activoAgroId': activoAgroId,
        'fecha': Timestamp.fromDate(fecha),
        'fechaCarga': Timestamp.fromDate(fechaCarga),
        'cargadoPor': cargadoPor,
        'monto': monto,
        'moneda': moneda,
        'categoria': categoria,
        'actividad': actividad,
        'grupoId': grupoId,
        'proveedor': proveedor,
        'descripcion': descripcion,
        'comprobanteRuta': comprobanteRuta,
        'corrigeGastoId': corrigeGastoId,
        'estadoDato': 'declarado',
      };

  static DateTime _leerFecha(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}

const List<String> monedasGasto = ['ARS', 'USD', 'PYG'];

const List<String> categoriasGasto = [
  'insumos',
  'combustible',
  'manoDeObra',
  'contratistas',
  'sanidad',
  'alquiler',
  'fletes',
  'mantenimiento',
  'impuestosServicios',
  'otros',
];

const List<String> actividadesGasto = ['agricultura', 'ganaderia', 'general'];
