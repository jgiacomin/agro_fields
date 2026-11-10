import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activos/evento_operacion_model.dart';
import '../../models/activos/operacion_protegida_model.dart';
import '../../services/control_operacion.dart';
import '../../services/documento_archivo_service.dart';
import '../../services/operacion_service.dart';
import '../../widgets/adjuntar_archivo_boton.dart';
import '../produccion/produccion_estilo.dart';
import 'operaciones_textos.dart';

/// Pantalla 4 (paso 7a-3, GAP-OPER-01): registrar lo que paso.
/// Paso 1: ¿que paso? (seis botones grandes).
/// Paso 2: solo los datos de ese tipo.
/// Queda "declarado" y no se borra: un error se corrige con otro evento.
class RegistrarEventoOperacionScreen extends StatefulWidget {
  final OperacionProtegida operacion;

  /// Pagos ya calculados (para elegir cual se cobro o se rechazo).
  final List<PagoCalculado> pagos;

  /// Para entrar directo a un tipo (ej.: "Cobrado" desde un cheque).
  final TipoEventoOperacion? tipoInicial;
  final String? pagoInicialId;

  const RegistrarEventoOperacionScreen({
    super.key,
    required this.operacion,
    required this.pagos,
    this.tipoInicial,
    this.pagoInicialId,
  });

  @override
  State<RegistrarEventoOperacionScreen> createState() =>
      _RegistrarEventoOperacionScreenState();
}

