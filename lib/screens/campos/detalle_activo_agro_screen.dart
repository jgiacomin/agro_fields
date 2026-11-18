import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/produccion_service.dart';
import '../documentos/documentos_activo_screen.dart';
import '../emergencias/emergencias_activo_screen.dart';
import '../encargados/encargados_activo_screen.dart';
import '../profesionales/profesionales_activo_screen.dart';
import '../traslados/traslados_activo_screen.dart';
import '../operaciones/operaciones_activo_screen.dart';
import '../produccion/produccion_activo_screen.dart';
import '../economia/economia_activo_screen.dart';
import '../stock/stock_activo_screen.dart';
import '../territorio/historia_territorio_screen.dart';
import 'primeros_pasos.dart';
import 'suelo_activo_screen.dart';
import 'ubicacion_activo_screen.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';

class DetalleActivoAgroScreen extends StatefulWidget {
  final ActivoAgroV2 activo;

  const DetalleActivoAgroScreen({super.key, required this.activo});

  @override
  State<DetalleActivoAgroScreen> createState() =>
      _DetalleActivoAgroScreenState();
}

class _DetalleActivoAgroScreenState extends State<DetalleActivoAgroScreen> {
  final ActivoAgroServiceV2 _activoService = ActivoAgroServiceV2();
  final ProduccionService _produccion = ProduccionService();

  /// QA Grupo B: cuántos lugares y cuántos rodeos/lotes/cultivos tiene el
  /// campo (para "Primeros pasos"). null = todavía no se sabe.
  int? _lugares;
  int? _animalesOCultivos;

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

  /// GAP-SUELO-01: abre la carga del suelo; si se guardó, relee el campo.
  Future<void> _abrirSuelo() async {
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SueloActivoScreen(activo: activo),
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
    _cargarProduccion();
  }

  bool get _esDueno =>
      FirebaseAuth.instance.currentUser?.uid == activo.propietarioId;

  /// QA Grupo B: solo hace falta para "Primeros pasos" (lo ve el dueño).
  Future<void> _cargarProduccion() async {
    if (!_esDueno) return;
    try {
      final unidades = await _produccion.unidadesDeActivo(activo.activoId);
      final grupos = await _produccion.gruposDeActivo(activo.activoId);
      if (!mounted) return;
      setState(() {
        _lugares = unidades.length;
        _animalesOCultivos = grupos.length;
      });
    } catch (_) {
      // Sin señal o sin permiso: la tarjeta no se muestra.
    }
  }

  /// Al volver de otra pantalla: relee el campo y lo de Producción, así
  /// las tildes de "Primeros pasos" se actualizan solas.
  Future<void> _recargar() async {
    try {
      final actualizado =
          await _activoService.obtenerActivoPorId(activo.activoId);
      if (mounted && actualizado != null) {
        setState(() => activo = actualizado);
      }
    } catch (_) {}
    await _cargarProduccion();
  }

  EstadoPrimerosPasos? get _primerosPasos {
    final lugares = _lugares;
    final animales = _animalesOCultivos;
    if (!_esDueno || lugares == null || animales == null) return null;
    final estado = EstadoPrimerosPasos.desdeActivo(activo,
        lugares: lugares, animalesOCultivos: animales);
    return estado.completos ? null : estado;
  }

