import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_publico_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/foto_mercado_service.dart';
import '../produccion/produccion_activo_screen.dart' show nombreActividad;
import '../produccion/produccion_estilo.dart';
import 'detalle_activo_agro_screen.dart' show emojiActividad;
import 'detalle_campo_screen.dart';
import '../../widgets/barra_campo.dart';

/// Mercado de campos (lista de campos aprobados).
/// GAP-MERC-01 Parte D (24/11/2026): diseño nuevo con foto, precio sobre
/// la foto, filtro por operación y tarjeta que se toca entera.
class CamposScreen extends StatefulWidget {
  const CamposScreen({super.key});

  @override
  State<CamposScreen> createState() => _CamposScreenState();
}

class _CamposScreenState extends State<CamposScreen> {
  final ActivoAgroServiceV2 _service = ActivoAgroServiceV2();
  late Future<List<ActivoPublico>> _campos;

  /// null = Todos; si no, 'venta' | 'alquiler' | 'arrendamiento'.
  String? _filtro;

  @override
  void initState() {
    super.initState();
    _campos = _service.obtenerActivosPublicados();
  }

  Future<void> _recargar() async {
    setState(() => _campos = _service.obtenerActivosPublicados());
    await _campos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgroTema.crema,
      appBar: BarraCampo(
        title: const Text("Mercado de campos"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ActivoPublico>>(
        future: _campos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: EstadoVacio(
                icono: Icons.wifi_off,
                texto: "No se pudo cargar el Mercado: ${snapshot.error}",
              ),
            );
          }
          final todos = snapshot.data ?? const <ActivoPublico>[];
          final filtrados = _filtro == null
              ? todos
              : todos
                  .where((c) => c.ofertas.any((o) => o.operacion == _filtro))
                  .toList();

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _filtros(),
                const SizedBox(height: 14),
                if (filtrados.isEmpty)
                  EstadoVacio(
                    icono: Icons.storefront,
                    texto: todos.isEmpty
                        ? "Todavía no hay campos publicados."
                        : "No hay campos con esa operación.",
                  ),
                for (final campo in filtrados) _TarjetaCampo(campo: campo),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filtros() {
    const opciones = [
      (null, "Todos"),
      ('venta', "Venta"),
      ('alquiler', "Alquiler"),
      ('arrendamiento', "Arrendamiento"),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (valor, texto) in opciones)
          ChoiceChip(
            label: Text(texto),
            selected: _filtro == valor,
            showCheckmark: false,
            selectedColor: AgroTema.terracota,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AgroTema.borde),
            labelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _filtro == valor ? Colors.white : AgroTema.pizarra,
            ),
            onSelected: (_) => setState(() => _filtro = valor),
          ),
      ],
    );
  }
}

/// GAP-MERC-01 H (25/11/2026): "Publicado hoy", "Publicado ayer",
/// "Publicado hace 5 días", "hace 3 meses"...
String publicadoHace(DateTime fecha, [DateTime? ahora]) {
  final hoy = ahora ?? DateTime.now();
  final dias = DateTime(hoy.year, hoy.month, hoy.day)
      .difference(DateTime(fecha.year, fecha.month, fecha.day))
      .inDays;
  if (dias <= 0) return 'Publicado hoy';
  if (dias == 1) return 'Publicado ayer';
  if (dias < 30) return 'Publicado hace $dias días';
  final meses = dias ~/ 30;
  if (meses < 12) {
    return meses == 1 ? 'Publicado hace 1 mes' : 'Publicado hace $meses meses';
  }
  final anios = dias ~/ 365;
  return anios <= 1 ? 'Publicado hace más de 1 año' : 'Publicado hace $anios años';
}

/// "2.390" o "6,5" (como se escribe en la región).
/// AF-146: "250 limpias · 200 agrícolas · 50 monte" (solo lo cargado).
String distribucionTexto(
    double limpias, double agricolas, double ganaderas, double monte) {
  return [
    if (limpias > 0) '${hectareasTexto(limpias)} limpias',
    if (agricolas > 0) '${hectareasTexto(agricolas)} agrícolas',
    if (ganaderas > 0) '${hectareasTexto(ganaderas)} ganaderas',
    if (monte > 0) '${hectareasTexto(monte)} monte',
  ].join(' · ');
}

String hectareasTexto(double ha) {
  final entero = ha.truncate();
  final s = entero.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  final dec = ((ha - entero) * 10).round();
  return dec > 0 ? '$b,$dec' : '$b';
}

class _TarjetaCampo extends StatelessWidget {
  final ActivoPublico campo;

  const _TarjetaCampo({required this.campo});

  @override
  Widget build(BuildContext context) {
    final lugar = [campo.localidad, campo.provincia]
        .where((x) => x.trim().isNotEmpty)
        .join(', ');
    final precio = campo.ofertas.isEmpty ? null : campo.ofertas.first.texto;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TarjetaBlanca(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleCampoScreen(activo: campo),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto con el precio encima (o un fondo si no tiene fotos).
            Stack(
              children: [
                campo.fotos.isNotEmpty
                    ? FotoDelMercado(ruta: campo.fotos.first, alto: 190)
                    : Container(
                        height: 120,
                        color: AgroTema.verdeClaro,
                        alignment: Alignment.center,
                        child: const Icon(Icons.landscape,
                            size: 48, color: AgroTema.verde),
                      ),
                if (precio != null)
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AgroTema.terracota,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        precio,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                // PUB-DIRECTO (27/11/2026): el último cambio bajó el precio.
                if (campo.bajoDePrecio)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AgroTema.verde,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_down,
                              size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Bajó de precio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (campo.fotos.length > 1)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('${campo.fotos.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          campo.nombre,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AgroTema.pizarra,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AgroTema.pizarraSuave),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place,
                          size: 16, color: AgroTema.terracota),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lugar.isEmpty ? "Ubicación sin información" : lugar,
                          style: const TextStyle(
                              fontSize: 14, color: AgroTema.pizarraSuave),
                        ),
                      ),
                      const Icon(Icons.straighten,
                          size: 16, color: AgroTema.azul),
                      const SizedBox(width: 4),
                      Text(
                        campo.superficie > 0
                            ? "${hectareasTexto(campo.superficie)} ha"
                            : "— ha",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AgroTema.pizarra,
                        ),
                      ),
                    ],
                  ),
                  // AF-146 (27/11/2026): cómo están las hectáreas.
                  if (campo.tieneDistribucion) ...[
                    const SizedBox(height: 4),
                    Text(
                      distribucionTexto(campo.haLimpias, campo.haAgricolas,
                          campo.haGanaderas, campo.haMonte),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AgroTema.verde,
                      ),
                    ),
                  ],
                  // GAP-MERC-01 H (25/11/2026): cuándo se publicó (la fecha
                  // se guarda al aprobar la publicación).
                  const SizedBox(height: 4),
                  Text(
                    publicadoHace(campo.ultimaActualizacion),
                    style: const TextStyle(
                        fontSize: 13, color: AgroTema.pizarraSuave),
                  ),
                  if (campo.ofertas.length > 1) ...[
                    const SizedBox(height: 6),
                    Text(
                      campo.ofertas.skip(1).map((o) => o.texto).join(" · "),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AgroTema.terracota,
                      ),
                    ),
                  ],
                  if (campo.producciones.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final a in campo.producciones)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AgroTema.verdeClaro,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${emojiActividad(a)} ${nombreActividad(a)}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AgroTema.verde,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
