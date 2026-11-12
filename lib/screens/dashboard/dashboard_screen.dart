import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/activos/documento_activo_model.dart';
import '../../widgets/logo_agro_fields.dart';
import '../campos/detalle_activo_agro_screen.dart';

import '../campos/crear_activo_agro_screen.dart';
import '../campos/mis_activos_screen.dart';
import '../campos/campos_screen.dart';

import '../solicitudes/solicitudes_recibidas_screen.dart';
import '../chat/chat_page.dart';

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

final activosPropios =
    await _activoService.buscarPorPropietario(
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (hoja) => SafeArea(
        child: Padding(
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
              const Divider(),
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
      backgroundColor: AgroTema.crema,
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
                        _encabezado(),
                        const SizedBox(height: 14),
                        _saludo(),
                        if (esPropietario) ...[
                          const SizedBox(height: 14),
                          _resumen(),
                        ],
                        const SizedBox(height: 14),
                        _accesosRapidos(),
                        if (activos.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _tituloConAccion(
                            'Mis campos',
                            'Ver todos',
                            abrirMisActivos,
                          ),
                          const SizedBox(height: 12),
                          _carruselCampos(),
                        ],
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
    final ancho = MediaQuery.sizeOf(context).width;
    return ancho > 792 ? (ancho - 760) / 2 : 16;
  }

  // ---------------- ENCABEZADO (diseño del 12/11/2026) ----------------

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
      decoration: BoxDecoration(
        color: AgroTema.pizarra,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const LogoAgroFields(tamano: 52),
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
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Conectar · Crecer · Resolver',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AgroTema.crema),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            tooltip: 'Avisos (pronto)',
            onPressed: null,
            disabledColor: Colors.white,
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

  /// Cartel de atardecer (dibujado, sin fotos de terceros).
  Widget _saludo() {
    final nombre = _primerNombre.isEmpty ? 'productor' : _primerNombre;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF2A65A), Color(0xFFD96A2B), Color(0xFF6B4A2E)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.grass, color: Color(0xFFFBE3C8), size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_saludoSegunHora, $nombre',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  esPropietario
                      ? 'Que tengas una excelente jornada.'
                      : 'Cargá tu primer campo para empezar.',
                  style: const TextStyle(fontSize: 14, color: Color(0xFFFFF3E6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ACCESOS (dos columnas) ----------------

  Widget _accesosRapidos() {
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
        mainAxisExtent: 76,
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
        final e = d.estadoVigencia();
        if (e == EstadoVigenciaDocumento.vencido) vencidos++;
        if (e == EstadoVigenciaDocumento.porVencer) porVencer++;
      }
    }
    final hectareas = activos.fold<double>(
        0, (suma, a) => suma + (a.ubicacion.superficie > 0 ? a.ubicacion.superficie : 0));
    final enMapa = activos.where((a) => a.ubicacion.tieneCoordenadas).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AgroTema.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu campo en resumen',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AgroTema.pizarra,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _dato(
                  Icons.agriculture,
                  AgroTema.verde,
                  '$cantidadActivosPropios',
                  cantidadActivosPropios == 1 ? 'campo' : 'campos',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dato(
                  Icons.straighten,
                  AgroTema.azul,
                  hectareas > 0 ? _miles(hectareas) : '—',
                  'hectáreas',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dato(
                  Icons.description,
                  vencidos > 0
                      ? AgroTema.rojo
                      : porVencer > 0
                          ? AgroTema.terracota
                          : AgroTema.pizarraSuave,
                  '${vencidos + porVencer}',
                  vencidos > 0 ? 'docs. vencidos' : 'docs. por vencer',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dato(
                  Icons.location_on,
                  AgroTema.terracota,
                  '$enMapa/$cantidadActivosPropios',
                  'en el mapa',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato(IconData icono, Color color, String valor, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AgroTema.crema,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AgroTema.pizarra,
              ),
            ),
          ),
          Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AgroTema.pizarraSuave),
          ),
        ],
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

  // ---------------- MIS CAMPOS (tarjetas que se deslizan) ----------------

  Widget _tituloConAccion(String titulo, String accion, VoidCallback alTocar) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AgroTema.pizarra,
            ),
          ),
        ),
        TextButton(onPressed: alTocar, child: Text('$accion  ›')),
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
    final lista = [...activos]..sort((a, b) => a.nombre.compareTo(b.nombre));
    return SizedBox(
      height: 132,
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
      width: 210,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AgroTema.borde),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _abrirCampo(a),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AgroTema.verdeClaro,
                      child: Icon(Icons.grass, size: 18, color: AgroTema.verde),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AgroTema.pizarra,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  lugar.isEmpty ? 'Ubicación sin información' : lugar,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AgroTema.pizarraSuave),
                ),
                const SizedBox(height: 4),
                Text(
                  superficie,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontStyle: u.superficie > 0 ? FontStyle.normal : FontStyle.italic,
                    color: u.superficie > 0 ? AgroTema.verde : AgroTema.pizarraSuave,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cuadroAcceso(_Acceso acceso) {
    final pronto = acceso.alTocar == null;
    return Material(
      color: pronto ? const Color(0xFFF3EEE5) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AgroTema.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: pronto ? null : acceso.alTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                acceso.icono,
                size: 32,
                color: pronto ? AgroTema.pizarraSuave : acceso.color,
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
