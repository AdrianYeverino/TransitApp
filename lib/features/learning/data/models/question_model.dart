// Modelo dinámico que representa una pregunta o reto dentro de un nivel.
class QuestionModel {
  final String id;
  final String type;
  final String questionText;
  final String feedback;
  final String? imageUrl;
  final List<String>? options;
  // Las siguientes variables son opciones
  final int? correctAnswerIndex;
  final List<int>? correctAnswerIndexes;
  final List<String>? correctOrder;
  final Map<String, dynamic>? matchingPairs;

  QuestionModel({
    required this.id,
    required this.type,
    required this.questionText,
    required this.feedback,
    // Datos opcionales 
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
      options: map['opciones'] != null ? List<String>.from(map['opciones']) : null, // Si hay opciones en la base de datos, las convierte en una lista de textos de Dart
      
      // Revisa de qué tipo de pregunta es con el comando 'is' es el 'rawAnswer' y lo guarda en la variable correcta
      // ¿Es un número entero? Entonces es un quiz de 1 sola respuesta
      correctAnswerIndex: rawAnswer is int ? rawAnswer : null,

      // ¿Es una lista de números? Entonces es un quiz de múltiples respuestas
      correctAnswerIndexes: rawAnswer is List && rawAnswer.isNotEmpty && rawAnswer.first is int 
          ? List<int>.from(rawAnswer) : null,
      
      // ¿Es una lista de textos? Entonces es un juego de ordenar
      correctOrder: rawAnswer is List && rawAnswer.isNotEmpty && rawAnswer.first is String 
          ? List<String>.from(rawAnswer) : null,

      // ¿Es un diccionario o mapa? Entonces es un juego de relacionar pares
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