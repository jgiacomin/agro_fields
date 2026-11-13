import 'package:cloud_firestore/cloud_firestore.dart';

/// Evento productivo (paso 6a, GAP-PROD-01): QUE PASO.
///
/// Es de SOLO AGREGAR: no se edita ni se borra. Un error se corrige con
/// otro evento que dice a cual corrige (corrigeEventoId).
///
/// El eventoId se arma en el telefono, para que cargarlo dos veces sin
/// senal no lo duplique (Concepto 8).
///
/// No confundir con EventoAfectacion (clima, inundaciones, etc.).
enum TipoEventoProductivo {
  // Para el lanzamiento:
  alta,
  baja,
  movimiento,
  cambioCategoria,
  sanidad,
  // Preparados (el modelo los acepta, la app todavia no los ofrece):
  reproduccion,
  pesaje,
  alimentacion,
  siembra,
  cosecha,
  // GAP-MON-01 (13/11/2026): monitoreo (motor común para todas las
  // actividades; en el lanzamiento la app lo ofrece en los cultivos).
  monitoreo,
  // GAP-APLI-01 (13/11/2026): aplicación terrestre (pulverización).
  aplicacion,
}

/// Origen de un alta (Concepto 5.2).
enum OrigenAlta {
  nacimiento,
  compra,
  capitalizacion,
  hoteleria,
  otro,
}

/// Motivo de una baja.
enum MotivoBaja {
  venta,
  muerte,
  consumo,
  traslado,
  otro,
}

/// Declarado no es verificado.
enum EstadoDatoEvento {
  declarado,
  conEvidencia,
  verificado,
}

const Set<TipoEventoProductivo> tiposEventoLanzamiento = {
  TipoEventoProductivo.alta,
  TipoEventoProductivo.baja,
  TipoEventoProductivo.movimiento,
  TipoEventoProductivo.cambioCategoria,
  TipoEventoProductivo.sanidad,
};

/// GAP-AGRO-01 (12/11/2026): eventos de agricultura que ofrece la app.
/// (No se suman a tiposEventoLanzamiento para no mostrarlos en los rodeos.)
const Set<TipoEventoProductivo> tiposEventoAgricola = {
  TipoEventoProductivo.siembra,
  TipoEventoProductivo.cosecha,
};

/// Unidades para lo cosechado.
const List<String> unidadesCosecha = ['tn', 'kg', 'qq'];

/// GAP-APLI-01: con viento mayor a esto, la app avisa antes de guardar
/// (no bloquea; el límite exacto depende de cada provincia).
const double vientoMaximoAviso = 15;

/// GAP-MON-01: qué se miró en el monitoreo.
const List<String> objetivosMonitoreo = [
  'plaga',
  'maleza',
  'enfermedad',
  'estadoCultivo',
  'agua',
  'otro',
];

/// GAP-MON-01: qué tan grave es lo que se vio.
const List<String> nivelesMonitoreo = ['bajo', 'medio', 'alto'];

/// GAP-MON-01 (Concepto 9, "fuente del dato"): de dónde sale el dato.
/// Agro Fields no vende drones ni sensores: solo anota de dónde vino.
const List<String> fuentesDato = [
  'recorrida',
  'dron',
  'satelite',
  'sensor',
  'estacion',
  'laboratorio',
  'otro',
];

class EventoProductivo {
  // Datos comunes a todo evento.
  final String eventoId;
  final String activoAgroId;
  final String grupoId;
  final String? unidadId;
  final TipoEventoProductivo tipo;
  final DateTime fechaHecho;
  final DateTime fechaCarga;
  final String cargadoPor;
  final EstadoDatoEvento estadoDato;
  final List<String> evidenciaIds;
  final String? trabajoId;
  final String? corrigeEventoId;
  final String? observaciones;

  // Datos propios segun el tipo (vacios si no aplican).
  final int? cantidad;
  final String? categoria;
  final String? categoriaNueva;
  final OrigenAlta? origen;
  final MotivoBaja? motivo;
  final String? unidadOrigenId;
  final String? unidadDestinoId;
  final String? tratamiento;
  final String? recursoId;
  final String? dosis;
  final String? responsable;

  /// Si el evento desconto un insumo del stock (paso 6a-2), el
  /// movimiento de stock que lo hizo.
  final String? movimientoStockId;

