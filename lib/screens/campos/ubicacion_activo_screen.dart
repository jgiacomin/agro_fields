import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';

/// AF-090 (12/11/2026): marcar la ubicación del campo en el mapa.
/// Una pantalla, una pregunta: "¿Dónde está tu campo?".
/// Mapa de OpenStreetMap (gratis, sin clave). La ubicación exacta es
/// privada: no se muestra en el marketplace.
class UbicacionActivoScreen extends StatefulWidget {
  final ActivoAgroV2 activo;

  const UbicacionActivoScreen({super.key, required this.activo});

  @override
  State<UbicacionActivoScreen> createState() => _UbicacionActivoScreenState();
}

class _UbicacionActivoScreenState extends State<UbicacionActivoScreen> {
  final ActivoAgroServiceV2 _activos = ActivoAgroServiceV2();

  /// Centro inicial si el campo todavía no tiene punto:
  /// entre Argentina y Paraguay (mercados iniciales).
  static const LatLng _centroInicial = LatLng(-27.5, -60.0);

  LatLng? punto;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    final u = widget.activo.ubicacion;
    if (u.tieneCoordenadas) {
      punto = LatLng(u.latitud, u.longitud);
    }
  }

  Future<void> _guardar() async {
    final p = punto;
    if (p == null || guardando) return;
    setState(() => guardando = true);
    try {
      await _activos.actualizarUbicacion(
        widget.activo.activoId,
        p.latitude,
        p.longitude,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = punto;
    return Scaffold(
      appBar: AppBar(title: const Text('¿Dónde está tu campo?')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Text(
              p == null
                  ? 'Acercá el mapa y tocá donde está el campo.'
                  : 'Punto marcado: ${p.latitude.toStringAsFixed(5)}, '
                      '${p.longitude.toStringAsFixed(5)}. '
                      'Si no es ahí, tocá otro lugar.',
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AgroTema.pizarra,
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: p ?? _centroInicial,
                initialZoom: p == null ? 5 : 14,
                onTap: (_, nuevo) => setState(() => punto = nuevo),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.agrofields.app',
                ),
                if (p != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: p,
                        width: 48,
                        height: 48,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on,
                          size: 48,
                          color: AgroTema.terracota,
                        ),
                      ),
                    ],
                  ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: p == null || guardando ? null : _guardar,
              icon: guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text(
                'Guardar ubicación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
