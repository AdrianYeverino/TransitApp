// Archivo: question_model.dart
class QuestionModel {
  final String id;
  final String type;
  final String questionText;
  final String feedback;
  final String? imageUrl;
  final List<String>? options;

  final int? correctAnswerIndex;
  final List<int>? correctAnswerIndexes;
  final List<String>? correctOrder;
  final Map<String, dynamic>? matchingPairs;

  QuestionModel({
    required this.id,
    required this.type,
    required this.questionText,
    required this.feedback,
    this.imageUrl,
    this.options,
    this.correctAnswerIndex,
    this.correctAnswerIndexes,
    this.correctOrder,
    this.matchingPairs,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    final dynamic rawAnswer = map['respuesta_correcta'];

    return QuestionModel(
      id: id,
      type: map['tipo'] ?? 'quiz',
      questionText: map['enunciado'] ?? '',
      feedback: map['feedback'] ?? '',
      imageUrl: map['imagen_url'],
      options: map['opciones'] != null ? List<String>.from(map['opciones']) : null,
      
      correctAnswerIndex: rawAnswer is int ? rawAnswer : null,
      correctAnswerIndexes: rawAnswer is List && rawAnswer.isNotEmpty && rawAnswer.first is int 
          ? List<int>.from(rawAnswer) : null,
      correctOrder: rawAnswer is List && rawAnswer.isNotEmpty && rawAnswer.first is String 
          ? List<String>.from(rawAnswer) : null,
      matchingPairs: rawAnswer is Map ? Map<String, dynamic>.from(rawAnswer) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': type,
      'enunciado': questionText,
      'feedback': feedback,
      if (imageUrl != null) 'imagen_url': imageUrl,
      if (options != null) 'opciones': options,
      'respuesta_correcta': correctAnswerIndex ?? correctAnswerIndexes ?? correctOrder ?? matchingPairs,
    };
  }
}