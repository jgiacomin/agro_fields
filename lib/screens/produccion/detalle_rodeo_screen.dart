import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/evento_productivo_model.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../services/calculo_existencias.dart';
import '../../services/calculo_rodeo.dart';
import '../../services/produccion_service.dart';
import 'produccion_estilo.dart';
import 'registrar_evento_screen.dart';
import '../../widgets/barra_campo.dart';

/// Pantalla 3 (paso 6a, GAP-PROD-01): el detalle de un rodeo.
/// Arriba las cuentas para revisar; despues cuantos hay, donde estan y la
/// historia de eventos (del mas nuevo al mas viejo).
class DetalleRodeoScreen extends StatefulWidget {
  final GrupoProductivo grupo;
  final List<UnidadProductiva> unidades;

  const DetalleRodeoScreen({
    super.key,
    required this.grupo,
    required this.unidades,
  });

  @override
  State<DetalleRodeoScreen> createState() => _DetalleRodeoScreenState();
}

class _DetalleRodeoScreenState extends State<DetalleRodeoScreen> {
  final ProduccionService _servicio = ProduccionService();

  bool cargando = true;
  bool huboCambios = false;
  String? error;
  List<EventoProductivo> eventos = [];
  ResultadoExistencias existencias =
      const ResultadoExistencias(porUnidad: {}, discrepancias: []);

  // GAP-PESO-01 + AF-102: salen de los eventos, no se cargan a mano.
  GananciaDiaria? ganancia;
  Mortandad? mortandad;

  Map<String, UnidadProductiva> get unidadesPorId =>
      {for (final u in widget.unidades) u.unidadId: u};

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
      final lista = await _servicio.eventosDeGrupo(
        activoAgroId: widget.grupo.activoAgroId,
        grupoId: widget.grupo.grupoId,
      );

      if (!mounted) return;

