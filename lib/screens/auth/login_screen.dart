import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthService _authService = AuthService();

  Future<void> _login(BuildContext context) async {
    final user = await _authService.signInWithGoogle();

    if (user != null) {
       // LOGIN OK
      //print("LOGIN OK");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agro Fields"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Ingresar con Google"),
          onPressed: () => _login(context),
        ),
      ),
    );
  }
}