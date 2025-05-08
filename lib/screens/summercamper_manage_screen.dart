import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/summercamper_item.dart';
import 'package:workgest/managers/user_manager.dart';
import 'package:workgest/managers/summer_camper_manager.dart';

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
    _summerCampersStream = SummerCamperManager.getSummerCampersStream();
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
                      trailing: userRol == 'Administrador' ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: iconSize),
                            onPressed: () {
                              _showManageSummerCamperDialog(context, camper: camper);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: iconSize),
                            onPressed: () {
                              _showDeleteSummerCamperDialog(context, camper);
                            },
                          ),
                        ],
                      ) : Column(
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
                  _showManageSummerCamperDialog(context);
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

  void _showManageSummerCamperDialog(BuildContext context, {SummerCamper? camper}) {
    final TextEditingController nameController = TextEditingController(text: camper?.nombre ?? '');
    final TextEditingController lastNameController = TextEditingController(text: camper?.apellido ?? '');
    final TextEditingController ageController = TextEditingController(text: camper?.edad.toString() ?? '');
    final TextEditingController monitorController = TextEditingController(text: camper?.monitor ?? '');
    final TextEditingController groupController = TextEditingController(text: camper?.group ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(camper == null ? 'Registrar Alumno' : 'Editar Alumno'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Nombre'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(hintText: 'Apellido'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(hintText: 'Edad'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: monitorController,
                  decoration: const InputDecoration(hintText: 'Monitor'),
                ),
                TextField(
                  controller: groupController,
                  decoration: const InputDecoration(hintText: 'Grupo'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(camper == null ? 'Registrar' : 'Guardar'),
              onPressed: () async {
                final String name = nameController.text.trim();
                final String lastName = lastNameController.text.trim();
                final int age = int.tryParse(ageController.text.trim()) ?? 0;
                final String monitor = monitorController.text.trim();
                final String group = groupController.text.trim();

                if (name.isEmpty || lastName.isEmpty || age <= 0 || monitor.isEmpty || group.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, completa todos los campos.')),
                  );
                  return;
                }

                if (camper == null) {
                  // Create new summer camper
                  final newSummerCamper = SummerCamper(
                    id: '', // ID will be generated by Firestore
                    nombre: name,
                    apellido: lastName,
                    edad: age,
                    monitor: monitor,
                    group: group,
                  );
                  await SummerCamperManager.createSummerCamper(newSummerCamper);
                } else {
                  // Update existing summer camper
                  final updatedSummerCamper = SummerCamper(
                    id: camper.id,
                    nombre: name,
                    apellido: lastName,
                    edad: age,
                    monitor: monitor,
                    group: group,
                  );
                  await SummerCamperManager.updateSummerCamper(updatedSummerCamper);
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSummerCamperDialog(BuildContext context, SummerCamper camper) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Alumno'),
          content: Text('¿Estás seguro de que quieres eliminar a ${camper.nombre} ${camper.apellido}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                try {
                  await SummerCamperManager.deleteSummerCamper(camper.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alumno eliminado con éxito')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar alumno: $e')),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
