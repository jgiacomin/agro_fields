import '../models/activos/evento_operacion_model.dart';
import '../models/activos/operacion_protegida_model.dart';

/// Control de una Operacion Protegida (paso 7a-2, GAP-OPER-01).
///
/// Nada de esto se escribe a mano: sale de la operacion y de sus eventos,
/// igual que las existencias del rodeo. Asi siempre se puede explicar de
/// donde sale cada numero.
///
/// No usa Firebase: recibe los datos y devuelve el resultado. Por eso se
/// puede probar sin conexion.
///
/// Calcula:
///  1. El estado de cada pago acordado (pendiente, por vencer, vencido,
///     cobrado, rechazado).
///  2. Cuanto se acordo, cobro, rechazo y cuanto falta.
///  3. La LISTA DE CONTROL ANTES DE ENTREGAR. Revisa la operacion, NO al
///     comprador: no es un puntaje ni una garantia de pago.
///
/// Lo que no cierra (cobrar mas de lo acordado, un cobro de un pago que no
/// existe, otra moneda) NO se esconde: queda como discrepancia para revisar.

/// Dias de anticipacion para avisar que un pago esta por vencer.
const int diasAvisoPago = 7;

enum EstadoPago {
  pendiente,
  porVencer,
  vencido,
  cobrado,
  rechazado,
}

/// Puntos de la lista de control antes de entregar.
enum PuntoControl {
  identificacionComprador,
  firmante,
  poderFirmante,
  contrato,
  pagosCubrenImporte,
  garantia,
  sinProblemas,
}

class DiscrepanciaOperacion {
  final String eventoId;
  final String descripcion;

  const DiscrepanciaOperacion({
    required this.eventoId,
    required this.descripcion,
  });

  @override
  String toString() => '$eventoId: $descripcion';
}

/// Un pago acordado con lo que le paso despues.
class PagoCalculado {
  final EventoOperacion pago;
  final EstadoPago estado;
  final double cobrado;
  final String? motivoRechazo;

  const PagoCalculado({
    required this.pago,
    required this.estado,
    required this.cobrado,
    this.motivoRechazo,
  });

  double get importe => pago.importe ?? 0;
  double get falta => (importe - cobrado) < 0 ? 0 : importe - cobrado;

  /// Lo que hay que mirar: por vencer, vencido o rechazado.
  bool get requiereAtencion =>
      estado == EstadoPago.porVencer ||
      estado == EstadoPago.vencido ||
      estado == EstadoPago.rechazado;
}

class ItemControl {
  final PuntoControl punto;
  final String descripcion;
  final bool completo;

  /// Que falta, en palabras simples (vacio si esta completo).
  final String? queFalta;

  const ItemControl({
    required this.punto,
    required this.descripcion,
    required this.completo,
    this.queFalta,
  });
}

class ResultadoOperacion {
  final List<PagoCalculado> pagos;
  final double totalAcordado;
  final double totalCobrado;
  final double totalRechazado;
  final double totalEntregado;
  final int incumplimientos;
  final List<ItemControl> listaControl;
  final List<DiscrepanciaOperacion> discrepancias;

  /// Importe de la operacion (para calcular lo que falta).
  final double importeOperacion;

  const ResultadoOperacion({
    required this.pagos,
    required this.totalAcordado,
    required this.totalCobrado,
    required this.totalRechazado,
    required this.totalEntregado,
    required this.incumplimientos,
    required this.listaControl,
    required this.discrepancias,
    required this.importeOperacion,
  });

  /// Lo que falta cobrar de la operacion.
  double get faltaCobrar {
    final falta = importeOperacion - totalCobrado;
    return falta < 0 ? 0 : falta;
  }

  /// Parte del importe que no tiene ningun pago acordado (sin contar los
  /// rechazados): plata que todavia no esta "en papel".
  double get sinPagoAcordado {
    final cubierto = totalAcordado - totalRechazado;
    final falta = importeOperacion - cubierto;
    return falta < 0 ? 0 : falta;
  }

  int get puntosCompletos => listaControl.where((i) => i.completo).length;
  int get puntosTotales => listaControl.length;

  List<PagoCalculado> get alertas =>
      pagos.where((p) => p.requiereAtencion).toList();

  bool get hayDiscrepancias => discrepancias.isNotEmpty;
}

