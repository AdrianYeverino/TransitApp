import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/learning_service.dart';
import '../../data/models/sublevel_model.dart';
import 'quiz_page.dart';
// IMPORTANTE: Asegúrate de que esta ruta sea correcta según tu proyecto
import '../widgets/map/level_button_widget.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LearningService _learningService = LearningService();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  String _normalizeId(String text) {
    return text.toLowerCase()
        .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i')
        .replaceAll('ó', 'o').replaceAll('ú', 'u');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.grey[400]),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              var data = snapshot.data!.data() as Map<String, dynamic>?;
              return Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                  const SizedBox(width: 4),
                  Text("${data?['racha'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50], borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("${data?['xp'] ?? 0} XP", style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          String nivelIdFirestore = _normalizeId(userData?['nivel_actual'] ?? 'basico');
          
          // --- LÓGICA DE DESBLOQUEO ---
          List<String> unlockedList = List<String>.from(userData?['subniveles_desbloqueados'] ?? []);

          return FutureBuilder<List<SubLevelModel>>(
            future: _learningService.getSubLevels(nivelIdFirestore),
            builder: (context, contentSnapshot) {
              if (contentSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              
              List<SubLevelModel> subniveles = contentSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: subniveles.length,
                itemBuilder: (context, index) {
                  SubLevelModel leccion = subniveles[index];

                  // Construimos el ID único: "basico_s1"
                  String compositeId = "${nivelIdFirestore}_${leccion.id}";
                  bool isUnlocked = unlockedList.contains(compositeId);
                  
                  // El actual es el que está desbloqueado pero no tiene un "siguiente" desbloqueado todavía
                  bool isCurrent = isUnlocked && !unlockedList.contains("${nivelIdFirestore}_s${index + 2}");

                  return LevelButtonWidget(
                    leccion: leccion,
                    isUnlocked: isUnlocked,
                    isCurrent: isCurrent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPage(
                            levelId: nivelIdFirestore,
                            subLevelId: leccion.id,
                            title: leccion.titulo,
                            xpRecompensa: leccion.xpRecompensa, // <--- XP Dinámica
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Salir'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        ],
        onTap: (index) => index == 0 ? _signOut() : null,
      ),
    );
  }
}