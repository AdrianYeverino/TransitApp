import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'level_screen.dart';
import 'dart:ui';

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
              // Cabecera con datos reales del Firebase
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

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
                          // Botón avatar
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/perfil'),
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.brown,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombreUsuario,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Nivel $nivelActual',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Menú desplegable
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.menu,
                                size: 20,
                                color: Colors.black87,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white,
                              elevation: 4,
                              offset: const Offset(0, 40),
                              onSelected: (String opcion) {
                                if (opcion == 'perfil') {
                                  Navigator.pushNamed(context, '/perfil');
                                } else if (opcion == 'logout')
                                  _signOut();
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'perfil',
                                  child: Text(
                                    'Ver Perfil',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Cerrar Sesión',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Tarjetas principales
                      _buildStatCard(
                        'XP Total',
                        '$xp',
                        Icons.star_border,
                        Colors.amber,
                      ),
                      _buildStatCard(
                        'Racha de Días',
                        '$racha días',
                        Icons.local_fire_department_outlined,
                        Colors.deepOrange,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),
              const Text(
                'Mundos de Aprendizaje',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Mapa de niveles con los candados esos
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  var userData = snapshot.data!.data() as Map<String, dynamic>?;
                  List<dynamic> desbloqueados =
                      userData?['subniveles_desbloqueados'] ?? [];

                  bool intermedioLibre = desbloqueados.contains(
                    'intermedio_s1',
                  );
                  bool avanzadoLibre = desbloqueados.contains('avanzado_s1');

                  return Column(
                    children: [
                      // Nivel básico (Siempre abierto)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LevelScreen(
                                levelId: 'basico',
                                tituloNivel: 'Nivel Básico',
                                colorNivel: Colors.blue,
                                iconoNivel: Icons.shield,
                              ),
                            ),
                          );
                        },
                        child: _buildNivelCard(
                          color: Colors.blue.shade600,
                          icono: Icons.shield,
                          titulo: 'Nivel Básico',
                          descripcion:
                              'Fundamentos de vialidad y seguridad para todos.',
                          progresoText: 'Toque para entrar',
                          bloqueado: false,
                        ),
                      ),

                      // Nivel intermedio
                      GestureDetector(
                        onTap: intermedioLibre
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LevelScreen(
                                      levelId: 'intermedio',
                                      tituloNivel: 'Nivel Intermedio',
                                      colorNivel: Colors.orange,
                                      iconoNivel: Icons.traffic,
                                    ),
                                  ),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Debes completar el Nivel Básico y su examen final primero.',
                                    ),
                                  ),
                                );
                              },
                        child: _buildNivelCard(
                          color: Colors.orange.shade600,
                          icono: Icons.traffic,
                          titulo: 'Nivel Intermedio',
                          descripcion:
                              'Señalización restrictiva, reglas de tránsito y multas.',
                          progresoText: intermedioLibre
                              ? 'Toque para entrar'
                              : 'Bloqueado',
                          bloqueado: !intermedioLibre,
                        ),
                      ),

                      // Nivel avanzado
                      GestureDetector(
                        onTap: avanzadoLibre
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LevelScreen(
                                      levelId: 'avanzado',
                                      tituloNivel: 'Nivel Avanzado',
                                      colorNivel: Colors.redAccent,
                                      iconoNivel: Icons.local_hospital,
                                    ),
                                  ),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Debes completar el Nivel Intermedio primero.',
                                    ),
                                  ),
                                );
                              },
                        child: _buildNivelCard(
                          color: Colors.redAccent.shade400,
                          icono: Icons.local_hospital,
                          titulo: 'Nivel Avanzado',
                          descripcion:
                              'Protocolos de emergencia, siniestros y primeros auxilios.',
                          progresoText: avanzadoLibre
                              ? 'Toque para entrar'
                              : 'Bloqueado',
                          bloqueado: !avanzadoLibre,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),
              _buildMotivationCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets extras

  Widget _buildStatCard(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
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
                Text(
                  titulo,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
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
      // Le damos una forma redondeada explícita y forzamos a que el contenido no se sala
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icono, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descripcion,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  progresoText,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          // El efecto borroso y el candado ese
          if (bloqueado)
            Positioned.fill(
              // Esto hace que abarque TODA la tarjeta
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
                ), // Intensidad del desfoque
                child: Container(
                  color: Colors.black.withOpacity(
                    0.3,
                  ), // Oscurecemos un poquito el cristal
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white, size: 50),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: const Text(
        '¡Sigue practicando para desbloquear nuevos mundos!',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
