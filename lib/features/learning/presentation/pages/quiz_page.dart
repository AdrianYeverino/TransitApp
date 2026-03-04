import 'package:flutter/material.dart';
import '../../data/services/learning_service.dart';
import '../../data/models/question_model.dart';
import 'package:transitapp/features/learning/presentation/widgets/games/quiz_router.dart';
import 'package:transitapp/features/learning/presentation/widgets/games/components/feedback_bottom_sheet.dart'; 

class QuizPage extends StatefulWidget {
  final String levelId;
  final String subLevelId;
  final String title;
  final int xpRecompensa;

  const QuizPage({
    super.key, 
    required this.levelId, 
    required this.subLevelId,
    required this.title,
    required this.xpRecompensa,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final LearningService _service = LearningService();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  
  // Variable para medir el tiempo
  late DateTime _startTime; 

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // Iniciamos el cronómetro al entrar
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    var questions = await _service.getQuestions(widget.levelId, widget.subLevelId);
    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  void _answerQuestion(bool esCorrecta) {
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
    // 1. Calculamos tiempo final
    int segundos = DateTime.now().difference(_startTime).inSeconds;

    // 2. Pantalla de carga mientras procesamos en la nube
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    // 3. Calculamos siguiente nivel (ej: s1 -> s2)
    String siguienteSubId = "s2"; 
    try {
      int num = int.parse(widget.subLevelId.replaceAll(RegExp(r'[^0-9]'), ''));
      siguienteSubId = 's${num + 1}';
    } catch(e) { /* Fallback a s2 */ }

    // 4. Enviamos TODO al motor de progreso
    await _service.actualizarProgresoAlGanar(
      xpGanada: widget.xpRecompensa,
      idMundo: widget.levelId,
      idSubnivel: widget.subLevelId,
      idSiguienteSubnivel: siguienteSubId,
      tiempoSegundos: segundos,
    );

    if (mounted) Navigator.pop(context); // Cerramos el cargando

    // 5. Diálogo de éxito para el usuario
    if (mounted) {
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("¡Excelente, Yeve! 🏆"),
          content: Text("Completaste el nivel en $segundos segundos.\nTu progreso y racha han sido actualizados."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cierra diálogo
                Navigator.pop(context); // Vuelve al mapa
              }, 
              child: const Text("VOLVER AL MAPA"),
            )
          ],
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