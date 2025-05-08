import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Necesario para firstWhereOrNull
import 'package:workgest/model/user_item.dart';
import 'package:workgest/services/firebase_service.dart';
import 'package:workgest/widgets/dialogs/update_myuser_dialog.dart';

class MyProfileScreen extends StatelessWidget {
  final User user;

  const MyProfileScreen(this.user, {super.key});

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.getStreamUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error de conexión'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          final userDoc = docs.firstWhereOrNull((doc) => doc['correo'] == user.email);

          if (userDoc == null) {
            return const Center(child: Text('Usuario no encontrado.'));
          }

          String nombre = userDoc['nombre'];
          String apellido = userDoc['apellido'];
          String correo = userDoc['correo'];
          String rol = userDoc['rol'];

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
                  style: TextStyle(fontSize: fontSizeSmall),
                ),
                SizedBox(height: paddingSize),
                Text(
                  'Rol: $rol',
                  style: TextStyle(fontSize: fontSizeSmall),
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
                            return UpdateMyUserDialog(
                              UserItem(nombre, apellido, correo, rol),
                              user,
                              snapshot: userDoc,
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
        },
      ),
    );
  }
}
