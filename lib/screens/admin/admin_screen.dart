import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/auth/admin.dart';
import '../../core/theme/agro_tema.dart';
import '../../models/aceptacion_legal_model.dart';
import '../../models/activos/activo_publico_model.dart';
import '../../models/plan_usuario_model.dart';
import '../../services/admin_service.dart';
import '../../services/habilitacion_service.dart';
import '../../services/encargado_service.dart' show CodigoNoValido;
import '../../widgets/aviso_codigo_equivocado.dart';
import '../produccion/produccion_estilo.dart';

/// GAP-ADMIN-01 (16/11/2026): pantalla del administrador.
/// Tres pestañas: publicaciones a revisar, Fundadores y pedidos de baja.
/// Solo se muestra al admin; las reglas de Firebase son las que protegen.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AgroTema.pizarra,
          foregroundColor: Colors.white,
          title: const Text('Administración'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AgroTema.terracota,
            tabs: [
              Tab(text: 'Publicaciones'),
              Tab(text: 'Fundadores'),
              Tab(text: 'Bajas'),
            ],
          ),
        ),
        body: FutureBuilder<bool>(
          future: esAdminActual(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.data != true || uid == null) {
              return const Center(child: Text('Solo para administradores.'));
            }
            return TabBarView(
              children: [
                _Publicaciones(adminId: uid),
                _Fundadores(adminId: uid),
                _Bajas(adminId: uid),
              ],
            );
          },
        ),
      ),
    );
  }
}

void _avisar(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
}

// =====================================================================
// PUBLICACIONES
// =====================================================================

class _Publicaciones extends StatefulWidget {
  final String adminId;
  const _Publicaciones({required this.adminId});

  @override
  State<_Publicaciones> createState() => _PublicacionesState();
}

class _PublicacionesState extends State<_Publicaciones> {
  final AdminService _admin = AdminService();
  final HabilitacionService _habilitacion = HabilitacionService();
  Future<List<ActivoPublico>>? _futuro;
  Future<List<Habilitado>>? _habilitados;

  @override
  void initState() {
    super.initState();
    _futuro = _admin.publicacionesPendientes();
    _habilitados = _habilitacion.habilitados();
  }

  // QA 20/11/2026: setState no puede devolver un Future (daba error al
  // aprobar o rechazar). Se asigna adentro de un bloque.
  void _recargar() => setState(() {
        _futuro = _admin.publicacionesPendientes();
        _habilitados = _habilitacion.habilitados();
      });

