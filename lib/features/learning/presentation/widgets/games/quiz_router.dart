import 'package:flutter/material.dart';
// Importación de todos los tipos de juegos disponibles
import '../../../data/models/question_model.dart';
import 'basic_quiz_game.dart'; 
import 'true_false_game.dart'; 
import 'image_quiz_game.dart'; 
import 'image_options_game.dart'; 
import 'ordering_game.dart'; 
import 'fill_blank_game.dart'; 
import 'matching_game.dart'; 
import 'multiple_choice_game.dart'; 

class QuizRouter extends StatelessWidget {
  final QuestionModel question;
  final Function(bool isCorrect) onAnswered;

  const QuizRouter({super.key, required this.question, required this.onAnswered});

  @override
  Widget build(BuildContext context) {
    // Debug log para verificar que el backend envía el string correcto
    print("El Router está leyendo el tipo: '${question.type}'");
    switch (question.type) {
      case 'verdad_falso':
        return TrueFalseGame(question: question, onAnswered: onAnswered);
      
      case 'imagen':
        return ImageQuizGame(question: question, onAnswered: onAnswered);
        
      case 'opciones_imagen': 
        return ImageOptionsGame(question: question, onAnswered: onAnswered);

      case 'ordenar':
        return OrderingGame(question: question, onAnswered: onAnswered);

      case 'completar':
        return FillBlankGame(question: question, onAnswered: onAnswered);

      case 'emparejar':
        return MatchingGame(question: question, onAnswered: onAnswered);

      case 'seleccion_multiple':
        return MultipleChoiceGame(question: question, onAnswered: onAnswered);
      // Si el tipo no coincide o es quiz estándar, carga el juego base
      case 'quiz':
      default:
        return BasicQuizGame(question: question, onAnswered: onAnswered);
    }
  }
}