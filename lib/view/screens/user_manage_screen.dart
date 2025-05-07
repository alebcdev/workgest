import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/firebase_data.dart';
import 'package:workgest/model/user_item.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../firebaseactions/user/register_user.dart';
import '../firebaseactions/user/update_user.dart';

class UserManage extends StatefulWidget {
  final User user;

  UserManage(this.user);

  @override
  _UserManageState createState() => _UserManageState();
}

class _UserManageState extends State<UserManage> {
  final Stream<QuerySnapshot> _usuariosStream = FirebaseData.getStreamUsuarios();

  late String userRol = '';

  @override
  void initState() {
    super.initState();
    getActualUserRole();
  }

  void getActualUserRole() async {
    String? role = await UserViewModel.getUserRole(widget.user);
    if (role != null) {
      setState(() {
        userRol = role;
      });
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
      body: Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _usuariosStream,
          builder: (context, usuarios) {
            if (usuarios.hasError) {
              return const Text('Error de conexión');
            }
            if (usuarios.hasData) {
              final data = usuarios.data;
              return ListView.builder(
                itemCount: usuarios.data!.docs.length,
                itemBuilder: (context, index) {
                  String nombre = data?.docs[index]['nombre'];
                  String apellido = data?.docs[index]['apellido'];
                  String correo = data?.docs[index]['correo'];
                  String rol = data?.docs[index]['rol'];
                  if (userRol == 'Administrador') {
                    return ListTile(
                      leading: Icon(Icons.account_circle, size: iconSize),
                      title: Text('$nombre $apellido', style: TextStyle(fontSize: fontSizeLarge)),
                      subtitle: Text(correo, style: TextStyle(fontSize: fontSizeSmall)),
                      trailing: IconButton(
                        onPressed: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return UpdateUser(
                                UserItem(nombre, apellido, correo, rol),
                                widget.user,
                                snapshot: data!.docs[index],
                                classID: 0,
                              );
                            },
                          );
                        },
                        icon: Icon(
                            Icons.edit, size: iconSize
                        ),
                      ),
                      tileColor: _colorTile(index),
                    );
                  } else {
                    return ListTile(
                      leading: Icon(
                          Icons.account_circle,
                          size: iconSize
                      ),
                      title: Text('$nombre $apellido', style: TextStyle(fontSize: fontSizeLarge)),
                      subtitle: Text(correo, style: TextStyle(fontSize: fontSizeSmall)),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Rol:', style: TextStyle(fontSize: fontSizeSmall)),
                          Text(rol, style: TextStyle(fontSize: fontSizeSmall)),
                        ],
                      ),
                      tileColor: _colorTile(index),
                    );
                  }
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: userRol == 'Administrador'
          ? Padding(
        padding: EdgeInsets.all(paddingSize),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserRegistration()));
          },
          child: Icon(Icons.add, size: iconSize),
        ),
      )
          : null,
    );
  }

  Color _colorTile(int index) {
    return index % 2 == 0 ? Colors.black12 : Colors.white;
  }
}