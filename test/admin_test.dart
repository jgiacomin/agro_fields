import 'package:agro_fields/core/auth/admin.dart';
import 'package:agro_fields/models/plan_usuario_model.dart';
import 'package:agro_fields/services/admin_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// GAP-ADMIN-01: tareas del administrador (sin Firebase).
void main() {
  test('ADMIN-T1. Reconoce al administrador por su código', () {
    expect(esAdminPorUid('RtUPcWdZHuQMNsDrza7firR2X2j1'), isTrue);
    expect(esAdminPorUid('otro'), isFalse);
    expect(esAdminPorUid(null), isFalse);
  });

  test('ADMIN-T2. Plan Fundador según el grupo, 12 meses', () {
    final inicio = DateTime(2026, 12, 15);
    final g = AdminService.planFundador('u1', GrupoFundador.gestion, inicio);
    expect(g.plan, TipoPlan.proProductor);
    expect(g.fechaFin, DateTime(2027, 12, 15));
    final i = AdminService.planFundador('u2', GrupoFundador.inmobiliaria, inicio);
    expect(i.plan, TipoPlan.proBroker);
    expect(i.esFundador, isTrue);
  });

  test('ADMIN-T3. Cuenta Fundadores por grupo', () {
    final lista = [
      AdminService.planFundador('a', GrupoFundador.gestion, DateTime(2026, 12, 1)),
      AdminService.planFundador('b', GrupoFundador.gestion, DateTime(2026, 12, 1)),
      AdminService.planFundador('c', GrupoFundador.inmobiliaria, DateTime(2026, 12, 1)),
      PlanUsuario.esencial('d'),
    ];
    final c = AdminService.contarPorGrupo(lista);
    expect(c[GrupoFundador.gestion], 2);
    expect(c[GrupoFundador.inmobiliaria], 1);
    expect(AdminService.cupoFundadores, 100);
  });

  test('ADMIN-T4. Revisión del código pegado', () {
    expect(AdminService.revisarCodigo(''), isNotNull);
    expect(AdminService.revisarCodigo('a/b'), isNotNull);
    expect(AdminService.revisarCodigo(' XoXo11mcLzV4 '), isNull);
  });
}
