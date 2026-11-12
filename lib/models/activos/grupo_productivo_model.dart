import 'package:cloud_firestore/cloud_firestore.dart';

/// Grupo productivo (paso 6a, GAP-PROD-01): QUE se produce.
/// En ganaderia es un rodeo o un lote de animales.
///
/// Las existencias NO se guardan en el grupo: se calculan sumando sus
/// eventos (alta, baja, cambio de categoria), igual que el stock.
/// Asi siempre se puede explicar de donde sale cada numero.
///
/// Por ahora se identifica por lote (cantidad por categoria). El registro
/// por animal, con caravana, queda preparado (ModoIdentificacion.porAnimal).
enum EtapaGanadera {
  cria,
  recriaPastoril,
  recriaCorral,
  recriaMixta,
  terminacion,
  feedlot,
  otra,
}

/// De quien son los animales (Concepto 5.2). Cambia el dueno de los
/// animales aunque esten en el mismo campo.
enum TenenciaAnimales {
  propios,
  capitalizacion,
  hoteleria,
  desconocida,
}

enum ModoIdentificacion {
  porLote,
  porAnimal,
}

enum EstadoGrupoProductivo {
  activo,
  cerrado,
}

/// Categorias base de ganaderia. Cada productor puede sumar las suyas:
/// por eso la categoria de un evento es texto libre y no una lista fija.
const List<String> categoriasGanaderasBase = [
  'vaca',
  'vaquillona',
  'toro',
  'ternero',
  'ternera',
  'novillito',
  'novillo',
];

/// GAP-AGRO-01 (12/11/2026): cultivos base de agricultura. Como las
/// categorías ganaderas, el cultivo es texto: el productor puede usar otro.
const List<String> cultivosBase = [
  'soja',
  'maiz',
  'trigo',
  'girasol',
  'sorgo',
  'algodon',
  'arroz',
  'pastura',
  'otro',
];

class GrupoProductivo {
  final String grupoId;
  final String activoAgroId;

  /// 'ganaderia' por ahora; despues agricultura, tambo, avicultura...
  final String actividad;
  final String nombre;

  /// null = no se sabe o no aplica.
  final EtapaGanadera? etapa;
  final TenenciaAnimales tenencia;
  final ModoIdentificacion modoIdentificacion;

  /// Donde arranco el grupo. Donde esta hoy se calcula con los movimientos.
  final String? unidadInicialId;
  final String? moduloProduccionId;
  final String? cicloId;

  final EstadoGrupoProductivo estado;

  final String creadoPor;
  final DateTime fechaCreacion;

  final String? observaciones;

  // GAP-AGRO-01: en agricultura el grupo es "el cultivo de la campaña"
  // (ej.: Soja 2026/27 en el Lote 3). En ganadería quedan vacíos.
  final String? cultivo;
  final String? campania;

  /// Variedad o híbrido declarado.
  final String? material;

  const GrupoProductivo({
    required this.grupoId,
    required this.activoAgroId,
    required this.actividad,
    required this.nombre,
    required this.creadoPor,
    required this.fechaCreacion,
    this.etapa,
    this.tenencia = TenenciaAnimales.desconocida,
    this.modoIdentificacion = ModoIdentificacion.porLote,
    this.unidadInicialId,
    this.moduloProduccionId,
    this.cicloId,
    this.estado = EstadoGrupoProductivo.activo,
    this.observaciones,
    this.cultivo,
    this.campania,
    this.material,
  });

  bool get esAgricola => actividad == 'agricultura';

  factory GrupoProductivo.fromMap(Map<String, dynamic> map, String id) {
    return GrupoProductivo(
      grupoId: id,
      activoAgroId: map['activoAgroId'] as String? ?? '',
      actividad: map['actividad'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      etapa: _buscar(EtapaGanadera.values, map['etapa']),
      tenencia: _buscar(TenenciaAnimales.values, map['tenencia']) ??
          TenenciaAnimales.desconocida,
      modoIdentificacion:
          _buscar(ModoIdentificacion.values, map['modoIdentificacion']) ??
              ModoIdentificacion.porLote,
      unidadInicialId: map['unidadInicialId'] as String?,
      moduloProduccionId: map['moduloProduccionId'] as String?,
      cicloId: map['cicloId'] as String?,
      estado: map['estado'] == EstadoGrupoProductivo.cerrado.name
          ? EstadoGrupoProductivo.cerrado
          : EstadoGrupoProductivo.activo,
      creadoPor: map['creadoPor'] as String? ?? '',
      fechaCreacion: _leerFecha(map['fechaCreacion']),
      observaciones: map['observaciones'] as String?,
      cultivo: map['cultivo'] as String?,
      campania: map['campania'] as String?,
      material: map['material'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grupoId': grupoId,
      'activoAgroId': activoAgroId,
      'actividad': actividad,
      'nombre': nombre,
      'etapa': etapa?.name,
      'tenencia': tenencia.name,
      'modoIdentificacion': modoIdentificacion.name,
      'unidadInicialId': unidadInicialId,
      'moduloProduccionId': moduloProduccionId,
      'cicloId': cicloId,
      'estado': estado.name,
      'creadoPor': creadoPor,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'observaciones': observaciones,
      'cultivo': cultivo,
      'campania': campania,
      'material': material,
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
