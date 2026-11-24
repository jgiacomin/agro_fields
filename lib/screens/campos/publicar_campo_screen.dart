import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/activos/economia_activo_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/foto_mercado_service.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';

/// GAP-MERC-01 Parte A (24/11/2026): "Publicar en el Mercado".
/// El dueño elige qué ofrece (venta, alquiler y/o arrendamiento) y el
/// precio de cada una (o "Consultar precio"). Se envía a revisión: el
/// administrador lo aprueba. Devuelve true si se envió.
class PublicarCampoScreen extends StatefulWidget {
  final ActivoAgroV2 activo;

  const PublicarCampoScreen({super.key, required this.activo});

  @override
  State<PublicarCampoScreen> createState() => _PublicarCampoScreenState();
}

/// Lo que se va completando de cada operación.
class _Oferta {
  final TextEditingController precio = TextEditingController();
  String moneda;
  bool consultar = false;
  String precioPor;

  _Oferta({required this.moneda, required this.precioPor});
}

class _PublicarCampoScreenState extends State<PublicarCampoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ActivoAgroServiceV2 _servicio = ActivoAgroServiceV2();

  /// Operaciones elegidas, en el orden fijo de OfertaMercado.operaciones.
  final Map<String, _Oferta> _ofertas = {};
  bool _faltaOperacion = false;
  bool _enviando = false;

  /// GAP-MERC-01 Parte B: fotos de la publicación (la primera es la
  /// portada) y las que se quitaron (se borran recién al enviar).
  final FotoMercadoService _fotosServicio = FotoMercadoService();
  List<String> _fotos = [];
  final List<String> _quitadas = [];
  bool _subiendoFoto = false;

  String get _monedaDelCampo {
    final m = widget.activo.ubicacion.monedaLocal;
    return OfertaMercado.monedas.contains(m) ? m : 'USD';
  }

  @override
  void initState() {
    super.initState();
    // Si ya se había publicado antes, se arranca con lo que tenía.
    for (final o in widget.activo.economia.ofertas) {
      final f = _Oferta(moneda: o.moneda, precioPor: o.precioPor)
        ..consultar = o.precio == null;
      if (o.precio != null) f.precio.text = OfertaMercado.numero(o.precio!);
      _ofertas[o.operacion] = f;
    }
    _cargarFotos();
  }

  Future<void> _cargarFotos() async {
    try {
      final fotos =
          await FotoMercadoService.fotosPublicadas(widget.activo.activoId);
      if (mounted) setState(() => _fotos = fotos);
    } catch (_) {
      // Sin señal o sin publicación anterior: se arranca sin fotos.
    }
  }

  Future<void> _agregarFoto() async {
    final archivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (archivo == null) return;
    setState(() => _subiendoFoto = true);
    try {
      final bytes = await archivo.readAsBytes();
      final ruta = await _fotosServicio.subir(
        activoId: widget.activo.activoId,
        nombreArchivo: archivo.name,
        bytes: bytes,
      );
      if (mounted) setState(() => _fotos = [..._fotos, ruta]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e is ArgumentError
            ? '${e.message}'
            : 'No se pudo subir la foto: $e'),
      ));
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  void _quitarFoto(String ruta) => setState(() {
        _fotos = [..._fotos]..remove(ruta);
        _quitadas.add(ruta);
      });

  void _hacerPortada(String ruta) => setState(() {
        _fotos = [ruta, ..._fotos.where((f) => f != ruta)];
      });

  @override
  void dispose() {
    for (final o in _ofertas.values) {
      o.precio.dispose();
    }
    super.dispose();
  }

  void _elegir(String operacion, bool si) {
    setState(() {
      if (si) {
        _ofertas[operacion] = _Oferta(
          moneda: _monedaDelCampo,
          precioPor: operacion == 'venta' ? 'total' : 'hectarea_anio',
        );
        _faltaOperacion = false;
      } else {
        _ofertas.remove(operacion)?.precio.dispose();
      }
    });
  }

  /// "6.000.000" o "250,5" -> número (miles con punto, decimales con coma).
  double? _leerPrecio(String texto) => double.tryParse(
      texto.trim().replaceAll('.', '').replaceAll(',', '.'));

  Future<void> _enviar() async {
    final bien = _formKey.currentState!.validate();
    setState(() => _faltaOperacion = _ofertas.isEmpty);
    if (!bien || _ofertas.isEmpty) return;

    final ofertas = [
      for (final op in OfertaMercado.operaciones)
        if (_ofertas[op] != null)
          OfertaMercado(
            operacion: op,
            precio: _ofertas[op]!.consultar
                ? null
                : _leerPrecio(_ofertas[op]!.precio.text),
            moneda: _ofertas[op]!.moneda,
            precioPor: _ofertas[op]!.precioPor,
          ),
    ];

    setState(() => _enviando = true);
    try {
      await _servicio.publicarActivo(widget.activo.activoId,
          ofertas: ofertas, fotos: _fotos);
      // Las fotos quitadas se borran recién ahora (si se cancelaba, la
      // publicación anterior seguía usándolas).
      for (final ruta in _quitadas) {
        try {
          await _fotosServicio.quitar(ruta);
        } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Enviado a revisión: se verá en el Mercado cuando se apruebe 🚜'),
      ));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo enviar: $e')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  InputDecoration _decoracion(String etiqueta, {String? ayuda}) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AgroTema.borde),
    );
    return InputDecoration(
      labelText: etiqueta,
      hintText: ayuda,
      filled: true,
      fillColor: Colors.white,
      border: borde,
      enabledBorder: borde,
      focusedBorder: borde.copyWith(
          borderSide: const BorderSide(color: AgroTema.terracota, width: 2)),
    );
  }

  Widget _tarjeta(IconData icono, Color color, String titulo,
      List<Widget> hijos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TarjetaBlanca(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconoCirculo(icono, color: color, tamano: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AgroTema.pizarra,
                      ),
                    ),
                  ),
                ],
              ),
              for (final h in hijos) ...[const SizedBox(height: 12), h],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String texto, bool elegido, ValueChanged<bool> alTocar,
      {IconData? icono}) {
    return FilterChip(
      avatar: icono == null
          ? null
          : Icon(icono,
              size: 18, color: elegido ? Colors.white : AgroTema.verde),
      label: Text(texto),
      selected: elegido,
      showCheckmark: false,
      selectedColor: AgroTema.verde,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: elegido ? Colors.white : AgroTema.pizarra,
      ),
      side: const BorderSide(color: AgroTema.borde),
      onSelected: alTocar,
    );
  }

  Widget _tarjetaPrecio(String operacion, _Oferta o) {
    final nombre = OfertaMercado(
            operacion: operacion, precio: null, moneda: '', precioPor: '')
        .nombreOperacion;
    final opcionesPor = operacion == 'venta'
        ? const [('total', 'Total'), ('hectarea', 'Por hectárea')]
        : const [
            ('hectarea_anio', 'Por hectárea por año'),
            ('total', 'Total por año'),
          ];
    return _tarjeta(Icons.sell_outlined, AgroTema.terracota,
        '¿Cuánto? · $nombre', [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: DropdownButtonFormField<String>(
              value: o.moneda,
              decoration: _decoracion('Moneda'),
              items: [
                for (final m in OfertaMercado.monedas)
                  DropdownMenuItem(value: m, child: Text(m)),
              ],
              onChanged: o.consultar
                  ? null
                  : (v) => setState(() => o.moneda = v ?? o.moneda),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: o.precio,
              enabled: !o.consultar,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _decoracion('Precio',
                  ayuda: operacion == 'venta' ? '6.000.000' : '250'),
              validator: (v) {
                if (o.consultar) return null;
                final p = _leerPrecio(v ?? '');
                if (p == null || p <= 0) {
                  return 'Escribí el precio o marcá "Consultar precio"';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (clave, texto) in opcionesPor)
            _chip(texto, o.precioPor == clave, (_) {
              setState(() => o.precioPor = clave);
            }),
        ],
      ),
      CheckboxListTile(
        value: o.consultar,
        onChanged: (v) => setState(() => o.consultar = v ?? false),
        title: const Text('Consultar precio (no mostrarlo)'),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        activeColor: AgroTema.verde,
      ),
    ]);
  }

  /// GAP-MERC-01 Parte B: tarjeta de fotos.
  Widget _tarjetaFotos() {
    return _tarjeta(Icons.photo_library_outlined, AgroTema.verde,
        'Fotos del campo', [
      Text(
        _fotos.isEmpty
            ? 'Hasta ${FotoMercadoService.maxFotos} fotos. La primera es la '
                'portada que se ve en el Mercado.'
            : 'Tocá ★ para elegir la portada (la primera).',
        style: const TextStyle(fontSize: 14, color: AgroTema.pizarraSuave),
      ),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final ruta in _fotos)
            SizedBox(
              width: 120,
              height: 90,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FotoDelMercado(ruta: ruta, alto: 90, ancho: 120),
                  ),
                  Positioned(
                    left: 2,
                    top: 2,
                    child: _botonFoto(
                      ruta == _fotos.first ? Icons.star : Icons.star_border,
                      ruta == _fotos.first ? 'Portada' : 'Hacer portada',
                      () => _hacerPortada(ruta),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: _botonFoto(
                        Icons.close, 'Quitar', () => _quitarFoto(ruta)),
                  ),
                ],
              ),
            ),
          if (_fotos.length < FotoMercadoService.maxFotos)
            SizedBox(
              width: 120,
              height: 90,
              child: OutlinedButton(
                onPressed: _subiendoFoto ? null : _agregarFoto,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AgroTema.terracota,
                  side: const BorderSide(color: AgroTema.terracota),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _subiendoFoto
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo_outlined),
                          SizedBox(height: 4),
                          Text('Agregar foto'),
                        ],
                      ),
              ),
            ),
        ],
      ),
    ]);
  }

  Widget _botonFoto(IconData icono, String ayuda, VoidCallback alTocar) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icono, color: Colors.white, size: 18),
        tooltip: ayuda,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        padding: EdgeInsets.zero,
        onPressed: alTocar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(title: const Text('Publicar en el Mercado')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(
              widget.activo.nombre,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AgroTema.pizarra,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Solo se publica el resumen del campo. Lo privado '
              '(documentos, economía, suelo, personas) no se muestra.',
              style: TextStyle(fontSize: 14, color: AgroTema.pizarraSuave),
            ),
            const SizedBox(height: 16),
            _tarjeta(Icons.storefront, AgroTema.azul, '¿Qué querés hacer?', [
              const Text(
                'Podés marcar más de una (por ejemplo, vender o alquilar).',
                style: TextStyle(fontSize: 14, color: AgroTema.pizarraSuave),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('Vender', _ofertas.containsKey('venta'),
                      (si) => _elegir('venta', si),
                      icono: Icons.sell_outlined),
                  _chip('Alquilar', _ofertas.containsKey('alquiler'),
                      (si) => _elegir('alquiler', si),
                      icono: Icons.key_outlined),
                  _chip('Arrendar', _ofertas.containsKey('arrendamiento'),
                      (si) => _elegir('arrendamiento', si),
                      icono: Icons.handshake_outlined),
                ],
              ),
              if (_faltaOperacion)
                const Text(
                  'Marcá al menos una opción',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AgroTema.rojo),
                ),
            ]),
            for (final op in OfertaMercado.operaciones)
              if (_ofertas[op] != null) _tarjetaPrecio(op, _ofertas[op]!),
            _tarjetaFotos(),
            const SizedBox(height: 8),
            BotonGrande(
              texto: 'Enviar a revisión',
              icono: Icons.send,
              ocupado: _enviando,
              onPressed: _enviando || _subiendoFoto ? null : _enviar,
            ),
            const SizedBox(height: 10),
            const Text(
              'Agro Fields no fija precios ni cobra comisiones: conecta a '
              'las partes. La decisión y el acuerdo son de ustedes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AgroTema.pizarraSuave),
            ),
          ],
        ),
      ),
    );
  }
}
