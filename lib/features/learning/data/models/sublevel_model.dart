// Archivo: sublevel_model.dart
import 'question_model.dart';

class SubLevelModel {
  final String id;
  final String titulo;
  final String descripcion;
  final int orden;
  final int xpRecompensa;
  final List<QuestionModel> preguntas;

  SubLevelModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.orden,
    required this.xpRecompensa,
    this.preguntas = const [],
  });

  factory SubLevelModel.fromMap(Map<String, dynamic> map, String id) {
    return SubLevelModel(
      id: id,
      titulo: map['titulo'] ?? 'Subnivel sin nombre',
      descripcion: map['descripcion'] ?? '',
      orden: map['orden'] ?? 0,
      // Leemos el campo exacto de tu captura image_6376c0.png
      xpRecompensa: map['xp_recompensa'] ?? 50, 
      preguntas: [], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'orden': orden,
      'xp_recompensa': xpRecompensa,
    };
  }

  SubLevelModel copyWith({List<QuestionModel>? preguntas}) {
    return SubLevelModel(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      orden: orden,
      xpRecompensa: xpRecompensa,
      preguntas: preguntas ?? this.preguntas,
    );
  }
}