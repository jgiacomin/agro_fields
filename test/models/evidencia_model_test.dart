import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agro_fields/models/activos/evidencia_model.dart';

void main() {
  test('Evidencia convierte correctamente de Map a modelo y nuevamente a Map', () {
    final fechaHecho = DateTime(2026, 9, 1, 10, 30);
    final fechaRegistro = DateTime(2026, 9, 2, 11, 45);
    final fechaVerificacion = DateTime(2026, 9, 3, 14, 15);

    final map = {
      'activoAgroId': 'activo-001',
      'moduloOrigen': 'suelo',
      'elementoTipo': 'dato',
      'elementoId': null,
      'campoRelacionado': 'ph',
      'tipo': 'analisis_tecnico',
      'descripcion': 'Análisis de pH del suelo',
      'observaciones': 'Muestra tomada en campo',
      'aportanteId': 'usuario-001',
      'fuenteTipo': 'laboratorio',
      'fuenteNombre': 'Laboratorio Agro',
      'fuenteReferencia': 'LAB-2026-001',
      'soporteTipo': 'documento',
      'soporteReferencia': 'storage/evidencias/lab-2026-001.pdf',
      'soporteNombre': 'analisis_ph.pdf',
      'fechaHecho': Timestamp.fromDate(fechaHecho),
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'estadoVerificacion': 'verificada',
      'verificadorId': 'profesional-001',
      'fechaVerificacion': Timestamp.fromDate(fechaVerificacion),
      'observacionVerificacion': 'Resultado revisado',
      'referenciaVerificacion': 'VER-001',
      'estadoValidez': 'vigente_verificado',
    };

    final evidencia = Evidencia.fromMap(
      map,
      'evidencia-001',
    );

    expect(evidencia.evidenciaId, 'evidencia-001');
    expect(evidencia.activoAgroId, 'activo-001');
    expect(evidencia.moduloOrigen, 'suelo');
    expect(evidencia.elementoTipo, 'dato');
    expect(evidencia.campoRelacionado, 'ph');
    expect(evidencia.tipo, 'analisis_tecnico');
    expect(evidencia.descripcion, 'Análisis de pH del suelo');
    expect(evidencia.aportanteId, 'usuario-001');
    expect(evidencia.fuenteNombre, 'Laboratorio Agro');
    expect(evidencia.soporteNombre, 'analisis_ph.pdf');

    expect(evidencia.fechaHecho, fechaHecho);
    expect(evidencia.fechaRegistro, fechaRegistro);
    expect(evidencia.fechaVerificacion, fechaVerificacion);

    expect(
      evidencia.estadoVerificacion,
      'verificada',
    );
    expect(
      evidencia.verificadorId,
      'profesional-001',
    );
    expect(
      evidencia.estadoValidez,
      'vigente_verificado',
    );

    final resultado = evidencia.toMap();

    expect(resultado['evidenciaId'], 'evidencia-001');
    expect(resultado['activoAgroId'], 'activo-001');
    expect(resultado['tipo'], 'analisis_tecnico');
    expect(resultado['descripcion'], 'Análisis de pH del suelo');

    expect(
      (resultado['fechaHecho'] as Timestamp).toDate(),
      fechaHecho,
    );

    expect(
      (resultado['fechaRegistro'] as Timestamp).toDate(),
      fechaRegistro,
    );

    expect(
      (resultado['fechaVerificacion'] as Timestamp).toDate(),
      fechaVerificacion,
    );
  });

  test('Evidencia maneja fechas opcionales correctamente', () {
    final evidencia = Evidencia(
      evidenciaId: 'evidencia-002',
      activoAgroId: 'activo-002',
      tipo: 'fotografica',
      descripcion: 'Fotografía del campo',
      fechaRegistro: DateTime(2026, 9, 4),
      estadoVerificacion: 'pendiente',
      estadoValidez: 'vigente_informado',
    );

    final resultado = evidencia.toMap();

    expect(resultado['fechaHecho'], isNull);
    expect(resultado['fechaVerificacion'], isNull);
    expect(resultado['fechaRegistro'], isA<Timestamp>());
    expect(resultado['estadoVerificacion'], 'pendiente');
    expect(resultado['estadoValidez'], 'vigente_informado');
  });
}