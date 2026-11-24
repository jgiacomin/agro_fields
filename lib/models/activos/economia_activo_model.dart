import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agro_fields/models/activos/dato_economico_model.dart';

class EconomiaActivo {

  // ==========================
  // NUEVA TRAZABILIDAD ECONÓMICA V8
  // ==========================


  /// Objetivo general declarado del proyecto
  final String objetivoProyecto;


  /// Etapa actual del proyecto
  /// Ejemplo:
  /// idea, inicial, producción, expansión
  final String etapaProyecto;


  /// Capital esperado para desarrollar el proyecto
  final double inversionEsperada;


  /// Capacidad productiva actual declarada
  final String capacidadActual;


  /// Capacidad productiva proyectada
  final String capacidadProyectada;


  /// Riesgos identificados por el responsable
  final String riesgosIdentificados;


  /// Fuente de la información económica
  /// productor, propietario, profesional, auditoría
  final String origenInformacion;


  /// Persona responsable de declarar la información
  final String responsableDeclaracion;

  // ==========================
  // CAMPOS ECONÓMICOS EXISTENTES
  // ==========================


  final double valorSolicitado;


  final String moneda;


  final String tipoOperacion;


  final double capitalRequerido;


  final String ingresosEstimados;


  final String costosEstimados;


  final String rentabilidadDeclarada;


  final String periodoEvaluacion;


  final List<DatoEconomico> datosEconomicos;


  final DateTime fechaActualizacion;

  /// GAP-MERC-01 Parte A (24/11/2026): lo que se ofrece en el Mercado
  /// (venta, alquiler y/o arrendamiento, cada una con su precio).
  final List<OfertaMercado> ofertas;

  EconomiaActivo({

    required this.objetivoProyecto,

    required this.etapaProyecto,

    required this.inversionEsperada,

    required this.capacidadActual,

    required this.capacidadProyectada,

    required this.riesgosIdentificados,

    required this.origenInformacion,

    required this.responsableDeclaracion,


    required this.valorSolicitado,

    required this.moneda,

    required this.tipoOperacion,

    required this.capitalRequerido,

    required this.ingresosEstimados,

    required this.costosEstimados,

    required this.rentabilidadDeclarada,

    required this.periodoEvaluacion,

    required this.datosEconomicos,

    required this.fechaActualizacion,

    this.ofertas = const [],

  });


