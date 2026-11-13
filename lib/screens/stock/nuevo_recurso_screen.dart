import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/recurso_agro_model.dart';
import '../../services/recurso_service.dart';
import '../produccion/produccion_estilo.dart';
import 'stock_textos.dart';

/// GAP-STOCK-01 (13/11/2026): cargar un producto nuevo.
/// Nace con saldo 0; la cantidad inicial entra como movimiento "entrada".
class NuevoRecursoScreen extends StatefulWidget {
  final String activoAgroId;

  const NuevoRecursoScreen({super.key, required this.activoAgroId});

  @override
  State<NuevoRecursoScreen> createState() => _NuevoRecursoScreenState();
}

class _NuevoRecursoScreenState extends State<NuevoRecursoScreen> {
  final RecursoService _servicio = RecursoService();
  final _nombre = TextEditingController();
  final _inicial = TextEditingController();
  final _minimo = TextEditingController();
  final _notas = TextEditingController();

  String? tipo;
  String? unidad;
  bool guardando = false;

  @override
  void dispose() {
    for (final c in [_nombre, _inicial, _minimo, _notas]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (tipo == null) {
      _avisar('Elegí el tipo de producto.');
      return;
    }
    if (_nombre.text.trim().isEmpty) {
      _avisar('Falta el nombre.');
      return;
    }
    if (unidad == null) {
      _avisar('Elegí la unidad.');
      return;
    }
    if (_inicial.text.trim().isNotEmpty && leerNumero(_inicial.text) == null) {
      _avisar('La cantidad inicial tiene que ser un número.');
      return;
    }
    if (_minimo.text.trim().isNotEmpty && leerNumero(_minimo.text) == null) {
      _avisar('El mínimo tiene que ser un número.');
      return;
    }

    setState(() => guardando = true);
    try {
      await _servicio.crearRecursoConStockInicial(
        recurso: RecursoAgro(
          recursoId: '',
          activoAgroId: widget.activoAgroId,
          tipo: tipo!,
          nombre: _nombre.text.trim(),
          descripcion: '',
          unidad: unidad!,
          cantidadActual: 0,
          cantidadMinima: leerNumero(_minimo.text) ?? 0,
          estado: 'disponible',
          observaciones:
              _notas.text.trim().isEmpty ? null : _notas.text.trim(),
        ),
        cantidadInicial: leerNumero(_inicial.text) ?? 0,
        usuarioId: uid,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => guardando = false);
      _avisar(mensajeErrorStock(e));
    }
  }

  void _avisar(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    const teclado = TextInputType.numberWithOptions(decimal: true);
    final u = unidad == null ? '' : ' (${nombreUnidadStock(unidad!).toLowerCase()})';
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Nuevo producto'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const EtiquetaCampo('Tipo'),
          OpcionesTocar<String>(
            opciones: tiposRecursoStock,
            elegida: tipo,
            etiqueta: nombreTipoRecurso,
            alElegir: (t) => setState(() => tipo = t),
          ),
          const EtiquetaCampo('Nombre'),
          TextField(
            controller: _nombre,
            decoration: decoracionCampo(ayuda: 'Ej.: Glifosato 66%'),
          ),
          const EtiquetaCampo('Unidad'),
          OpcionesTocar<String>(
            opciones: unidadesStock,
            elegida: unidad,
            etiqueta: nombreUnidadStock,
            alElegir: (v) => setState(() => unidad = v),
          ),
          EtiquetaCampo('¿Cuánto tenés hoy?$u'),
          TextField(
            controller: _inicial,
            keyboardType: teclado,
            decoration: decoracionCampo(ayuda: 'Ej.: 200'),
          ),
          EtiquetaCampo('Mínimo para avisar (opcional)$u'),
          TextField(
            controller: _minimo,
            keyboardType: teclado,
            decoration: decoracionCampo(ayuda: 'Ej.: 40'),
          ),
          const EtiquetaCampo('Notas (opcional)'),
          TextField(
            controller: _notas,
            maxLines: 2,
            decoration: decoracionCampo(ayuda: 'Ej.: depósito del galpón 2'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Lo que tenés hoy queda registrado como "Stock inicial", con la '
            'fecha y quién lo cargó. Después cada entrada y cada uso suma o '
            'resta, y nada se borra.',
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
            texto: 'Guardar producto',
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
