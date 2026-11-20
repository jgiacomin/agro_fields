import 'package:cloud_firestore/cloud_firestore.dart';

/// Si un documento pasa al nuevo dueño cuando se transfiere el campo.
/// Mientras nadie lo defina, es "desconocida" (nunca se asume transferible).
enum TransferibilidadDocumento {
  transferible,
  noTransferible,
  requiereTramite,
  desconocida,
}

/// Situación del documento según su fecha de vencimiento.
enum EstadoVigenciaDocumento {
  /// El documento no vence (o no se cargó la fecha de vencimiento).
  sinVencimiento,
  vigente,

  /// Vence dentro de los próximos días de aviso.
  porVencer,
  vencido,
}

class DocumentoActivo {

  /// Días de anticipación para avisar que un documento está por vencer.
  static const int diasAvisoVencimiento = 30;

  final String documentoId;
  final String tipo;
  final String descripcion;

  /// Fecha del documento (fecha de emisión).
  final DateTime? fecha;

  final String estado;
  final String? responsableId;
  final List<String> evidenciaIds;
  final String? observaciones;

  // =====================================================
  // PASO 4a — DATOS DEL DOCUMENTO (todos opcionales)
  // =====================================================

  /// Quién emitió el documento (escribanía, registro, organismo).
  final String? emisor;

  /// Número del documento, matrícula o expediente.
  final String? numero;

  /// Hasta cuándo es válido. Si es null, no vence.
  final DateTime? fechaVencimiento;

  /// Jurisdicción del documento.
  final String? pais;
  final String? provinciaEstado;

  /// Si el documento pasa al nuevo dueño al transferir el campo.
  final TransferibilidadDocumento transferibilidad;

  /// Si tiene datos personales (DNI, domicilio, etc.) que hay que ocultar
  /// al compartir. Por privacidad, se asume que sí hasta que se indique
  /// lo contrario.
  final bool contieneDatosPersonales;

  /// Ruta del archivo en Storage (se completa en el paso 4b).
  final String? archivoRuta;

  // =====================================================
  // AF-095 — CERTIFICACIONES (opcionales, solo para el
  // tipo "certificado"). Agro Fields no certifica: guarda,
  // ordena y avisa el vencimiento.
  // =====================================================

  /// Qué certifica (ej.: "Bienestar animal Welfair", "Orgánico").
  final String? alcance;

  /// A qué animales o producción aplica (ej.: "Rodeo de engorde").
  final String? aplicaA;

  // =====================================================
  // QA Grupo C (20/11/2026) — ARCHIVAR. Un documento no se
  // borra: se archiva con fecha y motivo. Sale de la lista y
  // de los avisos, pero se conserva (trazabilidad).
  // =====================================================

  /// Si el documento está archivado. Los documentos viejos se leen
  /// como "no archivado".
  final bool archivado;

  /// Cuándo se archivó.
  final DateTime? fechaArchivo;

  /// Por qué se archivó (ej.: "Cargado por error").
  final String? motivoArchivo;

  DocumentoActivo({
    required this.documentoId,
    required this.tipo,
    required this.descripcion,
    this.fecha,
    required this.estado,
    this.responsableId,
    required this.evidenciaIds,
    this.observaciones,
    this.emisor,
    this.numero,
    this.fechaVencimiento,
    this.pais,
    this.provinciaEstado,
    this.transferibilidad = TransferibilidadDocumento.desconocida,
    this.contieneDatosPersonales = true,
    this.archivoRuta,
    this.alcance,
    this.aplicaA,
    this.archivado = false,
    this.fechaArchivo,
    this.motivoArchivo,
  });

  /// Devuelve una copia archivada, con fecha y motivo.
  DocumentoActivo archivar(String motivo, {DateTime? fecha}) {
    return copyWith(
      archivado: true,
      fechaArchivo: fecha ?? DateTime.now(),
      motivoArchivo: motivo,
    );
  }

  /// Devuelve una copia que vuelve a la lista. La fecha y el motivo del
  /// archivo quedan en el historial del campo.
  DocumentoActivo desarchivar() {
    return DocumentoActivo(
      documentoId: documentoId,
      tipo: tipo,
      descripcion: descripcion,
      fecha: fecha,
      estado: estado,
      responsableId: responsableId,
      evidenciaIds: evidenciaIds,
      observaciones: observaciones,
      emisor: emisor,
      numero: numero,
      fechaVencimiento: fechaVencimiento,
      pais: pais,
      provinciaEstado: provinciaEstado,
      transferibilidad: transferibilidad,
      contieneDatosPersonales: contieneDatosPersonales,
      archivoRuta: archivoRuta,
      alcance: alcance,
      aplicaA: aplicaA,
    );
  }

