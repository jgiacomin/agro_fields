import 'package:cloud_firestore/cloud_firestore.dart';

/// GAP-LEGAL-01 (16/11/2026): prueba de que un usuario aceptó una versión
/// de los Términos de uso y la Política de privacidad.
///
/// Colección `aceptaciones_legales`. ID armado: usuario + versión, así
/// cada usuario acepta cada versión una sola vez. Solo se agrega: nunca se
/// cambia ni se borra (es la prueba).
class AceptacionLegal {
  static const String coleccion = 'aceptaciones_legales';

  final String usuarioId;
  final String version;
  final DateTime fecha;

  /// 'android', 'web', etc. (solo informativo).
  final String plataforma;

  const AceptacionLegal({
    required this.usuarioId,
    required this.version,
    required this.fecha,
    required this.plataforma,
  });

  /// ID del documento: usuario__version.
  static String construirId(String usuarioId, String version) =>
      '${usuarioId}__$version';

  String get id => construirId(usuarioId, version);

  Map<String, dynamic> toMap() => {
        'usuarioId': usuarioId,
        'version': version,
        'fecha': Timestamp.fromDate(fecha),
        'plataforma': plataforma,
      };

  factory AceptacionLegal.fromMap(Map<String, dynamic> map) {
    final f = map['fecha'];
    return AceptacionLegal(
      usuarioId: map['usuarioId'] as String? ?? '',
      version: map['version'] as String? ?? '',
      fecha: f is Timestamp
          ? f.toDate()
          : (f is DateTime ? f : DateTime.fromMillisecondsSinceEpoch(0)),
      plataforma: map['plataforma'] as String? ?? '',
    );
  }
}

/// GAP-LEGAL-01, opción A: pedido de baja de la cuenta.
///
/// Colección `solicitudes_baja`, un documento por usuario (ID = usuario).
/// El usuario lo crea "pendiente"; el administrador lo completa dentro de
/// [diasParaCompletar] días. El usuario no lo puede cambiar ni borrar.
class SolicitudBaja {
  static const String coleccion = 'solicitudes_baja';
  static const int diasParaCompletar = 30;
  static const int largoMaximoMotivo = 500;

  /// Lo que hay que escribir para confirmar (evita tocar sin querer).
  static const String palabraConfirmacion = 'BORRAR';

  final String usuarioId;
  final String? email;
  final String? motivo;
  final DateTime fechaPedido;
  final String estado; // pendiente | completada | anulada

  const SolicitudBaja({
    required this.usuarioId,
    this.email,
    this.motivo,
    required this.fechaPedido,
    this.estado = 'pendiente',
  });

  /// Fecha límite para completar la baja.
  DateTime get fechaLimite =>
      fechaPedido.add(const Duration(days: diasParaCompletar));

  /// true si lo escrito confirma la baja (sin importar mayúsculas ni
  /// espacios alrededor).
  static bool confirma(String escrito) =>
      escrito.trim().toUpperCase() == palabraConfirmacion;

  List<String> validar() {
    final errores = <String>[];
    if (usuarioId.trim().isEmpty) errores.add('Tenés que ingresar de nuevo.');
    if (motivo != null && motivo!.length > largoMaximoMotivo) {
      errores.add('El motivo es demasiado largo.');
    }
    if (estado != 'pendiente') errores.add('Un pedido nuevo empieza pendiente.');
    return errores;
  }

  Map<String, dynamic> toMap() => {
        'usuarioId': usuarioId,
        'email': email,
        'motivo': motivo,
        'fechaPedido': Timestamp.fromDate(fechaPedido),
        'estado': estado,
      };

  factory SolicitudBaja.fromMap(Map<String, dynamic> map) {
    final f = map['fechaPedido'];
    return SolicitudBaja(
      usuarioId: map['usuarioId'] as String? ?? '',
      email: map['email'] as String?,
      motivo: map['motivo'] as String?,
      fechaPedido: f is Timestamp
          ? f.toDate()
          : (f is DateTime ? f : DateTime.fromMillisecondsSinceEpoch(0)),
      // QA 20/11/2026: se suma "anulada" (el admin anula una prueba o un
      // arrepentimiento). Cualquier otro valor raro se lee como pendiente.
      estado: const ['completada', 'anulada'].contains(map['estado'])
          ? map['estado'] as String
          : 'pendiente',
    );
  }
}
