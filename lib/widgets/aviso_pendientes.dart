import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/agro_tema.dart';

/// GAP-OFF-01: aviso del Inicio cuando hay datos guardados en el teléfono
/// que todavía no llegaron al servidor (por falta de señal).
///
/// Usa lo que Firebase ya trae (waitForPendingWrites): no hace falta
/// instalar nada. Se revisa al abrir y cada 15 segundos; el aviso se va
/// solo cuando todo llegó.
class AvisoPendientes extends StatefulWidget {
  const AvisoPendientes({super.key});

  @override
  State<AvisoPendientes> createState() => _AvisoPendientesState();
}

class _AvisoPendientesState extends State<AvisoPendientes> {
  bool pendientes = false;
  bool revisando = false;
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    _revisar();
    _reloj = Timer.periodic(const Duration(seconds: 15), (_) => _revisar());
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  Future<void> _revisar() async {
    if (revisando) return;
    revisando = true;
    try {
      final todoEnviado = FirebaseFirestore.instance.waitForPendingWrites();
      try {
        // Si no hay nada pendiente, termina enseguida.
        await todoEnviado.timeout(const Duration(milliseconds: 800));
        debugPrint('AVISO_PENDIENTES: nada pendiente');
        _cambiar(false);
      } on TimeoutException {
        debugPrint('AVISO_PENDIENTES: HAY datos pendientes de enviar');
        _cambiar(true);
        await todoEnviado;
        debugPrint('AVISO_PENDIENTES: todo enviado');
        _cambiar(false);
      }
    } catch (e) {
      debugPrint('AVISO_PENDIENTES: error al revisar: $e');
      // Si no se puede saber, no se muestra nada (no asusta sin motivo).
      _cambiar(false);
    } finally {
      revisando = false;
    }
  }

  void _cambiar(bool valor) {
    if (mounted && pendientes != valor) setState(() => pendientes = valor);
  }

  @override
  Widget build(BuildContext context) {
    if (!pendientes) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgroTema.dorado),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_upload_outlined, color: AgroTema.pizarra),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hay datos guardados en el teléfono que se envían cuando '
              'haya señal. No cierres sesión hasta que se envíen.',
              style: TextStyle(height: 1.35, color: AgroTema.pizarra),
            ),
          ),
        ],
      ),
    );
  }
}
