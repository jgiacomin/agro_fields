import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/movimiento_stock_model.dart';
import '../../models/activos/recurso_agro_model.dart';
import '../../services/movimiento_stock_service.dart';
import '../../services/recurso_service.dart';
import '../produccion/produccion_estilo.dart';
import 'stock_textos.dart';

/// GAP-STOCK-01 (13/11/2026): un producto del stock.
/// Saldo arriba, botones Entrada / Consumo / Ajuste y la historia de
/// movimientos. Cada movimiento actualiza el saldo y deja su auditoría en
/// una sola transacción (MovimientoStockService). Nada se borra.
class DetalleRecursoScreen extends StatefulWidget {
  final RecursoAgro recurso;

  const DetalleRecursoScreen({super.key, required this.recurso});

  @override
  State<DetalleRecursoScreen> createState() => _DetalleRecursoScreenState();
}

class _DetalleRecursoScreenState extends State<DetalleRecursoScreen> {
  final RecursoService _servicio = RecursoService();
  late RecursoAgro recurso = widget.recurso;
  bool cargando = true;
  String? error;
  List<MovimientoConSaldo> movimientos = [];

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
      final actualizado =
          await _servicio.obtenerRecursoPorId(widget.recurso.recursoId);
      final lista = await _servicio.movimientosDeRecurso(
        activoAgroId: widget.recurso.activoAgroId,
        recursoId: widget.recurso.recursoId,
      );
      if (!mounted) return;
      setState(() {
        if (actualizado != null) recurso = actualizado;
        movimientos = lista;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudo cargar: $e';
        cargando = false;
      });
    }
  }

  Future<void> _movimiento(String tipo) async {
    final guardo = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FormMovimiento(recurso: recurso, tipo: tipo),
    );
    if (guardo == true) await cargar();
  }

  @override
  Widget build(BuildContext context) {
    final u = unidadCorta(recurso.unidad);
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: Text(recurso.nombre),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : RefreshIndicator(
                  onRefresh: cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        nombreTipoRecurso(recurso.tipo),
                        style: const TextStyle(
                            fontSize: 14, color: EstiloProduccion.textoSuave),
                      ),
                      const SizedBox(height: 12),
                      TarjetaBlanca(
                        colorBorde: recurso.stockBajo
                            ? EstiloProduccion.rojoBorde
                            : EstiloProduccion.borde,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hay hoy',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: EstiloProduccion.textoSuave)),
                              Text(
                                '${numeroStock(recurso.cantidadActual)} '
                                '${nombreUnidadStock(recurso.unidad).toLowerCase()}',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: recurso.stockBajo
                                      ? EstiloProduccion.rojo
                                      : EstiloProduccion.texto,
                                ),
                              ),
                              if (recurso.cantidadMinima > 0)
                                Text(
                                  recurso.stockBajo
                                      ? 'Stock bajo: el mínimo es '
                                          '${numeroStock(recurso.cantidadMinima)} $u'
                                      : 'Mínimo: ${numeroStock(recurso.cantidadMinima)} $u',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: recurso.stockBajo
                                        ? EstiloProduccion.rojo
                                        : EstiloProduccion.textoSuave,
                                    fontWeight: recurso.stockBajo
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const TituloSeccion('Movimientos'),
                      if (movimientos.isEmpty)
                        const Text(
                          'Todavía no hay movimientos.',
                          style: TextStyle(color: EstiloProduccion.textoSuave),
                        ),
                      ...movimientos.map(_filaMovimiento),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: BotonGrande(
                  texto: 'Entrada',
                  onPressed: cargando ? null : () => _movimiento('entrada'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BotonGrande(
                  texto: 'Consumo',
                  contorno: true,
                  onPressed: cargando ? null : () => _movimiento('consumo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BotonGrande(
                  texto: 'Ajuste',
                  contorno: true,
                  onPressed: cargando ? null : () => _movimiento('ajuste'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaMovimiento(MovimientoConSaldo ms) {
    final m = ms.movimiento;
    final suma = m.tipoMovimiento == 'entrada' ||
        (m.tipoMovimiento == 'ajuste' && m.sentido == 'positivo');
    final color = suma ? EstiloProduccion.verde : EstiloProduccion.terracota;
    final u = unidadCorta(m.unidad);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TarjetaBlanca(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(suma ? Icons.add_circle_outline : Icons.remove_circle_outline,
                  color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${nombreTipoMovimiento(m.tipoMovimiento)} · '
                      '${fechaCorta(m.fechaMovimiento)}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    if (m.motivo != null && m.motivo!.isNotEmpty)
                      Text(m.motivo!, style: const TextStyle(fontSize: 13)),
                    if (m.observaciones != null && m.observaciones!.isNotEmpty)
                      Text(m.observaciones!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: EstiloProduccion.textoSuave)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${suma ? '+' : '−'}${numeroStock(m.cantidad)} $u',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                  if (ms.saldoNuevo != null)
                    Text('Quedó ${numeroStock(ms.saldoNuevo!)} $u',
                        style: const TextStyle(
                            fontSize: 12,
                            color: EstiloProduccion.textoSuave)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formulario de un movimiento (entrada, consumo o ajuste).
class _FormMovimiento extends StatefulWidget {
  final RecursoAgro recurso;
  final String tipo;

  const _FormMovimiento({required this.recurso, required this.tipo});

  @override
  State<_FormMovimiento> createState() => _FormMovimientoState();
}

class _FormMovimientoState extends State<_FormMovimiento> {
  final _cantidad = TextEditingController();
  final _motivo = TextEditingController();
  final _notas = TextEditingController();
  String sentido = 'negativo';
  bool guardando = false;
  String? aviso;

  bool get esAjuste => widget.tipo == 'ajuste';

  @override
  void dispose() {
    _cantidad.dispose();
    _motivo.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final cantidad = leerNumero(_cantidad.text);
    if (cantidad == null || cantidad <= 0) {
      setState(() => aviso = 'La cantidad tiene que ser un número mayor a cero.');
      return;
    }
    final resta = widget.tipo == 'consumo' || (esAjuste && sentido == 'negativo');
    if (resta && cantidad > widget.recurso.cantidadActual) {
      setState(() => aviso =
          'No alcanza: hay ${numeroStock(widget.recurso.cantidadActual)} '
          '${unidadCorta(widget.recurso.unidad)}.');
      return;
    }
    if (esAjuste && _motivo.text.trim().isEmpty) {
      setState(() => aviso = 'El ajuste necesita un motivo.');
      return;
    }
    setState(() {
      guardando = true;
      aviso = null;
    });
    try {
      await MovimientoStockService().registrarMovimiento(
        movimiento: MovimientoStock(
          movimientoId: '',
          activoAgroId: widget.recurso.activoAgroId,
          recursoId: widget.recurso.recursoId,
          tipoMovimiento: widget.tipo,
          cantidad: cantidad,
          unidad: widget.recurso.unidad,
          fechaMovimiento: DateTime.now(),
          responsableId: uid,
          motivo: _motivo.text.trim().isEmpty ? null : _motivo.text.trim(),
          sentido: esAjuste ? sentido : null,
          observaciones: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
        ),
        usuarioId: uid,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        guardando = false;
        aviso = mensajeErrorStock(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unidad = nombreUnidadStock(widget.recurso.unidad).toLowerCase();
    final titulo = switch (widget.tipo) {
      'entrada' => 'Entrada (compra o ingreso)',
      'consumo' => 'Consumo (uso en el campo)',
      _ => 'Ajuste (corregir el saldo)',
    };
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(widget.recurso.nombre,
                style: const TextStyle(color: EstiloProduccion.textoSuave)),
            if (esAjuste) ...[
              const EtiquetaCampo('¿Sumar o restar?'),
              OpcionesTocar<String>(
                opciones: const ['positivo', 'negativo'],
                elegida: sentido,
                etiqueta: (s) => s == 'positivo' ? 'Sumar' : 'Restar',
                alElegir: (s) => setState(() => sentido = s),
              ),
            ],
            EtiquetaCampo('Cantidad ($unidad)'),
            TextField(
              controller: _cantidad,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: decoracionCampo(ayuda: 'Ej.: 100'),
            ),
            EtiquetaCampo(esAjuste ? 'Motivo' : 'Motivo (opcional)'),
            TextField(
              controller: _motivo,
              decoration: decoracionCampo(
                ayuda: switch (widget.tipo) {
                  'entrada' => 'Ej.: compra en la cooperativa',
                  'consumo' => 'Ej.: aplicación lote 3',
                  _ => 'Ej.: conteo del galpón',
                },
              ),
            ),
            const EtiquetaCampo('Notas (opcional)'),
            TextField(controller: _notas, decoration: decoracionCampo()),
            if (aviso != null) ...[
              const SizedBox(height: 10),
              Text(aviso!,
                  style: const TextStyle(
                      color: EstiloProduccion.rojo,
                      fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 16),
            BotonGrande(
              texto: 'Guardar',
              ocupado: guardando,
              onPressed: _guardar,
            ),
          ],
        ),
      ),
    );
  }
}