/// Calcula el estado de una operacion a partir de sus eventos.
///
/// [hoy] se puede pasar para probar; si no, se usa la fecha actual.
ResultadoOperacion calcularOperacion(
  OperacionProtegida operacion,
  List<EventoOperacion> eventos, {
  DateTime? hoy,
  int diasAviso = diasAvisoPago,
}) {
  final ahora = hoy ?? DateTime.now();
  final discrepancias = <DiscrepanciaOperacion>[];

  // 1. Solo los eventos de esta operacion.
  final propios = <EventoOperacion>[];
  for (final e in eventos) {
    if (e.operacionId != operacion.operacionId) {
      discrepancias.add(DiscrepanciaOperacion(
        eventoId: e.eventoId,
        descripcion: 'El evento es de otra operacion, no se conto.',
      ));
      continue;
    }
    propios.add(e);
  }

  // 2. Un evento corregido por otro deja de contar (cuenta el nuevo).
  final corregidos = propios
      .map((e) => e.corrigeEventoId)
      .whereType<String>()
      .where((id) => id.trim().isNotEmpty)
      .toSet();
  final vigentes =
      propios.where((e) => !corregidos.contains(e.eventoId)).toList();

  // 3. En el orden en que pasaron.
  vigentes.sort((a, b) {
    final porFecha = a.fechaHecho.compareTo(b.fechaHecho);
    if (porFecha != 0) return porFecha;
    final porCarga = a.fechaCarga.compareTo(b.fechaCarga);
    if (porCarga != 0) return porCarga;
    return a.eventoId.compareTo(b.eventoId);
  });

  bool mismaMoneda(String? moneda) =>
      moneda == null ||
      moneda.trim().isEmpty ||
      moneda.trim().toUpperCase() == operacion.moneda.trim().toUpperCase();

  // Estado de cada pago mientras se recorren los eventos.
  final pagos = <String, EventoOperacion>{};
  final cobrado = <String, double>{};
  final rechazado = <String, String?>{};
  double totalEntregado = 0;
  int incumplimientos = 0;

  for (final e in vigentes) {
    final errores = e.validar();
    if (errores.isNotEmpty) {
      discrepancias.add(DiscrepanciaOperacion(
        eventoId: e.eventoId,
        descripcion: 'Evento incompleto, no se conto: ${errores.join(' ')}',
      ));
      continue;
    }

    switch (e.tipo) {
      case TipoEventoOperacion.pagoAcordado:
        if (!mismaMoneda(e.moneda)) {
          discrepancias.add(DiscrepanciaOperacion(
            eventoId: e.eventoId,
            descripcion: 'El pago esta en ${e.moneda} y la operacion en '
                '${operacion.moneda}: no se sumo.',
          ));
          break;
        }
        pagos[e.eventoId] = e;
        cobrado[e.eventoId] = 0;
        break;

      case TipoEventoOperacion.cobro:
        {
          final pago = pagos[e.pagoEventoId];
          if (pago == null) {
            discrepancias.add(DiscrepanciaOperacion(
              eventoId: e.eventoId,
              descripcion: 'Cobro de un pago que no esta registrado.',
            ));
            break;
          }
          // Sin importe = se cobro todo lo que faltaba.
          final faltaba = (pago.importe ?? 0) - cobrado[pago.eventoId]!;
          final monto = e.importe ?? faltaba;
          final nuevo = cobrado[pago.eventoId]! + monto;
          cobrado[pago.eventoId] = nuevo;
          // Si se cobro despues de un rechazo (lo volvieron a pagar),
          // deja de figurar rechazado.
          rechazado.remove(pago.eventoId);
          if (nuevo > (pago.importe ?? 0)) {
            discrepancias.add(DiscrepanciaOperacion(
              eventoId: e.eventoId,
              descripcion: 'Se cobro mas de lo acordado en ese pago.',
            ));
          }
        }
        break;

      case TipoEventoOperacion.rechazo:
        if (!pagos.containsKey(e.pagoEventoId)) {
          discrepancias.add(DiscrepanciaOperacion(
            eventoId: e.eventoId,
            descripcion: 'Rechazo de un pago que no esta registrado.',
          ));
          break;
        }
        rechazado[e.pagoEventoId!] = e.motivoRechazo;
        break;

      case TipoEventoOperacion.entrega:
        {
          final unidadOp = operacion.unidad?.trim().toLowerCase();
          final unidadEv = e.unidad?.trim().toLowerCase();
          if (unidadOp != null &&
              unidadOp.isNotEmpty &&
              unidadEv != unidadOp) {
            discrepancias.add(DiscrepanciaOperacion(
              eventoId: e.eventoId,
              descripcion: 'La entrega esta en "${e.unidad}" y la operacion '
                  'en "${operacion.unidad}": no se sumo.',
            ));
            break;
          }
          totalEntregado += e.cantidad!;
        }
        break;

      case TipoEventoOperacion.incumplimiento:
        incumplimientos++;
        break;

      case TipoEventoOperacion.nota:
        break;
    }
  }

  if (operacion.cantidad != null && totalEntregado > operacion.cantidad!) {
    discrepancias.add(const DiscrepanciaOperacion(
      eventoId: '',
      descripcion: 'Se entrego mas de lo acordado en la operacion.',
    ));
  }

  // 4. Estado final de cada pago.
  final hoySolo = DateTime(ahora.year, ahora.month, ahora.day);
  final calculados = <PagoCalculado>[];
  double totalAcordado = 0;
  double totalCobrado = 0;
  double totalRechazado = 0;

  for (final pago in pagos.values) {
    final importe = pago.importe ?? 0;
    final yaCobrado = cobrado[pago.eventoId] ?? 0;
    totalAcordado += importe;
    totalCobrado += yaCobrado;

    EstadoPago estado;
    if (rechazado.containsKey(pago.eventoId)) {
      estado = EstadoPago.rechazado;
      final falta = importe - yaCobrado;
      totalRechazado += falta < 0 ? 0 : falta;
    } else if (yaCobrado >= importe) {
      estado = EstadoPago.cobrado;
    } else {
      final v = pago.fechaVencimiento!;
      final vence = DateTime(v.year, v.month, v.day);
      if (hoySolo.isAfter(vence)) {
        estado = EstadoPago.vencido;
      } else if (!vence.isAfter(hoySolo.add(Duration(days: diasAviso)))) {
        estado = EstadoPago.porVencer;
      } else {
        estado = EstadoPago.pendiente;
      }
    }

    calculados.add(PagoCalculado(
      pago: pago,
      estado: estado,
      cobrado: yaCobrado,
      motivoRechazo: rechazado[pago.eventoId],
    ));
  }

  calculados.sort(
      (a, b) => a.pago.fechaVencimiento!.compareTo(b.pago.fechaVencimiento!));

  // 5. Lista de control antes de entregar.
  final hayRechazos = calculados.any((p) => p.estado == EstadoPago.rechazado);
  final cubierto = totalAcordado - totalRechazado;

  final lista = _listaControl(
    operacion,
    pagosCubren: cubierto >= operacion.importe,
    faltaCubrir: operacion.importe - cubierto,
    hayRechazos: hayRechazos,
    incumplimientos: incumplimientos,
  );

  return ResultadoOperacion(
    pagos: calculados,
    totalAcordado: totalAcordado,
    totalCobrado: totalCobrado,
    totalRechazado: totalRechazado,
    totalEntregado: totalEntregado,
    incumplimientos: incumplimientos,
    listaControl: lista,
    discrepancias: discrepancias,
    importeOperacion: operacion.importe,
  );
}

