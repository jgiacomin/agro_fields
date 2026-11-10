import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/documento_archivo_service.dart';

/// Funcion que recibe el archivo elegido, lo sube y devuelve su ruta en
/// Storage. Cada pantalla decide a que carpeta va (documentos del campo,
/// operaciones, etc.).
typedef SubirArchivo = Future<String> Function(
  String nombreArchivo,
  Uint8List bytes,
  String contentType,
);

/// Boton unico para adjuntar un PDF o una foto (paso 7a-3).
///
/// Se usa en las Operaciones Protegidas y se va a reutilizar en los
/// Documentos del campo. Revisa tipo y tamano antes de subir (las Storage
/// Rules lo vuelven a revisar). Funciona en la web y en el celular.
class AdjuntarArchivoBoton extends StatefulWidget {
  final String texto;
  final SubirArchivo subir;

  /// Se llama con la ruta en Storage cuando el archivo se subio bien.
  final ValueChanged<String> alSubir;

  /// Si ya hay un archivo adjunto, se muestra como listo.
  final String? rutaActual;

  const AdjuntarArchivoBoton({
    super.key,
    required this.texto,
    required this.subir,
    required this.alSubir,
    this.rutaActual,
  });

  @override
  State<AdjuntarArchivoBoton> createState() => _AdjuntarArchivoBotonState();
}

class _AdjuntarArchivoBotonState extends State<AdjuntarArchivoBoton> {
  bool subiendo = false;
  String? nombreSubido;

  static String? tipoDeArchivo(String nombre) {
    final partes = nombre.toLowerCase().split('.');
    if (partes.length < 2) return null;
    switch (partes.last) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
    }
    return null;
  }

  Future<void> elegirYSubir() async {
    // file_picker 13: pickFile() elige un solo archivo y devuelve null si
    // se cancela; los bytes se leen aparte con readAsBytes().
    final archivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp'],
    );
    if (archivo == null) return;

    final tipo = tipoDeArchivo(archivo.name);

    final Uint8List bytes;
    try {
      bytes = await archivo.readAsBytes();
    } catch (e) {
      _avisar('No se pudo leer el archivo.');
      return;
    }
    if (!mounted) return;
    if (tipo == null) {
      _avisar('Solo se pueden subir archivos PDF o fotos.');
      return;
    }
    final error = DocumentoArchivoService.validar(
      contentType: tipo,
      tamanioBytes: bytes.length,
    );
    if (error != null) {
      _avisar(error);
      return;
    }

    setState(() => subiendo = true);
    try {
      final ruta = await widget.subir(archivo.name, bytes, tipo);
      if (!mounted) return;
      setState(() {
        subiendo = false;
        nombreSubido = archivo.name;
      });
      widget.alSubir(ruta);
    } catch (e) {
      if (!mounted) return;
      setState(() => subiendo = false);
      _avisar('No se pudo subir el archivo: $e');
    }
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final listo = nombreSubido != null ||
        (widget.rutaActual != null && widget.rutaActual!.trim().isNotEmpty);

    return OutlinedButton.icon(
      onPressed: subiendo ? null : elegirYSubir,
      icon: subiendo
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(listo ? Icons.check_circle : Icons.attach_file, size: 20),
      label: Text(
        subiendo
            ? 'Subiendo...'
            : listo
                ? 'Adjuntado${nombreSubido != null ? ': $nombreSubido' : ''}'
                    ' · tocar para sumar otro'
                : widget.texto,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        alignment: Alignment.centerLeft,
        foregroundColor:
            listo ? const Color(0xFF2F6B3A) : const Color(0xFF1C2419),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
