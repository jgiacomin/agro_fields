import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/permisos_encargado.dart';
import '../../services/encargado_service.dart';
import '../../widgets/barra_campo.dart';
import '../economia/economia_activo_screen.dart';
import '../produccion/produccion_activo_screen.dart';
import '../produccion/produccion_estilo.dart';
import '../stock/stock_activo_screen.dart';
import '../territorio/historia_territorio_screen.dart';
import '../traslados/traslados_activo_screen.dart';

/// GAP-ENC-01: campos donde el usuario es encargado. El nombre del campo
/// viene en la invitación (el encargado no lee el expediente privado).
class CamposEncargadoScreen extends StatefulWidget {
  const CamposEncargadoScreen({super.key});

  @override
  State<CamposEncargadoScreen> createState() => _CamposEncargadoScreenState();
}

class _CamposEncargadoScreenState extends State<CamposEncargadoScreen> {
  final EncargadoService _servicio = EncargadoService();
  bool cargando = true;
  String? error;
  List<EncargadoDelCampo> campos = [];

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
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final l = await _servicio.camposComoEncargado(uid);
      if (!mounted) return;
      setState(() {
        campos = l;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudieron cargar los campos: $e';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(title: const Text('Soy encargado')),
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
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (campos.isEmpty)
                        const EstadoVacio(
                          icono: Icons.engineering_outlined,
                          texto: 'Todavía no te invitaron a ningún campo. '
                              'Pasale tu código al dueño (Menú → Mi código).',
                        ),
                      for (final c in campos)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TarjetaBlanca(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CampoEncargadoScreen(campo: c),
                              ),
                            ),
                            child: FilaConIcono(
                              icono: Icons.grass,
                              color: EstiloProduccion.verde,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.nombreActivo,
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(c.areas.map(nombreArea).join(' · '),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: EstiloProduccion.textoSuave)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

/// Un campo visto por su encargado: solo los botones de lo habilitado.
/// Abre las mismas pantallas que usa el dueño.
class CampoEncargadoScreen extends StatelessWidget {
  final EncargadoDelCampo campo;
  const CampoEncargadoScreen({super.key, required this.campo});

  Widget _pantalla(AreaEncargado area) {
    final id = campo.activoId;
    final nombre = campo.nombreActivo;
    switch (area) {
      case AreaEncargado.produccion:
        return ProduccionActivoScreen(activoAgroId: id, nombreActivo: nombre);
      case AreaEncargado.stock:
        return StockActivoScreen(activoAgroId: id, nombreActivo: nombre);
      case AreaEncargado.gastos:
        return EconomiaActivoScreen(activoAgroId: id, nombreActivo: nombre);
      case AreaEncargado.traslados:
        return TrasladosActivoScreen(activoAgroId: id, nombreActivo: nombre);
      case AreaEncargado.territorio:
        return HistoriaTerritorioScreen(activoAgroId: id, nombreActivo: nombre);
    }
  }

  @override
  Widget build(BuildContext context) {
    final areas =
        AreaEncargado.values.where(campo.areas.contains).toList();
    return Scaffold(
      appBar: BarraCampo(title: Text(campo.nombreActivo)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Sos encargado de este campo. Esto es lo que podés cargar:',
            style: TextStyle(color: EstiloProduccion.textoSuave, height: 1.4),
          ),
          const SizedBox(height: 16),
          for (final area in areas)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TarjetaBlanca(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _pantalla(area)),
                ),
                child: FilaConIcono(
                  icono: iconoArea(area),
                  color: EstiloProduccion.verde,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombreArea(area),
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600)),
                        Text(ayudaArea(area),
                            style: const TextStyle(
                                fontSize: 13,
                                color: EstiloProduccion.textoSuave)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
