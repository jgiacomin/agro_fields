import 'package:firebase_auth/firebase_auth.dart';

/// GAP-ADMIN-01 (16/11/2026): ¿el usuario actual es administrador?
///
/// Misma lista que `adminUids()` en firestore.rules (y el custom claim
/// "admin"). Esto solo decide qué se MUESTRA: lo que de verdad protege
/// son las reglas de Firebase.
const List<String> adminUids = ['RtUPcWdZHuQMNsDrza7firR2X2j1'];

bool esAdminPorUid(String? uid) => uid != null && adminUids.contains(uid);

Future<bool> esAdminActual() async {
  final usuario = FirebaseAuth.instance.currentUser;
  if (usuario == null) return false;
  if (esAdminPorUid(usuario.uid)) return true;
  try {
    final token = await usuario.getIdTokenResult();
    return token.claims?['admin'] == true;
  } catch (_) {
    return false;
  }
}
