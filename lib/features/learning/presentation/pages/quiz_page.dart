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
  final bool isFinalExam; // <-- NUEVO: Bandera para saber si es examen
  final String nextSubLevelId; // <-- Clave para abrir el siguiente candado

  const QuizPage({
    super.key, 
    required this.levelId, 
    required this.subLevelId,
    required this.title,
    required this.xpRecompensa,
    this.isFinalExam = false, // Por defecto es falso
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
  
  // Variable para medir el tiempo
  late DateTime _startTime; 

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now(); // Iniciamos el cronómetro al entrar
    _loadQuestions();
  }

Future<void> _loadQuestions() async {
    List<QuestionModel> questions;
    
    if (widget.isFinalExam) {
      // Si es examen, llamamos a la nueva función aleatoria
      questions = await _service.getExamenFinal(widget.levelId, preguntasPorSubnivel: 2);
    } else {
      // Si es lección normal, carga la de siempre
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

// En la parte final de tu archivo:
  Future<void> _showFinishDialog() async {
    int segundos = DateTime.now().difference(_startTime).inSeconds;

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)));

    await _service.actualizarProgresoAlGanar(
      xpGanada: widget.xpRecompensa,
      idMundo: widget.levelId,
      idSubnivel: widget.subLevelId,
      idSiguienteSubnivel: widget.nextSubLevelId, // Usamos la variable directa
      tiempoSegundos: segundos,
    );

    if (mounted) Navigator.pop(context);

    if (mounted) {
      showDialog(
        context: context, barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("¡Excelente, Yeve! 🏆"),
          content: Text("Completaste la lección en $segundos segundos.\n¡Progreso guardado con éxito!"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context); 
              }, 
              child: const Text("VOLVER"),
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