import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

class ImageOptionsGame extends StatelessWidget {
  final QuestionModel question;
  final Function(bool) onAnswered;

  const ImageOptionsGame({super.key, required this.question, required this.onAnswered});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. El enunciado de la pregunta
        Text(
          question.questionText,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        
        // 2. La cuadrícula 2x2 con las imágenes
        if (question.options != null)
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // Evita que se mueva si solo son 4 opciones
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Cuántas columnas queremos
                crossAxisSpacing: 15, // Espacio horizontal
                mainAxisSpacing: 15, // Espacio vertical
              ),
              itemCount: question.options!.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    // Evalúa si tocó la imagen correcta
                    bool isCorrect = (index == question.correctAnswerIndex);
                    onAnswered(isCorrect);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      // Carga la imagen desde la URL que está en la posición del array
                      child: Image.network(
                        question.options![index],
                        fit: BoxFit.contain,
                        // Muestra un ícono roto si el link de GitHub falla
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}