  factory EconomiaActivo.fromMap(
      Map<String,dynamic> map
      ){

    return EconomiaActivo(


      objetivoProyecto:
      map['objetivoProyecto'] ?? '',


      etapaProyecto:
      map['etapaProyecto'] ?? '',


      inversionEsperada:
      (map['inversionEsperada'] ?? 0).toDouble(),


      capacidadActual:
      map['capacidadActual'] ?? '',


      capacidadProyectada:
      map['capacidadProyectada'] ?? '',


      riesgosIdentificados:
      map['riesgosIdentificados'] ?? '',


      origenInformacion:
      map['origenInformacion'] ?? '',


      responsableDeclaracion:
      map['responsableDeclaracion'] ?? '',

      valorSolicitado:
      (map['valorSolicitado'] ?? 0).toDouble(),


      moneda:
      map['moneda'] ?? 'USD',


      tipoOperacion:
      map['tipoOperacion'] ?? '',


      capitalRequerido:
      (map['capitalRequerido'] ?? 0).toDouble(),


      ingresosEstimados:
      map['ingresosEstimados'] ?? '',


      costosEstimados:
      map['costosEstimados'] ?? '',


      rentabilidadDeclarada:
      map['rentabilidadDeclarada'] ?? '',


      periodoEvaluacion:
map['periodoEvaluacion'] ?? '',
   datosEconomicos:
    map['datosEconomicos'] is List
        ? (map['datosEconomicos'] as List<dynamic>)
            .map(
              (item) => DatoEconomico.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : [],

      fechaActualizacion:

      map['fechaActualizacion'] is Timestamp

          ? (map['fechaActualizacion'] as Timestamp).toDate()

          : map['fechaActualizacion'] is DateTime

              ? map['fechaActualizacion']

              : DateTime.now(),

      ofertas: OfertaMercado.listaDesde(map['ofertas']),

    );

  }

  Map<String,dynamic> toMap(){

    return {


      // Nueva trazabilidad V8

      'objetivoProyecto':
      objetivoProyecto,


      'etapaProyecto':
      etapaProyecto,


      'inversionEsperada':
      inversionEsperada,


      'capacidadActual':
      capacidadActual,


      'capacidadProyectada':
      capacidadProyectada,


      'riesgosIdentificados':
      riesgosIdentificados,


      'origenInformacion':
      origenInformacion,


      'responsableDeclaracion':
      responsableDeclaracion,

      // Economía existente

      'valorSolicitado':
      valorSolicitado,


      'moneda':
      moneda,


      'tipoOperacion':
      tipoOperacion,


      'capitalRequerido':
      capitalRequerido,


      'ingresosEstimados':
      ingresosEstimados,


      'costosEstimados':
      costosEstimados,


      'rentabilidadDeclarada':
      rentabilidadDeclarada,


      'periodoEvaluacion':
      periodoEvaluacion,


      'datosEconomicos':
    datosEconomicos
        .map((dato) => dato.toMap())
        .toList(),


      'fechaActualizacion':
      fechaActualizacion,

      'ofertas':
      ofertas.map((o) => o.toMap()).toList(),

    };

  }

  factory EconomiaActivo.inicial(){

    return EconomiaActivo(


      objetivoProyecto:
      '',


      etapaProyecto:
      'inicial',


      inversionEsperada:
      0,


      capacidadActual:
      '',


      capacidadProyectada:
      '',


      riesgosIdentificados:
      '',


      origenInformacion:
      'productor',


      responsableDeclaracion:
      '',




      valorSolicitado:
      0,


      moneda:
      'USD',


      tipoOperacion:
      '',


      capitalRequerido:
      0,


      ingresosEstimados:
      '',


      costosEstimados:
      '',


      rentabilidadDeclarada:
      '',


      periodoEvaluacion:
      '',


      datosEconomicos:
        [],


      fechaActualizacion:
      DateTime.now(),

    );

  }


}

/// GAP-MERC-01 Parte A (24/11/2026): una oferta del campo en el Mercado.
/// Va en el expediente (Economía) y se copia al resumen público.
class OfertaMercado {
  /// venta | alquiler | arrendamiento
  final String operacion;

  /// null = "Consultar precio".
  final double? precio;

  /// USD | ARS | PYG | UYU
  final String moneda;

  /// total | hectarea | hectarea_anio
  final String precioPor;

  const OfertaMercado({
    required this.operacion,
    required this.precio,
    required this.moneda,
    required this.precioPor,
  });

  static const operaciones = ['venta', 'alquiler', 'arrendamiento'];
  static const monedas = ['USD', 'ARS', 'PYG', 'UYU'];

  factory OfertaMercado.fromMap(Map<String, dynamic> map) {
    return OfertaMercado(
      operacion: map['operacion'] as String? ?? 'venta',
      precio: (map['precio'] as num?)?.toDouble(),
      moneda: map['moneda'] as String? ?? 'USD',
      precioPor: map['precioPor'] as String? ?? 'total',
    );
  }

  static List<OfertaMercado> listaDesde(dynamic valor) {
    if (valor is! List) return const [];
    return [
      for (final item in valor)
        if (item is Map) OfertaMercado.fromMap(Map<String, dynamic>.from(item)),
    ];
  }

  Map<String, dynamic> toMap() => {
        'operacion': operacion,
        'precio': precio,
        'moneda': moneda,
        'precioPor': precioPor,
      };

  String get nombreOperacion => switch (operacion) {
        'alquiler' => 'Alquiler',
        'arrendamiento' => 'Arrendamiento',
        _ => 'Venta',
      };

  /// "6.000.000" (miles con punto, como se escribe en la región).
  static String numero(double v) {
    final entero = v.truncate();
    final s = entero.abs().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    final dec = ((v - entero).abs() * 100).round();
    return '${entero < 0 ? '-' : ''}$b${dec > 0 ? ',${dec.toString().padLeft(2, '0')}' : ''}';
  }

  /// "USD 6.000.000", "USD 250/ha/año" o "Consultar precio".
  String get textoPrecio {
    final p = precio;
    if (p == null) return 'Consultar precio';
    final unidad = switch (precioPor) {
      'hectarea' => '/ha',
      'hectarea_anio' => '/ha/año',
      _ => '',
    };
    return '$moneda ${numero(p)}$unidad';
  }

  /// "Venta · USD 6.000.000"
  String get texto => '$nombreOperacion · $textoPrecio';
}
