import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/intervencion_profesional_model.dart';
import '../../services/profesional_service.dart';
import '../produccion/produccion_estilo.dart';
import 'profesionales_textos.dart';

/// AF-093: intervenciones de un campo.
/// - Profesional ([soyProfesional] = true): ve las suyas y puede registrar.
/// - Dueño: ve todas (se usa dentro de ProfesionalesActivoScreen).
class IntervencionesScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const IntervencionesScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<IntervencionesScreen> createState() => _IntervencionesScreenState();
}

class _IntervencionesScreenState extends State<IntervencionesScreen> {
  final ProfesionalService _servicio = ProfesionalService();
  bool cargando = true;
  String? error;
  List<IntervencionProfesional> lista = [];

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

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
      final l = await _servicio.intervencionesDelCampo(
        widget.activoAgroId,
        profesionalId: _uid,
      );
      if (!mounted) return;
      setState(() {
        lista = l;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudieron cargar las intervenciones: $e';
        cargando = false;
      });
    }
  }

  Future<void> registrar() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            RegistrarIntervencionScreen(activoAgroId: widget.activoAgroId),
      ),
    );
    if (guardo == true) await cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: Text(widget.nombreActivo),
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
                      const TituloSeccion('Mis intervenciones en este campo'),
                      if (lista.isEmpty)
                        const Text(
                          'Todavía no registraste nada. Cada visita o '
                          'recomendación queda en la historia del campo.',
                          style: TextStyle(
                              color: EstiloProduccion.textoSuave, height: 1.4),
                        ),
                      ...lista.map(tarjetaIntervencion),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Registrar intervención',
            onPressed: cargando ? null : registrar,
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de una intervención (la usan el profesional y el dueño).
Widget tarjetaIntervencion(IntervencionProfesional i) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TarjetaBlanca(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombreTipoIntervencion(i.tipo),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '${fechaCorta(i.fecha)} · '
              '${i.profesionalNombre.isEmpty ? 'Profesional' : i.profesionalNombre}'
              ' · declarado',
              style: const TextStyle(
                  fontSize: 14, color: EstiloProduccion.textoSuave),
            ),
            const SizedBox(height: 6),
            Text(i.descripcion, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    ),
  );
}

/// Formulario: registrar una intervención (solo agregar).
class RegistrarIntervencionScreen extends StatefulWidget {
  final String activoAgroId;

  const RegistrarIntervencionScreen({super.key, required this.activoAgroId});

  @override
  State<RegistrarIntervencionScreen> createState() =>
      _RegistrarIntervencionScreenState();
}

class _RegistrarIntervencionScreenState
    extends State<RegistrarIntervencionScreen> {
  final ProfesionalService _servicio = ProfesionalService();
  final TextEditingController _descripcion = TextEditingController();

  /// ID armado al abrir: tocar "Guardar" dos veces no duplica.
  late final String intervencionId =
      'int_${DateTime.now().millisecondsSinceEpoch}';

  String? tipo;
  DateTime fecha = DateTime.now();
  bool guardando = false;

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;
    if (tipo == null) {
      _avisar('Elegí qué tipo de intervención es.');
      return;
    }
    final intervencion = IntervencionProfesional(
      intervencionId: intervencionId,
      activoAgroId: widget.activoAgroId,
      profesionalId: usuario.uid,
      profesionalNombre: usuario.displayName ?? '',
      tipo: tipo!,
      descripcion: _descripcion.text.trim(),
      fecha: fecha,
      fechaRegistro: DateTime.now(),
    );
    final errores = intervencion.validar();
    if (errores.isNotEmpty) {
      _avisar(errores.first);
      return;
    }
    setState(() => guardando = true);
    try {
      await _servicio.registrarIntervencion(intervencion);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => guardando = false);
      _avisar('No se pudo guardar: $e');
    }
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Registrar intervención'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const EtiquetaCampo('¿Qué hiciste?'),
          OpcionesTocar<String>(
            opciones: IntervencionProfesional.tipos,
            elegida: tipo,
            etiqueta: nombreTipoIntervencion,
            alElegir: (t) => setState(() => tipo = t),
          ),
          const EtiquetaCampo('¿Cuándo?'),
          OutlinedButton.icon(
            onPressed: () async {
              final hoy = DateTime.now();
              final f = await showDatePicker(
                context: context,
                initialDate: fecha,
                firstDate: DateTime(hoy.year - 2),
                lastDate: hoy,
              );
              if (f != null) setState(() => fecha = f);
            },
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(fechaCorta(fecha)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              alignment: Alignment.centerLeft,
            ),
          ),
          const EtiquetaCampo('Contá qué se hizo o qué recomendás'),
          TextField(
            controller: _descripcion,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(
                ayuda: 'Ej.: Recorrida del lote 3. Se recomienda...'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda registrado a tu nombre como declarado. No se puede editar '
            'ni borrar: si hay que corregir algo, registrá una nueva.',
            style: TextStyle(
                fontSize: 14, height: 1.5, color: EstiloProduccion.textoSuave),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: 'Guardar intervención',
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
