import 'package:flutter_test/flutter_test.dart';

import 'package:agro_fields/models/activos/activo_agro_test_data.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';

void main() {
  test('Activo Agro V2 serializa correctamente', () {
    final activo = ActivoAgroTestData.crearGranjaAvicola();

    final mapa = activo.toMap();

    expect(mapa['modeloVersion'], 2);

    final recuperado = ActivoAgroV2.fromMap(mapa, activo.activoId);

    expect(recuperado.nombre, activo.nombre);

    expect(recuperado.producciones.length, 1);

    // =====================================================
    // CONFIANZA
    // =====================================================

    expect(recuperado.confianza.nivelGeneral, activo.confianza.nivelGeneral);

    expect(
      recuperado.confianza.identidadVerificada,
      activo.confianza.identidadVerificada,
    );

    expect(
      recuperado.confianza.documentacionCompleta,
      activo.confianza.documentacionCompleta,
    );

    expect(
      recuperado.confianza.nivelDocumentacion,
      activo.confianza.nivelDocumentacion,
    );

    expect(
      recuperado.confianza.cantidadEvidencias,
      activo.confianza.cantidadEvidencias,
    );

    expect(
      recuperado.confianza.nivelEvidencias,
      activo.confianza.nivelEvidencias,
    );

    expect(
      recuperado.confianza.informacionProductivaCompleta,
      activo.confianza.informacionProductivaCompleta,
    );

    expect(
      recuperado.confianza.nivelProduccion,
      activo.confianza.nivelProduccion,
    );

    // =====================================================
    // INFRAESTRUCTURA
    // =====================================================

    expect(
      recuperado.confianza.nivelInfraestructura,
      activo.confianza.nivelInfraestructura,
    );

    expect(
      recuperado.confianza.infraestructuraVerificada,
      activo.confianza.infraestructuraVerificada,
    );

    expect(
      recuperado.confianza.cantidadInfraestructuras,
      activo.confianza.cantidadInfraestructuras,
    );

    // =====================================================
    // TECNOLOGÍA
    // =====================================================

    expect(
      recuperado.confianza.nivelTecnologia,
      activo.confianza.nivelTecnologia,
    );

    expect(
      recuperado.confianza.tecnologiaVerificada,
      activo.confianza.tecnologiaVerificada,
    );

    expect(
      recuperado.confianza.cantidadTecnologias,
      activo.confianza.cantidadTecnologias,
    );

    // =====================================================
    // INVERSIÓN
    // =====================================================

    expect(
      recuperado.confianza.nivelInversion,
      activo.confianza.nivelInversion,
    );

    expect(
      recuperado.confianza.inversionDeclarada,
      activo.confianza.inversionDeclarada,
    );

    expect(
      recuperado.confianza.inversionVerificada,
      activo.confianza.inversionVerificada,
    );

    expect(
      recuperado.confianza.montoInversionDeclarada,
      activo.confianza.montoInversionDeclarada,
    );

    expect(
      recuperado.confianza.monedaInversion,
      activo.confianza.monedaInversion,
    );

    // =====================================================
    // GOBERNANZA
    // =====================================================

    expect(
      recuperado.confianza.participantesVerificados,
      activo.confianza.participantesVerificados,
    );

    expect(
      recuperado.confianza.nivelGobernanza,
      activo.confianza.nivelGobernanza,
    );

    // =====================================================
    // CONTROL
    // =====================================================

    expect(recuperado.confianza.observaciones, activo.confianza.observaciones);
  });
}
