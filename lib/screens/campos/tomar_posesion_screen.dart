import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../services/posesion_service.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';

/// AF-038 F (27/11/2026): el dueño pega el código que le mandó el broker,
/// ve de qué campo es y confirma que es suyo.
class TomarPosesionScreen extends StatefulWidget {
  const TomarPosesionScreen({super.key});

  @override
  State<TomarPosesionScreen> createState() => _TomarPosesionScreenState();
}

class _TomarPosesionScreenState extends State<TomarPosesionScreen> {
  final _servicio = PosesionService();
  final _codigo = TextEditingController();
  CodigoPosesion? _encontrado;
  String? _error;
  bool _ocupado = false;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    setState(() {
      _ocupado = true;
      _error = null;
      _encontrado = null;
    });
    try {
      final c = await _servicio.buscar(_codigo.text);
      if (mounted) setState(() => _encontrado = c);
    } on CodigoPosesionNoValido catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (e) {
      if (mounted) setState(() => _error = 'No se pudo buscar el código: $e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _confirmar() async {
    final c = _encontrado;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (c == null || uid == null) return;
    setState(() => _ocupado = true);
    try {
      await _servicio.tomarPosesion(c, uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Listo: ${c.nombreCampo} ya figura a tu nombre.')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo tomar posesión. Revisá que el '
          'código sea tuyo y no esté vencido.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _encontrado;
    return Scaffold(
      backgroundColor: AgroTema.crema,
      appBar: BarraCampo(title: const Text('Tengo un código de mi campo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Si un broker o una inmobiliaria cargó tu campo, te mandó un '
                'código. Pegalo acá para que el campo quede a tu nombre.',
                style: TextStyle(fontSize: 15, color: AgroTema.pizarra),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codigo,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Código',
                  hintText: 'AF-7K3P9QXM',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _buscar(),
              ),
              const SizedBox(height: 12),
              BotonGrande(
                texto: 'Buscar',
                icono: Icons.search,
                ocupado: _ocupado && c == null,
                onPressed: _ocupado ? null : _buscar,
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!,
                    style: const TextStyle(
                        color: AgroTema.rojo, fontWeight: FontWeight.w600)),
              ],
              if (c != null) ...[
                const SizedBox(height: 20),
                TarjetaBlanca(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('¿Sos el dueño de este campo?',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(c.nombreCampo,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        if (c.lugar.isNotEmpty)
                          Text(c.lugar,
                              style: const TextStyle(
                                  color: AgroTema.pizarraSuave)),
                        const SizedBox(height: 10),
                        const Text(
                          'Vas a quedar como dueño declarado hasta que subas '
                          'la escritura. El broker sigue trabajando el aviso '
                          'y cada cambio que haga te llega a la campanita.',
                          style: TextStyle(
                              fontSize: 13, color: AgroTema.pizarraSuave),
                        ),
                        const SizedBox(height: 14),
                        BotonGrande(
                          texto: 'Sí, es mío',
                          icono: Icons.verified_outlined,
                          ocupado: _ocupado,
                          onPressed: _ocupado ? null : _confirmar,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
