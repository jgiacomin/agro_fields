import '../models/activos/evento_productivo_model.dart';

/// Calculo de existencias (paso 6a-2, GAP-PROD-01).
///
/// Las existencias NO se escriben a mano: salen de sumar los eventos de un
/// grupo, igual que el saldo de stock. Asi siempre se puede explicar de
/// donde sale cada numero.
///
/// No usa Firebase: recibe la lista de eventos y devuelve el resultado.
/// Por eso se puede probar sin conexion.
///
/// Si una cuenta da negativa (por ejemplo, se vendieron 12 donde habia 10)
/// NO se esconde ni se corrige sola: queda el numero negativo y una
/// discrepancia para revisar (Concepto: los datos contradictorios se
/// conservan como discrepancia).

/// Donde se anota lo que no dice en que unidad esta.
const String sinUbicacion = 'sin_ubicacion';

class DiscrepanciaExistencia {
  final String eventoId;
  final String descripcion;

  const DiscrepanciaExistencia({
    required this.eventoId,
    required this.descripcion,
  });

  @override
  String toString() => '$eventoId: $descripcion';
}

class ResultadoExistencias {
  /// unidadId -> categoria -> cantidad.
  final Map<String, Map<String, int>> porUnidad;
  final List<DiscrepanciaExistencia> discrepancias;

  const ResultadoExistencias({
    required this.porUnidad,
    required this.discrepancias,
  });

  /// Total por categoria, sumando todas las unidades.
  Map<String, int> get porCategoria {
    final total = <String, int>{};
    for (final categorias in porUnidad.values) {
      categorias.forEach((categoria, cantidad) {
        total[categoria] = (total[categoria] ?? 0) + cantidad;
      });
    }
    total.removeWhere((_, cantidad) => cantidad == 0);
    return total;
  }

  int get totalCabezas =>
      porCategoria.values.fold(0, (suma, cantidad) => suma + cantidad);

  bool get hayDiscrepancias => discrepancias.isNotEmpty;
}

/// Calcula las existencias de un grupo a partir de sus eventos.
///
/// [unidadInicialId] es donde arranco el grupo: se usa cuando un alta, una
/// baja o un cambio de categoria no dicen en que unidad pasaron.
ResultadoExistencias calcularExistencias(
  List<EventoProductivo> eventos, {
  String? unidadInicialId,
}) {
  final porUnidad = <String, Map<String, int>>{};
  final discrepancias = <DiscrepanciaExistencia>[];

  // Se recorren en el orden en que pasaron.
  final ordenados = [...eventos]..sort((a, b) {
      final porFecha = a.fechaHecho.compareTo(b.fechaHecho);
      if (porFecha != 0) return porFecha;
      final porCarga = a.fechaCarga.compareTo(b.fechaCarga);
      if (porCarga != 0) return porCarga;
      return a.eventoId.compareTo(b.eventoId);
    });

  String lugar(EventoProductivo e) {
    final unidad = e.unidadId?.trim();
    if (unidad != null && unidad.isNotEmpty) return unidad;
    final inicial = unidadInicialId?.trim();
    if (inicial != null && inicial.isNotEmpty) return inicial;
    return sinUbicacion;
  }

  void sumar(String eventoId, String unidad, String categoria, int cantidad) {
    final categorias = porUnidad.putIfAbsent(unidad, () => <String, int>{});
    final nuevo = (categorias[categoria] ?? 0) + cantidad;
    categorias[categoria] = nuevo;

    if (nuevo < 0) {
      discrepancias.add(DiscrepanciaExistencia(
        eventoId: eventoId,
        descripcion:
            'Queda $nuevo en "$categoria" en la unidad $unidad: salen mas '
            'animales de los que habia registrados.',
      ));
    }
  }

  for (final e in ordenados) {
    if (!_cuentaParaExistencias(e.tipo)) continue;

    final errores = e.validar();
    if (errores.isNotEmpty) {
      discrepancias.add(DiscrepanciaExistencia(
        eventoId: e.eventoId,
        descripcion: 'Evento incompleto, no se conto: ${errores.join(' ')}',
      ));
      continue;
    }

    final cantidad = e.cantidad!;
    final categoria = e.categoria!;

    switch (e.tipo) {
      case TipoEventoProductivo.alta:
        sumar(e.eventoId, lugar(e), categoria, cantidad);
        break;
      case TipoEventoProductivo.baja:
        sumar(e.eventoId, lugar(e), categoria, -cantidad);
        break;
      case TipoEventoProductivo.movimiento:
        sumar(e.eventoId, e.unidadOrigenId!, categoria, -cantidad);
        sumar(e.eventoId, e.unidadDestinoId!, categoria, cantidad);
        break;
      case TipoEventoProductivo.cambioCategoria:
        {
          final unidad = lugar(e);
          sumar(e.eventoId, unidad, categoria, -cantidad);
          sumar(e.eventoId, unidad, e.categoriaNueva!, cantidad);
        }
        break;
      default:
        break;
    }
  }

  // Se sacan los ceros para que el resultado sea facil de leer.
  for (final categorias in porUnidad.values) {
    categorias.removeWhere((_, cantidad) => cantidad == 0);
  }
  porUnidad.removeWhere((_, categorias) => categorias.isEmpty);

  return ResultadoExistencias(
    porUnidad: porUnidad,
    discrepancias: discrepancias,
  );
}

/// Solo estos tipos cambian cuantos animales hay o donde estan.
/// La sanidad, el pesaje, etc. no mueven existencias.
bool _cuentaParaExistencias(TipoEventoProductivo tipo) {
  return tipo == TipoEventoProductivo.alta ||
      tipo == TipoEventoProductivo.baja ||
      tipo == TipoEventoProductivo.movimiento ||
      tipo == TipoEventoProductivo.cambioCategoria;
}
