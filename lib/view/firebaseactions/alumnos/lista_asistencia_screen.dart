import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workgest/model/firebase_data.dart';
import 'package:workgest/viewmodel/summercamper_viewmodel.dart';

import '../../../viewmodel/user_viewmodel.dart';

class ListaAsistencia extends StatefulWidget {
  final User user;

  ListaAsistencia(this.user);

  @override
  _ListaAsistenciaState createState() => _ListaAsistenciaState();
}

class _ListaAsistenciaState extends State<ListaAsistencia> {
  late Stream<QuerySnapshot> _usuariosStream;
  late Stream<QuerySnapshot> _estudiantesStream;
  String? _selectedMonitor = 'Todos';
  DateTime _selectedDate = DateTime.now();
  Map<String, bool> attendanceStatus = {};
  late String userRol = '';
  late String monitorActual = '';

  @override
  void initState() {
    super.initState();
    _usuariosStream = FirebaseData.getStreamUsuarios();
    _estudiantesStream = FirebaseData.getStreamAlumnos();
    _loadAttendanceStatus();
    getActualUserRole();
    getMonitorActual();
  }

  void getActualUserRole() async {
    String? role = await UserViewModel.getUserRole(widget.user);
    if (role != null) {
      setState(() {
        userRol = role;
      });
    }
  }

  void getMonitorActual() async{
    String? monitor = await SummerCamperViewModel.getMonitor(widget.user);
    if (monitor != null) {
      setState(() {
        monitorActual = monitor;
      });
    }
  }

  void _loadAttendanceStatus() async {
    final today = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    // Await the Future<QuerySnapshot> to get the actual QuerySnapshot
    final snapshot = await FirebaseData.getAsistenciaByDate(today);

    setState(() {
      for (var doc in snapshot.docs) {
        attendanceStatus[doc['estudianteId']] = doc['asistio'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingSize = screenWidth * 0.03;
    double fontSizeLarge = screenHeight * 0.025;
    double fontSizeSmall = screenHeight * 0.02;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Lista de Asistencia',
          style: TextStyle(color: Colors.white, fontSize: fontSizeLarge),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingSize),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(paddingSize),
              child: Row(
                children: [
                  if(userRol != 'Estandard')
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
                                    attendanceStatus.clear();
                                    _loadAttendanceStatus();
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
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      _formatDate(_selectedDate),
                      style: TextStyle(fontSize: fontSizeSmall),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _estudiantesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  List<QueryDocumentSnapshot> estudiantes;
                  if(userRol != 'Estandard'){
                    estudiantes= _selectedMonitor != null && _selectedMonitor != 'Todos'
                        ? data.docs.where((doc) => doc['monitor'] == _selectedMonitor).toList().cast<QueryDocumentSnapshot>()
                        : data.docs.cast<QueryDocumentSnapshot>();
                  }else{
                    estudiantes= data.docs.where((doc) => doc['monitor'] == monitorActual).toList().cast<QueryDocumentSnapshot>();

                  }


                  return ListView.builder(
                    itemCount: estudiantes.length,
                    itemBuilder: (context, index) {
                      final doc = estudiantes[index];
                      final nombre = doc['nombre'];
                      final apellido = doc['apellido'];
                      final estudianteId = doc.id;
                      final asistio = attendanceStatus[estudianteId] ?? false;

                      return ListTile(
                        title: Text('$nombre $apellido', style: TextStyle(fontSize: fontSizeLarge)),
                        trailing: Switch(
                          value: asistio,
                          onChanged: (value) {
                            _updateAttendance(estudianteId, nombre, apellido, value);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAttendance(String estudianteId, String nombre, String apellido, bool asistio) async {
    final today = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final snapshot = await FirebaseData.getAsistenciaByEstudianteAndDay(estudianteId, today);

    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('asistencias')
          .doc(docId)
          .update({'asistio': asistio});
    } else {
      await FirebaseFirestore.instance.collection('asistencias').add({
        'estudianteId': estudianteId,
        'nombre': nombre,
        'apellido': apellido,
        'fecha': Timestamp.fromDate(today),
        'asistio': asistio,
      });
    }

    setState(() {
      attendanceStatus[estudianteId] = asistio;
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        attendanceStatus.clear();
        _loadAttendanceStatus();
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}