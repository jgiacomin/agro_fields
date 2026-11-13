import 'package:flutter/material.dart';

import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';
import 'suelo_textos.dart';

/// GAP-SUELO-01 (13/11/2026): cargar o corregir el suelo del campo.
/// Todo es opcional: lo que no se sabe queda "Sin información".
/// Se guarda con el camino que ya existía (actualizarSuelo): queda en el
/// historial y en la auditoría. Queda como "declarado": lo dice el
/// usuario; verificarlo es de otra persona.
class SueloActivoScreen extends StatefulWidget {
  final ActivoAgroV2 activo;

  const SueloActivoScreen({super.key, required this.activo});

  @override
  State<SueloActivoScreen> createState() => _SueloActivoScreenState();
}

class _SueloActivoScreenState extends State<SueloActivoScreen> {
  final ActivoAgroServiceV2 _activos = ActivoAgroServiceV2();

  final _ph = TextEditingController();
  final _materiaOrganica = TextEditingController();
  final _limitaciones = TextEditingController();
  final _observaciones = TextEditingController();

  String? textura;
  String? drenaje;
  String? profundidad;
  String? salinidad;
  String? erosion;
  String? clase;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    final s = widget.activo.suelo;
    textura = s.textura;
    drenaje = s.drenaje;
    profundidad = s.profundidad;
    salinidad = s.salinidad;
    erosion = s.erosion;
    clase = s.clase;
    if (s.ph != null) _ph.text = _numero(s.ph!);
    if (s.materiaOrganica != null) {
      _materiaOrganica.text = _numero(s.materiaOrganica!);
    }
    _limitaciones.text = s.limitaciones ?? '';
    _observaciones.text = s.observaciones ?? '';
  }

  @override
  void dispose() {
    _ph.dispose();
    _materiaOrganica.dispose();
    _limitaciones.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  String _numero(double v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toString().replaceAll('.', ',');

  void _avisar(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _guardar() async {
    if (guardando) return;
    final ph = leerDecimal(_ph.text);
    final mo = leerDecimal(_materiaOrganica.text);
    final errores = validarSuelo(ph: ph, materiaOrganica: mo);
    if (errores.isNotEmpty) {
      _avisar(errores.first);
      return;
    }
    final suelo = armarSuelo(
      anterior: widget.activo.suelo,
      ahora: DateTime.now(),
      textura: textura,
      drenaje: drenaje,
      ph: ph,
      materiaOrganica: mo,
      profundidad: profundidad,
      salinidad: salinidad,
      erosion: erosion,
      clase: clase,
      limitaciones: _limitaciones.text,
      observaciones: _observaciones.text,
    );
    setState(() => guardando = true);
    try {
      await _activos.actualizarSuelo(widget.activo.activoId, suelo);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => guardando = false);
      _avisar('No se pudo guardar: $e');
    }
  }

  /// Opciones para tocar. Tocar la elegida otra vez la saca
  /// (vuelve a "Sin información").
  Widget _opciones(
    List<String> opciones,
    String? elegida,
    ValueChanged<String?> cambiar, {
    String Function(String)? etiqueta,
  }) {
    return OpcionesTocar<String>(
      opciones: opciones,
      elegida: elegida,
      etiqueta: etiqueta ?? textoOpcion,
      alElegir: (v) => setState(() => cambiar(elegida == v ? null : v)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(title: const Text('Suelo del campo')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const SizedBox(height: 12),
          const Text(
            'Completá lo que sepas. Lo que no sepas dejalo vacío: queda '
            'como "Sin información" y lo podés completar más adelante.',
            style: TextStyle(
                fontSize: 14, height: 1.5, color: EstiloProduccion.textoSuave),
          ),
          const EtiquetaCampo('Textura'),
          _opciones(texturasSuelo, textura, (v) => textura = v),
          const EtiquetaCampo('Drenaje'),
          _opciones(drenajesSuelo, drenaje, (v) => drenaje = v),
          const EtiquetaCampo('pH (opcional)'),
          TextField(
            controller: _ph,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoracionCampo(ayuda: 'Ej.: 6,5'),
          ),
          const EtiquetaCampo('Materia orgánica % (opcional)'),
          TextField(
            controller: _materiaOrganica,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoracionCampo(ayuda: 'Ej.: 3,2'),
          ),
          const EtiquetaCampo('Profundidad'),
          _opciones(profundidadesSuelo, profundidad, (v) => profundidad = v),
          const EtiquetaCampo('Salinidad'),
          _opciones(salinidadesSuelo, salinidad, (v) => salinidad = v),
          const EtiquetaCampo('Erosión'),
          _opciones(erosionesSuelo, erosion, (v) => erosion = v),
          const EtiquetaCampo('Clase de capacidad de uso (opcional)'),
          _opciones(clasesCapacidadUso, clase, (v) => clase = v,
              etiqueta: (c) => 'Clase $c'),
          const EtiquetaCampo('Limitaciones (opcional)'),
          TextField(
            controller: _limitaciones,
            maxLines: 2,
            decoration: decoracionCampo(ayuda: 'Ej.: tosca a 60 cm, bajos que se anegan'),
          ),
          const EtiquetaCampo('Observaciones (opcional)'),
          TextField(
            controller: _observaciones,
            maxLines: 3,
            decoration: decoracionCampo(ayuda: 'Ej.: análisis de 2025 del lote norte'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda como declarado (lo informás vos). Si tenés un análisis de '
            'laboratorio, cargalo en Documentos del campo. Cada cambio queda '
            'en el historial.',
            style: TextStyle(
                fontSize: 14, height: 1.5, color: EstiloProduccion.textoSuave),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: 'Guardar suelo',
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
