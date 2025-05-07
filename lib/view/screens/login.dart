import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _processing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.4;
    double buttonHeight = screenHeight * 0.05;

    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.supervised_user_circle,
              size: screenHeight * 0.1,
              color: Colors.blue,
            ),
            Text(
              'Inicio de Sesión',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: screenHeight * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.03),
              child: TextField(
                controller: _emailFieldController,
                focusNode: _focusEmail,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.02),
                  ),
                  hintText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.03),
              child: TextField(
                controller: _passwordFieldController,
                focusNode: _focusPassword,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.02),
                  ),
                  hintText: 'Contraseña',
                ),
              ),
            ),
            _errorMessage != null
                ? Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.03),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
                : Container(),
            _processing
                ? const CircularProgressIndicator()
                : Padding(
              padding: EdgeInsets.all(screenHeight * 0.01),
              child: SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () async {
                    _focusPassword.unfocus();
                    _focusEmail.unfocus();

                    setState(() {
                      _processing = true;
                      _errorMessage = null;
                    });

                    User? user = await FireAuth.signInUsingEmailAndPass(
                      email: _emailFieldController.text,
                      password: _passwordFieldController.text,
                    );

                    setState(() {
                      _processing = false;
                    });

                    if (user != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => UserAdminScreen(user: user),
                        ),
                      );
                    } else {
                      setState(() {
                        _errorMessage = 'Usuario o contraseña incorrectos';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}