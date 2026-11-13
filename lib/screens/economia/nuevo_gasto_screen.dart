import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/gasto_model.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../services/gasto_service.dart';
import '../../services/produccion_service.dart';
import '../../widgets/adjuntar_archivo_boton.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';
import 'economia_textos.dart';

/// GAP-ECO-01 (13/11/2026): cargar un gasto (o corregir uno).
/// Se completa tocando: monto, moneda, categoría, actividad y, si
/// corresponde, el cultivo o rodeo. Comprobante opcional.
class NuevoGastoScreen extends StatefulWidget {
  final String activoAgroId;

  /// Si viene, es una corrección: arranca con esos datos y el gasto nuevo
  /// dice a cuál corrige. El original no se borra.
  final Gasto? corrige;

  const NuevoGastoScreen({super.key, required this.activoAgroId, this.corrige});

  @override
  State<NuevoGastoScreen> createState() => _NuevoGastoScreenState();
}

class _NuevoGastoScreenState extends State<NuevoGastoScreen> {
  final GastoService _servicio = GastoService();
  final _monto = TextEditingController();
  final _proveedor = TextEditingController();
  final _descripcion = TextEditingController();
  late final String gastoId = _servicio.nuevoId();

  DateTime fecha = DateTime.now();
  String moneda = 'ARS';
  String? categoria;
  String actividad = 'general';
  String? grupoId;
  String? comprobanteRuta;
  bool anular = false;
  bool guardando = false;
  List<GrupoProductivo> grupos = [];

  @override
  void initState() {
    super.initState();
    final c = widget.corrige;
    if (c != null) {
      fecha = c.fecha;
      moneda = c.moneda;
      categoria = c.categoria;
      actividad = c.actividad;
      grupoId = c.grupoId;
      _monto.text = formatoMonto(c.monto, c.moneda)
          .replaceFirst('${simboloMoneda(c.moneda)} ', '');
      _proveedor.text = c.proveedor ?? '';
      _descripcion.text = c.descripcion ?? '';
      comprobanteRuta = c.comprobanteRuta;
    }
    _cargarGrupos();
  }

  Future<void> _cargarGrupos() async {
    try {
      final lista =
          await ProduccionService().gruposDeActivo(widget.activoAgroId);
      if (!mounted) return;
      setState(() => grupos = lista);
    } catch (_) {
      // Sin permiso de producción: se carga igual, sin elegir cultivo.
    }
  }

  @override
  void dispose() {
    _monto.dispose();
    _proveedor.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  List<GrupoProductivo> get gruposDeActividad => grupos
      .where((g) => actividad == 'agricultura' ? g.esAgricola : !g.esAgricola)
      .toList();

  String? _txt(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<String> _subir(String nombre, Uint8List bytes, String tipo) {
    return _servicio.subirComprobante(
      activoId: widget.activoAgroId,
      gastoId: gastoId,
      nombreArchivo: nombre,
      bytes: bytes,
      contentType: tipo,
    );
  }

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final monto = anular ? 0.0 : leerMonto(_monto.text);
    if (monto == null) {
      _avisar('El monto tiene que ser un número.');
      return;
    }
    if (categoria == null) {
      _avisar('Elegí la categoría.');
      return;
    }
    final gasto = Gasto(
      gastoId: gastoId,
      activoAgroId: widget.activoAgroId,
      fecha: fecha,
      fechaCarga: DateTime.now(),
      cargadoPor: uid,
      monto: monto,
      moneda: moneda,
      categoria: categoria!,
      actividad: actividad,
      grupoId: actividad == 'general' ? null : grupoId,
      proveedor: _txt(_proveedor),
      descripcion: _txt(_descripcion),
      comprobanteRuta: comprobanteRuta,
      corrigeGastoId: widget.corrige?.gastoId,
    );
    final errores = gasto.validar();
    if (errores.isNotEmpty) {
      _avisar(errores.first);
      return;
    }
    setState(() => guardando = true);
    try {
      await _servicio.registrarGasto(gasto);
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
    final corrigiendo = widget.corrige != null;
    return Scaffold(
      appBar: BarraCampo(
        title: Text(corrigiendo ? 'Corregir gasto' : 'Nuevo gasto'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          if (corrigiendo) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Cambiá lo que esté mal y guardá. El gasto anterior no se '
                'borra: queda como "corregido" en la historia.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: anular,
              onChanged: (v) => setState(() => anular = v),
              title: const Text('Anular este gasto (se cargó por error)'),
            ),
          ],
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
          if (!anular) ...[
            const EtiquetaCampo('Monto'),
            TextField(
              controller: _monto,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              decoration: decoracionCampo(ayuda: 'Ej.: 150.000'),
            ),
            const EtiquetaCampo('Moneda'),
            OpcionesTocar<String>(
              opciones: monedasGasto,
              elegida: moneda,
              etiqueta: (m) => '${simboloMoneda(m)}  ${nombreMoneda(m)}',
              alElegir: (m) => setState(() => moneda = m),
            ),
          ],
          const EtiquetaCampo('¿En qué se gastó?'),
          OpcionesTocar<String>(
            opciones: categoriasGasto,
            elegida: categoria,
            etiqueta: nombreCategoriaGasto,
            alElegir: (c) => setState(() => categoria = c),
          ),
          const EtiquetaCampo('¿Para qué actividad?'),
          OpcionesTocar<String>(
            opciones: actividadesGasto,
            elegida: actividad,
            etiqueta: nombreActividadGasto,
            alElegir: (a) => setState(() {
              actividad = a;
              grupoId = null;
            }),
          ),
          if (actividad != 'general' && gruposDeActividad.isNotEmpty) ...[
            EtiquetaCampo(actividad == 'agricultura'
                ? '¿Qué cultivo? (opcional)'
                : '¿Qué rodeo? (opcional)'),
            OpcionesTocar<String>(
              opciones: gruposDeActividad.map((g) => g.grupoId).toList(),
              elegida: grupoId,
              etiqueta: (id) =>
                  gruposDeActividad.firstWhere((g) => g.grupoId == id).nombre,
              alElegir: (id) =>
                  setState(() => grupoId = grupoId == id ? null : id),
            ),
          ],
          const EtiquetaCampo('Proveedor (opcional)'),
          TextField(
            controller: _proveedor,
            decoration: decoracionCampo(ayuda: 'Ej.: Cooperativa, estación'),
          ),
          const EtiquetaCampo('Detalle (opcional)'),
          TextField(
            controller: _descripcion,
            maxLines: 2,
            decoration: decoracionCampo(ayuda: 'Ej.: gasoil para la siembra'),
          ),
          const EtiquetaCampo('Comprobante (opcional)'),
          AdjuntarArchivoBoton(
            texto: 'Adjuntar foto o PDF del ticket',
            subir: _subir,
            rutaActual: comprobanteRuta,
            alSubir: (ruta) => setState(() => comprobanteRuta = ruta),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda como declarado. No se edita ni se borra: si hay un error, '
            'tocá "Corregir" en el gasto. Cada gasto queda en su moneda.',
            style: TextStyle(
                fontSize: 14, height: 1.5, color: EstiloProduccion.textoSuave),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: anular
                ? 'Anular gasto'
                : (corrigiendo ? 'Guardar corrección' : 'Guardar gasto'),
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
