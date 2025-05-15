import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/managers/user_manager.dart';
import 'package:workgest/screens/login_screen.dart';
import 'package:workgest/screens/summercamper_manage_screen.dart';

class UserAdminScreen extends StatefulWidget {
  final User user;

  const UserAdminScreen({super.key, required this.user});

  @override
  UserAdminScreenState createState() => UserAdminScreenState();
}

class UserAdminScreenState extends State<UserAdminScreen> {
  late User _user;
  late String _userRole = "";

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    String? role = await UserManager.getUserRole(_user);
    if (role != null) {
      setState(() {
        _userRole = role;
      });
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeLarge = screenHeight * 0.025;
    double iconSize = screenHeight * 0.05;
    double spacing = screenHeight * 0.02;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Inicio"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: iconSize),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bienvenido, ${_user.email ?? 'usuario'}",
                style: TextStyle(fontSize: fontSizeLarge)),
            SizedBox(height: spacing),
            Text("Rol: $_userRole", style: TextStyle(fontSize: fontSizeLarge)),
            SizedBox(height: spacing * 2),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SummerCamperManage(_user),
                ));
              },
              icon: Icon(Icons.group, size: iconSize),
              label: Text("Gestión de Alumnos",
                  style: TextStyle(fontSize: fontSizeLarge)),
            ),
            // Puedes agregar más botones aquí según el rol u opciones disponibles
          ],
        ),
      ),
    );
  }
}
