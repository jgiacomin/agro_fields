import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/autorizacion_activo_model.dart';
import '../../models/activos/intervencion_profesional_model.dart';
import '../../services/profesional_service.dart';
import '../produccion/produccion_estilo.dart';
import 'intervenciones_screen.dart';
import 'profesionales_textos.dart';

/// AF-093: el dueño invita profesionales a su campo, les quita el acceso
/// y ve todo lo que registraron.
class ProfesionalesActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const ProfesionalesActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<ProfesionalesActivoScreen> createState() =>
      _ProfesionalesActivoScreenState();
}

class _ProfesionalesActivoScreenState extends State<ProfesionalesActivoScreen> {
  final ProfesionalService _servicio = ProfesionalService();
  bool cargando = true;
  String? error;
  List<AutorizacionActivo> profesionales = [];
  List<IntervencionProfesional> intervenciones = [];

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
      final p = await _servicio.profesionalesDelCampo(widget.activoAgroId);
      final i = await _servicio.intervencionesDelCampo(widget.activoAgroId);
      if (!mounted) return;
      setState(() {
        profesionales = p;
        intervenciones = i;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudo cargar: $e';
        cargando = false;
      });
    }
  }

  /// Nombre declarado del profesional, tomado de sus intervenciones.
  String _nombreDe(String uid) {
    for (final i in intervenciones) {
      if (i.profesionalId == uid && i.profesionalNombre.isNotEmpty) {
        return i.profesionalNombre;
      }
    }
    return 'Profesional (código ${codigoCorto(uid)})';
  }

  Future<void> _invitar() async {
    final control = TextEditingController();
    final codigo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invitar profesional'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pegá el código que te pasó el profesional (lo encuentra en '
              'Menú → Mi código de profesional).',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: control,
              autofocus: true,
              decoration: decoracionCampo(ayuda: 'Código'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(control.text),
            child: const Text('Invitar'),
          ),
        ],
      ),
    );
    control.dispose();
    if (codigo == null || codigo.trim().isEmpty) return;

    try {
      await _servicio.invitarProfesional(
        activoId: widget.activoAgroId,
        nombreActivo: widget.nombreActivo,
        duenoId: FirebaseAuth.instance.currentUser?.uid ?? '',
        codigoProfesional: codigo,
      );
      await cargar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profesional invitado.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo invitar: $e')),
      );
    }
  }

  Future<void> _revocar(AutorizacionActivo a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar acceso'),
        content: Text(
            '${_nombreDe(a.usuarioAutorizado)} ya no podrá registrar '
            'intervenciones. Lo que ya registró queda en el campo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Quitar acceso'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _servicio.revocar(a);
      await cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo quitar el acceso: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Profesionales'),
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
                            fontSize: 14, color: EstiloProduccion.textoSuave),
                      ),
                      const SizedBox(height: 16),
                      const TituloSeccion('Profesionales invitados'),
                      if (profesionales.isEmpty)
                        const Text(
                          'Todavía no invitaste a nadie. Tu agrónomo, '
                          'veterinario o técnico te pasa su código y lo '
                          'invitás acá. Solo registra lo suyo: no ve el '
                          'resto del expediente.',
                          style: TextStyle(
                              color: EstiloProduccion.textoSuave, height: 1.4),
                        ),
                      for (final a in profesionales) _tarjetaProfesional(a),
                      const SizedBox(height: 24),
                      const TituloSeccion('Intervenciones registradas'),
                      if (intervenciones.isEmpty)
                        const Text(
                          'Todavía no hay intervenciones.',
                          style: TextStyle(color: EstiloProduccion.textoSuave),
                        ),
                      ...intervenciones.map(tarjetaIntervencion),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Invitar profesional',
            onPressed: cargando ? null : _invitar,
          ),
        ),
      ),
    );
  }

  Widget _tarjetaProfesional(AutorizacionActivo a) {
    final activa = a.estado == EstadoAutorizacion.activa;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Icon(
                Icons.badge,
                color: activa
                    ? EstiloProduccion.verde
                    : EstiloProduccion.textoSuave,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nombreDe(a.usuarioAutorizado),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      activa
                          ? 'Con acceso desde el ${fechaCorta(a.fechaOtorgamiento)}'
                          : 'Sin acceso (quitado)',
                      style: const TextStyle(
                          fontSize: 13, color: EstiloProduccion.textoSuave),
                    ),
                  ],
                ),
              ),
              if (activa)
                TextButton(
                  onPressed: () => _revocar(a),
                  child: const Text('Quitar'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
