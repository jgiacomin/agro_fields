import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inversion_model.dart';

class InversionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = 'inversiones';

  /// 💰 Crear inversión
  Future<void> crearInversion(Inversion inversion) async {
    await _firestore.collection(collection).add(inversion.toMap());
  }

  /// 📄 Inversiones por usuario
  Stream<List<Inversion>> obtenerInversionesPorUsuario(String userId) {
    return _firestore
        .collection(collection)
        .where('inversorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Inversion.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}