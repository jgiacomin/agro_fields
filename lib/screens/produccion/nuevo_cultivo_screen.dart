import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../services/produccion_service.dart';
import 'cultivos_textos.dart';
import 'produccion_estilo.dart';
import '../../widgets/barra_campo.dart';

/// GAP-AGRO-01: nuevo cultivo de la campaña (ej.: Soja 2026/27 - Lote 3).
/// Reutiliza GrupoProductivo con actividad "agricultura".
class NuevoCultivoScreen extends StatefulWidget {
  final String activoAgroId;
  final List<UnidadProductiva> unidades;

  const NuevoCultivoScreen({
    super.key,
    required this.activoAgroId,
    required this.unidades,
  });

  @override
  State<NuevoCultivoScreen> createState() => _NuevoCultivoScreenState();
}

class _NuevoCultivoScreenState extends State<NuevoCultivoScreen> {
  final ProduccionService _servicio = ProduccionService();
  final _campania = TextEditingController(text: campaniaSugerida());
  final _material = TextEditingController();
  late final String grupoId = _servicio.nuevoIdGrupo();

  String? cultivo;
  String? loteId;
  bool guardando = false;

  @override
  void dispose() {
    _campania.dispose();
    _material.dispose();
    super.dispose();
  }

  String get _nombre {
    final lote = widget.unidades
        .where((u) => u.unidadId == loteId)
        .map((u) => u.nombre)
        .firstOrNull;
    return [
      '${nombreCultivo(cultivo)} ${_campania.text.trim()}'.trim(),
      if (lote != null) lote,
    ].join(' - ');
  }

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (cultivo == null) {
      _avisar('Elegí el cultivo.');
      return;
    }
    if (loteId == null) {
      _avisar('Elegí el lote (si no hay, cargalo primero).');
      return;
    }
    setState(() => guardando = true);
    try {
      await _servicio.crearGrupo(GrupoProductivo(
        grupoId: grupoId,
        activoAgroId: widget.activoAgroId,
        actividad: 'agricultura',
        nombre: _nombre,
        creadoPor: uid,
        fechaCreacion: DateTime.now(),
        unidadInicialId: loteId,
        cultivo: cultivo,
        campania: _campania.text.trim().isEmpty ? null : _campania.text.trim(),
        material: _material.text.trim().isEmpty ? null : _material.text.trim(),
      ));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => guardando = false);
      _avisar('No se pudo guardar: $e');
    }
  }

  void _avisar(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    // Primero los lotes; después el resto de las unidades.
    final unidades = [...widget.unidades]..sort((a, b) {
        final la = a.tipo == TipoUnidadProductiva.lote ? 0 : 1;
        final lb = b.tipo == TipoUnidadProductiva.lote ? 0 : 1;
        return la != lb ? la - lb : a.nombre.compareTo(b.nombre);
      });

    return Scaffold(
      appBar: BarraCampo(
        title: const Text('Nuevo cultivo'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const EtiquetaCampo('¿Qué cultivo?'),
          OpcionesTocar<String>(
            opciones: cultivosBase,
            elegida: cultivo,
            etiqueta: nombreCultivo,
            alElegir: (c) => setState(() => cultivo = c),
          ),
          const EtiquetaCampo('¿En qué lote?'),
          if (unidades.isEmpty)
            const Text(
              'Todavía no hay lotes. Volvé y tocá "+ Lote o potrero".',
              style: TextStyle(color: EstiloProduccion.textoSuave),
            )
          else
            OpcionesTocar<String>(
              opciones: unidades.map((u) => u.unidadId).toList(),
              elegida: loteId,
              etiqueta: (id) =>
                  unidades.firstWhere((u) => u.unidadId == id).nombre,
              alElegir: (id) => setState(() => loteId = id),
            ),
          const EtiquetaCampo('Campaña'),
          TextField(
            controller: _campania,
            onChanged: (_) => setState(() {}),
            decoration: decoracionCampo(ayuda: 'Ej.: 2026/27'),
          ),
          const EtiquetaCampo('Variedad o híbrido (opcional)'),
          TextField(
            controller: _material,
            decoration: decoracionCampo(ayuda: 'Ej.: DM 46i20'),
          ),
          if (cultivo != null) ...[
            const SizedBox(height: 18),
            Text(
              'Se va a llamar: $_nombre',
              style: const TextStyle(
                  fontSize: 14, color: EstiloProduccion.textoSuave),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: 'Guardar cultivo',
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
