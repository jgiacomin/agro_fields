import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/evento_productivo_model.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/recurso_agro_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../services/calculo_existencias.dart';
import '../../services/produccion_service.dart';
import '../../services/recurso_service.dart';
import 'produccion_estilo.dart';
import '../../widgets/barra_campo.dart';

/// Pantallas 4a y 4b (paso 6a, GAP-PROD-01): registrar un evento.
/// Paso 1: ¿que paso? (cinco botones grandes).
/// Paso 2: solo los datos de ese tipo.
/// El evento queda "declarado" y no se borra: un error se corrige con otro.
class RegistrarEventoScreen extends StatefulWidget {
  final GrupoProductivo grupo;
  final List<UnidadProductiva> unidades;
  final ResultadoExistencias existencias;

  const RegistrarEventoScreen({
    super.key,
    required this.grupo,
    required this.unidades,
    required this.existencias,
  });

  @override
  State<RegistrarEventoScreen> createState() => _RegistrarEventoScreenState();
}

class _RegistrarEventoScreenState extends State<RegistrarEventoScreen> {
  final ProduccionService _servicio = ProduccionService();
  final TextEditingController _cantidad = TextEditingController();
  final TextEditingController _tratamiento = TextEditingController();
  final TextEditingController _dosis = TextEditingController();
  final TextEditingController _cantidadInsumo = TextEditingController();
  final TextEditingController _observaciones = TextEditingController();
  // GAP-PESO-01: peso promedio por animal (kg).
  final TextEditingController _peso = TextEditingController();

  /// ID armado al abrir la pantalla: si se toca "Guardar" dos veces, o se
  /// reintenta sin senal, no se duplica el evento.
  late final String eventoId = _servicio.nuevoIdEvento();

  TipoEventoProductivo? tipo;
  String? categoria;
  String? categoriaNueva;
  OrigenAlta? origen;
  MotivoBaja? motivo;
  String? unidadId;
  String? unidadDestinoId;
  DateTime fecha = DateTime.now();

  bool usaStock = false;
  bool cargandoRecursos = false;
  List<RecursoAgro> recursos = [];
  RecursoAgro? recurso;

  bool guardando = false;

  static const opciones = [
    (TipoEventoProductivo.alta, 'Nacimiento, compra, capitalización u hotelería'),
    (TipoEventoProductivo.baja, 'Venta, muerte, consumo o traslado'),
    (TipoEventoProductivo.movimiento, 'Mover animales de un lugar a otro'),
    (TipoEventoProductivo.cambioCategoria, 'Por ejemplo, de ternero a novillito'),
    (TipoEventoProductivo.sanidad, 'Puede descontar el producto del stock'),
    (TipoEventoProductivo.pesaje, 'Peso promedio de los animales'),
  ];

  Map<String, int> get existentes => widget.existencias.porCategoria;

  /// Para una entrada se ofrecen todas; para lo demas, las que hay.
  List<String> get categoriasPosibles {
    if (tipo == TipoEventoProductivo.alta || existentes.isEmpty) {
      return {...categoriasGanaderasBase, ...existentes.keys}.toList();
    }
    return existentes.keys.toList();
  }

  @override
  void initState() {
    super.initState();
    unidadId = widget.grupo.unidadInicialId ??
        (widget.unidades.isNotEmpty ? widget.unidades.first.unidadId : null);
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _tratamiento.dispose();
    _dosis.dispose();
    _cantidadInsumo.dispose();
    _observaciones.dispose();
    _peso.dispose();
    super.dispose();
  }

  void elegirTipo(TipoEventoProductivo elegido) {
    setState(() {
      tipo = elegido;
      categoria = null;
      categoriaNueva = null;
    });
  }

  Future<void> cargarRecursos() async {
    setState(() => cargandoRecursos = true);
    try {
      final lista = await RecursoService()
          .obtenerRecursosPorActivo(widget.grupo.activoAgroId);
      if (!mounted) return;
      setState(() {
        recursos = lista;
        cargandoRecursos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargandoRecursos = false;
        usaStock = false;
      });
      _avisar('No se pudo leer el stock: $e');
    }
  }