      setState(() {
        eventos = lista;
        existencias = calcularExistencias(
          lista,
          unidadInicialId: widget.grupo.unidadInicialId,
        );
        final hoy = DateTime.now();
        ganancia = calcularGananciaDiaria(lista);
        mortandad = calcularMortandad(
          lista,
          desde: DateTime(hoy.year - 1, hoy.month, hoy.day),
          hasta: hoy,
        );
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudieron cargar los eventos: $e';
        cargando = false;
      });
    }
  }

  Future<void> registrarEvento() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RegistrarEventoScreen(
          grupo: widget.grupo,
          unidades: widget.unidades,
          existencias: existencias,
        ),
      ),
    );
    if (guardo == true) {
      huboCambios = true;
      await cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final grupo = widget.grupo;
    final subtitulo = [
      if (grupo.etapa != null) nombreEtapa(grupo.etapa!),
      nombreTenencia(grupo.tenencia),
      '${existencias.totalCabezas} cabezas',
    ].join(' · ');

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(huboCambios);
      },
      child: Scaffold(
        appBar: BarraCampo(
          title: Text(grupo.nombre),
        ),
        body: cargando
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!, textAlign: TextAlign.center))
                : RefreshIndicator(
                    onRefresh: cargar,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          subtitulo,
                          style: const TextStyle(
                            fontSize: 14,
                            color: EstiloProduccion.textoSuave,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._avisosDiscrepancias(),
                        const TituloSeccion('Cuántos hay', icono: Icons.numbers),
                        _cuantosHay(),
                        const SizedBox(height: 22),
                        const TituloSeccion('Indicadores', icono: Icons.monitor_weight_outlined),
                        _indicadores(),
                        const SizedBox(height: 22),
                        const TituloSeccion('Dónde están', icono: Icons.place_outlined),
                        _dondeEstan(),
                        const SizedBox(height: 22),
                        const TituloSeccion('Historia', icono: Icons.history),
                        _historia(),
                      ],
                    ),
                  ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: BotonGrande(
              texto: 'Registrar evento',
              onPressed: cargando ? null : registrarEvento,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _avisosDiscrepancias() {
    if (!existencias.hayDiscrepancias) return [];

    final porId = {for (final e in eventos) e.eventoId: e};
    final cantidad = existencias.discrepancias.length;

    return [
      Semantics(
        liveRegion: true,
        child: TarjetaBlanca(
          colorFondo: EstiloProduccion.rojoFondo,
          colorBorde: EstiloProduccion.rojoBorde,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cantidad == 1
                      ? 'Una cuenta para revisar'
                      : '$cantidad cuentas para revisar',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: EstiloProduccion.rojo,
                  ),
                ),
                const SizedBox(height: 6),
                ...existencias.discrepancias.map((d) {
                  final evento = porId[d.eventoId];
                  final texto = evento == null
                      ? d.descripcion
                      : 'Revisá: ${_resumen(evento)} del '
                          '${fechaCorta(evento.fechaHecho)}. Salen más '
                          'animales de los que había, o falta cargar una '
                          'entrada.';
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      texto,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF5E1A14),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
    ];
  }

  Widget _cuantosHay() {
    final categorias = existencias.porCategoria;
    if (categorias.isEmpty) {
      return const Text(
        'Todavía no hay animales. Registrá una Entrada para cargarlos.',
        style: TextStyle(color: EstiloProduccion.textoSuave),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categorias.entries.map((entrada) {
        final negativo = entrada.value < 0;
        final color =
            negativo ? EstiloProduccion.rojo : EstiloProduccion.texto;
        return SizedBox(
          width: 104,
          child: TarjetaBlanca(
            colorBorde: negativo
                ? EstiloProduccion.rojoBorde
                : EstiloProduccion.borde,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entrada.value}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    nombreCategoria(entrada.key, cantidad: entrada.value),
                    style: TextStyle(
                      fontSize: 13,
                      color: negativo
                          ? EstiloProduccion.rojo
                          : EstiloProduccion.textoSuave,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _decimal(double v, int decimales) =>
      v.toStringAsFixed(decimales).replaceAll('.', ',');

  /// GAP-PESO-01 + AF-102: ganancia diaria de peso y mortandad.
  Widget _indicadores() {
    final g = ganancia;
    final m = mortandad;

    Widget tarjeta(String valor, String titulo, String detalle) {
      return SizedBox(
        width: 220,
        child: TarjetaBlanca(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: EstiloProduccion.texto,
                  ),
                ),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detalle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: EstiloProduccion.textoSuave,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        g == null
            ? tarjeta('Sin información', 'Ganancia diaria de peso',
                'Hacen falta dos pesajes de la misma categoría, en días distintos.')
            : tarjeta(
                '${_decimal(g.kgPorDia, 2)} kg/día',
                'Ganancia diaria de peso',
                'De ${_decimal(g.pesoInicialKg, 0)} a '
                    '${_decimal(g.pesoFinalKg, 0)} kg en ${g.dias} días'
                    '${g.categoria == null ? '' : ' (${nombreCategoria(g.categoria!).toLowerCase()})'}.',
              ),
        m == null
            ? tarjeta('Sin información', 'Mortandad (últimos 12 meses)',
                'Todavía no hay animales cargados en este período.')
            : m.paraRevisar
            ? tarjeta('Para revisar', 'Mortandad (últimos 12 meses)',
                'Hay ${m.muertes} muertes cargadas y solo ${m.animalesBase} '
                    'animales. Falta cargar una entrada o hay un error.')
            : tarjeta(
                '${_decimal(m.porcentaje, 1)} %',
                'Mortandad (últimos 12 meses)',
                '${m.muertes} ${m.muertes == 1 ? 'muerte' : 'muertes'} sobre '
                    '${m.animalesBase} animales (los que había más los que entraron).',
              ),
      ],
    );
  }

  Widget _dondeEstan() {
    final lugares = existencias.porUnidad.entries.toList();
    if (lugares.isEmpty) {
      return const Text(
        'Sin información.',
        style: TextStyle(color: EstiloProduccion.textoSuave),
      );
    }

    return TarjetaBlanca(
      child: Column(
        children: [
          for (var i = 0; i < lugares.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: i == lugares.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: Color(0xFFEEF0EA)),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      nombreUnidad(lugares[i].key, unidadesPorId),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      lugares[i]
                          .value
                          .entries
                          .map((c) =>
                              '${c.value} ${nombreCategoria(c.key, cantidad: c.value).toLowerCase()}')
                          .join(' · '),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        color: EstiloProduccion.textoSuave,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _historia() {
    if (eventos.isEmpty) {
      return const Text(
        'Sin eventos todavía.',
        style: TextStyle(color: EstiloProduccion.textoSuave),
      );
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final conProblema = existencias.discrepancias.map((d) => d.eventoId).toSet();
    final recientes = eventos.reversed.toList();

    return TarjetaBlanca(
      child: Column(
        children: [
          for (var i = 0; i < recientes.length; i++)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: i == recientes.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: Color(0xFFEEF0EA)),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resumen(recientes[i]),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: conProblema.contains(recientes[i].eventoId)
                          ? EstiloProduccion.rojo
                          : EstiloProduccion.texto,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      fechaCorta(recientes[i].fechaHecho),
                      recientes[i].cargadoPor == uid ? 'Vos' : 'Otro usuario',
                      nombreEstadoDato(recientes[i].estadoDato),
                    ].join(' · '),
                    style: const TextStyle(
                      fontSize: 13,
                      color: EstiloProduccion.textoSuave,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Una linea que cuenta el evento, por ejemplo "Salida · 12 novillos · Venta".
  String _resumen(EventoProductivo e) {
    final partes = <String>[nombreTipoEvento(e.tipo)];
    final cantidad = e.cantidad;
    final categoria = e.categoria;

    switch (e.tipo) {
      case TipoEventoProductivo.alta:
      case TipoEventoProductivo.baja:
        if (cantidad != null && categoria != null) {
          partes.add(
              '$cantidad ${nombreCategoria(categoria, cantidad: cantidad).toLowerCase()}');
        }
        if (e.origen != null) partes.add(nombreOrigen(e.origen!));
        if (e.motivo != null) partes.add(nombreMotivo(e.motivo!));
        break;
      case TipoEventoProductivo.movimiento:
        if (cantidad != null && categoria != null) {
          partes.add(
              '$cantidad ${nombreCategoria(categoria, cantidad: cantidad).toLowerCase()}');
        }
        if (e.unidadOrigenId != null && e.unidadDestinoId != null) {
          partes.add('${nombreUnidad(e.unidadOrigenId!, unidadesPorId)} → '
              '${nombreUnidad(e.unidadDestinoId!, unidadesPorId)}');
        }
        break;
      case TipoEventoProductivo.cambioCategoria:
        if (cantidad != null && categoria != null && e.categoriaNueva != null) {
          partes.add('$cantidad: '
              '${nombreCategoria(categoria, cantidad: cantidad).toLowerCase()} → '
              '${nombreCategoria(e.categoriaNueva!, cantidad: cantidad).toLowerCase()}');
        }
        break;
      case TipoEventoProductivo.sanidad:
        if (e.tratamiento != null) partes.add(e.tratamiento!);
        if (cantidad != null) partes.add('$cantidad animales');
        break;
      case TipoEventoProductivo.pesaje:
        if (e.pesoPromedioKg != null) {
          partes.add('${_decimal(e.pesoPromedioKg!, 0)} kg promedio');
        }
        if (cantidad != null && categoria != null) {
          partes.add(
              '$cantidad ${nombreCategoria(categoria, cantidad: cantidad).toLowerCase()}');
        } else if (categoria != null) {
          partes.add(nombreCategoria(categoria));
        } else if (cantidad != null) {
          partes.add('$cantidad animales');
        }
        break;
      default:
        break;
    }

    return partes.join(' · ');
  }
}
