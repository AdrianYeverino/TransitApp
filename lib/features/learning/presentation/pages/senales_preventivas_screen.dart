import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui'; // Necesario para el efecto de desfoque (Blur)
import 'quiz_page.dart';

class SenalesPreventivasScreen extends StatelessWidget {
  const SenalesPreventivasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      // Escuchamos el progreso del usuario en tiempo real desde Firebase
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        // Datos de progreso (si no existen, ponemos un mapa vacío)
        Map<String, dynamic> progreso = {};
        if (snapshot.hasData && snapshot.data!.exists) {
          progreso = (snapshot.data!.data() as Map<String, dynamic>)['progreso'] ?? {};
        }

        // Calculamos el porcentaje (Ejemplo: 3 lecciones + 1 examen)
        int completadas = 0;
        if (progreso['s1'] == true) completadas++;
        if (progreso['s2'] == true) completadas++;
        if (progreso['s3'] == true) completadas++;
        if (progreso['examen'] == true) completadas++;
        double porcentaje = completadas / 4;

        return Scaffold(
          backgroundColor: Colors.blueGrey.shade50,
          appBar: AppBar(
            title: const Text('Volver', style: TextStyle(fontSize: 16, color: Colors.black)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CABECERA CON PROGRESO REAL
                _buildHeader(porcentaje),

                const SizedBox(height: 30),
                const Text('Lecciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // LECCIÓN 1: Curvas (Siempre desbloqueada o checar progreso)
                _buildBotonLeccion(
                  context: context,
                  id: 's1',
                  titulo: 'Señales de Curvas',
                  desc: 'Identifica señales de curvas peligrosas',
                  xp: '50 XP',
                  desbloqueada: true, // La primera siempre libre
                  completada: progreso['s1'] ?? false,
                ),

                // LECCIÓN 2: Peligro (Se desbloquea si s1 está lista)
                _buildBotonLeccion(
                  context: context,
                  id: 's2',
                  titulo: 'Señales de Peligro',
                  desc: 'Reconoce advertencias de condiciones viales',
                  xp: '50 XP',
                  desbloqueada: progreso['s1'] ?? false, 
                  completada: progreso['s2'] ?? false,
                ),

                // LECCIÓN 3: Peatones (Se desbloquea si s2 está lista)
                _buildBotonLeccion(
                  context: context,
                  id: 's3',
                  titulo: 'Animales y Peatones',
                  desc: 'Presencia de personas y animales en vía',
                  xp: '50 XP',
                  desbloqueada: progreso['s2'] ?? false,
                  completada: progreso['s3'] ?? false,
                ),

                const SizedBox(height: 20),

                // QUIZ FINAL (Solo si las 3 anteriores están listas)
                _buildQuizFinal(
                  context: context,
                  desbloqueado: progreso['s3'] ?? false,
                  completado: progreso['examen'] ?? false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildHeader(double porcentaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.amber.shade600, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 50),
              SizedBox(width: 15),
              Text('Señales\nPreventivas', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso del Módulo', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text('${(porcentaje * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: porcentaje, 
            backgroundColor: Colors.white.withOpacity(0.3), 
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), 
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildBotonLeccion({
    required BuildContext context,
    required String id,
    required String titulo,
    required String desc,
    required String xp,
    required bool desbloqueada,
    required bool completada,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: desbloqueada 
          ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuizPage(levelId: 'basico', subLevelId: id, title: titulo, xpRecompensa: 50)))
          : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // La tarjeta base
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: completada ? Colors.green.shade200 : Colors.grey.shade200, width: 2),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: completada ? Colors.green : (desbloqueada ? Colors.blue : Colors.grey.shade300),
                      child: Icon(completada ? Icons.check : Icons.play_arrow, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Text(xp, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                  ],
                ),
              ),
              // Capa de bloqueo (Blur + Candado)
              if (!desbloqueada)
                Positioned.fill(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Icon(Icons.lock, color: Colors.black54, size: 30),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizFinal({required BuildContext context, required bool desbloqueado, required bool completado}) {
    // Similar a la lección pero con estilo de tarjeta de premio
    return Opacity(
      opacity: desbloqueado ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amber, width: 2)
        ),
        child: Column(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
            const Text('Examen de Módulo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: desbloqueado 
                ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizPage(levelId: 'basico', subLevelId: 'examen', title: 'Examen Final', xpRecompensa: 200)))
                : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
              child: Text(completado ? 'Repetir Examen' : 'Comenzar ahora', style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}