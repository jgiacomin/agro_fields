import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/plan_usuario_model.dart';

/// GAP-PLAN-01: lee el plan del usuario. Solo lectura desde la app: el plan
/// lo carga el administrador (las reglas no dejan que nadie se lo cambie).
class PlanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// El plan del usuario; si no hay nada cargado, Esencial.
  Future<PlanUsuario> planDe(String usuarioId) async {
    final doc = await _db.collection(PlanUsuario.coleccion).doc(usuarioId).get();
    final datos = doc.data();
    if (datos == null) return PlanUsuario.esencial(usuarioId);
    return PlanUsuario.fromMap(datos, usuarioId);
  }
}
