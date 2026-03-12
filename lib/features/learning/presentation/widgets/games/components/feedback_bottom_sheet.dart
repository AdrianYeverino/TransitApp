import 'package:flutter/material.dart';

class FeedbackBottomSheet extends StatelessWidget {
  final bool isCorrect;
  final String feedback;
  final VoidCallback onContinue;

  const FeedbackBottomSheet({
    super.key,
    required this.isCorrect,
    required this.feedback,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    //Paleta de colores
    final Color backgroundColor = isCorrect ? Colors.green.shade50 : Colors.red.shade50;
    final Color primaryColor = isCorrect ? Colors.green.shade600 : Colors.red.shade600;
    final IconData icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final String title = isCorrect ? "¡Excelente!" : "Respuesta incorrecta";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Se adapta al contenido
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Título e icono 
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Texto de Feedback 
            if (feedback.isNotEmpty)
              Text(
                feedback,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: primaryColor.withValues(alpha: 0.8), 
                  height: 1.4,
                ),
              ),
            
            const SizedBox(height: 30),

            //Botón de Continuar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "CONTINUAR",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}