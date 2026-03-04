class QuestionModel {
  final String id;
  final String type; // Mapeado desde 'tipo'
  final String questionText; // Mapeado desde 'enunciado'
  final String feedback; 
  final String? imageUrl; // Mapeado desde 'imagen_url'

  // Para Quiz normal, V/F, Imagen, y Completar
  final List<String>? options; // Mapeado desde 'opciones'
  final int? correctAnswerIndex; // Mapeado desde 'respuesta_correcta'

  // Para Selección Múltiple
  final List<int>? correctAnswerIndexes; // Mapeado desde 'respuestas_correctas'

  // Para Ordenamiento (Drag & Drop)
  final List<String>? correctOrder; // Mapeado desde 'orden_correcto'

  // Para Emparejar (Matching)
  final Map<String, dynamic>? matchingPairs; // Mapeado desde 'parejas'

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

  // Convierte el mapa de Firestore (Español) a Objeto Dart (Inglés)
  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestionModel(
      id: id,
      type: map['tipo'] ?? 'quiz_basico',
      questionText: map['enunciado'] ?? '',
      feedback: map['feedback'] ?? '',
      imageUrl: map['imagen_url'],
      options: map['opciones'] != null ? List<String>.from(map['opciones']) : null,
      correctAnswerIndex: map['respuesta_correcta'],
      correctAnswerIndexes: map['respuestas_correctas'] != null ? List<int>.from(map['respuestas_correctas']) : null,
      correctOrder: map['orden_correcto'] != null ? List<String>.from(map['orden_correcto']) : null,
      matchingPairs: map['parejas'] != null ? Map<String, dynamic>.from(map['parejas']) : null,
    );
  }

  // Convierte el Objeto Dart (Inglés) a Mapa para Firestore (Español)
  Map<String, dynamic> toMap() {
    return {
      'tipo': type,
      'enunciado': questionText,
      'feedback': feedback,
      if (imageUrl != null) 'imagen_url': imageUrl,
      if (options != null) 'opciones': options,
      if (correctAnswerIndex != null) 'respuesta_correcta': correctAnswerIndex,
      if (correctAnswerIndexes != null) 'respuestas_correctas': correctAnswerIndexes,
      if (correctOrder != null) 'orden_correcto': correctOrder,
      if (matchingPairs != null) 'parejas': matchingPairs,
    };
  }
}