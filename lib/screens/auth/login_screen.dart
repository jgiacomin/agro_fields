import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../services/auth_service.dart';
import '../../widgets/logo_agro_fields.dart';

/// Pantalla de ingreso (diseño V8, 12/11/2026).
/// Atardecer, logo, AGRO FIELDS (sin "V8": es la versión interna del
/// proyecto, no el nombre para los usuarios), lema y un solo botón: Google.
/// El ingreso lo sigue haciendo AuthService (sin cambios). Cuando entra,
/// AuthGate pasa solo al Inicio.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool ingresando = false;

  Future<void> _ingresar() async {
    // Evita tocar el botón dos veces.
    if (ingresando) return;
    setState(() => ingresando = true);

    final user = await _authService.signInWithGoogle();

    if (!mounted) return;
    if (user == null) {
      setState(() => ingresando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se completó el ingreso. Probá de nuevo.'),
        ),
      );
    }
    // Si entró, AuthGate cambia de pantalla solo.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Cielo de atardecer que baja al crema de la app.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6C49B),
              Color(0xFFFBE6D2),
              AgroTema.crema,
            ],
            stops: [0.0, 0.45, 0.8],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LogoAgroFields(tamano: 132),
                    const SizedBox(height: 22),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'AGRO\n',
                            style: TextStyle(color: AgroTema.pizarra),
                          ),
                          TextSpan(
                            text: 'FIELDS',
                            style: TextStyle(color: AgroTema.terracota),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Conectar con confianza.\nCrecer con datos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.4,
                        color: AgroTema.pizarra,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: ingresando ? null : _ingresar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AgroTema.terracota,
                          disabledBackgroundColor:
                              AgroTema.terracota.withValues(alpha: 0.6),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: ingresando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(
                          ingresando ? 'Ingresando...' : 'Ingresar con Google',
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'El campo también tiene futuro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AgroTema.pizarraSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
