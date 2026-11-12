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
      builder: (context, child) => ColoredBox(
        color: AgroTema.crema,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: anchoMaximoApp),
            child: child,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}