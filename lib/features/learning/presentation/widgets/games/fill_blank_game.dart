import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

class FillBlankGame extends StatefulWidget {
  final QuestionModel question;
  final Function(bool isCorrect) onAnswered;

  const FillBlankGame({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<FillBlankGame> createState() => _FillBlankGameState();
}

class _FillBlankGameState extends State<FillBlankGame> {
  // Guarda el índice de la opción que el usuario seleccionó
  int? selectedIndex;

  // Paleta de colores consistente
  final Color deepBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color accentColor = const Color(0xFF1976D2); // Azul intermedio para selecciones

  void _checkAnswer() {
    if (selectedIndex == null || widget.question.correctAnswerIndex == null) return;
    
    // Compara el índice seleccionado con el correcto de Firebase
    bool isCorrect = selectedIndex == widget.question.correctAnswerIndex;
    widget.onAnswered(isCorrect);
  }

  // Esta función divide el texto y le inserta un widget en el espacio en blanco
  List<InlineSpan> _buildDynamicSentence() {
    final String text = widget.question.questionText;
    final List<String> parts = text.split('___');
    List<InlineSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      // Añade el texto normal
      spans.add(TextSpan(text: parts[i], style: TextStyle(fontSize: 20, color: deepBlue, height: 1.5)));
      
      // Si no es la última parte, añade el espacio en blanco
      if (i < parts.length - 1) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: selectedIndex != null ? accentColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedIndex != null ? accentColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Text(
                selectedIndex != null ? widget.question.options![selectedIndex!] : "      ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedIndex != null ? Colors.white : Colors.transparent,
                ),
              ),
            ),
          ),
        );
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.question.options ?? [];

    return Column(
      children: [
        // --- 1. ZONA DE LA ORACIÓN (ENUNCIADO) ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(Icons.edit_document, size: 40, color: deepBlue),
              const SizedBox(height: 15),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: _buildDynamicSentence()),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),

        // --- 2. ZONA DE OPCIONES (BOTONES) ---
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Dos columnas para que se vea balanceado
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 2.5, // Hace que los botones sean rectangulares
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? deepBlue : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? deepBlue : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: deepBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    options[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : deepBlue,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // --- 3. BOTÓN DE CONFIRMACIÓN ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              // Si no ha seleccionado nada, el botón se deshabilita (null)
              onPressed: selectedIndex != null ? _checkAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: deepBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: selectedIndex != null ? 4 : 0,
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