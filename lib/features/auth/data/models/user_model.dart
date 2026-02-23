import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final String nivelActual;
  final int subnivelActual;
  final int xp;
  final int racha;
  final DateTime fechaRegistro;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.nivelActual,
    required this.subnivelActual,
    required this.xp,
    required this.racha,
    required this.fechaRegistro,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      nivelActual: data['nivel_actual'] ?? 'Básico',
      subnivelActual: data['subnivel_actual'] ?? 1,
      xp: data['xp'] ?? 0,
      racha: data['racha'] ?? 0,
      fechaRegistro: (data['fecha_registro'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'nivel_actual': nivelActual,
      'subnivel_actual': subnivelActual,
      'xp': xp,
      'racha': racha,
      'fecha_registro': fechaRegistro,
    };
  }
}