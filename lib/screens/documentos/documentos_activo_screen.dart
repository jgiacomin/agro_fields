import 'package:flutter/material.dart';

import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/activos/documento_activo_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../operaciones/operaciones_textos.dart';
import '../produccion/produccion_estilo.dart';
import 'nuevo_documento_screen.dart';

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
      return 'Certificado';
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
  String? error;
  ActivoAgroV2? activo;

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

  @override
  Widget build(BuildContext context) {
    final documentos = [
      ...?activo?.documentacion.documentosEstructurados,
    ]..sort((a, b) => _orden(a).compareTo(_orden(b)));

    final avisos = documentos.where((d) {
      final e = d.estadoVigencia();
      return e == EstadoVigenciaDocumento.vencido ||
          e == EstadoVigenciaDocumento.porVencer;
    }).toList();

    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
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
                        const TituloSeccion('Necesita atención'),
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
                      const TituloSeccion('Documentos del campo'),
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
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BotonGrande(
            texto: '+ Nuevo documento',
            onPressed: cargando || activo == null ? null : nuevo,
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
      nombreTipoDocumento(d.tipo),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nombre(d),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
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
            ],
          ),
        ),
      ),
    );
  }
}