  // GAP-AGRO-01: datos de siembra y cosecha (vacíos si no aplican).
  /// Hectáreas sembradas o cosechadas.
  final double? superficieHa;

  /// Lo cosechado (con decimales; la cantidad entera es para animales).
  final double? cantidadObtenida;

  /// Unidad de lo cosechado: tn, kg o qq.
  final String? unidadMedida;

  /// Variedad o híbrido sembrado.
  final String? material;

  /// Densidad de siembra (texto libre: "70.000 pl/ha", "60 kg/ha").
  final String? densidad;

  /// Humedad del grano al cosechar (%).
  final double? humedad;

  // GAP-MON-01: datos del monitoreo (vacíos si no aplican).
  // "Qué se vio" va en observaciones (obligatorio en el monitoreo).
  /// Qué se miró: plaga, maleza, enfermedad, estadoCultivo, agua u otro.
  final String? objetivoMonitoreo;

  /// bajo, medio o alto.
  final String? nivel;

  /// De dónde sale el dato: recorrida, dron, satelite, sensor, estacion,
  /// laboratorio u otro.
  final String? fuenteDato;

  /// Qué se recomienda hacer (opcional; la decisión es del productor).
  final String? recomendacion;

  // GAP-APLI-01: datos de la aplicación (vacíos si no aplican).
  // Se reutilizan: superficieHa (hectáreas aplicadas), tratamiento
  // (producto), dosis y responsable (quién aplicó).
  /// Número de la receta agronómica.
  final String? recetaNumero;

  /// Viento al aplicar (km/h).
  final double? vientoKmh;

  /// Temperatura al aplicar (°C).
  final double? temperatura;

  /// Humedad del aire al aplicar (%). No confundir con [humedad], que es
  /// la del grano en la cosecha.
  final double? humedadAmbiente;

  const EventoProductivo({
    required this.eventoId,
    required this.activoAgroId,
    required this.grupoId,
    required this.tipo,
    required this.fechaHecho,
    required this.fechaCarga,
    required this.cargadoPor,
    this.unidadId,
    this.estadoDato = EstadoDatoEvento.declarado,
    this.evidenciaIds = const [],
    this.trabajoId,
    this.corrigeEventoId,
    this.observaciones,
    this.cantidad,
    this.categoria,
    this.categoriaNueva,
    this.origen,
    this.motivo,
    this.unidadOrigenId,
    this.unidadDestinoId,
    this.tratamiento,
    this.recursoId,
    this.dosis,
    this.responsable,
    this.movimientoStockId,
    this.superficieHa,
    this.cantidadObtenida,
    this.unidadMedida,
    this.material,
    this.densidad,
    this.humedad,
    this.objetivoMonitoreo,
    this.nivel,
    this.fuenteDato,
    this.recomendacion,
    this.recetaNumero,
    this.vientoKmh,
    this.temperatura,
    this.humedadAmbiente,
  });

  /// Lo cosechado pasado a toneladas (null si no hay dato o unidad).
  double? get toneladas {
    final c = cantidadObtenida;
    if (c == null) return null;
    switch (unidadMedida) {
      case 'tn':
        return c;
      case 'kg':
        return c / 1000;
      case 'qq':
        return c / 10;
    }
    return null;
  }

  bool get esDelLanzamiento => tiposEventoLanzamiento.contains(tipo);

