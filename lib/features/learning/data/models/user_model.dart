// Archivo: user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final int xp;
  final int racha;
  final int rachaMaxima;
  final int leccionesJugadas;
  final DateTime? ultimaPartida;
  final List<String> subnivelesDesbloqueados;
  final Map<String, int> progresoNiveles;

  UserModel({
    required this.id,
    this.xp = 0,
    this.racha = 0,
    this.rachaMaxima = 0,
    this.leccionesJugadas = 0,
    this.ultimaPartida,
    required this.subnivelesDesbloqueados,
    required this.progresoNiveles,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      xp: map['xp'] ?? 0,
      racha: map['racha'] ?? 0,
      rachaMaxima: map['racha_maxima'] ?? 0,
      leccionesJugadas: map['lecciones_jugadas'] ?? 0,
      ultimaPartida: map['ultima_partida'] != null ? (map['ultima_partida'] as Timestamp).toDate() : null,
      subnivelesDesbloqueados: List<String>.from(map['subniveles_desbloqueados'] ?? []),
      progresoNiveles: Map<String, int>.from(map['progreso_niveles'] ?? {}),
    );
  }
}