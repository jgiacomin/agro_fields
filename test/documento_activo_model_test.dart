import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/documento_activo_model.dart';

DocumentoActivo documento({DateTime? vencimiento}) {
  return DocumentoActivo(
    documentoId: 'doc1',
    tipo: 'escritura',
    descripcion: 'Escritura del campo',
    estado: 'documentado',
    evidenciaIds: const [],
    fechaVencimiento: vencimiento,
  );
}

void main() {
  final hoy = DateTime(2026, 11, 6);

  group('DocumentoActivo - vigencia (paso 4a)', () {
    test('sin fecha de vencimiento: no vence', () {
      expect(
        documento().estadoVigencia(hoy: hoy),
        EstadoVigenciaDocumento.sinVencimiento,
      );
    });

    test('vence en más de 30 días: vigente', () {
      expect(
        documento(vencimiento: DateTime(2027, 1, 10)).estadoVigencia(hoy: hoy),
        EstadoVigenciaDocumento.vigente,
      );
    });

    test('vence dentro de 30 días: por vencer', () {
      expect(
        documento(vencimiento: DateTime(2026, 11, 20)).estadoVigencia(hoy: hoy),
        EstadoVigenciaDocumento.porVencer,
      );
    });

    test('justo a 30 días: por vencer', () {
      expect(
        documento(vencimiento: DateTime(2026, 12, 6)).estadoVigencia(hoy: hoy),
        EstadoVigenciaDocumento.porVencer,
      );
    });

    test('ya pasó la fecha: vencido', () {
      expect(
        documento(vencimiento: DateTime(2026, 10, 1)).estadoVigencia(hoy: hoy),
        EstadoVigenciaDocumento.vencido,
      );
    });

    test('los días de aviso se pueden cambiar', () {
      expect(
        documento(vencimiento: DateTime(2026, 11, 20))
            .estadoVigencia(hoy: hoy, diasAviso: 7),
        EstadoVigenciaDocumento.vigente,
      );
    });
  });

  group('DocumentoActivo - valores por defecto seguros', () {
    test('la transferibilidad arranca en "desconocida"', () {
      expect(
        documento().transferibilidad,
        TransferibilidadDocumento.desconocida,
      );
    });

    test('se asume que tiene datos personales hasta que se indique', () {
      expect(documento().contieneDatosPersonales, isTrue);
    });

    test('un documento viejo (sin los datos nuevos) se lee igual', () {
      final viejo = DocumentoActivo.fromMap({
        'tipo': 'permiso',
        'descripcion': 'Permiso de bosque nativo',
        'estado': 'pendiente',
        'evidenciaIds': ['e1'],
      }, 'doc_viejo');

      expect(viejo.tipo, 'permiso');
      expect(viejo.evidenciaIds, ['e1']);
      expect(viejo.fechaVencimiento, isNull);
      expect(viejo.transferibilidad, TransferibilidadDocumento.desconocida);
      expect(viejo.contieneDatosPersonales, isTrue);
      expect(viejo.estadoVigencia(hoy: hoy),
          EstadoVigenciaDocumento.sinVencimiento);
    });

    test('un valor de transferibilidad raro se lee como "desconocida"', () {
      final raro = DocumentoActivo.fromMap({
        'tipo': 'escritura',
        'transferibilidad': 'quizas',
      }, 'doc_raro');

      expect(raro.transferibilidad, TransferibilidadDocumento.desconocida);
    });
  });

  group('DocumentoActivo - guardar y recuperar', () {
    test('conserva todos los datos nuevos', () {
      final original = DocumentoActivo(
        documentoId: 'doc2',
        tipo: 'permiso',
        descripcion: 'Permiso OTBN',
        fecha: DateTime(2026, 1, 15),
        estado: 'documentado',
        evidenciaIds: const ['e1'],
        emisor: 'Secretaría de Ambiente',
        numero: 'EXP-123/2026',
        fechaVencimiento: DateTime(2027, 1, 15),
        pais: 'Argentina',
        provinciaEstado: 'Córdoba',
        transferibilidad: TransferibilidadDocumento.requiereTramite,
        contieneDatosPersonales: false,
        archivoRuta: 'activos/a1/privado/documentos/doc2/permiso.pdf',
      );

      final recuperado =
          DocumentoActivo.fromMap(original.toMap(), original.documentoId);

      expect(recuperado.emisor, 'Secretaría de Ambiente');
      expect(recuperado.numero, 'EXP-123/2026');
      expect(recuperado.fechaVencimiento, DateTime(2027, 1, 15));
      expect(recuperado.pais, 'Argentina');
      expect(recuperado.provinciaEstado, 'Córdoba');
      expect(recuperado.transferibilidad,
          TransferibilidadDocumento.requiereTramite);
      expect(recuperado.contieneDatosPersonales, isFalse);
      expect(recuperado.archivoRuta,
          'activos/a1/privado/documentos/doc2/permiso.pdf');
    });
  });

  group('DocumentoActivo - certificaciones (AF-095)', () {
    test('conserva qué certifica y a qué aplica', () {
      final original = DocumentoActivo(
        documentoId: 'doc3',
        tipo: 'certificado',
        descripcion: 'Certificación de bienestar animal',
        estado: 'declarado',
        evidenciaIds: const [],
        emisor: 'Welfair',
        fechaVencimiento: DateTime(2027, 6, 30),
        alcance: 'Bienestar animal',
        aplicaA: 'Rodeo de engorde',
      );

      final recuperado =
          DocumentoActivo.fromMap(original.toMap(), original.documentoId);

      expect(recuperado.tipo, 'certificado');
      expect(recuperado.alcance, 'Bienestar animal');
      expect(recuperado.aplicaA, 'Rodeo de engorde');
      expect(recuperado.estadoVigencia(hoy: hoy),
          EstadoVigenciaDocumento.vigente);
    });

    test('un documento viejo sin estos datos los deja vacíos', () {
      final viejo = DocumentoActivo.fromMap({
        'tipo': 'certificado',
        'descripcion': 'Certificado',
        'estado': 'declarado',
      }, 'doc_viejo_cert');

      expect(viejo.alcance, isNull);
      expect(viejo.aplicaA, isNull);
    });
  });
}
