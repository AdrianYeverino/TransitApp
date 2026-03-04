import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

class MultipleChoiceGame extends StatefulWidget {
  final QuestionModel question;
  final Function(bool) onAnswered;

  const MultipleChoiceGame({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<MultipleChoiceGame> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceGame> {
  // Aquí guardamos TODOS los índices que el usuario va marcando
  List<int> selectedIndexes = [];

  // Paleta de colores TransitApp
  final Color deepBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color multiSelectAccent = const Color(0xFF3F51B5); // Índigo vibrante para multiselección

  // Función para agregar o quitar una opción de la lista de seleccionadas
  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index); // Si ya estaba, la quitamos (desmarcar)
      } else {
        selectedIndexes.add(index); // Si no estaba, la agregamos (marcar)
      }
    });
  }

  // Validación exacta de la respuesta
  void _checkAnswer() {
    if (widget.question.correctAnswerIndexes == null) return;

    // Convertimos ambas listas a "Sets" para compararlas sin importar el orden en que el usuario las tocó
    final correctAnswers = widget.question.correctAnswerIndexes!.toSet();
    final userAnswers = selectedIndexes.toSet();

    // Es correcto SOLO SI tienen el mismo tamaño y contienen exactamente los mismos elementos
    bool isCorrect = (correctAnswers.length == userAnswers.length) && 
                     correctAnswers.containsAll(userAnswers);

    widget.onAnswered(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.question.options ?? [];

    return Column(
      children: [
        // --- 1. ZONA DEL ENUNCIADO ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(Icons.checklist_rtl_rounded, size: 40, color: deepBlue),
              const SizedBox(height: 10),
              Text(
                widget.question.questionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: deepBlue,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: multiSelectAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Selecciona TODAS las opciones correctas",
                  style: TextStyle(color: multiSelectAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 25),

        // --- 2. LISTA DE OPCIONES MULTIPLES ---
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndexes.contains(index);

              return GestureDetector(
                onTap: () => _toggleSelection(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? multiSelectAccent.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? multiSelectAccent : Colors.grey.shade300,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? multiSelectAccent.withOpacity(0.1) : Colors.black.withOpacity(0.02),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // El Checkbox visual animado
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isSelected ? multiSelectAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? multiSelectAccent : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      // El texto de la opción
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? deepBlue : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // --- 3. BOTÓN DE CONFIRMAR ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              // Solo se habilita si el usuario seleccionó al menos 1 opción
              onPressed: selectedIndexes.isNotEmpty ? _checkAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: deepBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: selectedIndexes.isNotEmpty ? 4 : 0,
              ),
              child: const Text(
                "COMPROBAR",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}