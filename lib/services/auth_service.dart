import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<User?> signInWithGoogle() async {
    try {
      print("LOGIN START");

      final provider = GoogleAuthProvider();

      final result = await _auth.signInWithPopup(provider);

      final user = result.user;

      if (user != null) {
        print("LOGIN SUCCESS");
        print("USER EMAIL: ${user.email}");
        print("USER UID: ${user.uid}");

        final userModel = UserModel(
          uid: user.uid,
          nombre: user.displayName ?? '',
          email: user.email ?? '',
          foto: user.photoURL ?? '',
          rol: 'Comprador',
          fechaAlta: DateTime.now(),
        );

        await _userService.crearUsuarioSiNoExiste(userModel);

        print("USUARIO GUARDADO EN FIRESTORE");
      }

      return user;
    } catch (e) {
      print("ERROR LOGIN: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}