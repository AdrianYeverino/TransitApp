import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importamos el modelo que creamos anteriormente
import '../features/auth/data/models/user_model.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // FUNCIÓN PARA REGISTRARSE Y CREAR PERFIL
  Future<String?> signUp(String email, String password, String nombre) async {
    try {
      // 1. Crea el usuario en Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // 2. Si se creó bien, guardamos sus datos extra en Firestore usando el Modelo
      if (result.user != null) {
        // Creamos una instancia del modelo con los valores iniciales "limpios"
        UserModel nuevoUsuario = UserModel(
          uid: result.user!.uid,
          nombre: nombre,
          email: email,
          nivelActual: 'Básico', // Antes era 'nivel': 1
          subnivelActual: 1,      // Campo nuevo para tu lógica de juegos
          xp: 0,                 // Antes era 'puntos_xp'
          racha: 0,              // Campo nuevo para la gamificación
          fechaRegistro: DateTime.now(),
        );

        // Enviamos a Firestore usando el método toMap() del modelo
        await _db.collection('users').doc(nuevoUsuario.uid).set(nuevoUsuario.toMap());
      }
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error inesperado: $e";
    }
  }

  // FUNCIÓN PARA INICIAR SESIÓN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}