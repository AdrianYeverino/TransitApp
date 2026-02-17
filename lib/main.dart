import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importante
import 'firebase_options.dart'; // El archivo que acabas de generar
import 'features/auth/presentation/login_screen.dart'; // Tu pantalla

void main() async {
  // Asegura que los widgets c  arguen antes que Firebase
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Inicializa Firebase con tus opciones generadas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TransitApp());
}

class TransitApp extends StatelessWidget {
  const TransitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransitApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}