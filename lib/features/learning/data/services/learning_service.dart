import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/level_model.dart';
import '../models/sublevel_model.dart';
import '../models/question_model.dart'; 
import '../models/logro_model.dart';

class LearningService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- OBTENER NIVELES ---
  Stream<List<LevelModel>> getLevels() {
    return _db.collection('content')
        .orderBy('orden')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LevelModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // --- OBTENER SUBNIVELES ---
  Future<List<SubLevelModel>> getSubLevels(String levelId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('content')
          .doc(levelId)
          .collection('sublevels')
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

  // --- OBTENER PREGUNTAS ---
  Future<List<QuestionModel>> getQuestions(String levelId, String subLevelId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('content')
          .doc(levelId)
          .collection('sublevels')
          .doc(subLevelId)
          .collection('questions')
          .get();

      return snapshot.docs
          .map((doc) => QuestionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error trayendo preguntas: $e");
      return [];
    }
  }

  // --- MOTOR DE PROGRESO, XP Y RACHA ---
  Future<void> actualizarProgresoAlGanar({
    required int xpGanada,
    required String idMundo, 
    required String idSubnivel, 
    required String idSiguienteSubnivel,
    required int tiempoSegundos, 
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userRef = _db.collection('users').doc(user.uid);
      final doc = await userRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      List<String> completadas = List<String>.from(data['lecciones_completadas'] ?? []);
      
      // 0. LÓGICA DE SALTO DE MUNDOS Y CANDADOS
      String idActual = "${idMundo}_$idSubnivel";
      String idSiguiente = "${idMundo}_$idSiguienteSubnivel";
      String? nuevoNivelActual;

      if (idSubnivel == 'examen') {
        if (idMundo == 'basico') {
          idSiguiente = 'intermedio_s1'; 
          nuevoNivelActual = 'Intermedio';
        } else if (idMundo == 'intermedio') {
          idSiguiente = 'avanzado_s1'; 
          nuevoNivelActual = 'Avanzado';
        }
      }

      // 1. Lógica de XP
      int xpFinal = xpGanada;
      bool esRepeticion = completadas.contains(idActual);

      if (esRepeticion) {
        xpFinal = (xpGanada * 0.10).toInt(); 
      }

      // 2. Lógica de Racha
      int rachaActual = data['racha'] ?? 0;
      int rachaMax = data['racha_maxima'] ?? 0;
      DateTime hoy = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime? ultima = data['ultima_partida'] != null ? (data['ultima_partida'] as Timestamp).toDate() : null;

      if (ultima != null) {
        DateTime ultimaFecha = DateTime(ultima.year, ultima.month, ultima.day);
        int diferencia = hoy.difference(ultimaFecha).inDays;

        if (diferencia == 1) rachaActual++; 
        else if (diferencia > 1) rachaActual = 1; 
      } else {
        rachaActual = 1; 
      }
      if (rachaActual > rachaMax) rachaMax = rachaActual;

      // 3. Lógica de Mejor Tiempo
      int mejorTiempoAnterior = data['mejor_tiempo'] ?? 9999;
      int nuevoMejorTiempo = (tiempoSegundos < mejorTiempoAnterior) ? tiempoSegundos : mejorTiempoAnterior;

      // 4. Guardado en Firebase 
      Map<String, dynamic> updates = {
        'xp': FieldValue.increment(xpFinal),
        'lecciones_jugadas': FieldValue.increment(1),
        'racha': rachaActual,
        'racha_maxima': rachaMax,
        'mejor_tiempo': nuevoMejorTiempo,
        'ultima_partida': FieldValue.serverTimestamp(),
        'lecciones_completadas': FieldValue.arrayUnion([idActual]),
        'subniveles_desbloqueados': FieldValue.arrayUnion([idActual, idSiguiente]),
      };

      if (nuevoNivelActual != null) {
        updates['nivel_actual'] = nuevoNivelActual;
      }
      
      // 🛠️ AQUÍ ESTÁ LA SOLUCIÓN DE LA BASE DE DATOS: 
      // Lo mandamos como un Mapa real de Dart para que Firebase respete la estructura.
      if (!esRepeticion && idSubnivel != 'examen') {
        updates['progreso_niveles'] = {
          idMundo: FieldValue.increment(1)
        };
      }

      await userRef.set(updates, SetOptions(merge: true));

      // 5. Verificar Logros
      final snapshotActualizado = await userRef.get();
      await verificarLogros(snapshotActualizado.data()!, user.uid);

    } catch (e) {
      print("❌ Error en motor de progreso: $e");
    }
  }
  
  // --- MOTOR DE LOGROS GLOBALES ---
  Future<void> verificarLogros(Map<String, dynamic> userData, String userId) async {
    try {
      final configDoc = await _db.collection('app_config').doc('logros_globales').get();
      if (!configDoc.exists) return;

      List<dynamic> listaRaw = configDoc.data()?['lista_logros'] ?? [];
      List<LogroModel> reglas = listaRaw.map((l) => LogroModel.fromMap(l)).toList();

      List<String> yaObtenidos = List<String>.from(userData['logros_desbloqueados'] ?? []);
      List<String> nuevosLogros = [];

      for (var logro in reglas) {
        if (!yaObtenidos.contains(logro.id)) {
          dynamic valorActual = userData[logro.metricaUsuario];

          if (valorActual != null) {
            bool seCumple = false;
            if (logro.operacion == "mayor_que") seCumple = valorActual >= logro.valorMeta;
            else if (logro.operacion == "menor_que") seCumple = valorActual > 0 && valorActual <= logro.valorMeta;

            if (seCumple) nuevosLogros.add(logro.id);
          }
        }
      }

      if (nuevosLogros.isNotEmpty) {
        await _db.collection('users').doc(userId).update({
          'logros_desbloqueados': FieldValue.arrayUnion(nuevosLogros),
        });
      }
    } catch (e) {
      print("❌ Error en motor de logros: $e");
    }
  }

  // --- EXÁMENES FINALES ---
  Future<List<QuestionModel>> getExamenFinal(String levelId, {int preguntasPorSubnivel = 2}) async {
    List<QuestionModel> examenFinal = [];
    
    try {
      var sublevelsSnap = await _db.collection('content').doc(levelId).collection('sublevels').get();

      for (var subDoc in sublevelsSnap.docs) {
        var qSnap = await subDoc.reference.collection('questions').get();
        var questions = qSnap.docs.map((doc) => QuestionModel.fromMap(doc.data(), doc.id)).toList();

        questions.shuffle();
        examenFinal.addAll(questions.take(preguntasPorSubnivel));
      }

      examenFinal.shuffle();
      return examenFinal;
    } catch (e) {
      print("Error generando examen final: $e");
      return [];
    }
  }
}