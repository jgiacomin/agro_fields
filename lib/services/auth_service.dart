import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<User?> signInWithGoogle() async {
    try {
      late UserCredential result;

      if (kIsWeb) {
        // WEB: autenticación mediante popup de Firebase.
        final provider = GoogleAuthProvider();

        // Obliga a Google a mostrar el selector de cuentas.
        provider.setCustomParameters({
          'prompt': 'select_account',
        });

        result = await _auth.signInWithPopup(provider);
      } else {
        // ANDROID / IOS: autenticación nativa de Google.
        final GoogleSignInAccount? googleUser =
            await GoogleSignIn().signIn();

        // El usuario canceló la selección de cuenta.
        if (googleUser == null) {
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        result = await _auth.signInWithCredential(credential);
      }

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