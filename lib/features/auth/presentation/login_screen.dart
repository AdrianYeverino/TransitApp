import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import "package:transitapp/features/auth/presentation/register_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controladores para obtener el texto de los campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 2. Instancia del servicio de autenticación
  final AuthService _authService = AuthService();

  // 3. Variable para mostrar un cargando
  bool _isLoading = false;

  // Colores de alto contraste solicitados
  final Color deepBlue = const Color(0xFF0D47A1); // Azul fuerte
  final Color accentBlue = const Color(0xFF1976D2); // Azul medio
  final Color lightBlue = const Color(0xFFE3F2FD); // Fondo suave para campos

  void _handleLogin() async {
    // Validar que no estén vacíos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, llena todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Llamar al servicio de Firebase
    String? result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result == "Success") {
      // Aquí navegarías a la pantalla principal de TransitApp
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Ingreso exitoso! Bienvenido."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Feedback inmediato en caso de error (Contraseña incorrecta, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $result"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado con diseño curvo y azul fuerte
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              decoration: BoxDecoration(
                color: deepBlue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [deepBlue, accentBlue],
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.traffic_rounded, size: 90, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "TransitApp",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: deepBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Tu camino hacia una mejor cultura vial."),
                  const SizedBox(height: 40),

                  // Campo de Correo
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Correo Electrónico",
                      filled: true,
                      fillColor: lightBlue,
                      prefixIcon: Icon(Icons.email_outlined, color: deepBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo de Contraseña
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      filled: true,
                      fillColor: lightBlue,
                      prefixIcon: Icon(Icons.lock_outline, color: deepBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botón de Ingresar
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepBlue,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "INGRESAR",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Opción de Registro (Placeholder)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Aquí conectarías con la pantalla de Registro
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        "¿No tienes cuenta? Regístrate aquí",
                        style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}