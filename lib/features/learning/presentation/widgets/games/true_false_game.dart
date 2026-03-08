import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/question_model.dart';
import 'components/check_button.dart'; // Importar el botón

class TrueFalseGame extends StatefulWidget {
  final QuestionModel question;
  final Function(bool) onAnswered;

  const TrueFalseGame({super.key, required this.question, required this.onAnswered});

  @override
  State<TrueFalseGame> createState() => _TrueFalseGameState();
}

class _TrueFalseGameState extends State<TrueFalseGame> {
  int? _selectedIndex; 

  void _handleSelection(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSubmit() {
    if (_selectedIndex == null) return;
    bool isCorrect = (_selectedIndex == widget.question.correctAnswerIndex);
    widget.onAnswered(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.balance, size: 60, color: Colors.blueAccent),
        ),
        const SizedBox(height: 30),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            widget.question.questionText,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 50),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDecisionCard(title: "FALSO", icon: Icons.close_rounded, baseColor: Colors.deepOrange, index: 1),
            _buildDecisionCard(title: "VERDAD", icon: Icons.check_rounded, baseColor: Colors.teal, index: 0),
          ],
        ),
        
        // Empujamos el botón hacia abajo
        const Spacer(), 
        CheckButton(
          isEnabled: _selectedIndex != null,
          onPressed: _onSubmit,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDecisionCard({required String title, required IconData icon, required Color baseColor, required int index}) {
    bool isSelected = _selectedIndex == index;
    bool isOtherSelected = _selectedIndex != null && _selectedIndex != index;
    double currentOpacity = isOtherSelected ? 0.4 : 1.0;

    return GestureDetector(
      onTap: () => _handleSelection(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: currentOpacity,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: isSelected ? 0.95 : 1.0, 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 140, height: 140,
            decoration: BoxDecoration(
              color: isSelected ? baseColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: baseColor.withOpacity(isSelected ? 1.0 : 0.3), width: isSelected ? 3 : 2),
              boxShadow: [
                if (!isOtherSelected) BoxShadow(color: baseColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 45, color: isSelected ? Colors.white : baseColor),
                const SizedBox(height: 10),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: isSelected ? Colors.white : baseColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}