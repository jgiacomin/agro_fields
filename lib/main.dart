import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'core/auth/auth_gate.dart';
import 'core/theme/agro_tema.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //if (kDebugMode) {
    //FirebaseFirestore.instance.useFirestoreEmulator(
      //'127.0.0.1',
      //8080,
    //);
 // }

  runApp(const AgroApp());
}

/// Ancho máximo de la app en pantallas grandes (12/11/2026).
const double anchoMaximoApp = 860;

class AgroApp extends StatelessWidget {
  const AgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agro Fields',
      theme: AgroTema.tema,
      // En pantallas grandes (compu), toda la app queda centrada con un
      // ancho máximo, como una tablet. En el celular no cambia nada.
      // Diseño V8 campo (13/11/2026): fondo común con el campo de trigo
      // abajo, suave y desvanecido; las pantallas lo dejan ver.
      builder: (context, child) => ColoredBox(
        color: AgroTema.crema,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: anchoMaximoApp),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _FondoCampo(),
                child ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Franja del campo de trigo abajo de todas las pantallas (Pixabay, uso
/// libre). Se desvanece hacia arriba para no tapar el contenido.
class _FondoCampo extends StatelessWidget {
  const _FondoCampo();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: Opacity(
          opacity: 0.55,
          child: ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00000000), Color(0xFF000000)],
              stops: [0.0, 0.7],
            ).createShader(r),
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              'assets/fondo_campo.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}