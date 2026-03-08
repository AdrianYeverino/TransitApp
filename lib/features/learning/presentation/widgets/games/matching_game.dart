import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

class MatchingGame extends StatefulWidget {
  final QuestionModel question;
  final Function(bool) onAnswered;

  const MatchingGame({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  // Listas de elementos disponibles para emparejar
  List<String> availableLeft = [];
  List<String> availableRight = [];
  
  // Elementos actualmente seleccionados (resaltados en naranja)
  String? selectedLeft;
  String? selectedRight;

  // Mapa para guardar las parejas que el usuario ya formó
  Map<String, String> userPairs = {};

  // Paleta de colores TransitApp + Contrastes Dinámicos
  final Color deepBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color highlightColor = const Color(0xFFFF9800); // Naranja: Seleccionado
  final Color pairedColor = const Color(0xFF009688);    // Teal (Verde esmeralda): Emparejado

  @override
  void initState() {
    super.initState();
    // Extraemos las llaves y valores del mapa de Firebase y los desordenamos
    if (widget.question.matchingPairs != null) {
      availableLeft = widget.question.matchingPairs!.keys.toList()..shuffle();
      availableRight = widget.question.matchingPairs!.values.map((e) => e.toString()).toList()..shuffle();
    }
  }

  // Lógica al tocar una tarjeta de la izquierda
  void _onLeftTapped(String item) {
    setState(() {
      // Si ya estaba seleccionada, la deselecciona. Si no, la selecciona.
      selectedLeft = (selectedLeft == item) ? null : item;
      _checkAndMakePair();
    });
  }

  // Lógica al tocar una tarjeta de la derecha
  void _onRightTapped(String item) {
    setState(() {
      selectedRight = (selectedRight == item) ? null : item;
      _checkAndMakePair();
    });
  }

  // Si hay una de cada lado seleccionada, ¡creamos la pareja!
  void _checkAndMakePair() {
    if (selectedLeft != null && selectedRight != null) {
      userPairs[selectedLeft!] = selectedRight!;
      availableLeft.remove(selectedLeft);
      availableRight.remove(selectedRight);
      // Limpiamos la selección
      selectedLeft = null;
      selectedRight = null;
    }
  }

  // Lógica para romper una pareja si el usuario se arrepintió
  void _breakPair(String leftItem, String rightItem) {
    setState(() {
      userPairs.remove(leftItem);
      availableLeft.add(leftItem);
      availableRight.add(rightItem);
    });
  }

  // Validación final al presionar "COMPROBAR"
  void _checkFinalAnswer() {
    if (widget.question.matchingPairs == null) return;
    
    bool isCorrect = true;
    final correctPairs = widget.question.matchingPairs!;

    // Revisamos si cada pareja que armó el usuario coincide con la base de datos
    userPairs.forEach((left, right) {
      if (correctPairs[left] != right) {
        isCorrect = false;
      }
    });

    widget.onAnswered(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    // Si ya no hay elementos disponibles en las columnas, el juego está listo para comprobar
    bool isReadyToSubmit = availableLeft.isEmpty && availableRight.isEmpty;

    return Column(
      children: [
        // --- 1. ENUNCIADO ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(Icons.cable_rounded, size: 40, color: deepBlue),
              const SizedBox(height: 10),
              Text(
                widget.question.questionText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepBlue),
              ),
              const SizedBox(height: 8),
              Text(
                "Toca un elemento de cada columna para unirlos",
                style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),

        // --- 2. COLUMNAS DE EMPAREJAMIENTO ---
        if (!isReadyToSubmit)
          Expanded(
            child: Row(
              children: [
                // Columna Izquierda
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: availableLeft.length,
                    itemBuilder: (context, index) {
                      String item = availableLeft[index];
                      bool isSelected = selectedLeft == item;
                      return _buildItemCard(item, isSelected, () => _onLeftTapped(item));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                // Columna Derecha
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: availableRight.length,
                    itemBuilder: (context, index) {
                      String item = availableRight[index];
                      bool isSelected = selectedRight == item;
                      return _buildItemCard(item, isSelected, () => _onRightTapped(item));
                    },
                  ),
                ),
              ],
            ),
          ),

        // --- 3. ZONA DE "TUS PAREJAS" (Aparece cuando creas uniones) ---
        if (userPairs.isNotEmpty) ...[
          const Divider(height: 30, thickness: 2),
          Text(
            "Tus Parejas (Toca para separar)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: deepBlue),
          ),
          const SizedBox(height: 10),
          // Usamos Wrap para que las parejas se acomoden en renglones automáticamente
          Container(
            constraints: const BoxConstraints(maxHeight: 180), // Límite de altura
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: userPairs.entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _breakPair(entry.key, entry.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: pairedColor.withOpacity(0.1),
                        border: Border.all(color: pairedColor, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, color: pairedColor)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.link, size: 18, color: Colors.grey),
                          ),
                          Text(entry.value, style: TextStyle(fontWeight: FontWeight.bold, color: pairedColor)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],

        // Si el usuario ya terminó de emparejar, llenamos el espacio vacío
        if (isReadyToSubmit) const Spacer(),

        // --- 4. BOTÓN DE CONFIRMAR ---
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isReadyToSubmit ? _checkFinalAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: deepBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: isReadyToSubmit ? 4 : 0,
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

  // Widget reutilizable para las tarjetas de las columnas
  Widget _buildItemCard(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? highlightColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? highlightColor : deepBlue.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: highlightColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : deepBlue,
          ),
        ),
      ),
    );
  }
}