import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/question_model.dart';
// Importamos nuestro nuevo componente compartido
import 'components/check_button.dart';

class BasicQuizGame extends StatefulWidget {
  final QuestionModel question;
  final Function(bool) onAnswered;

  const BasicQuizGame({super.key, required this.question, required this.onAnswered});

  @override
  State<BasicQuizGame> createState() => _BasicQuizGameState();
}

class _BasicQuizGameState extends State<BasicQuizGame> {
  int? _selectedIndex;

  // 1. Ahora solo selecciona visualmente, NO envía la respuesta
  void _handleSelection(int index) {
    HapticFeedback.selectionClick(); 
    setState(() {
      _selectedIndex = index;
    });
  }

  // 2. Nueva función que se ejecuta al presionar "COMPROBAR"
  void _onSubmit() {
    if (_selectedIndex == null) return; // Por seguridad
    bool isCorrect = (_selectedIndex == widget.question.correctAnswerIndex);
    widget.onAnswered(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.quiz_rounded, size: 40, color: Colors.blueAccent),
        ),
        const SizedBox(height: 20),

        Text(
          widget.question.questionText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),

        if (widget.question.options != null)
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: widget.question.options!.length,
              itemBuilder: (context, index) {
                return _buildOptionCard(text: widget.question.options![index], index: index);
              },
            ),
          ),
          
        const SizedBox(height: 10),
        // 3. AQUÍ AGREGAMOS EL BOTÓN AL FINAL DE LA PANTALLLA
        CheckButton(
          isEnabled: _selectedIndex != null, // Solo se activa si eligió algo
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20), // Margen inferior
      ],
    );
  }

  // (El _buildOptionCard se queda igualito al que ya tenías)
  Widget _buildOptionCard({required String text, required int index}) {
    bool isSelected = _selectedIndex == index;
    bool isOtherSelected = _selectedIndex != null && _selectedIndex != index;
    List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    String letter = index < letters.length ? letters[index] : '';

    return GestureDetector(
      onTap: () => _handleSelection(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isOtherSelected ? 0.4 : 1.0, 
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: isSelected ? 0.96 : 1.0, 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey.shade300, width: 2),
              boxShadow: [
                if (!isOtherSelected && !isSelected) BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                if (isSelected) BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40, alignment: Alignment.center,
                  decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.2) : Colors.blue.shade50, shape: BoxShape.circle),
                  child: Text(letter, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.blueAccent)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black87, height: 1.4))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}