  void _abrirPaso(PasoInicial paso) {
    final id = activo.activoId;
    final nombre = activo.nombre;
    switch (paso) {
      case PasoInicial.mapa:
        _abrirMapa();
        break;
      case PasoInicial.documento:
        _abrir(DocumentosActivoScreen(activoAgroId: id, nombreActivo: nombre));
        break;
      case PasoInicial.suelo:
        _abrirSuelo();
        break;
      case PasoInicial.lugares:
        _abrir(ProduccionActivoScreen(
            activoAgroId: id,
            nombreActivo: nombre,
            enfoque: EnfoqueProduccion.lugares));
        break;
      case PasoInicial.animalesOCultivos:
        _abrir(ProduccionActivoScreen(
            activoAgroId: id,
            nombreActivo: nombre,
            enfoque: EnfoqueProduccion.animales));
        break;
    }
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

  /// Decimales con coma, como se escribe en la región (6,5).
  String _numero(num v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toString().replaceAll('.', ',');

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    // QA Grupo B: al volver se actualizan las tildes de "Primeros pasos".
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(title: Text(activo.nombre)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _resumen(),
          // QA Grupo B: mientras falten primeros pasos, se muestran ellos
          // en vez del "Próximo paso" (una pantalla, una pregunta).
          if (_primerosPasos != null) ...[
            const SizedBox(height: 12),
            TarjetaPrimerosPasos(
                estado: _primerosPasos!, alTocar: _abrirPaso),
          ] else if (activo.madurez.faltantes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _proximoPaso(),
          ],
          const SizedBox(height: 20),
          // Diseño V8 (16/11/2026): títulos con la banda oscura.
          const TituloSeccion('Gestión del campo', icono: Icons.agriculture),
          _modulos(),
          const SizedBox(height: 22),
          const TituloSeccion('Información del expediente',
              icono: Icons.folder_open),
          _secciones(),
        ],
      ),
    );
  }

  // ---------------- RESUMEN ----------------

  /// Diseño V8 (16/11/2026): tarjeta crema con nombre y lugar, chips y los
  /// números de colores (como el resumen de Producción), en dos filas para
  /// que entren en el celular.
  Widget _resumen() {
    final u = activo.ubicacion;
    final lugar = [u.localidad, u.provincia, u.pais]
        .where((x) => x.trim().isNotEmpty)
        .join(', ');
    final actividad = activo.produccionPrincipal == null
        ? null
        : _claro(activo.produccionPrincipal!.actividad);
    return TarjetaBlanca(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconoCirculo(Icons.grass,
                    color: AgroTema.verde, tamano: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activo.nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AgroTema.pizarra,
                        ),
                      ),
                      if (activo.descripcion.trim().isNotEmpty)
                        Text(
                          activo.descripcion,
                          style: const TextStyle(
                              fontSize: 14, color: AgroTema.pizarraSuave),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.place, size: 18, color: AgroTema.terracota),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    lugar.isEmpty ? 'Ubicación sin información' : lugar,
                    style: const TextStyle(
                        fontSize: 14, color: AgroTema.pizarra),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(Icons.grass, actividad ?? 'Sin actividad cargada',
                    color: AgroTema.verde),
                _chip(
                  u.tieneCoordenadas ? Icons.location_on : Icons.location_off,
                  u.tieneCoordenadas ? 'En el mapa' : 'Sin marcar en el mapa',
                  color: u.tieneCoordenadas
                      ? AgroTema.azul
                      : AgroTema.terracota,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ResumenNumeros([
              (
                u.superficie > 0 ? _numero(u.superficie) : '—',
                'hectáreas',
                Icons.straighten,
                AgroTema.azul,
              ),
              (
                '${activo.confianza.cantidadEvidencias}',
                'evidencias',
                Icons.photo_library,
                AgroTema.terracota,
              ),
            ]),
            const SizedBox(height: 10),
            ResumenNumeros([
              (
                '${_numero(activo.madurez.porcentaje)}%',
                'expediente',
                Icons.trending_up,
                AgroTema.verde,
              ),
              (
                '${activo.confianza.nivelGeneral}%',
                'confianza',
                Icons.verified,
                AgroTema.pizarra,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icono, String texto, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 6),
          Text(texto,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  /// Un solo próximo paso (regla de diseño: una pantalla, una pregunta).
  Widget _proximoPaso() {
    final faltantes = activo.madurez.faltantes;
    // Diseño V8: destacado con borde naranja e ícono en círculo.
    return TarjetaBlanca(
      colorBorde: AgroTema.terracota,
      colorFondo: AgroTema.terracotaClaro,
      child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const IconoCirculo(Icons.flag,
              color: AgroTema.terracota, tamano: 44),
          const SizedBox(width: 12),
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
      // QA T1-06 (18/11/2026): el suelo estaba escondido abajo.
      (
        Icons.terrain,
        'Suelo',
        'Textura, pH, materia orgánica',
        AgroTema.terracota,
        _abrirSuelo,
      ),
      (
        Icons.pets,
        'Producción',
        'Lugares, animales y cultivos',
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
        Icons.engineering,
        'Encargados',
        'Quién trabaja el campo y qué carga',
        AgroTema.pizarra,
        () => _abrir(EncargadosActivoScreen(
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
        Icons.landscape,
        'Historia del territorio',
        'Desmontes, canales, caminos...',
        AgroTema.verde,
        () => _abrir(HistoriaTerritorioScreen(
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
      (
        Icons.payments_outlined,
        'Economía',
        'Gastos del mes por categoría',
        AgroTema.terracota,
        () => _abrir(
            EconomiaActivoScreen(activoAgroId: id, nombreActivo: nombre)),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modulos.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 94,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final (icono, texto, ayuda, color, alTocar) = modulos[i];
        final pronto = alTocar == null;
        // Diseño V8: tarjeta crema con el ícono en círculo. Sin flecha y con
        // el nombre en hasta 2 renglones, para que no se corte en el celular.
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: TarjetaBlanca(
            onTap: alTocar,
            colorFondo:
                pronto ? const Color(0xFFF3EEE5) : const Color(0xFFFFFAF2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconoCirculo(icono,
                      color: pronto ? AgroTema.pizarraSuave : color,
                      tamano: 44),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          texto,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
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
                              fontSize: 12,
                              height: 1.2,
                              color: AgroTema.pizarraSuave),
                        ),
                      ],
                    ),
                  ),
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
      // Diseño V8: tarjeta crema con sombra e ícono en círculo.
      child: Material(
        color: const Color(0xFFFFFAF2),
        elevation: 1.5,
        shadowColor: const Color(0x22000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE6D6BC)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading:
              IconoCirculo(icono, color: AgroTema.terracota, tamano: 40),
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
          // GAP-SUELO-01: se muestran solo si están cargados.
          if (s.profundidad != null) _fila('Profundidad', _claro(s.profundidad)),
          if (s.salinidad != null) _fila('Salinidad', _claro(s.salinidad)),
          if (s.erosion != null) _fila('Erosión', _claro(s.erosion)),
          if (s.clase != null) _fila('Capacidad de uso', 'Clase ${s.clase}'),
          if (s.limitaciones != null && s.limitaciones!.isNotEmpty)
            _fila('Limitaciones', s.limitaciones!),
          _fila('Evidencias', '${s.evidencias.length}'),
          if (s.observaciones != null && s.observaciones!.isNotEmpty)
            _fila('Observaciones', s.observaciones!),
          if (s.fechaEvaluacion != null)
            _fila('Evaluado el', fechaCortaFicha(s.fechaEvaluacion!)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _abrirSuelo,
              icon: const Icon(Icons.edit, size: 18),
              label: Text(s.estado == 'sin_evaluar'
                  ? 'Cargar suelo'
                  : 'Editar suelo'),
            ),
          ),
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
