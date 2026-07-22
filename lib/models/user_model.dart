import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final String foto;
  final String rol;
  final DateTime fechaAlta;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.foto,
    required this.rol,
    required this.fechaAlta,
  });

  // 📤 GUARDAR EN FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'foto': foto,
      'rol': rol,
      'fechaAlta': FieldValue.serverTimestamp(),
    };
  }

  // 📥 LEER DESDE FIRESTORE
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      foto: map['foto'] ?? '',
      rol: map['rol'] ?? 'Inversor',
      fechaAlta: map['fechaAlta'] != null
    ? (map['fechaAlta'] as Timestamp).toDate()
    : DateTime.now(),
    );
  }
}