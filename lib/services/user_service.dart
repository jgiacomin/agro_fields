import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 📥 LEER USUARIO
  Future<UserModel?> getUsuario(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }

    return null;
  }

  // 📤 CREAR USUARIO SI NO EXISTE
  Future<void> crearUsuarioSiNoExiste(UserModel usuario) async {
    final doc = _db.collection('usuarios').doc(usuario.uid);

    final documento = await doc.get();

     if (!documento.exists) {
      await doc.set(usuario.toMap());
      print("Usuario creado en Firestore");
    } else {
      print("El usuario ya existe");
    }
  }
}