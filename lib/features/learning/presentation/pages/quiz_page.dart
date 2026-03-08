import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Agregado para leer el usuario
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Agregado para leer el nombre
import '../../data/services/learning_service.dart';
import '../../data/models/question_model.dart';
import 'package:transitapp/features/learning/presentation/widgets/games/quiz_router.dart';
import 'package:transitapp/features/learning/presentation/widgets/games/components/feedback_bottom_sheet.dart'; 

class QuizPage extends StatefulWidget {
  final String levelId;
  final String subLevelId;
  final String title;
  final int xpRecompensa;
  final bool isFinalExam; // Respetamos la variable de Adrián
  final String nextSubLevelId; // Respetamos la llave de Adrián

  const QuizPage({
    super.key, 
    required this.levelId, 
    required this.subLevelId,
    required this.title,
    required this.xpRecompensa,
    this.isFinalExam = false, 
    required this.nextSubLevelId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final LearningService _service = LearningService();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  
  late DateTime _startTime; 
  int _aciertos = 0; // <-- NUESTRO CONTADOR DE ACIERTOS

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); 
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    List<QuestionModel> questions;
    
    // Respetamos la lógica de Adrián para los exámenes
    if (widget.isFinalExam) {
      questions = await _service.getExamenFinal(widget.levelId, preguntasPorSubnivel: 2);
    } else {
      questions = await _service.getQuestions(widget.levelId, widget.subLevelId);
    }

    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  void _answerQuestion(bool esCorrecta) {
    if (esCorrecta) {
      _aciertos++; // <-- SUMAMOS ACIERTOS AQUÍ
    }

    QuestionModel currentQ = _questions[_currentIndex];
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackBottomSheet(
        isCorrect: esCorrecta,
        feedback: currentQ.feedback,
        onContinue: () {
          Navigator.pop(context); 
          _advanceToNextQuestion();
        },
      ),
    );
  }

  void _advanceToNextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showFinishDialog();
    }
  }

  Future<void> _showFinishDialog() async {
    int segundos = DateTime.now().difference(_startTime).inSeconds;

    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white))
    );

    // --- OBTENEMOS EL NOMBRE REAL DE FIREBASE ---
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    String nombreUsuario = 'Piloto';
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        nombreUsuario = userDoc.data()!['nombre'] ?? 'Piloto';
      }
    } catch (e) {
      print("Error obteniendo usuario: $e");
    }

    // Usamos la lógica original de Adrián para guardar
    await _service.actualizarProgresoAlGanar(
      xpGanada: widget.xpRecompensa,
      idMundo: widget.levelId,
      idSubnivel: widget.subLevelId,
      idSiguienteSubnivel: widget.nextSubLevelId, 
      tiempoSegundos: segundos,
    );

    if (mounted) Navigator.pop(context); // Cierra el circulito de carga

    // --- NUESTRO DIÁLOGO BONITO ---
    if (mounted) {
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 70),
                const SizedBox(height: 15),
                Text(
                  "¡Excelente, $nombreUsuario!",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  "Completaste la lección",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(thickness: 1.5),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text("Aciertos", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(height: 5),
                        Text(
                          "$_aciertos / ${_questions.length}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Tiempo", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(height: 5),
                        Text(
                          "${segundos}s",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cierra diálogo
                      Navigator.pop(context); // Vuelve al mapa
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("VOLVER AL MAPA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                )
              ],
            ),
          ),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF0D47A1),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: QuizRouter(
                    key: ValueKey(_questions[_currentIndex].id), 
                    question: _questions[_currentIndex], 
                    onAnswered: _answerQuestion, 
                  ),
                ),
              ],
            ),
          ),
    );
  }
}