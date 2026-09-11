import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/documento_activo_model.dart';

void main() {
  group('DocumentoActivo', () {
    test('toMap y fromMap conservan los datos del documento', () {
      final fecha = DateTime(2026, 9, 11, 10, 30);

      final documento = DocumentoActivo(
        documentoId: 'doc-001',
        tipo: 'titulo_propiedad',
        descripcion: 'TÃ­tulo de propiedad del inmueble',
        fecha: fecha,
        estado: 'documentado',
        responsableId: 'usuario-001',
        evidenciaIds: ['evidencia-001', 'evidencia-002'],
        observaciones: 'Documento recibido para revisiÃ³n.',
      );

      final map = documento.toMap();

      final recuperado = DocumentoActivo.fromMap(
        map,
        'doc-001',
      );

      expect(recuperado.documentoId, 'doc-001');
      expect(recuperado.tipo, 'titulo_propiedad');
      expect(
        recuperado.descripcion,
        'TÃ­tulo de propiedad del inmueble',
      );
      expect(recuperado.fecha, fecha);
      expect(recuperado.estado, 'documentado');
      expect(recuperado.responsableId, 'usuario-001');
      expect(
        recuperado.evidenciaIds,
        ['evidencia-001', 'evidencia-002'],
      );
      expect(
        recuperado.observaciones,
        'Documento recibido para revisiÃ³n.',
      );
    });

    test('fromMap convierte Timestamp a DateTime', () {
      final fecha = DateTime(2026, 9, 11, 12, 0);

      final map = {
        'tipo': 'certificacion_ambiental',
        'descripcion': 'CertificaciÃ³n ambiental vigente',
        'fecha': Timestamp.fromDate(fecha),
        'estado': 'validado',
        'responsableId': 'usuario-002',
        'evidenciaIds': ['evidencia-003'],
        'observaciones': 'Validada.',
      };

      final documento = DocumentoActivo.fromMap(
        map,
        'doc-002',
      );

      expect(documento.documentoId, 'doc-002');
      expect(documento.fecha, fecha);
      expect(documento.estado, 'validado');
      expect(
        documento.evidenciaIds,
        ['evidencia-003'],
      );
    });

    test('copyWith modifica solamente los campos indicados', () {
      final documento = DocumentoActivo(
        documentoId: 'doc-003',
        tipo: 'permiso_explotacion',
        descripcion: 'Permiso de explotaciÃ³n',
        fecha: DateTime(2026, 9, 10),
        estado: 'pendiente',
        responsableId: 'usuario-003',
        evidenciaIds: ['evidencia-004'],
        observaciones: 'Pendiente de revisiÃ³n.',
      );

      final actualizado = documento.copyWith(
        estado: 'validado',
        evidenciaIds: ['evidencia-004', 'evidencia-005'],
      );

      expect(actualizado.documentoId, 'doc-003');
      expect(actualizado.tipo, 'permiso_explotacion');
      expect(
        actualizado.descripcion,
        'Permiso de explotaciÃ³n',
      );
      expect(actualizado.estado, 'validado');
      expect(
        actualizado.evidenciaIds,
        ['evidencia-004', 'evidencia-005'],
      );
      expect(
        actualizado.observaciones,
        'Pendiente de revisiÃ³n.',
      );
    });
  }
  )
  }
