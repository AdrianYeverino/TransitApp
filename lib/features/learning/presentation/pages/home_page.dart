import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Este es el nuevo HomePage unificado (Tu diseño + Su backend)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CABECERA CON DATOS REALES DE FIREBASE
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  var userData = snapshot.data!.data() as Map<String, dynamic>?;
                  String nombreUsuario = userData?['nombre'] ?? 'Usuario';
                  String nivelActual = userData?['nivel_actual'] ?? 'Básico';
                  int xp = userData?['xp'] ?? 0;
                  int racha = userData?['racha'] ?? 0;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // --- BOTÓN DEL AVATAR ---
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/perfil');
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.brown,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(nombreUsuario, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Nivel $nivelActual', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // --- ESTADÍSTICAS RÁPIDAS Y MENÚ ---
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department_outlined, color: Colors.deepOrange, size: 20),
                              Text(' $racha  ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Icon(Icons.star_border, color: Colors.amber, size: 20),
                              Text(' $xp  ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              
                              // MENÚ DESPLEGABLE
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.menu, size: 20, color: Colors.black87),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: Colors.white,
                                  elevation: 4,
                                  offset: const Offset(0, 40),
                                  onSelected: (String opcion) {
                                    if (opcion == 'perfil') {
                                      Navigator.pushNamed(context, '/perfil');
                                    } else if (opcion == 'logout') {
                                      _signOut();
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<String>(
                                      value: 'perfil',
                                      child: Text('Ver Perfil', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'logout',
                                      child: Row(
                                        children: [
                                          Icon(Icons.logout, color: Colors.red, size: 18),
                                          SizedBox(width: 8),
                                          Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 30),

                      // 2. TARJETAS DE ESTADÍSTICAS DETALLADAS (Conectadas a Firebase)
                      _buildStatCard('XP Total', '$xp', Icons.star_border, Colors.amber),
                      _buildStatCard('Racha de Días', '$racha días', Icons.local_fire_department_outlined, Colors.deepOrange),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // 3. TÍTULO DE LOS NIVELES
              const Text(
                'Mundos de Aprendizaje',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 15),

              // 4. MAPA DE NIVELES (Usando tu diseño original)
              
              // Tarjeta Básico (Lleva a tu pantalla de lecciones)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/moduloSenales');
                },
                child: _buildNivelCard(
                  color: Colors.amber.shade600,
                  icono: Icons.warning_amber_rounded,
                  titulo: 'Señales Preventivas',
                  descripcion: 'Aprende a identificar y comprender las señales que te alertan sobre peligros en el camino.',
                  progresoText: 'Toque para entrar',
                  bloqueado: false,
                ),
              ),

              // Tarjeta Intermedio (Bloqueada visualmente por ahora)
              _buildNivelCard(
                color: Colors.redAccent.shade200,
                icono: Icons.traffic,
                titulo: 'Prioridades de Paso',
                descripcion: 'Domina las reglas de prioridad en intersecciones y vías.',
                progresoText: 'Bloqueado',
                bloqueado: true,
              ),

              // Tarjeta Avanzado (Bloqueada visualmente por ahora)
              _buildNivelCard(
                color: Colors.greenAccent.shade400,
                icono: Icons.assignment,
                titulo: 'Reglamento Local México',
                descripcion: 'Conoce las leyes específicas de tránsito en México y Monterrey.',
                progresoText: 'Bloqueado',
                bloqueado: true,
              ),

              const SizedBox(height: 10),

              // 5. TARJETA DE MOTIVACIÓN
              _buildMotivationCard(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNCIONES CONSTRUCTORAS DE TARJETAS (Tus funciones originales intactas) ---

  Widget _buildStatCard(String titulo, String valor, IconData icono, Color color) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Icon(icono, color: color, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelCard({
    required Color color,
    required IconData icono,
    required String titulo,
    required String descripcion,
    required String progresoText,
    bool bloqueado = false,
  }) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icono, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text(descripcion, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                Text(progresoText, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
            if (bloqueado)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white, size: 48),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.purple.shade400]),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: const Text(
        '¡Sigue practicando para desbloquear nuevos mundos!',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}