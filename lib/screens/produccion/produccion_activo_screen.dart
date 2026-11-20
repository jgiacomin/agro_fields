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

/// QA Grupo B (18/11/2026): desde dónde se entra a Producción.
/// QA 20/11/2026: abajo hay un solo botón. Desde el paso "lugares" es
/// "+ Lote o potrero"; en los demás casos es "+ Cargar", que pregunta qué
/// cargar (desde el paso "animales" solo ofrece animales o cultivo).
enum EnfoqueProduccion { normal, lugares, animales }

/// QA 20/11/2026: opciones del botón "+ Cargar".
enum _QueCargar { lugar, animales, cultivo }

/// Pantalla 1 (paso 6a, GAP-PROD-01): la produccion de un campo.
/// Muestra los rodeos con su total de cabezas y los potreros.
class ProduccionActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;
  final EnfoqueProduccion enfoque;

  const ProduccionActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
    this.enfoque = EnfoqueProduccion.normal,
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
    // GAP-PROD-02 (18/11/2026): con aves o peces se dice "animales".
    final soloGanaderia = rodeos.every((r) => r.grupo.esGanadero);
    // QA (18/11/2026): un total negativo es un error de carga: se muestra
    // "Revisar" en vez del número.
    final totalNegativo = totalCabezas < 0;
    final palabraTotal = soloGanaderia
        ? (totalCabezas == 1 ? 'cabeza' : 'cabezas')
        : (totalCabezas == 1 ? 'animal' : 'animales');

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
                          if (rodeos.isNotEmpty)
                            totalNegativo
                                ? 'cuentas para revisar'
                                : '$totalCabezas $palabraTotal',
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
                          totalNegativo ? 'Revisar' : '$totalCabezas',
                          palabraTotal,
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
                      TituloSeccion(soloGanaderia ? 'Rodeos' : 'Animales',
                          icono: Icons.pets),
                      if (rodeos.isEmpty)
                        const EstadoVacio(
                          icono: Icons.pets,
                          texto: 'Todavía no hay animales. Primero cargá tus '
                              'lugares. Después tocá "+ Cargar" → Animales '
                              'para crear un rodeo o un lote, y adentro '
                              '"Registrar evento" → Entrada para sumar los '
                              'animales.',
                        ),
                      ...rodeos.map(_tarjetaRodeo),
                      const SizedBox(height: 24),
                      const TituloSeccion('Cultivos', icono: Icons.grass),
                      if (cultivos.isEmpty)
                        const EstadoVacio(
                          icono: Icons.grass,
                          texto: 'Todavía no hay cultivos. Cargá un lote y '
                              'después tocá "+ Cargar" → Cultivo.',
                        ),
                      ...cultivos.map(_tarjetaCultivo),
                      const SizedBox(height: 24),
                      const TituloSeccion('Lotes, potreros y corrales', icono: Icons.crop_square),
                      if (unidades.isEmpty)
                        EstadoVacio(
                          icono: Icons.crop_square,
                          texto: 'Empezá por acá: tocá '
                              '${widget.enfoque == EnfoqueProduccion.lugares ? '"+ Lote o potrero"' : '"+ Cargar" → Lugar'}'
                              ' y cargá tus potreros, lotes, corrales, '
                              'galpones o estanques.',
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
          child: _botonesAbajo(),
        ),
      ),
    );
  }

  /// QA 20/11/2026: un solo botón abajo.
  /// - Desde el paso "lugares": "+ Lote o potrero" (como antes).
  /// - Desde el paso "animales": "+ Cargar" con animales o cultivo.
  /// - Normal: "+ Cargar" con lugar, animales o cultivo.
  /// Mientras carga la pantalla el botón espera, para no abrir las
  /// pantallas sin la lista de lugares.
  Widget _botonesAbajo() {
    if (widget.enfoque == EnfoqueProduccion.lugares) {
      return BotonGrande(
        texto: '+ Lote o potrero',
        onPressed: () => abrir(NuevoPotreroScreen(
          activoAgroId: widget.activoAgroId,
        )),
      );
    }
    return BotonGrande(
      texto: '+ Cargar',
      onPressed: cargando
          ? null
          : () => _elegirQueCargar(
                conLugar: widget.enfoque == EnfoqueProduccion.normal,
              ),
    );
  }

  /// QA 20/11/2026: menú de abajo que pregunta qué cargar.
  Future<void> _elegirQueCargar({required bool conLugar}) async {
    final eleccion = await showModalBottomSheet<_QueCargar>(
      context: context,
      backgroundColor: EstiloProduccion.fondo,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿Qué querés cargar?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: EstiloProduccion.texto,
                ),
              ),
              if (conLugar && unidades.isEmpty) ...[
                const SizedBox(height: 4),
                const Text(
                  'Si es la primera vez, empezá por Lugar.',
                  style: TextStyle(
                    fontSize: 14,
                    color: EstiloProduccion.textoSuave,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (conLugar)
                _opcionCargar(
                  ctx,
                  _QueCargar.lugar,
                  Icons.crop_square,
                  AgroTema.azul,
                  'Lugar',
                  'Potrero, lote, corral, galpón o estanque',
                ),
              _opcionCargar(
                ctx,
                _QueCargar.animales,
                Icons.pets,
                EstiloProduccion.terracota,
                'Animales',
                'Rodeo o lote de animales',
              ),
              _opcionCargar(
                ctx,
                _QueCargar.cultivo,
                Icons.grass,
                EstiloProduccion.verde,
                'Cultivo',
                'Siembra en un lote',
              ),
            ],
          ),
        ),
      ),
    );

    if (eleccion == null || !mounted) return;
    switch (eleccion) {
      case _QueCargar.lugar:
        await abrir(NuevoPotreroScreen(activoAgroId: widget.activoAgroId));
        break;
      case _QueCargar.animales:
        await abrir(NuevoRodeoScreen(
          activoAgroId: widget.activoAgroId,
          unidades: unidades,
        ));
        break;
      case _QueCargar.cultivo:
        await abrir(NuevoCultivoScreen(
          activoAgroId: widget.activoAgroId,
          unidades: unidades,
        ));
        break;
    }
  }

  Widget _opcionCargar(
    BuildContext ctx,
    _QueCargar valor,
    IconData icono,
    Color color,
    String titulo,
    String ayuda,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        onTap: () => Navigator.of(ctx).pop(valor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconoCirculo(icono, color: color, tamano: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ayuda,
                      style: const TextStyle(
                        fontSize: 14,
                        color: EstiloProduccion.textoSuave,
                      ),
                    ),
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

  /// GAP-PROD-02: ícono según la especie del lote.
  IconData _iconoActividad(String actividad) {
    switch (actividad) {
      case 'avicultura':
        return Icons.egg_outlined;
      case 'piscicultura':
        return Icons.set_meal;
      default:
        return Icons.pets;
    }
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
              IconoCirculo(_iconoActividad(rodeo.grupo.actividad),
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
                      '${existencias.totalCabezas < 0 ? 'Revisar las cuentas' : '${existencias.totalCabezas} ${rodeo.grupo.esGanadero ? 'cabezas' : 'animales'}'}'
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
    final ha = unidad.superficieHa != null
        ? '${unidad.superficieHa!.toStringAsFixed(unidad.superficieHa! % 1 == 0 ? 0 : 1)} ha'
        : null;
    // QA T1-07 (18/11/2026): se muestra la capacidad si está cargada.
    final cap =
        unidad.capacidad != null ? 'capacidad ${unidad.capacidad}' : null;
    final partes = [if (ha != null) ha, if (cap != null) cap];
    final detalle = partes.isNotEmpty
        ? partes.join(' · ')
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
