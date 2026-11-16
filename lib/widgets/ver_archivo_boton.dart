import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// GAP-ARCH-01 (16/11/2026): botón único para ver o descargar un archivo
/// adjunto (documento, comprobante, cheque, plano...).
///
/// Pide a Firebase un enlace temporal y lo abre: en el celular con el visor
/// del teléfono, en la compu en una pestaña nueva. Las Storage Rules
/// deciden quién puede abrirlo: si no corresponde, Firebase no da el enlace.
class VerArchivoBoton extends StatefulWidget {
  final String ruta;
  final String texto;

  const VerArchivoBoton({super.key, required this.ruta, this.texto = 'Ver archivo'});

  /// Nombre para mostrar: el final de la ruta, sin el número que se le
  /// agrega al subir (ej.: "1794835327_escritura.pdf" → "escritura.pdf").
  static String nombreVisible(String ruta) {
    final partes = ruta.split('/');
    final ultimo = partes.isEmpty ? ruta : partes.last;
    return ultimo.replaceFirst(RegExp(r'^\d{6,}_'), '');
  }

  @override
  State<VerArchivoBoton> createState() => _VerArchivoBotonState();
}

class _VerArchivoBotonState extends State<VerArchivoBoton> {
  bool abriendo = false;

  Future<void> _abrir() async {
    setState(() => abriendo = true);
    final mensajero = ScaffoldMessenger.of(context);
    try {
      final url = await FirebaseStorage.instance.ref(widget.ruta).getDownloadURL();
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok) throw StateError('no se pudo abrir');
    } catch (e) {
      mensajero.showSnackBar(const SnackBar(
        content: Text('No se pudo abrir el archivo (¿hay señal? ¿tenés permiso?).'),
      ));
    } finally {
      if (mounted) setState(() => abriendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: abriendo ? null : _abrir,
        icon: abriendo
            ? const SizedBox(
                width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.attach_file, size: 18),
        label: Text('${widget.texto} (${VerArchivoBoton.nombreVisible(widget.ruta)})',
            overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
