import 'package:cloud_firestore/cloud_firestore.dart';

class ConfianzaActivo {
  final int nivelGeneral;

  // =====================================================
  // IDENTIDAD
  // =====================================================

  final bool identidadVerificada;

  // =====================================================
  // DOCUMENTACIÓN
  // =====================================================

  final bool documentacionCompleta;
  final int nivelDocumentacion;

  // =====================================================
  // EVIDENCIAS
  // =====================================================

  final int cantidadEvidencias;
  final int nivelEvidencias;

  // =====================================================
  // INFORMACIÓN PRODUCTIVA
  // =====================================================

  final bool informacionProductivaCompleta;
  final int nivelProduccion;

  // =====================================================
  // INFRAESTRUCTURA
  // =====================================================

  final int nivelInfraestructura;
  final bool infraestructuraVerificada;
  final int cantidadInfraestructuras;

  // =====================================================
  // TECNOLOGÍA
  // =====================================================

  final int nivelTecnologia;
  final bool tecnologiaVerificada;
  final int cantidadTecnologias;

  // =====================================================
  // INVERSIÓN
  // =====================================================

  final int nivelInversion;
  final bool inversionDeclarada;
  final bool inversionVerificada;
  final double montoInversionDeclarada;
  final String monedaInversion;

  // =====================================================
  // PARTICIPANTES
  // =====================================================

  final bool participantesVerificados;

  // =====================================================
  // GOBERNANZA
  // =====================================================

  final int nivelGobernanza;

  // =====================================================
  // CONTROL
  // =====================================================

  final DateTime ultimaVerificacion;
  final DateTime ultimaEvaluacion;

  final String observaciones;

  ConfianzaActivo({
    required this.nivelGeneral,

    required this.identidadVerificada,

    required this.documentacionCompleta,
    required this.nivelDocumentacion,

    required this.cantidadEvidencias,
    required this.nivelEvidencias,

    required this.informacionProductivaCompleta,
    required this.nivelProduccion,

    required this.nivelInfraestructura,
    required this.infraestructuraVerificada,
    required this.cantidadInfraestructuras,

    required this.nivelTecnologia,
    required this.tecnologiaVerificada,
    required this.cantidadTecnologias,

    required this.nivelInversion,
    required this.inversionDeclarada,
    required this.inversionVerificada,
    required this.montoInversionDeclarada,
    required this.monedaInversion,

    required this.participantesVerificados,

    required this.nivelGobernanza,

    required this.ultimaVerificacion,
    required this.ultimaEvaluacion,

    required this.observaciones,
  });

  ConfianzaActivo copyWith({
    int? nivelGeneral,

    bool? identidadVerificada,

    bool? documentacionCompleta,
    int? nivelDocumentacion,

    int? cantidadEvidencias,
    int? nivelEvidencias,

    bool? informacionProductivaCompleta,
    int? nivelProduccion,

    int? nivelInfraestructura,
    bool? infraestructuraVerificada,
    int? cantidadInfraestructuras,

    int? nivelTecnologia,
    bool? tecnologiaVerificada,
    int? cantidadTecnologias,

    int? nivelInversion,
    bool? inversionDeclarada,
    bool? inversionVerificada,
    double? montoInversionDeclarada,
    String? monedaInversion,

    bool? participantesVerificados,

    int? nivelGobernanza,

    DateTime? ultimaVerificacion,
    DateTime? ultimaEvaluacion,

    String? observaciones,
  }) {
    return ConfianzaActivo(
      nivelGeneral: nivelGeneral ?? this.nivelGeneral,

      identidadVerificada: identidadVerificada ?? this.identidadVerificada,

      documentacionCompleta:
          documentacionCompleta ?? this.documentacionCompleta,

      nivelDocumentacion: nivelDocumentacion ?? this.nivelDocumentacion,

      cantidadEvidencias: cantidadEvidencias ?? this.cantidadEvidencias,

      nivelEvidencias: nivelEvidencias ?? this.nivelEvidencias,

      informacionProductivaCompleta:
          informacionProductivaCompleta ?? this.informacionProductivaCompleta,

      nivelProduccion: nivelProduccion ?? this.nivelProduccion,

      nivelInfraestructura: nivelInfraestructura ?? this.nivelInfraestructura,

      infraestructuraVerificada:
          infraestructuraVerificada ?? this.infraestructuraVerificada,

      cantidadInfraestructuras:
          cantidadInfraestructuras ?? this.cantidadInfraestructuras,

      nivelTecnologia: nivelTecnologia ?? this.nivelTecnologia,

      tecnologiaVerificada: tecnologiaVerificada ?? this.tecnologiaVerificada,

      cantidadTecnologias: cantidadTecnologias ?? this.cantidadTecnologias,

      nivelInversion: nivelInversion ?? this.nivelInversion,

      inversionDeclarada: inversionDeclarada ?? this.inversionDeclarada,

      inversionVerificada: inversionVerificada ?? this.inversionVerificada,

      montoInversionDeclarada:
          montoInversionDeclarada ?? this.montoInversionDeclarada,

      monedaInversion: monedaInversion ?? this.monedaInversion,

      participantesVerificados:
          participantesVerificados ?? this.participantesVerificados,

      nivelGobernanza: nivelGobernanza ?? this.nivelGobernanza,

      ultimaVerificacion: ultimaVerificacion ?? this.ultimaVerificacion,

      ultimaEvaluacion: ultimaEvaluacion ?? this.ultimaEvaluacion,

      observaciones: observaciones ?? this.observaciones,
    );
  }

