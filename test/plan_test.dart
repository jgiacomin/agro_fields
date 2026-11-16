import 'package:agro_fields/models/plan_usuario_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// GAP-PLAN-01: plan del usuario (sin Firebase).
void main() {
  final hoy = DateTime(2027, 3, 1);

  test('PLAN-T1. Sin nada cargado, el usuario es Esencial y gratis', () {
    final p = PlanUsuario.esencial('u1');
    expect(p.plan, TipoPlan.esencial);
    expect(p.esFundador, isFalse);
    expect(PlanUsuario.precioUsd[p.planEfectivo(hoy)], 0);
  });

  test('PLAN-T2. Precios decididos: 19, 39, 79, 89', () {
    expect(PlanUsuario.precioUsd[TipoPlan.proProductor], 19);
    expect(PlanUsuario.precioUsd[TipoPlan.proBroker], 39);
    expect(PlanUsuario.precioUsd[TipoPlan.business], 79);
    expect(PlanUsuario.precioUsd[TipoPlan.businessInmobiliaria], 89);
  });

  test('PLAN-T3. Fundador: 12 meses gratis y después 40% de descuento', () {
    final inicio = DateTime(2027, 1, 15);
    final p = PlanUsuario(
      usuarioId: 'u1',
      plan: TipoPlan.proProductor,
      grupoFundador: GrupoFundador.gestion,
      fechaInicio: inicio,
      fechaFin: PlanUsuario.finFundador(inicio),
    );
    expect(p.fechaFin, DateTime(2028, 1, 15));
    expect(p.precioFundadorUsd(), 11);
    final broker = PlanUsuario(
        usuarioId: 'u2', plan: TipoPlan.proBroker, grupoFundador: GrupoFundador.inmobiliaria);
    expect(broker.precioFundadorUsd(), 23);
  });

  test('PLAN-T4. Al vencer el período, vuelve a Esencial', () {
    final p = PlanUsuario(
      usuarioId: 'u1',
      plan: TipoPlan.proProductor,
      grupoFundador: GrupoFundador.gestion,
      fechaFin: DateTime(2028, 1, 15),
    );
    expect(p.planEfectivo(DateTime(2027, 6, 1)), TipoPlan.proProductor);
    expect(p.planEfectivo(DateTime(2028, 1, 15)), TipoPlan.proProductor);
    expect(p.planEfectivo(DateTime(2028, 1, 16)), TipoPlan.esencial);
  });

  test('PLAN-T5. Límites del Esencial: 2 personas, 1 campo, 500 MB', () {
    expect(PlanUsuario.personasInvitadas[TipoPlan.esencial], 2);
    expect(PlanUsuario.camposPublicados[TipoPlan.esencial], 1);
    expect(PlanUsuario.espacioArchivos[TipoPlan.esencial], '500 MB');
    expect(textoLimite(null), 'Sin límite');
  });

  test('PLAN-T6. Ida y vuelta y valores raros se leen como Esencial', () {
    final p = PlanUsuario(
        usuarioId: 'u1', plan: TipoPlan.business, fechaInicio: DateTime(2027, 1, 1));
    final m = p.toMap();
    expect(m['fechaInicio'], isA<Timestamp>());
    expect(PlanUsuario.fromMap(m, 'u1').plan, TipoPlan.business);
    final raro = PlanUsuario.fromMap({'plan': 'oro', 'grupoFundador': 'x'}, 'u1');
    expect(raro.plan, TipoPlan.esencial);
    expect(raro.esFundador, isFalse);
  });
}
