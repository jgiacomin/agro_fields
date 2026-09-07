import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inversion_model.dart';

class InversionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = 'inversiones';

  /// 💰 Crear inversión y actualizar monto recaudado
  Future<void> crearInversion(Inversion inversion) async {
    final inversionRef =
        _firestore.collection(collection).doc();

    final publicacionRef = _firestore
        .collection('publicaciones_inversion')
        .doc(inversion.publicacionId);

    await _firestore.runTransaction((transaction) async {
      final publicacionSnapshot =
          await transaction.get(publicacionRef);

      if (!publicacionSnapshot.exists) {
        throw Exception(
          'La publicación de inversión no existe: '
          '${inversion.publicacionId}',
        );
      }

      final publicacionData =
          publicacionSnapshot.data() as Map<String, dynamic>;

      final montoRecaudadoActual =
          (publicacionData['montoRecaudado'] ?? 0).toDouble();

      final nuevoMontoRecaudado =
          montoRecaudadoActual + inversion.monto;

      transaction.set(
        inversionRef,
        inversion.toMap(),
      );

      transaction.update(
        publicacionRef,
        {
          'montoRecaudado': nuevoMontoRecaudado,
        },
      );
    });
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