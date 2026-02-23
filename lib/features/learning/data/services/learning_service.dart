import 'package:cloud_firestore/cloud_firestore.dart';
// IMPORTANTE: Ajusta estas rutas si tus carpetas se llaman diferente
import '../models/level_model.dart';
import '../models/sublevel_model.dart';
import '../models/question_model.dart'; 

class LearningService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ----------------------------------------------------------------
  // 1. OBTENER NIVELES (Básico, Intermedio, Avanzado)
  // ----------------------------------------------------------------
  // Usamos Stream para que si cambias algo en la base de datos, 
  // la app se actualice sola en tiempo real.
  Stream<List<LevelModel>> getLevels() {
    return _db.collection('content') // Colección raíz
        .orderBy('orden')            // Ordenar por 1, 2, 3...
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LevelModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ----------------------------------------------------------------
  // 2. OBTENER SUBNIVELES (Lecciones dentro de un nivel)
  // ----------------------------------------------------------------
  // Esto lo pedimos solo cuando el usuario entra al nivel (Future),
  // para no gastar datos cargando todo de golpe.
  Future<List<SubLevelModel>> getSubLevels(String levelId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('content')
          .doc(levelId)              // Ej: doc('basico')
          .collection('sublevels')   // Subcolección
          .orderBy('orden')
          .get();

      return snapshot.docs
          .map((doc) => SubLevelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error trayendo subniveles: $e");
      return [];
    }
  }

  // ----------------------------------------------------------------
  // 3. OBTENER PREGUNTAS (Para el Quiz)
  // ----------------------------------------------------------------
  Future<List<QuestionModel>> getQuestions(String levelId, String subLevelId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('content')
          .doc(levelId)
          .collection('sublevels')
          .doc(subLevelId)
          .collection('questions') // Sub-subcolección
          .get();

      return snapshot.docs
          .map((doc) => QuestionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error trayendo preguntas: $e");
      return [];
    }
  }
}