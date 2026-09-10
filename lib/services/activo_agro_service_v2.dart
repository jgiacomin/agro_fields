import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';

import '../models/activos/activo_agro_model_v2.dart';
import '../models/activos/suelo_activo_model.dart';
import '../models/activos/confianza_activo_model.dart';
import '../models/activos/evaluacion_confianza_model.dart';
import '../models/activos/historial_activo_model.dart';
import '../models/activos/estado_activo.dart';
import '../models/activos/evidencia_model.dart'; 
import '../models/activos/modulo_produccion_model.dart';
import '../models/activos/ciclo_productivo_model.dart';
import '../models/activos/documentacion_activo_model.dart';
import 'evidencia_service.dart';
import 'confianza_activo_service.dart';

class ActivoAgroServiceV2 {

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;


  final String coleccion =
      'activos_agro';

final ConfianzaActivoService _confianzaService =
      ConfianzaActivoService();

      final AuditService _auditService =
      AuditService();

    final EvidenciaService _evidenciaService =
     EvidenciaService();

// =====================================================
// GENERAR EVENTO DE HISTORIAL
// =====================================================

HistorialActivo _crearEventoHistorial({
  required String tipoEvento,
  required String descripcion,
  required String usuarioId,
  required String moduloOrigen,
    }) 
   
    {

  return HistorialActivo(

    eventoId:
    DateTime.now()
        .millisecondsSinceEpoch
        .toString(),

    tipoEvento:
    tipoEvento,

    descripcion:
    descripcion,

    usuarioId:
    usuarioId,

    moduloOrigen:
    moduloOrigen,

    fecha:
    DateTime.now(),

  );

}
  // =====================================================
  // CREAR ACTIVO
  // =====================================================

  Future<String> crearActivo(
    ActivoAgroV2 activo,
    ) async {

  final existente = await _db
      .collection(coleccion)
      .where(
        'hashActivo',
        isEqualTo: activo.hashActivo,
      )
      .limit(1)
      .get();

  if(existente.docs.isNotEmpty){

    throw Exception(
      'Ya existe un activo similar registrado',
    );

  }
  final doc = _db
      .collection(coleccion)
      .doc(activo.activoId);

final produccionesNormalizadas =
    activo.producciones.map((modulo) {
  final moduloId =
      modulo.id ?? _db.collection(coleccion).doc().id;

  return modulo.copyWith(
    id: moduloId,
    activoAgroId:
        modulo.activoAgroId ?? activo.activoId,
  );
    })
    .toList();

  final historialInicial = _crearEventoHistorial(

    tipoEvento:
    'creacion_activo',

    descripcion:
    'Creación inicial del Activo Agro',

    usuarioId:
    activo.creadorId,

    moduloOrigen:
    'activo',

  );

  final activoConHistorial = activo.copyWith(
  producciones: produccionesNormalizadas,
  historial: [
    ...activo.historial,
    historialInicial,
  ],
);

  await doc.set(
  activoConHistorial.toMap(),
);

await _auditService.registrar(
  activoId: activo.activoId,
  usuarioId: activo.creadorId,
  tipo: AuditType.creacion,
  modulo: 'activo',
  accion: 'crear_activo',
  elementoAfectado: activo.activoId,
  referencia: doc.id,
  datos: {
    'nombre': activo.nombre,
    'tipoActivo': activo.tipoActivo.name,
    'hashActivo': activo.hashActivo,
    'modeloVersion': ActivoAgroV2.modeloVersion,
  },
);

return doc.id;

}

  // =====================================================
  // OBTENER ACTIVO POR ID
  // =====================================================

  Future<ActivoAgroV2?> obtenerActivoPorId(
      String id,
      ) async {

    final snapshot =
        await _db
            .collection(coleccion)
            .doc(id)
            .get();

    if(!snapshot.exists){

      return null;

    }

    return ActivoAgroV2.fromMap(
      snapshot.data()!,
      snapshot.id,
    );

  }

  // =====================================================
  // OBTENER TODOS LOS ACTIVOS
  // =====================================================

  Future<List<ActivoAgroV2>> obtenerActivos() async {

    final snapshot =
        await _db
            .collection(coleccion)
            .get();

    return snapshot.docs
        .map(

          (doc)=>

          ActivoAgroV2.fromMap(
            doc.data(),
            doc.id,
          ),

    )
        .toList();

  }

