import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/firebase_auth.dart';
import 'package:workgest/viewmodel/user_viewmodel.dart';

class UserRegistration extends StatefulWidget {
  @override
  _UserRegistrationState createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
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
    _focusName.dispose();
    _focusApellido.dispose();
    _focusEmail.dispose();
    _focusPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
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
          title: const Text(
            'Registra un Nuevo Usuario',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: _nameFieldController,
                  focusNode: _focusName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
                    hintText: 'Nombre',
                  ),
                ),
                SizedBox(height: paddingVertical),
                TextField(
                  controller: _apellidoFieldController,
                  focusNode: _focusApellido,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
                    hintText: 'Apellido',
                  ),
                ),
                SizedBox(height: paddingVertical),
                TextField(
                  controller: _emailFieldController,
                  focusNode: _focusEmail,
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
                  ),
                ),
                SizedBox(height: paddingVertical),
                TextField(
                  controller: _passwordFieldController,
                  focusNode: _focusPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
                  ),
                ),
                SizedBox(height: paddingVertical),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Administrador',
                      style: _opcionRol == RadioOpciones.Administrador
                          ? const TextStyle(color: Colors.green)
                          : const TextStyle(color: Colors.black),
                    ),
                    Radio(
                      value: RadioOpciones.Administrador,
                      groupValue: _opcionRol,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _opcionRol = RadioOpciones.Administrador;
                        });
                      },
                    ),
                    Text(
                      'Estandard',
                      style: _opcionRol == RadioOpciones.Estandard
                          ? const TextStyle(color: Colors.green)
                          : const TextStyle(color: Colors.black),
                    ),
                    Radio(
                      value: RadioOpciones.Estandard,
                      groupValue: _opcionRol,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _opcionRol = RadioOpciones.Estandard;
                        });
                      },
                    )
                  ],
                ),
                SizedBox(height: paddingVertical),
                _processing
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () async {
                    String nombre= _nameFieldController.text;
                    String apellido= _apellidoFieldController.text;
                    String email = _emailFieldController.text;
                    String password = _passwordFieldController.text;

                    setState(() {
                      _processing = true;
                      _statusMessage = "";
                    });

                    if (!UserViewModel.validateFields(nombre, apellido, email,password)) {
                      setState(() {
                        _statusMessage=  UserViewModel.statusMessage;
                        _processing = false;
                      });
                      return;
                    }

                    bool emailExists = await UserViewModel.isEmailAlreadyRegistered(email);

                    if (emailExists) {
                      setState(() {
                        _statusMessage = "El correo electrónico ya está registrado.";
                        _processing = false;
                      });
                      return;
                    }

                    User? user = await FireAuth.signUpUsingEmailAndPass(
                      name: nombre,
                      email: email,
                      password: password,
                    );

                    if (user != null) {
                      await FirebaseFirestore.instance.collection('usuarios').add({
                        'nombre': nombre,
                        'apellido': apellido,
                        'correo': email,
                        'rol': _opcionRol.name,
                      });

                      setState(() {
                        _statusMessage = "Usuario registrado correctamente.";
                      });
                    } else {
                      setState(() {
                        _statusMessage = "Error al registrar usuario. Vuelva a intentarlo.";
                      });
                    }

                    setState(() {
                      _processing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
                  ),
                  child: Text(
                    'Registrar Usuario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                SizedBox(height: paddingVertical),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage == "Usuario registrado correctamente."
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum RadioOpciones {
  Administrador,
  Estandard
}