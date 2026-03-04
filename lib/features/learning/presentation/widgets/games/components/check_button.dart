import 'package:flutter/material.dart';

class CheckButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed; // Lo mantenemos como onPressed aquí para no romper tus otros juegos

  const CheckButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        // Si está habilitado es un azul vibrante, si no, es un gris inactivo
        color: isEnabled ? Colors.blueAccent : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isEnabled)
            BoxShadow(
              // CORRECCIÓN 1: Usamos la nueva sintaxis de Flutter para la transparencia
              color: Colors.blueAccent.withValues(alpha: 0.4), 
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // CORRECCIÓN 2: InkWell usa 'onTap' en lugar de 'onPressed'
          onTap: isEnabled ? onPressed : null, 
          child: Center(
            child: Text(
              "COMPROBAR",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                // Texto blanco si está activo, gris oscuro si está inactivo
                color: isEnabled ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}