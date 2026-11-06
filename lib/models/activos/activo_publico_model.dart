import 'package:cloud_firestore/cloud_firestore.dart';

import 'activo_agro_model_v2.dart';

/// Resumen público de un Activo Agro.
///
/// Es lo único que lee el marketplace (colección `activos_publicos`).
/// El ID del documento es el mismo `activoId` del expediente privado.
///
/// Regla: acá NO va nada privado (economía, documentos, suelo,
/// historial, participantes ni datos personales). Si se agrega un dato,
/// primero se decide si es publicable y se suma su prueba.
class ActivoPublico {

  final String activoId;
  final String nombre;
  final String descripcion;
  final String tipoActivo;

  final String pais;
  final String provincia;
  final String localidad;
  final double superficie;

  /// Solo el número general, sin el detalle de la evaluación.
  final int nivelConfianza;

  /// Solo el porcentaje, sin la lista de faltantes.
  final double madurezPorcentaje;

  /// Solo el nombre de cada actividad (ej: "Gallinas ponedoras").
  final List<String> producciones;

  final String propietarioId;

  /// borrador | pendienteRevision | publicado | pausado
  final String estadoPublicacion;

  /// Solo el administrador lo pone en true al aprobar.
  final bool visible;

  final DateTime ultimaActualizacion;

  const ActivoPublico({
    required this.activoId,
    required this.nombre,
    required this.descripcion,
    required this.tipoActivo,
    required this.pais,
    required this.provincia,
    required this.localidad,
    required this.superficie,
    required this.nivelConfianza,
    required this.madurezPorcentaje,
    required this.producciones,
    required this.propietarioId,
    required this.estadoPublicacion,
    required this.visible,
    required this.ultimaActualizacion,
  });

  /// Arma el resumen a partir del expediente, copiando solo lo publicable.
  /// Siempre nace pendiente de revisión y no visible.
  factory ActivoPublico.desdeActivo(ActivoAgroV2 activo) {
    return ActivoPublico(
      activoId: activo.activoId,
      nombre: activo.nombre,
      descripcion: activo.descripcion,
      tipoActivo: activo.tipoActivo.name,
      pais: activo.ubicacion.pais,
      provincia: activo.ubicacion.provincia,
      localidad: activo.ubicacion.localidad,
      superficie: activo.ubicacion.superficie,
      nivelConfianza: activo.confianza.nivelGeneral,
      madurezPorcentaje: activo.madurez.porcentaje,
      producciones:
          activo.producciones.map((p) => p.actividad).toList(),
      propietarioId: activo.propietarioId,
      estadoPublicacion: 'pendienteRevision',
      visible: false,
      ultimaActualizacion: DateTime.now(),
    );
  }

  factory ActivoPublico.fromMap(Map<String, dynamic> map, String id) {
    return ActivoPublico(
      activoId: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      tipoActivo: map['tipoActivo'] ?? '',
      pais: map['pais'] ?? '',
      provincia: map['provincia'] ?? '',
      localidad: map['localidad'] ?? '',
      superficie: (map['superficie'] as num?)?.toDouble() ?? 0,
      nivelConfianza: (map['nivelConfianza'] as num?)?.toInt() ?? 0,
      madurezPorcentaje:
          (map['madurezPorcentaje'] as num?)?.toDouble() ?? 0,
      producciones: List<String>.from(map['producciones'] ?? const []),
      propietarioId: map['propietarioId'] ?? '',
      estadoPublicacion: map['estadoPublicacion'] ?? 'borrador',
      visible: map['visible'] == true,
      ultimaActualizacion: _leerFecha(map['ultimaActualizacion']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activoId': activoId,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipoActivo': tipoActivo,
      'pais': pais,
      'provincia': provincia,
      'localidad': localidad,
      'superficie': superficie,
      'nivelConfianza': nivelConfianza,
      'madurezPorcentaje': madurezPorcentaje,
      'producciones': producciones,
      'propietarioId': propietarioId,
      'estadoPublicacion': estadoPublicacion,
      'visible': visible,
      'ultimaActualizacion': Timestamp.fromDate(ultimaActualizacion),
    };
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
