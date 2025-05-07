import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/viewmodel/user_viewmodel.dart';

import '../../../model/user_item.dart';
import 'delete_user.dart';

class UpdateUser extends StatefulWidget {
  final UserItem userItem;
  final QueryDocumentSnapshot snapshot;
  final int classID;
  final User user;

  UpdateUser(this.userItem, this.user, {required this.snapshot, required this.classID});

  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  late final TextEditingController _nameFieldController;
  late final TextEditingController _apellidoFieldController;
  late final TextEditingController _emailFieldController;
  late RadioOpciones _opcionRol;

  final FocusNode _focusName = FocusNode();
  final FocusNode _focusApellido = FocusNode();
  final FocusNode _focusEmail = FocusNode();

  String _statusMessage = "";
  @override
  void initState() {
    super.initState();
    _nameFieldController = TextEditingController(text: widget.userItem.nombre);
    _apellidoFieldController = TextEditingController(text: widget.userItem.apellido);
    _emailFieldController = TextEditingController(text: widget.userItem.correo);

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
    _focusName.dispose();
    _focusApellido.dispose();
    _focusEmail.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    String oldEmail= widget.userItem.correo;
    double screenHeight = MediaQuery.of(context).size.height;
    double dialogWidth = MediaQuery.of(context).size.width * 0.8;
    double paddingVertical = MediaQuery.of(context).size.width * 0.04;
    double paddingHorizontal = MediaQuery.of(context).size.width * 0.05;
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    double iconSize = screenHeight * 0.04;

    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusApellido.unfocus();
        _focusEmail.unfocus();
      },
      child: AlertDialog(
        title: const Text(
          'Edita el usuario',
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
        actions: [
          if (widget.classID != 1 && oldEmail != widget.user.email)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteUser(snapshot: widget.snapshot);
                  },
                );
              },
              icon: Icon(
                Icons.delete,
                size: iconSize,
              ),
            ),
          TextButton(
            onPressed: () async {
              String nombre= _nameFieldController.text;
              String apellido= _apellidoFieldController.text;
              String nuevoEmail = _emailFieldController.text;
              String oldMonitorName = "${widget.userItem.nombre} ${widget.userItem.apellido}";
              String newMonitorName = "${_nameFieldController.text} ${_apellidoFieldController.text}";

              setState(() {
                _statusMessage = "";
              });

              if (!UserViewModel.validateFields(nombre,apellido,nuevoEmail,null)) {
                setState(() {
                  _statusMessage=  UserViewModel.statusMessage;
                });
                return;
              }


              bool emailExists = await UserViewModel.isEmailAlreadyRegistered(_emailFieldController.text);

              if (emailExists && nuevoEmail != widget.userItem.correo) {
                setState(() {
                  _statusMessage = "El correo electrónico ya está registrado.";
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

              setState(() {
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
                if (widget.classID != 1 && oldEmail != widget.user.email)
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