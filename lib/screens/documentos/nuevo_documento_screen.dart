import 'package:flutter/material.dart';

import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/activos/documentacion_activo_model.dart';
import '../../models/activos/documento_activo_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/documento_archivo_service.dart';
import '../../widgets/adjuntar_archivo_boton.dart';
import '../produccion/produccion_estilo.dart';
import 'documentos_activo_screen.dart';

/// Pantalla 2 (paso 4b, pantalla pendiente): cargar un documento del campo.
///
/// Reutiliza lo ya validado:
///  - DocumentoActivo (paso 4a): emisor, numero, vigencia, jurisdiccion,
///    transferibilidad y datos personales.
///  - DocumentoArchivoService (paso 4b): sube el archivo a la carpeta
///    privada del Activo.
///  - ActivoAgroServiceV2.actualizarDocumentacion: guarda y deja historial
///    y auditoria.
///  - AdjuntarArchivoBoton (paso 7a-3): el boton unico para adjuntar.
///
/// Los documentos no se borran desde la app (archivar no es borrar).
class NuevoDocumentoScreen extends StatefulWidget {
  final ActivoAgroV2 activo;

  const NuevoDocumentoScreen({super.key, required this.activo});

  @override
  State<NuevoDocumentoScreen> createState() => _NuevoDocumentoScreenState();
}

class _NuevoDocumentoScreenState extends State<NuevoDocumentoScreen> {
  final ActivoAgroServiceV2 _activos = ActivoAgroServiceV2();
  final DocumentoArchivoService _archivos = DocumentoArchivoService();

  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _emisor = TextEditingController();
  final TextEditingController _numero = TextEditingController();
  final TextEditingController _provincia = TextEditingController();
  final TextEditingController _observaciones = TextEditingController();

  /// ID armado al abrir la pantalla: el archivo se sube a la carpeta de
  /// este documento y tocar "Guardar" dos veces no lo duplica.
  late final String documentoId =
      'doc_${DateTime.now().millisecondsSinceEpoch}';

  String? tipo;
  DateTime? fechaEmision;
  DateTime? fechaVencimiento;
  TransferibilidadDocumento transferibilidad =
      TransferibilidadDocumento.desconocida;
  bool contieneDatosPersonales = true;
  String? archivoRuta;
  bool guardando = false;

