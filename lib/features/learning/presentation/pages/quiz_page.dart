import 'package:flutter/material.dart';
import '../../data/services/learning_service.dart';
import '../../data/models/question_model.dart';

class QuizPage extends StatefulWidget {
  final String levelId;
  final String subLevelId;
  final String title;

  const QuizPage({
    super.key, 
    required this.levelId, 
    required this.subLevelId,
    required this.title,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final LearningService _service = LearningService();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // Descarga las preguntas al iniciar
  Future<void> _loadQuestions() async {
    print("Buscando preguntas en: ${widget.levelId} -> ${widget.subLevelId}");
    var questions = await _service.getQuestions(widget.levelId, widget.subLevelId);
    
    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  // Lógica para avanzar o terminar
  void _answerQuestion(int indexSeleccionado) {
    QuestionModel currentQ = _questions[_currentIndex];
    bool esCorrecta = indexSeleccionado == currentQ.respuestaCorrecta;

    // Feedback visual sencillo
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(esCorrecta ? "¡Correcto! 🎉" : "Incorrecto ❌. ${currentQ.feedback}"),
      backgroundColor: esCorrecta ? Colors.green : Colors.red,
      duration: const Duration(seconds: 1),
    ));

    // Esperar un segundo y avanzar
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        // FIN DEL JUEGO
        _showFinishDialog();
      }
    });
  }

  void _showFinishDialog() {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("¡Subnivel Completado!"),
        content: const Text("Aquí tus compañeros pondrán la pantalla de 'Ganaste XP'."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra diálogo
              Navigator.pop(context); // Vuelve al Home
            }, 
            child: const Text("Volver al Mapa")
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _questions.isEmpty
          ? const Center(child: Text("⚠️ No hay preguntas en este subnivel (Revisa Firebase)."))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Progreso
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),

                  // Número de pregunta
                  Text("Pregunta ${_currentIndex + 1} de ${_questions.length}"),
                  const SizedBox(height: 10),

                  // --- AQUÍ MOSTRAMOS LA PREGUNTA ---
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Si es tipo IMAGEN, la mostramos (Placeholder por ahora si es null)
                          if (_questions[_currentIndex].tipo == 'imagen') ...[
                             Container(
                               height: 150,
                               color: Colors.grey[200],
                               child: _questions[_currentIndex].imagenUrl != null 
                                ? Image.network(_questions[_currentIndex].imagenUrl!)
                                : const Center(child: Icon(Icons.image, size: 50)),
                             ),
                             const SizedBox(height: 10),
                          ],
                          
                          // Texto de la pregunta
                          Text(
                            _questions[_currentIndex].enunciado,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- OPCIONES DE RESPUESTA ---
                  ...List.generate(_questions[_currentIndex].opciones.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _answerQuestion(index),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(_questions[_currentIndex].opciones[index]),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}