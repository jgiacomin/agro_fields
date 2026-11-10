import 'package:flutter/material.dart';

import '../../models/activos/operacion_protegida_model.dart';
import '../../services/control_operacion.dart';
import '../../services/operacion_service.dart';
import '../produccion/produccion_estilo.dart';
import 'detalle_operacion_screen.dart';
import 'nueva_operacion_screen.dart';
import 'operaciones_textos.dart';

/// Pantalla 1 (paso 7a-3, GAP-OPER-01): las operaciones protegidas de un
/// campo. Arriba, lo que necesita atencion (cheques por vencer, vencidos o
/// rechazados). Abajo, las operaciones en curso y las cerradas.
class OperacionesActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const OperacionesActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<OperacionesActivoScreen> createState() =>
      _OperacionesActivoScreenState();
}

class _OperacionConResultado {
  final OperacionProtegida operacion;
  final ResultadoOperacion resultado;

  const _OperacionConResultado(this.operacion, this.resultado);
}

class _OperacionesActivoScreenState extends State<OperacionesActivoScreen> {
  final OperacionService _servicio = OperacionService();

  bool cargando = true;
  String? error;
  List<_OperacionConResultado> operaciones = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final lista = await _servicio.operacionesDeActivo(widget.activoAgroId);
      final conResultado = await Future.wait(lista.map((op) async {
        final r = await _servicio.resumenDeOperacion(op);
        return _OperacionConResultado(op, r);
      }));
      if (!mounted) return;
      setState(() {
        operaciones = conResultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudieron cargar las operaciones: $e';
        cargando = false;
      });
    }
  }

  Future<void> nueva() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NuevaOperacionScreen(activoAgroId: widget.activoAgroId),
      ),
    );
    if (guardo == true) await cargar();
  }

  Future<void> abrir(OperacionProtegida op) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetalleOperacionScreen(operacion: op)),
    );
    // Al volver se recarga siempre: pudo haber cheques, cobros o cierres.
    await cargar();
  }

  @override
  Widget build(BuildContext context) {
    final enCurso = operaciones.where((o) => o.operacion.estaEnCurso).toList();
    final cerradas =
        operaciones.where((o) => !o.operacion.estaEnCurso).toList();

    // Alertas de todas las operaciones (salvo canceladas).
    final alertas = <(OperacionProtegida, PagoCalculado)>[
      for (final o in operaciones)
        if (o.operacion.estado != EstadoOperacion.cancelada)
          for (final p in o.resultado.alertas) (o.operacion, p),
    ]..sort((a, b) =>
        a.$2.pago.fechaVencimiento!.compareTo(b.$2.pago.fechaVencimiento!));

    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Operaciones protegidas'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        BotonGrande(texto: 'Reintentar', onPressed: cargar),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        '${widget.nombreActivo} · ventas antes de entregar',
                        style: const TextStyle(
                          fontSize: 14,
                          color: EstiloProduccion.textoSuave,
                        ),
                      ),
                      if (alertas.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const TituloSeccion('Necesita atención'),
                        for (final (op, pago) in alertas)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => abrir(op),
                              child: Aviso(
                                '${nombreEstadoPago(pago.estado)}: '
                                '${formatoImporte(pago.falta, op.moneda)} de '
                                '${op.comprador.nombre} · '
                                '${fechaCorta(pago.pago.fechaVencimiento!)}',
                                grave: pago.estado != EstadoPago.porVencer,
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 20),
                      const TituloSeccion('En curso'),
                      if (enCurso.isEmpty)
                        const Text(
                          'No hay operaciones en curso. Antes de entregar '
                          'hacienda o granos, cargala acá: te avisa lo que '
                          'falta y te recuerda los cheques.',
                          style: TextStyle(
                            color: EstiloProduccion.textoSuave,
                            height: 1.4,
                          ),
                        ),
                      ...enCurso.map(_tarjeta),
                      if (cerradas.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const TituloSeccion('Cerradas'),
                        ...cerradas.map(_tarjeta),
                      ],
                      const LeyendaNoGarantia(),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Nueva operación',
            onPressed: cargando ? null : nueva,
          ),
        ),
      ),
    );
  }

  Widget _tarjeta(_OperacionConResultado o) {
    final op = o.operacion;
    final r = o.resultado;
    final alertas = r.alertas.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        onTap: () => abrir(op),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      op.comprador.nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${nombreProducto(op.producto)} · '
                      '${formatoImporte(op.importe, op.moneda)}'
                      '${op.estaEnCurso ? '' : ' · ${nombreEstadoOperacion(op.estado)}'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: EstiloProduccion.textoSuave,
                      ),
                    ),
                    if (op.estaEnCurso) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Antes de entregar: ${r.puntosCompletos} de '
                        '${r.puntosTotales}'
                        '${alertas > 0 ? ' · $alertas para mirar' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: alertas > 0
                              ? EstiloProduccion.rojo
                              : r.puntosCompletos == r.puntosTotales
                                  ? EstiloProduccion.verde
                                  : amarillo,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: EstiloProduccion.textoSuave),
            ],
          ),
        ),
      ),
    );
  }
}
