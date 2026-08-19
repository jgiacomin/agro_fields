import '../models/activos/activo_agro_model_v2.dart';
import '../models/activos/evaluacion_confianza_model.dart';
import '../models/activos/factor_confianza_model.dart';
import '../models/activos/madurez_activo_model.dart';

class ConfianzaActivoService {
  int calcularNivel(ActivoAgroV2 activo) {
    int puntos = 0;

    // =====================================================
    // Identidad
    // Peso: 20%
    // =====================================================

    if (activo.nombre.isNotEmpty &&
        activo.ubicacion.provincia.isNotEmpty &&
        activo.ubicacion.localidad.isNotEmpty) {
      puntos += 20;
    }

    // =====================================================
    // Producción
    // Peso: 20%
    // =====================================================

    if (activo.producciones.isNotEmpty) {
      puntos += 20;
    }

    // =====================================================
    // Economía
    // Peso: 15%
    // =====================================================

    if (activo.economia.valorSolicitado > 0 ||
        activo.economia.capitalRequerido > 0) {
      puntos += 15;
    }

    // =====================================================
    // Documentación
    // Peso: 20%
    // =====================================================

    if (activo.documentacion.documentacionCompleta) {
      puntos += 20;
    }

    // =====================================================
    // Evidencias
    // Peso: 10%
    // =====================================================

    // Pendiente incorporar modelo propio de evidencias.

    // =====================================================
    // Participantes
    // Peso: 10%
    // =====================================================

    if (activo.participantes.isNotEmpty) {
      puntos += 10;
    }

    // =====================================================
    // Historial
    // Peso: 5%
    // =====================================================

    if (activo.historial.isNotEmpty) {
      puntos += 5;
    }

    if (puntos > 100) {
      puntos = 100;
    }

    return puntos;
  }

  // =====================================================
  // CALCULAR MADUREZ DEL ACTIVO
  // =====================================================

  MadurezActivo calcularMadurez(ActivoAgroV2 activo) {
    int puntos = 0;

    final List<String> faltantes = [];

    // =====================================================
    // IDENTIDAD
    // Peso: 15%
    // =====================================================

    final identidadCompleta =
        activo.nombre.trim().isNotEmpty &&
        activo.ubicacion.pais.trim().isNotEmpty &&
        activo.ubicacion.provincia.trim().isNotEmpty &&
        activo.ubicacion.localidad.trim().isNotEmpty;

    if (identidadCompleta) {
      puntos += 15;
    } else {
      faltantes.add('Identidad');
    }

    // =====================================================
    // PRODUCCIÓN
    // Peso: 20%
    // =====================================================

    if (activo.producciones.isNotEmpty) {
      puntos += 20;
    } else {
      faltantes.add('Producción');
    }

    // =====================================================
    // ECONOMÍA
    // Peso: 15%
    // =====================================================

    final economiaCompleta =
        activo.economia.valorSolicitado > 0 ||
        activo.economia.capitalRequerido > 0 ||
        activo.economia.inversionEsperada > 0;

    if (economiaCompleta) {
      puntos += 15;
    } else {
      faltantes.add('Economía');
    }

    // =====================================================
    // DOCUMENTACIÓN
    // Peso: 20%
    // =====================================================

    if (activo.documentacion.documentacionCompleta) {
      puntos += 20;
    } else {
      faltantes.add('Documentación');
    }

    // =====================================================
    // EVIDENCIAS
    // Peso: 10%
    // =====================================================

    if (activo.confianza.cantidadEvidencias > 0) {
      puntos += 10;
    } else {
      faltantes.add('Evidencias');
    }

    // =====================================================
    // PARTICIPANTES
    // Peso: 10%
    // =====================================================

    if (activo.participantes.isNotEmpty) {
      puntos += 10;
    } else {
      faltantes.add('Participantes');
    }

    // =====================================================
    // HISTORIAL
    // Peso: 10%
    // =====================================================

    if (activo.historial.isNotEmpty) {
      puntos += 10;
    } else {
      faltantes.add('Historial');
    }

    if (puntos > 100) {
      puntos = 100;
    }

    // =====================================================
    // ETAPA
    // =====================================================

    String etapa;

    if (puntos >= 80) {
      etapa = 'maduro';
    } else if (puntos >= 50) {
      etapa = 'desarrollo';
    } else {
      etapa = 'inicial';
    }

    // =====================================================
    // NIVEL TECNOLÓGICO
    // =====================================================

    String nivelTecnologico;

    if (puntos >= 80) {
      nivelTecnologico = 'alto';
    } else if (puntos >= 50) {
      nivelTecnologico = 'medio';
    } else {
      nivelTecnologico = 'bajo';
    }

    // =====================================================
    // PREPARACIÓN PARA INVERSIÓN
    // =====================================================

    String preparacionInversion;

    if (activo.documentacion.documentacionCompleta &&
        economiaCompleta &&
        activo.producciones.isNotEmpty &&
        activo.participantes.isNotEmpty) {
      preparacionInversion = 'avanzada';
    } else if (economiaCompleta && activo.producciones.isNotEmpty) {
      preparacionInversion = 'media';
    } else {
      preparacionInversion = 'inicial';
    }

    return MadurezActivo(
      porcentaje: puntos.toDouble(),
      faltantes: faltantes,
      etapa: etapa,
      nivelTecnologico: nivelTecnologico,
      preparacionInversion: preparacionInversion,
    );
  }

