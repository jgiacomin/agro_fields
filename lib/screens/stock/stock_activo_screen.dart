import 'package:flutter/material.dart';

import '../../models/activos/recurso_agro_model.dart';
import '../../services/recurso_service.dart';
import '../produccion/produccion_estilo.dart';
import 'detalle_recurso_screen.dart';
import 'nuevo_recurso_screen.dart';
import 'stock_textos.dart';
import '../../widgets/barra_campo.dart';

/// GAP-STOCK-01 (13/11/2026): el stock del campo.
/// Lista de productos con su saldo; los que están en el mínimo o debajo
/// aparecen primero y en rojo.
class StockActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const StockActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<StockActivoScreen> createState() => _StockActivoScreenState();
}

class _StockActivoScreenState extends State<StockActivoScreen> {
  final RecursoService _servicio = RecursoService();
  bool cargando = true;
  String? error;
  List<RecursoAgro> productos = [];

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
      final lista =
          await _servicio.obtenerRecursosPorActivo(widget.activoAgroId);
      lista.sort((a, b) {
        if (a.stockBajo != b.stockBajo) return a.stockBajo ? -1 : 1;
        return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      });
      if (!mounted) return;
      setState(() {
        productos = lista;
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

  Future<void> _nuevo() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NuevoRecursoScreen(activoAgroId: widget.activoAgroId),
      ),
    );
    if (guardo == true) await cargar();
  }

  Future<void> _abrir(RecursoAgro r) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetalleRecursoScreen(recurso: r)),
    );
    await cargar();
  }

  @override
  Widget build(BuildContext context) {
    final bajos = productos.where((p) => p.stockBajo).length;
    return Scaffold(
      appBar: BarraCampo(
        title: const Text('Stock e insumos'),
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
                        widget.nombreActivo,
                        style: const TextStyle(
                            fontSize: 14, color: EstiloProduccion.textoSuave),
                      ),
                      const SizedBox(height: 12),
                      if (bajos > 0) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: EstiloProduccion.rojoFondo,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: EstiloProduccion.rojoBorde),
                          ),
                          child: Text(
                            bajos == 1
                                ? '1 producto con stock bajo.'
                                : '$bajos productos con stock bajo.',
                            style: const TextStyle(
                                color: EstiloProduccion.rojo,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (productos.isEmpty)
                        const EstadoVacio(
                          icono: Icons.inventory_2_outlined,
                          texto: 'Todavía no hay productos. Cargá lo que '
                              'tenés en el galpón: semillas, agroquímicos, '
                              'vacunas, gasoil. Cada entrada y cada uso queda '
                              'registrado.',
                        ),
                      ...productos.map(_tarjeta),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Producto',
            onPressed: cargando ? null : _nuevo,
          ),
        ),
      ),
    );
  }

  Widget _tarjeta(RecursoAgro r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        colorBorde: r.stockBajo
            ? EstiloProduccion.rojoBorde
            : EstiloProduccion.borde,
        onTap: () => _abrir(r),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconoCirculo(
                iconoTipoRecurso(r.tipo),
                color: r.stockBajo
                    ? EstiloProduccion.rojo
                    : EstiloProduccion.verde,
                tamano: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.nombre,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(
                      nombreTipoRecurso(r.tipo),
                      style: const TextStyle(
                          fontSize: 13, color: EstiloProduccion.textoSuave),
                    ),
                    if (r.stockBajo)
                      Text(
                        'Stock bajo (mínimo ${numeroStock(r.cantidadMinima)} '
                        '${unidadCorta(r.unidad)})',
                        style: const TextStyle(
                            fontSize: 13,
                            color: EstiloProduccion.rojo,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              Text(
                '${numeroStock(r.cantidadActual)} ${unidadCorta(r.unidad)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: r.stockBajo
                      ? EstiloProduccion.rojo
                      : EstiloProduccion.texto,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: EstiloProduccion.textoSuave),
            ],
          ),
        ),
      ),
    );
  }
}
