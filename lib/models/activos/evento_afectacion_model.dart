class EventoAfectacion {
  final String eventoId;
  final String activoAgroId;
  final String tipoEvento;
  final String? subtipoEvento;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String descripcion;
  final String origen;
  final String estado;
  final String usuarioRegistrador;
  final DateTime fechaRegistro;
  final List<Afectacion> afectaciones;

  const EventoAfectacion({
    required this.eventoId,
    required this.activoAgroId,
    required this.tipoEvento,
    this.subtipoEvento,
    required this.fechaInicio,
    this.fechaFin,
    required this.descripcion,
    required this.origen,
    required this.estado,
    required this.usuarioRegistrador,
    required this.fechaRegistro,
    this.afectaciones = const [],
  })  : assert(eventoId != ''),
        assert(activoAgroId != ''),
        assert(tipoEvento != ''),
        assert(descripcion != ''),
        assert(origen != ''),
        assert(estado != ''),
        assert(usuarioRegistrador != '');

  Map<String, dynamic> toMap() {
    return {
      'eventoId': eventoId,
      'activoAgroId': activoAgroId,
      'tipoEvento': tipoEvento,
      'subtipoEvento': subtipoEvento,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'descripcion': descripcion,
      'origen': origen,
      'estado': estado,
      'usuarioRegistrador': usuarioRegistrador,
      'fechaRegistro': fechaRegistro,
      'afectaciones':
          afectaciones.map((afectacion) => afectacion.toMap()).toList(),
    };
  }

  factory EventoAfectacion.fromMap(
    Map<String, dynamic> map,
  ) {
    return EventoAfectacion(
      eventoId: map['eventoId'] as String? ?? '',
      activoAgroId: map['activoAgroId'] as String? ?? '',
      tipoEvento: map['tipoEvento'] as String? ?? '',
      subtipoEvento: map['subtipoEvento'] as String?,
      fechaInicio: _leerFecha(map['fechaInicio']),
      fechaFin: _leerFechaOpcional(map['fechaFin']),
      descripcion: map['descripcion'] as String? ?? '',
      origen: map['origen'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      usuarioRegistrador:
          map['usuarioRegistrador'] as String? ?? '',
      fechaRegistro: _leerFecha(map['fechaRegistro']),
      afectaciones:
          (map['afectaciones'] as List<dynamic>? ?? [])
              .map(
                (item) => Afectacion.fromMap(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
    );
  }
}

class Afectacion {
  final String objetoTipo;
  final String objetoId;
  final String descripcion;
  final double? magnitud;
  final String? unidad;
  final double? superficieAfectada;
  final double? porcentajeAfectado;
  final String nivel;
  final String estado;
  final List<Consecuencia> consecuencias;

  const Afectacion({
    required this.objetoTipo,
    required this.objetoId,
    required this.descripcion,
    this.magnitud,
    this.unidad,
    this.superficieAfectada,
    this.porcentajeAfectado,
    required this.nivel,
    required this.estado,
    this.consecuencias = const [],
  })  : assert(objetoTipo != ''),
        assert(objetoId != ''),
        assert(descripcion != ''),
        assert(nivel != ''),
        assert(estado != ''),
        assert(
          magnitud == null || magnitud >= 0,
          'magnitud no puede ser negativa.',
        ),
        assert(
          superficieAfectada == null || superficieAfectada >= 0,
          'superficieAfectada no puede ser negativa.',
        ),
        assert(
          porcentajeAfectado == null ||
              (porcentajeAfectado >= 0 &&
                  porcentajeAfectado <= 100),
          'porcentajeAfectado debe estar entre 0 y 100.',
        );

  Map<String, dynamic> toMap() {
    return {
      'objetoTipo': objetoTipo,
      'objetoId': objetoId,
      'descripcion': descripcion,
      'magnitud': magnitud,
      'unidad': unidad,
      'superficieAfectada': superficieAfectada,
      'porcentajeAfectado': porcentajeAfectado,
      'nivel': nivel,
      'estado': estado,
      'consecuencias':
          consecuencias.map((consecuencia) => consecuencia.toMap()).toList(),
    };
  }

  factory Afectacion.fromMap(
    Map<String, dynamic> map,
  ) {
    return Afectacion(
      objetoTipo: map['objetoTipo'] as String? ?? '',
      objetoId: map['objetoId'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      magnitud: _leerDouble(map['magnitud']),
      unidad: map['unidad'] as String?,
      superficieAfectada: _leerDouble(map['superficieAfectada']),
      porcentajeAfectado: _leerDouble(map['porcentajeAfectado']),
      nivel: map['nivel'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      consecuencias:
          (map['consecuencias'] as List<dynamic>? ?? [])
              .map(
                (item) => Consecuencia.fromMap(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(),
    );
  }
}

class Consecuencia {
  final String tipoConsecuencia;
  final String descripcion;
  final String estado;
  final DateTime? fechaEstimacion;
  final ReferenciaEntidad? referenciaProductiva;
  final ReferenciaDatoEconomico? referenciaEconomica;
  final ImpactoProductivo? impactoProductivo;

  const Consecuencia({
    required this.tipoConsecuencia,
    required this.descripcion,
    required this.estado,
    this.fechaEstimacion,
    this.referenciaProductiva,
    this.referenciaEconomica,
    this.impactoProductivo,
  })  : assert(tipoConsecuencia != ''),
        assert(descripcion != ''),
        assert(estado != '');

  Map<String, dynamic> toMap() {
    return {
      'tipoConsecuencia': tipoConsecuencia,
      'descripcion': descripcion,
      'estado': estado,
      'fechaEstimacion': fechaEstimacion,
      'referenciaProductiva': referenciaProductiva?.toMap(),
      'referenciaEconomica': referenciaEconomica?.toMap(),
      'impactoProductivo': impactoProductivo?.toMap(),
    };
  }

  factory Consecuencia.fromMap(
    Map<String, dynamic> map,
  ) {
    final referenciaProductivaMap =
        map['referenciaProductiva'];

    final referenciaEconomicaMap =
        map['referenciaEconomica'];
    final impactoProductivoMap =
        map['impactoProductivo'];

    return Consecuencia(
      tipoConsecuencia:
          map['tipoConsecuencia'] as String? ?? '',
      descripcion:
          map['descripcion'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      fechaEstimacion:
          _leerFechaOpcional(map['fechaEstimacion']),
      referenciaProductiva:
          referenciaProductivaMap is Map
              ? ReferenciaEntidad.fromMap(
                  Map<String, dynamic>.from(
                    referenciaProductivaMap,
                  ),
                )
              : null,
      referenciaEconomica:
          referenciaEconomicaMap is Map
              ? ReferenciaDatoEconomico.fromMap(
                  Map<String, dynamic>.from(
                    referenciaEconomicaMap,
                  ),
                )
              : null,
                    impactoProductivo:
          impactoProductivoMap is Map
              ? ImpactoProductivo.fromMap(
                  Map<String, dynamic>.from(
                    impactoProductivoMap,
                  ),
                )
              : null,
    );
  }
 }

class ImpactoProductivo {
  final String tipoImpacto;
  final double valor;
  final String unidad;
  final ReferenciaEntidad? referenciaProductiva;
  final String estado;

  const ImpactoProductivo({
    required this.tipoImpacto,
    required this.valor,
    required this.unidad,
    this.referenciaProductiva,
    required this.estado,
  })  : assert(tipoImpacto != ''),
        assert(valor >= 0),
        assert(unidad != ''),
        assert(estado != '');

  Map<String, dynamic> toMap() {
    return {
      'tipoImpacto': tipoImpacto,
      'valor': valor,
      'unidad': unidad,
      'referenciaProductiva':
          referenciaProductiva?.toMap(),
      'estado': estado,
    };
  }

  factory ImpactoProductivo.fromMap(
    Map<String, dynamic> map,
  ) {
    final referenciaProductivaMap =
        map['referenciaProductiva'];

    return ImpactoProductivo(
      tipoImpacto:
          map['tipoImpacto'] as String? ?? '',
      valor:
          (map['valor'] as num?)?.toDouble() ?? 0,
      unidad:
          map['unidad'] as String? ?? '',
      referenciaProductiva:
          referenciaProductivaMap is Map
              ? ReferenciaEntidad.fromMap(
                  Map<String, dynamic>.from(
                    referenciaProductivaMap,
                  ),
                )
              : null,
      estado:
          map['estado'] as String? ?? '',
    );
  }
}

class ReferenciaEntidad {
  final String tipo;
  final String id;

  const ReferenciaEntidad({
    required this.tipo,
    required this.id,
  })  : assert(tipo != ''),
        assert(id != '');

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'id': id,
    };
  }

  factory ReferenciaEntidad.fromMap(
    Map<String, dynamic> map,
  ) {
    return ReferenciaEntidad(
      tipo: map['tipo'] as String? ?? '',
      id: map['id'] as String? ?? '',
    );
  }
}

class ReferenciaDatoEconomico {
  final String nombreDato;
  final String tipoTemporal;
  final String periodo;
  final String? escenarioId;

  const ReferenciaDatoEconomico({
    required this.nombreDato,
    required this.tipoTemporal,
    required this.periodo,
    this.escenarioId,
  })  : assert(nombreDato != ''),
        assert(tipoTemporal != ''),
        assert(periodo != ''),
        assert(
          tipoTemporal == 'escenario'
              ? escenarioId != null && escenarioId != ''
              : escenarioId == null,
          'escenarioId debe existir Ãºnicamente para referencias de tipo escenario.',
        );

  Map<String, dynamic> toMap() {
    return {
      'nombreDato': nombreDato,
      'tipoTemporal': tipoTemporal,
      'periodo': periodo,
      'escenarioId': escenarioId,
    };
  }

  factory ReferenciaDatoEconomico.fromMap(
    Map<String, dynamic> map,
  ) {
    return ReferenciaDatoEconomico(
      nombreDato: map['nombreDato'] as String? ?? '',
      tipoTemporal: map['tipoTemporal'] as String? ?? '',
      periodo: map['periodo'] as String? ?? '',
      escenarioId: map['escenarioId'] as String?,
    );
  }
}

DateTime _leerFecha(dynamic valor) {
  if (valor is DateTime) {
    return valor;
  }

  if (valor != null) {
    try {
      if (valor.runtimeType.toString() == 'Timestamp') {
        return valor.toDate() as DateTime;
      }
    } catch (_) {
      // ContinÃºa con la siguiente estrategia.
    }

    if (valor is String) {
      final fecha = DateTime.tryParse(valor);
      if (fecha != null) {
        return fecha;
      }
    }
  }

  return DateTime.now();
}

DateTime? _leerFechaOpcional(dynamic valor) {
  if (valor == null) {
    return null;
  }

  if (valor is DateTime) {
    return valor;
  }

  try {
    if (valor.runtimeType.toString() == 'Timestamp') {
      return valor.toDate() as DateTime;
    }
  } catch (_) {
    // ContinÃºa con la siguiente estrategia.
  }

  if (valor is String) {
    return DateTime.tryParse(valor);
  }

  return null;
}

double? _leerDouble(dynamic valor) {
  if (valor == null) {
    return null;
  }

  if (valor is num) {
    return valor.toDouble();
  }

  if (valor is String) {
    return double.tryParse(valor);
  }

  return null;
}
