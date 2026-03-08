import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';
import 'basic_quiz_game.dart'; // Importamos los juegos básicos
import 'true_false_game.dart'; // Importamos los juegos verdadero/falso
import 'image_quiz_game.dart'; // Importamos juego con imagen y opciones tipo quiz
import 'image_options_game.dart'; // Importamos el nuevo juego de imagen con opciones
import 'ordering_game.dart'; // Importamos el nuevo juego de ordenar
import 'fill_blank_game.dart'; // 1. IMPORTA EL NUEVO JUEGO AQUÍ
import 'matching_game.dart'; // 1. IMPORTA EL JUEGO DE EMPAREJAR
import 'multiple_choice_game.dart'; // 1. IMPORTA EL NUEVO JUEGO

class QuizRouter extends StatelessWidget {
  final QuestionModel question;
  final Function(bool isCorrect) onAnswered;

  const QuizRouter({super.key, required this.question, required this.onAnswered});

  @override
  Widget build(BuildContext context) {
    print("🚦 El Router está leyendo el tipo: '${question.type}'");
    switch (question.type) {
      case 'verdad_falso':
        return TrueFalseGame(question: question, onAnswered: onAnswered);
      
      case 'imagen':
        return ImageQuizGame(question: question, onAnswered: onAnswered);
        
      case 'opciones_imagen': 
        return ImageOptionsGame(question: question, onAnswered: onAnswered);

      // --- NUEVO CASO AÑADIDO ---
      case 'ordenar':
        return OrderingGame(question: question, onAnswered: onAnswered);

      // --- 2. AGREGA EL CASO PARA COMPLETAR ---
      case 'completar':
        return FillBlankGame(question: question, onAnswered: onAnswered);

      // --- 2. AGREGA EL CASO PARA EMPAREJAR ---
      case 'emparejar':
        return MatchingGame(question: question, onAnswered: onAnswered);

        // --- 2. AGREGA EL CASO PARA SELECCIÓN MÚLTIPLE ---
      case 'seleccion_multiple':
        return MultipleChoiceGame(question: question, onAnswered: onAnswered);

      case 'quiz':
      default:
        return BasicQuizGame(question: question, onAnswered: onAnswered);
    }
  }
}