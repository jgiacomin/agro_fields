import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/autorizacion_activo_model.dart';
import '../../services/profesional_service.dart';
import '../produccion/produccion_estilo.dart';
import 'intervenciones_screen.dart';

/// AF-093: campos donde el usuario fue invitado como profesional.
/// El nombre del campo viene en la invitación (el profesional no lee el
/// expediente).
class CamposProfesionalScreen extends StatefulWidget {
  const CamposProfesionalScreen({super.key});

  @override
  State<CamposProfesionalScreen> createState() =>
      _CamposProfesionalScreenState();
}

class _CamposProfesionalScreenState extends State<CamposProfesionalScreen> {
  final ProfesionalService _servicio = ProfesionalService();
  bool cargando = true;
  String? error;
  List<AutorizacionActivo> lista = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final l = await _servicio.camposComoProfesional(uid);
      if (!mounted) return;
      setState(() {
        lista = l;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudieron cargar los campos: $e';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Campos donde soy profesional'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error!, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (lista.isEmpty)
                        const Text(
                          'Todavía no te invitaron a ningún campo. Pasale tu '
                          'código al dueño (Menú → Mi código de profesional).',
                          style: TextStyle(
                              color: EstiloProduccion.textoSuave, height: 1.4),
                        ),
                      for (final a in lista)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TarjetaBlanca(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => IntervencionesScreen(
                                  activoAgroId: a.activoId,
                                  nombreActivo:
                                      a.ambito.descripcion ?? 'Campo',
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.grass,
                                      color: EstiloProduccion.verde),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a.ambito.descripcion ?? 'Campo',
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          'Invitado el ${fechaCorta(a.fechaOtorgamiento)}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color:
                                                  EstiloProduccion.textoSuave),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: EstiloProduccion.textoSuave),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
