import 'package:flutter/material.dart';

import '../../models/activos/disponibilidad_recepcion_model.dart';
import '../../models/activos/evento_afectacion_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../produccion/produccion_estilo.dart';
import 'emergencias_textos.dart';
import 'registrar_emergencia_screen.dart';
import '../../widgets/barra_campo.dart';

/// AF-092: emergencias del campo ("de la alerta a la acción").
/// Arriba, la marca voluntaria "Mi campo puede recibir en una emergencia";
/// abajo, las emergencias registradas (las más recientes primero).
class EmergenciasActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const EmergenciasActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<EmergenciasActivoScreen> createState() =>
      _EmergenciasActivoScreenState();
}

class _EmergenciasActivoScreenState extends State<EmergenciasActivoScreen> {
  final ActivoAgroServiceV2 _activos = ActivoAgroServiceV2();
  final TextEditingController _capacidad = TextEditingController();

  bool cargando = true;
  bool guardandoMarca = false;
  String? error;
  List<EventoAfectacion> eventos = [];

  bool disponible = false;
  Set<String> recursos = {};

  @override
  void initState() {
    super.initState();
    cargar();
  }

  @override
  void dispose() {
    _capacidad.dispose();
    super.dispose();
  }

  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final activo = await _activos.obtenerActivoPorId(widget.activoAgroId);
      final lista = await _activos.listarEventosAfectacion(widget.activoAgroId);
      if (!mounted) return;
      final d = activo?.disponibleParaRecibir;
      setState(() {
        eventos = lista;
        disponible = d?.activa ?? false;
        recursos = {...?d?.recursos};
        _capacidad.text = d?.capacidad ?? '';
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudieron cargar las emergencias: $e';
        cargando = false;
      });
    }
  }

  Future<void> _guardarMarca() async {
    setState(() => guardandoMarca = true);
    try {
      final capacidad = _capacidad.text.trim();
      await _activos.actualizarDisponibilidadRecepcion(
        widget.activoAgroId,
        DisponibilidadRecepcion(
          activa: disponible,
          recursos: disponible
              ? DisponibilidadRecepcion.recursosPosibles
                  .where(recursos.contains)
                  .toList()
              : const [],
          capacidad: disponible && capacidad.isNotEmpty ? capacidad : null,
          fechaActualizacion: DateTime.now(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardado.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => guardandoMarca = false);
    }
  }

  Future<void> _registrar() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            RegistrarEmergenciaScreen(activoAgroId: widget.activoAgroId),
      ),
    );
    if (guardo == true) await cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(
        title: const Text('Emergencias'),
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
                      const SizedBox(height: 16),
                      _tarjetaDisponible(),
                      const SizedBox(height: 24),
                      const TituloSeccion('Emergencias registradas', icono: Icons.warning_amber_rounded),
                      if (eventos.isEmpty)
                        const Text(
                          'No hay emergencias registradas. Si pasa algo '
                          '(inundación, sequía, incendio...), registralo: '
                          'queda en la historia del campo.',
                          style: TextStyle(
                            color: EstiloProduccion.textoSuave,
                            height: 1.4,
                          ),
                        ),
                      ...eventos.map(_tarjetaEvento),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Registrar emergencia',
            onPressed: cargando ? null : _registrar,
          ),
        ),
      ),
    );
  }

  Widget _tarjetaDisponible() {
    return TarjetaBlanca(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Mi campo puede recibir en una emergencia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                  'Es voluntario. Por ahora solo lo ves vos.'),
              value: disponible,
              onChanged: (v) => setState(() => disponible = v),
            ),
            if (disponible) ...[
              const EtiquetaCampo('¿Qué puede recibir?'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final r in DisponibilidadRecepcion.recursosPosibles)
                    FilterChip(
                      label: Text(nombreRecurso(r)),
                      selected: recursos.contains(r),
                      onSelected: (s) => setState(() {
                        s ? recursos.add(r) : recursos.remove(r);
                      }),
                    ),
                ],
              ),
              const EtiquetaCampo('Capacidad (opcional)'),
              TextField(
                controller: _capacidad,
                textCapitalization: TextCapitalization.sentences,
                decoration: decoracionCampo(
                    ayuda: 'Ej.: 300 cabezas, 2 potreros con agua'),
              ),
            ],
            const SizedBox(height: 12),
            BotonGrande(
              texto: 'Guardar',
              contorno: true,
              ocupado: guardandoMarca,
              onPressed: _guardarMarca,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaEvento(EventoAfectacion e) {
    final a = e.afectaciones.isNotEmpty ? e.afectaciones.first : null;
    final detalle = [
      'Desde el ${fechaCorta(e.fechaInicio)}',
      if (a != null) 'Gravedad ${nombreGravedad(a.nivel).toLowerCase()}',
      if (a?.superficieAfectada != null) '${a!.superficieAfectada} ha',
      'declarado',
    ].join(' · ');
    final grave = a?.nivel == 'grave';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        colorBorde: grave ? EstiloProduccion.rojo : EstiloProduccion.borde,
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
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
