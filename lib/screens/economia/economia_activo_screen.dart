import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/gasto_model.dart';
import '../../services/calculo_economia.dart';
import '../../services/gasto_service.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';
import 'economia_textos.dart';
import 'nuevo_gasto_screen.dart';

/// GAP-ECO-01 (13/11/2026): la economía del campo, mes a mes.
/// Total del mes (separado por moneda), en qué se gastó, por actividad y
/// la lista de gastos. No es contabilidad.
class EconomiaActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const EconomiaActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<EconomiaActivoScreen> createState() => _EconomiaActivoScreenState();
}

class _EconomiaActivoScreenState extends State<EconomiaActivoScreen> {
  final GastoService _servicio = GastoService();
  bool cargando = true;
  String? error;
  List<Gasto> gastos = [];
  String mes = mesDe(DateTime.now());

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
      final lista = await _servicio.gastosDeActivo(widget.activoAgroId);
      if (!mounted) return;
      setState(() {
        gastos = lista;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString().contains('permission-denied')
            ? 'No tenés permiso para ver la economía de este campo.'
            : 'No se pudo cargar: $e';
        cargando = false;
      });
    }
  }

  Future<void> _nuevo({Gasto? corrige}) async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NuevoGastoScreen(
          activoAgroId: widget.activoAgroId,
          corrige: corrige,
        ),
      ),
    );
    if (guardo == true) await cargar();
  }

  @override
  Widget build(BuildContext context) {
    final r = resumenDelMes(gastos, mes);
    final esteMes = mesDe(DateTime.now());
    return Scaffold(
      appBar: BarraCampo(title: const Text('Economía')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error!, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargar,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      Text(
                        widget.nombreActivo,
                        style: const TextStyle(
                            fontSize: 14, color: EstiloProduccion.textoSuave),
                      ),
                      const SizedBox(height: 8),
                      _selectorMes(esteMes),
                      const SizedBox(height: 12),
                      if (r.vacio)
                        const EstadoVacio(
                          icono: Icons.payments_outlined,
                          texto: 'No hay gastos en este mes. Tocá "+ Gasto" '
                              'para cargar el primero: gasoil, semilla, '
                              'sueldos, fletes...',
                        )
                      else ...[
                        ResumenNumeros([
                          for (final m in monedasGasto)
                            if (r.totalPorMoneda.containsKey(m))
                              (
                                formatoMonto(r.totalPorMoneda[m]!, m),
                                'gastado en ${nombreMoneda(m).toLowerCase()}',
                                Icons.payments_outlined,
                                m == 'USD'
                                    ? AgroTema.verde
                                    : AgroTema.terracota,
                              ),
                        ]),
                        const SizedBox(height: 20),
                        const TituloSeccion('En qué se gastó',
                            icono: Icons.pie_chart_outline),
                        for (final m in monedasGasto)
                          if (r.porCategoria.containsKey(m))
                            _barras(m, r.porCategoria[m]!,
                                varias: r.totalPorMoneda.length > 1),
                        const SizedBox(height: 16),
                        const TituloSeccion('Por actividad',
                            icono: Icons.agriculture),
                        for (final m in monedasGasto)
                          if (r.porActividad.containsKey(m))
                            _actividades(m, r.porActividad[m]!),
                        const SizedBox(height: 16),
                        TituloSeccion(
                            'Gastos de ${nombreMes(mes).split(' ').first.toLowerCase()}',
                            icono: Icons.receipt_long_outlined),
                        ...r.gastos.map(_tarjeta),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Gasto',
            icono: Icons.payments_outlined,
            onPressed: cargando || error != null ? null : () => _nuevo(),
          ),
        ),
      ),
    );
  }

  Widget _selectorMes(String esteMes) {
    return TarjetaBlanca(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => mes = moverMes(mes, -1)),
          ),
          Expanded(
            child: Text(
              nombreMes(mes),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: mes == esteMes
                ? null
                : () => setState(() => mes = moverMes(mes, 1)),
          ),
        ],
      ),
    );
  }

  Widget _barras(String moneda, Map<String, double> porCat,
      {required bool varias}) {
    final filas = porCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maximo = filas.first.value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (varias)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(nombreMoneda(moneda),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: EstiloProduccion.textoSuave)),
                ),
              for (final f in filas)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(iconoCategoriaGasto(f.key),
                              size: 18, color: colorCategoriaGasto(f.key)),
                          const SizedBox(width: 6),
                          Expanded(child: Text(nombreCategoriaGasto(f.key))),
                          Text(formatoMonto(f.value, moneda),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: maximo == 0 ? 0 : f.value / maximo,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFF1E8D9),
                          color: colorCategoriaGasto(f.key),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actividades(String moneda, Map<String, double> porAct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final a in actividadesGasto)
            if (porAct.containsKey(a))
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAF2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE6D6BC)),
                ),
                child: Text(
                  '${nombreActividadGasto(a)}: '
                  '${formatoMonto(porAct[a]!, moneda)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
        ],
      ),
    );
  }

  Widget _tarjeta(Gasto g) {
    final detalle = [
      nombreActividadGasto(g.actividad),
      if (g.proveedor != null) g.proveedor!,
      if (g.descripcion != null) g.descripcion!,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: [
              IconoCirculo(iconoCategoriaGasto(g.categoria),
                  color: colorCategoriaGasto(g.categoria), tamano: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${nombreCategoriaGasto(g.categoria)} · '
                      '${fechaCorta(g.fecha)}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(detalle,
                        style: const TextStyle(
                            fontSize: 13, color: EstiloProduccion.textoSuave)),
                    if (g.comprobanteRuta != null)
                      const Text('Con comprobante',
                          style: TextStyle(
                              fontSize: 12, color: EstiloProduccion.verde)),
                    if (g.esCorreccion)
                      const Text('Corregido',
                          style: TextStyle(
                              fontSize: 12,
                              color: EstiloProduccion.terracota)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatoMonto(g.monto, g.moneda),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  TextButton(
                    onPressed: () => _nuevo(corrige: g),
                    child: const Text('Corregir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
