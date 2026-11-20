import 'package:flutter/material.dart';

import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/activos/documentacion_activo_model.dart';
import '../../models/activos/documento_activo_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../operaciones/operaciones_textos.dart';
import '../produccion/produccion_estilo.dart';
import 'nuevo_documento_screen.dart';
import '../../widgets/barra_campo.dart';
import '../../widgets/ver_archivo_boton.dart';

/// Tipos de documento que se ofrecen para elegir tocando.
const List<String> tiposDocumento = [
  'escritura',
  'mensura',
  'permiso',
  'bosques_nativos',
  'arrendamiento',
  'certificado',
  'otro',
];

String nombreTipoDocumento(String tipo) {
  switch (tipo) {
    case 'escritura':
      return 'Escritura';
    case 'mensura':
      return 'Mensura o plano';
    case 'permiso':
      return 'Permiso o habilitación';
    case 'bosques_nativos':
      return 'Bosques nativos / OTBN';
    case 'arrendamiento':
      return 'Contrato de arrendamiento';
    case 'certificado':
      // AF-095: se reutiliza el tipo existente (sin crear otro).
      return 'Certificación o certificado';
    case 'otro':
      return 'Otro';
  }
  if (tipo.isEmpty) return 'Documento';
  return tipo[0].toUpperCase() + tipo.substring(1);
}

String nombreTransferibilidad(TransferibilidadDocumento t) {
  switch (t) {
    case TransferibilidadDocumento.transferible:
      return 'Sí, pasa';
    case TransferibilidadDocumento.noTransferible:
      return 'No pasa';
    case TransferibilidadDocumento.requiereTramite:
      return 'Requiere trámite';
    case TransferibilidadDocumento.desconocida:
      return 'No sé';
  }
}

/// Pantalla 1 (paso 4b, pantalla pendiente): los documentos del campo.
/// Arriba, los vencidos y por vencer (aviso de 30 dias, paso 4a).
class DocumentosActivoScreen extends StatefulWidget {
  final String activoAgroId;
  final String nombreActivo;

  const DocumentosActivoScreen({
    super.key,
    required this.activoAgroId,
    required this.nombreActivo,
  });

  @override
  State<DocumentosActivoScreen> createState() => _DocumentosActivoScreenState();
}

class _DocumentosActivoScreenState extends State<DocumentosActivoScreen> {
  final ActivoAgroServiceV2 _activos = ActivoAgroServiceV2();

  bool cargando = true;
  bool guardando = false;
  String? error;
  ActivoAgroV2? activo;