class _RegistrarEventoOperacionScreenState
    extends State<RegistrarEventoOperacionScreen> {
  final OperacionService _servicio = OperacionService();
  final DocumentoArchivoService _archivos = DocumentoArchivoService();

  final TextEditingController _importe = TextEditingController();
  final TextEditingController _banco = TextEditingController();
  final TextEditingController _numero = TextEditingController();
  final TextEditingController _librador = TextEditingController();
  final TextEditingController _cuitLibrador = TextEditingController();
  final TextEditingController _cantidad = TextEditingController();
  final TextEditingController _motivoOtro = TextEditingController();
  final TextEditingController _observaciones = TextEditingController();

  /// ID armado al abrir la pantalla: tocar "Guardar" dos veces no duplica.
  late final String eventoId = _servicio.nuevoIdEvento();

  TipoEventoOperacion? tipo;
  MedioPago? medio;
  DateTime fecha = DateTime.now();
  DateTime? vencimiento;
  String? pagoId;
  String? motivo;
  late String unidad;
  final List<String> archivos = [];
  bool guardando = false;

  static const motivosRechazo = [
    'sin fondos',
    'firma no coincide',
    'cuenta cerrada',
    'orden de no pagar',
    'otro',
  ];

  static const opciones = [
    (TipoEventoOperacion.pagoAcordado, 'Cargar un cheque, eCheq o pago con su fecha'),
    (TipoEventoOperacion.entrega, 'Se entregaron animales, granos u otro producto'),
    (TipoEventoOperacion.cobro, 'Un cheque o pago se cobró'),
    (TipoEventoOperacion.rechazo, 'Un cheque rebotó'),
    (TipoEventoOperacion.incumplimiento, 'El comprador no cumplió algo'),
    (TipoEventoOperacion.nota, 'Un comentario o dato para que quede registrado'),
  ];

  OperacionProtegida get op => widget.operacion;

  /// Pagos que todavia se pueden cobrar o rechazar.
  List<PagoCalculado> get pagosAbiertos =>
      widget.pagos.where((p) => p.estado != EstadoPago.cobrado).toList();

  @override
  void initState() {
    super.initState();
    tipo = widget.tipoInicial;
    pagoId = widget.pagoInicialId;
    unidad = op.unidad ?? 'cabezas';
    if (op.formaPago == FormaPagoOperacion.echeq) medio = MedioPago.echeq;
    if (op.formaPago == FormaPagoOperacion.cheque) medio = MedioPago.cheque;
    if (op.formaPago == FormaPagoOperacion.transferencia) {
      medio = MedioPago.transferencia;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _importe,
      _banco,
      _numero,
      _librador,
      _cuitLibrador,
      _cantidad,
      _motivoOtro,
      _observaciones,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? texto(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(hoy.year - 5),
      lastDate: hoy,
      helpText: '¿Cuándo pasó?',
    );
    if (elegida == null) return;
    final esHoy = elegida.year == hoy.year &&
        elegida.month == hoy.month &&
        elegida.day == hoy.day;
    setState(() => fecha = esHoy ? hoy : elegida);
  }

  Future<void> elegirVencimiento() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: vencimiento ?? hoy,
      firstDate: DateTime(hoy.year - 2),
      lastDate: DateTime(hoy.year + 3),
      helpText: '¿Cuándo vence o se paga?',
    );
    if (elegida == null) return;
    setState(() => vencimiento = elegida);
  }

  Future<void> guardar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _avisar('Tenés que iniciar sesión.');
      return;
    }

    double? importe;
    if (_importe.text.trim().isNotEmpty) {
      importe = leerNumero(_importe.text);
      if (importe == null) {
        _avisar('El importe tiene que ser un número.');
        return;
      }
    }
    double? cantidad;
    if (_cantidad.text.trim().isNotEmpty) {
      cantidad = leerNumero(_cantidad.text);
      if (cantidad == null) {
        _avisar('La cantidad tiene que ser un número.');
        return;
      }
    }

    final t = tipo!;
    final esPago = t == TipoEventoOperacion.pagoAcordado;
    final esCobroORechazo =
        t == TipoEventoOperacion.cobro || t == TipoEventoOperacion.rechazo;
    final ahora = DateTime.now();

    final evento = EventoOperacion(
      eventoId: eventoId,
      operacionId: op.operacionId,
      activoAgroId: op.activoAgroId,
      tipo: t,
      fechaHecho: fecha.isAfter(ahora) ? ahora : fecha,
      fechaCarga: ahora,
      cargadoPor: uid,
      archivoRutas: List.of(archivos),
      observaciones: texto(_observaciones),
      medioPago: esPago ? medio : null,
      importe: (esPago || t == TipoEventoOperacion.cobro) ? importe : null,
      moneda: esPago ? op.moneda : null,
      fechaVencimiento: esPago ? vencimiento : null,
      banco: esPago ? texto(_banco) : null,
      numero: esPago ? texto(_numero) : null,
      libradorNombre: esPago ? texto(_librador) : null,
      libradorIdentificacionFiscal: esPago ? texto(_cuitLibrador) : null,
      cantidad: t == TipoEventoOperacion.entrega ? cantidad : null,
      unidad: t == TipoEventoOperacion.entrega ? unidad : null,
      pagoEventoId: esCobroORechazo ? pagoId : null,
      motivoRechazo: t == TipoEventoOperacion.rechazo
          ? (motivo == 'otro' ? texto(_motivoOtro) : motivo)
          : null,
    );

    final errores = evento.validar();
    if (errores.isNotEmpty) {
      _avisar(errores.join(' '));
      return;
    }

    setState(() => guardando = true);
    try {
      await _servicio.registrarEvento(evento);
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
    final elegido = tipo;

    return Scaffold(
      backgroundColor: EstiloProduccion.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: EstiloProduccion.texto,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: elegido == null ? 'Volver' : 'Cambiar qué pasó',
          onPressed: () {
            if (elegido == null || widget.tipoInicial != null) {
              Navigator.of(context).pop(false);
            } else {
              setState(() => tipo = null);
            }
          },
        ),
        title: Text(elegido == null
            ? '¿Qué pasó?'
            : nombreTipoEventoOperacion(elegido)),
      ),
      body: elegido == null ? _paso1() : _paso2(elegido),
      bottomNavigationBar: elegido == null
          ? null
          : SafeArea(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: BotonGrande(
                  texto: 'Guardar',
                  ocupado: guardando,
                  onPressed: guardar,
                ),
              ),
            ),
    );
  }

  Widget _paso1() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final (opcion, explicacion) in opciones)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TarjetaBlanca(
              onTap: () => setState(() => tipo = opcion),
              child: Container(
                constraints: const BoxConstraints(minHeight: 72),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            nombreTipoEventoOperacion(opcion),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            explicacion,
                            style: const TextStyle(
                              fontSize: 14,
                              color: EstiloProduccion.textoSuave,
                            ),
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
    );
  }

  Widget _paso2(TipoEventoOperacion elegido) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        if (elegido == TipoEventoOperacion.pagoAcordado) ..._camposPago(),
        if (elegido == TipoEventoOperacion.entrega) ..._camposEntrega(),
        if (elegido == TipoEventoOperacion.cobro) ..._camposCobro(),
        if (elegido == TipoEventoOperacion.rechazo) ..._camposRechazo(),
        EtiquetaCampo(elegido == TipoEventoOperacion.incumplimiento ||
                elegido == TipoEventoOperacion.nota
            ? '¿Qué pasó?'
            : 'Notas (opcional)'),
        TextField(
          controller: _observaciones,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: decoracionCampo(),
        ),
        const EtiquetaCampo('¿Cuándo pasó?'),
        _botonFecha(fechaCorta(fecha), elegirFecha),
        const EtiquetaCampo('Foto o comprobante (opcional)'),
        AdjuntarArchivoBoton(
          texto: elegido == TipoEventoOperacion.pagoAcordado
              ? 'Adjuntar foto del cheque'
              : 'Adjuntar foto o PDF',
          subir: (nombre, bytes, tipoArchivo) =>
              _archivos.subirArchivoOperacion(
            activoId: op.activoAgroId,
            operacionId: op.operacionId,
            nombreArchivo: nombre,
            bytes: bytes,
            contentType: tipoArchivo,
          ),
          alSubir: (ruta) => setState(() => archivos.add(ruta)),
        ),
        const SizedBox(height: 18),
        const Text(
          'Queda como declarado. Si después algo está mal, se corrige con '
          'otro registro: este no se borra.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: EstiloProduccion.textoSuave,
          ),
        ),
      ],
    );
  }

  List<Widget> _camposPago() {
    final esCheque = medio == MedioPago.cheque || medio == MedioPago.echeq;
    return [
      const EtiquetaCampo('Medio de pago'),
      OpcionesTocar<MedioPago>(
        opciones: MedioPago.values,
        elegida: medio,
        etiqueta: nombreMedioPago,
        alElegir: (m) => setState(() => medio = m),
      ),
      EtiquetaCampo('Importe (${op.moneda})'),
      TextField(
        controller: _importe,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: decoracionCampo(ayuda: 'Ej.: 5000000'),
      ),
      EtiquetaCampo(esCheque ? 'Fecha de cobro del cheque' : 'Fecha de pago'),
      _botonFecha(
        vencimiento == null ? 'Elegir fecha' : fechaCorta(vencimiento!),
        elegirVencimiento,
      ),
      if (esCheque) ...[
        const EtiquetaCampo('Número del cheque'),
        TextField(
          controller: _numero,
          keyboardType: TextInputType.number,
          decoration: decoracionCampo(ayuda: 'Ej.: 00012345'),
        ),
      ],
      const EtiquetaCampo('Banco (opcional)'),
      TextField(
        controller: _banco,
        textCapitalization: TextCapitalization.words,
        decoration: decoracionCampo(),
      ),
      if (esCheque) ...[
        const EtiquetaCampo('¿Quién libró el cheque? (opcional)'),
        TextField(
          controller: _librador,
          textCapitalization: TextCapitalization.words,
          decoration: decoracionCampo(ayuda: 'Puede ser otro que el comprador'),
        ),
        const EtiquetaCampo('CUIT / RUC de quien lo libró (opcional)'),
        TextField(
          controller: _cuitLibrador,
          keyboardType: TextInputType.number,
          decoration: decoracionCampo(),
        ),
      ],
    ];
  }

  List<Widget> _camposEntrega() {
    return [
      const EtiquetaCampo('¿Cuánto se entregó?'),
      TextField(
        controller: _cantidad,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: decoracionCampo(ayuda: 'Ej.: 40'),
      ),
      const SizedBox(height: 10),
      OpcionesTocar<String>(
        opciones: {unidad, 'cabezas', 'kg', 'toneladas', 'unidades'}.toList(),
        elegida: unidad,
        etiqueta: (u) => u,
        alElegir: (u) => setState(() => unidad = u),
      ),
    ];
  }

  List<Widget> _elegirPago(String titulo) {
    if (pagosAbiertos.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 18),
          child: Aviso('No hay cheques ni pagos pendientes en esta operación. '
              'Primero cargá el cheque o pago.'),
        ),
      ];
    }
    return [
      EtiquetaCampo(titulo),
      OpcionesTocar<String>(
        opciones: pagosAbiertos.map((p) => p.pago.eventoId).toList(),
        elegida: pagoId,
        etiqueta: (id) {
          final p = pagosAbiertos.firstWhere((x) => x.pago.eventoId == id);
          final numero = p.pago.numero == null ? '' : ' Nº ${p.pago.numero}';
          return '${nombreMedioPago(p.pago.medioPago ?? MedioPago.otro)}'
              '$numero · ${formatoImporte(p.importe, op.moneda)} · '
              '${fechaCorta(p.pago.fechaVencimiento!)}';
        },
        alElegir: (id) => setState(() => pagoId = id),
      ),
    ];
  }

  List<Widget> _camposCobro() {
    return [
      ..._elegirPago('¿Qué se cobró?'),
      const EtiquetaCampo('Importe cobrado (vacío = todo)'),
      TextField(
        controller: _importe,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: decoracionCampo(ayuda: 'Solo si se cobró una parte'),
      ),
    ];
  }

  List<Widget> _camposRechazo() {
    return [
      ..._elegirPago('¿Qué cheque rebotó?'),
      const EtiquetaCampo('Motivo'),
      OpcionesTocar<String>(
        opciones: motivosRechazo,
        elegida: motivo,
        etiqueta: (m) => m[0].toUpperCase() + m.substring(1),
        alElegir: (m) => setState(() => motivo = m),
      ),
      if (motivo == 'otro') ...[
        const EtiquetaCampo('¿Cuál?'),
        TextField(
          controller: _motivoOtro,
          decoration: decoracionCampo(),
        ),
      ],
    ];
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
