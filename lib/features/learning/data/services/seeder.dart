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

    print("📦 Niveles detectados en JSON: ${data.length}"); // <--- AGREGA ESTO

    for (var levelData in data) {
      String levelId = levelData['id'];
      print("🚀 Procesando nivel: $levelId"); // <--- AGREGA ESTO

      await db.collection('content').doc(levelId).set({
        if (levelData['titulo'] != null) 'titulo': levelData['titulo'],
        if (levelData['descripcion'] != null) 'descripcion': levelData['descripcion'],
        if (levelData['color_hex'] != null) 'color_hex': levelData['color_hex'],
        if (levelData['imagen_path'] != null) 'imagen_path': levelData['imagen_path'],
        if (levelData['orden'] != null) 'orden': levelData['orden'],
      }, SetOptions(merge: true));

      List<dynamic> sublevels = levelData['sublevels'] ?? [];
      print("   📂 Subniveles encontrados: ${sublevels.length}"); // <--- AGREGA ESTO

      for (var subData in sublevels) {
        String subId = subData['id'];
        // ... resto del código igual ...
      }
    }
  } catch (e) {
    print("❌ ERROR CRÍTICO: $e"); // <--- Asegúrate de ver esto
  }
}
}