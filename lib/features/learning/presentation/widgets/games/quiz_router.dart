import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';
import 'basic_quiz_game.dart'; // Importamos los juegos básicos
import 'true_false_game.dart'; // Importamos los juegos verdadero/falso
import 'image_quiz_game.dart'; //Importamos juego con imagen y opciones tipo quiz
import 'image_options_game.dart'; // Importamos el nuevo juego de imagen con opciones

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
        
      // 2. AGREGA EL CASO EXACTO AQUÍ
      case 'opciones_imagen': 
        return ImageOptionsGame(question: question, onAnswered: onAnswered);
        
      case 'quiz':
      default:
        return BasicQuizGame(question: question, onAnswered: onAnswered);
    }
  }
}