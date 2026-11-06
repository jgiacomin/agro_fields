import 'package:cloud_firestore/cloud_firestore.dart';

/// Permisos atómicos de una autorización sobre un Activo Agro.
enum PermisoAutorizacion {
  ver,
  crear,
  modificar,
  compartir,
  verificar,
  publicar,
  exportar,
  revocar,
  adminPart,
}

/// Roles contextuales dentro de una autorización.
enum RolAutorizacion {
  propietario,
  arrendatario,
  broker,
  comprador,
  inversor,
  verificador,
  administrador,
  encargado,
  profesional,
}

/// Estados del ciclo de vida de una autorización.
enum EstadoAutorizacion {
  pendiente,
  activa,
  suspendida,
  vencida,
  revocada,
  finalizada,
  rechazada,
}

/// Modalidad de representación cuando corresponde.
enum ModalidadRepresentacion {
  exclusiva,
  noExclusiva,
  conjunta,
  porZona,
  porPeriodo,
  porOperacion,
  porMercado,
}

/// Tipos de ámbito funcional de una autorización.
enum TipoAmbitoAutorizacion {
  identidad,
  titularidad,
  expedienteProductivo,
  trabajo,
  recursosInventario,
  planificacionProgramacion,
  monitoreo,
  aplicaciones,
  economia,
  mantenimiento,
  riesgosAlertas,
  documentacion,
  evidencias,
  historial,
  marketplace,
  datosPrivados,
  participantesAccesos,
}

/// Tipo de exclusividad comercial.
enum TipoExclusividadAutorizacion {
  general,
  venta,
  alquiler,
  zona,
  periodo,
  operacion,
  mercado,
}

/// Ámbito funcional de una autorización.
class AmbitoAutorizacion {
  final TipoAmbitoAutorizacion tipo;
  final String? referenciaId;
  final String? descripcion;

  const AmbitoAutorizacion({
    required this.tipo,
    this.referenciaId,
    this.descripcion,
  });

