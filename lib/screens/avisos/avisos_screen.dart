import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/avisos_service.dart';
import '../../widgets/barra_campo.dart';

/// AF-145 (26/11/2026): la pantalla de la campanita. Lista simple de lo
/// que hay que atender; cada aviso lleva directo a su pantalla.
class AvisosScreen extends StatefulWidget {
  final List<ActivoAgroV2> campos;

  const AvisosScreen({super.key, required this.campos});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  final AvisosService _servicio = AvisosService();
  List<Aviso>? _avisos;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await _servicio.avisos(widget.campos);
    if (!mounted) return;
    setState(() => _avisos = lista);
  }

  @override
  Widget build(BuildContext context) {
    final avisos = _avisos;
    return Scaffold(
      backgroundColor: AgroTema.crema,
      appBar: BarraCampo(title: const Text('Avisos')),
      body: avisos == null
          ? const Center(child: CircularProgressIndicator())
          : avisos.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No tenés avisos. Está todo al día.',
                      style: TextStyle(
                          fontSize: 16, color: AgroTema.pizarraSuave),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: avisos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _tarjeta(avisos[i]),
                  ),
                ),
    );
  }

  Widget _tarjeta(Aviso a) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          // 27/11/2026: los avisos de "algo que pasó" quedan vistos.
          await _servicio.marcarVisto(a);
          if (!mounted) return;
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => a.destino()));
          // Al volver, se recalcula (por si ya lo atendiste).
          _cargar();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AgroTema.borde),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: a.color.withValues(alpha: 0.15),
                child: Icon(a.icono, color: a.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AgroTema.pizarra,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.detalle,
                      style: const TextStyle(
                          fontSize: 13, color: AgroTema.pizarraSuave),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AgroTema.terracota),
            ],
          ),
        ),
      ),
    );
  }
}