  factory ConfianzaActivo.fromMap(Map<String, dynamic> map) {
    return ConfianzaActivo(
      nivelGeneral: _leerInt(map['nivelGeneral']),

      identidadVerificada: map['identidadVerificada'] ?? false,

      documentacionCompleta: map['documentacionCompleta'] ?? false,

      nivelDocumentacion: _leerInt(map['nivelDocumentacion']),

      cantidadEvidencias: _leerInt(map['cantidadEvidencias']),

      nivelEvidencias: _leerInt(map['nivelEvidencias']),

      informacionProductivaCompleta:
          map['informacionProductivaCompleta'] ?? false,

      nivelProduccion: _leerInt(map['nivelProduccion']),

      nivelInfraestructura: _leerInt(map['nivelInfraestructura']),

      infraestructuraVerificada: map['infraestructuraVerificada'] ?? false,

      cantidadInfraestructuras: _leerInt(map['cantidadInfraestructuras']),

      nivelTecnologia: _leerInt(map['nivelTecnologia']),

      tecnologiaVerificada: map['tecnologiaVerificada'] ?? false,

      cantidadTecnologias: _leerInt(map['cantidadTecnologias']),

      nivelInversion: _leerInt(map['nivelInversion']),

      inversionDeclarada: map['inversionDeclarada'] ?? false,

      inversionVerificada: map['inversionVerificada'] ?? false,

      montoInversionDeclarada: _leerDouble(map['montoInversionDeclarada']),

      monedaInversion: map['monedaInversion'] ?? '',

      participantesVerificados: map['participantesVerificados'] ?? false,

      nivelGobernanza: _leerInt(map['nivelGobernanza']),

      ultimaVerificacion: _leerFecha(map['ultimaVerificacion']),

      ultimaEvaluacion: _leerFecha(map['ultimaEvaluacion']),

      observaciones: map['observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nivelGeneral': nivelGeneral,

      'identidadVerificada': identidadVerificada,

      'documentacionCompleta': documentacionCompleta,

      'nivelDocumentacion': nivelDocumentacion,

      'cantidadEvidencias': cantidadEvidencias,

      'nivelEvidencias': nivelEvidencias,

      'informacionProductivaCompleta': informacionProductivaCompleta,

      'nivelProduccion': nivelProduccion,

      'nivelInfraestructura': nivelInfraestructura,

      'infraestructuraVerificada': infraestructuraVerificada,

      'cantidadInfraestructuras': cantidadInfraestructuras,

      'nivelTecnologia': nivelTecnologia,

      'tecnologiaVerificada': tecnologiaVerificada,

      'cantidadTecnologias': cantidadTecnologias,

      'nivelInversion': nivelInversion,

      'inversionDeclarada': inversionDeclarada,

      'inversionVerificada': inversionVerificada,

      'montoInversionDeclarada': montoInversionDeclarada,

      'monedaInversion': monedaInversion,

      'participantesVerificados': participantesVerificados,

      'nivelGobernanza': nivelGobernanza,

      'ultimaVerificacion': Timestamp.fromDate(ultimaVerificacion),

      'ultimaEvaluacion': Timestamp.fromDate(ultimaEvaluacion),

      'observaciones': observaciones,
    };
  }

  // =====================================================
  // HELPERS DE COMPATIBILIDAD
  // =====================================================

  static int _leerInt(dynamic valor) {
    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.toInt();
    }

    return 0;
  }

  static double _leerDouble(dynamic valor) {
    if (valor is double) {
      return valor;
    }

    if (valor is num) {
      return valor.toDouble();
    }

    return 0;
  }

  static DateTime _leerFecha(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }

    if (valor is DateTime) {
      return valor;
    }

    if (valor is String) {
      return DateTime.tryParse(valor) ?? DateTime.now();
    }

    return DateTime.now();
  }
}
