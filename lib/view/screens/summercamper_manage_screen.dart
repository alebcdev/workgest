import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/summercamper_item.dart';
import 'package:workgest/viewmodel/app_navegation.dart';
import 'package:workgest/viewmodel/summercamper_viewmodel.dart';
import '../../model/firebase_data.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../firebaseactions/alumnos/register_summercamper.dart';
import '../firebaseactions/alumnos/update_summercamper.dart';

class SummerCamperManage extends StatefulWidget {
  late final User user;

  SummerCamperManage(this.user);

  @override
  _SummerCamperManageState createState() => _SummerCamperManageState();
}

class _SummerCamperManageState extends State<SummerCamperManage> {
  late Stream<QuerySnapshot> _usuariosStream;
  late Stream<QuerySnapshot> _estudiantesStream;

  String? _selectedMonitor = 'Todos';
  late String userRol = '';
  late Future<List<String>> monitoresFuture;

  @override
  void initState() {
    super.initState();
    _usuariosStream = FirebaseData.getStreamUsuarios();
    _estudiantesStream = FirebaseData.getStreamAlumnos();
    getActualUserRole();
    monitoresFuture = SummerCamperViewModel().getMonitoresList();
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
          'Gestión de alumnos',
          style: TextStyle(color: Colors.white, fontSize: fontSizeLarge),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(paddingSize),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filtra por monitor:', style: TextStyle(fontSize: fontSizeSmall)),
                      StreamBuilder<QuerySnapshot>(
                        stream: _usuariosStream,
                        builder: (context, usuarios) {
                          if (usuarios.hasError) {
                            return const CircularProgressIndicator();
                          }
                          if (usuarios.connectionState == ConnectionState.waiting) {
                            return Container();
                          }
                          final data = usuarios.data!;
                          List<String> monitores = [];
                          for (int i = 0; i < data.docs.length; i++) {
                            if (data.docs[i]['rol'] == 'Estandard') {
                              monitores.add(data.docs[i]['nombre'] + ' ' + data.docs[i]['apellido']);
                            }
                          }
                          monitores.add('Todos');
                          return DropdownButton<String>(
                            value: _selectedMonitor,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedMonitor = newValue;
                              });
                            },
                            items: monitores.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: fontSizeSmall)),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _estudiantesStream,
              builder: (context, estudiante) {
                if (estudiante.hasError) {
                  return const Text('Error de conexión');
                }
                if (estudiante.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (estudiante.hasData) {
                  final data = estudiante.data!;
                  List<QueryDocumentSnapshot> estudiantes = _selectedMonitor != null && _selectedMonitor != 'Todos'
                      ? data.docs.where((doc) => doc['monitor'] == _selectedMonitor).toList().cast<QueryDocumentSnapshot>()
                      : data.docs.cast<QueryDocumentSnapshot>();
                  return ListView.builder(
                    itemCount: estudiantes.length,
                    itemBuilder: (context, index) {
                      String nombre = data.docs[index]['nombre'];
                      String apellido = data.docs[index]['apellido'];
                      String monitor = data.docs[index]['monitor'];
                      int edad = data.docs[index]['edad'];
                      if (userRol == 'Administrador') {
                        return ListTile(
                          leading: Icon(Icons.account_circle, size: iconSize),
                          title: Text('$nombre $apellido', style: TextStyle(fontSize: fontSizeLarge)),
                          subtitle: Text(monitor, style: TextStyle(fontSize: fontSizeSmall)),
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return UpdateSummerCamper(
                                    SummerCamper(nombre, apellido, edad, monitor),
                                    snapshot: data.docs[index],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.edit, size: iconSize),
                          ),
                          tileColor: _colorTile(index),
                        );
                      } else {
                        return ListTile(
                          leading: Icon(Icons.account_circle, size: iconSize),
                          title: Text('$nombre $apellido', style: TextStyle(fontSize: fontSizeLarge)),
                          subtitle: Text(monitor, style: TextStyle(fontSize: fontSizeSmall)),
                          tileColor: _colorTile(index),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Edad:', style: TextStyle(fontSize: fontSizeSmall)),
                              Text('$edad', style: TextStyle(fontSize: fontSizeSmall)),
                            ],
                          ),
                        );
                      }
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(paddingSize),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userRol == 'Administrador')
              FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SummerCamperRegistration()));
                },
                child: Icon(Icons.add, size: iconSize),
              ),
            const SizedBox(height: 10),
            if (userRol == 'Administrador' || userRol == 'Estandard')
              FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () {
                  AppNavigation.goToListaAsistencia(context, widget.user);
                },
                child: Icon(Icons.check, size: iconSize),
              ),
          ],
        ),
      ),
    );
  }

  Color _colorTile(int index) {
    return index % 2 == 0 ? Colors.black12 : Colors.white;
  }
}