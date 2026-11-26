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
import '../campos/detalle_activo_agro_screen.dart';

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
                        if (esPropietario) ...[
                          const TituloSeccion('Tu campo en resumen',
                              icono: Icons.insights),
                          _resumen(),
                          const SizedBox(height: 20),
                        ],
                        if (activos.isNotEmpty) ...[
                          _tituloConAccion(
                            'Mis campos',
                            'Ver todos',
                            abrirMisActivos,
                          ),
                          _carruselCampos(),
                          const SizedBox(height: 20),
                        ],
                        const TituloSeccion('Accesos', icono: Icons.apps),
                        _accesosRapidos(),
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

  // ---------------- ACCESOS (dos columnas) ----------------

  Widget _accesosRapidos() {
    // Los que todavía no existen ("Próximamente") van al final.
    final accesos = <_Acceso>[
      if (esPropietario)
        _Acceso(Icons.eco, 'Mis Activos Agro', AgroTema.verde, abrirMisActivos),
      _Acceso(Icons.add_business, 'Crear campo', AgroTema.terracota,
          abrirCrearActivo),
      _Acceso(Icons.storefront, 'Mercado de campos', const Color(0xFFE8893A),
          abrirCamposDisponibles),
      if (esPropietario)
        _Acceso(Icons.inbox, 'Solicitudes', AgroTema.azul, abrirSolicitudes),
      _Acceso(Icons.chat_bubble, 'Conversaciones', AgroTema.pizarra,
          abrirConversaciones),
      const _Acceso(Icons.map, 'Territorio Inteligente', AgroTema.azul, null),
      const _Acceso(
          Icons.bar_chart, 'Economía y Gestión', AgroTema.verde, null),
      const _Acceso(Icons.groups, 'Red Agropecuaria', AgroTema.pizarra, null),
    ];

    // Dos columnas en el celular; más en pantallas grandes.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accesos.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 78,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (_, i) => _cuadroAcceso(accesos[i]),
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
              item(Icons.agriculture, 'Mis campos', abrirMisActivos),
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

    // Diseño V8: los mismos números de colores que el resumen de Producción,
    // en dos filas para que entren bien en el celular.
    final colorDocs = vencidos > 0
        ? AgroTema.rojo
        : porVencer > 0
            ? AgroTema.terracota
            : AgroTema.pizarraSuave;
    return Column(
      children: [
        ResumenNumeros([
          (
            '$cantidadActivosPropios',
            cantidadActivosPropios == 1 ? 'campo' : 'campos',
            Icons.agriculture,
            AgroTema.verde,
          ),
          (
            hectareas > 0 ? _miles(hectareas) : '—',
            'hectáreas',
            Icons.straighten,
            AgroTema.azul,
          ),
        ]),
        const SizedBox(height: 10),
        ResumenNumeros([
          (
            '${vencidos + porVencer}',
            vencidos > 0 ? 'docs. vencidos' : 'docs. por vencer',
            Icons.description,
            colorDocs,
          ),
          (
            '$enMapa/$cantidadActivosPropios',
            'en el mapa',
            Icons.location_on,
            AgroTema.terracota,
          ),
        ]),
      ],
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

  // ---------------- MIS CAMPOS (tarjetas que se deslizan) ----------------

  /// Banda oscura V8 con el botón "Ver todos" a la derecha.
  Widget _tituloConAccion(String titulo, String accion, VoidCallback alTocar) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: TituloSeccion(titulo, icono: Icons.agriculture)),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: TextButton(onPressed: alTocar, child: Text('$accion  ›')),
        ),
      ],
    );
  }

  Future<void> _abrirCampo(ActivoAgroV2 activo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalleActivoAgroScreen(activo: activo),
      ),
    );
    await cargarUsuario();
  }

  Widget _carruselCampos() {
    // QA T1-02 (18/11/2026): el más nuevo primero, para no tocar otro
    // campo por error cuando hay muchos.
    final lista = [...activos]
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: lista.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _tarjetaCampo(lista[i]),
      ),
    );
  }

  Widget _tarjetaCampo(ActivoAgroV2 a) {
    final u = a.ubicacion;
    final lugar = [u.localidad, u.provincia]
        .where((x) => x.trim().isNotEmpty)
        .join(', ');
    final superficie = u.superficie > 0
        ? '${_miles(u.superficie)} ha'
        : 'Superficie sin información';

    return SizedBox(
      width: 220,
      child: Padding(
        // Lugar para la sombra de la tarjeta.
        padding: const EdgeInsets.only(bottom: 4),
        child: TarjetaBlanca(
          onTap: () => _abrirCampo(a),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sin flecha (se toca toda la tarjeta) y el nombre en hasta
                // 2 renglones, para que se lea completo.
                Row(
                  children: [
                    const IconoCirculo(Icons.grass,
                        color: AgroTema.verde, tamano: 38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        a.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: AgroTema.pizarra,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.place,
                        size: 15, color: AgroTema.pizarraSuave),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lugar.isEmpty ? 'Ubicación sin información' : lugar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: AgroTema.pizarraSuave),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.straighten,
                        size: 15,
                        color: u.superficie > 0
                            ? AgroTema.verde
                            : AgroTema.pizarraSuave),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        superficie,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontStyle: u.superficie > 0
                              ? FontStyle.normal
                              : FontStyle.italic,
                          color: u.superficie > 0
                              ? AgroTema.verde
                              : AgroTema.pizarraSuave,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Diseño V8: tarjeta crema con el ícono en círculo. Los "Próximamente"
  /// quedan más apagados y sin flecha.
  Widget _cuadroAcceso(_Acceso acceso) {
    final pronto = acceso.alTocar == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: TarjetaBlanca(
        onTap: pronto ? null : acceso.alTocar,
        colorFondo: pronto ? const Color(0xFFF3EEE5) : const Color(0xFFFFFAF2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              IconoCirculo(
                acceso.icono,
                color: pronto ? AgroTema.pizarraSuave : acceso.color,
                tamano: 44,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      acceso.texto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: pronto ? AgroTema.pizarraSuave : AgroTema.pizarra,
                      ),
                    ),
                    if (pronto)
                      const Text(
                        'Próximamente',
                        style: TextStyle(
                            fontSize: 11, color: AgroTema.pizarraSuave),
                      ),
                  ],
                ),
              ),
              if (!pronto)
                const Icon(Icons.chevron_right, color: AgroTema.pizarraSuave),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un cuadro de "Accesos rapidos". Sin accion = todavia no existe ("Próximamente").
class _Acceso {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback? alTocar;

  const _Acceso(this.icono, this.texto, this.color, this.alTocar);
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