  /// Revisa que el evento tenga lo minimo segun su tipo.
  /// Devuelve la lista de problemas; vacia = esta bien.
  List<String> validar() {
    final errores = <String>[];

    if (activoAgroId.trim().isEmpty) errores.add('Falta el Activo.');
    if (grupoId.trim().isEmpty) errores.add('Falta el grupo.');
    if (cargadoPor.trim().isEmpty) errores.add('Falta quien lo cargo.');
    if (fechaHecho.isAfter(fechaCarga)) {
      errores.add('La fecha del hecho no puede ser posterior a la carga.');
    }

    bool vacio(String? texto) => texto == null || texto.trim().isEmpty;

    void pedirCantidadYCategoria() {
      if (cantidad == null || cantidad! <= 0) {
        errores.add('La cantidad tiene que ser mayor a cero.');
      }
      if (vacio(categoria)) errores.add('Falta la categoria.');
    }

    switch (tipo) {
      case TipoEventoProductivo.alta:
        pedirCantidadYCategoria();
        if (origen == null) errores.add('Falta el origen del alta.');
        break;
      case TipoEventoProductivo.baja:
        pedirCantidadYCategoria();
        if (motivo == null) errores.add('Falta el motivo de la baja.');
        break;
      case TipoEventoProductivo.movimiento:
        pedirCantidadYCategoria();
        if (vacio(unidadOrigenId)) errores.add('Falta desde donde.');
        if (vacio(unidadDestinoId)) errores.add('Falta hacia donde.');
        if (!vacio(unidadOrigenId) && unidadOrigenId == unidadDestinoId) {
          errores.add('El origen y el destino son la misma unidad.');
        }
        break;
      case TipoEventoProductivo.cambioCategoria:
        pedirCantidadYCategoria();
        if (vacio(categoriaNueva)) errores.add('Falta la categoria nueva.');
        if (!vacio(categoriaNueva) && categoria == categoriaNueva) {
          errores.add('La categoria nueva es igual a la anterior.');
        }
        break;
      case TipoEventoProductivo.sanidad:
        if (vacio(tratamiento)) errores.add('Falta el tratamiento o vacuna.');
        if (cantidad != null && cantidad! <= 0) {
          errores.add('La cantidad tiene que ser mayor a cero.');
        }
        break;
      case TipoEventoProductivo.siembra:
        if (superficieHa == null || superficieHa! <= 0) {
          errores.add('Las hectáreas sembradas tienen que ser mayores a cero.');
        }
        if (vacio(unidadId)) errores.add('Falta el lote.');
        break;
      case TipoEventoProductivo.cosecha:
        if (superficieHa == null || superficieHa! <= 0) {
          errores.add('Las hectáreas cosechadas tienen que ser mayores a cero.');
        }
        if (cantidadObtenida == null || cantidadObtenida! < 0) {
          errores.add('Falta cuánto se cosechó.');
        }
        if (!unidadesCosecha.contains(unidadMedida)) {
          errores.add('Falta la unidad (tn, kg o qq).');
        }
        if (humedad != null && (humedad! < 0 || humedad! > 100)) {
          errores.add('La humedad tiene que estar entre 0 y 100.');
        }
        break;
      case TipoEventoProductivo.aplicacion:
        if (superficieHa == null || superficieHa! <= 0) {
          errores.add('Las hectáreas aplicadas tienen que ser mayores a cero.');
        }
        if (vacio(unidadId)) errores.add('Falta el lote.');
        if (vacio(tratamiento)) errores.add('Falta el producto aplicado.');
        if (vacio(dosis)) errores.add('Falta la dosis.');
        if (vientoKmh != null && vientoKmh! < 0) {
          errores.add('El viento no puede ser negativo.');
        }
        if (temperatura != null && (temperatura! < -30 || temperatura! > 60)) {
          errores.add('La temperatura tiene que estar entre -30 y 60 °C.');
        }
        if (humedadAmbiente != null &&
            (humedadAmbiente! < 0 || humedadAmbiente! > 100)) {
          errores.add('La humedad del aire tiene que estar entre 0 y 100.');
        }
        break;
      case TipoEventoProductivo.monitoreo:
        if (!objetivosMonitoreo.contains(objetivoMonitoreo)) {
          errores.add('Falta qué se miró.');
        }
        if (vacio(observaciones)) errores.add('Falta qué se vio.');
        if (!nivelesMonitoreo.contains(nivel)) {
          errores.add('Falta el nivel (bajo, medio o alto).');
        }
        if (!fuentesDato.contains(fuenteDato)) {
          errores.add('Falta de dónde sale el dato.');
        }
        break;
      default:
        // Tipos preparados: por ahora solo se piden los datos comunes.
        break;
    }

    return errores;
  }