  @override
  void dispose() {
    _descripcion.dispose();
    _emisor.dispose();
    _numero.dispose();
    _provincia.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  String? texto(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<DateTime?> elegirFecha(DateTime? actual, String ayuda,
      {bool futuro = false}) {
    final hoy = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: actual ?? hoy,
      firstDate: DateTime(1900),
      lastDate: futuro ? DateTime(hoy.year + 50) : hoy,
      helpText: ayuda,
    );
  }

  Future<void> guardar() async {
    if (tipo == null) {
      _avisar('Elegí el tipo de documento.');
      return;
    }
    if (fechaEmision != null &&
        fechaVencimiento != null &&
        fechaVencimiento!.isBefore(fechaEmision!)) {
      _avisar('El vencimiento no puede ser antes de la emisión.');
      return;
    }

    final documento = DocumentoActivo(
      documentoId: documentoId,
      tipo: tipo!,
      descripcion: texto(_descripcion) ?? nombreTipoDocumento(tipo!),
      fecha: fechaEmision,
      // Declarado no es verificado. Con archivo, queda "con documento".
      estado: archivoRuta == null ? 'declarado' : 'con_documento',
      evidenciaIds: const [],
      observaciones: texto(_observaciones),
      emisor: texto(_emisor),
      numero: texto(_numero),
      fechaVencimiento: fechaVencimiento,
      pais: null,
      provinciaEstado: texto(_provincia),
      transferibilidad: transferibilidad,
      contieneDatosPersonales: contieneDatosPersonales,
      archivoRuta: archivoRuta,
    );

    setState(() => guardando = true);
    try {
      // Se relee el campo para no pisar documentos cargados mientras tanto.
      final actual =
          await _activos.obtenerActivoPorId(widget.activo.activoId);
      if (actual == null) throw Exception('No se encontró el campo.');
      final d = actual.documentacion;

      final yaEsta =
          d.documentosEstructurados.any((x) => x.documentoId == documentoId);

      final nueva = DocumentacionActivo(
        documentacionCompleta: d.documentacionCompleta,
        documentos: d.documentos,
        certificaciones: d.certificaciones,
        permisos: d.permisos,
        archivos: d.archivos,
        documentosEstructurados: yaEsta
            ? d.documentosEstructurados
            : [...d.documentosEstructurados, documento],
        observaciones: d.observaciones,
        fechaActualizacion: DateTime.now(),
      );

      await _activos.actualizarDocumentacion(actual.activoId, nueva);

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

  Widget _botonFecha(String texto, VoidCallback alTocar) {
    return OutlinedButton.icon(
      onPressed: alTocar,
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(texto),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        foregroundColor: EstiloProduccion.texto,
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        title: const Text('Nuevo documento'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const EtiquetaCampo('Tipo de documento'),
          OpcionesTocar<String>(
            opciones: tiposDocumento,
            elegida: tipo,
            etiqueta: nombreTipoDocumento,
            alElegir: (t) => setState(() => tipo = t),
          ),
          const EtiquetaCampo('Descripción (opcional)'),
          TextField(
            controller: _descripcion,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo(ayuda: 'Ej.: Escritura del lote norte'),
          ),
          const EtiquetaCampo('¿Quién lo emitió? (opcional)'),
          TextField(
            controller: _emisor,
            textCapitalization: TextCapitalization.words,
            decoration:
                decoracionCampo(ayuda: 'Escribanía, registro, organismo...'),
          ),
          const EtiquetaCampo('Número, matrícula o expediente (opcional)'),
          TextField(controller: _numero, decoration: decoracionCampo()),
          const EtiquetaCampo('Fecha de emisión (opcional)'),
          _botonFecha(
            fechaEmision == null ? 'Elegir fecha' : fechaCorta(fechaEmision!),
            () async {
              final f = await elegirFecha(fechaEmision, '¿Cuándo se emitió?');
              if (f != null) setState(() => fechaEmision = f);
            },
          ),
          const EtiquetaCampo('¿Vence? (vacío = no vence)'),
          _botonFecha(
            fechaVencimiento == null
                ? 'No vence / elegir fecha'
                : fechaCorta(fechaVencimiento!),
            () async {
              final f = await elegirFecha(
                  fechaVencimiento, '¿Hasta cuándo vale?',
                  futuro: true);
              if (f != null) setState(() => fechaVencimiento = f);
            },
          ),
          if (fechaVencimiento != null)
            TextButton(
              onPressed: () => setState(() => fechaVencimiento = null),
              child: const Text('Quitar vencimiento'),
            ),
          const EtiquetaCampo('Provincia o departamento (opcional)'),
          TextField(
            controller: _provincia,
            textCapitalization: TextCapitalization.words,
            decoration: decoracionCampo(ayuda: 'Ej.: Córdoba'),
          ),
          const EtiquetaCampo('Si se vende el campo, ¿pasa al nuevo dueño?'),
          OpcionesTocar<TransferibilidadDocumento>(
            opciones: TransferibilidadDocumento.values,
            elegida: transferibilidad,
            etiqueta: nombreTransferibilidad,
            alElegir: (t) => setState(() => transferibilidad = t),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Tiene datos personales',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
                'DNI, domicilio, etc. Se ocultan al compartir con terceros.'),
            value: contieneDatosPersonales,
            onChanged: (v) => setState(() => contieneDatosPersonales = v),
          ),
          const EtiquetaCampo('Archivo (opcional)'),
          AdjuntarArchivoBoton(
            texto: 'Adjuntar PDF o foto del documento',
            rutaActual: archivoRuta,
            subir: (nombre, bytes, tipoArchivo) => _archivos.subirArchivo(
              activoId: widget.activo.activoId,
              documentoId: documentoId,
              nombreArchivo: nombre,
              bytes: bytes,
              contentType: tipoArchivo,
            ),
            alSubir: (ruta) => setState(() => archivoRuta = ruta),
          ),
          const EtiquetaCampo('Notas (opcional)'),
          TextField(
            controller: _observaciones,
            maxLines: 2,
            decoration: decoracionCampo(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Queda como declarado (con documento si adjuntás el archivo). '
            'Los documentos no se borran: si algo cambia, cargá uno nuevo.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: EstiloProduccion.textoSuave,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: 'Guardar documento',
            ocupado: guardando,
            onPressed: guardar,
          ),
        ),
      ),
    );
  }
}
