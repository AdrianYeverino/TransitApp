import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Asegúrate de que la ruta del modelo sea la correcta en tu proyecto
import '../features/auth/data/models/user_model.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ----------------------------------------------------------------
  // 1. REGISTRO Y CREACIÓN DE PERFIL MAESTRO
  // ----------------------------------------------------------------
  Future<String?> signUp(String email, String password, String nombre) async {
    try {
      // Crea el usuario en Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      if (result.user != null) {
        // Creamos el modelo con TODOS los campos necesarios para la app
        UserModel nuevoUsuario = UserModel(
          uid: result.user!.uid,
          nombre: nombre,
          email: email,
          nivelActual: 'Básico',
          subnivelActual: 1,
          xp: 0,
          racha: 0,
          rachaMaxima: 0,
          leccionesJugadas: 0,
          mejorTiempo: 0,
          logrosDesbloqueados: [],
          // IMPORTANTE: Desbloqueamos s1 para que no empiecen bloqueados
          subnivelesDesbloqueados: ["basico_s1"], 
          progresoNiveles: {
            'basico': 0,
            'intermedio': 0,
            'avanzado': 0,
          },
          fechaRegistro: DateTime.now(),
        );

        // Guardamos en Firestore
        await _db.collection('users').doc(nuevoUsuario.uid).set(nuevoUsuario.toMap());
      }
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error inesperado: $e";
    }
  }

  // ----------------------------------------------------------------
  // 2. INICIO DE SESIÓN
  // ----------------------------------------------------------------
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ----------------------------------------------------------------
  // 3. SCRIPT DE REPARACIÓN (Para usuarios)
  // ----------------------------------------------------------------
  // Ejecuta esta función una vez para nivelar a los usuarios antiguos
  Future<void> actualizarUsuariosAntiguos() async {
    try {
      final snapshot = await _db.collection('users').get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Usamos merge: true para añadir campos faltantes sin borrar los existentes
        await _db.collection('users').doc(doc.id).set({
          'racha_maxima': data['racha_maxima'] ?? 0,
          'lecciones_jugadas': data['lecciones_jugadas'] ?? 0,
          'mejor_tiempo': data['mejor_tiempo'] ?? 0,
          'logros_desbloqueados': data['logros_desbloqueados'] ?? [],
          'subniveles_desbloqueados': data['subniveles_desbloqueados'] ?? ["basico_s1"],
          'progreso_niveles': data['progreso_niveles'] ?? {
            'basico': 0, 'intermedio': 0, 'avanzado': 0
          },
        }, SetOptions(merge: true));
      }
      print("✅ Todos los perfiles han sido actualizados al esquema maestro.");
    } catch (e) {
      print("❌ Error en la migración de usuarios: $e");
    }
  }
}