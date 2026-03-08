import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  // ...existing code...

  // Módulo progress item widget
  Widget _buildModuleProgress(IconData icon, Color color, String title, String progress) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(progress, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

// Logro (achievement) item widget
Widget _buildLogroItem(IconData icon, String title, String description) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.amber, size: 24),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ],
    ),
  );
}

const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50, // Fondo grisecito claro
      appBar: AppBar(
        title: const Text('Volver', style: TextStyle(fontSize: 16, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Flecha negra
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // 1. TARJETA PRINCIPAL (DEGRADADO)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.purpleAccent],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Column(
                children: [
                  // Avatar con borde blanco
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.brown, // Color temporal para el muñequito
                      child: Icon(Icons.person, size: 50, color: Colors.white), // Aquí luego puedes poner tu AssetImage
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('gael', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text('gael@gmail.com', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Nivel 1', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(height: 30),
                  // Fila de Estadísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTopStat(Icons.star_border, '0', 'XP Total'),
                      _buildTopStat(Icons.local_fire_department_outlined, '0', 'Racha'),
                      _buildTopStat(Icons.emoji_events_outlined, '0', 'Módulos'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. PROGRESO GENERAL
            _buildCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.track_changes, color: Colors.blue, size: 20),
                      SizedBox(width: 10),
                      Text('Progreso General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildProgressBar('Lecciones completadas', '0/9', 0.0),
                  const SizedBox(height: 20),
                  _buildProgressBar('Próximo nivel en:', '500 XP', 0.0),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. INFORMACIÓN
            _buildCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_today_outlined, color: Colors.purpleAccent, size: 20),
                      SizedBox(width: 10),
                      Text('Información', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoText('Miembro desde', '23 de febrero de 2026'),
                  const SizedBox(height: 15),
                  _buildInfoText('Última actividad', '23/2/2026'),
                  const SizedBox(height: 15),
                  _buildInfoText('Lecciones esta semana', '0 lecciones'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. PROGRESO POR MÓDULO
            _buildCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progreso por Módulo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildModuleProgress(Icons.warning_amber_rounded, Colors.orange, 'Señales Preventivas', '0/3 lecciones'),
                  const SizedBox(height: 15),
                  _buildModuleProgress(Icons.traffic, Colors.grey.shade800, 'Prioridades de Paso', '0/3 lecciones'),
                  const SizedBox(height: 15),
                  _buildModuleProgress(Icons.assignment_outlined, Colors.brown.shade300, 'Reglamento Local México', '0/3 lecciones'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. LOGROS
            _buildCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      SizedBox(width: 10),
                      Text('Logros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text('0/6 desbloqueados', style: TextStyle(color: Colors.blue.shade700, fontSize: 13)),
                  const SizedBox(height: 20),
                  // Lista de logros
                  _buildLogroItem(Icons.track_changes, 'Primer Paso', 'Completaste tu primera lección'),
                  _buildLogroItem(Icons.library_books, 'Estudiante Dedicado', 'Completaste 5 lecciones'),
                  _buildLogroItem(Icons.emoji_events, 'Maestro del Módulo', 'Completaste tu primer módulo'),
                  _buildLogroItem(Icons.local_fire_department, 'Racha de Fuego', 'Mantén una racha de 7 días'),
                  _buildLogroItem(Icons.star, 'Coleccionista de XP', 'Alcanza 500 XP'),
                  _buildLogroItem(Icons.directions_car, 'Conductor Experto', 'Completa todos los módulos'),
                ],
              ),
            ),
            const SizedBox(height: 30), // Espacio extra al final para scrollear a gusto
          ],
        ),
      ),
    );
  }

  // --- FUNCIONES DE AYUDA (Para mantener el código limpio) ---

  // Contenedor blanco con sombra suave para todas las tarjetas
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  // Ítems de la tarjeta morada (Estrella, Fuego, Trofeo)
  Widget _buildTopStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 5),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // Información (label + valor)
  Widget _buildInfoText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
      ],
    );
  }

    // Barras de progreso general
    Widget _buildProgressBar(String label, String value, double progress) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      );
    }
  }