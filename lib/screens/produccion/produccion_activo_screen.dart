import 'package:flutter/material.dart';

import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../models/activos/evento_productivo_model.dart';
import '../../services/calculo_agricola.dart';
import '../../services/calculo_existencias.dart';
import '../../services/produccion_service.dart';
import 'cultivos_textos.dart';
import 'detalle_cultivo_screen.dart';
import 'detalle_rodeo_screen.dart';
import 'nuevo_cultivo_screen.dart';
import 'nuevo_potrero_screen.dart';
import 'nuevo_rodeo_screen.dart';
import '../../core/theme/agro_tema.dart';
import 'produccion_estilo.dart';
import '../../widgets/barra_campo.dart';

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

/// GAP-AGRO-01: un cultivo de la campaña con su resumen calculado.
class _CultivoConResumen {
  final GrupoProductivo grupo;
  final ResumenCultivo resumen;

  const _CultivoConResumen(this.grupo, this.resumen);
}

class _ProduccionActivoScreenState extends State<ProduccionActivoScreen> {
  final ProduccionService _servicio = ProduccionService();

  bool cargando = true;
  String? error;
  List<UnidadProductiva> unidades = [];
  List<_RodeoConExistencias> rodeos = [];
  List<_CultivoConResumen> cultivos = [];

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

      // GAP-AGRO-01: los cultivos no son rodeos (no tienen cabezas).
      final agricolas = grupos.where((g) => g.esAgricola).toList();
      final conResumen = await Future.wait(agricolas.map((g) async {
        final eventos = await _servicio.eventosDeGrupo(
          activoAgroId: g.activoAgroId,
          grupoId: g.grupoId,
        );
        return _CultivoConResumen(
          g,
          calcularResumenCultivo(
              eventos.where((e) => tiposEventoAgricola.contains(e.tipo))),
        );
      }));

      final conExistencias =
          await Future.wait(grupos.where((g) => !g.esAgricola).map((g) async {
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
        cultivos = conResumen;
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
      appBar: BarraCampo(
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
                        [
                          widget.nombreActivo,
                          if (rodeos.isNotEmpty) '$totalCabezas cabezas',
                          if (cultivos.isNotEmpty)
                            '${cultivos.length} '
                                '${cultivos.length == 1 ? 'cultivo' : 'cultivos'}',
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: EstiloProduccion.textoSuave,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ResumenNumeros([
                        (
                          '$totalCabezas',
                          totalCabezas == 1 ? 'cabeza' : 'cabezas',
                          Icons.pets,
                          EstiloProduccion.terracota,
                        ),
                        (
                          '${cultivos.length}',
                          cultivos.length == 1 ? 'cultivo' : 'cultivos',
                          Icons.grass,
                          EstiloProduccion.verde,
                        ),
                        (
                          numeroAgro(unidades.fold<double>(
                              0, (s, u) => s + (u.superficieHa ?? 0))),
                          'ha en lotes',
                          Icons.crop_square,
                          AgroTema.azul,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      const TituloSeccion('Rodeos', icono: Icons.pets),
                      if (rodeos.isEmpty)
                        const EstadoVacio(
                          icono: Icons.pets,
                          texto: 'Todavía no hay rodeos. Tocá "Nuevo rodeo" '
                              'para empezar.',
                        ),
                      ...rodeos.map(_tarjetaRodeo),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(child: TituloSeccion('Cultivos', icono: Icons.grass)),
                          TextButton(
                            onPressed: () => abrir(NuevoCultivoScreen(
                              activoAgroId: widget.activoAgroId,
                              unidades: unidades,
                            )),
                            child: const Text('+ Nuevo cultivo'),
                          ),
                        ],
                      ),
                      if (cultivos.isEmpty)
                        const EstadoVacio(
                          icono: Icons.grass,
                          texto: 'Todavía no hay cultivos. Cargá un lote y '
                              'después tocá "Nuevo cultivo".',
                        ),
                      ...cultivos.map(_tarjetaCultivo),
                      const SizedBox(height: 24),
                      const TituloSeccion('Lotes, potreros y corrales', icono: Icons.crop_square),
                      if (unidades.isEmpty)
                        const EstadoVacio(
                          icono: Icons.crop_square,
                          texto: 'Todavía no hay lotes ni potreros. Cargá al '
                              'menos uno para saber dónde está cada cosa.',
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
                  texto: '+ Lote o potrero',
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
              const IconoCirculo(Icons.pets,
                  color: EstiloProduccion.terracota, tamano: 48),
              const SizedBox(width: 12),
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

  Widget _tarjetaCultivo(_CultivoConResumen c) {
    final r = c.resumen;
    final detalle = r.haSembradas == 0 && r.haCosechadas == 0
        ? 'Sin sembrar todavía'
        : r.rendimiento != null
            ? '${numeroAgro(r.haCosechadas)} ha cosechadas · '
                '${numeroAgro(r.toneladas)} tn · '
                '${numeroAgro(r.rendimiento!)} tn/ha'
            : '${numeroAgro(r.haSembradas)} ha sembradas · en curso';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        onTap: () => abrir(DetalleCultivoScreen(
          grupo: c.grupo,
          unidades: unidades,
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const IconoCirculo(Icons.grass,
                  color: EstiloProduccion.verde, tamano: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.grupo.nombre,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detalle,
                      style: const TextStyle(
                          fontSize: 14, color: EstiloProduccion.textoSuave),
                    ),
                    if (r.cosechaSinSiembraSuficiente) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Revisar: cosecha mayor que lo sembrado',
                        style: TextStyle(
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
          IconoCirculo(
            unidad.tipo == TipoUnidadProductiva.lote
                ? Icons.crop_square
                : Icons.fence,
            color: AgroTema.azul,
            tamano: 36,
          ),
          const SizedBox(width: 12),
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