  // =====================================================
  // ACTIVOS PUBLICADOS PARA INVERSORES
  // =====================================================

  Future<List<ActivoAgroV2>> obtenerActivosPublicados() async {

    final snapshot =
        await _db
            .collection(coleccion)
            .where(
              'estadoPublicacion',
              isEqualTo: 'publicado',
            )
            .where(
              'visible',
              isEqualTo: true,
            )
            .get();

    return snapshot.docs
        .map(

          (doc)=>

          ActivoAgroV2.fromMap(
            doc.data(),
            doc.id,
          ),

    )
        .toList();

  }

  // =====================================================
  // ACTIVOS DEL PROPIETARIO
  // =====================================================

  Future<List<ActivoAgroV2>> buscarPorPropietario(
      String propietarioId,
      ) async {

    final snapshot =
        await _db
            .collection(coleccion)
            .where(
              'propietarioId',
              isEqualTo: propietarioId,
            )
            .get();

    return snapshot.docs
        .map(

          (doc)=>

          ActivoAgroV2.fromMap(
            doc.data(),
            doc.id,
          ),

    )
        .toList();

  }

  // =====================================================
  // ACTIVOS PUBLICADOS POR INTERMEDIARIO
  // =====================================================

  Future<List<ActivoAgroV2>> buscarPorPublicador(
      String publicadorId,
      ) async {

    final snapshot =
        await _db
            .collection(coleccion)
            .where(
              'publicadorId',
              isEqualTo: publicadorId,
            )
            .get();

    return snapshot.docs
        .map(

          (doc)=>

          ActivoAgroV2.fromMap(
            doc.data(),
            doc.id,
          ),

    )
        .toList();
}

// =====================================================
// PUBLICAR ACTIVO
// =====================================================

Future<void> publicarActivo(
  String activoId,
) async {
  final activo =
      await obtenerActivoPorId(activoId);

  if (activo == null) {
    throw Exception(
      'Activo no encontrado',
    );
  }

  // =====================================================
  // EVALUAR CONFIANZA Y MADUREZ ANTES DE PUBLICAR
  // =====================================================

  await evaluarActivo(activoId);

  final activoEvaluado =
      await obtenerActivoPorId(activoId);

  if (activoEvaluado == null) {
    throw Exception(
      'No se pudo recuperar el activo evaluado',
    );
  }

  // =====================================================
  // EVENTO DE HISTORIAL
  // =====================================================

  final evento =
      _crearEventoHistorial(
    tipoEvento:
        'publicacion_activo',
    descripcion:
        'El Activo Agro fue publicado',
    usuarioId:
        activoEvaluado.publicadorId,
    moduloOrigen:
        'activo',
  );

  // =====================================================
  // PUBLICAR
  // =====================================================

  final activoActualizado =
      activoEvaluado.copyWith(
    estado:
        EstadoActivo.publicado,
    estadoPublicacion:
        'publicado',
    visible:
        true,
    historial: [
      ...activoEvaluado.historial,
      evento,
    ],
  );

  await _db
      .collection(coleccion)
      .doc(activoId)
      .update(
    activoActualizado.toMap(),
  );

  // =====================================================
  // AUDITORÍA
  // =====================================================

  await _auditService.registrar(
    activoId: activoId,
    usuarioId:
        activoEvaluado.publicadorId,
    tipo:
        AuditType.publicacion,
    modulo:
        'activo',
    accion:
        'publicar_activo',
    elementoAfectado:
        activoId,
    estadoAnterior:
        activoEvaluado.estadoPublicacion,
    estadoNuevo:
        'publicado',
    referencia:
        activoId,
  );
}

// =====================================================
// PAUSAR ACTIVO
// =====================================================

Future<void> pausarActivo(
  String activoId,
) async {
  final activo =
      await obtenerActivoPorId(activoId);

  if (activo == null) {
    throw Exception(
      'Activo no encontrado',
    );
  }

  final evento =
      _crearEventoHistorial(
    tipoEvento:
        'pausa_activo',
    descripcion:
        'El Activo Agro fue pausado',
    usuarioId:
        activo.publicadorId,
    moduloOrigen:
        'activo',
  );

  final activoActualizado =
      activo.copyWith(
    estado:
        EstadoActivo.pausado,
    estadoPublicacion:
        'pausado',
    visible:
        false,
    historial: [
      ...activo.historial,
      evento,
    ],
  );

  await _db
      .collection(coleccion)
      .doc(activoId)
      .update(
    activoActualizado.toMap(),
  );

  await _auditService.registrar(
    activoId: activoId,
    usuarioId:
        activo.publicadorId,
    tipo:
        AuditType.pausa,
    modulo:
        'activo',
    accion:
        'pausar_activo',
    elementoAfectado:
        activoId,
    estadoAnterior:
        activo.estadoPublicacion,
    estadoNuevo:
        'pausado',
    referencia:
        activoId,
  );
}

// =====================================================
// ACTUALIZAR ACTIVO COMPLETO
// =====================================================

Future<void> actualizarActivo(
  ActivoAgroV2 activo,
) async {
  final evento =
      _crearEventoHistorial(
    tipoEvento:
        'actualizacion_activo',
    descripcion:
        'Actualización general del Activo Agro',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'activo',
  );

  final activoActualizado =
      activo.copyWith(
    historial: [
      ...activo.historial,
      evento,
    ],
  );

  await _db
      .collection(coleccion)
      .doc(activo.activoId)
      .update(
    activoActualizado.toMap(),
  );

  await _auditService.registrar(
    activoId:
        activo.activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.modificacion,
    modulo:
        'activo',
    accion:
        'actualizar_activo',
    elementoAfectado:
        activo.activoId,
    referencia:
        activo.activoId,
  );
}

// =====================================================
// ACTUALIZAR SUELO
// =====================================================

Future<void> actualizarSuelo(
  String activoId,
  SueloActivo suelo, {
  Evidencia? evidencia,
}) async {

  final activo =
      await obtenerActivoPorId(activoId);

  if (activo == null) {
    throw Exception(
      'Activo no encontrado',
    );
  }

  // =====================================================
  // EVIDENCIA OPCIONAL DEL SUELO
  // =====================================================

  var sueloGuardar = suelo;

  if (evidencia != null) {

    if (evidencia.activoAgroId != activoId) {
      throw ArgumentError(
        'La evidencia no corresponde al activo indicado.',
      );
    }

    final evidenciaId =
        await _evidenciaService.crearEvidencia(
      evidencia:
          evidencia,
      usuarioId:
          activo.creadorId,
    );

    sueloGuardar =
        suelo.copyWith(
      evidencias: [
        ...suelo.evidencias,
        evidenciaId,
      ],
    );
  }

  // =====================================================
  // HISTORIAL
  // =====================================================

  final evento =
      _crearEventoHistorial(
    tipoEvento:
        'actualizacion_suelo',
    descripcion:
        'Actualización de información del suelo',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'suelo',
  );

  // =====================================================
  // ACTUALIZAR ACTIVO
  // =====================================================

  final activoActualizado =
      activo.copyWith(
    suelo:
        sueloGuardar,
    historial: [
      ...activo.historial,
      evento,
    ],
  );

  await _db
      .collection(coleccion)
      .doc(activoId)
      .update(
    activoActualizado.toMap(),
  );

  // =====================================================
  // AUDITORÍA
  // =====================================================

  await _auditService.registrar(
    activoId:
        activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.modificacion,
    modulo:
        'suelo',
    accion:
        'actualizar_suelo',
    elementoAfectado:
        activoId,
    referencia:
        activoId,
  );
}
// =====================================================
// ACTUALIZAR DOCUMENTACIÓN
// =====================================================

Future<void> actualizarDocumentacion(
  String activoId,
  DocumentacionActivo documentacion, {
  Evidencia? evidencia,
}) async {
  final activo =
      await obtenerActivoPorId(activoId);

  if (activo == null) {
    throw Exception(
      'Activo no encontrado',
    );
  }

  // =====================================================
  // EVIDENCIA OPCIONAL DE LA DOCUMENTACIÓN
  // =====================================================

  if (evidencia != null) {
    if (evidencia.activoAgroId != activoId) {
      throw ArgumentError(
        'La evidencia no corresponde al activo indicado.',
      );
    }

    await _evidenciaService.crearEvidencia(
      evidencia: evidencia,
      usuarioId: activo.creadorId,
    );
  }

  // =====================================================
  // HISTORIAL
  // =====================================================

  final evento =
      _crearEventoHistorial(
    tipoEvento:
        'actualizacion_documentacion',
    descripcion:
        'Actualización de la documentación del Activo Agro',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'documentacion',
  );

  // =====================================================
  // ACTUALIZAR ACTIVO
  // =====================================================

  final activoActualizado =
      activo.copyWith(
    documentacion:
        documentacion,
    historial: [
      ...activo.historial,
      evento,
    ],
  );

  await _db
      .collection(coleccion)
      .doc(activoId)
      .update(
    activoActualizado.toMap(),
  );

  // =====================================================
  // AUDITORÍA
  // =====================================================

  await _auditService.registrar(
    activoId:
        activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.modificacion,
    modulo:
        'documentacion',
    accion:
        'actualizar_documentacion',
    elementoAfectado:
        activoId,
    referencia:
        activoId,
    datos: {
      'documentacionCompleta':
          documentacion.documentacionCompleta,
      'tieneEvidencia':
          evidencia != null,
    },
  );
}
// =====================================================
// REGISTRAR CICLO PRODUCTIVO
// =====================================================

Future<void> registrarCicloProductivo(
  String activoId,
  String moduloProduccionId,
  CicloProductivo ciclo, {
  Evidencia? evidencia,
}) async {
  final activo =
      await obtenerActivoPorId(activoId);

  if (activo == null) {
    throw Exception(
      'Activo no encontrado',
    );
  }

  final indiceModulo =
      activo.producciones.indexWhere(
    (modulo) =>
        modulo.id == moduloProduccionId,
  );

  if (indiceModulo == -1) {
    throw Exception(
      'Módulo de producción no encontrado',
    );
  }

  if (ciclo.activoAgroId != null &&
      ciclo.activoAgroId != activoId) {
    throw ArgumentError(
      'El ciclo no corresponde al activo indicado.',
    );
  }

  if (ciclo.moduloProduccionId != null &&
      ciclo.moduloProduccionId !=
          moduloProduccionId) {
    throw ArgumentError(
      'El ciclo no corresponde al módulo indicado.',
    );
  }

  // =====================================================
  // EVIDENCIA OPCIONAL
  // =====================================================

  if (evidencia != null) {
    if (evidencia.activoAgroId != activoId) {
      throw ArgumentError(
        'La evidencia no corresponde al activo indicado.',
      );
    }

    await _evidenciaService.crearEvidencia(
      evidencia: evidencia,
      usuarioId: activo.creadorId,
    );
  }

  // =====================================================
  // CICLO NORMALIZADO
  // =====================================================

  final cicloGuardar =
      CicloProductivo(
    cicloId: ciclo.cicloId,
    activoAgroId: activoId,
    moduloProduccionId:
        moduloProduccionId,
    fechaInicio:
        ciclo.fechaInicio,
    fechaFin:
        ciclo.fechaFin,
    campania:
        ciclo.campania,
    produccionObtenida:
        ciclo.produccionObtenida,
    unidadProduccion:
        ciclo.unidadProduccion,
    observaciones:
        ciclo.observaciones,
  );

  // =====================================================
  // ACTUALIZAR MÓDULO
  // =====================================================

  final moduloActual =
      activo.producciones[indiceModulo];

  final moduloActualizado =
      ModuloProduccion(
    id: moduloActual.id,
    activoAgroId:
        moduloActual.activoAgroId ?? activoId,
    dominio:
        moduloActual.dominio,
    actividad:
        moduloActual.actividad,
    descripcion:
        moduloActual.descripcion,
    superficie:
        moduloActual.superficie,
    unidad:
        moduloActual.unidad,
    capacidadActual:
        moduloActual.capacidadActual,
    capacidadMaxima:
        moduloActual.capacidadMaxima,
    activo:
        moduloActual.activo,
    datos:
        moduloActual.datos,
    ciclos: [
      ...moduloActual.ciclos,
      cicloGuardar,
    ],
  );

  final produccionesActualizadas =
      List<ModuloProduccion>.from(
    activo.producciones,
  );

  produccionesActualizadas[indiceModulo] =
      moduloActualizado;

  // =====================================================
  // HISTORIAL
  // =====================================================

  final evento =
      _crearEventoHistorial(
    tipoEvento:
        'registro_ciclo_productivo',
    descripcion:
        'Registro de un nuevo ciclo productivo',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'produccion',
  );

  // =====================================================
  // ACTUALIZAR ACTIVO
  // =====================================================

  final activoActualizado =
      activo.copyWith(
    producciones:
        produccionesActualizadas,
    historial: [
      ...activo.historial,
      evento,
    ],
  );

  await _db
      .collection(coleccion)
      .doc(activoId)
      .update(
    activoActualizado.toMap(),
  );

  // =====================================================
  // AUDITORÍA
  // =====================================================

  await _auditService.registrar(
    activoId:
        activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.modificacion,
    modulo:
        'produccion',
    accion:
        'registrar_ciclo_productivo',
    elementoAfectado:
        cicloGuardar.cicloId,
    referencia:
        activoId,
    datos: {
      'moduloProduccionId':
          moduloProduccionId,
      'cicloId':
          cicloGuardar.cicloId,
      'campania':
          cicloGuardar.campania,
      'produccionObtenida':
          cicloGuardar.produccionObtenida,
      'unidadProduccion':
          cicloGuardar.unidadProduccion,
      'tieneEvidencia':
          evidencia != null,
    },
  );
}
// =====================================================
// ACTUALIZAR SISTEMA DE CONFIANZA
// =====================================================

Future<void> actualizarConfianza(
  String activoId,
  ConfianzaActivo confianza,
) async {
  final activo =
      await obtenerActivoPorId(activoId);

  if (activo == null) {
    throw Exception(
      'Activo no encontrado',
    );
  }

  final evento =
      _crearEventoHistorial(
    tipoEvento:
        'actualizacion_confianza',
    descripcion:
        'Se actualizó el sistema de confianza del Activo Agro',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'confianza',
  );

  final activoActualizado =
      activo.copyWith(
    confianza:
        confianza,
    historial: [
      ...activo.historial,
      evento,
    ],
  );

  await _db
      .collection(coleccion)
      .doc(activoId)
      .update(
    activoActualizado.toMap(),
  );

  await _auditService.registrar(
    activoId:
        activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.actualizacionConfianza,
    modulo:
        'confianza',
    accion:
        'actualizar_confianza',
    elementoAfectado:
        activoId,
    referencia:
        activoId,
  );
}

// =====================================================
// ACTUALIZAR EVALUACIÓN DE CONFIANZA
// =====================================================

Future<void> actualizarEvaluacionConfianza(
  String activoId,
  EvaluacionConfianza evaluacion,
) async {
  final activo =
      await obtenerActivoPorId(activoId);

  if (activo == null) {
    throw Exception(
      'Activo no encontrado',
    );
  }

  final evento =
      _crearEventoHistorial(
    tipoEvento:
        'evaluacion_confianza',
    descripcion:
        'Se actualizó la evaluación de confianza',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'confianza',
  );

  final confianzaActualizada =
      activo.confianza.copyWith(
    nivelGeneral:
        evaluacion.nivelGeneral,
    ultimaVerificacion:
        DateTime.now(),
    ultimaEvaluacion:
        evaluacion.fechaEvaluacion,
  );

  // =====================================================
  // CALCULAR MADUREZ
  // =====================================================

  final madurezActualizada =
      _confianzaService.calcularMadurez(
    activo,
  );

  // =====================================================
  // ACTUALIZAR ACTIVO
  // =====================================================

  final activoActualizado =
      activo.copyWith(
    evaluacion:
        evaluacion,
    confianza:
        confianzaActualizada,
    madurez:
        madurezActualizada,
    historial: [
      ...activo.historial,
      evento,
    ],
  );

  await _db
      .collection(coleccion)
      .doc(activoId)
      .update(
    activoActualizado.toMap(),
  );

  await _auditService.registrar(
    activoId:
        activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.evaluacionConfianza,
    modulo:
        'confianza',
    accion:
        'evaluar_confianza',
    elementoAfectado:
        activoId,
    referencia:
        activoId,
  );
}

// =====================================================
// EVALUAR ACTIVO AGRO
// =====================================================

Future<void> evaluarActivo(
  String activoId,
) async {

  final activo =
      await obtenerActivoPorId(activoId);

  if (activo == null) {
    throw Exception(
      'Activo no encontrado',
    );
  }

  final evaluacion =
      _confianzaService.generarEvaluacion(
    activo,
  );

  await actualizarEvaluacionConfianza(
    activoId,
    evaluacion,
  );
}

}
