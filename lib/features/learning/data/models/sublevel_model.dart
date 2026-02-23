import 'question_model.dart';

class SubLevelModel {
  final String id;
  final String titulo;
  final String descripcion;
  final int orden;           // Para saber si es el 1, 2, 3...
  final int xpRecompensa;    // Cuánta XP gana al completarlo
  final List<QuestionModel> preguntas; // Las preguntas de este nivel

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
      xpRecompensa: map['xp_recompensa'] ?? 50,
      // Nota: Las preguntas se suelen cargar por separado en una subcolección,
      // por eso aquí la iniciamos vacía por defecto.
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
  
  // Método helper para añadir preguntas después de cargarlas
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