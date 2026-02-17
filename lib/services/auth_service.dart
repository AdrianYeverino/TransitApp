import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      
      // 2. Si se creó bien, guardamos sus datos extra en Firestore
      if (result.user != null) {
        await _db.collection('users').doc(result.user!.uid).set({
          'nombre': nombre,
          'email': email,
          'puntos_xp': 0,        // Empieza en 0
          'nivel': 1,            // Empieza en nivel 1
          'rol': 'conductor',
          'fecha_registro': DateTime.now(),
        });
      }
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
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