// Archivo: seeder.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Seeder {
  static Future<void> importarContenidoDinamico() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      final String response = await rootBundle.loadString('assets/data/data_seed.json');
      final List<dynamic> data = json.decode(response);

      for (var levelData in data) {
        String levelId = levelData['id'];
        
        await db.collection('content').doc(levelId).set({
          if (levelData['titulo'] != null) 'titulo': levelData['titulo'],
          if (levelData['descripcion'] != null) 'descripcion': levelData['descripcion'],
          if (levelData['color_hex'] != null) 'color_hex': levelData['color_hex'],
          if (levelData['imagen_path'] != null) 'imagen_path': levelData['imagen_path'],
          if (levelData['orden'] != null) 'orden': levelData['orden'],
        }, SetOptions(merge: true));

        List<dynamic> sublevels = levelData['sublevels'] ?? [];
        for (var subData in sublevels) {
          String subId = subData['id'];
          
          await db.collection('content').doc(levelId)
              .collection('sublevels').doc(subId).set({
            if (subData['titulo'] != null) 'titulo': subData['titulo'],
            if (subData['descripcion'] != null) 'descripcion': subData['descripcion'],
            if (subData['orden'] != null) 'orden': subData['orden'],
            if (subData['xp_recompensa'] != null) 'xp_recompensa': subData['xp_recompensa'],
          }, SetOptions(merge: true));

          List<dynamic> questions = subData['questions'] ?? [];
          for (var qData in questions) {
            String qId = qData['id'];
            
            await db.collection('content').doc(levelId)
                .collection('sublevels').doc(subId)
                .collection('questions').doc(qId).set({
              'enunciado': qData['enunciado'],
              'tipo': qData['tipo'],
              'feedback': qData['feedback'],
              'respuesta_correcta': qData['respuesta_correcta'], 
              if (qData['opciones'] != null) 'opciones': qData['opciones'],
              if (qData['imagen_url'] != null) 'imagen_url': qData['imagen_url'],
            }, SetOptions(merge: true));
          }
        }
      }
      print("✅ Seeder: Plantillas inyectadas correctamente en Firebase.");
    } catch (e) {
      print("❌ Error en Seeder: $e");
    }
  }
}