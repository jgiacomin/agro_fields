import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/movimiento_model.dart';
import '../../services/movimiento_service.dart';
import '../produccion/produccion_estilo.dart';
import 'traslados_textos.dart';

/// AF-089: cargar un traslado simple. Una pantalla, preguntas simples.
class NuevoTrasladoScreen extends StatefulWidget {
  final String activoAgroId;

  const NuevoTrasladoScreen({super.key, required this.activoAgroId});

  @override
  State<NuevoTrasladoScreen> createState() => _NuevoTrasladoScreenState();
}

class _NuevoTrasladoScreenState extends State<NuevoTrasladoScreen> {
  final MovimientoService _servicio = MovimientoService();
  final _carga = TextEditingController();
  final _cantidad = TextEditingController();
  final _destino = TextEditingController();
  final _transportista = TextEditingController();
  final _patente = TextEditingController();
  final _guia = TextEditingController();
  final _observaciones = TextEditingController();

  /// ID armado al abrir: tocar "Guardar" dos veces no lo duplica.
  late final String movimientoId =
      'mov_${DateTime.now().millisecondsSinceEpoch}';

  String actividad = 'ganaderia';
  String unidad = 'cabezas';
  DateTime fechaSalida = DateTime.now();
  bool yaSalio = false;
  bool guardando = false;

  @override
  void dispose() {
    for (final c in [
      _carga,
      _cantidad,
      _destino,
      _transportista,
      _patente,
      _guia,
      _observaciones
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _texto(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final cantidad =
        double.tryParse(_cantidad.text.trim().replaceAll(',', '.')) ?? 0;
    final m = Movimiento(
      movimientoId: movimientoId,
      activoAgroId: widget.activoAgroId,
      actividad: actividad,
      destinoDescripcion: _destino.text.trim(),
      carga: _carga.text.trim(),
      cantidadDeclarada: cantidad,
      unidad: unidad,
      transportista: _texto(_transportista),
      patente: _texto(_patente)?.toUpperCase(),
      guia: _texto(_guia),
      fechaSalida: fechaSalida,
      estado: yaSalio ? EstadoMovimiento.enCamino : EstadoMovimiento.programado,
      observaciones: _texto(_observaciones),
      cargadoPor: uid,
      fechaCarga: DateTime.now(),
    );
    final errores = m.validar();
    if (errores.isNotEmpty) {
      _avisar(errores.first);
      return;
    }
    setState(() => guardando = true);
    try {
      await _servicio.registrar(m);
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
    final unidades = Movimiento.unidadesPorActividad[actividad]!;
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Nuevo traslado'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const EtiquetaCampo('¿Qué se traslada?'),
          OpcionesTocar<String>(
            opciones: Movimiento.actividades,
            elegida: actividad,
            etiqueta: nombreActividad,
            alElegir: (a) => setState(() {
              actividad = a;
              unidad = Movimiento.unidadesPorActividad[a]!.first;
            }),
          ),
          const EtiquetaCampo('Detalle de la carga'),
          TextField(
            controller: _carga,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(
                ayuda: actividad == 'ganaderia'
                    ? 'Ej.: Novillos, vacas, terneros'
                    : 'Ej.: Soja, maíz, colmenas'),
          ),
          const EtiquetaCampo('Cantidad'),
          TextField(
            controller: _cantidad,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoracionCampo(ayuda: 'Ej.: 50'),
          ),
          if (unidades.length > 1) ...[
            const EtiquetaCampo('Unidad'),
            OpcionesTocar<String>(
              opciones: unidades,
              elegida: unidad,
              etiqueta: (u) => u,
              alElegir: (u) => setState(() => unidad = u),
            ),
          ],
          const EtiquetaCampo('¿A dónde va?'),
          TextField(
            controller: _destino,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(
                ayuda: 'Ej.: Feedlot Los Aromos, Cafferata (Santa Fe)'),
          ),
          const EtiquetaCampo('Fecha de salida'),
          OutlinedButton.icon(
            onPressed: () async {
              final hoy = DateTime.now();
              final f = await showDatePicker(
                context: context,
                initialDate: fechaSalida,
                firstDate: DateTime(hoy.year - 1),
                lastDate: DateTime(hoy.year + 1),
              );
              if (f != null) setState(() => fechaSalida = f);
            },
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(fechaCorta(fechaSalida)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              alignment: Alignment.centerLeft,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ya salió (está en camino)'),
            value: yaSalio,
            onChanged: (v) => setState(() => yaSalio = v),
          ),
          const EtiquetaCampo('Transportista (opcional)'),
          TextField(
            controller: _transportista,
            textCapitalization: TextCapitalization.words,
            decoration: decoracionCampo(ayuda: 'Nombre o empresa'),
          ),
          const EtiquetaCampo('Patente (opcional)'),
          TextField(
            controller: _patente,
            textCapitalization: TextCapitalization.characters,
            decoration: decoracionCampo(ayuda: 'Ej.: AB123CD'),
          ),
          const EtiquetaCampo('Número de guía o DTe (opcional)'),
          TextField(controller: _guia, decoration: decoracionCampo()),
          const EtiquetaCampo('Notas (opcional)'),
          TextField(
            controller: _observaciones,
            maxLines: 2,
            decoration: decoracionCampo(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda como declarado. Al llegar, anotás cuánto se recibió y el '
            'sistema avisa si no coincide. Recordá registrar la baja o el alta '
            'en Producción si corresponde. No reemplaza la guía oficial.',
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
            texto: 'Guardar traslado',
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
