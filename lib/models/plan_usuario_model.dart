import 'package:cloud_firestore/cloud_firestore.dart';

/// GAP-PLAN-01 (16/11/2026): el plan de cada usuario.
///
/// Colección `planes_usuarios`, un documento por usuario (ID = usuario).
/// Solo el administrador la escribe (desde la consola de Firebase); cada
/// usuario lee la suya. Si no hay documento, el usuario es Esencial.
/// En 2027 no se cobra ni se corta nada: los límites solo se informan.
enum TipoPlan { esencial, proProductor, proBroker, business, businessInmobiliaria }

/// Grupo de los Fundadores (100 de cada uno).
enum GrupoFundador { gestion, inmobiliaria }

class PlanUsuario {
  static const String coleccion = 'planes_usuarios';

  /// Meses de Pro gratis para los Fundadores.
  static const int mesesFundador = 12;

  /// Descuento para siempre del Fundador que pasa a pagar.
  static const double descuentoFundador = 0.40;

  /// Precio de referencia en dólares por mes (decidido 16/11/2026).
  static const Map<TipoPlan, int> precioUsd = {
    TipoPlan.esencial: 0,
    TipoPlan.proProductor: 19,
    TipoPlan.proBroker: 39,
    TipoPlan.business: 79,
    TipoPlan.businessInmobiliaria: 89,
  };

  /// Límites (null = sin límite). En 2027 solo se informan.
  static const Map<TipoPlan, int?> personasInvitadas = {
    TipoPlan.esencial: 2,
    TipoPlan.proProductor: 10,
    TipoPlan.proBroker: 1,
    TipoPlan.business: null,
    TipoPlan.businessInmobiliaria: 10,
  };

  static const Map<TipoPlan, int?> camposPublicados = {
    TipoPlan.esencial: 1,
    TipoPlan.proProductor: 5,
    TipoPlan.proBroker: 15,
    TipoPlan.business: null,
    TipoPlan.businessInmobiliaria: null,
  };

  static const Map<TipoPlan, String> espacioArchivos = {
    TipoPlan.esencial: '500 MB',
    TipoPlan.proProductor: '10 GB',
    TipoPlan.proBroker: '10 GB',
    TipoPlan.business: '50 GB',
    TipoPlan.businessInmobiliaria: '50 GB',
  };

  final String usuarioId;
  final TipoPlan plan;
  final GrupoFundador? grupoFundador;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const PlanUsuario({
    required this.usuarioId,
    this.plan = TipoPlan.esencial,
    this.grupoFundador,
    this.fechaInicio,
    this.fechaFin,
  });

  /// Plan por defecto cuando no hay nada cargado.
  factory PlanUsuario.esencial(String usuarioId) =>
      PlanUsuario(usuarioId: usuarioId);

  bool get esFundador => grupoFundador != null;

  /// true si el plan pago (o el período Fundador) sigue vigente hoy.
  bool vigente(DateTime hoy) =>
      plan == TipoPlan.esencial || fechaFin == null || !hoy.isAfter(fechaFin!);

  /// El plan que rige hoy: si venció, vuelve a Esencial.
  TipoPlan planEfectivo(DateTime hoy) =>
      vigente(hoy) ? plan : TipoPlan.esencial;

  /// Lo que pagaría por mes (en dólares) el Fundador al terminar el
  /// período gratis, con su descuento para siempre (redondeado).
  int? precioFundadorUsd() {
    if (!esFundador) return null;
    final base = precioUsd[plan] ?? 0;
    return (base * (1 - descuentoFundador)).round();
  }

  /// Fin del período Fundador a partir del alta (12 meses).
  static DateTime finFundador(DateTime inicio) =>
      DateTime(inicio.year + 1, inicio.month, inicio.day);

  Map<String, dynamic> toMap() => {
        'usuarioId': usuarioId,
        'plan': plan.name,
        'grupoFundador': grupoFundador?.name,
        'fechaInicio': fechaInicio == null ? null : Timestamp.fromDate(fechaInicio!),
        'fechaFin': fechaFin == null ? null : Timestamp.fromDate(fechaFin!),
      };

  /// Un valor desconocido se lee como Esencial (nunca como más).
  factory PlanUsuario.fromMap(Map<String, dynamic> map, String id) {
    TipoPlan plan = TipoPlan.esencial;
    for (final p in TipoPlan.values) {
      if (p.name == map['plan']) plan = p;
    }
    GrupoFundador? grupo;
    for (final g in GrupoFundador.values) {
      if (g.name == map['grupoFundador']) grupo = g;
    }
    return PlanUsuario(
      usuarioId: id,
      plan: plan,
      grupoFundador: grupo,
      fechaInicio: _fecha(map['fechaInicio']),
      fechaFin: _fecha(map['fechaFin']),
    );
  }

  static DateTime? _fecha(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}

String nombrePlan(TipoPlan p) {
  switch (p) {
    case TipoPlan.esencial:
      return 'Esencial (gratis)';
    case TipoPlan.proProductor:
      return 'Pro Productor';
    case TipoPlan.proBroker:
      return 'Pro Broker';
    case TipoPlan.business:
      return 'Business';
    case TipoPlan.businessInmobiliaria:
      return 'Business Inmobiliaria';
  }
}

String textoLimite(int? n) => n == null ? 'Sin límite' : '$n';
