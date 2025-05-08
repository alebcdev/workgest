import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/summercamper_item.dart';
import 'package:workgest/managers/user_manager.dart';
import 'package:workgest/managers/summer_camper_manager.dart';
import 'package:workgest/screens/summercamper_registration_screen.dart';

class SummerCamperManage extends StatefulWidget {
  final User user;

  const SummerCamperManage(this.user, {super.key});

  @override
  _SummerCamperManageState createState() => _SummerCamperManageState();
}

class _SummerCamperManageState extends State<SummerCamperManage> {
  late Stream<List<SummerCamper>> _summerCampersStream;
  String? _selectedMonitor = 'Todos';
  late String userRol = '';

  @override
  void initState() {
    super.initState();
    _summerCampersStream = SummerCamperManager.getSummerCampersStream() as Stream<List<SummerCamper>>;
    _loadUserRole();
  }

  void _loadUserRole() async {
    String? role = await UserManager.getUserRole(widget.user);
    if (mounted) {
      setState(() {
        userRol = role ?? '';
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
                  child: StreamBuilder<List<String>>(
                    stream: SummerCamperManager.getMonitorsStream(),
                    builder: (context, monitorsSnapshot) {
                      if (monitorsSnapshot.hasError || !monitorsSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      List<String> monitors = ['Todos', ...monitorsSnapshot.data!];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Filtra por monitor:',
                              style: TextStyle(fontSize: fontSizeSmall)),
                          DropdownButton<String>(
                            value: _selectedMonitor,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedMonitor = newValue!;
                              });
                            },
                            items: monitors.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(fontSize: fontSizeSmall)),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SummerCamper>>(
              stream: _summerCampersStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error de conexión'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final campers = _selectedMonitor != 'Todos'
                    ? snapshot.data!.where((c) => c.monitor == _selectedMonitor).toList()
                    : snapshot.data!;

                if (campers.isEmpty) {
                  return const Center(child: Text('No hay alumnos registrados.'));
                }

                return ListView.builder(
                  itemCount: campers.length,
                  itemBuilder: (context, index) {
                    final camper = campers[index];

                    return ListTile(
                      leading: Icon(Icons.account_circle, size: iconSize),
                      title: Text('${camper.nombre} ${camper.apellido}',
                          style: TextStyle(fontSize: fontSizeLarge)),
                      subtitle: Text(camper.monitor,
                          style: TextStyle(fontSize: fontSizeSmall)),
                      trailing: userRol == 'Administrador'
                          ? IconButton(
                        icon: Icon(Icons.edit, size: iconSize),
                        onPressed: () {
                          // Aquí deberías crear la pantalla UpdateSummerCamperScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SummerCamperRegistrationScreen(
                                      camperToEdit: camper),
                            ),
                          );
                        },
                      )
                          : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Edad:',
                              style: TextStyle(fontSize: fontSizeSmall)),
                          Text('${camper.edad}',
                              style: TextStyle(fontSize: fontSizeSmall)),
                        ],
                      ),
                      tileColor: _colorTile(index),
                    );
                  },
                );
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SummerCamperRegistrationScreen(),
                  ));
                },
                child: Icon(Icons.add, size: iconSize),
              ),
            const SizedBox(height: 10),
            if (userRol == 'Administrador' || userRol == 'Estandard')
              FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () {
                  // Aquí puedes navegar a la pantalla de asistencia
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
