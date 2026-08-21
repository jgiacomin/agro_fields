import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un ciclo productivo histórico de un módulo
/// perteneciente a un Activo Agro V2.
///
/// Ejemplos:
/// - campaña agrícola
/// - ciclo ganadero
/// - período de producción avícola
/// - ciclo vitivinícola
class CicloProductivo {
  /// Identificador único del ciclo.
  final String cicloId;

  /// Referencia al Activo Agro V2.
  final String? activoAgroId;

  /// Referencia al módulo productivo.
  final String? moduloProduccionId;

  /// Inicio del ciclo productivo.
  final DateTime fechaInicio;

  /// Finalización del ciclo.
  final DateTime? fechaFin;

  /// Campaña, período o identificación productiva.
  ///
  /// Ejemplos:
  /// 2025/2026
  /// 2026-Q1
  final String? campania;

  /// Producción obtenida durante el ciclo.
  final double? produccionObtenida;

  /// Unidad de la producción obtenida.
  ///
  /// Ejemplos:
  /// kg, toneladas, litros, huevos, animales.
  final String? unidadProduccion;

  /// Información adicional del ciclo.
  final String observaciones;

  CicloProductivo({
    required this.cicloId,
    this.activoAgroId,
    this.moduloProduccionId,
    required this.fechaInicio,
    this.fechaFin,
    this.campania,
    this.produccionObtenida,
    this.unidadProduccion,
    required this.observaciones,
  });

  /// Reconstruye un ciclo desde Firestore.
  factory CicloProductivo.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return CicloProductivo(
      cicloId: id,

      activoAgroId:
          map['activoAgroId'],

      moduloProduccionId:
          map['moduloProduccionId'],

      fechaInicio:
          _leerFecha(
            map['fechaInicio'],
          ),

      fechaFin:
          map['fechaFin'] != null
              ? _leerFecha(
                  map['fechaFin'],
                )
              : null,

      campania:
          map['campania'],

      produccionObtenida:
          map['produccionObtenida'] != null
              ? (map['produccionObtenida'] as num).toDouble()
              : null,

      unidadProduccion:
          map['unidadProduccion'],

      observaciones:
          map['observaciones'] ?? '',
    );
  }

  /// Convierte el ciclo a estructura compatible con Firestore.
  Map<String, dynamic> toMap() {
    return {
      'cicloId': cicloId,
      'activoAgroId': activoAgroId,
      'moduloProduccionId': moduloProduccionId,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': fechaFin != null
          ? Timestamp.fromDate(fechaFin!)
          : null,
      'campania': campania,
      'produccionObtenida': produccionObtenida,
      'unidadProduccion': unidadProduccion,
      'observaciones': observaciones,
    };
  }

  /// Conversión robusta de fechas.
  static DateTime _leerFecha(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }

    if (valor is DateTime) {
      return valor;
    }

    if (valor is String) {
      return DateTime.tryParse(valor) ??
          DateTime.now();
    }

    return DateTime.now();
  }
}