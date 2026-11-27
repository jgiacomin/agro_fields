import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/activos/documento_activo_model.dart';
import '../../core/auth/admin.dart';
import '../../widgets/aviso_pendientes.dart';
import '../admin/admin_screen.dart';
import '../legal/borrar_cuenta_screen.dart';
import '../legal/terminos_screen.dart';
import '../plan/mi_plan_screen.dart';
import '../../widgets/logo_agro_fields.dart';
import '../produccion/produccion_estilo.dart';
import '../campos/mis_campos_screen.dart';
import '../campos/ubicacion_activo_screen.dart';
import '../documentos/documentos_activo_screen.dart';
import '../emergencias/emergencias_activo_screen.dart';
import '../produccion/produccion_activo_screen.dart';

import '../campos/crear_activo_agro_screen.dart';
import '../campos/mis_activos_screen.dart';
import '../campos/campos_screen.dart';

import '../solicitudes/solicitudes_recibidas_screen.dart';
import '../chat/chat_page.dart';
import '../encargados/campos_encargado_screen.dart';
import '../profesionales/campos_profesional_screen.dart';
import '../profesionales/mi_codigo_profesional_screen.dart';
import '../../widgets/aviso_publicaciones_admin.dart';
import '../../services/avisos_service.dart';
import '../avisos/avisos_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  UserModel? usuario;

  bool loading = true;

  bool esPropietario = false;

  int cantidadActivosPropios = 0;

  /// Los campos propios (para las tarjetas del Inicio).
  List<ActivoAgroV2> activos = [];

  /// AF-145: cuántos avisos hay para la campanita.
  int _cantidadAvisos = 0;

  Future<void> _contarAvisos() async {
    try {
      final lista = await AvisosService().avisos(activos);
      if (!mounted) return;
      setState(() => _cantidadAvisos = lista.length);
    } catch (_) {}
  }

  Future<void> _abrirAvisos() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AvisosScreen(campos: activos)));
    // Al volver, se vuelve a contar.
    _contarAvisos();
  }

  final UserService _userService =
      UserService();

  final ActivoAgroServiceV2 _activoService =
      ActivoAgroServiceV2();

  @override
  void initState() {
    super.initState();

    cargarUsuario();
  }

  // =====================================================
  // CARGAR USUARIO Y RELACIÓN CON ACTIVOS
  // =====================================================

  Future<void> cargarUsuario() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          loading = false;
          usuario = null;
          esPropietario = false;
          cantidadActivosPropios = 0;
        });

        return;
      }

      // =================================================
      // IDENTIDAD DEL USUARIO
      // =================================================
final data =
    await _userService.getUsuario(
  user.uid,
);

debugPrint('DASHBOARD: getUsuario OK');

// GAP-BROKER-01: también los campos que cargó para un cliente.
final activosPropios =
    await _activoService.buscarMisCampos(
  user.uid,
);

