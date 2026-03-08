import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'quiz_page.dart';

class LevelScreen extends StatelessWidget {
  final String levelId;
  final String tituloNivel;
  final Color colorNivel;
  final IconData iconoNivel;

  const LevelScreen({
    super.key, required this.levelId, required this.tituloNivel, required this.colorNivel, required this.iconoNivel,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(title: Text(tituloNivel, style: const TextStyle(fontSize: 16, color: Colors.black)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('content').doc(levelId).collection('sublevels').orderBy('orden').get(),
        builder: (context, snapshotSublevels) {
          if (snapshotSublevels.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshotSublevels.hasData || snapshotSublevels.data!.docs.isEmpty) return const Center(child: Text("Próximamente..."));

          final sublevels = snapshotSublevels.data!.docs;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
            builder: (context, snapshotUser) {
              if (!snapshotUser.hasData) return const SizedBox.shrink();

              var userData = snapshotUser.data!.data() as Map<String, dynamic>? ?? {};
              
              // 1. Listas de seguridad
              List<dynamic> desbloqueados = userData['subniveles_desbloqueados'] ?? ['basico_s1']; // Siempre gratis
              List<dynamic> completados = userData['lecciones_completadas'] ?? [];

              // 2. Progreso
              int cantCompletadas = 0;
              for (var doc in sublevels) {
                if (completados.contains('${levelId}_${doc.id}')) cantCompletadas++;
              }
              double porcentaje = cantCompletadas / (sublevels.length + 1);
              
              bool examenDesbloqueado = (cantCompletadas >= sublevels.length);
              bool examenCompletado = completados.contains('${levelId}_examen');
              if (examenCompletado) porcentaje = 1.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(porcentaje),
                    const SizedBox(height: 30),
                    const Text('Lecciones del Mundo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sublevels.length,
                      itemBuilder: (context, index) {
                        var subData = sublevels[index].data() as Map<String, dynamic>;
                        String subId = sublevels[index].id;
                        String tagSubnivel = '${levelId}_$subId';
                        String nextId = (index == sublevels.length - 1) ? 'examen' : sublevels[index + 1].id;

                        // Verificación estricta (Mantiene candado de tu amigo)
                        bool isUnlocked = desbloqueados.contains(tagSubnivel);
                        if (levelId == 'basico' && subId == 's1') isUnlocked = true;

                        return _buildBotonLeccion(
                          context: context, levelId: levelId, subId: subId,
                          titulo: subData['titulo'] ?? 'Lección',
                          desc: subData['descripcion'] ?? '',
                          xp: '${subData['xp_recompensa'] ?? 50} XP',
                          desbloqueada: isUnlocked,
                          completada: completados.contains(tagSubnivel),
                          isFinalExam: false,
                          nextSubId: nextId,
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    _buildBotonLeccion(
                      context: context, levelId: levelId, subId: 'examen',
                      titulo: 'Examen Final de Módulo', desc: 'Demuestra todo lo que aprendiste.', xp: '200 XP',
                      desbloqueada: examenDesbloqueado,
                      completada: examenCompletado,
                      isFinalExam: true,
                      nextSubId: 's1', // El siguiente de un examen es el s1 del mundo que sigue
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(double porcentaje) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: colorNivel, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: colorNivel.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(iconoNivel, color: Colors.white, size: 50), const SizedBox(width: 15), Expanded(child: Text(tituloNivel, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1)))]),
          const SizedBox(height: 25),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Progreso', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)), Text('${(porcentaje * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: porcentaje, backgroundColor: Colors.white.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8),
        ],
      ),
    );
  }

  Widget _buildBotonLeccion({
    required BuildContext context, required String levelId, required String subId, required String titulo, required String desc, required String xp, required bool desbloqueada, required bool completada, required bool isFinalExam, required String nextSubId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: desbloqueada ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuizPage(levelId: levelId, subLevelId: subId, title: titulo, xpRecompensa: int.parse(xp.split(' ')[0]), isFinalExam: isFinalExam, nextSubLevelId: nextSubId))) : () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comienza con las lecciones anteriores.')));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isFinalExam ? Colors.amber.shade50 : Colors.white, border: Border.all(color: completada ? Colors.green.shade200 : Colors.grey.shade200, width: 2)),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: completada ? Colors.green : (desbloqueada ? (isFinalExam ? Colors.amber : colorNivel) : Colors.grey.shade300), child: Icon(completada ? Icons.check : (isFinalExam ? Icons.emoji_events : Icons.play_arrow), color: Colors.white)),
                    const SizedBox(width: 15),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])),
                    Text(xp, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                  ],
                ),
              ),
              if (!desbloqueada)
                Positioned.fill(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(color: Colors.black.withOpacity(0.1), child: const Icon(Icons.lock, color: Colors.black54, size: 30)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}