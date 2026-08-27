import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/oportunidad_agro_model.dart';
//import '../models/activos/activo_agro_model_v2.dart';
import '../core/audit/audit_service.dart';
import '../core/audit/audit_type.dart';

class OportunidadAgroService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final String coleccion =
      'oportunidades_agro';

  final AuditService _auditService =
      AuditService();

  // =====================================================
  // CREAR OPORTUNIDAD
  // =====================================================

  Future<String> crearOportunidad(
    OportunidadAgro oportunidad,
  ) async {

    // Verificar que exista el Activo Agro
    final activoSnapshot =
        await _db
            .collection('activos_agro')
            .doc(oportunidad.activoId)
            .get();

    if (!activoSnapshot.exists) {
      throw Exception(
        'El Activo Agro asociado no existe',
      );
    }

    final doc = _db
        .collection(coleccion)
        .doc(oportunidad.oportunidadId);

    await doc.set(
      oportunidad.toMap(),
    );

    await _auditService.registrar(
      activoId: oportunidad.activoId,
      usuarioId: oportunidad.creadorId,
      tipo: AuditType.creacion,
      modulo: 'oportunidad',
      accion: 'crear_oportunidad',
      elementoAfectado:
          oportunidad.oportunidadId,
      referencia: doc.id,
      datos: {
        'titulo': oportunidad.titulo,
        'tipo': oportunidad.tipo,
        'estado': oportunidad.estado,
      },
    );

    return doc.id;
  }

  // =====================================================
  // OBTENER OPORTUNIDAD POR ID
  // =====================================================

  Future<OportunidadAgro?> obtenerOportunidadPorId(
    String oportunidadId,
  ) async {

    final snapshot =
        await _db
            .collection(coleccion)
            .doc(oportunidadId)
            .get();

    if (!snapshot.exists) {
      return null;
    }

    return OportunidadAgro.fromMap(
      snapshot.data()!,
      snapshot.id,
    );
  }

  // =====================================================
  // OPORTUNIDADES DE UN ACTIVO
  // =====================================================

  Future<List<OportunidadAgro>>
      obtenerOportunidadesPorActivo(
    String activoId,
  ) async {

    final snapshot =
        await _db
            .collection(coleccion)
            .where(
              'activoId',
              isEqualTo: activoId,
            )
            .get();

    return snapshot.docs
        .map(
          (doc) =>
              OportunidadAgro.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }

  // =====================================================
  // OPORTUNIDADES ACTIVAS
  // =====================================================

  Future<List<OportunidadAgro>>
      obtenerOportunidadesActivas() async {

    final snapshot =
        await _db
            .collection(coleccion)
            .where(
              'estado',
              isEqualTo: 'activa',
            )
            .get();

    return snapshot.docs
        .map(
          (doc) =>
              OportunidadAgro.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }
}