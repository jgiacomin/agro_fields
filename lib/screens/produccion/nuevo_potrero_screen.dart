import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/unidad_productiva_model.dart';
import '../../services/produccion_service.dart';
import 'produccion_estilo.dart';

/// Formulario corto para cargar un potrero, corral u otra unidad
/// (paso 6a, GAP-PROD-01). Si no se saben las hectareas, quedan vacias.
class NuevoPotreroScreen extends StatefulWidget {
  final String activoAgroId;

  const NuevoPotreroScreen({super.key, required this.activoAgroId});

  @override
  State<NuevoPotreroScreen> createState() => _NuevoPotreroScreenState();
}

class _NuevoPotreroScreenState extends State<NuevoPotreroScreen> {
  final ProduccionService _servicio = ProduccionService();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _hectareas = TextEditingController();

  static const tipos = [
    TipoUnidadProductiva.potrero,
    TipoUnidadProductiva.corral,
    TipoUnidadProductiva.lote,
    TipoUnidadProductiva.galpon,
    TipoUnidadProductiva.tambo,
    TipoUnidadProductiva.otro,
  ];

  TipoUnidadProductiva tipo = TipoUnidadProductiva.potrero;
  bool guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _hectareas.dispose();
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
      _avisar('Poné un nombre, por ejemplo "Potrero 1".');
      return;
    }

    // Lo desconocido no es cero: vacio = no se sabe.
    double? hectareas;
    final textoHa = _hectareas.text.trim().replaceAll(',', '.');
    if (textoHa.isNotEmpty) {
      hectareas = double.tryParse(textoHa);
      if (hectareas == null || hectareas <= 0) {
        _avisar('Las hectáreas tienen que ser un número mayor a cero, '
            'o dejalas vacías si no las sabés.');
        return;
      }
    }

    setState(() => guardando = true);

    try {
      await _servicio.crearUnidad(UnidadProductiva(
        unidadId: _servicio.nuevoIdUnidad(),
        activoAgroId: widget.activoAgroId,
        tipo: tipo,
        nombre: nombre,
        superficieHa: hectareas,
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
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Nuevo potrero'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          const EtiquetaCampo('Nombre'),
          TextField(
            controller: _nombre,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(ayuda: 'Ej.: Potrero 1'),
          ),
          const EtiquetaCampo('Tipo'),
          OpcionesTocar<TipoUnidadProductiva>(
            opciones: tipos,
            elegida: tipo,
            etiqueta: nombreTipoUnidad,
            alElegir: (t) => setState(() => tipo = t),
          ),
          const EtiquetaCampo('Hectáreas (opcional)'),
          TextField(
            controller: _hectareas,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoracionCampo(ayuda: 'Si no las sabés, dejalo vacío'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: 'Guardar potrero',
            ocupado: guardando,
            onPressed: guardar,
          ),
        ),
      ),
    );
  }
}
