import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? authUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Volver', style: TextStyle(fontSize: 16, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: authUser == null 
        ? const Center(child: Text("Error: Usuario no encontrado"))
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(authUser.uid).snapshots(),
            builder: (context, snapshot) {
              
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              
              String nombre = userData['nombre'] ?? 'Usuario';
              String correo = authUser.email ?? 'correo@oculto.com';
              int xp = userData['xp'] ?? 0;
              int racha = userData['racha'] ?? 0;
              String nivelActual = userData['nivel_actual'] ?? 'Básico';
              
              // LA SOLUCIÓN: Leer la lista real de nuestra base de datos
              List<String> completadas = List<String>.from(userData['lecciones_completadas'] ?? []);
              
              // Matemáticas de Progreso reales
              int prevCompletadas = 0;
              if (completadas.contains('basico_s1')) prevCompletadas++;
              if (completadas.contains('basico_s2')) prevCompletadas++;
              if (completadas.contains('basico_s3')) prevCompletadas++;
              if (completadas.contains('basico_examen')) prevCompletadas++;
              
              int totalLeccionesCompletadas = completadas.length; 
              
              // Cuenta cuántos exámenes finales ha pasado el usuario (Módulos completados)
              int modulosCompletados = completadas.where((id) => id.contains('examen')).length;
              
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
                          // Cambié el límite estático de 9 por uno dinámico
                          _buildProgressBar('Lecciones completadas', '$totalLeccionesCompletadas completadas', totalLeccionesCompletadas > 0 ? 1.0 : 0.0),
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
                          _buildInfoText('Lecciones en total', '$totalLeccionesCompletadas lecciones'),
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
                          _buildModuleProgress(Icons.warning_amber_rounded, Colors.blue, 'Mundo Básico', '$prevCompletadas lecciones'),
                          const SizedBox(height: 15),
                          _buildModuleProgress(Icons.traffic, Colors.orange, 'Mundo Intermedio', 'Bloqueado'),
                          const SizedBox(height: 15),
                          _buildModuleProgress(Icons.assignment_outlined, Colors.red, 'Mundo Avanzado', 'Bloqueado'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 5. LOGROS (Estáticos por ahora)
                    // 5. LOGROS (Dinámicos conectados a Firebase)
                    _buildCardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                              const SizedBox(width: 10),
                              const Text('Logros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              // Mostramos cuántos tiene desbloqueados en total
                              Text('${(userData['logros_desbloqueados'] as List?)?.length ?? 0} Desbloqueados', 
                                style: TextStyle(color: Colors.blue.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text('Sigue jugando para desbloquear', style: TextStyle(color: Colors.black54, fontSize: 13)),
                          const SizedBox(height: 20),
                          
                          // Lista dinámica de logros. Pasamos la lista del usuario al widget.
                          _buildLogroItem(
                            icon: Icons.track_changes, 
                            title: 'Primer Paso', 
                            description: 'Completaste tu primera lección',
                            idLogro: 'primer_paso', // Este debe coincidir con el ID de Firebase app_config
                            logrosDelUsuario: List<String>.from(userData['logros_desbloqueados'] ?? []),
                          ),
                          _buildLogroItem(
                            icon: Icons.local_fire_department, 
                            title: 'Racha de Fuego', 
                            description: 'Mantén una racha de 7 días',
                            idLogro: 'racha_fuego',
                            logrosDelUsuario: List<String>.from(userData['logros_desbloqueados'] ?? []),
                          ),
                          _buildLogroItem(
                            icon: Icons.directions_car, 
                            title: 'Conductor Experto', 
                            description: 'Acumula 500 XP',
                            idLogro: 'conductor_experto',
                            logrosDelUsuario: List<String>.from(userData['logros_desbloqueados'] ?? []),
                          ),
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

  //
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: child,
    );
  }

  Widget _buildTopStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 5), Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 5), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black))],
    );
  }

  Widget _buildProgressBar(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: progress.isNaN || progress.isInfinite ? 0.0 : progress, minHeight: 8, backgroundColor: Colors.grey.shade300, valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildModuleProgress(IconData icon, Color color, String title, String progress) {
    return Row(
      children: [
        Container(decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle), padding: const EdgeInsets.all(10), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(progress, style: const TextStyle(fontSize: 12, color: Colors.black54))])),
      ],
    );
  }

  Widget _buildLogroItem({
    required IconData icon, 
    required String title, 
    required String description, 
    required String idLogro, 
    required List<String> logrosDelUsuario
  }) {
    // Aquí ocurre la magia: verificamos si el usuario tiene este logro
    bool estaDesbloqueado = logrosDelUsuario.contains(idLogro);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Opacity(
        // Si no está desbloqueado, lo hacemos un poco transparente
        opacity: estaDesbloqueado ? 1.0 : 0.5, 
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                // Fondo gris si está bloqueado, doradito claro si está desbloqueado
                color: estaDesbloqueado ? Colors.amber.shade100 : Colors.grey.shade200, 
                shape: BoxShape.circle
              ), 
              padding: const EdgeInsets.all(10), 
              child: Icon(
                icon, 
                // Color gris si está bloqueado, dorado intenso si lo ganó
                color: estaDesbloqueado ? Colors.amber.shade800 : Colors.grey, 
                size: 28
              )
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15,
                      // Texto gris si está bloqueado
                      color: estaDesbloqueado ? Colors.black : Colors.black54 
                    )
                  ), 
                  Text(
                    estaDesbloqueado ? description : "Bloqueado", 
                    style: const TextStyle(fontSize: 12, color: Colors.black54)
                  )
                ]
              )
            ),
            // Ponemos un candadito chiquito si está bloqueado
            if (!estaDesbloqueado)
              const Icon(Icons.lock_outline, size: 16, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}