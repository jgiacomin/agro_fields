/// AF-093 (12/11/2026): intervención de un profesional invitado al campo
/// (ingeniero agrónomo, veterinario, técnico...). Se guarda en
/// intervenciones_profesionales. Es de SOLO AGREGAR: no se edita ni se borra.
/// Agro Fields facilita, no reemplaza: el título profesional queda
/// "declarado" hasta que se verifique.
class IntervencionProfesional {
  static const List<String> tipos = [
    'visita',
    'recomendacion',
    'diagnostico',
    'informe',
    'otro',
  ];

  final String intervencionId;
  final String activoAgroId;
  final String profesionalId;

  /// Nombre que declara el profesional (no verificado).
  final String profesionalNombre;

  final String tipo;
  final String descripcion;
  final DateTime fecha;

  /// Siempre "declarado" al cargarse.
  final String estado;

  final DateTime fechaRegistro;

  const IntervencionProfesional({
    required this.intervencionId,
    required this.activoAgroId,
    required this.profesionalId,
    required this.profesionalNombre,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    this.estado = 'declarado',
    required this.fechaRegistro,
  });

  /// Lista de problemas (vacía = se puede guardar).
  List<String> validar() {
    final errores = <String>[];
    if (activoAgroId.trim().isEmpty) errores.add('Falta el campo.');
    if (profesionalId.trim().isEmpty) errores.add('Falta el profesional.');
    if (!tipos.contains(tipo)) errores.add('Tipo de intervención no válido.');
    if (descripcion.trim().isEmpty) errores.add('Contá qué se hizo.');
    return errores;
  }

  factory IntervencionProfesional.fromMap(Map<String, dynamic> map) {
    final tipo = map['tipo'] as String?;
    return IntervencionProfesional(
      intervencionId: map['intervencionId'] as String? ?? '',
      activoAgroId: map['activoAgroId'] as String? ?? '',
      profesionalId: map['profesionalId'] as String? ?? '',
      profesionalNombre: map['profesionalNombre'] as String? ?? '',
      // Un tipo desconocido se lee como "otro".
      tipo: tipos.contains(tipo) ? tipo! : 'otro',
      descripcion: map['descripcion'] as String? ?? '',
      fecha: _leerFecha(map['fecha']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      estado: map['estado'] as String? ?? 'declarado',
      fechaRegistro: _leerFecha(map['fechaRegistro']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'intervencionId': intervencionId,
      'activoAgroId': activoAgroId,
      'profesionalId': profesionalId,
      'profesionalNombre': profesionalNombre,
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha': fecha,
      'estado': estado,
      'fechaRegistro': fechaRegistro,
    };
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor);
    try {
      // Timestamp de Firestore (sin importar el paquete en el modelo).
      final fecha = (valor as dynamic).toDate();
      if (fecha is DateTime) return fecha;
    } catch (_) {}
    return null;
  }
}
