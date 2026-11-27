import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/auth/admin.dart';
import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/activos/economia_activo_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/foto_mercado_service.dart';
import '../../services/habilitacion_service.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../services/produccion_service.dart';
import '../produccion/produccion_activo_screen.dart' show actividadDeGrupo;
import 'detalle_activo_agro_screen.dart' show actividadesDeclaradas;
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';

/// GAP-EDITAR-01 (26/11/2026): esta pantalla pasa a ser "Editar campo":
/// arriba los datos del campo y abajo el aviso y las fotos. Se llega desde
/// el ✏️ de la tarjeta (Inicio) y de la ficha. "Guardar" solo guarda los
/// datos; "Guardar y publicar" además manda el aviso a revisión.
///
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


  /// GAP-MERC-01 Parte B: fotos de la publicación (la primera es la
  /// portada) y las que se quitaron (se borran recién al enviar).
  final FotoMercadoService _fotosServicio = FotoMercadoService();
  List<String> _fotos = [];
  final List<String> _quitadas = [];
  bool _subiendoFoto = false;

  /// GAP-EDITAR-01: datos del campo.
  late final TextEditingController _nombre =
      TextEditingController(text: widget.activo.nombre);
  late final TextEditingController _descripcion =
      TextEditingController(text: widget.activo.descripcion);
  late final TextEditingController _provincia =
      TextEditingController(text: widget.activo.ubicacion.provincia);
  late final TextEditingController _localidad =
      TextEditingController(text: widget.activo.ubicacion.localidad);
  late final TextEditingController _superficie = TextEditingController(
      text: widget.activo.ubicacion.superficie > 0
          ? OfertaMercado.numero(widget.activo.ubicacion.superficie)
          : '');
  // AF-146: "¿Cómo están las hectáreas?"
  late final TextEditingController _haLimpias =
      _controlHa(widget.activo.ubicacion.haLimpias);
  late final TextEditingController _haAgricolas =
      _controlHa(widget.activo.ubicacion.haAgricolas);
  late final TextEditingController _haGanaderas =
      _controlHa(widget.activo.ubicacion.haGanaderas);
  late final TextEditingController _haMonte =
      _controlHa(widget.activo.ubicacion.haMonte);

  static TextEditingController _controlHa(double v) => TextEditingController(
      text: v > 0 ? OfertaMercado.numero(v) : '');

  late final TextEditingController _dueno =
      TextEditingController(text: widget.activo.duenoDeclarado ?? '');
  bool _guardando = false;

  String get _estado => widget.activo.estadoPublicacion;
  bool get _yaEnviado =>
      _estado == 'publicado' || _estado == 'pendienteRevision';

  /// PUB-DIRECTO (27/11/2026): interruptor "Mostrar en el Mercado".
  late bool _enMercado = _yaEnviado;

  /// Admin o usuario habilitado: lo que guarda se ve al instante.
  bool _directo = false;

  Future<void> _verSiPublicaDirecto() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final si = esAdminPorUid(uid) ||
        await HabilitacionService().estaHabilitado(uid);
    if (mounted) setState(() => _directo = si);
  }

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
    _verSiPublicaDirecto();
  }

  /// GAP-MERC-01 Parte D: actividades reales del campo para el Mercado
  /// (declaradas al crearlo + cargadas en Producción). null = no se pudo
  /// saber (se usan las del expediente, como antes).
  Future<List<String>?> _actividades() async {
    try {
      const orden = ['ganaderia', 'agricultura', 'avicultura', 'piscicultura'];
      final grupos =
          await ProduccionService().gruposDeActivo(widget.activo.activoId);
      final todas = {
        ...actividadesDeclaradas(widget.activo),
        ...grupos
            .where((g) => g.estado == EstadoGrupoProductivo.activo)
            .map(actividadDeGrupo),
      };
      return [
        ...orden.where(todas.contains),
        ...todas.where((a) => !orden.contains(a)),
      ];
    } catch (_) {
      return null;
    }
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
    for (final c in [
      _nombre, _descripcion, _provincia, _localidad, _superficie, _dueno,
      _haLimpias, _haAgricolas, _haGanaderas, _haMonte,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// GAP-EDITAR-01: guarda los datos del campo (sin tocar el aviso).
  Future<void> _guardarDatos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _servicio.actualizarDatosCampo(
      activo: widget.activo,
      usuarioId: uid,
      nombre: _nombre.text.trim(),
      descripcion: _descripcion.text.trim(),
      provincia: _provincia.text.trim(),
      localidad: _localidad.text.trim(),
      superficie: _leerPrecio(_superficie.text) ?? 0,
      haLimpias: _leerPrecio(_haLimpias.text) ?? 0,
      haAgricolas: _leerPrecio(_haAgricolas.text) ?? 0,
      haGanaderas: _leerPrecio(_haGanaderas.text) ?? 0,
      haMonte: _leerPrecio(_haMonte.text) ?? 0,
      duenoDeclarado:
          _dueno.text.trim().isEmpty ? null : _dueno.text.trim(),
    );
  }

  /// PUB-DIRECTO (27/11/2026): un solo botón "Guardar".
  /// - Siempre guarda los datos del campo y el precio.
  /// - "Mostrar en el Mercado" prendido: publica el aviso. Si es admin o
  ///   está habilitado, se ve al instante; si no, va a revisión.
  /// - Apagado en un aviso que estaba en el Mercado: se saca (pausa).
  Future<void> _guardar() async {
    if (_nombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Escribí el nombre del campo')));
      return;
    }
    final ofertas = _armarOfertas();
    if (_enMercado) {
      final bien = _formKey.currentState!.validate();
      setState(() => _faltaOperacion = _ofertas.isEmpty);
      if (!bien || _ofertas.isEmpty) return;
    }

    // Sin permiso para publicar directo, un aviso ya publicado vuelve a
    // revisión: se avisa antes.
    if (_enMercado && !_directo && _estado == 'publicado') {
      final seguir = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('El aviso vuelve a revisión'),
          content: const Text(
            'El precio ya queda guardado en tu campo. En el Mercado se ve '
            'cuando el administrador apruebe el cambio.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Seguir'),
            ),
          ],
        ),
      );
      if (seguir != true || !mounted) return;
    }

    setState(() => _guardando = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      await _guardarDatos();
      String mensaje;
      if (_enMercado) {
        await _servicio.publicarActivo(widget.activo.activoId,
            ofertas: ofertas,
            fotos: _fotos,
            actividades: await _actividades(),
            directo: _directo,
            usuarioId: uid);
        // Las fotos quitadas se borran recién ahora.
        for (final ruta in _quitadas) {
          try {
            await _fotosServicio.quitar(ruta);
          } catch (_) {}
        }
        mensaje = _directo
            ? 'Guardado. Ya se ve en el Mercado 🚜'
            : 'Guardado y enviado a revisión: se verá en el Mercado '
                'cuando se apruebe.';
      } else {
        if (ofertas.isNotEmpty) {
          await _servicio.guardarOfertas(
              activo: widget.activo, ofertas: ofertas, usuarioId: uid);
        }
        if (_yaEnviado) {
          await _servicio.pausarActivo(widget.activo.activoId);
          mensaje = 'Guardado. El aviso ya no se ve en el Mercado.';
        } else {
          mensaje = 'Guardado';
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
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

  /// Las ofertas tal como están en pantalla (operación, precio, moneda).
  List<OfertaMercado> _armarOfertas() => [
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

  Widget _campoHa(TextEditingController c, String etiqueta) {
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _decoracion(etiqueta, ayuda: 'ha'),
    );
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
      appBar: BarraCampo(title: const Text('Editar campo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // GAP-EDITAR-01: datos del campo.
            _tarjeta(Icons.edit_note, AgroTema.verde, 'Datos del campo', [
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoracion('Nombre del campo'),
              ),
              TextFormField(
                controller: _descripcion,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: _decoracion('Descripción (opcional)'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _provincia,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoracion('Provincia'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _localidad,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoracion('Localidad'),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _superficie,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _decoracion('Hectáreas', ayuda: '2.300'),
              ),
              // AF-146 (27/11/2026): cómo están las hectáreas (declarado).
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('¿Cómo están las hectáreas?',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AgroTema.pizarra)),
              ),
              Row(
                children: [
                  Expanded(child: _campoHa(_haLimpias, 'Limpias')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _campoHa(_haAgricolas, 'Agrícolas / directa')),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: _campoHa(_haGanaderas, 'Ganaderas / pasturas')),
                  const SizedBox(width: 10),
                  Expanded(child: _campoHa(_haMonte, 'Monte')),
                ],
              ),
              const Text(
                'Dato declarado. Dejá vacío lo que no sepas.',
                style: TextStyle(fontSize: 12, color: AgroTema.pizarraSuave),
              ),
              if (widget.activo.sinDueno)
                TextFormField(
                  controller: _dueno,
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoracion('Nombre del dueño (opcional)',
                      ayuda: 'Dato declarado'),
                ),
              const Text(
                'Las actividades se suman desde la ficha del campo.',
                style: TextStyle(fontSize: 13, color: AgroTema.pizarraSuave),
              ),
            ]),
            const SizedBox(height: 4),
            const Text(
              'El aviso del Mercado: solo se publica el resumen del campo. '
              'Lo privado (documentos, economía, suelo, personas) no se '
              'muestra.',
              style: TextStyle(fontSize: 14, color: AgroTema.pizarraSuave),
            ),
            const SizedBox(height: 12),
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
            // PUB-DIRECTO (27/11/2026): un interruptor y un solo botón.
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AgroTema.borde),
              ),
              child: SwitchListTile(
                value: _enMercado,
                onChanged: _guardando
                    ? null
                    : (v) => setState(() => _enMercado = v),
                activeColor: AgroTema.verde,
                secondary:
                    const Icon(Icons.storefront, color: AgroTema.azul),
                title: const Text('Mostrar en el Mercado',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(!_enMercado
                    ? 'El aviso no se ve en el Mercado'
                    : _directo
                        ? 'Lo que guardes se ve al instante'
                        : 'Se ve cuando el administrador lo apruebe'),
              ),
            ),
            const SizedBox(height: 12),
            BotonGrande(
              texto: 'Guardar',
              icono: Icons.save_outlined,
              ocupado: _guardando,
              onPressed:
                  _guardando || _subiendoFoto ? null : _guardar,
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
