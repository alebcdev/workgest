import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/user_item.dart';
import 'package:workgest/managers/user_manager.dart';
import 'package:workgest/screens/user_registration_screen.dart';
import 'package:workgest/screens/update_user_screen.dart';

class UserManage extends StatefulWidget {
  final User? user;

  const UserManage(this.user, {super.key});

  @override
  UserManageState createState() => UserManageState();
}

class UserManageState extends State<UserManage> {
  final Stream<QuerySnapshot> _usuariosStream =
      FirebaseFirestore.instance.collection('usuarios').snapshots();

  String userRol = '';

  @override
  void initState() {
    super.initState();
    getActualUserRole();
  }

  void getActualUserRole() async {
    if (widget.user != null) {
      String? role = await UserManager.getUserRole(widget.user!);
      if (role != null) {
        setState(() {
          userRol = role;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingSize = screenWidth * 0.03;
    double fontSizeLarge = screenHeight * 0.025;
    double fontSizeSmall = screenHeight * 0.02;
    double iconSize = screenHeight * 0.04;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Gestión de usuarios',
          style: TextStyle(color: Colors.white, fontSize: fontSizeLarge),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usuariosStream,
        builder: (context, usuarios) {
          if (usuarios.hasError) {
            return const Center(child: Text('Error de conexión'));
          }
          if (usuarios.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = usuarios.data;
          if (data == null || data.docs.isEmpty) {
            return const Center(child: Text("No hay usuarios."));
          }

          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final doc = data.docs[index];
              final nombre = doc['nombre'];
              final apellido = doc['apellido'];
              final correo = doc['correo'];
              final rol = doc['rol'];

              return ListTile(
                leading: Icon(
                  Icons.account_circle,
                  size: iconSize,
                ),
                title: Text('$nombre $apellido',
                    style: TextStyle(fontSize: fontSizeLarge)),
                subtitle:
                    Text(correo, style: TextStyle(fontSize: fontSizeSmall)),
                trailing: userRol == 'Administrador'
                    ? IconButton(
                        icon: Icon(Icons.edit, size: iconSize),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => UpdateUserScreen(
                              userItem: UserItem(
                                id: doc.id,
                                name: '$nombre $apellido',
                                email: correo,
                                type: rol,
                              ),
                            ),
                          );
                        },
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Rol:',
                              style: TextStyle(fontSize: fontSizeSmall)),
                          Text(rol, style: TextStyle(fontSize: fontSizeSmall)),
                        ],
                      ),
                tileColor: _colorTile(index),
              );
            },
          );
        },
      ),
      floatingActionButton: userRol == 'Administrador'
          ? Padding(
              padding: EdgeInsets.all(paddingSize),
              child: FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const UserRegistrationScreen(),
                  ));
                },
                child: Icon(Icons.add, size: iconSize),
              ),
            )
          : null,
    );
  }

  Color _colorTile(int index) {
    return index % 2 == 0 ? Colors.grey.shade200 : Colors.white;
  }
}
