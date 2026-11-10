import 'package:flutter/material.dart';

import '../../models/activos/evento_operacion_model.dart';
import '../../models/activos/operacion_protegida_model.dart';
import '../../services/control_operacion.dart';
import '../produccion/produccion_estilo.dart';

/// Textos en castellano y piezas chicas de las pantallas de Operaciones
/// Protegidas (paso 7a-3, GAP-OPER-01). Los colores, botones y tarjetas
/// se reutilizan de produccion_estilo.dart (no se duplican).

const Color amarillo = Color(0xFF8A5A00);
const Color amarilloFondo = Color(0xFFFFF7E6);
const Color amarilloBorde = Color(0xFFF2D49B);

String nombreProducto(ProductoOperacion p) {
  switch (p) {
    case ProductoOperacion.hacienda:
      return 'Hacienda';
    case ProductoOperacion.granos:
      return 'Granos';
    case ProductoOperacion.otro:
      return 'Otro';
  }
}

String nombreFormaPago(FormaPagoOperacion f) {
  switch (f) {
    case FormaPagoOperacion.contado:
      return 'Contado';
    case FormaPagoOperacion.transferencia:
      return 'Transferencia';
    case FormaPagoOperacion.cheque:
      return 'Cheque';
    case FormaPagoOperacion.echeq:
      return 'eCheq';
    case FormaPagoOperacion.mixto:
      return 'Mixto';
    case FormaPagoOperacion.otro:
      return 'Otro';
  }
}

String nombreEstadoOperacion(EstadoOperacion e) {
  switch (e) {
    case EstadoOperacion.enCurso:
      return 'En curso';
    case EstadoOperacion.cumplida:
      return 'Cumplida';
    case EstadoOperacion.conIncumplimiento:
      return 'Con incumplimiento';
    case EstadoOperacion.cancelada:
      return 'Cancelada';
  }
}

String nombreEstadoPago(EstadoPago e) {
  switch (e) {
    case EstadoPago.pendiente:
      return 'Pendiente';
    case EstadoPago.porVencer:
      return 'Por vencer';
    case EstadoPago.vencido:
      return 'Vencido sin cobrar';
    case EstadoPago.cobrado:
      return 'Cobrado';
    case EstadoPago.rechazado:
      return 'Rechazado';
  }
}

Color colorEstadoPago(EstadoPago e) {
  switch (e) {
    case EstadoPago.cobrado:
      return EstiloProduccion.verde;
    case EstadoPago.pendiente:
      return EstiloProduccion.textoSuave;
    case EstadoPago.porVencer:
      return amarillo;
    case EstadoPago.vencido:
    case EstadoPago.rechazado:
      return EstiloProduccion.rojo;
  }
}

String nombreTipoEventoOperacion(TipoEventoOperacion t) {
  switch (t) {
    case TipoEventoOperacion.pagoAcordado:
      return 'Cheque o pago';
    case TipoEventoOperacion.entrega:
      return 'Entrega';
    case TipoEventoOperacion.cobro:
      return 'Cobro';
    case TipoEventoOperacion.rechazo:
      return 'Cheque rechazado';
    case TipoEventoOperacion.incumplimiento:
      return 'Incumplimiento';
    case TipoEventoOperacion.nota:
      return 'Nota';
  }
}

String nombreMedioPago(MedioPago m) {
  switch (m) {
    case MedioPago.cheque:
      return 'Cheque';
    case MedioPago.echeq:
      return 'eCheq';
    case MedioPago.transferencia:
      return 'Transferencia';
    case MedioPago.efectivo:
      return 'Efectivo';
    case MedioPago.otro:
      return 'Otro';
  }
}

String nombreTipoGarantia(TipoGarantia t) {
  switch (t) {
    case TipoGarantia.avalBancario:
      return 'Aval bancario';
    case TipoGarantia.sgr:
      return 'SGR';
    case TipoGarantia.seguroCredito:
      return 'Seguro de crédito';
    case TipoGarantia.seguroCaucion:
      return 'Seguro de caución';
    case TipoGarantia.otra:
      return 'Otra';
  }
}

/// 15000000 -> "ARS 15.000.000"
String formatoImporte(double valor, String moneda) {
  final entero = valor.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < entero.length; i++) {
    if (i > 0 && (entero.length - i) % 3 == 0) buffer.write('.');
    buffer.write(entero[i]);
  }
  final signo = valor < 0 ? '-' : '';
  return '$moneda $signo$buffer';
}

/// Lee un numero escrito a la argentina: "15.000.000" o "1500,5".
/// Devuelve null si no es un numero.
double? leerNumero(String texto) {
  final limpio =
      texto.trim().replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.');
  if (limpio.isEmpty) return null;
  return double.tryParse(limpio);
}

String numeroSimple(double valor) =>
    valor % 1 == 0 ? valor.toStringAsFixed(0) : valor.toStringAsFixed(1);

/// Recuadro de aviso (amarillo o rojo).
class Aviso extends StatelessWidget {
  final String texto;
  final bool grave;

  const Aviso(this.texto, {super.key, this.grave = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: grave ? EstiloProduccion.rojoFondo : amarilloFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: grave ? EstiloProduccion.rojoBorde : amarilloBorde,
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: grave ? EstiloProduccion.rojo : amarillo,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Texto fijo: Agro Fields no garantiza el pago (Concepto 6.2).
class LeyendaNoGarantia extends StatelessWidget {
  const LeyendaNoGarantia({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 18),
      child: Text(
        'Agro Fields organiza la información y te avisa lo que falta, pero '
        'no garantiza el pago ni evalúa al comprador. La decisión y el '
        'riesgo son de las partes.',
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: EstiloProduccion.textoSuave,
        ),
      ),
    );
  }
}
