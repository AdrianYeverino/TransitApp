import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:transitapp/features/learning/presentation/pages/perfil_screen.dart';
// Eliminamos la importación del level_screen aquí porque ya no se usa como ruta fija
//import 'features/learning/data/services/seeder.dart';

// Importa tus pantallas
import 'features/auth/presentation/login_screen.dart';
import 'features/learning/presentation/pages/home_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. CARGA MASIVA DE DATOS
  // ¡ATENCIÓN! Córrelo así una vez para que Firebase reciba los nombres reales.
  // Después de correrlo, ponle // a estas 3 líneas para apagarlas.
  //print("--- Iniciando carga masiva ---");
  //await Seeder.importarContenidoDinamico();
  //print("--- Carga finalizada ---");

  // 2. REPARACIÓN DE USUARIOS
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
      
      // --- AQUÍ REGISTRAMOS TUS RUTAS NUEVAS ---
      routes: {
        '/perfil': (context) => const PerfilScreen(),
        // Se eliminó la ruta '/moduloSenales' porque el HomePage ahora manda
        // directamente a LevelScreen con los datos correctos de cada mundo.
      },

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