  /// Dice si el documento está vigente, por vencer o vencido.
  /// Es la base de las alertas de vencimiento.
  EstadoVigenciaDocumento estadoVigencia({
    DateTime? hoy,
    int diasAviso = diasAvisoVencimiento,
  }) {
    final vencimiento = fechaVencimiento;

    if (vencimiento == null) {
      return EstadoVigenciaDocumento.sinVencimiento;
    }

    final ahora = hoy ?? DateTime.now();

    if (ahora.isAfter(vencimiento)) {
      return EstadoVigenciaDocumento.vencido;
    }

    final limiteAviso = ahora.add(Duration(days: diasAviso));

    if (!vencimiento.isAfter(limiteAviso)) {
      return EstadoVigenciaDocumento.porVencer;
    }

    return EstadoVigenciaDocumento.vigente;
  }

  factory DocumentoActivo.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return DocumentoActivo(
      documentoId: id,
      tipo: map['tipo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fecha: _leerFecha(map['fecha']),
      estado: map['estado'] ?? 'pendiente',
      responsableId: map['responsableId'],
      evidenciaIds: List<String>.from(
        map['evidenciaIds'] ?? [],
      ),
      observaciones: map['observaciones'],
      emisor: map['emisor'],
      numero: map['numero'],
      fechaVencimiento: _leerFecha(map['fechaVencimiento']),
      pais: map['pais'],
      provinciaEstado: map['provinciaEstado'],
      transferibilidad: _leerTransferibilidad(map['transferibilidad']),
      contieneDatosPersonales: map['contieneDatosPersonales'] ?? true,
      archivoRuta: map['archivoRuta'],
      alcance: map['alcance'],
      aplicaA: map['aplicaA'],
      archivado: map['archivado'] == true,
      fechaArchivo: _leerFecha(map['fechaArchivo']),
      motivoArchivo: map['motivoArchivo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentoId': documentoId,
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha': fecha != null
          ? Timestamp.fromDate(fecha!)
          : null,
      'estado': estado,
      'responsableId': responsableId,
      'evidenciaIds': evidenciaIds,
      'observaciones': observaciones,
      'emisor': emisor,
      'numero': numero,
      'fechaVencimiento': fechaVencimiento != null
          ? Timestamp.fromDate(fechaVencimiento!)
          : null,
      'pais': pais,
      'provinciaEstado': provinciaEstado,
      'transferibilidad': transferibilidad.name,
      'contieneDatosPersonales': contieneDatosPersonales,
      'archivoRuta': archivoRuta,
      'alcance': alcance,
      'aplicaA': aplicaA,
      'archivado': archivado,
      'fechaArchivo': fechaArchivo != null
          ? Timestamp.fromDate(fechaArchivo!)
          : null,
      'motivoArchivo': motivoArchivo,
    };
  }

  DocumentoActivo copyWith({
    String? documentoId,
    String? tipo,
    String? descripcion,
    DateTime? fecha,
    String? estado,
    String? responsableId,
    List<String>? evidenciaIds,
    String? observaciones,
    String? emisor,
    String? numero,
    DateTime? fechaVencimiento,
    String? pais,
    String? provinciaEstado,
    TransferibilidadDocumento? transferibilidad,
    bool? contieneDatosPersonales,
    String? archivoRuta,
    String? alcance,
    String? aplicaA,
    bool? archivado,
    DateTime? fechaArchivo,
    String? motivoArchivo,
  }) {
    return DocumentoActivo(
      documentoId: documentoId ?? this.documentoId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      responsableId: responsableId ?? this.responsableId,
      evidenciaIds: evidenciaIds ?? this.evidenciaIds,
      observaciones: observaciones ?? this.observaciones,
      emisor: emisor ?? this.emisor,
      numero: numero ?? this.numero,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      pais: pais ?? this.pais,
      provinciaEstado: provinciaEstado ?? this.provinciaEstado,
      transferibilidad: transferibilidad ?? this.transferibilidad,
      contieneDatosPersonales:
          contieneDatosPersonales ?? this.contieneDatosPersonales,
      archivoRuta: archivoRuta ?? this.archivoRuta,
      alcance: alcance ?? this.alcance,
      aplicaA: aplicaA ?? this.aplicaA,
      archivado: archivado ?? this.archivado,
      fechaArchivo: fechaArchivo ?? this.fechaArchivo,
      motivoArchivo: motivoArchivo ?? this.motivoArchivo,
    );
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }
    if (valor is DateTime) {
      return valor;
    }
    if (valor is String) {
      return DateTime.tryParse(valor);
    }
    return null;
  }

  /// Un valor desconocido o vacío se lee como "desconocida":
  /// nunca se asume que un documento es transferible.
  static TransferibilidadDocumento _leerTransferibilidad(dynamic valor) {
    for (final opcion in TransferibilidadDocumento.values) {
      if (opcion.name == valor) {
        return opcion;
      }
    }
    return TransferibilidadDocumento.desconocida;
  }
}
