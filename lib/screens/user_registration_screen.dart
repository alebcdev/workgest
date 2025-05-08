import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum RadioOpciones { Administrador, Estandard }

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _nameFieldController = TextEditingController();
  final _apellidoFieldController = TextEditingController();
  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  late RadioOpciones _opcionRol = RadioOpciones.Estandard;

  final _focusName = FocusNode();
  final _focusApellido = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _processing = false;
  String _statusMessage = "";

  @override
  void dispose() {
    _nameFieldController.dispose();
    _apellidoFieldController.dispose();
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    _focusName.dispose();
    _focusApellido.dispose();
    _focusEmail.dispose();
    _focusPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double paddingVertical = MediaQuery.of(context).size.width * 0.04;
    double padding = MediaQuery.of(context).size.width * 0.05;
    double fontSize = MediaQuery.of(context).size.width * 0.04;

    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusApellido.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Registrar nuevo usuario", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: EdgeInsets.all(padding),
          child: ListView(
            children: [
              TextField(
                controller: _nameFieldController,
                focusNode: _focusName,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              SizedBox(height: paddingVertical),
              TextField(
                controller: _apellidoFieldController,
                focusNode: _focusApellido,
                decoration: const InputDecoration(labelText: "Apellido"),
              ),
              SizedBox(height: paddingVertical),
              TextField(
                controller: _emailFieldController,
                focusNode: _focusEmail,
                decoration: const InputDecoration(labelText: "Correo electrónico"),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: paddingVertical),
              TextField(
                controller: _passwordFieldController,
                focusNode: _focusPassword,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
              ),
              SizedBox(height: paddingVertical),
              const Text("Rol del usuario:"),
              ListTile(
                title: const Text("Administrador"),
                leading: Radio<RadioOpciones>(
                  value: RadioOpciones.Administrador,
                  groupValue: _opcionRol,
                  onChanged: (RadioOpciones? value) {
                    setState(() {
                      _opcionRol = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("Estándar"),
                leading: Radio<RadioOpciones>(
                  value: RadioOpciones.Estandard,
                  groupValue: _opcionRol,
                  onChanged: (RadioOpciones? value) {
                    setState(() {
                      _opcionRol = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: paddingVertical),
              _processing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _registerUser,
                child: const Text("Registrar"),
              ),
              SizedBox(height: paddingVertical),
              Text(_statusMessage, style: TextStyle(color: Colors.red, fontSize: fontSize)),
            ],
          ),
        ),
      ),
    );
  }

  void _registerUser() async {
    setState(() {
      _processing = true;
      _statusMessage = "";
    });

    final String nombre = _nameFieldController.text.trim();
    final String apellido = _apellidoFieldController.text.trim();
    final String email = _emailFieldController.text.trim();
    final String password = _passwordFieldController.text.trim();
    final String rol = _opcionRol == RadioOpciones.Administrador ? "Administrador" : "Estandard";

    if (nombre.isEmpty || apellido.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _statusMessage = "Todos los campos son obligatorios.";
        _processing = false;
      });
      return;
    }

    try {
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'correo': email,
        'rol': rol,
        'uid': uid,
      });

      setState(() {
        _statusMessage = "Usuario registrado exitosamente.";
        _processing = false;
      });

      Navigator.pop(context); // Volver a la pantalla anterior
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.message}";
        _processing = false;
      });
    }
  }
}
