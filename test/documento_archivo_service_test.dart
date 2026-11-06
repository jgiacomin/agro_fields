import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/services/documento_archivo_service.dart';

void main() {
  group('DocumentoArchivoService - ruta (paso 4b)', () {
    test('arma la ruta en la carpeta privada de documentos del Activo', () {
      expect(
        DocumentoArchivoService.construirRuta(
          activoId: 'a1',
          documentoId: 'doc1',
          nombreArchivo: 'escritura.pdf',
        ),
        'activos/a1/privado/documentos/doc1/escritura.pdf',
      );
    });

    test('limpia el nombre para que no rompa la ruta', () {
      expect(
        DocumentoArchivoService.limpiarNombre('Escritura campo/2026 (copia).pdf'),
        'Escritura_campo_2026__copia_.pdf',
      );
    });

    test('un nombre vacío queda como "archivo"', () {
      expect(DocumentoArchivoService.limpiarNombre('   '), 'archivo');
    });
  });

  group('DocumentoArchivoService - validación antes de subir', () {
    test('acepta un PDF', () {
      expect(
        DocumentoArchivoService.validar(
          contentType: 'application/pdf',
          tamanioBytes: 1000,
        ),
        isNull,
      );
    });

    test('acepta una imagen', () {
      expect(
        DocumentoArchivoService.validar(
          contentType: 'image/jpeg',
          tamanioBytes: 1000,
        ),
        isNull,
      );
    });

    test('rechaza lo que no es PDF ni imagen', () {
      expect(
        DocumentoArchivoService.validar(
          contentType: 'text/plain',
          tamanioBytes: 1000,
        ),
        isNotNull,
      );
    });

    test('rechaza un archivo vacío', () {
      expect(
        DocumentoArchivoService.validar(
          contentType: 'application/pdf',
          tamanioBytes: 0,
        ),
        isNotNull,
      );
    });

    test('rechaza 20 MB o más', () {
      expect(
        DocumentoArchivoService.validar(
          contentType: 'application/pdf',
          tamanioBytes: DocumentoArchivoService.tamanioMaximoBytes,
        ),
        isNotNull,
      );
    });
  });
}