  Future<void> _aprobar(ActivoPublico p) async {
    // PUB-DIRECTO (27/11/2026): al aprobar, se puede habilitar a quien
    // publicó para que de ahora en más publique directo.
    final quien =
        p.ultimoCambioPor.isNotEmpty ? p.ultimoCambioPor : p.propietarioId;
    final yaHabilitado = await _habilitacion.estaHabilitado(quien);
    if (!mounted) return;
    var habilitar = !yaHabilitado;
    final seguir = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogo) => AlertDialog(
          title: const Text('Aprobar publicación'),
          content: yaHabilitado
              ? const Text('Quien publicó ya está habilitado para publicar '
                  'directo.')
              : CheckboxListTile(
                  value: habilitar,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setDialogo(() => habilitar = v ?? false),
                  title: const Text('Habilitar para publicar directo'),
                  subtitle: const Text(
                      'De ahora en más sus avisos y cambios se ven al instante, '
                      'sin revisión. Podés sacarle el permiso cuando quieras.'),
                ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar')),
            ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Aprobar')),
          ],
        ),
      ),
    );
    if (seguir != true) return;
    try {
      await _admin.aprobar(p, widget.adminId);
      if (habilitar && !yaHabilitado && quien.isNotEmpty) {
        await _habilitacion.habilitar(quien, widget.adminId);
      }
      if (!mounted) return;
      _avisar(
          context,
          habilitar && !yaHabilitado
              ? 'Aprobada y habilitado para publicar directo.'
              : 'Aprobada: ya aparece en el Mercado de campos.');
      _recargar();
    } catch (e) {
      if (!mounted) return;
      _avisar(context, 'No se pudo aprobar: $e');
    }
  }

  Future<void> _rechazar(ActivoPublico p) async {
    final control = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar publicación'),
        content: TextField(
          controller: control,
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: decoracionCampo(
              ayuda: 'Motivo (lo ve quien publicó). Ej.: faltan fotos'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(control.text),
              child: const Text('Rechazar')),
        ],
      ),
    );
    control.dispose();
    if (motivo == null) return;
    try {
      await _admin.rechazar(p, widget.adminId, motivo);
      if (!mounted) return;
      _avisar(context, 'Rechazada.');
      _recargar();
    } catch (e) {
      if (!mounted) return;
      _avisar(context, 'No se pudo rechazar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActivoPublico>>(
      future: _futuro,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('No se pudo cargar: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final lista = snap.data!;
        return RefreshIndicator(
          onRefresh: () async => _recargar(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (lista.isEmpty)
                const EstadoVacio(
                  icono: Icons.inbox_outlined,
                  texto: 'No hay publicaciones esperando revisión.',
                ),
              for (final p in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TarjetaBlanca(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.nombre,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (p.provincia.isNotEmpty) p.provincia,
                              if (p.localidad.isNotEmpty) p.localidad,
                              '${p.superficie.toStringAsFixed(0)} ha',
                              p.tipoActivo,
                              'Enviada el ${fechaCorta(p.ultimaActualizacion)}',
                            ].join(' · '),
                            style: const TextStyle(
                                fontSize: 13,
                                color: EstiloProduccion.textoSuave),
                          ),
                          if (p.descripcion.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(p.descripcion,
                                maxLines: 3, overflow: TextOverflow.ellipsis),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _rechazar(p),
                                  child: const Text('Rechazar'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _aprobar(p),
                                  child: const Text('Aprobar'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _seccionHabilitados(),
            ],
          ),
        );
      },
    );
  }

  /// PUB-DIRECTO: quiénes publican directo, con el botón para sacar el permiso.
  Widget _seccionHabilitados() {
    return FutureBuilder<List<Habilitado>>(
      future: _habilitados,
      builder: (context, snap) {
        final lista = snap.data ?? const <Habilitado>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Habilitados para publicar directo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            if (!snap.hasData && !snap.hasError)
              const LinearProgressIndicator()
            else if (lista.isEmpty)
              const Text('Todavía no habilitaste a nadie.',
                  style: TextStyle(color: EstiloProduccion.textoSuave)),
            for (final h in lista)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_outlined),
                title: Text(h.nombre),
                subtitle: h.fecha == null
                    ? null
                    : Text('Desde el ${fechaCorta(h.fecha!)}'),
                trailing: TextButton(
                  onPressed: () => _quitar(h),
                  child: const Text('Quitar permiso'),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _quitar(Habilitado h) async {
    final seguir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar permiso'),
        content: Text('${h.nombre} va a volver a pasar por revisión cada vez '
            'que publique o cambie un aviso.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Quitar')),
        ],
      ),
    );
    if (seguir != true) return;
    try {
      await _habilitacion.quitar(h.usuarioId, widget.adminId);
      if (!mounted) return;
      _avisar(context, 'Permiso quitado.');
      _recargar();
    } catch (e) {
      if (!mounted) return;
      _avisar(context, 'No se pudo quitar: $e');
    }
  }
}

// =====================================================================
// FUNDADORES
// =====================================================================

class _Fundadores extends StatefulWidget {
  final String adminId;
  const _Fundadores({required this.adminId});

  @override
  State<_Fundadores> createState() => _FundadoresState();
}

class _FundadoresState extends State<_Fundadores> {
  final AdminService _admin = AdminService();
  final TextEditingController _codigo = TextEditingController();
  GrupoFundador grupo = GrupoFundador.gestion;
  bool guardando = false;
  Future<List<PlanUsuario>>? _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _admin.fundadores();
  }

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _alta() async {
    setState(() => guardando = true);
    try {
      await _admin.altaFundador(
          codigo: _codigo.text, grupo: grupo, adminId: widget.adminId);
      if (!mounted) return;
      _codigo.clear();
      _avisar(context, 'Fundador dado de alta: Pro gratis por 12 meses.');
      setState(() {
        _futuro = _admin.fundadores();
      });
    } on CodigoNoValido {
      if (!mounted) return;
      await mostrarCodigoEquivocado(context);
    } on StateError catch (e) {
      // QA 20/11/2026: sin el "Bad state:" en inglés.
      if (!mounted) return;
      _avisar(context, e.message);
    } catch (e) {
      if (!mounted) return;
      _avisar(context, 'No se pudo dar de alta: $e');
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlanUsuario>>(
      future: _futuro,
      builder: (context, snap) {
        final lista = snap.data ?? const <PlanUsuario>[];
        final cuenta = AdminService.contarPorGrupo(lista);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TarjetaBlanca(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gestión: ${cuenta[GrupoFundador.gestion]} de ${AdminService.cupoFundadores}'
                  '  ·  Inmobiliarias: ${cuenta[GrupoFundador.inmobiliaria]} de ${AdminService.cupoFundadores}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const TituloSeccion('Dar de alta', icono: Icons.person_add_alt),
            const Text(
              'La persona entra a la app y copia su código en '
              'Menú → Mi código. Pegalo acá y elegí el grupo.',
              style: TextStyle(color: EstiloProduccion.textoSuave, height: 1.4),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codigo,
              decoration: decoracionCampo(ayuda: 'Código de la persona'),
            ),
            const SizedBox(height: 10),
            OpcionesTocar<GrupoFundador>(
              opciones: GrupoFundador.values,
              elegida: grupo,
              etiqueta: (g) => g == GrupoFundador.gestion
                  ? 'Gestión (productor)'
                  : 'Inmobiliaria / broker',
              alElegir: (g) => setState(() => grupo = g),
            ),
            const SizedBox(height: 12),
            BotonGrande(
              texto: 'Dar de alta como Fundador',
              ocupado: guardando,
              onPressed: _alta,
            ),
            const SizedBox(height: 20),
            const TituloSeccion('Fundadores', icono: Icons.workspace_premium),
            if (snap.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator()),
            if (snap.hasData && lista.isEmpty)
              const Text('Todavía no hay Fundadores.',
                  style: TextStyle(color: EstiloProduccion.textoSuave)),
            for (final p in lista)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text('Código …${p.usuarioId.length > 6 ? p.usuarioId.substring(p.usuarioId.length - 6) : p.usuarioId}'),
                subtitle: Text(
                  '${p.grupoFundador == GrupoFundador.gestion ? 'Gestión' : 'Inmobiliaria'}'
                  '${p.fechaFin == null ? '' : ' · gratis hasta el ${fechaCorta(p.fechaFin!)}'}',
                ),
              ),
          ],
        );
      },
    );
  }
}

