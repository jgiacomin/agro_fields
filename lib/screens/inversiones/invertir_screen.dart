import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/inversion_model.dart';
import '../../services/inversion_service.dart';
import '../chat/chat_screen.dart';

class InvertirScreen extends StatefulWidget {
  final String publicacionId;

  const InvertirScreen({
    super.key,
    required this.publicacionId,
  });

  @override
  State<InvertirScreen> createState() => _InvertirScreenState();
}

class _InvertirScreenState extends State<InvertirScreen> {
  final _formKey = GlobalKey<FormState>();
  final InversionService _service = InversionService();

  final TextEditingController montoController = TextEditingController();
  final TextEditingController porcentajeController = TextEditingController();

  bool loading = false;

  Future<void> invertir() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final chatId = '${widget.publicacionId}_${user.uid}';

      final inversion = Inversion(
        inversionId: '',
        inversorId: user.uid,
        publicacionId: widget.publicacionId,
        monto: double.parse(montoController.text),
        porcentaje: double.parse(porcentajeController.text),
        estado: 'activa',
        fecha: DateTime.now(),
      );

      await _service.crearInversion(inversion);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otroUsuarioId: '',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invertir'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto a invertir',
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Ingrese un monto' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: porcentajeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Porcentaje esperado',
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Ingrese porcentaje' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : invertir,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Confirmar inversión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}