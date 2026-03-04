import 'package:flutter/material.dart';
import '../../../data/models/question_model.dart';

class ImageOptionsGame extends StatefulWidget {
  final QuestionModel question;
  final Function(bool) onAnswered;

  const ImageOptionsGame({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<ImageOptionsGame> createState() => _ImageOptionsGameState();
}

class _ImageOptionsGameState extends State<ImageOptionsGame> {
  // Variable para rastrear qué imagen tocó el usuario
  int? selectedIndex;

  // Paleta de colores de TransitApp
  final Color deepBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color selectionColor = const Color(0xFFFF9800); // Naranja para resaltar selección

  // Función para validar la respuesta
  void _checkAnswer() {
    if (selectedIndex == null || widget.question.correctAnswerIndex == null) return;
    
    bool isCorrect = (selectedIndex == widget.question.correctAnswerIndex);
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
              Icon(Icons.image_search_rounded, size: 40, color: deepBlue),
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
                "Toca la imagen correcta para seleccionarla",
                style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 25),
        
        // --- 2. ZONA DE IMÁGENES (CUADRÍCULA) ---
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.9, // Hace las tarjetas ligeramente más altas que anchas
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              final imageUrl = options[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  // Diseño de la tarjeta seleccionada vs normal
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? selectionColor : lightBlue,
                      width: isSelected ? 4 : 2, // Borde más grueso al seleccionar
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? selectionColor.withOpacity(0.3) 
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 10 : 5,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // La imagen con soporte para diferentes tamaños
                      Padding(
                        padding: const EdgeInsets.all(12.0), // Espacio para que respire
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain, // Ajusta sin deformar ni cortar
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: deepBlue,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text("Sin imagen", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Insignia (Palomita) que aparece al seleccionar
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: selectionColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 20),
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