  Future<void> elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(hoy.year - 5),
      lastDate: hoy,
      helpText: '¿Cuándo pasó?',
    );
    if (elegida == null) return;

    final esHoy = elegida.year == hoy.year &&
        elegida.month == hoy.month &&
        elegida.day == hoy.day;
    setState(() => fecha = esHoy ? hoy : elegida);
  }

  Future<void> guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _avisar('Tenés que iniciar sesión.');
      return;
    }

    final textoCantidad = _cantidad.text.trim();
    final cantidad = textoCantidad.isEmpty ? null : int.tryParse(textoCantidad);
    if (textoCantidad.isNotEmpty && cantidad == null) {
      _avisar('La cantidad tiene que ser un número entero.');
      return;
    }

    final esMovimiento = tipo == TipoEventoProductivo.movimiento;
    final esSanidad = tipo == TipoEventoProductivo.sanidad;
    final esPesaje = tipo == TipoEventoProductivo.pesaje;
    double? peso;
    if (esPesaje) {
      peso = double.tryParse(_peso.text.trim().replaceAll(',', '.'));
      if (peso == null) {
        _avisar('Poné el peso promedio por animal, en kg.');
        return;
      }
    }
    final ahora = DateTime.now();

    final evento = EventoProductivo(
      eventoId: eventoId,
      activoAgroId: widget.grupo.activoAgroId,
      grupoId: widget.grupo.grupoId,
      tipo: tipo!,
      fechaHecho: fecha.isAfter(ahora) ? ahora : fecha,
      fechaCarga: ahora,
      cargadoPor: uid,
      unidadId: esMovimiento ? null : unidadId,
      cantidad: cantidad,
      categoria: esSanidad ? null : categoria,
      categoriaNueva: categoriaNueva,
      origen: tipo == TipoEventoProductivo.alta ? origen : null,
      motivo: tipo == TipoEventoProductivo.baja ? motivo : null,
      unidadOrigenId: esMovimiento ? unidadId : null,
      unidadDestinoId: esMovimiento ? unidadDestinoId : null,
      tratamiento: esSanidad ? _tratamiento.text.trim() : null,
      dosis: esSanidad && _dosis.text.trim().isNotEmpty
          ? _dosis.text.trim()
          : null,
      pesoPromedioKg: esPesaje ? peso : null,
      observaciones: _observaciones.text.trim().isEmpty
          ? null
          : _observaciones.text.trim(),
    );

    final errores = evento.validar();
    if (errores.isNotEmpty) {
      _avisar(errores.join(' '));
      return;
    }

    double? cantidadInsumo;
    if (esSanidad && usaStock) {
      if (recurso == null) {
        _avisar('Elegí el producto del stock, o apagá "Descontar del stock".');
        return;
      }
      cantidadInsumo =
          double.tryParse(_cantidadInsumo.text.trim().replaceAll(',', '.'));
      if (cantidadInsumo == null || cantidadInsumo <= 0) {
        _avisar('Poné cuánto producto se usó (mayor a cero).');
        return;
      }
    }

    setState(() => guardando = true);

    try {
      if (esSanidad && usaStock) {
        await _servicio.registrarSanidadConStock(
          evento: evento,
          recursoId: recurso!.recursoId,
          cantidadInsumo: cantidadInsumo!,
          unidadInsumo: recurso!.unidad,
          usuarioId: uid,
        );
      } else {
        await _servicio.registrarEvento(evento);
      }

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
    final elegido = tipo;

    return Scaffold(
      appBar: BarraCampo(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: elegido == null ? 'Volver' : 'Cambiar qué pasó',
          onPressed: () {
            if (elegido == null) {
              Navigator.of(context).pop(false);
            } else {
              setState(() => tipo = null);
            }
          },
        ),
        title: Text(elegido == null ? '¿Qué pasó?' : nombreTipoEvento(elegido)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: Padding(
            padding: const EdgeInsets.only(left: 72, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                elegido == null ? 'Paso 1 de 2' : 'Paso 2 de 2',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: EstiloProduccion.textoSuave,
                ),
              ),
            ),
          ),
        ),
      ),
      body: elegido == null ? _paso1() : _paso2(elegido),
      bottomNavigationBar: elegido == null
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: BotonGrande(
                  texto: 'Guardar ${nombreTipoEvento(elegido).toLowerCase()}',
                  ocupado: guardando,
                  onPressed: guardar,
                ),
              ),
            ),
    );
  }

  Widget _paso1() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final (opcion, explicacion) in opciones)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TarjetaBlanca(
              onTap: () => elegirTipo(opcion),
              child: Container(
                constraints: const BoxConstraints(minHeight: 76),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            nombreTipoEvento(opcion),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            explicacion,
                            style: const TextStyle(
                              fontSize: 14,
                              color: EstiloProduccion.textoSuave,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: EstiloProduccion.textoSuave),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _paso2(TipoEventoProductivo elegido) {
    final esSanidad = elegido == TipoEventoProductivo.sanidad;
    final esMovimiento = elegido == TipoEventoProductivo.movimiento;
    final esCambio = elegido == TipoEventoProductivo.cambioCategoria;
    final esPesaje = elegido == TipoEventoProductivo.pesaje;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        if (esPesaje) ...[
          const EtiquetaCampo('Peso promedio por animal (kg)'),
          TextField(
            controller: _peso,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: decoracionCampo(ayuda: 'Ej.: 320'),
          ),
        ],
        if (esSanidad) ...[
          const EtiquetaCampo('Vacuna o tratamiento'),
          TextField(
            controller: _tratamiento,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(ayuda: 'Ej.: Aftosa'),
          ),
        ],
        EtiquetaCampo(esSanidad
            ? '¿A cuántos animales? (opcional)'
            : esPesaje
                ? '¿Cuántos se pesaron? (opcional)'
                : 'Cantidad de animales'),
        TextField(
          controller: _cantidad,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          decoration: decoracionCampo(ayuda: 'Ej.: 10'),
        ),
        if (!esSanidad) ...[
          EtiquetaCampo(esCambio
              ? 'Categoría de antes'
              : esPesaje
                  ? 'Categoría (opcional, para comparar pesajes)'
                  : 'Categoría'),
          OpcionesTocar<String>(
            opciones: categoriasPosibles,
            elegida: categoria,
            etiqueta: (c) => existentes.containsKey(c) &&
                    elegido != TipoEventoProductivo.alta
                ? '${nombreCategoria(c)} (${existentes[c]})'
                : nombreCategoria(c),
            alElegir: (c) => setState(() => categoria = c),
          ),
        ],
        if (esCambio) ...[
          const EtiquetaCampo('Categoría nueva'),
          OpcionesTocar<String>(
            opciones: {...categoriasGanaderasBase, ...existentes.keys}
                .where((c) => c != categoria)
                .toList(),
            elegida: categoriaNueva,
            etiqueta: nombreCategoria,
            alElegir: (c) => setState(() => categoriaNueva = c),
          ),
        ],
        if (elegido == TipoEventoProductivo.alta) ...[
          const EtiquetaCampo('¿De dónde vienen?'),
          OpcionesTocar<OrigenAlta>(
            opciones: OrigenAlta.values,
            elegida: origen,
            etiqueta: nombreOrigen,
            alElegir: (o) => setState(() => origen = o),
          ),
        ],
        if (elegido == TipoEventoProductivo.baja) ...[
          const EtiquetaCampo('Motivo'),
          OpcionesTocar<MotivoBaja>(
            opciones: MotivoBaja.values,
            elegida: motivo,
            etiqueta: nombreMotivo,
            alElegir: (m) => setState(() => motivo = m),
          ),
        ],
        if (widget.unidades.isNotEmpty) ...[
          EtiquetaCampo(esMovimiento
              ? '¿Desde qué potrero?'
              : elegido == TipoEventoProductivo.alta
                  ? '¿A qué potrero entran?'
                  : '¿En qué potrero?'),
          _elegirUnidad(unidadId, (id) => setState(() => unidadId = id)),
        ],
        if (esMovimiento && widget.unidades.isNotEmpty) ...[
          const EtiquetaCampo('¿Hacia qué potrero?'),
          _elegirUnidad(
            unidadDestinoId,
            (id) => setState(() => unidadDestinoId = id),
            excepto: unidadId,
          ),
        ],
        if (esMovimiento && widget.unidades.length < 2)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Para mover animales hacen falta al menos dos potreros '
              'cargados.',
              style: TextStyle(color: EstiloProduccion.rojo),
            ),
          ),
        if (esSanidad) ..._camposStock(),
        const EtiquetaCampo('¿Cuándo?'),
        OutlinedButton.icon(
          onPressed: elegirFecha,
          icon: const Icon(Icons.calendar_today, size: 18),
          label: Text(fechaCorta(fecha)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            foregroundColor: EstiloProduccion.texto,
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const EtiquetaCampo('Notas (opcional)'),
        TextField(
          controller: _observaciones,
          maxLines: 2,
          decoration: decoracionCampo(),
        ),
        const SizedBox(height: 18),
        const Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: EstiloProduccion.textoSuave,
            ),
            children: [
              TextSpan(text: 'Queda como '),
              TextSpan(
                text: 'declarado',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '. Si después algo está mal, se corrige con otro '
                    'evento: este no se borra.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _elegirUnidad(
    String? elegida,
    ValueChanged<String> alElegir, {
    String? excepto,
  }) {
    final posibles =
        widget.unidades.where((u) => u.unidadId != excepto).toList();
    return OpcionesTocar<String>(
      opciones: posibles.map((u) => u.unidadId).toList(),
      elegida: elegida,
      etiqueta: (id) => posibles.firstWhere((u) => u.unidadId == id).nombre,
      alElegir: alElegir,
    );
  }

  List<Widget> _camposStock() {
    return [
      const EtiquetaCampo('Dosis (opcional)'),
      TextField(
        controller: _dosis,
        decoration: decoracionCampo(ayuda: 'Ej.: 2 ml por animal'),
      ),
      const SizedBox(height: 12),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Descontar del stock',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Resta el producto usado de tu inventario'),
        value: usaStock,
        onChanged: (valor) {
          setState(() => usaStock = valor);
          if (valor && recursos.isEmpty) cargarRecursos();
        },
      ),
      if (usaStock && cargandoRecursos)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (usaStock && !cargandoRecursos && recursos.isEmpty)
        const Text(
          'No hay productos cargados en el stock de este campo.',
          style: TextStyle(color: EstiloProduccion.textoSuave),
        ),
      if (usaStock && recursos.isNotEmpty) ...[
        const EtiquetaCampo('Producto'),
        OpcionesTocar<RecursoAgro>(
          opciones: recursos,
          elegida: recurso,
          etiqueta: (r) =>
              '${r.nombre} (${_numero(r.cantidadActual)} ${r.unidad})',
          alElegir: (r) => setState(() => recurso = r),
        ),
        EtiquetaCampo(recurso == null
            ? '¿Cuánto se usó?'
            : '¿Cuánto se usó? (en ${recurso!.unidad})'),
        TextField(
          controller: _cantidadInsumo,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: decoracionCampo(ayuda: 'Ej.: 168'),
        ),
      ],
    ];
  }

  String _numero(double valor) =>
      valor % 1 == 0 ? valor.toStringAsFixed(0) : valor.toStringAsFixed(1);
}
