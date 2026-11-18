import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../services/produccion_service.dart';
import 'produccion_estilo.dart';
import '../../widgets/barra_campo.dart';

/// Pantalla 2 (paso 6a, GAP-PROD-01): cargar un rodeo.
/// Los animales se cargan despues, con un evento de Entrada.
///
/// GAP-PROD-02 (18/11/2026): tambien sirve para lotes de aves y de peces.
/// Se elige la actividad arriba; etapa y tenencia son solo de ganaderia.
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

  String actividad = 'ganaderia';
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
      _avisar('Poné un nombre, por ejemplo "${_ejemploNombre()}".');
      return;
    }

    setState(() => guardando = true);

    try {
      await _servicio.crearGrupo(GrupoProductivo(
        grupoId: _servicio.nuevoIdGrupo(),
        activoAgroId: widget.activoAgroId,
        actividad: actividad,
        nombre: nombre,
        etapa: _esGanaderia ? etapa : null,
        tenencia: _esGanaderia ? tenencia : TenenciaAnimales.desconocida,
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

  bool get _esGanaderia => actividad == 'ganaderia';

  String _ejemploNombre() {
    switch (actividad) {
      case 'avicultura':
        return 'Galpón 1 parrilleros';
      case 'piscicultura':
        return 'Estanque 2 tilapias';
      default:
        return 'Rodeo de cría';
    }
  }

  static String _nombreActividad(String a) {
    switch (a) {
      case 'avicultura':
        return 'Aves';
      case 'piscicultura':
        return 'Peces';
      default:
        return 'Ganadería';
    }
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(
        title: Text(_esGanaderia ? 'Nuevo rodeo' : 'Nuevo lote'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          const EtiquetaCampo('¿Qué animales son?'),
          OpcionesTocar<String>(
            opciones: actividadesAnimales,
            elegida: actividad,
            etiqueta: _nombreActividad,
            alElegir: (a) => setState(() => actividad = a),
          ),
          const EtiquetaCampo('Nombre'),
          TextField(
            controller: _nombre,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(ayuda: 'Ej.: ${_ejemploNombre()}'),
          ),
          if (_esGanaderia) ...[
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
          ],
          EtiquetaCampo(_esGanaderia
              ? '¿En qué potrero arranca?'
              : '¿En qué galpón o estanque arranca?'),
          if (widget.unidades.isEmpty)
            const Text(
              'Todavía no hay lugares cargados. Podés guardar igual '
              'y cargar el lugar después.',
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
            texto: _esGanaderia ? 'Guardar rodeo' : 'Guardar lote',
            ocupado: guardando,
            onPressed: guardar,
          ),
        ),
      ),
    );
  }
}
