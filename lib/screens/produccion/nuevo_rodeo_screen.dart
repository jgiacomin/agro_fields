import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../services/produccion_service.dart';
import 'produccion_estilo.dart';
import '../../widgets/barra_campo.dart';

/// Pantalla 2 (paso 6a, GAP-PROD-01): cargar un rodeo.
/// Los animales se cargan despues, con un evento de Entrada.
class NuevoRodeoScreen extends StatefulWidget {
  final String activoAgroId;
  final List<UnidadProductiva> unidades;

  const NuevoRodeoScreen({
    super.key,
    required this.activoAgroId,
    required this.unidades,
  });

  @override
  State<NuevoRodeoScreen> createState() => _NuevoRodeoScreenState();
}

class _NuevoRodeoScreenState extends State<NuevoRodeoScreen> {
  final ProduccionService _servicio = ProduccionService();
  final TextEditingController _nombre = TextEditingController();

  static const etapas = [
    EtapaGanadera.cria,
    EtapaGanadera.recriaPastoril,
    EtapaGanadera.recriaCorral,
    EtapaGanadera.recriaMixta,
    EtapaGanadera.terminacion,
    EtapaGanadera.feedlot,
  ];

  static const tenencias = [
    TenenciaAnimales.propios,
    TenenciaAnimales.capitalizacion,
    TenenciaAnimales.hoteleria,
    TenenciaAnimales.desconocida,
  ];

  EtapaGanadera? etapa;
  TenenciaAnimales tenencia = TenenciaAnimales.desconocida;
  String? unidadInicialId;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.unidades.isNotEmpty) {
      unidadInicialId = widget.unidades.first.unidadId;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _avisar('Tenés que iniciar sesión.');
      return;
    }

    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      _avisar('Poné un nombre, por ejemplo "Rodeo de cría".');
      return;
    }

    setState(() => guardando = true);

    try {
      await _servicio.crearGrupo(GrupoProductivo(
        grupoId: _servicio.nuevoIdGrupo(),
        activoAgroId: widget.activoAgroId,
        actividad: 'ganaderia',
        nombre: nombre,
        etapa: etapa,
        tenencia: tenencia,
        unidadInicialId: unidadInicialId,
        creadoPor: uid,
        fechaCreacion: DateTime.now(),
      ));

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => guardando = false);
      _avisar('No se pudo guardar: $e');
    }
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(
        title: const Text('Nuevo rodeo'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          const EtiquetaCampo('Nombre'),
          TextField(
            controller: _nombre,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(ayuda: 'Ej.: Rodeo de cría'),
          ),
          const EtiquetaCampo('Etapa'),
          OpcionesTocar<EtapaGanadera>(
            opciones: etapas,
            elegida: etapa,
            etiqueta: nombreEtapa,
            alElegir: (e) => setState(() => etapa = e),
          ),
          const EtiquetaCampo('¿De quién son los animales?'),
          OpcionesTocar<TenenciaAnimales>(
            opciones: tenencias,
            elegida: tenencia,
            etiqueta: nombreTenencia,
            alElegir: (t) => setState(() => tenencia = t),
          ),
          const EtiquetaCampo('¿En qué potrero arranca?'),
          if (widget.unidades.isEmpty)
            const Text(
              'Todavía no hay potreros cargados. Podés guardar el rodeo igual '
              'y cargar el potrero después.',
              style: TextStyle(color: EstiloProduccion.textoSuave),
            )
          else
            OpcionesTocar<String>(
              opciones: widget.unidades.map((u) => u.unidadId).toList(),
              elegida: unidadInicialId,
              etiqueta: (id) => widget.unidades
                  .firstWhere((u) => u.unidadId == id)
                  .nombre,
              alElegir: (id) => setState(() => unidadInicialId = id),
            ),
          const SizedBox(height: 20),
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: EstiloProduccion.textoSuave,
              ),
              children: [
                TextSpan(text: 'Los animales se cargan después, con un evento '
                    'de '),
                TextSpan(
                  text: 'Entrada',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                    text: '. Así queda registrado de dónde vino cada uno.'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: 'Guardar rodeo',
            ocupado: guardando,
            onPressed: guardar,
          ),
        ),
      ),
    );
  }
}
