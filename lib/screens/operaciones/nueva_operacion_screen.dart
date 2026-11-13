import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/operacion_protegida_model.dart';
import '../../services/operacion_service.dart';
import '../produccion/produccion_estilo.dart';
import 'operaciones_textos.dart';
import '../../widgets/barra_campo.dart';

/// Pantalla 2 (paso 7a-3, GAP-OPER-01): cargar una operacion protegida.
/// Lo indispensable: que se vende, a quien, cuanto y como se paga.
/// El poder, el contrato y las garantias se adjuntan despues, en el
/// detalle (la lista de control avisa lo que falta).
class NuevaOperacionScreen extends StatefulWidget {
  final String activoAgroId;

  const NuevaOperacionScreen({super.key, required this.activoAgroId});

  @override
  State<NuevaOperacionScreen> createState() => _NuevaOperacionScreenState();
}

class _NuevaOperacionScreenState extends State<NuevaOperacionScreen> {
  final OperacionService _servicio = OperacionService();

  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _cantidad = TextEditingController();
  final TextEditingController _comprador = TextEditingController();
  final TextEditingController _cuit = TextEditingController();
  final TextEditingController _firmante = TextEditingController();
  final TextEditingController _importe = TextEditingController();
  final TextEditingController _observaciones = TextEditingController();

  /// ID armado al abrir la pantalla: tocar "Guardar" dos veces no duplica.
  late final String operacionId = _servicio.nuevoIdOperacion();

  ProductoOperacion? producto;
  String unidad = 'cabezas';
  String? caracter;
  String moneda = 'ARS';
  FormaPagoOperacion? formaPago;
  bool guardando = false;

  static const unidades = ['cabezas', 'kg', 'toneladas', 'unidades'];
  static const caracteres = ['titular', 'apoderado', 'presidente', 'socio gerente', 'otro'];
  static const monedas = ['ARS', 'USD', 'PYG'];

  @override
  void dispose() {
    _descripcion.dispose();
    _cantidad.dispose();
    _comprador.dispose();
    _cuit.dispose();
    _firmante.dispose();
    _importe.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  void elegirProducto(ProductoOperacion p) {
    setState(() {
      producto = p;
      if (p == ProductoOperacion.hacienda) unidad = 'cabezas';
      if (p == ProductoOperacion.granos) unidad = 'toneladas';
    });
  }

  String? texto(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _avisar('Tenés que iniciar sesión.');
      return;
    }
    if (producto == null) {
      _avisar('Elegí qué se vende.');
      return;
    }
    if (formaPago == null) {
      _avisar('Elegí la forma de pago.');
      return;
    }

    final importe = leerNumero(_importe.text);
    if (importe == null) {
      _avisar('Poné el importe total (solo números).');
      return;
    }

    double? cantidad;
    if (_cantidad.text.trim().isNotEmpty) {
      cantidad = leerNumero(_cantidad.text);
      if (cantidad == null) {
        _avisar('La cantidad tiene que ser un número.');
        return;
      }
    }

    final operacion = OperacionProtegida(
      operacionId: operacionId,
      activoAgroId: widget.activoAgroId,
      creadoPor: uid,
      fechaCreacion: DateTime.now(),
      producto: producto!,
      descripcionProducto: texto(_descripcion),
      cantidad: cantidad,
      unidad: cantidad == null ? null : unidad,
      importe: importe,
      moneda: moneda,
      formaPago: formaPago!,
      comprador: CompradorOperacion(
        nombre: _comprador.text.trim(),
        identificacionFiscal: texto(_cuit),
        representanteNombre: texto(_firmante),
        representanteCaracter: caracter,
      ),
      observaciones: texto(_observaciones),
    );

    final errores = operacion.validar();
    if (errores.isNotEmpty) {
      _avisar(errores.join(' '));
      return;
    }

    setState(() => guardando = true);
    try {
      await _servicio.crearOperacion(operacion);
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
        title: const Text('Nueva operación'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const TituloSeccionEspaciada('Qué se vende'),
          OpcionesTocar<ProductoOperacion>(
            opciones: ProductoOperacion.values,
            elegida: producto,
            etiqueta: nombreProducto,
            alElegir: elegirProducto,
          ),
          if (producto == ProductoOperacion.otro) ...[
            const EtiquetaCampo('¿Qué producto?'),
            TextField(
              controller: _descripcion,
              textCapitalization: TextCapitalization.sentences,
              decoration: decoracionCampo(ayuda: 'Ej.: Miel a granel'),
            ),
          ],
          const EtiquetaCampo('Cantidad (opcional)'),
          TextField(
            controller: _cantidad,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoracionCampo(ayuda: 'Ej.: 40'),
          ),
          const SizedBox(height: 10),
          OpcionesTocar<String>(
            opciones: unidades,
            elegida: unidad,
            etiqueta: (u) => u,
            alElegir: (u) => setState(() => unidad = u),
          ),
          const TituloSeccionEspaciada('A quién'),
          const EtiquetaCampo('Comprador (nombre o razón social)'),
          TextField(
            controller: _comprador,
            textCapitalization: TextCapitalization.words,
            decoration: decoracionCampo(ayuda: 'Ej.: Frigorífico Ejemplo SA'),
          ),
          const EtiquetaCampo('CUIT / RUC del comprador'),
          TextField(
            controller: _cuit,
            keyboardType: TextInputType.number,
            decoration: decoracionCampo(ayuda: 'Ej.: 30-12345678-9'),
          ),
          const EtiquetaCampo('¿Quién firma por el comprador?'),
          TextField(
            controller: _firmante,
            textCapitalization: TextCapitalization.words,
            decoration: decoracionCampo(ayuda: 'Nombre y apellido'),
          ),
          const SizedBox(height: 10),
          OpcionesTocar<String>(
            opciones: caracteres,
            elegida: caracter,
            etiqueta: (c) => c[0].toUpperCase() + c.substring(1),
            alElegir: (c) => setState(() => caracter = c),
          ),
          const TituloSeccionEspaciada('Cuánto y cómo se paga'),
          const EtiquetaCampo('Importe total'),
          TextField(
            controller: _importe,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: decoracionCampo(ayuda: 'Ej.: 15000000'),
          ),
          const SizedBox(height: 10),
          OpcionesTocar<String>(
            opciones: monedas,
            elegida: moneda,
            etiqueta: (m) => m,
            alElegir: (m) => setState(() => moneda = m),
          ),
          const EtiquetaCampo('Forma de pago'),
          OpcionesTocar<FormaPagoOperacion>(
            opciones: FormaPagoOperacion.values,
            elegida: formaPago,
            etiqueta: nombreFormaPago,
            alElegir: (f) => setState(() => formaPago = f),
          ),
          const EtiquetaCampo('Notas (opcional)'),
          TextField(
            controller: _observaciones,
            maxLines: 2,
            decoration: decoracionCampo(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Lo que no sepas ahora, dejalo vacío. Después, en el detalle, '
            'podés adjuntar el contrato, el poder del que firma, las '
            'garantías y cargar los cheques.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: EstiloProduccion.textoSuave,
            ),
          ),
          const LeyendaNoGarantia(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: 'Guardar operación',
            ocupado: guardando,
            onPressed: guardar,
          ),
        ),
      ),
    );
  }
}

/// Titulo de seccion con aire arriba, para separar bloques del formulario.
class TituloSeccionEspaciada extends StatelessWidget {
  final String texto;

  const TituloSeccionEspaciada(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: TituloSeccion(texto),
    );
  }
}
