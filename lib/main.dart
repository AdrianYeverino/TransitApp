import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:transitapp/features/learning/presentation/pages/perfil_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/learning/presentation/pages/home_page.dart';
import 'services/auth_service.dart';
//import 'features/learning/data/services/logros_service.dart'; // Descomenta cuando uses LogrosService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ============ CARGA DE LOGROS ============
  // Descomenta la siguiente línea para cargar/actualizar los logros desde assets/logros.json a Firestore
  // Solo necesitas hacerlo UNA VEZ cada vez que actualices el archivo logros.json
  //await LogrosService.uploadLogros();
  // ==========================================

  // Carga de datos de mi poderosisimo seeder
  //print("Cargando...");
  //await Seeder.importarContenidoDinamico();
  //print("Seeder cargado, espero sin problemas");

  // Proteger y verificar usuarios viejos
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

      routes: {'/perfil': (context) => const PerfilScreen()},

      // Aquí se mueve todo
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const HomePage();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
