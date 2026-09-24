import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';

import 'package:agro_fields/models/activos/relacion_juridica_model.dart';
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
import '../models/activos/economia_activo_model.dart';
import '../models/activos/derecho_activo_model.dart';
import '../models/activos/evento_afectacion_model.dart';
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
}) {

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
  // EVENTO DE HISTORIAL — PUBLICAR ACTIVO
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
  // PUBLICAR ACTIVO — ACTUALIZAR ESTADO
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
  // AUDITORIA — PUBLICAR ACTIVO
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

  // =====================================================
  // AUDITORIA — PAUSAR ACTIVO
  // =====================================================

  await _auditService.registrar(
    activoId:
        activoId,
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

  // =====================================================
  // AUDITORIA — ACTUALIZAR ACTIVO COMPLETO
  // =====================================================

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
// REGISTRAR DERECHO / CARGA JURIDICA
// =====================================================

Future<void> registrarDerechoActivo(
  String activoId,
  DerechoActivo derecho, {
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
  // VALIDAR VINCULO DEL DERECHO CON EL ACTIVO
  // =====================================================

  if (derecho.activoAgroId != activoId) {
    throw ArgumentError(
      'El DerechoActivo no corresponde al activo indicado.',
    );
  }

  // =====================================================
  // EVITAR DUPLICACIÓN DEL DERECHO
  // =====================================================

  final existeDerecho =
      activo.derechos.any(
    (item) =>
        item.derechoId ==
        derecho.derechoId,
  );

  if (existeDerecho) {
    throw Exception(
      'El DerechoActivo ya está registrado en el activo.',
    );
  }

  // =====================================================
  // EVIDENCIA OPCIONAL — DERECHO ACTIVO
  // =====================================================

  String? evidenciaId;

  if (evidencia != null) {

    if (evidencia.activoAgroId != activoId) {
      throw ArgumentError(
        'La evidencia no corresponde al activo indicado.',
      );
    }

    evidenciaId =
        await _evidenciaService.crearEvidencia(
      evidencia: evidencia,
      usuarioId: activo.creadorId,
    );
  }

  // =====================================================
  // HISTORIAL — DERECHO ACTIVO
  // =====================================================

  final eventoId =
      DateTime.now()
          .millisecondsSinceEpoch
          .toString();

  final evento = HistorialActivo(
    eventoId:
        eventoId,
    tipoEvento:
        'registro_derecho_activo',
    descripcion:
        'Registro de un derecho o carga jurídica asociada al Activo Agro',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'derecho',
    fecha:
        DateTime.now(),
    entidadRelacionada:
        'DerechoActivo',
    referenciaId:
        derecho.derechoId,
    datosEvento: {
      'derechoId':
          derecho.derechoId,
      'tipoDerecho':
          derecho.tipoDerecho,
      'tipoObjeto':
          derecho.tipoObjeto,
      'descripcionObjeto':
          derecho.descripcionObjeto,
      'tipoInstrumento':
          derecho.tipoInstrumento,
      'identificadorInstrumento':
          derecho.identificadorInstrumento,
      'estado':
          derecho.estado,
      'tieneEvidencia':
          evidencia != null,
      if (evidenciaId != null)
        'evidenciaId':
            evidenciaId,
    },
  );

  // =====================================================
  // ACTUALIZAR ACTIVO — DERECHO ACTIVO
  // =====================================================

  final derechosActualizados =
      <DerechoActivo>[
    ...activo.derechos,
    derecho,
  ];

  final activoActualizado =
      activo.copyWith(
    derechos:
        derechosActualizados,
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
  // AUDITORIA — DERECHO ACTIVO
  // =====================================================

  await _auditService.registrar(
    activoId:
        activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.modificacion,
    modulo:
        'derecho',
    accion:
        'registrar_derecho_activo',
    elementoAfectado:
        derecho.derechoId,
    referencia:
        activoId,
    estadoAnterior:
        'sin_derecho_registrado',
    estadoNuevo:
        derecho.estado,
    datos: {
      'derechoId':
          derecho.derechoId,
      'tipoDerecho':
          derecho.tipoDerecho,
      'tipoObjeto':
          derecho.tipoObjeto,
      'descripcionObjeto':
          derecho.descripcionObjeto,
      'tipoInstrumento':
          derecho.tipoInstrumento,
      'identificadorInstrumento':
          derecho.identificadorInstrumento,
      'estado':
          derecho.estado,
      'tieneEvidencia':
          evidencia != null,
      if (evidenciaId != null)
        'evidenciaId':
            evidenciaId,
    },
  );
}

// =====================================================
// REGISTRAR RELACIÓN JURIDICA / OBLIGACIÓN
// =====================================================

Future<void> registrarRelacionJuridica(
  String activoId,
  RelacionJuridica relacion, {
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
  // VALIDAR VINCULO DE LA RELACIÓN CON EL ACTIVO
  // =====================================================

  final derechoExiste =
      activo.derechos.any(
    (derecho) =>
        derecho.derechoId == relacion.derechoId,
  );

  if (!derechoExiste) {
    throw ArgumentError(
      'La relación jurídica referencia un derecho que no existe en el activo.',
    );
  }

  // =====================================================
  // EVITAR DUPLICADOS — RELACIÓN JURÍDICA
  // =====================================================

  final relacionDuplicada =
      activo.relacionesJuridicas.any(
    (relacionExistente) =>
        relacionExistente.relacionId ==
        relacion.relacionId,
  );

  if (relacionDuplicada) {
    throw Exception(
      'La relación jurídica ya existe en el activo.',
    );
  }

  // =====================================================
  // EVIDENCIA — RELACIÓN JURÍDICA
  // =====================================================

  String? evidenciaId;

  if (evidencia != null) {

    if (evidencia.activoAgroId != activoId) {
      throw ArgumentError(
        'La evidencia no corresponde al activo indicado.',
      );
    }

    evidenciaId =
        await _evidenciaService.crearEvidencia(
      evidencia: evidencia,
      usuarioId: activo.creadorId,
    );
  }

  // =====================================================
  // AGREGAR RELACIÓN JURÍDICA
  // =====================================================

  final relacionesActualizadas = [
    ...activo.relacionesJuridicas,
    relacion,
  ];

  final activoActualizado = activo.copyWith(
    relacionesJuridicas:
        relacionesActualizadas,
  );

  // =====================================================
  // HISTORIAL — RELACIÓN JURÍDICA
  // =====================================================

  final eventoId =
      DateTime.now()
          .millisecondsSinceEpoch
          .toString();

  final evento = HistorialActivo(
    eventoId: eventoId,
    tipoEvento:
        'registro_relacion_juridica',
    descripcion:
        'Registro de una relación jurídica asociada a un derecho del Activo Agro',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'derecho',
    fecha:
        DateTime.now(),
    entidadRelacionada:
        'RelacionJuridica',
    referenciaId:
        relacion.relacionId,
    datosEvento: {
      'relacionId':
          relacion.relacionId,
      'derechoId':
          relacion.derechoId,
      'sujetoId':
          relacion.sujetoId,
      'tipoSujeto':
          relacion.tipoSujeto,
      'rol':
          relacion.rol,
      'estado':
          relacion.estado,
      'tieneEvidencia':
          evidenciaId != null,
      if (evidenciaId != null)
        'evidenciaId':
            evidenciaId,
    },
  );

  final historialActualizado = [
    ...activoActualizado.historial,
    evento,
  ];

  final activoConHistorial =
      activoActualizado.copyWith(
    historial:
        historialActualizado,
  );

  // =====================================================
  // PERSISTENCIA — RELACIÓN JURÍDICA
  // =====================================================

  await _db
      .collection(coleccion)
      .doc(activoId)
      .update(
    activoConHistorial.toMap(),
  );

  // =====================================================
  // AUDITORIA — RELACIÓN JURÍDICA
  // =====================================================

  await _auditService.registrar(
    activoId: activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.modificacion,
    modulo:
        'derecho',
    accion:
        'registrar_relacion_juridica',
    elementoAfectado:
        relacion.relacionId,
    referencia:
        activoId,
    estadoAnterior:
        'sin_relacion_registrada',
    estadoNuevo:
        relacion.estado,
    datos: {
      'relacionId':
          relacion.relacionId,
      'derechoId':
          relacion.derechoId,
      'sujetoId':
          relacion.sujetoId,
      'tipoSujeto':
          relacion.tipoSujeto,
      'rol':
          relacion.rol,
      'tieneEvidencia':
          evidenciaId != null,
      if (evidenciaId != null)
        'evidenciaId':
            evidenciaId,
    },
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
  // HISTORIAL — SUELO
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
  // ACTUALIZAR ACTIVO — SUELO
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
  // AUDITORIA — SUELO
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
  // TRAZABILIDAD DOCUMENTAL: ESTADO ANTERIOR / NUEVO
  // =====================================================

  final documentacionAnterior =
      activo.documentacion.toMap();

  final documentacionNueva =
      documentacion.toMap();

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
  // HISTORIAL — DOCUMENTACIÓN
  // =====================================================

  final eventoId =
      DateTime.now()
          .millisecondsSinceEpoch
          .toString();

  final evento = HistorialActivo(
    eventoId: eventoId,
    tipoEvento:
        'actualizacion_documentacion',
    descripcion:
        'Actualización de la documentación del Activo Agro',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'documentacion',
    fecha:
        DateTime.now(),
    entidadRelacionada:
        'documentacion',
    referenciaId:
        activoId,
    datosEvento: {
      'documentacionAnterior':
          documentacionAnterior,
      'documentacionNueva':
          documentacionNueva,
      'tieneEvidencia':
          evidencia != null,
      if (evidencia != null)
        'evidenciaId':
            evidencia.evidenciaId,
    },
  );

  // =====================================================
  // ACTUALIZAR ACTIVO — DOCUMENTACIÓN
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
  // AUDITORIA — DOCUMENTACIÓN
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
    estadoAnterior:
        'documentacion_registrada',
    estadoNuevo:
        'documentacion_actualizada',
    referencia:
        activoId,
    datos: {
      'documentacionAnterior':
          documentacionAnterior,
      'documentacionNueva':
          documentacionNueva,
      'documentacionCompleta':
          documentacion.documentacionCompleta,
      'tieneEvidencia':
          evidencia != null,
      if (evidencia != null)
        'evidenciaId':
            evidencia.evidenciaId,
    },
  );
}

// =====================================================
// ACTUALIZAR ECONOMIA
// =====================================================

Future<void> actualizarEconomia(
  String activoId,
  EconomiaActivo economia, {
  Evidencia? evidencia,
}) async {

  final activo =
      await obtenerActivoPorId(activoId);

  if (activo == null) {
    throw Exception(
      'Activo no encontrado',
    );
  }

  final economiaAnterior =
      activo.economia.toMap();

  final economiaNueva =
      economia.toMap();

  // =====================================================
  // EVIDENCIA OPCIONAL DE LA ECONOMIA
  // =====================================================

  String? evidenciaId;

  if (evidencia != null) {

    if (evidencia.activoAgroId != activoId) {
      throw ArgumentError(
        'La evidencia no corresponde al activo indicado.',
      );
    }

    evidenciaId =
        await _evidenciaService.crearEvidencia(
      evidencia: evidencia,
      usuarioId: activo.creadorId,
    );
  }

  // =====================================================
  // HISTORIAL — ECONOMIA
  // =====================================================

  final eventoId =
      DateTime.now()
          .millisecondsSinceEpoch
          .toString();

  final evento = HistorialActivo(
    eventoId: eventoId,
    tipoEvento:
        'actualizacion_economia',
    descripcion:
        'Actualización de la información económica del Activo Agro',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'economia',
    fecha:
        DateTime.now(),
    entidadRelacionada:
        'economia',
    referenciaId:
        activoId,
    datosEvento: {
      'economiaAnterior':
          economiaAnterior,
      'economiaNueva':
          economiaNueva,
      'tieneEvidencia':
          evidencia != null,
      if (evidenciaId != null)
        'evidenciaId':
            evidenciaId,
    },
  );

  // =====================================================
  // ACTUALIZAR ACTIVO — ECONOMIA
  // =====================================================

  final activoActualizado =
      activo.copyWith(
    economia:
        economia,
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
  // AUDITORIA — ECONOMIA
  // =====================================================

  await _auditService.registrar(
    activoId:
        activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.modificacion,
    modulo:
        'economia',
    accion:
        'actualizar_economia',
    elementoAfectado:
        activoId,
    referencia:
        activoId,
    datos: {
      'economiaAnterior':
          economiaAnterior,
      'economiaNueva':
          economiaNueva,
      'valorSolicitado':
          economia.valorSolicitado,
      'capitalRequerido':
          economia.capitalRequerido,
      'inversionEsperada':
          economia.inversionEsperada,
      'tieneEvidencia':
          evidencia != null,
      if (evidenciaId != null)
        'evidenciaId':
            evidenciaId,
    },
  );
}

Future<void> registrarEventoAfectacion(
  String activoId,
  EventoAfectacion evento, {
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
  // VALIDAR VINCULO DEL EVENTO CON EL ACTIVO
  // =====================================================

  if (evento.activoAgroId != activoId) {
    throw ArgumentError(
      'El EventoAfectacion no corresponde al activo indicado.',
    );
  }

  // =====================================================
  // EVITAR DUPLICACION DEL EVENTO
  // =====================================================

  final eventoExistente =
      await _db
          .collection('eventos_afectacion')
          .doc(evento.eventoId)
          .get();

  if (eventoExistente.exists) {
    throw Exception(
      'El EventoAfectacion ya está registrado.',
    );
  }

  // =====================================================
// EVIDENCIA OPCIONAL — EVENTO AFECTACION
// =====================================================

String? evidenciaId;

if (evidencia != null) {

  if (evidencia.activoAgroId != activoId) {
    throw ArgumentError(
      'La evidencia no corresponde al activo indicado.',
    );
  }

  if (evidencia.elementoTipo != 'EventoAfectacion') {
    throw ArgumentError(
      'La evidencia debe estar vinculada a un EventoAfectacion.',
    );
  }

  if (evidencia.elementoId != evento.eventoId) {
    throw ArgumentError(
      'La evidencia no corresponde al EventoAfectacion indicado.',
    );
  }

  evidenciaId =
      await _evidenciaService.crearEvidencia(
    evidencia: evidencia,
    usuarioId: activo.creadorId,
  );
}

// =====================================================
// PERSISTIR EVENTO — EVENTO AFECTACION
// =====================================================

  await _db
      .collection('eventos_afectacion')
      .doc(evento.eventoId)
      .set(
    evento.toMap(),
  );

  // =====================================================
  // HISTORIAL — EVENTO AFECTACION
  // =====================================================

  final historialEvento =
      HistorialActivo(
    eventoId:
        DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
    tipoEvento:
        'registro_evento_afectacion',
    descripcion:
        'Registro de un evento de afectación del Activo Agro',
    usuarioId:
        activo.creadorId,
    moduloOrigen:
        'afectacion',
    fecha:
        DateTime.now(),
    entidadRelacionada:
        'EventoAfectacion',
    referenciaId:
        evento.eventoId,
    datosEvento: {
      'eventoId':
          evento.eventoId,
      'tipoEvento':
          evento.tipoEvento,
      'subtipoEvento':
          evento.subtipoEvento,
      'origen':
          evento.origen,
      'estado':
          evento.estado,
      'cantidadAfectaciones':
          evento.afectaciones.length,
      'tieneEvidencia':
          evidencia != null,
      if (evidenciaId != null)
        'evidenciaId':
            evidenciaId,
    },
  );

  // =====================================================
  // ACTUALIZAR HISTORIAL DEL ACTIVO — EVENTO AFECTACION
  // =====================================================

  final activoActualizado =
      activo.copyWith(
    historial: [
      ...activo.historial,
      historialEvento,
    ],
  );

  await _db
      .collection(coleccion)
      .doc(activoId)
      .update(
    activoActualizado.toMap(),
  );

  // =====================================================
  // AUDITORIA — EVENTO AFECTACION
  // =====================================================

  await _auditService.registrar(
    activoId:
        activoId,
    usuarioId:
        activo.creadorId,
    tipo:
        AuditType.modificacion,
    modulo:
        'afectacion',
    accion:
        'registrar_evento_afectacion',
    elementoAfectado:
        evento.eventoId,
    referencia:
        activoId,
    datos: {
      'eventoId':
          evento.eventoId,
      'tipoEvento':
          evento.tipoEvento,
      'subtipoEvento':
          evento.subtipoEvento,
      'origen':
          evento.origen,
      'estado':
          evento.estado,
      'cantidadAfectaciones':
          evento.afectaciones.length,
      'tieneEvidencia':
          evidencia != null,
      if (evidenciaId != null)
        'evidenciaId':
            evidenciaId,
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
  // EVIDENCIA OPCIONAL — CICLO PRODUCTIVO
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
    cicloId:
        ciclo.cicloId,
    activoAgroId:
        activoId,
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
  // ACTUALIZAR MÓDULO — CICLO PRODUCTIVO
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
  // HISTORIAL — CICLO PRODUCTIVO
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
  // ACTUALIZAR ACTIVO — CICLO PRODUCTIVO
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
  // AUDITORIA — CICLO PRODUCTIVO
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

  // =====================================================
  // AUDITORIA — ACTUALIZAR SISTEMA DE CONFIANZA
  // =====================================================

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
  // ACTUALIZAR ACTIVO — EVALUACIÓN DE CONFIANZA
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

  // =====================================================
  // AUDITORIA — EVALUACIÓN DE CONFIANZA
  // =====================================================

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
