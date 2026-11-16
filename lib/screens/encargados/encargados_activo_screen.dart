import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/permisos_encargado.dart';
import '../../services/encargado_service.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';
import '../profesionales/profesionales_textos.dart';

/// GAP-ENC-01: el dueño invita encargados a su campo, elige qué puede hacer
/// cada uno, cambia esas tareas o le quita el acceso.
class EncargadosActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const EncargadosActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<EncargadosActivoScreen> createState() => _EncargadosActivoScreenState();
}

class _EncargadosActivoScreenState extends State<EncargadosActivoScreen> {
  final EncargadoService _servicio = EncargadoService();
  bool cargando = true;
  String? error;
  List<EncargadoDelCampo> encargados = [];

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
      final l = await _servicio.encargadosDelCampo(widget.activoAgroId);
      if (!mounted) return;
      setState(() {
        encargados = l;
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

  /// Diálogo para invitar (sin código previo) o cambiar tareas (con código).
  Future<void> _abrirDialogo({EncargadoDelCampo? existente}) async {
    final control = TextEditingController(text: existente?.usuarioId ?? '');
    final elegidas = <AreaEncargado>{...?existente?.areas};
    if (existente == null) elegidas.add(AreaEncargado.produccion);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(existente == null ? 'Invitar encargado' : 'Tareas del encargado'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (existente == null) ...[
                  const Text(
                    'Pegá el código que te pasó el encargado (lo encuentra en '
                    'Menú → Mi código).',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: control,
                    autofocus: true,
                    decoration: decoracionCampo(ayuda: 'Código'),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text('¿Qué puede hacer?',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                for (final area in AreaEncargado.values)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: elegidas.contains(area),
                    onChanged: (v) => setD(() {
                      v == true ? elegidas.add(area) : elegidas.remove(area);
                    }),
                    title: Text(nombreArea(area)),
                    subtitle: Text(ayudaArea(area),
                        style: const TextStyle(fontSize: 12)),
                  ),
                const SizedBox(height: 4),
                const Text(
                  'No ve el expediente privado, los documentos, los cheques '
                  'ni las emergencias.',
                  style: TextStyle(
                      fontSize: 12, color: EstiloProduccion.textoSuave),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(existente == null ? 'Invitar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
    final codigo = control.text;
    control.dispose();
    if (ok != true) return;

    try {
      await _servicio.invitar(
        activoId: widget.activoAgroId,
        nombreActivo: widget.nombreActivo,
        duenoId: FirebaseAuth.instance.currentUser?.uid ?? '',
        codigoEncargado: codigo,
        areas: elegidas,
      );
      await cargar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(existente == null ? 'Encargado invitado.' : 'Tareas guardadas.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    }
  }

  Future<void> _quitar(EncargadoDelCampo e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar acceso'),
        content: const Text(
            'El encargado ya no podrá cargar nada en este campo. Lo que ya '
            'cargó queda en el campo.'),
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
      await _servicio.revocarTodo(e);
      await cargar();
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo quitar el acceso: $err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(title: const Text('Encargados')),
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
                      Text(widget.nombreActivo,
                          style: const TextStyle(
                              fontSize: 14, color: EstiloProduccion.textoSuave)),
                      const SizedBox(height: 16),
                      const TituloSeccion('Encargados del campo',
                          icono: Icons.engineering_outlined),
                      if (encargados.isEmpty)
                        const EstadoVacio(
                          icono: Icons.engineering_outlined,
                          texto: 'Todavía no invitaste a nadie. Tu encargado '
                              'te pasa su código y lo invitás acá, eligiendo '
                              'qué puede cargar.',
                        ),
                      for (final e in encargados) _tarjeta(e),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Invitar encargado',
            onPressed: cargando ? null : () => _abrirDialogo(),
          ),
        ),
      ),
    );
  }

  Widget _tarjeta(EncargadoDelCampo e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        onTap: e.activo ? () => _abrirDialogo(existente: e) : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              IconoCirculo(
                Icons.engineering,
                color: e.activo
                    ? EstiloProduccion.verde
                    : EstiloProduccion.textoSuave,
                tamano: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Encargado (código ${codigoCorto(e.usuarioId)})',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      e.activo
                          ? e.areas.map(nombreArea).join(' · ')
                          : 'Sin acceso (quitado)',
                      style: const TextStyle(
                          fontSize: 13, color: EstiloProduccion.textoSuave),
                    ),
                    if (e.activo)
                      const Text('Tocá para cambiar sus tareas',
                          style: TextStyle(
                              fontSize: 12, color: EstiloProduccion.terracota)),
                  ],
                ),
              ),
              if (e.activo)
                IconButton(
                  tooltip: 'Quitar acceso',
                  icon: const Icon(Icons.person_remove_outlined),
                  onPressed: () => _quitar(e),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
