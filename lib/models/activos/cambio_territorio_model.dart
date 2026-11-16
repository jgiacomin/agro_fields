import 'package:cloud_firestore/cloud_firestore.dart';

/// AF-109 (16/11/2026): Historia del territorio (versión chica para enero).
///
/// Un cambio que la gente o la naturaleza le hizo al campo: un desmonte,
/// un canal, un camino, un drenaje, un cambio de uso, erosión o una
/// recuperación. Sirve para entender el suelo, el agua y los riesgos del
/// campo, y para que Emergencias aprenda de lo que pasó.
///
/// Reglas de confianza:
///  * Queda "declarado" (lo cuenta el usuario) o "conDocumento" (si tiene
///    un archivo adjunto). Nunca "verificado": verificar es de otro.
///  * No se edita ni se borra. Si algo se cargó mal, se carga otro
///    registro que lo corrige ([corrigeCambioId]) y queda la historia.
///  * Es un hecho contado, no una conclusión: no dice qué causó qué.
///
/// Colección propia `cambios_territorio` (no se mezcla con emergencias ni
/// con la identidad o la titularidad del Activo).
class CambioTerritorio {
  static const String coleccion = 'cambios_territorio';

  static const List<String> tipos = [
    'desmonte',
    'canal',
    'camino',
    'drenaje',
    'cambioUso',
    'erosion',
    'recuperacion',
    'otro',
  ];

  /// Cómo se sabe lo que se cuenta.
  static const List<String> fuentes = [
    'propia',
    'documento',
    'imagen',
    'profesional',
    'vecino',
    'organismo',
    'otra',
  ];

  static const int largoMaximoDescripcion = 2000;

  final String cambioId;
  final String activoAgroId;
  final String tipo;

  /// Cuándo pasó. Si fue a lo largo de un tiempo, desde [fechaDesde]
  /// hasta [fechaHasta]. Puede ser aproximada (ej.: "año 2015").
  final DateTime fechaDesde;
  final DateTime? fechaHasta;

  final String descripcion;

  /// Quién lo hizo (ej.: el dueño anterior, Vialidad, un vecino). Opcional.
  final String? realizadoPor;

  final String fuente;

  /// Ruta en Storage del archivo adjunto (foto, plano, permiso). Opcional.
  final String? archivoRuta;

  /// 'declarado' o 'conDocumento'.
  final String estadoDato;

  /// Si este registro corrige otro anterior.
  final String? corrigeCambioId;

  final String cargadoPor;
  final DateTime fechaCarga;

  const CambioTerritorio({
    required this.cambioId,
    required this.activoAgroId,
    required this.tipo,
    required this.fechaDesde,
    this.fechaHasta,
    required this.descripcion,
    this.realizadoPor,
    required this.fuente,
    this.archivoRuta,
    required this.estadoDato,
    this.corrigeCambioId,
    required this.cargadoPor,
    required this.fechaCarga,
  });

  /// Con archivo adjunto queda "con documento"; sin archivo, "declarado".
  static String estadoSegunArchivo(String? archivoRuta) =>
      (archivoRuta != null && archivoRuta.trim().isNotEmpty)
          ? 'conDocumento'
          : 'declarado';

  /// Lista de problemas (vacía = se puede guardar).
  List<String> validar({DateTime? hoy}) {
    final errores = <String>[];
    final ahora = hoy ?? DateTime.now();
    final finDeHoy = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);

    if (cambioId.trim().isEmpty) errores.add('Falta el ID del registro.');
    if (activoAgroId.trim().isEmpty) errores.add('Falta el campo.');
    if (!tipos.contains(tipo)) errores.add('Elegí qué cambió.');
    if (descripcion.trim().isEmpty) errores.add('Contá qué cambió.');
    if (descripcion.length > largoMaximoDescripcion) {
      errores.add('La descripción es demasiado larga.');
    }
    if (!fuentes.contains(fuente)) errores.add('Elegí cómo lo sabés.');
    if (fechaDesde.isAfter(finDeHoy)) {
      errores.add('La fecha no puede ser futura.');
    }
    if (fechaHasta != null) {
      if (fechaHasta!.isBefore(fechaDesde)) {
        errores.add('La fecha "hasta" no puede ser antes de la fecha "desde".');
      }
      if (fechaHasta!.isAfter(finDeHoy)) {
        errores.add('La fecha "hasta" no puede ser futura.');
      }
    }
    if (estadoDato != estadoSegunArchivo(archivoRuta)) {
      errores.add('El estado del dato no coincide con el archivo adjunto.');
    }
    if (cargadoPor.trim().isEmpty) errores.add('Tenés que ingresar de nuevo.');
    return errores;
  }

  /// Los que valen hoy: saca los que fueron corregidos por otro registro.
  /// Ordenados del más nuevo al más viejo (por la fecha en que pasó).
  static List<CambioTerritorio> vigentes(List<CambioTerritorio> todos) {
    final corregidos = todos
        .map((c) => c.corrigeCambioId)
        .whereType<String>()
        .toSet();
    return todos.where((c) => !corregidos.contains(c.cambioId)).toList()
      ..sort((a, b) => b.fechaDesde.compareTo(a.fechaDesde));
  }

  factory CambioTerritorio.fromMap(Map<String, dynamic> map) {
    final tipo = map['tipo'] as String?;
    final fuente = map['fuente'] as String?;
    return CambioTerritorio(
      cambioId: map['cambioId'] as String? ?? '',
      activoAgroId: map['activoAgroId'] as String? ?? '',
      tipo: tipos.contains(tipo) ? tipo! : 'otro',
      fechaDesde: _leerFecha(map['fechaDesde']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      fechaHasta: _leerFecha(map['fechaHasta']),
      descripcion: map['descripcion'] as String? ?? '',
      realizadoPor: map['realizadoPor'] as String?,
      fuente: fuentes.contains(fuente) ? fuente! : 'otra',
      archivoRuta: map['archivoRuta'] as String?,
      // Un estado desconocido se lee como "declarado" (nunca como más).
      estadoDato: map['estadoDato'] == 'conDocumento'
          ? 'conDocumento'
          : 'declarado',
      corrigeCambioId: map['corrigeCambioId'] as String?,
      cargadoPor: map['cargadoPor'] as String? ?? '',
      fechaCarga: _leerFecha(map['fechaCarga']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cambioId': cambioId,
      'activoAgroId': activoAgroId,
      'tipo': tipo,
      'fechaDesde': Timestamp.fromDate(fechaDesde),
      'fechaHasta': fechaHasta == null ? null : Timestamp.fromDate(fechaHasta!),
      'descripcion': descripcion,
      'realizadoPor': realizadoPor,
      'fuente': fuente,
      'archivoRuta': archivoRuta,
      'estadoDato': estadoDato,
      'corrigeCambioId': corrigeCambioId,
      'cargadoPor': cargadoPor,
      'fechaCarga': Timestamp.fromDate(fechaCarga),
    };
  }

  static DateTime? _leerFecha(dynamic valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor);
    return null;
  }
}