  factory EventoProductivo.fromMap(Map<String, dynamic> map, String id) {
    final tipo = _buscar(TipoEventoProductivo.values, map['tipo']);
    if (tipo == null) {
      throw FormatException('TipoEventoProductivo invalido: ${map['tipo']}');
    }

    return EventoProductivo(
      eventoId: id,
      activoAgroId: map['activoAgroId'] as String? ?? '',
      grupoId: map['grupoId'] as String? ?? '',
      unidadId: map['unidadId'] as String?,
      tipo: tipo,
      fechaHecho: _leerFecha(map['fechaHecho']),
      fechaCarga: _leerFecha(map['fechaCarga']),
      cargadoPor: map['cargadoPor'] as String? ?? '',
      estadoDato: _buscar(EstadoDatoEvento.values, map['estadoDato']) ??
          EstadoDatoEvento.declarado,
      evidenciaIds: List<String>.from(map['evidenciaIds'] as List? ?? const []),
      trabajoId: map['trabajoId'] as String?,
      corrigeEventoId: map['corrigeEventoId'] as String?,
      observaciones: map['observaciones'] as String?,
      cantidad: (map['cantidad'] as num?)?.toInt(),
      categoria: map['categoria'] as String?,
      categoriaNueva: map['categoriaNueva'] as String?,
      origen: _buscar(OrigenAlta.values, map['origen']),
      motivo: _buscar(MotivoBaja.values, map['motivo']),
      unidadOrigenId: map['unidadOrigenId'] as String?,
      unidadDestinoId: map['unidadDestinoId'] as String?,
      tratamiento: map['tratamiento'] as String?,
      recursoId: map['recursoId'] as String?,
      dosis: map['dosis'] as String?,
      responsable: map['responsable'] as String?,
      movimientoStockId: map['movimientoStockId'] as String?,
      superficieHa: (map['superficieHa'] as num?)?.toDouble(),
      cantidadObtenida: (map['cantidadObtenida'] as num?)?.toDouble(),
      unidadMedida: map['unidadMedida'] as String?,
      material: map['material'] as String?,
      densidad: map['densidad'] as String?,
      humedad: (map['humedad'] as num?)?.toDouble(),
      objetivoMonitoreo: map['objetivoMonitoreo'] as String?,
      nivel: map['nivel'] as String?,
      fuenteDato: map['fuenteDato'] as String?,
      recomendacion: map['recomendacion'] as String?,
      recetaNumero: map['recetaNumero'] as String?,
      vientoKmh: (map['vientoKmh'] as num?)?.toDouble(),
      temperatura: (map['temperatura'] as num?)?.toDouble(),
      humedadAmbiente: (map['humedadAmbiente'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventoId': eventoId,
      'activoAgroId': activoAgroId,
      'grupoId': grupoId,
      'unidadId': unidadId,
      'tipo': tipo.name,
      'fechaHecho': Timestamp.fromDate(fechaHecho),
      'fechaCarga': Timestamp.fromDate(fechaCarga),
      'cargadoPor': cargadoPor,
      'estadoDato': estadoDato.name,
      'evidenciaIds': evidenciaIds,
      'trabajoId': trabajoId,
      'corrigeEventoId': corrigeEventoId,
      'observaciones': observaciones,
      'cantidad': cantidad,
      'categoria': categoria,
      'categoriaNueva': categoriaNueva,
      'origen': origen?.name,
      'motivo': motivo?.name,
      'unidadOrigenId': unidadOrigenId,
      'unidadDestinoId': unidadDestinoId,
      'tratamiento': tratamiento,
      'recursoId': recursoId,
      'dosis': dosis,
      'responsable': responsable,
      'movimientoStockId': movimientoStockId,
      'superficieHa': superficieHa,
      'cantidadObtenida': cantidadObtenida,
      'unidadMedida': unidadMedida,
      'material': material,
      'densidad': densidad,
      'humedad': humedad,
      'objetivoMonitoreo': objetivoMonitoreo,
      'nivel': nivel,
      'fuenteDato': fuenteDato,
      'recomendacion': recomendacion,
      'recetaNumero': recetaNumero,
      'vientoKmh': vientoKmh,
      'temperatura': temperatura,
      'humedadAmbiente': humedadAmbiente,
    };
  }

  static T? _buscar<T extends Enum>(List<T> valores, dynamic valor) {
    for (final item in valores) {
      if (item.name == valor) return item;
    }
    return null;
  }

  static DateTime _leerFecha(dynamic valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor) ?? DateTime.now();
    return DateTime.now();
  }
}