List<ItemControl> _listaControl(
  OperacionProtegida op, {
  required bool pagosCubren,
  required double faltaCubrir,
  required bool hayRechazos,
  required int incumplimientos,
}) {
  bool tiene(String? texto) => texto != null && texto.trim().isNotEmpty;
  final c = op.comprador;

  return [
    ItemControl(
      punto: PuntoControl.identificacionComprador,
      descripcion: 'Comprador identificado (CUIT / RUC)',
      completo: tiene(c.identificacionFiscal),
      queFalta: tiene(c.identificacionFiscal)
          ? null
          : 'Cargar el CUIT o RUC del comprador.',
    ),
    ItemControl(
      punto: PuntoControl.firmante,
      descripcion: 'Se sabe quien firma y con que caracter',
      completo: tiene(c.representanteNombre) && tiene(c.representanteCaracter),
      queFalta: tiene(c.representanteNombre) && tiene(c.representanteCaracter)
          ? null
          : 'Cargar quien firma y si es titular, apoderado, presidente...',
    ),
    ItemControl(
      punto: PuntoControl.poderFirmante,
      descripcion: 'Poder o estatuto del que firma adjunto',
      completo: tiene(c.facultadArchivoRuta),
      queFalta: tiene(c.facultadArchivoRuta)
          ? null
          : 'Adjuntar el poder o estatuto que muestra que puede firmar.',
    ),
    ItemControl(
      punto: PuntoControl.contrato,
      descripcion: 'Contrato, boleto o acuerdo adjunto',
      completo: tiene(op.contratoArchivoRuta),
      queFalta: tiene(op.contratoArchivoRuta)
          ? null
          : 'Adjuntar el contrato, boleto o acuerdo firmado.',
    ),
    ItemControl(
      punto: PuntoControl.pagosCubrenImporte,
      descripcion: 'Los pagos cargados cubren el importe',
      completo: pagosCubren,
      queFalta: pagosCubren
          ? null
          : 'Faltan pagos (cheques, transferencias) por '
              '${faltaCubrir.toStringAsFixed(0)} ${op.moneda}.',
    ),
    ItemControl(
      punto: PuntoControl.garantia,
      descripcion: 'Hay alguna garantia (aval, SGR, seguro)',
      completo: op.garantias.isNotEmpty,
      queFalta: op.garantias.isNotEmpty
          ? null
          : 'No hay garantia cargada. No es obligatoria, pero protege.',
    ),
    ItemControl(
      punto: PuntoControl.sinProblemas,
      descripcion: 'Sin cheques rechazados ni incumplimientos',
      completo: !hayRechazos && incumplimientos == 0,
      queFalta: !hayRechazos && incumplimientos == 0
          ? null
          : 'Hay cheques rechazados o incumplimientos registrados.',
    ),
  ];
}
