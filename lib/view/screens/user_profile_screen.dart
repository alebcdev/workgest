import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/user_item.dart';

import '../../model/firebase_data.dart';
import '../firebaseactions/user/update_myuser.dart';

class MyProfileScreen extends StatelessWidget {
  final User user;

  MyProfileScreen(this.user);

  late final Stream<QuerySnapshot> _usuariosStream = FirebaseData.getStreamUsuarios();


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = screenHeight * 0.2;
    double fontSizeLarge = screenHeight * 0.04;
    double fontSizeMedium = screenHeight * 0.03;
    double fontSizeSmall = screenHeight * 0.025;
    double paddingSize = screenHeight * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi usuario',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder(
        stream: _usuariosStream,
        builder: (context, usuarios) {
          if (usuarios.hasError) {
            return const Text('Error de conexión');
          }
          if (usuarios.hasData) {
            final data = usuarios.data;
            if (data != null) {
              return ListView.builder(
                itemCount: data.docs.length,
                itemBuilder: (context, index) {
                  if (data.docs[index]['correo'] == user.email) {
                    String nombre = data.docs[index]['nombre'];
                    String apellido = data.docs[index]['apellido'];
                    String correo = data.docs[index]['correo'];
                    String rol = data.docs[index]['rol'];
                    return Padding(
                      padding: EdgeInsets.all(paddingSize),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Icon(
                              Icons.account_circle,
                              size: iconSize,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          SizedBox(height: paddingSize),
                          Text(
                            nombre,
                            style: TextStyle(
                              fontSize: fontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: paddingSize),
                          Text(
                            apellido,
                            style: TextStyle(
                              fontSize: fontSizeMedium,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: paddingSize),
                          Text(
                            'Email: $correo',
                            style: TextStyle(
                              fontSize: fontSizeSmall,
                            ),
                          ),
                          SizedBox(height: paddingSize),
                          Text(
                            'Rol: $rol',
                            style: TextStyle(
                              fontSize: fontSizeSmall,
                            ),
                          ),
                          SizedBox(height: paddingSize),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FloatingActionButton(
                                shape: const CircleBorder(),
                                child: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return UpdateMyUser(
                                        UserItem(nombre, apellido, correo, rol),
                                        user,
                                        snapshot: data.docs[index],
                                        classID: 1,
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}