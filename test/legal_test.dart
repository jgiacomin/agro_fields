import 'package:agro_fields/core/legal/textos_legales.dart';
import 'package:agro_fields/models/aceptacion_legal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// GAP-LEGAL-01: aceptación de términos y pedido de baja (sin Firebase).
void main() {
  test('LEGAL-T1. Hay versión y texto de términos y privacidad', () {
    expect(versionLegal, isNotEmpty);
    expect(textoTerminos, contains('no es garante'));
    expect(textoPrivacidad, contains('Anexo por país'));
  });

  test('LEGAL-T2. El ID de la aceptación es usuario__version', () {
    expect(AceptacionLegal.construirId('u1', '1.0'), 'u1__1.0');
    final a = AceptacionLegal(
        usuarioId: 'u1', version: '1.0', fecha: DateTime(2026, 11, 16), plataforma: 'web');
    expect(a.id, 'u1__1.0');
  });

  test('LEGAL-T3. Aceptación: ida y vuelta por Firestore', () {
    final a = AceptacionLegal(
        usuarioId: 'u1', version: '1.0', fecha: DateTime(2026, 11, 16), plataforma: 'android');
    final m = a.toMap();
    expect(m['fecha'], isA<Timestamp>());
    final b = AceptacionLegal.fromMap(m);
    expect(b.version, '1.0');
    expect(b.fecha, DateTime(2026, 11, 16));
  });

  test('LEGAL-T4. Confirmar la baja exige escribir BORRAR', () {
    expect(SolicitudBaja.confirma('BORRAR'), isTrue);
    expect(SolicitudBaja.confirma('  borrar '), isTrue);
    expect(SolicitudBaja.confirma('borra'), isFalse);
    expect(SolicitudBaja.confirma(''), isFalse);
  });

  test('LEGAL-T5. El pedido de baja se completa a más tardar a los 30 días', () {
    final p = SolicitudBaja(usuarioId: 'u1', fechaPedido: DateTime(2026, 11, 16));
    expect(p.fechaLimite, DateTime(2026, 12, 16));
    expect(p.validar(), isEmpty);
  });

  test('LEGAL-T6. Un pedido nuevo no puede nacer completado ni con motivo enorme', () {
    final completo = SolicitudBaja(
        usuarioId: 'u1', fechaPedido: DateTime(2026, 11, 16), estado: 'completada');
    expect(completo.validar(), isNotEmpty);
    final largo = SolicitudBaja(
        usuarioId: 'u1', fechaPedido: DateTime(2026, 11, 16), motivo: 'x' * 501);
    expect(largo.validar(), isNotEmpty);
  });

  test('LEGAL-T7. Un estado raro se lee como pendiente', () {
    final p = SolicitudBaja.fromMap({
      'usuarioId': 'u1',
      'fechaPedido': Timestamp.fromDate(DateTime(2026, 11, 16)),
      'estado': 'inventado',
    });
    expect(p.estado, 'pendiente');
  });
}
