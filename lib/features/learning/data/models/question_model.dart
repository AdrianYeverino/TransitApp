class QuestionModel {
  final String id;
  final String enunciado;       // La pregunta en sí
  final List<String> opciones;  // Las 3 o 4 posibles respuestas
  final int respuestaCorrecta;  // El índice (0, 1, 2...) de la correcta
  final String feedback;        // La explicación que sale al contestar
  final String tipo;            // 'quiz' (texto) o 'visual' (imagen)
  final String? imagenUrl;      // Opcional: Solo si el tipo es 'visual'

  QuestionModel({
    required this.id,
    required this.enunciado,
    required this.opciones,
    required this.respuestaCorrecta,
    required this.feedback,
    this.tipo = 'quiz',
    this.imagenUrl,
  });

  // Convierte lo que viene de Firestore (Map) a tu Objeto Dart
  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestionModel(
      id: id,
      enunciado: map['enunciado'] ?? '',
      // Aseguramos que sea una lista de Strings
      opciones: List<String>.from(map['opciones'] ?? []),
      respuestaCorrecta: map['respuesta_correcta'] ?? 0,
      feedback: map['feedback'] ?? '¡Bien hecho!',
      tipo: map['tipo'] ?? 'quiz',
      imagenUrl: map['imagen_url'],
    );
  }

  // Convierte tu Objeto Dart a Mapa para subirlo a Firestore (si creas un editor)
  Map<String, dynamic> toMap() {
    return {
      'enunciado': enunciado,
      'opciones': opciones,
      'respuesta_correcta': respuestaCorrecta,
      'feedback': feedback,
      'tipo': tipo,
      'imagen_url': imagenUrl,
    };
  }
}