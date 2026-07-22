import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campo_model.dart';

class CampoService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String collection = 'campos';


  /// ➕ Crear campo con control de duplicados
  Future<void> crearCampo(Campo campo) async {

    final query = await _firestore
        .collection(collection)
        .where(
          'hashCampo',
          isEqualTo: campo.hashCampo,
        )
        .limit(1)
        .get();


    if (query.docs.isNotEmpty) {

      throw Exception(
        'Ya existe un campo similar registrado',
      );

    }


    await _firestore
        .collection(collection)
        .add(
          campo.toMap(),
        );

  }



  /// 📄 Obtener campos publicados

  Stream<List<Campo>> obtenerCampos() {

    return _firestore
        .collection(collection)
        .where(
          'estadoPublicacion',
          isEqualTo: 'disponible',
        )
        .snapshots()
        .map((snapshot) {

          print(
            "CAMPOS DISPONIBLES: ${snapshot.docs.length}",
          );


          return snapshot.docs.map((doc) {

            return Campo.fromMap(
              doc.data(),
              doc.id,
            );

          }).toList();

        });

  }



  /// 👤 Campos donde el usuario es propietario

  Stream<List<Campo>> obtenerCamposPorPropietario(
      String propietarioId
  ) {

    return _firestore
        .collection(collection)
        .where(
          'propietarioId',
          isEqualTo: propietarioId,
        )
        .snapshots()
        .map((snapshot) {

          return snapshot.docs.map((doc) {

            return Campo.fromMap(
              doc.data(),
              doc.id,
            );

          }).toList();

        });

  }



  /// 👤 Campos publicados por un intermediario

  Stream<List<Campo>> obtenerCamposPorPublicador(
      String publicadorId
  ) {

    return _firestore
        .collection(collection)
        .where(
          'publicadorId',
          isEqualTo: publicadorId,
        )
        .snapshots()
        .map((snapshot) {

          return snapshot.docs.map((doc) {

            return Campo.fromMap(
              doc.data(),
              doc.id,
            );

          }).toList();

        });

  }



  /// 🔎 Obtener campo por ID

  Future<Campo?> obtenerCampoPorId(
      String campoId
  ) async {

    final doc = await _firestore
        .collection(collection)
        .doc(campoId)
        .get();


    if (doc.exists) {

      return Campo.fromMap(
        doc.data()!,
        doc.id,
      );

    }


    return null;

  }



  /// ✏️ Actualizar campo

  Future<void> actualizarCampo(
      String campoId,
      Map<String,dynamic> data
  ) async {

    await _firestore
        .collection(collection)
        .doc(campoId)
        .update(data);

  }



  /// 🗑 Eliminar campo

  Future<void> eliminarCampo(
      String campoId
  ) async {

    await _firestore
        .collection(collection)
        .doc(campoId)
        .delete();

  }


}