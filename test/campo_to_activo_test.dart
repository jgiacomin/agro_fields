import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/campo_model.dart';
import 'package:agro_fields/models/activos/estado_activo.dart';
import 'package:agro_fields/services/campo_to_activo_service.dart';

Campo campoDePrueba({
  String pais = 'Argentina',
  bool verificado = true,
  String estadoPublicacion = 'disponible',
}) {
  return Campo(
    campoId: 'campo_test_001',
    propietarioId: 'usuario_001',
    publicadorId: 'usuario_001',
    tipoRelacion: 'propietario',
    pais: pais,
    provincia: 'Buenos Aires',
    departamento: 'La Plata',
    localidad: 'Ensenada',
    codigoPostal: '1925',
    nombre: 'Campo Los Tilos',
    hectareas: 25.5,
    descripcion: 'Campo de prueba',
    estadoPublicacion: estadoPublicacion,
    verificado: verificado,
    hashCampo: 'hash_campo_test',
    fechaCreacion: DateTime(2026, 7, 16),
  );
}

void main() {
  test('conserva la identidad y los datos que el Campo sí tenía', () {
    final campo = campoDePrueba();
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
    expect(activo.hashActivo, campo.hashCampo);
  });

  test('no inventa producción (paso 5b)', () {
    final activo = CampoToActivoService().convertir(campoDePrueba());

    expect(activo.producciones, isEmpty);
    expect(activo.madurez.faltantes, contains('Producción'));
    expect(activo.madurez.faltantes, contains('Ubicación en el mapa'));
  });

  test('el "verificado" viejo no cuenta como verificación', () {
    final activo = CampoToActivoService().convertir(campoDePrueba());

    expect(activo.confianza.identidadVerificada, isFalse);
    expect(activo.confianza.nivelGeneral, 0);
    expect(activo.confianza.observaciones, contains('sin evidencia'));
  });

  test('nace privado: hay que volver a publicarlo con revisión', () {
    final activo = CampoToActivoService().convertir(
      campoDePrueba(estadoPublicacion: 'disponible'),
    );

    expect(activo.estadoPublicacion, 'borrador');
    expect(activo.visible, isFalse);
    expect(activo.estado, EstadoActivo.borrador);
  });

  test('zona horaria y moneda según el país, vacías si no se conoce', () {
    final ar = CampoToActivoService().convertir(campoDePrueba(pais: 'Argentina'));
    final py = CampoToActivoService().convertir(campoDePrueba(pais: 'Paraguay'));
    final otro = CampoToActivoService().convertir(campoDePrueba(pais: 'Bolivia'));

    expect(ar.ubicacion.monedaLocal, 'ARS');
    expect(py.ubicacion.monedaLocal, 'PYG');
    expect(py.ubicacion.zonaHoraria, 'America/Asuncion');
    expect(otro.ubicacion.monedaLocal, '');
    expect(otro.ubicacion.zonaHoraria, '');
  });

  test('el historial dice que vino del sistema anterior', () {
    final activo = CampoToActivoService().convertir(campoDePrueba());

    expect(activo.historial, hasLength(1));
    expect(activo.historial.first.tipoEvento, 'migracion_desde_campo');
    expect(activo.historial.first.descripcion, contains('campos/campo_test_001'));
  });
}
