import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/learning_service.dart';
import '../../data/services/logros_service.dart';
import '../../data/models/question_model.dart';
import '../../data/models/logro_model.dart';
import 'package:transitapp/features/learning/presentation/widgets/games/quiz_router.dart';
import 'package:transitapp/features/learning/presentation/widgets/games/components/feedback_bottom_sheet.dart';
import 'package:transitapp/features/learning/presentation/widgets/logro_notification_widget.dart';

class QuizPage extends StatefulWidget {
  final String levelId;
  final String subLevelId;
  final String title;
  final int xpRecompensa;
  final bool isFinalExam;
  final String nextSubLevelId;

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
  final LearningService _service =
      LearningService(); // Conexión con la base de datos
  List<QuestionModel> _questions = [];
  bool _isLoading = true; // Para mostrar la ruedita de carga al inicio
  int _currentIndex = 0; // Empezamos en el número de pregunta 0
  bool _isFinalizando =
      false; // Flag para evitar múltiples clicks en última pregunta

  late DateTime _startTime; // Definimos un cronómetro
  int _aciertos = 0; // Contador de aciertos

  @override
  void initState() {
    super.initState();
    _startTime =
        DateTime.now(); // Empezamos el cronómetro en cuanto se abre la pantalla
    _loadQuestions(); // Mandamos a llamar las preguntas de Firebase
  }

  Future<void> _loadQuestions() async {
    List<QuestionModel> questions;

    // ¿Es un examen final o una lección normal?
    if (widget.isFinalExam) {
      questions = await _service.getExamenFinal(
        widget.levelId,
        preguntasPorSubnivel: 2,
      );
    } else {
      questions = await _service.getQuestions(
        widget.levelId,
        widget.subLevelId,
      );
    }

    // Este if (mounted) significa "Si el usuario no ha cerrado esta pantalla mientras descargábamos, actualiza la UI".
    if (mounted) {
      setState(() {
        _questions = questions; // Llenamos la lista
        _isLoading = false; // Quitamos la ruedita de carga
      });
    }
  }

  // Ciclo del juego
  void _answerQuestion(bool esCorrecta) {
    if (esCorrecta) {
      _aciertos++; // Se suman los aciertos aquí
    }

    // Mostramos la tarjetita emergente de abajo (BottomSheet) para decirle si acertó o falló
    QuestionModel currentQ = _questions[_currentIndex];
    showModalBottomSheet(
      context: context,
      isDismissible:
          false, // No dejamos que la cierre tocando afuera de la tarjetita
      enableDrag: false, // Ni arrastarla
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackBottomSheet(
        isCorrect: esCorrecta,
        feedback: currentQ.feedback,
        onContinue: () {
          Navigator.pop(context); // Ocultamos la tarjetita
          _advanceToNextQuestion(); // Avanzamos a la siguiente pregunta
        },
      ),
    );
  }

  void _advanceToNextQuestion() {
    // Si todavía nos quedan preguntas en la lista, simplemente avanzamos el índice
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // Si ya no hay preguntas, se acabó el juego
      // Proteger contra múltiples calls
      if (!_isFinalizando) {
        _isFinalizando = true;
        _showFinishDialog();
      }
    }
  }

  // Resultados finales con verificación de logros
  Future<void> _showFinishDialog() async {
    // Detenemos el cronómetro y calculamos los segundos totales
    int segundos = DateTime.now().difference(_startTime).inSeconds;

    // Mostramos una ruedita de carga bloqueando la pantalla mientras guardamos en Firebase
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Doxxeamos al usuario sacamos su nombre para esta tarjeta
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    String nombreUsuario = 'Piloto';
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        nombreUsuario = userDoc.data()!['nombre'] ?? 'Piloto';
      }
    } catch (e) {
      print("Error obteniendo usuario: $e");
    }

    // La motor cosa para actualizar el progreso (Linea 60 del learning_service.dart)
    await _service.actualizarProgresoAlGanar(
      xpGanada: widget.xpRecompensa,
      idMundo: widget.levelId,
      idSubnivel: widget.subLevelId,
      idSiguienteSubnivel: widget.nextSubLevelId,
      tiempoSegundos: segundos,
    );

    // ========== VERIFICAR LOGROS AL SALIR DEL NIVEL ==========
    List<LogroModel> logrosRecientementeDesbloqueados = [];
    try {
      await LogrosService.sincronizarAlmacenamientoLogros(uid);
      final idsAntes = (await LogrosService.obtenerLogrosDesbloqueados(uid))
          .map((l) => l.id)
          .toSet();
      await LogrosService.verificarYDesbloquearPorMetricas(uid, const [
        'lecciones_jugadas',
        'progreso_niveles',
        'xp',
        'racha_maxima',
        'mejor_tiempo',
      ]);
      final despues = await LogrosService.obtenerLogrosDesbloqueados(uid);
      logrosRecientementeDesbloqueados =
          despues.where((l) => !idsAntes.contains(l.id)).toList();
      print("✅ Logros desbloqueados: ${logrosRecientementeDesbloqueados.length}");
    } catch (e) {
      print("Error verificando logros: $e");
    }

    // Cerrar el diálogo de carga esperando a que se procese
    if (mounted) {
      Navigator.pop(context);
      // Pequeño delay para asegurar que el Navigator.pop() se procese completamente
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Mostrar notificaciones de logros desbloqueados
    if (logrosRecientementeDesbloqueados.isNotEmpty && mounted) {
      for (final logro in logrosRecientementeDesbloqueados) {
        await _mostrarNotificacionLogro(logro);
      }
    }

    // Aquí es FRONTEND para mostrar las estrellitas, el nombre, los aciertos y el botón de volver.
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          // Todo el diseño visual de la tarjeta blanca con el resultado
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
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
                        Text(
                          "Aciertos",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "$_aciertos / ${_questions.length}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Tiempo",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${segundos}s",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "VOLVER AL MAPA",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
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
  }

  Future<void> _mostrarNotificacionLogro(LogroModel logro) {
    return showLogroUnlockNotification(context, logro);
  }

  // Lo que ve nuestro usuario
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
                  // Barra de progreso
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF0D47A1),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    // Enrutador de preguntas
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
