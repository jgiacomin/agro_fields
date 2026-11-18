import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/busqueda_lugar.dart';
import '../../widgets/barra_campo.dart';

/// AF-090 (12/11/2026): marcar la ubicación del campo en el mapa.
/// Una pantalla, una pregunta: "¿Dónde está tu campo?".
/// Mapa de OpenStreetMap (gratis, sin clave). La ubicación exacta es
/// privada: no se muestra en el marketplace.
///
/// QA (18/11/2026): para no buscar el campo a mano, el mapa arranca en la
/// localidad cargada al crear el campo, y arriba hay una cajita para
/// buscar otro pueblo o pegar coordenadas / un link de Google Maps.
class UbicacionActivoScreen extends StatefulWidget {
  final ActivoAgroV2 activo;

  const UbicacionActivoScreen({super.key, required this.activo});

  @override
  State<UbicacionActivoScreen> createState() => _UbicacionActivoScreenState();
}

class _UbicacionActivoScreenState extends State<UbicacionActivoScreen> {
  final ActivoAgroServiceV2 _activos = ActivoAgroServiceV2();
  final MapController _mapa = MapController();
  final TextEditingController _busqueda = TextEditingController();

  /// Centro inicial si el campo todavía no tiene punto:
  /// entre Argentina y Paraguay (mercados iniciales).
  static const LatLng _centroInicial = LatLng(-27.5, -60.0);

  LatLng? punto;
  bool guardando = false;
  bool buscando = false;

  @override
  void initState() {
    super.initState();
    final u = widget.activo.ubicacion;
    if (u.tieneCoordenadas) {
      punto = LatLng(u.latitud, u.longitud);
    }
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  /// Al abrir el mapa sin punto marcado: ir a la localidad del campo.
  Future<void> _alAbrirMapa() async {
    if (punto != null) return;
    final u = widget.activo.ubicacion;
    final consulta = consultaDesdeUbicacion(
      localidad: u.localidad,
      departamento: u.departamento,
      provincia: u.provincia,
      pais: u.pais,
    );
    if (consulta.isEmpty) return;
    setState(() => buscando = true);
    final lugar = await buscarLugar(consulta);
    if (!mounted) return;
    setState(() => buscando = false);
    if (lugar != null && punto == null) _mapa.move(lugar, 12);
  }

  /// Cajita de arriba: primero prueba si son coordenadas o un link; si no,
  /// busca el pueblo por nombre.
  Future<void> _buscar() async {
    final texto = _busqueda.text.trim();
    if (texto.isEmpty || buscando) return;
    FocusScope.of(context).unfocus();

    final coordenadas = coordenadasDesdeTexto(texto);
    if (coordenadas != null) {
      setState(() => punto = coordenadas);
      _mapa.move(coordenadas, 14);
      return;
    }

    setState(() => buscando = true);
    final lugar = await buscarLugar(texto);
    if (!mounted) return;
    setState(() => buscando = false);
    if (lugar != null) {
      _mapa.move(lugar, 12);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No encontré ese lugar. Probá con el pueblo y la '
            'provincia, o pegá las coordenadas. Los links cortos '
            '(maps.app.goo.gl) no traen las coordenadas: abrilo y copiá '
            'los números.'),
      ));
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
      appBar: BarraCampo(title: const Text('¿Dónde está tu campo?')),
      body: Column(
        children: [
          // QA T1-03 (18/11/2026): botón "Buscar" a la vista (la lupa
          // dentro de la cajita quedaba escondida en pantallas angostas).
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _busqueda,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _buscar(),
                    decoration: InputDecoration(
                      hintText: 'Pueblo, coordenadas o link de Google Maps',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: buscando ? null : _buscar,
                    icon: buscando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Buscar'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Text(
              p == null
                  ? 'Tocá el mapa donde está el campo (o buscá arriba). '
                      'Después, "Guardar ubicación".'
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
              mapController: _mapa,
              options: MapOptions(
                onMapReady: _alAbrirMapa,
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
