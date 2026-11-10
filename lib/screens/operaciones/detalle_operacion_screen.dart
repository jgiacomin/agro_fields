import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/activos/evento_operacion_model.dart';
import '../../models/activos/operacion_protegida_model.dart';
import '../../services/control_operacion.dart';
import '../../services/documento_archivo_service.dart';
import '../../services/operacion_service.dart';
import '../../widgets/adjuntar_archivo_boton.dart';
import '../produccion/produccion_estilo.dart';
import 'operaciones_textos.dart';
import 'registrar_evento_operacion_screen.dart';

/// Pantalla 3 (paso 7a-3, GAP-OPER-01): el detalle de una operacion.
/// Arriba, la lista de control antes de entregar ("X de 7").
/// Despues, los cheques y pagos con su estado, las cuentas y la historia.
class DetalleOperacionScreen extends StatefulWidget {
  final OperacionProtegida operacion;

  const DetalleOperacionScreen({super.key, required this.operacion});

  @override
  State<DetalleOperacionScreen> createState() => _DetalleOperacionScreenState();
}

class _DetalleOperacionScreenState extends State<DetalleOperacionScreen> {
  final OperacionService _servicio = OperacionService();
  final DocumentoArchivoService _archivos = DocumentoArchivoService();

  late OperacionProtegida op = widget.operacion;
  bool cargando = true;
  String? error;
  List<EventoOperacion> eventos = [];
  ResultadoOperacion? resultado;

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
      final lista = await _servicio.eventosDeOperacion(
        activoAgroId: op.activoAgroId,
        operacionId: op.operacionId,
      );
      if (!mounted) return;
      setState(() {
        eventos = lista;
        resultado = calcularOperacion(op, lista);
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudo cargar la operación: $e';
        cargando = false;
      });
    }
  }

  Future<void> registrar({TipoEventoOperacion? tipo, String? pagoId}) async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RegistrarEventoOperacionScreen(
          operacion: op,
          pagos: resultado?.pagos ?? const [],
          tipoInicial: tipo,
          pagoInicialId: pagoId,
        ),
      ),
    );
    if (guardo == true) await cargar();
  }

  /// Guarda un cambio de la operacion (archivo adjunto, garantia...).
  /// Solo mientras esta en curso (las reglas tambien lo exigen).
  Future<void> corregir(Map<String, dynamic> cambios) async {
    final nueva = OperacionProtegida.fromMap(
      {...op.toMap(), ...cambios},
      op.operacionId,
    );
    try {
      await _servicio.corregirOperacion(nueva);
      if (!mounted) return;
      setState(() {
        op = nueva;
        resultado = calcularOperacion(op, eventos);
      });
    } catch (e) {
      _avisar('No se pudo guardar: $e');
    }
  }

  Future<String> subir(String nombre, Uint8List bytes, String tipo) {
    return _archivos.subirArchivoOperacion(
      activoId: op.activoAgroId,
      operacionId: op.operacionId,
      nombreArchivo: nombre,
      bytes: bytes,
      contentType: tipo,
    );
  }

  Future<void> agregarGarantia() async {
    final garantia = await showModalBottomSheet<GarantiaOperacion>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => _HojaGarantia(moneda: op.moneda),
    );
    if (garantia == null) return;
    await corregir({
      'garantias': [
        ...op.garantias.map((g) => g.toMap()),
        garantia.toMap(),
      ],
    });
  }

  Future<void> cerrar() async {
    final estado = await showDialog<EstadoOperacion>(
      context: context,
      builder: (contexto) => SimpleDialog(
        title: const Text('¿Cómo terminó la operación?'),
        children: [
          for (final e in [
            EstadoOperacion.cumplida,
            EstadoOperacion.conIncumplimiento,
            EstadoOperacion.cancelada,
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.of(contexto).pop(e),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(nombreEstadoOperacion(e),
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              'Una vez cerrada no se puede corregir. Se puede seguir '
              'registrando lo que pase (salvo si se cancela).',
              style: TextStyle(fontSize: 13, color: EstiloProduccion.textoSuave),
            ),
          ),
        ],
      ),
    );
    if (estado == null) return;

    try {
      final fecha = DateTime.now();
      await _servicio.cerrarOperacion(
        operacionId: op.operacionId,
        estado: estado,
        fechaCierre: fecha,
      );
      if (!mounted) return;
      setState(() {
        op = OperacionProtegida.fromMap(
          {...op.toMap(), 'estado': estado.name, 'fechaCierre': fecha},
          op.operacionId,
        );
      });
    } catch (e) {
      _avisar('No se pudo cerrar: $e');
    }
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final puedeRegistrar = op.estado != EstadoOperacion.cancelada;

    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: Text(op.comprador.nombre, overflow: TextOverflow.ellipsis),
        actions: [
          if (op.estaEnCurso)
            TextButton(onPressed: cerrar, child: const Text('Cerrar')),
        ],
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
                      _encabezado(),
                      const SizedBox(height: 20),
                      _listaControl(),
                      const SizedBox(height: 24),
                      _pagos(),
                      const SizedBox(height: 24),
                      _cuentas(),
                      if (resultado!.hayDiscrepancias) ...[
                        const SizedBox(height: 16),
                        for (final d in resultado!.discrepancias)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Aviso('Para revisar: ${d.descripcion}',
                                grave: true),
                          ),
                      ],
                      const SizedBox(height: 24),
                      _historia(),
                      const LeyendaNoGarantia(),
                    ],
                  ),
                ),
      bottomNavigationBar: puedeRegistrar && !cargando && error == null
          ? SafeArea(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: BotonGrande(
                  texto: '+ Registrar lo que pasó',
                  onPressed: () => registrar(),
                ),
              ),
            )
          : null,
    );
  }

  Widget _encabezado() {
    final cantidad = op.cantidad == null
        ? ''
        : ' · ${numeroSimple(op.cantidad!)} ${op.unidad ?? ''}';
    final producto = op.producto == ProductoOperacion.otro
        ? (op.descripcionProducto ?? 'Otro')
        : nombreProducto(op.producto);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatoImporte(op.importe, op.moneda),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '$producto$cantidad · ${nombreFormaPago(op.formaPago)} · '
          '${nombreEstadoOperacion(op.estado)}',
          style: const TextStyle(
            fontSize: 15,
            color: EstiloProduccion.textoSuave,
          ),
        ),
      ],
    );
  }

  Widget _listaControl() {
    final r = resultado!;
    final completo = r.puntosCompletos == r.puntosTotales;

    return TarjetaBlanca(
      colorBorde: completo ? EstiloProduccion.verde : amarilloBorde,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antes de entregar: ${r.puntosCompletos} de ${r.puntosTotales}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: completo ? EstiloProduccion.verde : amarillo,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Revisa tu operación, no al comprador.',
              style: TextStyle(fontSize: 13, color: EstiloProduccion.textoSuave),
            ),
            const SizedBox(height: 12),
            for (final item in r.listaControl) _itemControl(item),
          ],
        ),
      ),
    );
  }

  Widget _itemControl(ItemControl item) {
    Widget? accion;
    if (op.estaEnCurso && !item.completo) {
      switch (item.punto) {
        case PuntoControl.poderFirmante:
          accion = AdjuntarArchivoBoton(
            texto: 'Adjuntar poder o estatuto',
            subir: subir,
            alSubir: (ruta) => corregir({
              'comprador': {
                ...op.comprador.toMap(),
                'facultadArchivoRuta': ruta,
              },
            }),
          );
          break;
        case PuntoControl.contrato:
          accion = AdjuntarArchivoBoton(
            texto: 'Adjuntar contrato o boleto',
            subir: subir,
            alSubir: (ruta) => corregir({'contratoArchivoRuta': ruta}),
          );
          break;
        case PuntoControl.garantia:
          accion = OutlinedButton.icon(
            onPressed: agregarGarantia,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Agregar garantía'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              alignment: Alignment.centerLeft,
            ),
          );
          break;
        case PuntoControl.pagosCubrenImporte:
          accion = OutlinedButton.icon(
            onPressed: () =>
                registrar(tipo: TipoEventoOperacion.pagoAcordado),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Cargar cheque o pago'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              alignment: Alignment.centerLeft,
            ),
          );
          break;
        default:
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.completo ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: item.completo
                    ? EstiloProduccion.verde
                    : EstiloProduccion.textoSuave,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.descripcion,
                        style: const TextStyle(fontSize: 15)),
                    if (item.queFalta != null)
                      Text(
                        item.queFalta!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: EstiloProduccion.textoSuave,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (accion != null)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 8),
              child: accion,
            ),
        ],
      ),
    );
  }

  Widget _pagos() {
    final pagos = resultado!.pagos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloSeccion('Cheques y pagos'),
        if (pagos.isEmpty)
          const Text(
            'Todavía no hay cheques ni pagos cargados.',
            style: TextStyle(color: EstiloProduccion.textoSuave),
          ),
        for (final p in pagos)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TarjetaBlanca(
              colorBorde: p.requiereAtencion
                  ? colorEstadoPago(p.estado)
                  : EstiloProduccion.borde,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatoImporte(p.importe, op.moneda),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          nombreEstadoPago(p.estado),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorEstadoPago(p.estado),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${nombreMedioPago(p.pago.medioPago ?? MedioPago.otro)}'
                      '${p.pago.numero == null ? '' : ' Nº ${p.pago.numero}'}'
                      '${p.pago.banco == null ? '' : ' · ${p.pago.banco}'}'
                      ' · vence ${fechaCorta(p.pago.fechaVencimiento!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: EstiloProduccion.textoSuave,
                      ),
                    ),
                    if (p.cobrado > 0 && p.estado != EstadoPago.cobrado)
                      Text(
                        'Cobrado ${formatoImporte(p.cobrado, op.moneda)} · '
                        'falta ${formatoImporte(p.falta, op.moneda)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    if (p.motivoRechazo != null)
                      Text(
                        'Motivo: ${p.motivoRechazo}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: EstiloProduccion.rojo,
                        ),
                      ),
                    if (p.estado != EstadoPago.cobrado &&
                        op.estado != EstadoOperacion.cancelada) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => registrar(
                                tipo: TipoEventoOperacion.cobro,
                                pagoId: p.pago.eventoId,
                              ),
                              child: const Text('Se cobró'),
                            ),
                          ),
                          if (p.estado != EstadoPago.rechazado) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => registrar(
                                  tipo: TipoEventoOperacion.rechazo,
                                  pagoId: p.pago.eventoId,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: EstiloProduccion.rojo,
                                ),
                                child: const Text('Rebotó'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _cuentas() {
    final r = resultado!;
    Widget fila(String nombre, String valor, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text(nombre, style: const TextStyle(fontSize: 15))),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color ?? EstiloProduccion.texto,
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloSeccion('Cuentas'),
        TarjetaBlanca(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                fila('Importe de la operación',
                    formatoImporte(r.importeOperacion, op.moneda)),
                fila('Cheques y pagos cargados',
                    formatoImporte(r.totalAcordado, op.moneda)),
                fila('Cobrado', formatoImporte(r.totalCobrado, op.moneda),
                    color: EstiloProduccion.verde),
                if (r.totalRechazado > 0)
                  fila('Rechazado',
                      formatoImporte(r.totalRechazado, op.moneda),
                      color: EstiloProduccion.rojo),
                fila('Falta cobrar', formatoImporte(r.faltaCobrar, op.moneda)),
                if (r.sinPagoAcordado > 0)
                  fila('Sin cheque ni pago cargado',
                      formatoImporte(r.sinPagoAcordado, op.moneda),
                      color: amarillo),
                if (r.totalEntregado > 0 || op.cantidad != null)
                  fila(
                    'Entregado',
                    '${numeroSimple(r.totalEntregado)}'
                        '${op.cantidad == null ? '' : ' de ${numeroSimple(op.cantidad!)}'}'
                        ' ${op.unidad ?? ''}',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _historia() {
    final ordenados = [...eventos]
      ..sort((a, b) => b.fechaHecho.compareTo(a.fechaHecho));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloSeccion('Historia'),
        if (ordenados.isEmpty)
          const Text(
            'Todavía no hay nada registrado.',
            style: TextStyle(color: EstiloProduccion.textoSuave),
          ),
        for (final e in ordenados)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 86,
                  child: Text(
                    fechaCorta(e.fechaHecho),
                    style: const TextStyle(
                      fontSize: 13,
                      color: EstiloProduccion.textoSuave,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _resumenEvento(e),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _resumenEvento(EventoOperacion e) {
    final base = nombreTipoEventoOperacion(e.tipo);
    final partes = <String>[base];
    if (e.importe != null) partes.add(formatoImporte(e.importe!, op.moneda));
    if (e.cantidad != null) {
      partes.add('${numeroSimple(e.cantidad!)} ${e.unidad ?? ''}');
    }
    if (e.motivoRechazo != null) partes.add(e.motivoRechazo!);
    if (e.observaciones != null) partes.add(e.observaciones!);
    if (e.archivoRutas.isNotEmpty) {
      partes.add(e.archivoRutas.length == 1
          ? '1 archivo'
          : '${e.archivoRutas.length} archivos');
    }
    return partes.join(' · ');
  }
}

/// Hoja para agregar una garantia (aval, SGR, seguro).
class _HojaGarantia extends StatefulWidget {
  final String moneda;

  const _HojaGarantia({required this.moneda});

  @override
  State<_HojaGarantia> createState() => _HojaGarantiaState();
}

class _HojaGarantiaState extends State<_HojaGarantia> {
  final TextEditingController _emisor = TextEditingController();
  final TextEditingController _importe = TextEditingController();
  TipoGarantia? tipo;

  @override
  void dispose() {
    _emisor.dispose();
    _importe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agregar garantía',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const EtiquetaCampo('Tipo'),
          OpcionesTocar<TipoGarantia>(
            opciones: TipoGarantia.values,
            elegida: tipo,
            etiqueta: nombreTipoGarantia,
            alElegir: (t) => setState(() => tipo = t),
          ),
          const EtiquetaCampo('¿Quién la da? (banco, SGR, aseguradora)'),
          TextField(controller: _emisor, decoration: decoracionCampo()),
          EtiquetaCampo('Importe cubierto (${widget.moneda}, opcional)'),
          TextField(
            controller: _importe,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoracionCampo(),
          ),
          const SizedBox(height: 20),
          BotonGrande(
            texto: 'Agregar',
            onPressed: tipo == null
                ? null
                : () => Navigator.of(context).pop(GarantiaOperacion(
                      tipo: tipo!,
                      emisor: _emisor.text.trim().isEmpty
                          ? null
                          : _emisor.text.trim(),
                      importe: leerNumero(_importe.text),
                    )),
          ),
        ],
      ),
    );
  }
}