  factory AmbitoAutorizacion.fromMap(Map<String, dynamic> map) {
    return AmbitoAutorizacion(
      tipo: _tipoAmbitoDesdeString(map['tipo']),
      referenciaId: map['referenciaId'] as String?,
      descripcion: map['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo.name,
      'referenciaId': referenciaId,
      'descripcion': descripcion,
    };
  }

  AmbitoAutorizacion copyWith({
    TipoAmbitoAutorizacion? tipo,
    String? referenciaId,
    String? descripcion,
  }) {
    return AmbitoAutorizacion(
      tipo: tipo ?? this.tipo,
      referenciaId: referenciaId ?? this.referenciaId,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  static TipoAmbitoAutorizacion _tipoAmbitoDesdeString(dynamic valor) {
    final encontrado = TipoAmbitoAutorizacion.values.where(
      (item) => item.name == valor,
    );

    if (encontrado.isEmpty) {
      throw FormatException(
        'TipoAmbitoAutorizacion inválido: $valor',
      );
    }

    return encontrado.first;
  }
}

/// Estados del ciclo de vida de una evidencia de autorización.
enum EstadoEvidenciaAutorizacion {
  informada,
  presentada,
  enRevision,
  verificada,
  observada,
  rechazada,
  vencida,
  reemplazada,
}

/// Evidencia que respalda una autorización.
class EvidenciaAutorizacion {
  final String tipo;
  final String? referenciaId;
  final String? descripcion;
  final EstadoEvidenciaAutorizacion estado;

  const EvidenciaAutorizacion({
    required this.tipo,
    this.referenciaId,
    this.descripcion,
    this.estado = EstadoEvidenciaAutorizacion.presentada,
  });

  factory EvidenciaAutorizacion.fromMap(Map<String, dynamic> map) {
    return EvidenciaAutorizacion(
      tipo: map['tipo'] as String? ?? '',
      referenciaId: map['referenciaId'] as String?,
      descripcion: map['descripcion'] as String?,
      estado: _estadoDesdeString(map['estado']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'referenciaId': referenciaId,
      'descripcion': descripcion,
      'estado': estado.name,
    };
  }

  EvidenciaAutorizacion copyWith({
    String? tipo,
    String? referenciaId,
    String? descripcion,
    EstadoEvidenciaAutorizacion? estado,
  }) {
    return EvidenciaAutorizacion(
      tipo: tipo ?? this.tipo,
      referenciaId: referenciaId ?? this.referenciaId,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
    );
  }

  static EstadoEvidenciaAutorizacion _estadoDesdeString(dynamic valor) {
    if (valor == null) {
      return EstadoEvidenciaAutorizacion.presentada;
    }

    final encontrado = EstadoEvidenciaAutorizacion.values.where(
      (item) => item.name == valor,
    );

    if (encontrado.isEmpty) {
      throw FormatException(
        'EstadoEvidenciaAutorizacion inválido: $valor',
      );
    }

    return encontrado.first;
  }
}

/// Condición de exclusividad asociada a una autorización.
class ExclusividadAutorizacion {
  final bool activa;
  final TipoExclusividadAutorizacion? tipo;
  final String? alcance;

  const ExclusividadAutorizacion({
    required this.activa,
    this.tipo,
    this.alcance,
  });

  factory ExclusividadAutorizacion.fromMap(Map<String, dynamic> map) {
    return ExclusividadAutorizacion(
      activa: map['activa'] as bool? ?? false,
      tipo: _tipoExclusividadDesdeString(map['tipo']),
      alcance: map['alcance'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activa': activa,
      'tipo': tipo?.name,
      'alcance': alcance,
    };
  }

  ExclusividadAutorizacion copyWith({
    bool? activa,
    TipoExclusividadAutorizacion? tipo,
    String? alcance,
  }) {
    return ExclusividadAutorizacion(
      activa: activa ?? this.activa,
      tipo: tipo ?? this.tipo,
      alcance: alcance ?? this.alcance,
    );
  }

  static TipoExclusividadAutorizacion? _tipoExclusividadDesdeString(
    dynamic valor,
  ) {
    if (valor == null) return null;

    final encontrado = TipoExclusividadAutorizacion.values.where(
      (item) => item.name == valor,
    );

    if (encontrado.isEmpty) {
      throw FormatException(
        'TipoExclusividadAutorizacion inválido: $valor',
      );
    }

    return encontrado.first;
  }
}

/// Autorización atómica de una capacidad concreta sobre un ámbito.
class AutorizacionActivo {
  /// Nombre fijo del documento en Firestore.
  ///
  /// Las Firestore Rules no pueden buscar: solo abren un documento por su
  /// nombre. Por eso cada autorizacion se guarda con un nombre armado con
  /// Activo + usuario + permiso + ambito (y la referencia, si la tiene).
  /// Asi la regla puede comprobar si un usuario tiene un permiso, y la misma
  /// autorizacion no se duplica aunque se cargue dos veces (offline).
  static String construirId({
    required String activoId,
    required String usuarioAutorizado,
    required PermisoAutorizacion permiso,
    required AmbitoAutorizacion ambito,
  }) {
    final base =
        '${activoId}__${usuarioAutorizado}__${permiso.name}__${ambito.tipo.name}';

    final referencia = ambito.referenciaId?.trim();

    if (referencia == null || referencia.isEmpty) {
      return base;
    }

    return '${base}__$referencia';
  }

  final String autorizacionId;
  final String? grupoAutorizacionId;
  final String? autorizacionOrigenId;
  final String activoId;
  final String usuarioAutorizado;
  final String quienOtorga;
  final RolAutorizacion rol;
  final PermisoAutorizacion permiso;
  final AmbitoAutorizacion ambito;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final EstadoAutorizacion estado;
  final ModalidadRepresentacion? modalidadRepresentacion;
  final ExclusividadAutorizacion? exclusividad;
  final EvidenciaAutorizacion? evidenciaAutorizacion;
  final List<String> condiciones;
  final bool puedeDelegar;
  final DateTime fechaOtorgamiento;
  final String? motivo;

  const AutorizacionActivo({
    required this.autorizacionId,
    this.grupoAutorizacionId,
    this.autorizacionOrigenId,
    required this.activoId,
    required this.usuarioAutorizado,
    required this.quienOtorga,
    required this.rol,
    required this.permiso,
    required this.ambito,
    required this.fechaInicio,
    this.fechaFin,
    required this.estado,
    this.modalidadRepresentacion,
    this.exclusividad,
    this.evidenciaAutorizacion,
    this.condiciones = const [],
    this.puedeDelegar = false,
    required this.fechaOtorgamiento,
    this.motivo,
  });

  factory AutorizacionActivo.fromMap(Map<String, dynamic> map) {
    return AutorizacionActivo(
      autorizacionId: map['autorizacionId'] as String? ?? '',
      grupoAutorizacionId: map['grupoAutorizacionId'] as String?,
      autorizacionOrigenId: map['autorizacionOrigenId'] as String?,
      activoId: map['activoId'] as String? ?? '',
      usuarioAutorizado: map['usuarioAutorizado'] as String? ?? '',
      quienOtorga: map['quienOtorga'] as String? ?? '',
      rol: _rolDesdeString(map['rol']),
      permiso: _permisoDesdeString(map['permiso']),
      ambito: AmbitoAutorizacion.fromMap(
        Map<String, dynamic>.from(
          map['ambito'] as Map? ?? const {},
        ),
      ),
      fechaInicio: _leerFecha(map['fechaInicio']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      fechaFin: _leerFecha(map['fechaFin']),
      estado: _estadoDesdeString(map['estado']),
      modalidadRepresentacion:
          _modalidadDesdeString(map['modalidadRepresentacion']),
      exclusividad: map['exclusividad'] != null
          ? ExclusividadAutorizacion.fromMap(
              Map<String, dynamic>.from(
                map['exclusividad'] as Map,
              ),
            )
          : null,
      evidenciaAutorizacion: map['evidenciaAutorizacion'] != null
          ? EvidenciaAutorizacion.fromMap(
              Map<String, dynamic>.from(
                map['evidenciaAutorizacion'] as Map,
              ),
            )
          : null,
      condiciones: List<String>.from(
        map['condiciones'] ?? const [],
      ),
      puedeDelegar: map['puedeDelegar'] as bool? ?? false,
      fechaOtorgamiento: _leerFecha(map['fechaOtorgamiento']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      motivo: map['motivo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autorizacionId': autorizacionId,
      'grupoAutorizacionId': grupoAutorizacionId,
      'autorizacionOrigenId': autorizacionOrigenId,
      'activoId': activoId,
      'usuarioAutorizado': usuarioAutorizado,
      'quienOtorga': quienOtorga,
      'rol': rol.name,
      'permiso': permiso.name,
      'ambito': ambito.toMap(),
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin':
          fechaFin != null ? Timestamp.fromDate(fechaFin!) : null,
      'estado': estado.name,
      'modalidadRepresentacion': modalidadRepresentacion?.name,
      'exclusividad': exclusividad?.toMap(),
      'evidenciaAutorizacion': evidenciaAutorizacion?.toMap(),
      'condiciones': condiciones,
      'puedeDelegar': puedeDelegar,
      'fechaOtorgamiento': Timestamp.fromDate(fechaOtorgamiento),
      'motivo': motivo,
    };
  }

  AutorizacionActivo copyWith({
    String? autorizacionId,
    String? grupoAutorizacionId,
    String? autorizacionOrigenId,
    String? activoId,
    String? usuarioAutorizado,
    String? quienOtorga,
    RolAutorizacion? rol,
    PermisoAutorizacion? permiso,
    AmbitoAutorizacion? ambito,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    EstadoAutorizacion? estado,
    ModalidadRepresentacion? modalidadRepresentacion,
    ExclusividadAutorizacion? exclusividad,
    EvidenciaAutorizacion? evidenciaAutorizacion,
    List<String>? condiciones,
    bool? puedeDelegar,
    DateTime? fechaOtorgamiento,
    String? motivo,
  }) {
    return AutorizacionActivo(
      autorizacionId: autorizacionId ?? this.autorizacionId,
      grupoAutorizacionId:
          grupoAutorizacionId ?? this.grupoAutorizacionId,
      autorizacionOrigenId:
          autorizacionOrigenId ?? this.autorizacionOrigenId,
      activoId: activoId ?? this.activoId,
      usuarioAutorizado:
          usuarioAutorizado ?? this.usuarioAutorizado,
      quienOtorga: quienOtorga ?? this.quienOtorga,
      rol: rol ?? this.rol,
      permiso: permiso ?? this.permiso,
      ambito: ambito ?? this.ambito,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      modalidadRepresentacion:
          modalidadRepresentacion ?? this.modalidadRepresentacion,
      exclusividad: exclusividad ?? this.exclusividad,
      evidenciaAutorizacion:
          evidenciaAutorizacion ?? this.evidenciaAutorizacion,
      condiciones: condiciones ?? this.condiciones,
      puedeDelegar: puedeDelegar ?? this.puedeDelegar,
      fechaOtorgamiento:
          fechaOtorgamiento ?? this.fechaOtorgamiento,
      motivo: motivo ?? this.motivo,
    );
  }

  static RolAutorizacion _rolDesdeString(dynamic valor) {
    final encontrado = RolAutorizacion.values.where(
      (item) => item.name == valor,
    );

    if (encontrado.isEmpty) {
      throw FormatException(
        'RolAutorizacion inválido: $valor',
      );
    }

    return encontrado.first;
  }

  static PermisoAutorizacion _permisoDesdeString(dynamic valor) {
    final encontrado = PermisoAutorizacion.values.where(
      (item) => item.name == valor,
    );

    if (encontrado.isEmpty) {
      throw FormatException(
        'PermisoAutorizacion inválido: $valor',
      );
    }

    return encontrado.first;
  }

  static EstadoAutorizacion _estadoDesdeString(dynamic valor) {
    final encontrado = EstadoAutorizacion.values.where(
      (item) => item.name == valor,
    );

    if (encontrado.isEmpty) {
      throw FormatException(
        'EstadoAutorizacion inválido: $valor',
      );
    }

    return encontrado.first;
  }

  static ModalidadRepresentacion? _modalidadDesdeString(
    dynamic valor,
  ) {
    if (valor == null) return null;

    final encontrado = ModalidadRepresentacion.values.where(
      (item) => item.name == valor,
    );

    if (encontrado.isEmpty) {
      throw FormatException(
        'ModalidadRepresentacion inválida: $valor',
      );
    }

    return encontrado.first;
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor == null) return null;

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
}
