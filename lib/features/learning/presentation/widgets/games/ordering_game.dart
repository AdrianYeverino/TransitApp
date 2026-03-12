import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

class OrderingGame extends StatefulWidget {
  final QuestionModel question;
  final Function(bool isCorrect) onAnswered; 

  const OrderingGame({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<OrderingGame> createState() => _OrderingGameState();
}

class _OrderingGameState extends State<OrderingGame> {
  late List<String> currentOrder;

  // Paleta de colores de TransitApp
  final Color deepBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color dragAccentColor = const Color(0xFFFF9800); 

  @override
  void initState() {
    super.initState();
    // Cargamos las opciones desordenadas que vienen del JSON
    currentOrder = List.from(widget.question.options ?? []);
  }

  // Función para validar 
  void _checkAnswer() {
    if (widget.question.correctOrder == null) return;

    bool isCorrect = true;
    for (int i = 0; i < currentOrder.length; i++) {
      if (currentOrder[i] != widget.question.correctOrder![i]) {
        isCorrect = false;
        break;
      }
    }
    // Retornamos el resultado al router
    widget.onAnswered(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(Icons.format_list_numbered_rounded, size: 40, color: deepBlue),
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
              Text(
                "Mantén presionado y arrastra para ordenar",
                style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),

        // 2. ZONA INTERACTIVA DE ARRASTRE 
        Expanded(
          child: Theme(
            data: ThemeData(canvasColor: Colors.transparent),
            child: ReorderableListView.builder(
              itemCount: currentOrder.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final String item = currentOrder.removeAt(oldIndex);
                  currentOrder.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final itemText = currentOrder[index];
                return ReorderableDelayedDragStartListener( 
                  key: ValueKey(itemText),
                  index: index,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dragAccentColor.withOpacity(0.5), width: 2),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: dragAccentColor,
                        child: Text("${index + 1}"),
                      ),
                      title: Text(itemText),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: Icon(Icons.drag_indicator, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // 3. BOTÓN DE CONFIRMACION
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: deepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
              ),
              child: const Text(
                "CONFIRMAR ORDEN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}