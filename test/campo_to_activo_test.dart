import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/campo_model.dart';
import 'package:agro_fields/services/campo_to_activo_service.dart';

void main() {
  test('Campo se convierte correctamente a Activo Agro V2', () {
    final fecha = DateTime(2026, 7, 16);

    final campo = Campo(
      campoId: 'campo_test_001',
      propietarioId: 'usuario_001',
      publicadorId: 'usuario_001',
      tipoRelacion: 'propietario',
      pais: 'Argentina',
      provincia: 'Buenos Aires',
      departamento: 'La Plata',
      localidad: 'Ensenada',
      codigoPostal: '1925',
      nombre: 'Campo Los Tilos',
      hectareas: 25.5,
      descripcion: 'Campo de prueba',
      estadoPublicacion: 'disponible',
      verificado: true,
      hashCampo: 'hash_campo_test',
      fechaCreacion: fecha,
    );

    final activo = CampoToActivoService().convertir(campo);

    expect(activo.activoId, campo.campoId);
    expect(activo.nombre, campo.nombre);
    expect(activo.descripcion, campo.descripcion);

    expect(activo.propietarioId, campo.propietarioId);
    expect(activo.publicadorId, campo.publicadorId);
    expect(activo.tipoRelacionPropietario, campo.tipoRelacion);

    expect(activo.ubicacion.pais, campo.pais);
    expect(activo.ubicacion.provincia, campo.provincia);
    expect(activo.ubicacion.departamento, campo.departamento);
    expect(activo.ubicacion.localidad, campo.localidad);
    expect(activo.ubicacion.codigoPostal, campo.codigoPostal);
    expect(activo.ubicacion.superficie, campo.hectareas);

    expect(activo.confianza.identidadVerificada, true);
    expect(activo.confianza.nivelGeneral, 50);

    expect(activo.producciones.length, 1);
    expect(activo.producciones.first.superficie, campo.hectareas);

    expect(activo.estadoPublicacion, campo.estadoPublicacion);
    expect(activo.hashActivo, campo.hashCampo);
  });
}
