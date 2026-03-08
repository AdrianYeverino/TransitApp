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
  List<String> leftItems = [];
  List<String> rightItems = [];
  
  // Elementos actualmente seleccionados (esperando a su pareja)
  String? selectedLeft;
  String? selectedRight;

  // Mapa de parejas formadas: Item Izquierdo -> Item Derecho
  Map<String, String> userPairs = {};
  
  // Mapa para guardar el color asignado a cada pareja (Item Izquierdo -> Color)
  Map<String, Color> activeColors = {};

  // Paleta de colores distintivos para cada par
  List<Color> availableColors = [
    const Color(0xFF9C27B0), // Morado
    const Color(0xFFFF9800), // Naranja
    const Color(0xFF009688), // Teal (Verde esmeralda)
    const Color(0xFFE91E63), // Rosa
    const Color(0xFF3F51B5), // Índigo
    const Color(0xFF795548), // Café
  ];

  final Color deepBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    if (widget.question.matchingPairs != null) {
      leftItems = widget.question.matchingPairs!.keys.toList()..shuffle();
      rightItems = widget.question.matchingPairs!.values.map((e) => e.toString()).toList()..shuffle();
    }
  }

  // --- LÓGICA DE EMPAREJAMIENTO ---

  void _onLeftTapped(String item) {
    setState(() {
      // 1. Si ya tiene pareja, rompemos la pareja
      if (userPairs.containsKey(item)) {
        _breakPair(item);
        return;
      }
      
      // 2. Si no tiene pareja, lo seleccionamos/deseleccionamos
      selectedLeft = (selectedLeft == item) ? null : item;
      _tryToPair();
    });
  }

  void _onRightTapped(String item) {
    setState(() {
      // 1. Buscamos si este item derecho ya está emparejado con alguien
      String? pairedLeftItem;
      userPairs.forEach((left, right) {
        if (right == item) pairedLeftItem = left;
      });

      // Si ya tiene pareja, rompemos la pareja
      if (pairedLeftItem != null) {
        _breakPair(pairedLeftItem!);
        return;
      }

      // 2. Si no tiene pareja, lo seleccionamos/deseleccionamos
      selectedRight = (selectedRight == item) ? null : item;
      _tryToPair();
    });
  }

  void _tryToPair() {
    // Si hay uno de cada lado seleccionado, los unimos
    if (selectedLeft != null && selectedRight != null) {
      // Sacamos un color de la lista de disponibles
      Color pairColor = availableColors.removeAt(0); 
      
      userPairs[selectedLeft!] = selectedRight!;
      activeColors[selectedLeft!] = pairColor; // Les asignamos el color

      // Limpiamos la selección temporal
      selectedLeft = null;
      selectedRight = null;
    }
  }

  void _breakPair(String leftItem) {
    // Recuperamos el color para que se pueda volver a usar
    Color freedColor = activeColors[leftItem]!;
    availableColors.add(freedColor);

    // Borramos la pareja
    userPairs.remove(leftItem);
    activeColors.remove(leftItem);
    
    // Nos aseguramos de limpiar selecciones a medias
    selectedLeft = null;
    selectedRight = null;
  }

  // --- EVALUACIÓN FINAL ---

  void _checkAnswers() {
    bool isAllCorrect = true;
    
    // Revisamos si cada pareja del usuario coincide con la base de datos
    for (String left in leftItems) {
      if (widget.question.matchingPairs![left] != userPairs[left]) {
        isAllCorrect = false;
        break;
      }
    }

    // Enviamos el resultado al QuizRouter
    widget.onAnswered(isAllCorrect);
  }

  @override
  Widget build(BuildContext context) {
    // El botón se activa solo cuando todos los elementos izquierdos tienen pareja
    bool isReady = userPairs.length == leftItems.length;

    return Column(
      children: [
        // --- 1. ENUNCIADO ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Icon(Icons.cable_rounded, size: 40, color: deepBlue),
              const SizedBox(height: 10),
              Text(
                widget.question.questionText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepBlue),
              ),
              const SizedBox(height: 8),
              Text(
                "Toca un elemento de cada lado para unirlos.\nToca un color para deshacer el par.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),

        // --- 2. COLUMNAS DE JUEGO ---
        Expanded(
          child: Row(
            children: [
              // Columna Izquierda
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: leftItems.length,
                  itemBuilder: (context, index) {
                    String item = leftItems[index];
                    bool isSelected = selectedLeft == item;
                    Color? pairedColor = activeColors[item]; // Tiene color si está emparejado

                    return _buildItemCard(
                      text: item,
                      isSelected: isSelected,
                      pairColor: pairedColor,
                      onTap: () => _onLeftTapped(item),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              // Columna Derecha
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: rightItems.length,
                  itemBuilder: (context, index) {
                    String item = rightItems[index];
                    bool isSelected = selectedRight == item;
                    
                    // Buscamos si este item derecho está en alguna pareja para sacar su color
                    Color? pairedColor;
                    userPairs.forEach((left, right) {
                      if (right == item) pairedColor = activeColors[left];
                    });

                    return _buildItemCard(
                      text: item,
                      isSelected: isSelected,
                      pairColor: pairedColor,
                      onTap: () => _onRightTapped(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // --- 3. BOTÓN DE COMPROBAR ---
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 10),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isReady ? _checkAnswers : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: deepBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: isReady ? 4 : 0,
              ),
              child: const Text("COMPROBAR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ),
      ],
    );
  }

  // Widget visual para las tarjetas dinámicas
  Widget _buildItemCard({
    required String text,
    required bool isSelected,
    required Color? pairColor,
    required VoidCallback onTap,
  }) {
    Color bgColor = Colors.white;
    Color borderColor = deepBlue.withOpacity(0.3);
    Color textColor = deepBlue;
    double borderWidth = 1.0;

    // Lógica visual: Si está emparejado
    if (pairColor != null) {
      bgColor = pairColor.withOpacity(0.15); // Fondo clarito del color asignado
      borderColor = pairColor;               // Borde fuerte
      textColor = pairColor;                 // Texto del color
      borderWidth = 2.0;
    } 
    // Lógica visual: Si está seleccionado (esperando pareja)
    else if (isSelected) {
      bgColor = deepBlue;
      borderColor = deepBlue;
      textColor = Colors.white;
      borderWidth = 2.0;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: (isSelected || pairColor != null)
              ? [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
    );
  }
}