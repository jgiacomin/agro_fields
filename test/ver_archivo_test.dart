import 'package:agro_fields/widgets/ver_archivo_boton.dart';
import 'package:flutter_test/flutter_test.dart';

/// GAP-ARCH-01: nombre visible del archivo (sin Firebase).
void main() {
  test('ARCH-T1. Saca la carpeta y el número que se agrega al subir', () {
    expect(VerArchivoBoton.nombreVisible('activos/a1/gastos/g1/1794835327123_ticket.pdf'),
        'ticket.pdf');
    expect(VerArchivoBoton.nombreVisible('activos/a1/privado/documentos/d1/escritura.pdf'),
        'escritura.pdf');
  });

  test('ARCH-T2. No toca nombres que empiezan con pocos números', () {
    expect(VerArchivoBoton.nombreVisible('activos/a1/territorio/c1/2018_plano.jpg'),
        '2018_plano.jpg');
    expect(VerArchivoBoton.nombreVisible('foto.png'), 'foto.png');
  });
}
