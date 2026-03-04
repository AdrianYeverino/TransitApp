import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'features/learning/data/services/seeder.dart';

// Importa tus pantallas
import 'features/auth/presentation/login_screen.dart';
import 'features/learning/presentation/pages/home_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. LLAMADA A TU FUNCIÓN DE CARGA
  // Ponemos un print para verlo en consola
  //print("--- Iniciando carga masiva ---");
  //await Seeder.importarContenidoDinamico();
  //print("--- Carga finalizada ---");

  // 3. REPARACIÓN DE USUARIOS (Lo nuevo)
  // Creamos la instancia y llamamos a la migración
  final AuthService authService = AuthService(); 
  await authService.actualizarUsuariosAntiguos();

  runApp(const TransitApp());
}

class TransitApp extends StatelessWidget {
  const TransitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransitApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      // EL PORTERO (Auth Wrapper)
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const HomePage(); // ¡Sesión iniciada!
          }
          return const LoginScreen(); // ¡A loguearse!
        },
      ),
    );
  }
}