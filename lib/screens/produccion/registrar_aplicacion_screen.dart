import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/evento_productivo_model.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../services/calculo_agricola.dart';
import '../../services/produccion_service.dart';
import 'cultivos_textos.dart';
import 'produccion_estilo.dart';

/// GAP-APLI-01 (13/11/2026): registrar una aplicación terrestre.
/// Hectáreas, producto, dosis, quién aplicó, receta y condiciones.
/// Es un evento productivo más: solo agregar, queda como declarado.
/// Con viento alto avisa antes de guardar, pero no bloquea.
class RegistrarAplicacionScreen extends StatefulWidget {
  final GrupoProductivo grupo;

  const RegistrarAplicacionScreen({super.key, required this.grupo});

  @override
  State<RegistrarAplicacionScreen> createState() =>
      _RegistrarAplicacionScreenState();
}

class _RegistrarAplicacionScreenState extends State<RegistrarAplicacionScreen> {
  final ProduccionService _servicio = ProduccionService();
  final _ha = TextEditingController();
  final _producto = TextEditingController();
  final _dosis = TextEditingController();
  final _aplicador = TextEditingController();
  final _receta = TextEditingController();
  final _viento = TextEditingController();
  final _temperatura = TextEditingController();
  final _humedad = TextEditingController();
  final _notas = TextEditingController();
  late final String eventoId = _servicio.nuevoIdEvento();

  DateTime fecha = DateTime.now();
  bool guardando = false;

  List<TextEditingController> get _todos => [
        _ha,
        _producto,
        _dosis,
        _aplicador,
        _receta,
        _viento,
        _temperatura,
        _humedad,
        _notas,
      ];

  @override
  void dispose() {
    for (final c in _todos) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) {
    final t = c.text.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  String? _txt(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<bool> _confirmarViento(double viento) async {
    final seguir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Viento alto'),
        content: Text(
          'Cargaste ${numeroAgro(viento)} km/h. Con más de '
          '${numeroAgro(vientoMaximoAviso)} km/h aumenta la deriva del '
          'producto. Revisá lo que pide tu provincia.\n\n'
          '¿Guardar igual? Queda anotado en el registro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Revisar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Guardar igual'),
          ),
        ],
      ),
    );
    return seguir == true;
  }

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final evento = EventoProductivo(
      eventoId: eventoId,
      activoAgroId: widget.grupo.activoAgroId,
      grupoId: widget.grupo.grupoId,
      unidadId: widget.grupo.unidadInicialId,
      tipo: TipoEventoProductivo.aplicacion,
      fechaHecho: fecha,
      fechaCarga: DateTime.now(),
      cargadoPor: uid,
      observaciones: _txt(_notas),
      superficieHa: _num(_ha),
      tratamiento: _txt(_producto),
      dosis: _txt(_dosis),
      responsable: _txt(_aplicador),
      recetaNumero: _txt(_receta),
      vientoKmh: _num(_viento),
      temperatura: _num(_temperatura),
      humedadAmbiente: _num(_humedad),
    );
    final errores = evento.validar();
    if (errores.isNotEmpty) {
      _avisar(errores.first);
      return;
    }
    if (vientoAlto(evento.vientoKmh) &&
        !await _confirmarViento(evento.vientoKmh!)) {
      return;
    }
    if (!mounted) return;
    setState(() => guardando = true);
    try {
      await _servicio.registrarEvento(evento);
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
    const teclado = TextInputType.numberWithOptions(decimal: true);
    const tecladoSigno =
        TextInputType.numberWithOptions(decimal: true, signed: true);
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Registrar aplicación'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const EtiquetaCampo('Fecha'),
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
          const EtiquetaCampo('Hectáreas aplicadas'),
          TextField(
            controller: _ha,
            keyboardType: teclado,
            decoration: decoracionCampo(ayuda: 'Ej.: 80'),
          ),
          const EtiquetaCampo('Producto'),
          TextField(
            controller: _producto,
            decoration: decoracionCampo(ayuda: 'Ej.: Glifosato 66%'),
          ),
          const EtiquetaCampo('Dosis'),
          TextField(
            controller: _dosis,
            decoration: decoracionCampo(ayuda: 'Ej.: 2 l/ha'),
          ),
          const EtiquetaCampo('¿Quién aplicó? (opcional)'),
          TextField(
            controller: _aplicador,
            decoration:
                decoracionCampo(ayuda: 'Nombre o contratista'),
          ),
          const EtiquetaCampo('Número de receta agronómica (opcional)'),
          TextField(controller: _receta, decoration: decoracionCampo()),
          const EtiquetaCampo('Condiciones al aplicar (opcional)'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _viento,
                  keyboardType: teclado,
                  decoration: decoracionCampo(ayuda: 'Viento km/h'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _temperatura,
                  keyboardType: tecladoSigno,
                  decoration: decoracionCampo(ayuda: 'Temp. °C'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _humedad,
                  keyboardType: teclado,
                  decoration: decoracionCampo(ayuda: 'Humedad %'),
                ),
              ),
            ],
          ),
          const EtiquetaCampo('Notas (opcional)'),
          TextField(
            controller: _notas,
            maxLines: 2,
            decoration: decoracionCampo(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda como declarado. No se edita ni se borra: si hay un error, '
            'cargá una aplicación nueva y anotalo en las notas.',
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
            texto: 'Guardar aplicación',
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
