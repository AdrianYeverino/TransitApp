import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para capturar los datos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Paleta de colores de alto contraste
  final Color deepBlue = const Color(0xFF0D47A1);
  final Color accentBlue = const Color(0xFF1976D2);
  final Color lightBlue = const Color(0xFFE3F2FD);

  void _handleRegister() async {
    // Validación básica de ingeniería: campos no vacíos
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      _showSnackBar("Por favor, llena todos los campos", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    // Llamada al servicio que creamos (Auth + Firestore)
    String? result = await _authService.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result == "Success") {
      _showSnackBar("¡Cuenta creada con éxito!", Colors.green);
      // Regresa al Login o mándalo al Home
      Navigator.pop(context); 
    } else {
      _showSnackBar("Error: $result", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: deepBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado similar al Login para consistencia visual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                color: deepBlue,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.person_add_alt_1_rounded, size: 70, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Crea tu Perfil",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  // Campo de Nombre (Nuevo para Firestore)
                  _buildTextField(
                    controller: _nameController,
                    label: "Nombre Completo",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // Campo de Correo
                  _buildTextField(
                    controller: _emailController,
                    label: "Correo Electrónico",
                    icon: Icons.email_outlined,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Campo de Contraseña
                  _buildTextField(
                    controller: _passwordController,
                    label: "Contraseña",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),

                  // Botón de Registro
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("REGISTRARSE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // Widget reutilizable para los campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: lightBlue,
        prefixIcon: Icon(icon, color: deepBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}