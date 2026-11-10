import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/activos/documento_activo_model.dart';
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
  // BUILD — INICIO V8 (referencia visual del 10/11/2026,
  // docs/diseno/referencia_visual_v8.png)
  //
  // Solo cambia lo visual: la carga del usuario y las
  // pantallas que se abren son las mismas de antes.
  // No se muestra nada sin datos reales (clima, mapa y
  // alertas quedan como "Pronto").
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        _encabezado(),
                        const SizedBox(height: 20),
                        _tarjetaPrincipal(),
                        if (esPropietario) ...[
                          const SizedBox(height: 16),
                          _resumen(),
                        ],
                        const SizedBox(height: 28),
                        const Text(
                          'Accesos rápidos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AgroTema.pizarra,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _accesosRapidos(),
                        if (activos.isNotEmpty) ...[
                          const SizedBox(height: 28),
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
      bottomNavigationBar: loading || usuario == null
          ? null
          : NavigationBar(
              selectedIndex: 0,
              backgroundColor: Colors.white,
              indicatorColor: AgroTema.terracota.withValues(alpha: 0.15),
              onDestinationSelected: (indice) {
                switch (indice) {
                  case 1:
                    abrirMisActivos();
                    break;
                  case 2:
                    abrirConversaciones();
                    break;
                  case 3:
                    _abrirMenu();
                    break;
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AgroTema.terracota),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.agriculture_outlined),
                  label: 'Mis campos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'Mensajes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu),
                  label: 'Menú',
                ),
              ],
            ),
    );
  }

  Widget _encabezado() {
    final inicial = _primerNombre.isEmpty ? '?' : _primerNombre[0];
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AgroTema.terracota,
          child: Text(
            inicial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $_primerNombre',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AgroTema.pizarra,
                ),
              ),
              Text(
                esPropietario
                    ? 'Propietario de $cantidadActivosPropios '
                        '${cantidadActivosPropios == 1 ? 'campo' : 'campos'}'
                    : 'Participante de Agro Fields',
                style: const TextStyle(
                  fontSize: 14,
                  color: AgroTema.pizarraSuave,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AgroTema.pizarraSuave),
          tooltip: 'Cerrar sesión',
          onPressed: cerrarSesion,
        ),
      ],
    );
  }

  Widget _tarjetaPrincipal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AgroTema.pizarra,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu campo, tu historia,\nen un solo lugar.',
                  style: TextStyle(
                    fontSize: 21,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AgroTema.terracota,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Conectar con confianza. Crecer con datos.',
                  style: TextStyle(fontSize: 14, color: AgroTema.crema),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 86,
            height: 70,
            child: CustomPaint(painter: _SolYSurcos()),
          ),
        ],
      ),
    );
  }

  Widget _accesosRapidos() {
    final accesos = <_Acceso>[
      if (esPropietario)
        _Acceso(Icons.agriculture, 'Mis campos', AgroTema.verde,
            abrirMisActivos),
      _Acceso(Icons.add_business, 'Crear campo', AgroTema.terracota,
          abrirCrearActivo),
      _Acceso(Icons.storefront, 'Mercado de campos', const Color(0xFFE8893A),
          abrirCamposDisponibles),
      if (esPropietario)
        _Acceso(Icons.inbox, 'Solicitudes', AgroTema.azul, abrirSolicitudes),
      _Acceso(Icons.chat_bubble, 'Conversaciones', AgroTema.pizarra,
          abrirConversaciones),
      const _Acceso(Icons.map, 'Mapa territorial', AgroTema.azul, null),
      const _Acceso(Icons.warning_amber, 'Alertas', AgroTema.rojo, null),
    ];

    // Alto fijo y ancho que se acomoda: el texto nunca se sale del cuadro,
    // sea la pantalla de un celular o de una compu.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accesos.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        mainAxisExtent: 124,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => _cuadroAcceso(accesos[i]),
    );
  }

  // ---------------- RESUMEN (datos reales) ----------------

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

    return Row(
      children: [
        Expanded(
          child: _dato(
            Icons.agriculture,
            AgroTema.verde,
            '$cantidadActivosPropios',
            cantidadActivosPropios == 1 ? 'campo' : 'campos',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dato(
            Icons.straighten,
            AgroTema.azul,
            hectareas > 0 ? _miles(hectareas) : '—',
            'hectáreas',
          ),
        ),
        const SizedBox(width: 10),
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
      ],
    );
  }

  Widget _dato(IconData icono, Color color, String valor, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AgroTema.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 22),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AgroTema.pizarra,
              ),
            ),
          ),
          Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AgroTema.pizarraSuave),
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
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AgroTema.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: pronto ? null : acceso.alTocar,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    pronto ? AgroTema.borde : acceso.color,
                child: Icon(
                  acceso.icono,
                  color: pronto ? AgroTema.pizarraSuave : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                acceso.texto,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: pronto ? AgroTema.pizarraSuave : AgroTema.pizarra,
                ),
              ),
              if (pronto)
                const Text(
                  'Pronto',
                  style: TextStyle(fontSize: 11, color: AgroTema.pizarraSuave),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un cuadro de "Accesos rapidos". Sin accion = todavia no existe ("Pronto").
class _Acceso {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback? alTocar;

  const _Acceso(this.icono, this.texto, this.color, this.alTocar);
}

/// Dibujo del logo en la tarjeta principal: el sol del atardecer y los
/// surcos del campo (sin fotos: no se inventa una imagen).
class _SolYSurcos extends CustomPainter {
  const _SolYSurcos();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sol (medio circulo).
    final sol = Paint()..color = const Color(0xFFE8893A);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.55), radius: h * 0.38),
      3.1416,
      3.1416,
      true,
      sol,
    );

    // Surcos (tres curvas).
    final colores = [AgroTema.terracota, AgroTema.crema, AgroTema.terracota];
    for (var i = 0; i < 3; i++) {
      final y = h * (0.62 + i * 0.14);
      final camino = Path()
        ..moveTo(0, y + 6)
        ..quadraticBezierTo(w * 0.5, y - 10, w, y + 2);
      canvas.drawPath(
        camino,
        Paint()
          ..color = colores[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
