import 'package:flutter/material.dart';

import 'autorizacion_activo_model.dart';

/// GAP-ENC-01 (16/11/2026): qué puede hacer un encargado.
///
/// El dueño tilda ÁREAS; cada área se guarda como varias autorizaciones
/// del paso 3 (rol encargado + permiso + ámbito). Las reglas de Firestore
/// ya reconocen esos ámbitos: no hace falta cambiarlas.
/// El encargado NO ve el expediente privado, los documentos, las
/// operaciones protegidas ni las emergencias.
enum AreaEncargado { produccion, stock, gastos, traslados, territorio }

typedef PermisoEnAmbito = (PermisoAutorizacion, TipoAmbitoAutorizacion);

const Map<AreaEncargado, List<PermisoEnAmbito>> permisosPorArea = {
  AreaEncargado.produccion: [
    (PermisoAutorizacion.ver, TipoAmbitoAutorizacion.produccion),
    (PermisoAutorizacion.crear, TipoAmbitoAutorizacion.produccion),
    (PermisoAutorizacion.modificar, TipoAmbitoAutorizacion.produccion),
  ],
  AreaEncargado.stock: [
    (PermisoAutorizacion.ver, TipoAmbitoAutorizacion.recursosInventario),
    (PermisoAutorizacion.crear, TipoAmbitoAutorizacion.recursosInventario),
    (PermisoAutorizacion.modificar, TipoAmbitoAutorizacion.recursosInventario),
  ],
  AreaEncargado.gastos: [
    (PermisoAutorizacion.ver, TipoAmbitoAutorizacion.economia),
    (PermisoAutorizacion.crear, TipoAmbitoAutorizacion.economia),
  ],
  AreaEncargado.traslados: [
    (PermisoAutorizacion.ver, TipoAmbitoAutorizacion.movimientos),
    (PermisoAutorizacion.crear, TipoAmbitoAutorizacion.movimientos),
    (PermisoAutorizacion.modificar, TipoAmbitoAutorizacion.movimientos),
  ],
  AreaEncargado.territorio: [
    (PermisoAutorizacion.ver, TipoAmbitoAutorizacion.territorio),
    (PermisoAutorizacion.crear, TipoAmbitoAutorizacion.territorio),
  ],
};

String nombreArea(AreaEncargado a) {
  switch (a) {
    case AreaEncargado.produccion:
      return 'Producción';
    case AreaEncargado.stock:
      return 'Stock e insumos';
    case AreaEncargado.gastos:
      return 'Gastos';
    case AreaEncargado.traslados:
      return 'Traslados';
    case AreaEncargado.territorio:
      return 'Historia del territorio';
  }
}

String ayudaArea(AreaEncargado a) {
  switch (a) {
    case AreaEncargado.produccion:
      return 'Rodeos, cultivos, eventos, pesajes, monitoreo, aplicaciones';
    case AreaEncargado.stock:
      return 'Semillas, productos, combustible';
    case AreaEncargado.gastos:
      return 'Cargar y ver los gastos del campo';
    case AreaEncargado.traslados:
      return 'Salidas de hacienda, granos y más';
    case AreaEncargado.territorio:
      return 'Desmontes, canales, caminos...';
  }
}

IconData iconoArea(AreaEncargado a) {
  switch (a) {
    case AreaEncargado.produccion:
      return Icons.pets;
    case AreaEncargado.stock:
      return Icons.inventory_2;
    case AreaEncargado.gastos:
      return Icons.payments_outlined;
    case AreaEncargado.traslados:
      return Icons.local_shipping;
    case AreaEncargado.territorio:
      return Icons.landscape;
  }
}

/// Es una autorización de encargado sobre el campo entero.
bool esAutorizacionEncargado(AutorizacionActivo a) =>
    a.rol == RolAutorizacion.encargado &&
    (a.ambito.referenciaId == null || a.ambito.referenciaId!.isEmpty);

bool _vigente(AutorizacionActivo a, DateTime ahora) =>
    a.estado == EstadoAutorizacion.activa &&
    !a.fechaInicio.isAfter(ahora.add(const Duration(minutes: 5))) &&
    (a.fechaFin == null || a.fechaFin!.isAfter(ahora));

/// Áreas habilitadas: las que tienen TODOS sus permisos activos.
Set<AreaEncargado> areasHabilitadas(
    Iterable<AutorizacionActivo> autorizaciones, DateTime ahora) {
  final activos = autorizaciones
      .where((a) => esAutorizacionEncargado(a) && _vigente(a, ahora))
      .map((a) => (a.permiso, a.ambito.tipo))
      .toSet();
  return {
    for (final e in permisosPorArea.entries)
      if (e.value.every(activos.contains)) e.key,
  };
}

/// Un encargado de un campo (agrupa sus autorizaciones).
class EncargadoDelCampo {
  final String usuarioId;
  final String activoId;
  final String nombreActivo;
  final List<AutorizacionActivo> autorizaciones;
  final Set<AreaEncargado> areas;
  final DateTime desde;

  const EncargadoDelCampo({
    required this.usuarioId,
    required this.activoId,
    required this.nombreActivo,
    required this.autorizaciones,
    required this.areas,
    required this.desde,
  });

  bool get activo => areas.isNotEmpty;
}

/// Agrupa autorizaciones de encargado por campo y usuario.
List<EncargadoDelCampo> agruparEncargados(
    Iterable<AutorizacionActivo> todas, DateTime ahora) {
  final grupos = <String, List<AutorizacionActivo>>{};
  for (final a in todas.where(esAutorizacionEncargado)) {
    grupos.putIfAbsent('${a.activoId}|${a.usuarioAutorizado}', () => []).add(a);
  }
  final lista = grupos.values.map((auts) {
    auts.sort((x, y) => x.fechaOtorgamiento.compareTo(y.fechaOtorgamiento));
    return EncargadoDelCampo(
      usuarioId: auts.first.usuarioAutorizado,
      activoId: auts.first.activoId,
      nombreActivo: auts.first.ambito.descripcion ?? 'Campo',
      autorizaciones: auts,
      areas: areasHabilitadas(auts, ahora),
      desde: auts.first.fechaOtorgamiento,
    );
  }).toList()
    ..sort((a, b) => b.desde.compareTo(a.desde));
  return lista;
}
