import 'package:flutter/material.dart';
import '../../../data/models/sublevel_model.dart';

class LevelButtonWidget extends StatelessWidget {
  final SubLevelModel leccion;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback onTap;

  const LevelButtonWidget({
    super.key,
    required this.leccion,
    required this.isUnlocked,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: isUnlocked ? onTap : null,
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: isUnlocked 
                ? (isCurrent ? const Color(0xFFFFC107) : const Color(0xFF0D47A1)) 
                : Colors.grey[300],
              shape: BoxShape.circle,
              boxShadow: [
                if (isUnlocked)
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: Icon(
              isUnlocked ? (isCurrent ? Icons.play_arrow : Icons.check) : Icons.lock,
              color: Colors.white, size: 36,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          leccion.titulo,
          style: TextStyle(fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black : Colors.grey),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}