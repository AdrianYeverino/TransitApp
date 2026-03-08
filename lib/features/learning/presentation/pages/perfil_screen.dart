import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario actual de la sesión
    final User? authUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Volver', style: TextStyle(fontSize: 16, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // Escuchamos los datos del usuario en tiempo real desde Firestore
      body: authUser == null 
        ? const Center(child: Text("Error: Usuario no encontrado"))
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(authUser.uid).snapshots(),
            builder: (context, snapshot) {
              
              // Pantalla de carga mientras trae los datos
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Extraemos la información de la base de datos
              var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              
              String nombre = userData['nombre'] ?? 'Usuario';
              String correo = authUser.email ?? 'correo@oculto.com';
              int xp = userData['xp'] ?? 0;
              int racha = userData['racha'] ?? 0;
              String nivelActual = userData['nivel_actual'] ?? '1';
              
              // Matemáticas de Progreso
              Map<String, dynamic> progreso = userData['progreso'] ?? {};
              
              // Contamos Preventivas (4 items: s1, s2, s3, examen)
              int prevCompletadas = 0;
              if (progreso['basico_s1'] == true) prevCompletadas++;
              if (progreso['basico_s2'] == true) prevCompletadas++;
              if (progreso['basico_s3'] == true) prevCompletadas++;
              if (progreso['basico_examen'] == true) prevCompletadas++;
              
              int totalLeccionesCompletadas = prevCompletadas; // Aquí sumarás los otros mundos luego
              int modulosCompletados = progreso['basico_examen'] == true ? 1 : 0;
              
              // Fechas
              DateTime fechaCreacion = authUser.metadata.creationTime ?? DateTime.now();
              String fechaRegistroStr = "${fechaCreacion.day}/${fechaCreacion.month}/${fechaCreacion.year}";
              DateTime fechaUltima = authUser.metadata.lastSignInTime ?? DateTime.now();
              String fechaUltimaStr = "${fechaUltima.day}/${fechaUltima.month}/${fechaUltima.year}";

              // Cálculo para el próximo nivel (ej. cada 500 XP)
              int metaXp = ((xp ~/ 500) + 1) * 500;
              double progresoNivelXp = (xp % 500) / 500;

              return SingleChildScrollView(
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
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.brown, 
                              child: Icon(Icons.person, size: 50, color: Colors.white), 
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          Text(correo, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Text('Nivel $nivelActual', style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTopStat(Icons.star_border, '$xp', 'XP Total'),
                              _buildTopStat(Icons.local_fire_department_outlined, '$racha', 'Racha'),
                              _buildTopStat(Icons.emoji_events_outlined, '$modulosCompletados', 'Módulos'),
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
                          const Row(
                            children: [
                              Icon(Icons.track_changes, color: Colors.blue, size: 20),
                              SizedBox(width: 10),
                              Text('Progreso General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildProgressBar('Lecciones completadas', '$totalLeccionesCompletadas/9', totalLeccionesCompletadas / 9),
                          const SizedBox(height: 20),
                          _buildProgressBar('Próximo nivel en:', '$metaXp XP', progresoNivelXp),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. INFORMACIÓN
                    _buildCardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, color: Colors.purpleAccent, size: 20),
                              SizedBox(width: 10),
                              Text('Información', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildInfoText('Miembro desde', fechaRegistroStr),
                          const SizedBox(height: 15),
                          _buildInfoText('Última actividad', fechaUltimaStr),
                          const SizedBox(height: 15),
                          _buildInfoText('Lecciones esta semana', '$totalLeccionesCompletadas lecciones'),
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
                          _buildModuleProgress(Icons.warning_amber_rounded, Colors.orange, 'Señales Preventivas', '$prevCompletadas/4 lecciones'),
                          const SizedBox(height: 15),
                          _buildModuleProgress(Icons.traffic, Colors.grey.shade800, 'Prioridades de Paso', '0/3 lecciones'),
                          const SizedBox(height: 15),
                          _buildModuleProgress(Icons.assignment_outlined, Colors.brown.shade300, 'Reglamento Local México', '0/3 lecciones'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 5. LOGROS (Estáticos por ahora)
                    _buildCardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                              SizedBox(width: 10),
                              Text('Logros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text('0/6 desbloqueados', style: TextStyle(color: Colors.blue.shade700, fontSize: 13)),
                          const SizedBox(height: 20),
                          _buildLogroItem(Icons.track_changes, 'Primer Paso', 'Completaste tu primera lección'),
                          _buildLogroItem(Icons.library_books, 'Estudiante Dedicado', 'Completaste 5 lecciones'),
                          _buildLogroItem(Icons.emoji_events, 'Maestro del Módulo', 'Completaste tu primer módulo'),
                          _buildLogroItem(Icons.local_fire_department, 'Racha de Fuego', 'Mantén una racha de 7 días'),
                          _buildLogroItem(Icons.star, 'Coleccionista de XP', 'Alcanza 500 XP'),
                          _buildLogroItem(Icons.directions_car, 'Conductor Experto', 'Completa todos los módulos'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }
          ),
    );
  }

  // --- WIDGETS DE APOYO (Intactos de tu diseño original) ---

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

  Widget _buildInfoText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
      ],
    );
  }

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
            value: progress.isNaN || progress.isInfinite ? 0.0 : progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleProgress(IconData icon, Color color, String title, String progress) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
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

  Widget _buildLogroItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}