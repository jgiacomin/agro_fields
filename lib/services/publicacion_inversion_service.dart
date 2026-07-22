import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/publicacion_inversion_model.dart';

class PublicacionInversionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = 'publicaciones_inversion';

  /// 📢 Crear publicación
  Future<void> crearPublicacion(PublicacionInversion pub) async {
    await _firestore.collection(collection).add(pub.toMap());
  }

  /// 📄 Obtener publicaciones activas
  Stream<List<PublicacionInversion>> obtenerPublicaciones() {
    return _firestore
        .collection(collection)
        .where('estado', isEqualTo: 'activa')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PublicacionInversion.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}