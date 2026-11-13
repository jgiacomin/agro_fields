import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/evento_productivo_model.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../services/calculo_agricola.dart';
import '../../services/produccion_service.dart';
import 'cultivos_textos.dart';
import 'produccion_estilo.dart';
import 'registrar_aplicacion_screen.dart';
import 'registrar_monitoreo_screen.dart';
import '../../widgets/barra_campo.dart';

/// GAP-AGRO-01: un cultivo de la campaña. Resumen calculado (hectáreas,
/// toneladas, rendimiento) y sus siembras y cosechas (solo agregar).
/// GAP-MON-01: también sus monitoreos, con alerta si el último es "alto".
/// GAP-APLI-01: y sus aplicaciones (producto, dosis, receta, condiciones).
class DetalleCultivoScreen extends StatefulWidget {
  final GrupoProductivo grupo;
  final List<UnidadProductiva> unidades;

  const DetalleCultivoScreen({
    super.key,
    required this.grupo,
    required this.unidades,
  });

  @override
  State<DetalleCultivoScreen> createState() => _DetalleCultivoScreenState();
}

class _DetalleCultivoScreenState extends State<DetalleCultivoScreen> {
  final ProduccionService _servicio = ProduccionService();
  bool cargando = true;
  String? error;
  List<EventoProductivo> eventos = [];
  List<EventoProductivo> monitoreos = [];
  List<EventoProductivo> aplicaciones = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final todos = await _servicio.eventosDeGrupo(
        activoAgroId: widget.grupo.activoAgroId,
        grupoId: widget.grupo.grupoId,
      );
      if (!mounted) return;
      setState(() {
        eventos = todos
            .where((e) => tiposEventoAgricola.contains(e.tipo))
            .toList()
          ..sort((a, b) => b.fechaHecho.compareTo(a.fechaHecho));
        monitoreos = todos
            .where((e) => e.tipo == TipoEventoProductivo.monitoreo)
            .toList()
          ..sort((a, b) => b.fechaHecho.compareTo(a.fechaHecho));
        aplicaciones = todos
            .where((e) => e.tipo == TipoEventoProductivo.aplicacion)
            .toList()
          ..sort((a, b) => b.fechaHecho.compareTo(a.fechaHecho));
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudo cargar: $e';
        cargando = false;
      });
    }
  }

  Future<void> _registrar(TipoEventoProductivo tipo,
      {EventoProductivo? corrige}) async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RegistrarEventoCultivoScreen(
          grupo: widget.grupo,
          tipo: tipo,
          corrige: corrige,
        ),
      ),
    );
    if (guardo == true) await cargar();
  }

  Future<void> _registrarAplicacion() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RegistrarAplicacionScreen(grupo: widget.grupo),
      ),
    );
    if (guardo == true) await cargar();
  }

  Future<void> _registrarMonitoreo() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RegistrarMonitoreoScreen(grupo: widget.grupo),
      ),
    );
    if (guardo == true) await cargar();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.grupo;
    final r = calcularResumenCultivo(eventos);
    final corregidos = idsCorregidos(eventos);
    final alertas = alertasMonitoreo(monitoreos);
    final superanSembrado = aplicacionesQueSuperanSembrado(
            [...eventos, ...aplicaciones])
        .map((e) => e.eventoId)
        .toSet();
    final lote = widget.unidades
        .where((u) => u.unidadId == g.unidadInicialId)
        .map((u) => u.nombre)
        .firstOrNull;

    return Scaffold(
      appBar: BarraCampo(
        title: Text(g.nombre),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : RefreshIndicator(
                  onRefresh: cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        [
                          nombreCultivo(g.cultivo),
                          if (g.campania != null) 'Campaña ${g.campania}',
                          if (lote != null) lote,
                          if (g.material != null) g.material!,
                        ].join(' · '),
                        style: const TextStyle(
                            fontSize: 14, color: EstiloProduccion.textoSuave),
                      ),
                      if (alertas.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _alertaMonitoreo(alertas),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: _dato('Sembrado',
                                  '${numeroAgro(r.haSembradas)} ha')),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _dato('Cosechado',
                                  '${numeroAgro(r.haCosechadas)} ha')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: _dato(
                                  'Toneladas', numeroAgro(r.toneladas))),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _dato(
                              'Rendimiento',
                              r.rendimiento == null
                                  ? 'Sin cosecha'
                                  : '${numeroAgro(r.rendimiento!)} tn/ha',
                              destacado: r.rendimiento != null,
                            ),
                          ),
                        ],
                      ),
                      if (r.cosechaSinSiembraSuficiente) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: EstiloProduccion.rojoFondo,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: EstiloProduccion.rojoBorde),
                          ),
                          child: Row(children: [
                            const Icon(Icons.warning_rounded,
                                color: EstiloProduccion.rojo, size: 30),
                            const SizedBox(width: 10),
                            Expanded(child: Text(
                            'Se cosecharon ${numeroAgro(r.haCosechadas)} ha y '
                            'figuran ${numeroAgro(r.haSembradas)} ha sembradas. '
                            '¿Falta cargar la siembra?',
                            style: const TextStyle(
                                color: EstiloProduccion.rojo,
                                fontWeight: FontWeight.w600),
                          )),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 6),
                      const Text(
                        'El rendimiento lo calcula el sistema con las cosechas '
                        'cargadas (toneladas ÷ hectáreas cosechadas).',
                        style: TextStyle(
                            fontSize: 12, color: EstiloProduccion.textoSuave),
                      ),
                      const SizedBox(height: 22),
                      const TituloSeccion('Siembras y cosechas', icono: Icons.eco),
                      if (eventos.isEmpty)
                        const EstadoVacio(
                          icono: Icons.eco,
                          texto: 'Todavía no hay registros. Empezá por la '
                              'siembra.',
                        ),
                      ...eventos.map((e) => _tarjeta(e, corregidos)),
                      const SizedBox(height: 22),
                      const TituloSeccion('Monitoreos', icono: Icons.search),
                      BotonGrande(
                        texto: '+ Monitoreo',
                        icono: Icons.search,
                        flecha: true,
                        onPressed: _registrarMonitoreo,
                      ),
                      const SizedBox(height: 12),
                      if (monitoreos.isEmpty)
                        const EstadoVacio(
                          icono: Icons.search,
                          texto: 'Todavía no hay monitoreos. Anotá lo que ves '
                              'en cada recorrida: queda con su fecha y su '
                              'fuente.',
                        ),
                      ...monitoreos.map(_tarjetaMonitoreo),
                      const SizedBox(height: 22),
                      const TituloSeccion('Aplicaciones', icono: Icons.water_drop_outlined),
                      BotonGrande(
                        texto: '+ Aplicación',
                        icono: Icons.water_drop_outlined,
                        flecha: true,
                        onPressed: _registrarAplicacion,
                      ),
                      const SizedBox(height: 12),
                      if (aplicaciones.isEmpty)
                        const EstadoVacio(
                          icono: Icons.water_drop_outlined,
                          texto: 'Todavía no hay aplicaciones. Anotá cada '
                              'pasada: producto, dosis, quién aplicó y las '
                              'condiciones.',
                        ),
                      ...aplicaciones.map((e) => _tarjetaAplicacion(
                          e, superanSembrado.contains(e.eventoId))),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: BotonGrande(
                  texto: '+ Siembra',
                  icono: Icons.grass,
                  onPressed: cargando
                      ? null
                      : () => _registrar(TipoEventoProductivo.siembra),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BotonGrande(
                  texto: '+ Cosecha',
                  icono: Icons.agriculture,
                  contorno: true,
                  onPressed: cargando
                      ? null
                      : () => _registrar(TipoEventoProductivo.cosecha),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Aviso arriba de todo: lo último que se vio en nivel alto.
  Widget _alertaMonitoreo(List<EventoProductivo> alertas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EstiloProduccion.rojoFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EstiloProduccion.rojoBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.warning_rounded, color: EstiloProduccion.rojo, size: 26),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Atención: monitoreo en nivel alto',
                style: TextStyle(
                    color: EstiloProduccion.rojo,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          ...alertas.map((e) => Text(
                '${nombreObjetivoMonitoreo(e.objetivoMonitoreo)} · '
                '${fechaCorta(e.fechaHecho)}: ${e.observaciones ?? ''}',
                style: const TextStyle(color: EstiloProduccion.rojo),
              )),
        ],
      ),
    );
  }

  Widget _tarjetaAplicacion(EventoProductivo e, bool superaSembrado) {
    final condiciones = [
      if (e.vientoKmh != null) 'Viento ${numeroAgro(e.vientoKmh!)} km/h',
      if (e.temperatura != null) '${numeroAgro(e.temperatura!)} °C',
      if (e.humedadAmbiente != null)
        'Humedad ${numeroAgro(e.humedadAmbiente!)}%',
    ];
    final avisos = [
      if (superaSembrado)
        'Se aplicaron más hectáreas de las sembradas '
            '(${numeroAgro(calcularResumenCultivo(eventos).haSembradas)} ha).',
      if (vientoAlto(e.vientoKmh))
        'Se aplicó con viento mayor a '
            '${numeroAgro(vientoMaximoAviso)} km/h.',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconoCirculo(Icons.water_drop_outlined,
                  color: EstiloProduccion.terracota),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.tratamiento ?? 'Aplicación'} · '
                      '${fechaCorta(e.fechaHecho)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      [
                        '${numeroAgro(e.superficieHa ?? 0)} ha',
                        if (e.dosis != null) e.dosis!,
                        if (e.responsable != null) e.responsable!,
                      ].join(' · '),
                      style: const TextStyle(
                          fontSize: 14, color: EstiloProduccion.textoSuave),
                    ),
                    if (e.recetaNumero != null)
                      Text('Receta ${e.recetaNumero!}',
                          style: const TextStyle(fontSize: 13)),
                    if (e.movimientoStockId != null)
                      const Text('Descontado del stock',
                          style: TextStyle(
                              fontSize: 13, color: EstiloProduccion.verde)),
                    if (condiciones.isNotEmpty)
                      Text(condiciones.join(' · '),
                          style: const TextStyle(
                              fontSize: 13,
                              color: EstiloProduccion.textoSuave)),
                    if (e.observaciones != null)
                      Text(e.observaciones!,
                          style: const TextStyle(fontSize: 13)),
                    ...avisos.map((a) => Text(a,
                        style: const TextStyle(
                            fontSize: 13,
                            color: EstiloProduccion.rojo,
                            fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaMonitoreo(EventoProductivo e) {
    final color = switch (e.nivel) {
      'alto' => EstiloProduccion.rojo,
      'medio' => EstiloProduccion.terracota,
      _ => EstiloProduccion.verde,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconoCirculo(Icons.search, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${nombreObjetivoMonitoreo(e.objetivoMonitoreo)} · '
                      '${fechaCorta(e.fechaHecho)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Nivel ${nombreNivel(e.nivel).toLowerCase()} · '
                      '${nombreFuenteDato(e.fuenteDato)}',
                      style: TextStyle(
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.w600),
                    ),
                    if (e.observaciones != null)
                      Text(e.observaciones!,
                          style: const TextStyle(fontSize: 14)),
                    if (e.recomendacion != null)
                      Text('Recomendación: ${e.recomendacion!}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: EstiloProduccion.textoSuave)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dato(String etiqueta, String valor, {bool destacado = false}) {
    return TarjetaBlanca(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta,
                style: const TextStyle(
                    fontSize: 13, color: EstiloProduccion.textoSuave)),
            const SizedBox(height: 4),
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: destacado
                    ? EstiloProduccion.verde
                    : EstiloProduccion.texto,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(EventoProductivo e, Set<String> corregidos) {
    final esSiembra = e.tipo == TipoEventoProductivo.siembra;
    final fueCorregido = corregidos.contains(e.eventoId);
    final original = e.corrigeEventoId == null
        ? null
        : eventos.where((x) => x.eventoId == e.corrigeEventoId).firstOrNull;
    final detalle = esSiembra
        ? [
            '${numeroAgro(e.superficieHa ?? 0)} ha',
            if (e.material != null) e.material!,
            if (e.densidad != null) e.densidad!,
          ]
        : [
            '${numeroAgro(e.superficieHa ?? 0)} ha',
            '${numeroAgro(e.cantidadObtenida ?? 0)} ${e.unidadMedida ?? ''}',
            if (e.humedad != null) 'Humedad ${numeroAgro(e.humedad!)}%',
          ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        colorFondo: fueCorregido ? const Color(0xFFF3EEE5) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconoCirculo(esSiembra ? Icons.grass : Icons.agriculture,
                  color: esSiembra
                      ? EstiloProduccion.verde
                      : EstiloProduccion.terracota),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${esSiembra ? 'Siembra' : 'Cosecha'} · ${fechaCorta(e.fechaHecho)}'
                      '${fueCorregido ? ' · corregido' : ''}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: fueCorregido
                            ? EstiloProduccion.textoSuave
                            : EstiloProduccion.texto,
                      ),
                    ),
                    Text(detalle.join(' · '),
                        style: TextStyle(
                            fontSize: 14,
                            color: EstiloProduccion.textoSuave,
                            decoration: fueCorregido
                                ? TextDecoration.lineThrough
                                : null)),
                    if (original != null)
                      Text(
                        'Corrige el registro del ${fechaCorta(original.fechaHecho)}'
                        ' (${numeroAgro(original.superficieHa ?? 0)} ha'
                        '${original.cantidadObtenida != null ? ' · ${numeroAgro(original.cantidadObtenida!)} ${original.unidadMedida ?? ''}' : ''})',
                        style: const TextStyle(
                            fontSize: 12, color: EstiloProduccion.terracota),
                      ),
                    if (e.observaciones != null)
                      Text(e.observaciones!,
                          style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              if (!fueCorregido)
                TextButton(
                  onPressed: () => _registrar(e.tipo, corrige: e),
                  child: const Text('Corregir'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formulario de siembra o cosecha (solo agregar, declarado).
class RegistrarEventoCultivoScreen extends StatefulWidget {
  final GrupoProductivo grupo;
  final TipoEventoProductivo tipo;

  /// Si viene, es una corrección: el formulario arranca con esos datos y
  /// el registro nuevo dice a cuál corrige. El original no se borra.
  final EventoProductivo? corrige;

  const RegistrarEventoCultivoScreen({
    super.key,
    required this.grupo,
    required this.tipo,
    this.corrige,
  });

  @override
  State<RegistrarEventoCultivoScreen> createState() =>
      _RegistrarEventoCultivoScreenState();
}

class _RegistrarEventoCultivoScreenState
    extends State<RegistrarEventoCultivoScreen> {
  final ProduccionService _servicio = ProduccionService();
  final _ha = TextEditingController();
  final _cantidad = TextEditingController();
  final _material = TextEditingController();
  final _densidad = TextEditingController();
  final _humedad = TextEditingController();
  final _notas = TextEditingController();
  late final String eventoId = _servicio.nuevoIdEvento();

  DateTime fecha = DateTime.now();
  String unidad = 'tn';
  bool guardando = false;

  bool get esSiembra => widget.tipo == TipoEventoProductivo.siembra;

  // Valor exacto (sin redondear) para no cambiar el dato al corregir.
  String _n(double? v) => v == null
      ? ''
      : (v == v.roundToDouble() ? v.toInt().toString() : v.toString())
          .replaceAll('.', ',');

  @override
  void initState() {
    super.initState();
    _material.text = widget.grupo.material ?? '';
    final c = widget.corrige;
    if (c != null) {
      fecha = c.fechaHecho;
      _ha.text = _n(c.superficieHa);
      _cantidad.text = _n(c.cantidadObtenida);
      _material.text = c.material ?? _material.text;
      _densidad.text = c.densidad ?? '';
      _humedad.text = _n(c.humedad);
      _notas.text = c.observaciones ?? '';
      if (c.unidadMedida != null) unidad = c.unidadMedida!;
    }
  }

  @override
  void dispose() {
    for (final c in [_ha, _cantidad, _material, _densidad, _humedad, _notas]) {
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

  Future<void> _guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final evento = EventoProductivo(
      eventoId: eventoId,
      activoAgroId: widget.grupo.activoAgroId,
      grupoId: widget.grupo.grupoId,
      unidadId: widget.grupo.unidadInicialId,
      tipo: widget.tipo,
      fechaHecho: fecha,
      fechaCarga: DateTime.now(),
      cargadoPor: uid,
      corrigeEventoId: widget.corrige?.eventoId,
      observaciones: _txt(_notas),
      superficieHa: _num(_ha),
      cantidadObtenida: esSiembra ? null : _num(_cantidad),
      unidadMedida: esSiembra ? null : unidad,
      material: esSiembra ? _txt(_material) : null,
      densidad: esSiembra ? _txt(_densidad) : null,
      humedad: esSiembra ? null : _num(_humedad),
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
    final teclado = const TextInputType.numberWithOptions(decimal: true);
    return Scaffold(
      appBar: BarraCampo(
        title: Text(widget.corrige != null
            ? (esSiembra ? 'Corregir siembra' : 'Corregir cosecha')
            : (esSiembra ? 'Registrar siembra' : 'Registrar cosecha')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          if (widget.corrige != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Cambiá lo que esté mal y guardá. El registro anterior no se '
                'borra: queda como "corregido" en la historia.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
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
          EtiquetaCampo(
              esSiembra ? 'Hectáreas sembradas' : 'Hectáreas cosechadas'),
          TextField(
            controller: _ha,
            keyboardType: teclado,
            decoration: decoracionCampo(ayuda: 'Ej.: 100'),
          ),
          if (esSiembra) ...[
            const EtiquetaCampo('Variedad o híbrido (opcional)'),
            TextField(controller: _material, decoration: decoracionCampo()),
            const EtiquetaCampo('Densidad (opcional)'),
            TextField(
              controller: _densidad,
              decoration:
                  decoracionCampo(ayuda: 'Ej.: 70.000 pl/ha o 60 kg/ha'),
            ),
          ] else ...[
            const EtiquetaCampo('¿Cuánto se cosechó?'),
            TextField(
              controller: _cantidad,
              keyboardType: teclado,
              decoration: decoracionCampo(ayuda: 'Ej.: 350'),
            ),
            const EtiquetaCampo('Unidad'),
            OpcionesTocar<String>(
              opciones: unidadesCosecha,
              elegida: unidad,
              etiqueta: (u) => switch (u) {
                'tn' => 'Toneladas',
                'kg' => 'Kilos',
                'qq' => 'Quintales',
                _ => u,
              },
              alElegir: (u) => setState(() => unidad = u),
            ),
            const EtiquetaCampo('Humedad % (opcional)'),
            TextField(
              controller: _humedad,
              keyboardType: teclado,
              decoration: decoracionCampo(ayuda: 'Ej.: 13,5'),
            ),
          ],
          const EtiquetaCampo('Notas (opcional)'),
          TextField(
            controller: _notas,
            maxLines: 2,
            decoration: decoracionCampo(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda como declarado. No se edita ni se borra: si hay un error, '
            'cargá un registro nuevo y anotalo en las notas.',
            style: TextStyle(
                fontSize: 14, height: 1.5, color: EstiloProduccion.textoSuave),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: widget.corrige != null
                ? 'Guardar corrección'
                : (esSiembra ? 'Guardar siembra' : 'Guardar cosecha'),
            ocupado: guardando,
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
