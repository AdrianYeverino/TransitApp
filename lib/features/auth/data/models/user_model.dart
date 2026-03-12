import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final String nivelActual;
  final int subnivelActual;
  final int xp;
  final int racha;
  final int rachaMaxima; 
  final int leccionesJugadas; 
  final int mejorTiempo;  
  final List<String> logrosDesbloqueados; 
  final List<String> subnivelesDesbloqueados; 
  final Map<String, dynamic> progresoNiveles; 
  final DateTime fechaRegistro;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.nivelActual,
    required this.subnivelActual,
    required this.xp,
    required this.racha,
    required this.rachaMaxima,
    required this.leccionesJugadas,
    required this.mejorTiempo,
    required this.logrosDesbloqueados,
    required this.subnivelesDesbloqueados,
    required this.progresoNiveles,
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
      rachaMaxima: data['racha_maxima'] ?? 0,
      leccionesJugadas: data['lecciones_jugadas'] ?? 0,
      mejorTiempo: data['mejor_tiempo'] ?? 0,
      logrosDesbloqueados: List<String>.from(data['logros_desbloqueados'] ?? []),
      subnivelesDesbloqueados: List<String>.from(data['subniveles_desbloqueados'] ?? ['basico_s1']),
      progresoNiveles: Map<String, dynamic>.from(data['progreso_niveles'] ?? {
        'basico': 0, 'intermedio': 0, 'avanzado': 0
      }),
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
      'racha_maxima': rachaMaxima,
      'lecciones_jugadas': leccionesJugadas,
      'mejor_tiempo': mejorTiempo,
      'logros_desbloqueados': logrosDesbloqueados,
      'subniveles_desbloqueados': subnivelesDesbloqueados,
      'progreso_niveles': progresoNiveles,
      'fecha_registro': fechaRegistro,
    };
  }
}