  /// QA Grupo C (20/11/2026): motivos para archivar, para elegir tocando.
  static const List<String> motivosArchivo = [
    'Cargado por error',
    'Reemplazado por uno nuevo',
    'Ya no corresponde',
    'Otro',
  ];

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
      final leido = await _activos.obtenerActivoPorId(widget.activoAgroId);
      if (!mounted) return;
      setState(() {
        activo = leido;
        cargando = false;
        if (leido == null) error = 'No se encontró el campo.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'No se pudieron cargar los documentos: $e';
        cargando = false;
      });
    }
  }

  Future<void> nuevo() async {
    final a = activo;
    if (a == null) return;
    final guardo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NuevoDocumentoScreen(activo: a)),
    );
    if (guardo == true) await cargar();
  }

  /// QA Grupo C (20/11/2026): pregunta el motivo antes de archivar.
  Future<String?> _pedirMotivo(DocumentoActivo d) {
    String? elegido;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogo) => AlertDialog(
          title: Text('¿Archivar "${_nombre(d)}"?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No se borra: queda en "Archivados" y en el historial del '
                'campo. Deja de avisar el vencimiento.',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Por qué lo archivás?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              OpcionesTocar<String>(
                opciones: motivosArchivo,
                elegida: elegido,
                etiqueta: (m) => m,
                alElegir: (m) => setDialogo(() => elegido = m),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: elegido == null
                  ? null
                  : () => Navigator.of(ctx).pop(elegido),
              child: const Text('Archivar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> archivar(DocumentoActivo d) async {
    final motivo = await _pedirMotivo(d);
    if (motivo == null) return;
    await _cambiarArchivo(d, motivo: motivo);
  }

  /// Archiva (con motivo) o vuelve a la lista (sin motivo). Se relee el
  /// campo para no pisar documentos cargados mientras tanto. El historial
  /// del campo guarda el antes y el después.
  Future<void> _cambiarArchivo(DocumentoActivo d, {String? motivo}) async {
    setState(() => guardando = true);
    try {
      final actual = await _activos.obtenerActivoPorId(widget.activoAgroId);
      if (actual == null) throw Exception('No se encontró el campo.');
      final doc = actual.documentacion;

      final nueva = DocumentacionActivo(
        documentacionCompleta: doc.documentacionCompleta,
        documentos: doc.documentos,
        certificaciones: doc.certificaciones,
        permisos: doc.permisos,
        archivos: doc.archivos,
        documentosEstructurados: [
          for (final x in doc.documentosEstructurados)
            if (x.documentoId != d.documentoId)
              x
            else if (motivo != null)
              x.archivar(motivo)
            else
              x.desarchivar(),
        ],
        observaciones: doc.observaciones,
        fechaActualizacion: DateTime.now(),
      );

      await _activos.actualizarDocumentacion(actual.activoId, nueva);
      if (!mounted) return;
      setState(() => guardando = false);
      _avisar(motivo != null
          ? 'Documento archivado.'
          : 'El documento volvió a la lista.');
      await cargar();
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
    final todos = [...?activo?.documentacion.documentosEstructurados];
    // QA Grupo C: los archivados van aparte y no avisan.
    final documentos = todos.where((d) => !d.archivado).toList()
      ..sort((a, b) => _orden(a).compareTo(_orden(b)));
    final archivados = todos.where((d) => d.archivado).toList();

    final avisos = documentos.where((d) {
      final e = d.estadoVigencia();
      return e == EstadoVigenciaDocumento.vencido ||
          e == EstadoVigenciaDocumento.porVencer;
    }).toList();

    return Scaffold(
      appBar: BarraCampo(
        title: const Text('Documentos'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        BotonGrande(texto: 'Reintentar', onPressed: cargar),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        '${widget.nombreActivo} · ${documentos.length} '
                        '${documentos.length == 1 ? 'documento' : 'documentos'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: EstiloProduccion.textoSuave,
                        ),
                      ),
                      if (avisos.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const TituloSeccion('Necesita atención', icono: Icons.warning_amber_rounded),
                        for (final d in avisos)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Aviso(
                              '${_nombre(d)}: '
                              '${d.estadoVigencia() == EstadoVigenciaDocumento.vencido ? 'vencido' : 'vence'}'
                              ' el ${fechaCorta(d.fechaVencimiento!)}',
                              grave: d.estadoVigencia() ==
                                  EstadoVigenciaDocumento.vencido,
                            ),
                          ),
                      ],
                      const SizedBox(height: 20),
                      const TituloSeccion('Documentos del campo', icono: Icons.description_outlined),
                      if (documentos.isEmpty)
                        const Text(
                          'Todavía no hay documentos. Cargá la escritura, la '
                          'mensura, los permisos o lo que tengas: el sistema '
                          'te avisa cuando algo está por vencer.',
                          style: TextStyle(
                            color: EstiloProduccion.textoSuave,
                            height: 1.4,
                          ),
                        ),
                      ...documentos.map(_tarjeta),
                      if (archivados.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _seccionArchivados(archivados),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Nuevo documento',
            onPressed:
                cargando || guardando || activo == null ? null : nuevo,
          ),
        ),
      ),
    );
  }

  /// Primero los vencidos, despues los por vencer, despues el resto.
  int _orden(DocumentoActivo d) {
    switch (d.estadoVigencia()) {
      case EstadoVigenciaDocumento.vencido:
        return 0;
      case EstadoVigenciaDocumento.porVencer:
        return 1;
      case EstadoVigenciaDocumento.vigente:
        return 2;
      case EstadoVigenciaDocumento.sinVencimiento:
        return 3;
    }
  }

  String _nombre(DocumentoActivo d) =>
      d.descripcion.trim().isEmpty ? nombreTipoDocumento(d.tipo) : d.descripcion;

  Widget _tarjeta(DocumentoActivo d) {
    final vigencia = d.estadoVigencia();
    final (textoVigencia, color) = switch (vigencia) {
      EstadoVigenciaDocumento.vencido => (
          'Vencido el ${fechaCorta(d.fechaVencimiento!)}',
          EstiloProduccion.rojo
        ),
      EstadoVigenciaDocumento.porVencer => (
          'Vence el ${fechaCorta(d.fechaVencimiento!)}',
          amarillo
        ),
      EstadoVigenciaDocumento.vigente => (
          'Vigente hasta ${fechaCorta(d.fechaVencimiento!)}',
          EstiloProduccion.verde
        ),
      EstadoVigenciaDocumento.sinVencimiento => (
          'No vence',
          EstiloProduccion.textoSuave
        ),
    };

    final detalle = [
      // Si no hay descripcion, el titulo ya es el tipo: no se repite.
      if (_nombre(d) != nombreTipoDocumento(d.tipo)) nombreTipoDocumento(d.tipo),
      if (d.alcance != null) d.alcance!,
      if (d.aplicaA != null) 'Aplica a: ${d.aplicaA}',
      if (d.emisor != null) d.emisor!,
      if (d.numero != null) 'Nº ${d.numero}',
      if (d.provinciaEstado != null) d.provinciaEstado!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TarjetaBlanca(
        colorBorde: vigencia == EstadoVigenciaDocumento.vencido ||
                vigencia == EstadoVigenciaDocumento.porVencer
            ? color
            : EstiloProduccion.borde,
        child: FilaConIcono(
          icono: Icons.description_outlined,
          color: color,
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nombre(d),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              if (detalle.isNotEmpty) const SizedBox(height: 4),
              if (detalle.isNotEmpty)
                Text(
                detalle,
                style: const TextStyle(
                  fontSize: 14,
                  color: EstiloProduccion.textoSuave,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                textoVigencia,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                [
                  d.archivoRuta == null ? 'Sin archivo' : 'Con archivo',
                  'Al vender: ${nombreTransferibilidad(d.transferibilidad).toLowerCase()}',
                  if (d.contieneDatosPersonales) 'Tiene datos personales',
                ].join(' · '),
                style: const TextStyle(
                  fontSize: 13,
                  color: EstiloProduccion.textoSuave,
                ),
              ),
              if (d.archivoRuta != null)
                VerArchivoBoton(ruta: d.archivoRuta!),
              // QA Grupo C: archivar en vez de borrar.
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: guardando ? null : () => archivar(d),
                  icon: const Icon(Icons.archive_outlined, size: 18),
                  label: const Text('Archivar'),
                  style: TextButton.styleFrom(
                    foregroundColor: EstiloProduccion.textoSuave,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  /// QA Grupo C: sección cerrada con los documentos archivados.
  Widget _seccionArchivados(List<DocumentoActivo> archivados) {
    return TarjetaBlanca(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.archive_outlined,
              color: EstiloProduccion.textoSuave),
          title: Text(
            'Archivados (${archivados.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'No avisan vencimientos. Se conservan por trazabilidad.',
            style: TextStyle(fontSize: 13, color: EstiloProduccion.textoSuave),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            for (final d in archivados) _filaArchivado(d),
          ],
        ),
      ),
    );
  }

  Widget _filaArchivado(DocumentoActivo d) {
    final cuando = d.fechaArchivo != null
        ? 'Archivado el ${fechaCorta(d.fechaArchivo!)}'
        : 'Archivado';
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _nombre(d),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            [
              cuando,
              if (d.motivoArchivo != null) d.motivoArchivo!,
            ].join(' · '),
            style: const TextStyle(
                fontSize: 13, color: EstiloProduccion.textoSuave),
          ),
          if (d.archivoRuta != null) VerArchivoBoton(ruta: d.archivoRuta!),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: guardando ? null : () => _cambiarArchivo(d),
              icon: const Icon(Icons.unarchive_outlined, size: 18),
              label: const Text('Volver a la lista'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ),
        ],
      ),
    );
  }
}
