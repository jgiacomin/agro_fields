import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/legal/terminos_screen.dart';
import '../../services/legal_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // GAP-LEGAL-01: antes del Inicio, revisar que haya aceptado la
          // versión vigente de los Términos y la Política de privacidad.
          return PuertaLegal(
            key: ValueKey(snapshot.data!.uid),
            usuarioId: snapshot.data!.uid,
          );
        }

        return LoginScreen();
      },
    );
  }
}

/// GAP-LEGAL-01: muestra la pantalla de aceptación si falta aceptar la
/// versión vigente. Sin señal (no se puede saber) deja pasar y vuelve a
/// revisar la próxima vez que se abra la app.
class PuertaLegal extends StatefulWidget {
  final String usuarioId;
  const PuertaLegal({super.key, required this.usuarioId});

  @override
  State<PuertaLegal> createState() => _PuertaLegalState();
}

class _PuertaLegalState extends State<PuertaLegal> {
  bool? acepto;
  bool revisando = true;

  @override
  void initState() {
    super.initState();
    _revisar();
  }

  Future<void> _revisar() async {
    bool? resultado;
    try {
      resultado = await LegalService().aceptoVersionVigente(widget.usuarioId);
    } catch (_) {
      // Error inesperado: no trabar al usuario; se revisa la próxima vez.
      resultado = null;
    }
    if (!mounted) return;
    setState(() {
      acepto = resultado;
      revisando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (revisando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (acepto == false) {
      return TerminosScreen(
        pedirAceptacion: true,
        alAceptar: () => setState(() => acepto = true),
      );
    }
    return const DashboardScreen();
  }
}
