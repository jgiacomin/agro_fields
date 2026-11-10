import 'package:flutter/material.dart';

import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../services/calculo_existencias.dart';
import '../../services/produccion_service.dart';
import 'detalle_rodeo_screen.dart';
import 'nuevo_potrero_screen.dart';
import 'nuevo_rodeo_screen.dart';
import 'produccion_estilo.dart';

/// Pantalla 1 (paso 6a, GAP-PROD-01): la produccion de un campo.
/// Muestra los rodeos con su total de cabezas y los potreros.
class ProduccionActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const ProduccionActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<ProduccionActivoScreen> createState() => _ProduccionActivoScreenState();
}

class _RodeoConExistencias {
  final GrupoProductivo grupo;
  final ResultadoExistencias existencias;

  const _RodeoConExistencias(this.grupo, this.existencias);
}

class _ProduccionActivoScreenState extends State<ProduccionActivoScreen> {
  final ProduccionService _servicio = ProduccionService();

  bool cargando = true;
  String? error;
  List<UnidadProductiva> unidades = [];
  List<_RodeoConExistencias> rodeos = [];

  Map<String, UnidadProductiva> get unidadesPorId =>
      {for (final u in unidades) u.unidadId: u};

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
      final resultados = await Future.wait([
        _servicio.unidadesDeActivo(widget.activoAgroId),
        _servicio.gruposDeActivo(widget.activoAgroId),
      ]);

      final todasLasUnidades = resultados[0] as List<UnidadProductiva>;
      final grupos = (resultados[1] as List<GrupoProductivo>)
          .where((g) => g.estado == EstadoGrupoProductivo.activo)
          .toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre));

      final conExistencias = await Future.wait(grupos.map((g) async {
        final existencias = await _servicio.existenciasDeGrupo(g);
        return _RodeoConExistencias(g, existencias);
      }));

      if (!mounted) return;

      setState(() {
        unidades = todasLasUnidades
            .where((u) => !u.estaArchivada)
            .toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        rodeos = conExistencias;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudo cargar la producción: $e';
        cargando = false;
      });
    }
  }

  Future<void> abrir(Widget pantalla) async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => pantalla),
    );
    if (guardo == true) await cargar();
  }

  @override
  Widget build(BuildContext context) {
    final totalCabezas =
        rodeos.fold<int>(0, (suma, r) => suma + r.existencias.totalCabezas);

    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Producción'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _mensajeError()
              : RefreshIndicator(
                  onRefresh: cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        '${widget.nombreActivo} · Ganadería · '
                        '$totalCabezas cabezas en total',
                        style: const TextStyle(
                          fontSize: 14,
                          color: EstiloProduccion.textoSuave,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const TituloSeccion('Rodeos'),
                      if (rodeos.isEmpty)
                        const Text(
                          'Todavía no hay rodeos. Tocá "Nuevo rodeo" para '
                          'empezar.',
                          style: TextStyle(color: EstiloProduccion.textoSuave),
                        ),
                      ...rodeos.map(_tarjetaRodeo),
                      const SizedBox(height: 24),
                      const TituloSeccion('Potreros y corrales'),
                      if (unidades.isEmpty)
                        const Text(
                          'Todavía no hay potreros. Cargá al menos uno para '
                          'saber dónde están los animales.',
                          style: TextStyle(color: EstiloProduccion.textoSuave),
                        )
                      else
                        TarjetaBlanca(
                          child: Column(
                            children: [
                              for (var i = 0; i < unidades.length; i++)
                                _filaUnidad(unidades[i],
                                    ultima: i == unidades.length - 1),
                            ],
                          ),
                        ),
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
                  texto: '+ Nuevo rodeo',
                  onPressed: () => abrir(NuevoRodeoScreen(
                    activoAgroId: widget.activoAgroId,
                    unidades: unidades,
                  )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BotonGrande(
                  texto: '+ Nuevo potrero',
                  contorno: true,
                  onPressed: () => abrir(NuevoPotreroScreen(
                    activoAgroId: widget.activoAgroId,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaRodeo(_RodeoConExistencias rodeo) {
    final existencias = rodeo.existencias;
    final lugares = existencias.porUnidad.keys
        .map((id) => nombreUnidad(id, unidadesPorId))
        .join(' y ');
    final discrepancias = existencias.discrepancias.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        onTap: () => abrir(DetalleRodeoScreen(
          grupo: rodeo.grupo,
          unidades: unidades,
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rodeo.grupo.nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${existencias.totalCabezas} cabezas'
                      '${lugares.isEmpty ? '' : ' · $lugares'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: EstiloProduccion.textoSuave,
                      ),
                    ),
                    if (discrepancias > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        discrepancias == 1
                            ? '1 cuenta para revisar'
                            : '$discrepancias cuentas para revisar',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: EstiloProduccion.rojo,
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

  Widget _filaUnidad(UnidadProductiva unidad, {required bool ultima}) {
    final detalle = unidad.superficieHa != null
        ? '${unidad.superficieHa!.toStringAsFixed(unidad.superficieHa! % 1 == 0 ? 0 : 1)} ha'
        : unidad.tipo == TipoUnidadProductiva.potrero
            ? 'Sin información'
            : nombreTipoUnidad(unidad.tipo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: ultima
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFEEF0EA))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(unidad.nombre, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            detalle,
            style: TextStyle(
              fontSize: 14,
              color: EstiloProduccion.textoSuave,
              fontStyle: detalle == 'Sin información'
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mensajeError() {
    return Center(
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
    );
  }
}
