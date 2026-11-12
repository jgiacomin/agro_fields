import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/movimiento_model.dart';
import '../../services/movimiento_service.dart';
import '../operaciones/operaciones_textos.dart' show Aviso;
import '../produccion/produccion_estilo.dart';
import 'nuevo_traslado_screen.dart';
import 'traslados_textos.dart';

/// AF-089: traslados del campo, con su estado y el control de coherencia
/// (declarado / recibido).
class TrasladosActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const TrasladosActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<TrasladosActivoScreen> createState() => _TrasladosActivoScreenState();
}

class _TrasladosActivoScreenState extends State<TrasladosActivoScreen> {
  final MovimientoService _servicio = MovimientoService();
  bool cargando = true;
  String? error;
  List<Movimiento> lista = [];

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
      final l = await _servicio.delCampo(widget.activoAgroId);
      if (!mounted) return;
      setState(() {
        lista = l;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudieron cargar los traslados: $e';
        cargando = false;
      });
    }
  }

  Future<void> _nuevo() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NuevoTrasladoScreen(activoAgroId: widget.activoAgroId),
      ),
    );
    if (guardo == true) await cargar();
  }

  Future<void> _cambiar(Movimiento m, EstadoMovimiento nuevo) async {
    double? recibida;
    if (nuevo == EstadoMovimiento.entregado) {
      final control = TextEditingController(text: numero(m.cantidadDeclarada));
      final texto = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Cuánto llegó?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Se declararon ${numero(m.cantidadDeclarada)} ${m.unidad}.'),
              const SizedBox(height: 12),
              TextField(
                controller: control,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: decoracionCampo(ayuda: 'Cantidad recibida'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(control.text),
              child: const Text('Marcar entregado'),
            ),
          ],
        ),
      );
      control.dispose();
      if (texto == null) return;
      recibida = double.tryParse(texto.trim().replaceAll(',', '.'));
      if (recibida == null || recibida < 0) {
        _avisar('La cantidad recibida tiene que ser un número.');
        return;
      }
    } else if (nuevo == EstadoMovimiento.cancelado) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cancelar traslado'),
          content: const Text(
              'Queda en la historia como cancelado. Si estaba mal cargado, '
              'cargalo de nuevo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Volver'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cancelar traslado'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    try {
      await _servicio.cambiarEstado(
        movimiento: m,
        nuevo: nuevo,
        usuarioId: FirebaseAuth.instance.currentUser?.uid ?? '',
        cantidadRecibida: recibida,
      );
      await cargar();
    } catch (e) {
      _avisar('No se pudo actualizar: $e');
    }
  }

  void _avisar(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  @override
  Widget build(BuildContext context) {
    final diferencias = lista.where((m) => m.hayDiferencia).toList();
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Traslados'),
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
                        widget.nombreActivo,
                        style: const TextStyle(
                            fontSize: 14, color: EstiloProduccion.textoSuave),
                      ),
                      if (diferencias.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const TituloSeccion('Necesita atención'),
                        for (final m in diferencias)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Aviso(
                              '${m.carga} a ${m.destinoDescripcion}: llegaron '
                              '${numero(m.cantidadRecibida!)} de '
                              '${numero(m.cantidadDeclarada)} ${m.unidad}',
                              grave: true,
                            ),
                          ),
                      ],
                      const SizedBox(height: 16),
                      const TituloSeccion('Traslados del campo'),
                      if (lista.isEmpty)
                        const Text(
                          'Todavía no hay traslados. Cargá cada salida de '
                          'hacienda, granos o colmenas: queda la trazabilidad '
                          'de origen a destino.',
                          style: TextStyle(
                              color: EstiloProduccion.textoSuave, height: 1.4),
                        ),
                      ...lista.map(_tarjeta),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Nuevo traslado',
            onPressed: cargando ? null : _nuevo,
          ),
        ),
      ),
    );
  }

  Widget _tarjeta(Movimiento m) {
    final color = switch (m.estado) {
      EstadoMovimiento.programado => EstiloProduccion.textoSuave,
      EstadoMovimiento.enCamino => EstiloProduccion.terracota,
      EstadoMovimiento.entregado =>
        m.hayDiferencia ? EstiloProduccion.rojo : EstiloProduccion.verde,
      EstadoMovimiento.cancelado => EstiloProduccion.textoSuave,
    };
    final detalle = [
      fechaCorta(m.fechaSalida),
      if (m.transportista != null) m.transportista!,
      if (m.patente != null) m.patente!,
      if (m.guia != null) 'Guía ${m.guia}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        colorBorde: m.hayDiferencia ? EstiloProduccion.rojo : EstiloProduccion.borde,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${numero(m.cantidadDeclarada)} ${m.unidad} · ${m.carga}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    nombreEstadoMovimiento(m.estado),
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('A: ${m.destinoDescripcion}',
                  style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 2),
              Text(detalle,
                  style: const TextStyle(
                      fontSize: 13, color: EstiloProduccion.textoSuave)),
              if (m.cantidadRecibida != null) ...[
                const SizedBox(height: 4),
                Text(
                  m.hayDiferencia
                      ? 'Llegaron ${numero(m.cantidadRecibida!)} '
                          '(${m.diferencia! > 0 ? '+' : ''}${numero(m.diferencia!)})'
                      : 'Llegó completo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: m.hayDiferencia
                        ? EstiloProduccion.rojo
                        : EstiloProduccion.verde,
                  ),
                ),
              ],
              if (!m.terminado) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    if (m.estado == EstadoMovimiento.programado)
                      OutlinedButton(
                        onPressed: () => _cambiar(m, EstadoMovimiento.enCamino),
                        child: const Text('Marcar en camino'),
                      ),
                    ElevatedButton(
                      onPressed: () => _cambiar(m, EstadoMovimiento.entregado),
                      child: const Text('Marcar entregado'),
                    ),
                    TextButton(
                      onPressed: () => _cambiar(m, EstadoMovimiento.cancelado),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