  // =====================================================
  // GENERAR EVALUACIÓN DE CONFIANZA
  // =====================================================

  EvaluacionConfianza generarEvaluacion(ActivoAgroV2 activo) {
    final ahora = DateTime.now();

    // =====================================================
    // FACTOR DOCUMENTAL
    // =====================================================

    final FactorConfianza documental = FactorConfianza(
      nivel: activo.documentacion.documentacionCompleta ? 90 : 40,
      descripcion: 'Estado documental del activo',
      evidencias: [],
      fechaActualizacion: ahora,
    );

    // =====================================================
    // FACTOR PRODUCTIVO
    // =====================================================

    final FactorConfianza productivo = FactorConfianza(
      nivel: activo.producciones.isNotEmpty ? 80 : 30,
      descripcion: 'Estado de información productiva del activo',
      evidencias: [],
      fechaActualizacion: ahora,
    );

    // =====================================================
    // FACTOR ECONÓMICO
    // =====================================================

    final FactorConfianza economico = FactorConfianza(
      nivel:
          activo.economia.valorSolicitado > 0 ||
              activo.economia.capitalRequerido > 0
          ? 70
          : 30,
      descripcion: 'Nivel de información económica del activo',
      evidencias: [],
      fechaActualizacion: ahora,
    );

    // =====================================================
    // FACTOR LEGAL
    // =====================================================

    final FactorConfianza legal = FactorConfianza(
      nivel: activo.documentacion.documentacionCompleta ? 60 : 20,
      descripcion: 'Nivel de información legal disponible del activo',
      evidencias: [],
      fechaActualizacion: ahora,
    );

    // =====================================================
    // FACTOR PROFESIONAL
    // =====================================================

    final FactorConfianza profesional = FactorConfianza(
      nivel: activo.participantes.isNotEmpty ? 50 : 0,
      descripcion: 'Participación de personas relacionadas con el activo',
      evidencias: [],
      fechaActualizacion: ahora,
    );

    // =====================================================
    // NIVEL GENERAL
    // =====================================================

    final int nivelGeneral =
        (documental.nivel +
            productivo.nivel +
            economico.nivel +
            legal.nivel +
            profesional.nivel) ~/
        5;

    // =====================================================
    // FORTALEZAS
    // =====================================================

    final List<String> fortalezas = [];

    if (activo.producciones.isNotEmpty) {
      fortalezas.add('Información productiva disponible');
    }

    if (activo.documentacion.documentacionCompleta) {
      fortalezas.add('Documentación completa');
    }

    if (activo.economia.valorSolicitado > 0 ||
        activo.economia.capitalRequerido > 0) {
      fortalezas.add('Información económica disponible');
    }

    if (activo.participantes.isNotEmpty) {
      fortalezas.add('Participantes registrados');
    }

    if (activo.historial.isNotEmpty) {
      fortalezas.add('Historial del activo disponible');
    }

    // =====================================================
    // PENDIENTES
    // =====================================================

    final List<String> pendientes = [];

    if (!activo.documentacion.documentacionCompleta) {
      pendientes.add('Completar documentación');
    }

    if (activo.producciones.isEmpty) {
      pendientes.add('Completar información productiva');
    }

    if (activo.economia.valorSolicitado <= 0 &&
        activo.economia.capitalRequerido <= 0) {
      pendientes.add('Completar información económica');
    }

    if (!activo.documentacion.documentacionCompleta) {
      pendientes.add('Completar información legal');
    }

    if (activo.participantes.isEmpty) {
      pendientes.add('Registrar participantes');
    }

    // =====================================================
    // RESULTADO
    // =====================================================

    return EvaluacionConfianza(
      nivelGeneral: nivelGeneral,
      documental: documental,
      productivo: productivo,
      economico: economico,
      legal: legal,
      profesional: profesional,
      fortalezas: fortalezas,
      pendientes: pendientes,
      resumen: nivelTexto(nivelGeneral),
      responsable: 'Sistema Agro Fields',
      fechaEvaluacion: ahora,
    );
  }

  // =====================================================
  // TEXTO DEL NIVEL
  // =====================================================

  String nivelTexto(int nivel) {
    if (nivel >= 80) {
      return 'Activo con alta confianza';
    }

    if (nivel >= 50) {
      return 'Activo con información parcial';
    }

    return 'Activo en construcción';
  }
}
