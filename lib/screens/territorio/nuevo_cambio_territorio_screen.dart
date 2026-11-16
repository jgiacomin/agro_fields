import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/cambio_territorio_model.dart';
import '../../services/territorio_service.dart';
import '../../widgets/adjuntar_archivo_boton.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';
import 'territorio_textos.dart';

/// AF-109: cargar un cambio del territorio (o corregir uno anterior).
/// Una pantalla, una pregunta por bloque; todo se elige tocando salvo la
/// descripción. Queda "declarado" o "con documento" si se adjunta archivo.
class NuevoCambioTerritorioScreen extends StatefulWidget {
  final String activoAgroId;

  /// Si viene, este registro corrige al anterior (se precarga).
  final CambioTerritorio? corrige;

  const NuevoCambioTerritorioScreen({
    super.key,
    required this.activoAgroId,
    this.corrige,
  });

  @override
  State<NuevoCambioTerritorioScreen> createState() =>
      _NuevoCambioTerritorioScreenState();
}

class _NuevoCambioTerritorioScreenState
    extends State<NuevoCambioTerritorioScreen> {
  final TerritorioService _servicio = TerritorioService();
  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _realizadoPor = TextEditingController();

  /// ID armado al abrir: tocar "Guardar" dos veces no duplica el registro.
  late final String cambioId = _servicio.nuevoId();

  String? tipo;
  String? fuente;
  DateTime desde = DateTime.now();
  DateTime? hasta;
  bool duroUnTiempo = false;
  String? archivoRuta;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.corrige;
    if (c != null) {
      tipo = c.tipo;
      fuente = c.fuente;
      desde = c.fechaDesde;
      hasta = c.fechaHasta;
      duroUnTiempo = c.fechaHasta != null;
      _descripcion.text = c.descripcion;
      _realizadoPor.text = c.realizadoPor ?? '';
    }
  }

  @override
  void dispose() {
    _descripcion.dispose();
    _realizadoPor.dispose();
    super.dispose();
  }

  Future<String> _subir(String nombre, Uint8List bytes, String tipoArchivo) {
    return _servicio.subirArchivo(
      activoId: widget.activoAgroId,
      cambioId: cambioId,
      nombreArchivo: nombre,
      bytes: bytes,
      contentType: tipoArchivo,
    );
  }

  Future<DateTime?> _elegirFecha(DateTime inicial, String ayuda) {
    final hoy = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: inicial.isAfter(hoy) ? hoy : inicial,
      firstDate: DateTime(1900),
      lastDate: hoy,
      helpText: ayuda,
    );
  }

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _avisar('Tenés que ingresar de nuevo.');
      return;
    }
    if (tipo == null) {
      _avisar('Elegí qué cambió.');
      return;
    }
    if (fuente == null) {
      _avisar('Elegí cómo lo sabés.');
      return;
    }
    final realizadoPor = _realizadoPor.text.trim();
    final cambio = CambioTerritorio(
      cambioId: cambioId,
      activoAgroId: widget.activoAgroId,
      tipo: tipo!,
      fechaDesde: desde,
      fechaHasta: duroUnTiempo ? hasta : null,
      descripcion: _descripcion.text.trim(),
      realizadoPor: realizadoPor.isEmpty ? null : realizadoPor,
      fuente: fuente!,
      archivoRuta: archivoRuta,
      estadoDato: CambioTerritorio.estadoSegunArchivo(archivoRuta),
      corrigeCambioId: widget.corrige?.cambioId,
      cargadoPor: uid,
      fechaCarga: DateTime.now(),
    );
    final errores = cambio.validar();
    if (errores.isNotEmpty) {
      _avisar(errores.first);
      return;
    }

    setState(() => guardando = true);
    try {
      await _servicio.registrar(cambio);
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

  Widget _botonFecha(String texto, VoidCallback alTocar) {
    return OutlinedButton.icon(
      onPressed: alTocar,
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(texto),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esCorreccion = widget.corrige != null;
    return Scaffold(
      appBar: BarraCampo(
        title: Text(esCorreccion ? 'Corregir cambio' : 'Cambio del territorio'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          if (esCorreccion) ...[
            const SizedBox(height: 12),
            const EstadoVacio(
              icono: Icons.edit_note,
              texto: 'Este registro reemplaza al anterior. El anterior no se '
                  'borra: queda guardado como "corregido".',
            ),
          ],
          const EtiquetaCampo('¿Qué cambió?'),
          OpcionesTocar<String>(
            opciones: CambioTerritorio.tipos,
            elegida: tipo,
            etiqueta: nombreTipoCambio,
            alElegir: (t) => setState(() => tipo = t),
          ),
          const EtiquetaCampo('¿Cuándo pasó? (puede ser aproximado)'),
          _botonFecha(periodoTexto(desde, null), () async {
            final f = await _elegirFecha(desde, '¿Cuándo pasó?');
            if (f != null) setState(() => desde = f);
          }),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Duró un tiempo (tiene fecha de fin)'),
            value: duroUnTiempo,
            onChanged: (v) => setState(() {
              duroUnTiempo = v;
              if (v && hasta == null) hasta = DateTime.now();
            }),
          ),
          if (duroUnTiempo)
            _botonFecha(
              'Hasta: ${periodoTexto(hasta ?? DateTime.now(), null)}',
              () async {
                final f = await _elegirFecha(
                    hasta ?? DateTime.now(), '¿Hasta cuándo?');
                if (f != null) setState(() => hasta = f);
              },
            ),
          const EtiquetaCampo('Contá qué cambió'),
          TextField(
            controller: _descripcion,
            maxLines: 3,
            maxLength: CambioTerritorio.largoMaximoDescripcion,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(
                ayuda: 'Ej.: Se desmontaron 80 ha del monte del fondo'),
          ),
          const EtiquetaCampo('¿Quién lo hizo? (opcional)'),
          TextField(
            controller: _realizadoPor,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(
                ayuda: 'Ej.: el dueño anterior, Vialidad, un vecino'),
          ),
          const EtiquetaCampo('¿Cómo lo sabés?'),
          OpcionesTocar<String>(
            opciones: CambioTerritorio.fuentes,
            elegida: fuente,
            etiqueta: nombreFuente,
            alElegir: (f) => setState(() => fuente = f),
          ),
          const EtiquetaCampo('Foto, plano o permiso (opcional)'),
          AdjuntarArchivoBoton(
            texto: 'Adjuntar foto o PDF',
            subir: _subir,
            rutaActual: archivoRuta,
            alSubir: (ruta) => setState(() => archivoRuta = ruta),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda como declarado por vos (o "con documento" si adjuntás un '
            'archivo). Es un hecho contado: no dice qué causó qué. No se '
            'edita ni se borra; si hay un error, tocá "Corregir".',
            style: TextStyle(
                fontSize: 14, height: 1.5, color: EstiloProduccion.textoSuave),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: esCorreccion ? 'Guardar corrección' : 'Guardar cambio',
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