// =====================================================================
// PEDIDOS DE BAJA
// =====================================================================

class _Bajas extends StatefulWidget {
  final String adminId;
  const _Bajas({required this.adminId});

  @override
  State<_Bajas> createState() => _BajasState();
}

class _BajasState extends State<_Bajas> {
  final AdminService _admin = AdminService();
  Future<List<SolicitudBaja>>? _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _admin.pedidosBajaPendientes();
  }

  Future<void> _completar(SolicitudBaja p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Marcar como completada'),
        content: const Text(
            '¿Ya borraste los datos personales de esta cuenta siguiendo los '
            'pasos? Esto solo marca el pedido como terminado.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Todavía no')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sí, completada')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _admin.completarBaja(p.usuarioId, widget.adminId);
      if (!mounted) return;
      setState(() {
        _futuro = _admin.pedidosBajaPendientes();
      });
    } catch (e) {
      if (!mounted) return;
      _avisar(context, 'No se pudo marcar: $e');
    }
  }

  /// QA 20/11/2026: anular un pedido (prueba o arrepentimiento), con motivo.
  Future<void> _anular(SolicitudBaja p) async {
    final control = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Anular el pedido de baja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'La cuenta sigue activa. El pedido no se borra: queda anulado '
              'con el motivo, y la persona puede volver a pedir la baja.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: control,
              decoration: decoracionCampo(
                  ayuda: 'Motivo (ej.: era una prueba, se arrepintió)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () {
                final m = control.text.trim();
                if (m.isNotEmpty) Navigator.of(ctx).pop(m);
              },
              child: const Text('Anular')),
        ],
      ),
    );
    control.dispose();
    if (motivo == null) return;
    try {
      await _admin.anularBaja(p.usuarioId, widget.adminId, motivo);
      if (!mounted) return;
      _avisar(context, 'Pedido anulado.');
      setState(() {
        _futuro = _admin.pedidosBajaPendientes();
      });
    } catch (e) {
      if (!mounted) return;
      _avisar(context, 'No se pudo anular: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SolicitudBaja>>(
      future: _futuro,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('No se pudo cargar: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final lista = snap.data!;
        final hoy = DateTime.now();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const EstadoVacio(
              icono: Icons.info_outline,
              texto: 'Pasos para completar una baja (a mano, por ahora): '
                  '1) En la consola de Firebase, Authentication: deshabilitar '
                  'o borrar la cuenta. 2) Firestore: borrar su documento en '
                  '"usuarios" y sus campos propios. 3) En los campos de otros, '
                  'sus registros quedan (trazabilidad). 4) Volver acá y '
                  'marcar como completada.',
            ),
            const SizedBox(height: 16),
            if (lista.isEmpty)
              const Text('No hay pedidos de baja pendientes.',
                  style: TextStyle(color: EstiloProduccion.textoSuave)),
            for (final p in lista)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TarjetaBlanca(
                  colorBorde: p.fechaLimite.isBefore(hoy)
                      ? EstiloProduccion.rojo
                      : const Color(0xFFE6D6BC),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.email ?? 'Sin email',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(
                          'Código: ${p.usuarioId}\n'
                          'Pedido el ${fechaCorta(p.fechaPedido)} · '
                          'completar antes del ${fechaCorta(p.fechaLimite)}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: EstiloProduccion.textoSuave),
                        ),
                        if (p.motivo != null) ...[
                          const SizedBox(height: 4),
                          Text('Motivo: ${p.motivo}'),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => _completar(p),
                              child: const Text('Marcar completada'),
                            ),
                            TextButton(
                              onPressed: () => _anular(p),
                              child: const Text('Anular (prueba o arrepentido)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
