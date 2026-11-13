import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';
import '../documentos/documentos_activo_screen.dart';
import '../emergencias/emergencias_activo_screen.dart';
import '../profesionales/profesionales_activo_screen.dart';
import '../traslados/traslados_activo_screen.dart';
import '../operaciones/operaciones_activo_screen.dart';
import '../produccion/produccion_activo_screen.dart';
import '../stock/stock_activo_screen.dart';
import 'ubicacion_activo_screen.dart';

class DetalleActivoAgroScreen extends StatefulWidget {
  final ActivoAgroV2 activo;

  const DetalleActivoAgroScreen({super.key, required this.activo});

  @override
  State<DetalleActivoAgroScreen> createState() =>
      _DetalleActivoAgroScreenState();
}

class _DetalleActivoAgroScreenState extends State<DetalleActivoAgroScreen> {
  final ActivoAgroServiceV2 _activoService = ActivoAgroServiceV2();

  late ActivoAgroV2 activo;

  bool evaluando = false;
  Future<void> evaluarActivo() async {
    if (evaluando) {
      return;
    }

    setState(() {
      evaluando = true;
    });

    try {
      await _activoService.evaluarActivo(activo.activoId);

      final actualizado = await _activoService.obtenerActivoPorId(
        activo.activoId,
      );

      if (actualizado == null) {
        throw Exception('No se pudo recuperar el activo actualizado');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        activo = actualizado;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evaluación de confianza realizada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error evaluando activo: $e')));
    } finally {
      if (mounted) {
        setState(() {
          evaluando = false;
        });
      }
    }
  }

  /// AF-090: abre el mapa; si se guardó, relee el campo.
  Future<void> _abrirMapa() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => UbicacionActivoScreen(activo: activo),
      ),
    );
    if (guardo != true) return;
    final actualizado =
        await _activoService.obtenerActivoPorId(activo.activoId);
    if (!mounted || actualizado == null) return;
    setState(() => activo = actualizado);
  }

  @override
  void initState() {
    super.initState();

    activo = widget.activo;
  }

  // =====================================================
  // DISEÑO DE LA FICHA (12/11/2026): mismo estilo que el Inicio.
  // Arriba el resumen, después los módulos en columnas y abajo el
  // detalle en secciones que se abren. No se quitó ningún dato.
  // =====================================================

  /// "sin_evaluar" -> "Sin evaluar" (nombres internos a texto claro).
  String _claro(String? valor, {String vacio = 'Sin información'}) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return vacio;
    final t = v.replaceAll('_', ' ');
    return t[0].toUpperCase() + t.substring(1);
  }

  String _numero(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void _abrir(Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgroTema.crema,
      appBar: AppBar(title: Text(activo.nombre)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _resumen(),
          if (activo.madurez.faltantes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _proximoPaso(),
          ],
          const SizedBox(height: 18),
          const Text(
            'Gestión del campo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AgroTema.pizarra,
            ),
          ),
          const SizedBox(height: 10),
          _modulos(),
          const SizedBox(height: 22),
          const Text(
            'Información del expediente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AgroTema.pizarra,
            ),
          ),
          const SizedBox(height: 10),
          _secciones(),
        ],
      ),
    );
  }

  // ---------------- RESUMEN ----------------

  Widget _resumen() {
    final u = activo.ubicacion;
    final lugar = [u.localidad, u.provincia, u.pais]
        .where((x) => x.trim().isNotEmpty)
        .join(', ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AgroTema.pizarra,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activo.nombre,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (activo.descripcion.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              activo.descripcion,
              style: const TextStyle(fontSize: 15, color: AgroTema.crema),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place, size: 18, color: Color(0xFFF2C08F)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lugar.isEmpty ? 'Ubicación sin información' : lugar,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _datoGrande(
                  Icons.straighten,
                  u.superficie > 0 ? _numero(u.superficie) : '—',
                  'Hectáreas',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _datoGrande(
                  Icons.grass,
                  activo.produccionPrincipal == null
                      ? '—'
                      : _claro(activo.produccionPrincipal!.actividad),
                  'Actividad',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _datoGrande(
                  Icons.photo_library,
                  '${activo.confianza.cantidadEvidencias}',
                  'Evidencias',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(
                u.tieneCoordenadas ? Icons.location_on : Icons.location_off,
                u.tieneCoordenadas ? 'En el mapa' : 'Sin marcar en el mapa',
                alerta: !u.tieneCoordenadas,
              ),
              _chip(Icons.trending_up,
                  'Expediente ${_numero(activo.madurez.porcentaje)}%'),
              _chip(Icons.verified, 'Confianza ${activo.confianza.nivelGeneral}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datoGrande(IconData icono, String valor, String texto) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: const Color(0xFFF2C08F)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Text(texto,
              style: const TextStyle(fontSize: 12, color: AgroTema.crema)),
        ],
      ),
    );
  }

  Widget _chip(IconData icono, String texto, {bool alerta = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: alerta
            ? AgroTema.terracota.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(texto,
              style: const TextStyle(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  /// Un solo próximo paso (regla de diseño: una pantalla, una pregunta).
  Widget _proximoPaso() {
    final faltantes = activo.madurez.faltantes;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AgroTema.borde),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: AgroTema.terracota),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Próximo paso',
                  style: TextStyle(
                      fontSize: 12, color: AgroTema.pizarraSuave),
                ),
                Text(
                  _claro(faltantes.first),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AgroTema.pizarra,
                  ),
                ),
                if (faltantes.length > 1)
                  Text(
                    'Y ${faltantes.length - 1} '
                    '${faltantes.length - 1 == 1 ? 'pendiente más' : 'pendientes más'} '
                    '(ver "Avance del expediente")',
                    style: const TextStyle(
                        fontSize: 12, color: AgroTema.pizarraSuave),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- MÓDULOS (dos columnas) ----------------

  Widget _modulos() {
    final id = activo.activoId;
    final nombre = activo.nombre;
    final modulos = <(IconData, String, String, Color, VoidCallback?)>[
      (
        activo.ubicacion.tieneCoordenadas
            ? Icons.location_on
            : Icons.add_location_alt,
        activo.ubicacion.tieneCoordenadas ? 'Mapa' : 'Marcar en el mapa',
        'Dónde está el campo (privado)',
        AgroTema.azul,
        _abrirMapa,
      ),
      (
        Icons.pets,
        'Producción',
        'Rodeos, potreros y eventos',
        AgroTema.verde,
        () => _abrir(ProduccionActivoScreen(
            activoAgroId: id, nombreActivo: nombre)),
      ),
      (
        Icons.verified_user,
        'Operaciones protegidas',
        'Ventas, cheques y garantías',
        AgroTema.pizarra,
        () => _abrir(OperacionesActivoScreen(
            activoAgroId: id, nombreActivo: nombre)),
      ),
      (
        Icons.description,
        'Documentos',
        'Escrituras, permisos, certificaciones',
        AgroTema.terracota,
        () => _abrir(DocumentosActivoScreen(
            activoAgroId: id, nombreActivo: nombre)),
      ),
      (
        Icons.local_shipping,
        'Traslados',
        'Salidas de hacienda, granos y más',
        const Color(0xFFE8893A),
        () => _abrir(
            TrasladosActivoScreen(activoAgroId: id, nombreActivo: nombre)),
      ),
      (
        Icons.badge,
        'Profesionales',
        'Agrónomos, veterinarios, técnicos',
        AgroTema.azul,
        () => _abrir(ProfesionalesActivoScreen(
            activoAgroId: id, nombreActivo: nombre)),
      ),
      (
        Icons.warning_amber,
        'Emergencias',
        'Inundación, sequía, incendio...',
        AgroTema.rojo,
        () => _abrir(EmergenciasActivoScreen(
            activoAgroId: id, nombreActivo: nombre)),
      ),
      (
        Icons.inventory_2,
        'Stock e insumos',
        'Semillas, productos, combustible',
        AgroTema.verde,
        () => _abrir(
            StockActivoScreen(activoAgroId: id, nombreActivo: nombre)),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modulos.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 82,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final (icono, texto, ayuda, color, alTocar) = modulos[i];
        final pronto = alTocar == null;
        return Material(
          color: pronto ? const Color(0xFFF3EEE5) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AgroTema.borde),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: alTocar,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(icono, size: 30, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          texto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: pronto
                                ? AgroTema.pizarraSuave
                                : AgroTema.pizarra,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ayuda,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AgroTema.pizarraSuave),
                        ),
                      ],
                    ),
                  ),
                  if (!pronto)
                    const Icon(Icons.chevron_right,
                        color: AgroTema.pizarraSuave),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- SECCIONES QUE SE ABREN ----------------

  Widget _fila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(etiqueta,
                style: const TextStyle(
                    fontSize: 14, color: AgroTema.pizarraSuave)),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(fontSize: 14, color: AgroTema.pizarra)),
          ),
        ],
      ),
    );
  }

  Widget _seccion(IconData icono, String titulo, List<Widget> contenido,
      {String? resumen}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AgroTema.borde),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: Icon(icono, color: AgroTema.terracota),
          title: Text(titulo,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AgroTema.pizarra)),
          subtitle: resumen == null
              ? null
              : Text(resumen,
                  style: const TextStyle(
                      fontSize: 13, color: AgroTema.pizarraSuave)),
          shape: const Border(),
          collapsedShape: const Border(),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: contenido,
        ),
      ),
    );
  }

  Widget _secciones() {
    final s = activo.suelo;
    final e = activo.economia;
    final ev = activo.evaluacion;
    final p = activo.produccionPrincipal;

    return Column(
      children: [
        _seccion(Icons.landscape, 'Suelo', [
          _fila('Estado', _claro(s.estado)),
          _fila('Textura', _claro(s.textura)),
          _fila('Drenaje', _claro(s.drenaje)),
          _fila('pH', s.ph == null ? 'Sin información' : _numero(s.ph!)),
          _fila('Materia orgánica',
              s.materiaOrganica == null ? 'Sin información' : _numero(s.materiaOrganica!)),
          _fila('Evidencias', '${s.evidencias.length}'),
          if (s.observaciones != null && s.observaciones!.isNotEmpty)
            _fila('Observaciones', s.observaciones!),
          if (s.fechaEvaluacion != null)
            _fila('Evaluado el', '${s.fechaEvaluacion}'),
        ], resumen: _claro(s.estado)),
        _seccion(Icons.category, 'Clasificación y producción', [
          _fila('Tipo de campo', _claro(activo.tipoActivo.name)),
          _fila('Categorías',
              activo.categorias.isEmpty ? 'Sin información' : activo.categorias.map(_claro).join(', ')),
          _fila('Actividad principal', p == null ? 'Sin producción registrada' : _claro(p.actividad)),
          if (p != null && p.descripcion.trim().isNotEmpty)
            _fila('Descripción', p.descripcion),
        ], resumen: p == null ? 'Sin producción registrada' : _claro(p.actividad)),
        _seccion(Icons.payments, 'Economía', [
          _fila('Valor solicitado', '${e.valorSolicitado} ${e.moneda}'),
          _fila('Tipo de operación', _claro(e.tipoOperacion)),
          _fila('Capital requerido', '${e.capitalRequerido} ${e.moneda}'),
          _fila('Inversión esperada', '${e.inversionEsperada} ${e.moneda}'),
          _fila('Período de evaluación', _claro(e.periodoEvaluacion)),
          if (e.objetivoProyecto.isNotEmpty) _fila('Objetivo', e.objetivoProyecto),
          if (e.etapaProyecto.isNotEmpty) _fila('Etapa', e.etapaProyecto),
          if (e.capacidadActual.isNotEmpty) _fila('Capacidad actual', e.capacidadActual),
          if (e.capacidadProyectada.isNotEmpty) _fila('Capacidad proyectada', e.capacidadProyectada),
          if (e.ingresosEstimados.isNotEmpty) _fila('Ingresos estimados', e.ingresosEstimados),
          if (e.costosEstimados.isNotEmpty) _fila('Costos estimados', e.costosEstimados),
          if (e.rentabilidadDeclarada.isNotEmpty) _fila('Rentabilidad declarada', e.rentabilidadDeclarada),
          if (e.riesgosIdentificados.isNotEmpty) _fila('Riesgos identificados', e.riesgosIdentificados),
          if (e.datosEconomicos.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Text('Datos económicos trazables',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            for (final dato in e.datosEconomicos)
              _fila(dato.nombreDato,
                  '${dato.valor} · ${_claro(dato.tipoTemporal.name)} · ${dato.periodo}'
                  '${dato.escenarioId != null && dato.escenarioId!.isNotEmpty ? ' · Escenario ${dato.escenarioId}' : ''}'),
          ],
        ]),
        _seccion(Icons.warehouse, 'Infraestructura', [
          if (activo.infraestructura.isEmpty)
            const Text('Sin infraestructura registrada',
                style: TextStyle(color: AgroTema.pizarraSuave))
          else
            for (final inf in activo.infraestructura) ...[
              Text(inf.nombre.isEmpty ? _claro(inf.tipo) : inf.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              _fila('Tipo', _claro(inf.tipo)),
              if (inf.descripcion.isNotEmpty) _fila('Descripción', inf.descripcion),
              _fila('Cantidad', '${inf.cantidad}'),
              _fila('Estado', _claro(inf.estado)),
              if (inf.moduloProduccionId != null && inf.moduloProduccionId!.isNotEmpty)
                _fila('Producción relacionada', inf.moduloProduccionId!),
              const SizedBox(height: 6),
            ],
        ], resumen: '${activo.infraestructura.length} registrada(s)'),
        _seccion(Icons.verified, 'Confianza', [
          _fila('Nivel general', '${activo.confianza.nivelGeneral}%'),
          _fila('Evaluación', '${ev.nivelGeneral}%'),
          _fila('Documental', '${_claro(ev.documental.estado)} (${ev.documental.nivel}%)'),
          _fila('Productivo', '${_claro(ev.productivo.estado)} (${ev.productivo.nivel}%)'),
          _fila('Económico', '${_claro(ev.economico.estado)} (${ev.economico.nivel}%)'),
          _fila('Legal', '${_claro(ev.legal.estado)} (${ev.legal.nivel}%)'),
          _fila('Profesional', '${_claro(ev.profesional.estado)} (${ev.profesional.nivel}%)'),
          _fila('Evidencias', '${activo.confianza.cantidadEvidencias}'),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: evaluando ? null : evaluarActivo,
              icon: evaluando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.analytics),
              label: Text(evaluando ? 'Evaluando...' : 'Evaluar confianza'),
            ),
          ),
        ], resumen: '${activo.confianza.nivelGeneral}%'),
        _seccion(Icons.trending_up, 'Avance del expediente', [
          _fila('Completo', '${_numero(activo.madurez.porcentaje)}%'),
          if (activo.madurez.faltantes.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text('Pendientes:',
                style: TextStyle(fontWeight: FontWeight.w700)),
            for (final f in activo.madurez.faltantes)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• ${_claro(f)}'),
              ),
          ],
        ], resumen: '${_numero(activo.madurez.porcentaje)}%'),
        _seccion(Icons.history, 'Historial del campo', [
          if (activo.historial.isEmpty)
            const Text('Todavía no hay movimientos registrados.',
                style: TextStyle(color: AgroTema.pizarraSuave))
          else
            for (final h in ([...activo.historial]
                  ..sort((a, b) => b.fecha.compareTo(a.fecha)))
                .take(15))
              _fila(fechaCortaFicha(h.fecha), h.descripcion),
          if (activo.historial.length > 15)
            Text('Se muestran los últimos 15 de ${activo.historial.length}.',
                style: const TextStyle(
                    fontSize: 12, color: AgroTema.pizarraSuave)),
        ], resumen: activo.historial.isEmpty
            ? 'Sin movimientos'
            : '${activo.historial.length} registro(s)'),
        _seccion(Icons.group, 'Participantes y publicación', [
          if (activo.participantes.isEmpty)
            const Text('Sin participantes registrados',
                style: TextStyle(color: AgroTema.pizarraSuave))
          else
            for (final pa in activo.participantes)
              _fila(_claro(pa.rol), pa.usuarioId),
          const SizedBox(height: 6),
          _fila('Estado interno', _claro(activo.estado.name)),
          _fila('Publicación', _claro(activo.estadoPublicacion)),
          _fila('Visibilidad',
              activo.visible ? 'Visible públicamente' : 'No visible públicamente'),
        ]),
      ],
    );
  }
}

/// Fecha corta para el historial (dd/mm/aaaa).
String fechaCortaFicha(DateTime f) =>
    '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
