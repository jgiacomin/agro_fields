import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/activo_agro_service_v2.dart';

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

      // =================================================
      // RELACIÓN CONTEXTUAL CON ACTIVOS AGRO
      //
      // NO usamos usuario.rol para determinar
      // si es propietario.
      // =================================================

      final activosPropios =
          await _activoService.buscarPorPropietario(
        user.uid,
      );

      if (!mounted) return;

      setState(() {
        usuario = data;

        cantidadActivosPropios =
            activosPropios.length;

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
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agro Fields',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            tooltip: 'Cerrar sesión',
            onPressed: cerrarSesion,
          ),
        ],
      ),

      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : usuario == null
                ? const Text(
                    'No se pudo cargar el usuario',
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.agriculture,
                          size: 80,
                          color: Colors.green,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Text(
                          usuario!.nombre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        // =================================================
                        // ESTADO REAL DEL USUARIO EN EL ECOSISTEMA
                        // =================================================

                        Text(
                          esPropietario
                              ? 'Propietario de $cantidadActivosPropios Activo${cantidadActivosPropios == 1 ? '' : 's'} Agro'
                              : 'Participante de Agro Fields',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        _buildContenido(),
                      ],
                    ),
                  ),
      ),
    );
  }

  // =====================================================
  // CONTENIDO DEL DASHBOARD
  // =====================================================

  Widget _buildContenido() {
    return Column(
      children: [
        // =================================================
        // CREAR ACTIVO
        //
        // Cualquier usuario autenticado puede iniciar
        // la creación de un Activo Agro.
        // =================================================

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: abrirCrearActivo,
            icon: const Icon(
              Icons.add_business,
            ),
            label: const Text(
              'Crear Activo Agro',
            ),
          ),
        ),

        // =================================================
        // FUNCIONES DE PROPIETARIO
        // =================================================

        if (esPropietario) ...[
          const SizedBox(
            height: 15,
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: abrirMisActivos,
              icon: const Icon(
                Icons.agriculture,
              ),
              label: const Text(
                'Mis Activos / Publicar campo',
              ),
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: abrirSolicitudes,
              icon: const Icon(
                Icons.inbox,
              ),
              label: const Text(
                'Solicitudes recibidas',
              ),
            ),
          ),
        ],

        // =================================================
        // EXPLORAR CAMPOS
        //
        // No depende del rol global del usuario.
        // =================================================

        const SizedBox(
          height: 15,
        ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: abrirCamposDisponibles,
            icon: const Icon(
              Icons.search,
            ),
            label: const Text(
              'Ver campos disponibles',
            ),
          ),
        ),

        // =================================================
        // CONVERSACIONES
        // =================================================

        const SizedBox(
          height: 15,
        ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: abrirConversaciones,
            icon: const Icon(
              Icons.chat,
            ),
            label: const Text(
              'Mis conversaciones',
            ),
          ),
        ),
      ],
    );
  }
}