debugPrint(
  'DASHBOARD: buscarPorPropietario OK - ${activosPropios.length} activos',
);

      // =================================================
      // RELACIÓN CONTEXTUAL CON ACTIVOS AGRO
      //
      // NO usamos usuario.rol para determinar
      // si es propietario.
      // =================================================

    

      if (!mounted) return;

      setState(() {
        usuario = data;

        cantidadActivosPropios =
            activosPropios.length;

        activos = activosPropios;

        esPropietario =
            activosPropios.isNotEmpty;

        loading = false;
      });
      // AF-145: la campanita cuenta los avisos con los campos ya cargados.
      _contarAvisos();
    } catch (e) {
      debugPrint(
        'ERROR CARGANDO DASHBOARD: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
        esPropietario = false;
        cantidadActivosPropios = 0;
      });
    }
  }

  // =====================================================
  // CERRAR SESIÓN
  // =====================================================

  Future<void> cerrarSesion() async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cerrar sesión',
          ),
          content: const Text(
            '¿Querés cerrar la sesión actual?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(true),
              child: const Text(
                'Cerrar sesión',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await FirebaseAuth.instance.signOut();

    final usuarioActual =
        FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          usuarioActual == null
              ? 'SESIÓN CERRADA'
              : 'SIGUE LOGUEADO: ${usuarioActual.email}',
        ),
      ),
    );
  }

  // =====================================================
  // CREAR ACTIVO
  // =====================================================

  Future<void> abrirCrearActivo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CrearActivoAgroScreen(),
      ),
    );

    // Al volver, volvemos a consultar los activos.
    await cargarUsuario();
  }

  // =====================================================
  // MIS ACTIVOS
  // =====================================================

  Future<void> abrirMisActivos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const MisActivosScreen(),
      ),
    );

    // Al volver, actualizamos el estado.
    await cargarUsuario();
  }

  // =====================================================
  // CAMPOS DISPONIBLES
  // =====================================================

  Future<void> abrirCamposDisponibles() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CamposScreen(),
      ),
    );
  }

  // =====================================================
  // CHAT
  // =====================================================

  Future<void> abrirConversaciones() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatPage(),
      ),
    );
  }

  // =====================================================
  // SOLICITUDES
  // =====================================================

  Future<void> abrirSolicitudes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SolicitudesRecibidasScreen(),
      ),
    );
  }

  // =====================================================
  // BUILD — INICIO V8 (referencia visual del 10/11/2026, rediseño con
  // la demo aprobada el 12/11/2026: encabezado oscuro, saludo de
  // atardecer, resumen, accesos en dos columnas y botón central)
  //
  // Solo cambia lo visual: la carga del usuario y las
  // pantallas que se abren son las mismas de antes.
  // No se muestra nada sin datos reales (clima, mapa y
  // alertas quedan como "Próximamente").
  // =====================================================

  String get _primerNombre {
    final nombre = usuario?.nombre.trim() ?? '';
    if (nombre.isEmpty) return '';
    final primero = nombre.split(RegExp(r'\s+')).first;
    return primero[0].toUpperCase() + primero.substring(1);
  }

  void _abrirMenu() {
    showModalBottomSheet<void>(
      context: context,
      // El menú tiene muchas opciones: se puede deslizar y ocupar más alto.
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (hoja) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esPropietario)
                ListTile(
                  leading: const Icon(Icons.inbox_outlined),
                  title: const Text('Solicitudes recibidas'),
                  onTap: () {
                    Navigator.of(hoja).pop();
                    abrirSolicitudes();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Ver campos disponibles'),
                onTap: () {
                  Navigator.of(hoja).pop();
                  abrirCamposDisponibles();
                },
              ),
              // GAP-ENC-01: para quien trabaja el campo de otro.
              ListTile(
                leading: const Icon(Icons.engineering_outlined),
                title: const Text('Campos donde soy encargado'),
                onTap: () {
                  Navigator.of(hoja).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const CamposEncargadoScreen()));
                },
              ),
              // AF-093: para agrónomos, veterinarios y técnicos.
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Campos donde soy profesional'),
                onTap: () {
                  Navigator.of(hoja).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const CamposProfesionalScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_2),
                title: const Text('Mi código (para que me inviten)'),
                onTap: () {
                  Navigator.of(hoja).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MiCodigoProfesionalScreen()));
                },
              ),
              // GAP-ADMIN-01: solo para el administrador.
              if (esAdminPorUid(FirebaseAuth.instance.currentUser?.uid))
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Administración'),
                  onTap: () {
                    Navigator.of(hoja).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AdminScreen()));
                  },
                ),
              const Divider(),
              // GAP-PLAN-01: el plan de cada usuario (Esencial, Pro, Fundador).
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: const Text('Mi plan'),
                onTap: () {
                  Navigator.of(hoja).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MiPlanScreen()));
                },
              ),
              // GAP-LEGAL-01: términos siempre a mano y pedido de baja.
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: const Text('Términos y privacidad'),
                onTap: () {
                  Navigator.of(hoja).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const TerminosScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: const Text('Borrar mi cuenta'),
                onTap: () {
                  Navigator.of(hoja).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const BorrarCuentaScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AgroTema.rojo),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: AgroTema.rojo),
                ),
                onTap: () {
                  Navigator.of(hoja).pop();
                  cerrarSesion();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : usuario == null
                ? const Center(
                    child: Text('No se pudo cargar el usuario'),
                  )
                : RefreshIndicator(
                    onRefresh: cargarUsuario,
                    child: ListView(
                      // En pantallas grandes el contenido queda centrado
                      // con un ancho máximo (como en el celular).
                      padding: EdgeInsets.fromLTRB(_margen(context), 12,
                          _margen(context), 24),
                      children: [
                        // Diseño V8 (16/11/2026): foto del campo con el
                        // logo y el saludo, como la barra de las demás
                        // pantallas.
                        _encabezado(),
                        const SizedBox(height: 14),
                        // GAP-OFF-01: datos guardados sin señal.
                        const AvisoPendientes(),
                        // GAP-MERC-01 G: publicaciones para aprobar (admin).
                        const AvisoPublicacionesAdmin(),
                        // INICIO-BOTONES (27/11/2026): el Inicio con botones
                        // grandes (estilo miArgentina). La lista de campos
                        // pasó al botón "Mis campos" (lista corta).
                        if (esPropietario) ...[
                          _resumen(),
                          const SizedBox(height: 18),
                        ],
                        // Sin campos: el Mercado y la invitación a cargar.
                        if (activos.isEmpty) ...[
                          _sinCampos(),
                          const SizedBox(height: 18),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            _trabajaElCampo
                                ? '¿Qué hacemos hoy en el campo?'
                                : '¿Qué querés hacer hoy?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AgroTema.pizarra,
                            ),
                          ),
                        ),
                        _botones(),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar:
          loading || usuario == null ? null : _menuInferior(),
    );
  }

  /// Margen a los costados: 16 en el celular; en la compu, lo que haga
  /// falta para que el contenido no pase de 760 de ancho.
  double _margen(BuildContext context) {
    // La app ya tiene un ancho máximo de 860 (main.dart): se calcula
    // sobre ese ancho, no sobre el de toda la pantalla.
    final ancho = MediaQuery.sizeOf(context).width.clamp(0, 860).toDouble();
    return ancho > 792 ? (ancho - 760) / 2 : 16;
  }

  // ---------------- ENCABEZADO (diseño V8, 16/11/2026) ----------------

  /// Foto del campo al atardecer (la misma de BarraCampo), con velo oscuro,
  /// logo en círculo dorado, saludo y curva dorada abajo.
  Widget _encabezado() {
    final nombre = _primerNombre.isEmpty ? 'productor' : _primerNombre;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/encabezado_campo.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0.6, 0.3),
              // Si la imagen no carga, queda el fondo oscuro.
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: AgroTema.pizarra),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xE62F3B46),
                    Color(0xAA2F3B46),
                    Color(0x222F3B46),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AgroTema.pizarra,
                        border: Border.all(color: AgroTema.dorado, width: 2),
                      ),
                      child: const ClipOval(child: LogoAgroFields(tamano: 48)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agro Fields',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Color(0x88000000), blurRadius: 6)
                              ],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Conectar · Crecer · Resolver',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 13, color: AgroTema.crema),
                          ),
                        ],
                      ),
                    ),
                    // AF-145 (26/11/2026): campanita de avisos con número.
                    IconButton(
                      icon: Badge(
                        isLabelVisible: _cantidadAvisos > 0,
                        label: Text('$_cantidadAvisos'),
                        child: Icon(
                            _cantidadAvisos > 0
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            color: Colors.white),
                      ),
                      tooltip: 'Avisos',
                      onPressed: _abrirAvisos,
                    ),
                    // INICIO-BOTONES: la personita abre "Mi perfil".
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _abrirPerfil,
                        child: Tooltip(
                          message: 'Mi perfil',
                          child: _avatar(40),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '$_saludoSegunHora, $nombre',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [Shadow(color: Color(0x88000000), blurRadius: 6)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  esPropietario
                      ? 'Que tengas una excelente jornada.'
                      : 'Cargá tu primer campo para empezar.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFFF3E6),
                    shadows: [Shadow(color: Color(0x88000000), blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
          // Curva dorada abajo, igual que la barra de las demás pantallas.
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 18,
            child: CustomPaint(painter: _CurvaDoradaInicio()),
          ),
        ],
      ),
    );
  }

  String get _saludoSegunHora {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  // ---------------- BOTONES (INICIO-BOTONES, 27/11/2026) ----------------

  /// Trabaja el campo (tiene campos propios) o es broker/inmobiliaria/
  /// sin campos: cambia la frase de arriba de los botones.
  bool get _trabajaElCampo => activos.any((a) => !a.sinDueno);

  bool get _esAdmin => esAdminPorUid(FirebaseAuth.instance.currentUser?.uid);

  Widget _botones() {
    final botones = <_Boton>[
      _Boton(Icons.agriculture, 'Mis campos', AgroTema.verde, _abrirMisCampos),
      _Boton(Icons.storefront, 'Mercado', AgroTema.azul, abrirCamposDisponibles),
      _Boton(Icons.chat_bubble_outline, 'Mensajes', AgroTema.azul,
          abrirConversaciones),
      _Boton(Icons.description_outlined, 'Documentos', AgroTema.pizarra,
          () => _conCampo('Documentos', soloPropios: false, abrir: (a) {
                return DocumentosActivoScreen(
                    activoAgroId: a.activoId, nombreActivo: a.nombre);
              })),
      _Boton(Icons.warning_amber_rounded, 'Emergencias', AgroTema.rojo,
          () => _conCampo('Emergencias', abrir: (a) {
                return EmergenciasActivoScreen(
                    activoAgroId: a.activoId, nombreActivo: a.nombre);
              })),
      _Boton(Icons.location_on_outlined, 'Mapa', AgroTema.verde,
          () => _conCampo('Mapa', soloPropios: false, abrir: (a) {
                return UbicacionActivoScreen(activo: a);
              })),
      _Boton(Icons.bar_chart, 'Producción', AgroTema.pizarra,
          () => _conCampo('Producción', abrir: (a) {
                return ProduccionActivoScreen(
                    activoAgroId: a.activoId, nombreActivo: a.nombre);
              })),
      if (_esAdmin)
        _Boton(Icons.admin_panel_settings_outlined, 'Administración',
            AgroTema.pizarra, () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminScreen()));
        })
      else if (esPropietario)
        _Boton(Icons.inbox_outlined, 'Solicitudes', AgroTema.azul,
            abrirSolicitudes)
      else
        _Boton(Icons.workspace_premium_outlined, 'Mi plan', AgroTema.pizarra,
            () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MiPlanScreen()));
        }),
      _Boton(Icons.add, 'Cargar campo', AgroTema.terracota, abrirCrearActivo,
          destacado: true),
    ];

    // Tres columnas, en el celular y en la compu (como la demo aprobada).
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: MediaQuery.sizeOf(context).width > 600 ? 2.2 : 1.0,
      children: [for (final b in botones) _cuadroBoton(b)],
    );
  }

  Widget _cuadroBoton(_Boton b) {
    final fondo = b.destacado ? AgroTema.terracota : Colors.white;
    final colorTexto = b.destacado ? Colors.white : AgroTema.pizarra;
    return Material(
      color: fondo,
      elevation: 1.5,
      shadowColor: const Color(0x332F3B46),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: b.destacado ? AgroTema.terracotaOscuro : AgroTema.borde),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: b.alTocar,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(b.icono,
                  size: 34, color: b.destacado ? Colors.white : b.color),
              const SizedBox(height: 8),
              Text(
                b.texto,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorTexto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirMisCampos() async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MisCamposScreen()));
    await cargarUsuario();
  }

  /// Documentos, Emergencias, Mapa y Producción son de un campo: con un
  /// solo campo se abre directo; con varios, primero se elige cuál.
  /// [soloPropios]: la gestión (Producción, Emergencias) no es para los
  /// campos que un broker cargó para un cliente.
  Future<void> _conCampo(
    String titulo, {
    bool soloPropios = true,
    required Widget Function(ActivoAgroV2 activo) abrir,
  }) async {
    final lista = activos.where((a) => !soloPropios || !a.sinDueno).toList()
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    if (lista.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Primero cargá un campo con "Cargar campo".')));
      return;
    }
    ActivoAgroV2? elegido = lista.length == 1 ? lista.first : null;
    elegido ??= await showModalBottomSheet<ActivoAgroV2>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (hoja) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(hoja).height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Text(
                  '$titulo: ¿de qué campo?',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final a in lista)
                      ListTile(
                        leading: const Icon(Icons.grass, color: AgroTema.verde),
                        title: Text(a.nombre),
                        subtitle: Text([
                          a.ubicacion.localidad,
                          a.ubicacion.provincia
                        ].where((x) => x.trim().isNotEmpty).join(', ')),
                        onTap: () => Navigator.of(hoja).pop(a),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (elegido == null || !mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => abrir(elegido!)));
    await cargarUsuario();
  }

  // ---------------- MI PERFIL (la personita) ----------------

  Widget _avatar(double tamano) {
    final foto = usuario?.foto.trim() ?? '';
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE9E2D4),
        border: Border.all(color: AgroTema.dorado, width: 2),
      ),
      child: ClipOval(
        child: foto.isEmpty
            ? Icon(Icons.person, color: AgroTema.pizarra, size: tamano * 0.6)
            : Image.network(
                foto,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.person,
                    color: AgroTema.pizarra, size: tamano * 0.6),
              ),
      ),
    );
  }

  void _abrirPerfil() {
    final email = usuario?.email ?? '';
    final nombre = usuario?.nombre.trim() ?? '';
    final rol = _esAdmin
        ? 'Administrador'
        : (usuario?.rol.trim().isNotEmpty ?? false)
            ? usuario!.rol
            : '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (hoja) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _avatar(72),
              const SizedBox(height: 10),
              Text(
                nombre.isEmpty ? 'Mi perfil' : nombre,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              if (email.isNotEmpty)
                Text(email,
                    style: const TextStyle(color: AgroTema.pizarraSuave)),
              if (rol.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(rol,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AgroTema.verde)),
                ),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: const Text('Mi plan'),
                onTap: () {
                  Navigator.of(hoja).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MiPlanScreen()));
                },
              ),
              // AF nuevo "Entrar con huella": 🟡 diciembre, en Android.
              const ListTile(
                enabled: false,
                leading: Icon(Icons.fingerprint),
                title: Text('Entrar con huella'),
                subtitle: Text('Próximamente, en el celular'),
              ),
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: const Text('Términos y privacidad'),
                onTap: () {
                  Navigator.of(hoja).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const TerminosScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AgroTema.rojo),
                title: const Text('Cerrar sesión',
                    style: TextStyle(color: AgroTema.rojo)),
                onTap: () {
                  Navigator.of(hoja).pop();
                  cerrarSesion();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- MENÚ INFERIOR (botón central) ----------------

  Widget _menuInferior() {
    Widget item(IconData icono, String texto, VoidCallback? alTocar,
        {bool activo = false}) {
      final color = activo ? AgroTema.terracota : Colors.white;
      return Expanded(
        child: InkWell(
          onTap: alTocar,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, color: color),
                const SizedBox(height: 2),
                Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: color),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: AgroTema.pizarra,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              item(Icons.home, 'Inicio', null, activo: true),
              // GAP-EDITAR-01: el mismo menú para todos.
              item(Icons.storefront, 'Mercado', abrirCamposDisponibles),
              Expanded(
                child: Center(
                  child: Tooltip(
                    message: 'Crear campo',
                    child: Material(
                      color: AgroTema.terracota,
                      shape: const CircleBorder(
                        side: BorderSide(color: Color(0xFFF2C08F), width: 2),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: abrirCrearActivo,
                        child: const SizedBox(
                          width: 54,
                          height: 54,
                          child: Icon(Icons.add, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              item(Icons.chat_bubble_outline, 'Mensajes', abrirConversaciones),
              item(Icons.menu, 'Menú', _abrirMenu),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- RESUMEN (solo datos reales) ----------------

  Widget _resumen() {
    var vencidos = 0;
    var porVencer = 0;
    for (final a in activos) {
      for (final d in a.documentacion.documentosEstructurados) {
        // QA Grupo C: los archivados no avisan.
        if (d.archivado) continue;
        final e = d.estadoVigencia();
        if (e == EstadoVigenciaDocumento.vencido) vencidos++;
        if (e == EstadoVigenciaDocumento.porVencer) porVencer++;
      }
    }
    final hectareas = activos.fold<double>(
        0, (suma, a) => suma + (a.ubicacion.superficie > 0 ? a.ubicacion.superficie : 0));
    final enMapa = activos.where((a) => a.ubicacion.tieneCoordenadas).length;

    // INICIO-BOTONES: los 4 números en una sola fila chica.
    final colorDocs = vencidos > 0
        ? AgroTema.rojo
        : porVencer > 0
            ? AgroTema.terracota
            : AgroTema.pizarraSuave;
    return Row(
      children: [
        _numero('$cantidadActivosPropios',
            cantidadActivosPropios == 1 ? 'campo' : 'campos',
            AgroTema.verde, AgroTema.verdeClaro),
        const SizedBox(width: 8),
        _numero(hectareas > 0 ? _miles(hectareas) : '—', 'hectáreas',
            AgroTema.azul, const Color(0xFFE6ECF3)),
        const SizedBox(width: 8),
        _numero('${vencidos + porVencer}',
            vencidos > 0 ? 'docs. vencidos' : 'docs. por vencer',
            colorDocs, AgroTema.rojoFondo),
        const SizedBox(width: 8),
        _numero('$enMapa/$cantidadActivosPropios', 'en el mapa',
            AgroTema.terracotaOscuro, AgroTema.terracotaClaro),
      ],
    );
  }

  Widget _numero(String valor, String texto, Color color, Color fondo) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            FittedBox(
              child: Text(
                valor,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: color),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              texto,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 11, color: AgroTema.pizarra),
            ),
          ],
        ),
      ),
    );
  }

  String _miles(double valor) {
    final entero = valor.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < entero.length; i++) {
      if (i > 0 && (entero.length - i) % 3 == 0) buffer.write('.');
      buffer.write(entero[i]);
    }
    return buffer.toString();
  }

  /// GAP-EDITAR-01: quien no tiene campos ve el Mercado y la invitación.
  Widget _sinCampos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TituloSeccion('Mercado de campos', icono: Icons.storefront),
        TarjetaBlanca(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Buscá campos para comprar, alquilar o invertir.',
                  style: TextStyle(fontSize: 15, color: AgroTema.pizarra),
                ),
                const SizedBox(height: 12),
                BotonGrande(
                  texto: 'Ver el Mercado',
                  icono: Icons.storefront,
                  onPressed: abrirCamposDisponibles,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: abrirCrearActivo,
                  icon: const Icon(Icons.add),
                  label: const Text('¿Tenés un campo? Cargalo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AgroTema.terracota,
                    side: const BorderSide(color: AgroTema.terracota),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

/// Un botón grande del Inicio (INICIO-BOTONES, 27/11/2026).
class _Boton {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback alTocar;
  final bool destacado;

  const _Boton(this.icono, this.texto, this.color, this.alTocar,
      {this.destacado = false});
}

/// Curva dorada abajo del encabezado del Inicio (la misma que dibuja
/// BarraCampo en las demás pantallas).
class _CurvaDoradaInicio extends CustomPainter {
  const _CurvaDoradaInicio();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final relleno = Path()
      ..moveTo(0, h * 0.35)
      ..quadraticBezierTo(w * 0.35, h * 1.15, w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(relleno, Paint()..color = AgroTema.crema);
    final linea = Path()
      ..moveTo(0, h * 0.35)
      ..quadraticBezierTo(w * 0.35, h * 1.15, w, h * 0.55);
    canvas.drawPath(
      linea,
      Paint()
        ..color = AgroTema.dorado
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
