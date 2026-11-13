import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/evento_productivo_model.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../services/produccion_service.dart';
import 'cultivos_textos.dart';
import 'produccion_estilo.dart';
import '../../widgets/barra_campo.dart';

/// GAP-MON-01 (13/11/2026): registrar un monitoreo.
/// Qué se miró, qué se vio, el nivel y de dónde sale el dato.
/// Es un evento productivo más: solo agregar, queda como declarado.
class RegistrarMonitoreoScreen extends StatefulWidget {
  final GrupoProductivo grupo;

  const RegistrarMonitoreoScreen({super.key, required this.grupo});

  @override
  State<RegistrarMonitoreoScreen> createState() =>
      _RegistrarMonitoreoScreenState();
}

class _RegistrarMonitoreoScreenState extends State<RegistrarMonitoreoScreen> {
  final ProduccionService _servicio = ProduccionService();
  final _visto = TextEditingController();
  final _recomendacion = TextEditingController();
  late final String eventoId = _servicio.nuevoIdEvento();

  DateTime fecha = DateTime.now();
  String? objetivo;
  String? nivel;
  String fuente = 'recorrida';
  bool guardando = false;

  @override
  void dispose() {
    _visto.dispose();
    _recomendacion.dispose();
    super.dispose();
  }

  String? _txt(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final evento = EventoProductivo(
      eventoId: eventoId,
      activoAgroId: widget.grupo.activoAgroId,
      grupoId: widget.grupo.grupoId,
      unidadId: widget.grupo.unidadInicialId,
      tipo: TipoEventoProductivo.monitoreo,
      fechaHecho: fecha,
      fechaCarga: DateTime.now(),
      cargadoPor: uid,
      observaciones: _txt(_visto),
      objetivoMonitoreo: objetivo,
      nivel: nivel,
      fuenteDato: fuente,
      recomendacion: _txt(_recomendacion),
    );
    final errores = evento.validar();
    if (errores.isNotEmpty) {
      _avisar(errores.first);
      return;
    }
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
    return Scaffold(
      appBar: BarraCampo(
        title: const Text('Registrar monitoreo'),
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
          const EtiquetaCampo('¿Qué miraste?'),
          OpcionesTocar<String>(
            opciones: objetivosMonitoreo,
            elegida: objetivo,
            etiqueta: nombreObjetivoMonitoreo,
            alElegir: (o) => setState(() => objetivo = o),
          ),
          const EtiquetaCampo('¿Qué viste?'),
          TextField(
            controller: _visto,
            maxLines: 3,
            decoration: decoracionCampo(
                ayuda: 'Ej.: chinche verde en el borde norte, 2 por metro'),
          ),
          const EtiquetaCampo('Nivel'),
          OpcionesTocar<String>(
            opciones: nivelesMonitoreo,
            elegida: nivel,
            etiqueta: nombreNivel,
            alElegir: (n) => setState(() => nivel = n),
          ),
          const EtiquetaCampo('¿De dónde sale el dato?'),
          OpcionesTocar<String>(
            opciones: fuentesDato,
            elegida: fuente,
            etiqueta: nombreFuenteDato,
            alElegir: (f) => setState(() => fuente = f),
          ),
          const EtiquetaCampo('Recomendación (opcional)'),
          TextField(
            controller: _recomendacion,
            maxLines: 2,
            decoration: decoracionCampo(ayuda: 'Ej.: volver a mirar en 5 días'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda como declarado. No se edita ni se borra: si cambia la '
            'situación, cargá un monitoreo nuevo. El último es el que vale '
            'para la alerta.',
            style: TextStyle(
                fontSize: 14, height: 1.5, color: EstiloProduccion.textoSuave),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: 'Guardar monitoreo',
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
