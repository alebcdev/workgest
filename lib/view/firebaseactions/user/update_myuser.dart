import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../model/user_item.dart';
import '../../../viewmodel/user_viewmodel.dart';
import 'delete_user.dart';

class UpdateMyUser extends StatefulWidget {
  final UserItem userItem;
  final QueryDocumentSnapshot snapshot;
  final int classID;
  final User user;

  UpdateMyUser(this.userItem, this.user, {required this.snapshot, required this.classID});

  @override
  _UpdateMyUserState createState() => _UpdateMyUserState();
}

class _UpdateMyUserState extends State<UpdateMyUser> {
  late final TextEditingController _nameFieldController;
  late final TextEditingController _apellidoFieldController;
  late final TextEditingController _emailFieldController;
  late final TextEditingController _passwordFieldController1;
  late final TextEditingController _passwordFieldController2;

  late RadioOpciones _opcionRol;

  final FocusNode _focusName = FocusNode();
  final FocusNode _focusApellido = FocusNode();
  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusPassword1 = FocusNode();
  final FocusNode _focusPassword2 = FocusNode();

  bool _processing = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _nameFieldController = TextEditingController(text: widget.userItem.nombre);
    _apellidoFieldController = TextEditingController(text: widget.userItem.apellido);
    _emailFieldController = TextEditingController(text: widget.userItem.correo);
    _passwordFieldController1 = TextEditingController();
    _passwordFieldController2 = TextEditingController();

    if (widget.userItem.rol == 'Administrador') {
      _opcionRol = RadioOpciones.Administrador;
    } else {
      _opcionRol = RadioOpciones.Estandard;
    }
  }

  @override
  void dispose() {
    _nameFieldController.dispose();
    _apellidoFieldController.dispose();
    _emailFieldController.dispose();
    _passwordFieldController1.dispose();
    _passwordFieldController2.dispose();
    _focusName.dispose();
    _focusApellido.dispose();
    _focusEmail.dispose();
    _focusPassword1.dispose();
    _focusPassword2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double dialogWidth = MediaQuery.of(context).size.width * 0.8;
    double paddingVertical = MediaQuery.of(context).size.width * 0.04;
    double paddingHorizontal = MediaQuery.of(context).size.width * 0.05;
    double fontSize = MediaQuery.of(context).size.width * 0.04;

    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusApellido.unfocus();
        _focusEmail.unfocus();
        _focusPassword1.unfocus();
        _focusPassword2.unfocus();
      },
      child: AlertDialog(
        title: const Text('Edita el usuario'),
        contentPadding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
        actions: [
          TextButton(
            onPressed: () async {
              String nombre= _nameFieldController.text;
              String apellido= _apellidoFieldController.text;
              String nuevoEmail = _emailFieldController.text;
              String oldMonitorName = "${widget.userItem.nombre} ${widget.userItem.apellido}";
              String newMonitorName = "${_nameFieldController.text} ${_apellidoFieldController.text}";

              setState(() {
                _processing = true;
                _statusMessage = "";
              });

              if (!UserViewModel.validateFields(nombre, apellido, nuevoEmail, _passwordFieldController1.text)) {
                setState(() {
                  _statusMessage=  UserViewModel.statusMessage;
                  _processing = false;
                });
                return;
              }

              bool emailExists = await UserViewModel.isEmailAlreadyRegistered(_emailFieldController.text);

              if (emailExists && nuevoEmail != widget.userItem.correo) {
                setState(() {
                  _statusMessage = "El correo electrónico ya está registrado.";
                  _processing = false;
                });
                return;
              }

              if(widget.userItem.correo != nuevoEmail){
                await widget.user.verifyBeforeUpdateEmail(nuevoEmail);
              }

              UserViewModel.updateData(
                  nombre: nombre,
                  apellido: apellido,
                  correo: nuevoEmail,
                  rol: _opcionRol.name,
                  oldMonitorName: oldMonitorName,
                  newMonitorName: newMonitorName,
                  snapshotReference: widget.snapshot.reference
              );

              if (_passwordFieldController1.text.isNotEmpty && _passwordFieldController1.text == _passwordFieldController2.text) {
                await widget.user.updatePassword(_passwordFieldController1.text);
              } else if (_passwordFieldController1.text != _passwordFieldController2.text) {
                setState(() {
                  _processing = false;
                  _statusMessage = "Las contraseñas no coinciden.";
                });
                return;
              }

              setState(() {
                _processing = false;
                _statusMessage = "Usuario actualizado correctamente.";
              });

              Navigator.of(context).pop();

            },
            child: Text(
              'Editar',
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancelar',
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
        content: SingleChildScrollView(
          child: SizedBox(
            width: dialogWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameFieldController,
                  focusNode: _focusName,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
                  ),
                ),
                SizedBox(height: paddingVertical),
                TextField(
                  controller: _apellidoFieldController,
                  focusNode: _focusApellido,
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
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
                  controller: _passwordFieldController1,
                  focusNode: _focusPassword1,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
                  ),
                ),
                SizedBox(height: paddingVertical),
                TextField(
                  controller: _passwordFieldController2,
                  focusNode: _focusPassword2,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Repite la nueva contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                    ),
                  ),
                ),
                SizedBox(height: paddingVertical),
                if (widget.classID != 1 && _emailFieldController.text != widget.user.email)
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
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage == "Usuario actualizado correctamente."
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