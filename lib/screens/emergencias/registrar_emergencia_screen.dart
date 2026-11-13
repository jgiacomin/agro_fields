import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/evento_afectacion_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../produccion/produccion_estilo.dart';
import 'emergencias_textos.dart';
import '../../widgets/barra_campo.dart';

/// AF-092: registrar una emergencia del campo.
/// Reutiliza EventoAfectacion y ActivoAgroServiceV2.registrarEventoAfectacion
/// (colección eventos_afectacion con su regla, historial y auditoría).
/// Queda como "declarado": declarado no es verificado.
class RegistrarEmergenciaScreen extends StatefulWidget {
  final String activoAgroId;

  const RegistrarEmergenciaScreen({super.key, required this.activoAgroId});

  @override
  State<RegistrarEmergenciaScreen> createState() =>
      _RegistrarEmergenciaScreenState();
}

class _RegistrarEmergenciaScreenState extends State<RegistrarEmergenciaScreen> {
  final ActivoAgroServiceV2 _activos = ActivoAgroServiceV2();
  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _hectareas = TextEditingController();

  /// ID armado al abrir: tocar "Guardar" dos veces no duplica el evento.
  late final String eventoId = 'emer_${DateTime.now().millisecondsSinceEpoch}';

  String? tipo;
  String gravedad = 'medio';
  DateTime desde = DateTime.now();
  bool guardando = false;

  @override
  void dispose() {
    _descripcion.dispose();
    _hectareas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (tipo == null) {
      _avisar('Elegí qué pasó.');
      return;
    }
    final textoHa = _hectareas.text.trim().replaceAll(',', '.');
    final hectareas = textoHa.isEmpty ? null : double.tryParse(textoHa);
    if (textoHa.isNotEmpty && (hectareas == null || hectareas < 0)) {
      _avisar('Las hectáreas tienen que ser un número.');
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _avisar('Tenés que ingresar de nuevo.');
      return;
    }

    final descripcion = _descripcion.text.trim().isEmpty
        ? nombreTipoEmergencia(tipo)
        : _descripcion.text.trim();

    final evento = EventoAfectacion(
      eventoId: eventoId,
      activoAgroId: widget.activoAgroId,
      tipoEvento: grupoEmergencia(tipo!),
      subtipoEvento: tipo,
      fechaInicio: desde,
      descripcion: descripcion,
      origen: 'declaracion_usuario',
      estado: 'declarado',
      usuarioRegistrador: uid,
      fechaRegistro: DateTime.now(),
      afectaciones: [
        Afectacion(
          objetoTipo: 'ActivoAgro',
          objetoId: widget.activoAgroId,
          descripcion: descripcion,
          superficieAfectada: hectareas,
          unidad: hectareas == null ? null : 'ha',
          magnitud: hectareas,
          nivel: gravedad,
          estado: 'declarado',
        ),
      ],
    );

    setState(() => guardando = true);
    try {
      await _activos.registrarEventoAfectacion(widget.activoAgroId, evento);
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
      appBar: BarraCampo(
        title: const Text('Registrar emergencia'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const EtiquetaCampo('¿Qué pasó?'),
          OpcionesTocar<String>(
            opciones: tiposEmergencia,
            elegida: tipo,
            etiqueta: nombreTipoEmergencia,
            alElegir: (t) => setState(() => tipo = t),
          ),
          const EtiquetaCampo('¿Desde cuándo?'),
          OutlinedButton.icon(
            onPressed: () async {
              final hoy = DateTime.now();
              final f = await showDatePicker(
                context: context,
                initialDate: desde,
                firstDate: DateTime(hoy.year - 5),
                lastDate: hoy,
                helpText: '¿Desde cuándo?',
              );
              if (f != null) setState(() => desde = f);
            },
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(fechaCorta(desde)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              alignment: Alignment.centerLeft,
            ),
          ),
          const EtiquetaCampo('¿Qué tan grave es?'),
          OpcionesTocar<String>(
            opciones: gravedades,
            elegida: gravedad,
            etiqueta: nombreGravedad,
            alElegir: (g) => setState(() => gravedad = g),
          ),
          const EtiquetaCampo('Hectáreas afectadas (opcional)'),
          TextField(
            controller: _hectareas,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoracionCampo(ayuda: 'Ej.: 120'),
          ),
          const EtiquetaCampo('Contá qué pasó (opcional)'),
          TextField(
            controller: _descripcion,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(
                ayuda: 'Ej.: El arroyo desbordó y tapó el potrero 3'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda en el historial del campo como declarado por vos. '
            'No reemplaza el aviso a los organismos oficiales.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: EstiloProduccion.textoSuave,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: 'Guardar emergencia',
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
