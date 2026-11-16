import 'package:flutter/material.dart';

import '../../models/activos/cambio_territorio_model.dart';
import '../../models/activos/evento_afectacion_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/territorio_service.dart';
import '../../widgets/barra_campo.dart';
import '../emergencias/emergencias_textos.dart';
import '../produccion/produccion_estilo.dart';
import 'nuevo_cambio_territorio_screen.dart';
import 'territorio_textos.dart';

/// AF-109: Historia del territorio del campo.
///
/// Muestra juntos, del más nuevo al más viejo:
///  * los cambios del territorio (colección `cambios_territorio`), y
///  * las emergencias de AF-092 (se LEEN de `eventos_afectacion`, no se
///    copian).
/// Las emergencias hoy las ve solo el dueño (regla de AF-092); si quien
/// mira no puede verlas, la pantalla sigue andando con los cambios.
class HistoriaTerritorioScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const HistoriaTerritorioScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<HistoriaTerritorioScreen> createState() =>
      _HistoriaTerritorioScreenState();
}

class _HistoriaTerritorioScreenState extends State<HistoriaTerritorioScreen> {
  final TerritorioService _territorio = TerritorioService();
  final ActivoAgroServiceV2 _activos = ActivoAgroServiceV2();

  bool cargando = true;
  String? error;
  List<CambioTerritorio> cambios = [];
  int corregidos = 0;
  List<EventoAfectacion> emergencias = [];

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
      final todos = await _territorio.delCampo(widget.activoAgroId);
      List<EventoAfectacion> listaEmergencias = [];
      try {
        listaEmergencias =
            await _activos.listarEventosAfectacion(widget.activoAgroId);
      } catch (_) {
        // Sin permiso para ver emergencias: se muestran solo los cambios.
      }
      if (!mounted) return;
      final vigentes = CambioTerritorio.vigentes(todos);
      setState(() {
        cambios = vigentes;
        corregidos = todos.length - vigentes.length;
        emergencias = listaEmergencias;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudo cargar la historia del territorio: $e';
        cargando = false;
      });
    }
  }

  Future<void> _abrirFormulario({CambioTerritorio? corrige}) async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NuevoCambioTerritorioScreen(
          activoAgroId: widget.activoAgroId,
          corrige: corrige,
        ),
      ),
    );
    if (guardo == true) await cargar();
  }

  /// Cambios y emergencias mezclados por fecha (más nuevo primero).
  List<Widget> _lineaDeTiempo() {
    final entradas = <(DateTime, Widget)>[
      for (final c in cambios) (c.fechaDesde, _tarjetaCambio(c)),
      for (final e in emergencias) (e.fechaInicio, _tarjetaEmergencia(e)),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    return entradas.map((e) => e.$2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(
        title: const Text('Historia del territorio'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
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
                )
              : RefreshIndicator(
                  onRefresh: cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        widget.nombreActivo,
                        style: const TextStyle(
                          fontSize: 14,
                          color: EstiloProduccion.textoSuave,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Lo que le pasó al campo con los años: desmontes, '
                        'canales, caminos, cambios de uso y emergencias. '
                        'Ayuda a entender el suelo, el agua y los riesgos.',
                        style: TextStyle(
                            height: 1.4, color: EstiloProduccion.textoSuave),
                      ),
                      const SizedBox(height: 20),
                      const TituloSeccion('Línea de tiempo',
                          icono: Icons.timeline),
                      if (cambios.isEmpty && emergencias.isEmpty)
                        const EstadoVacio(
                          icono: Icons.landscape,
                          texto: 'Sin información. Si sabés de algún cambio '
                              '(un desmonte, un canal, un camino nuevo...), '
                              'cargalo: queda en la historia del campo.',
                        ),
                      ..._lineaDeTiempo(),
                      if (corregidos > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            corregidos == 1
                                ? '1 registro corregido queda guardado.'
                                : '$corregidos registros corregidos quedan guardados.',
                            style: const TextStyle(
                                fontSize: 13,
                                color: EstiloProduccion.textoSuave),
                          ),
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Cargar un cambio',
            onPressed: cargando ? null : () => _abrirFormulario(),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaCambio(CambioTerritorio c) {
    final detalle = [
      periodoTexto(c.fechaDesde, c.fechaHasta),
      'Fuente: ${nombreFuente(c.fuente).toLowerCase()}',
      nombreEstadoDatoTerritorio(c.estadoDato),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        child: FilaConIcono(
          icono: iconoTipoCambio(c.tipo),
          color: EstiloProduccion.verde,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreTipoCambio(c.tipo),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  detalle,
                  style: const TextStyle(
                      fontSize: 14, color: EstiloProduccion.textoSuave),
                ),
                const SizedBox(height: 6),
                Text(c.descripcion, style: const TextStyle(height: 1.4)),
                if (c.realizadoPor != null) ...[
                  const SizedBox(height: 4),
                  Text('Lo hizo: ${c.realizadoPor}',
                      style: const TextStyle(fontSize: 14)),
                ],
                if (c.archivoRuta != null) ...[
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.attach_file,
                          size: 16, color: EstiloProduccion.textoSuave),
                      SizedBox(width: 4),
                      Text('Archivo adjunto',
                          style: TextStyle(
                              fontSize: 14,
                              color: EstiloProduccion.textoSuave)),
                    ],
                  ),
                ],
                if (c.corrigeCambioId != null) ...[
                  const SizedBox(height: 4),
                  const Text('Corrige un registro anterior',
                      style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: EstiloProduccion.textoSuave)),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _abrirFormulario(corrige: c),
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Corregir'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaEmergencia(EventoAfectacion e) {
    final a = e.afectaciones.isNotEmpty ? e.afectaciones.first : null;
    final detalle = [
      'Emergencia · desde el ${fechaCorta(e.fechaInicio)}',
      if (a != null) 'Gravedad ${nombreGravedad(a.nivel).toLowerCase()}',
      'declarado',
    ].join(' · ');
    final grave = a?.nivel == 'grave';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        colorBorde: grave ? EstiloProduccion.rojo : const Color(0xFFE6D6BC),
        child: FilaConIcono(
          icono: Icons.warning_amber_rounded,
          color: grave ? EstiloProduccion.rojo : EstiloProduccion.terracota,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreTipoEmergencia(e.subtipoEvento),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  detalle,
                  style: const TextStyle(
                      fontSize: 14, color: EstiloProduccion.textoSuave),
                ),
                if (e.descripcion != nombreTipoEmergencia(e.subtipoEvento)) ...[
                  const SizedBox(height: 6),
                  Text(e.descripcion, style: const TextStyle(height: 1.4)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
