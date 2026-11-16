import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/aceptacion_legal_model.dart';
import '../../services/legal_service.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';

/// GAP-LEGAL-01, opción A: pedir la baja de la cuenta.
///
/// Explica qué se borra, pide escribir BORRAR para confirmar y registra el
/// pedido. El administrador lo completa dentro de 30 días (lo exige Google
/// Play: que el usuario pueda PEDIR la baja desde la app).
class BorrarCuentaScreen extends StatefulWidget {
  const BorrarCuentaScreen({super.key});

  @override
  State<BorrarCuentaScreen> createState() => _BorrarCuentaScreenState();
}

class _BorrarCuentaScreenState extends State<BorrarCuentaScreen> {
  final LegalService _legal = LegalService();
  final TextEditingController _confirmacion = TextEditingController();
  final TextEditingController _motivo = TextEditingController();

  bool cargando = true;
  bool enviando = false;
  SolicitudBaja? pedido;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _confirmacion.dispose();
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final p = await _legal.pedidoDeBaja(uid);
      if (!mounted) return;
      setState(() {
        pedido = p;
        cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => cargando = false);
    }
  }

  Future<void> _pedir() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;
    if (!SolicitudBaja.confirma(_confirmacion.text)) {
      _avisar('Escribí ${SolicitudBaja.palabraConfirmacion} para confirmar.');
      return;
    }
    final motivo = _motivo.text.trim();
    final nuevo = SolicitudBaja(
      usuarioId: usuario.uid,
      email: usuario.email,
      motivo: motivo.isEmpty ? null : motivo,
      fechaPedido: DateTime.now(),
    );
    setState(() => enviando = true);
    try {
      await _legal.pedirBaja(nuevo);
      if (!mounted) return;
      setState(() {
        pedido = nuevo;
        enviando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => enviando = false);
      _avisar('No se pudo enviar el pedido (¿hay señal?): $e');
    }
  }

  void _avisar(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(title: const Text('Borrar mi cuenta')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : pedido != null
              ? _yaPedido(pedido!)
              : _formulario(),
      bottomNavigationBar: (cargando || pedido != null)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: BotonGrande(
                  texto: 'Pedir la baja de mi cuenta',
                  ocupado: enviando,
                  onPressed: _pedir,
                ),
              ),
            ),
    );
  }

  Widget _yaPedido(SolicitudBaja p) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        EstadoVacio(
          icono: Icons.hourglass_top,
          texto: p.estado == 'completada'
              ? 'Tu pedido de baja ya fue completado.'
              : 'Ya pediste la baja de tu cuenta el ${fechaCorta(p.fechaPedido)}. '
                  'Se completa a más tardar el ${fechaCorta(p.fechaLimite)}. '
                  'Si cambiaste de idea, escribinos antes de esa fecha.',
        ),
      ],
    );
  }

  Widget _formulario() {
    const estilo = TextStyle(fontSize: 15, height: 1.45);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const Text(
          'Si pedís la baja, dentro de 30 días se borran:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text('•  Tu cuenta y tus datos personales (nombre, email, foto).',
            style: estilo),
        const Text('•  Los campos que son solo tuyos, con su información y archivos.',
            style: estilo),
        const Text('•  Los permisos que diste o te dieron.', style: estilo),
        const SizedBox(height: 12),
        const Text(
          'Lo que cargaste en el campo de otra persona (por ejemplo, como '
          'encargado o profesional) queda en la historia de ese campo, pero '
          'con tu nombre reemplazado por "usuario eliminado".',
          style: estilo,
        ),
        const SizedBox(height: 12),
        const Text(
          'Mientras tanto podés seguir usando la app. Esto no se puede '
          'deshacer una vez completado.',
          style: TextStyle(
              fontSize: 14, height: 1.45, color: EstiloProduccion.textoSuave),
        ),
        const EtiquetaCampo('¿Por qué te vas? (opcional)'),
        TextField(
          controller: _motivo,
          maxLines: 2,
          maxLength: SolicitudBaja.largoMaximoMotivo,
          textCapitalization: TextCapitalization.sentences,
          decoration: decoracionCampo(ayuda: 'Nos ayuda a mejorar'),
        ),
        EtiquetaCampo(
            'Para confirmar, escribí ${SolicitudBaja.palabraConfirmacion}'),
        TextField(
          controller: _confirmacion,
          textCapitalization: TextCapitalization.characters,
          decoration:
              decoracionCampo(ayuda: SolicitudBaja.palabraConfirmacion),
        ),
      ],
    );
  }
}
