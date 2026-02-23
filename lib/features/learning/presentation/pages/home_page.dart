import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/learning_service.dart';
import '../../data/models/sublevel_model.dart';
import '../../../auth/presentation/login_screen.dart'; 
import 'quiz_page.dart'; // Agrega esto arriba// Para redirigir al salir

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LearningService _learningService = LearningService();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Función para cerrar sesión
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    // El StreamBuilder del main.dart nos llevará al Login, pero por seguridad:

  }

  // Ayuda a convertir "Básico" -> "basico" para buscar en Firebase
  String _normalizeId(String text) {
    return text.toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- 1. BARRA SUPERIOR (APP BAR) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Icono de menú tenue a la izquierda
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[400]),
          onPressed: () {}, // Acción futura del menú
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              var data = snapshot.data!.data() as Map<String, dynamic>?;
              
              int xp = data?['xp'] ?? 0;
              int racha = data?['racha'] ?? 0;

              return Row(
                children: [
                  // Racha (Fuego)
                  Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                  const SizedBox(width: 4),
                  Text("$racha", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 20),
                  // XP
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withOpacity(0.3))
                    ),
                    child: Text(
                      "$xp XP", 
                      style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),

      // --- 2. CUERPO (NIVELES) ---
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) return const Center(child: Text("Error de usuario"));

          // Lógica de corrección de ID: "Básico" -> "basico"
          String nivelUsuarioRaw = userData['nivel_actual'] ?? 'basico';
          String nivelIdFirestore = _normalizeId(nivelUsuarioRaw);
          int subnivelUsuario = userData['subnivel_actual'] ?? 1;

          return FutureBuilder<List<SubLevelModel>>(
            future: _learningService.getSubLevels(nivelIdFirestore),
            builder: (context, contentSnapshot) {
              if (contentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              // DEBUGGING: Si sale vacía, mostramos por qué
              if (!contentSnapshot.hasData || contentSnapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 50, color: Colors.red),
                        const SizedBox(height: 20),
                        const Text("No se encontraron niveles.", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("Buscando en colección: content -> $nivelIdFirestore -> sublevels"),
                        const SizedBox(height: 10),
                        const Text("Asegúrate que en Firestore el documento se llame 'basico' (minúscula, sin acento)."),
                      ],
                    ),
                  ),
                );
              }

              List<SubLevelModel> subniveles = contentSnapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: subniveles.length,
                itemBuilder: (context, index) {
                  SubLevelModel leccion = subniveles[index];
                  bool isUnlocked = leccion.orden <= subnivelUsuario;
                  bool isCurrent = leccion.orden == subnivelUsuario;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: isUnlocked ? () {
                          // --- CÓDIGO NUEVO ---
                          // Navegamos a la pantalla del Quiz pasando los IDs necesarios
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizPage(
                              levelId: nivelIdFirestore, // 'basico'
                              subLevelId: leccion.id,    // 's1'
                              title: leccion.titulo,     // 'Intro...'
              ),
            ),
          );
          // --------------------
                        } : null,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isUnlocked 
                              ? (isCurrent ? const Color(0xFFFFC107) : const Color(0xFF0D47A1)) 
                              : Colors.grey[300],
                            shape: BoxShape.circle,
                            border: isCurrent ? Border.all(color: Colors.blue.shade100, width: 6) : null,
                            boxShadow: [
                               BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4)
                              )
                            ]
                          ),
                          child: Icon(
                            isUnlocked ? (isCurrent ? Icons.play_arrow : Icons.check) : Icons.lock,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        leccion.titulo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.black87 : Colors.grey
                        ),
                      ),
                      const SizedBox(height: 30), // Espacio entre niveles
                    ],
                  );
                },
              );
            },
          );
        },
      ),

      // --- 3. BARRA DE NAVEGACIÓN INFERIOR ---
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 1, // El del medio (Perfil) está seleccionado visualmente
        onTap: (index) {
          if (index == 0) {
            // Botón Izquierdo: CERRAR SESIÓN
            _signOut();
          }
          // El index 1 es Perfil (donde estamos), no hace nada
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.logout), // Izquierda: Salir
            label: 'Salir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 32), // Medio: Usuario
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(), // Derecha: Vacío (para balancear)
            label: '',
          ),
        ],
      ),
    );
  }
}