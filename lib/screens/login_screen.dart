import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_navegation_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState(); // <- Cambio aquí
}

class LoginScreenState extends State<LoginScreen> { // <- Cambio aquí
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _processing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height * 0.15),
              const Icon(Icons.lock_outline, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Login to continue',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _emailController,
                focusNode: _focusEmail,
                hintText: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                focusNode: _focusPassword,
                hintText: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 30),
              _processing
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Provider.of<AppNavegationProvider>(context, listen: false)
                      .changeRoute('/registerUser');
                },
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  Future<void> _handleLogin() async {
    _focusEmail.unfocus();
    _focusPassword.unfocus();

    setState(() {
      _processing = true;
      _errorMessage = null;
    });

    // Aquí puedes agregar tu lógica real de autenticación

    setState(() {
      _processing = false;
    });

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }
}
