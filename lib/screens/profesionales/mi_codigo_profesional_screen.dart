import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../produccion/produccion_estilo.dart';

/// AF-093: el profesional comparte su código para que un dueño lo invite.
/// El código es su identificador interno: no da acceso a nada por sí solo;
/// el acceso lo da el dueño y lo puede quitar cuando quiera.
class MiCodigoProfesionalScreen extends StatelessWidget {
  const MiCodigoProfesionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Mi código de profesional'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Si sos ingeniero agrónomo, veterinario o técnico, pasale este '
            'código al dueño del campo (por WhatsApp, por ejemplo). Él te '
            'invita y vas a poder registrar tus visitas y recomendaciones.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          TarjetaBlanca(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                uid,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          BotonGrande(
            texto: 'Copiar código',
            onPressed: uid.isEmpty
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: uid));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Código copiado.')),
                    );
                  },
          ),
          const SizedBox(height: 18),
          const Text(
            'El código solo no da acceso a ningún campo. Tu título queda '
            'como "declarado" hasta que se verifique.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: EstiloProduccion.textoSuave,
            ),
          ),
        ],
      ),
    );
  }
}
