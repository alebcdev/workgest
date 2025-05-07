import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workgest/viewmodel/summercamper_viewmodel.dart';

class SummerCamperRegistration extends StatefulWidget {
  @override
  _SummerCamperRegistrationState createState() => _SummerCamperRegistrationState();
}

class _SummerCamperRegistrationState extends State<SummerCamperRegistration> {
  late Stream<QuerySnapshot> _usuariosStream;
  late Stream<QuerySnapshot> _estudiantesStream;
  late QueryDocumentSnapshot _snapshot;

  final _nameFieldController = TextEditingController();
  final _apellidoFieldController = TextEditingController();
  String? _selectedMonitor;
  late int _edad;

  final _focusName = FocusNode();
  final _focusApellido = FocusNode();

  bool _processing = false;
  String _statusMessage = "";

  static Stream<QuerySnapshot> getUsuarios() =>
      FirebaseFirestore.instance.collection('usuarios').orderBy('rol').snapshots();

  static Stream<QuerySnapshot> getEstudiantes() =>
      FirebaseFirestore.instance.collection('estudiantes').orderBy('edad').snapshots();

  @override
  void dispose() {
    _nameFieldController.dispose();
    _apellidoFieldController.dispose();
    _focusName.dispose();
    _focusApellido.dispose();
    super.dispose();
  }

  List<int> edades = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  @override
  void initState() {
    super.initState();
    _usuariosStream = getUsuarios();
    _estudiantesStream = getEstudiantes();
    _edad = edades[0];
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double padding = MediaQuery.of(context).size.width * 0.05;
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    double paddingVertical = MediaQuery.of(context).size.width * 0.04;

    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusApellido.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Registra un Nuevo Alumno',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: Column(
                children: [
                  TextField(
                    controller: _nameFieldController,
                    focusNode: _focusName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.025),
                      ),
                      hintText: 'Nombre',
                    ),
                  ),
                  SizedBox(height: paddingVertical),
                  TextField(
                    controller: _apellidoFieldController,
                    focusNode: _focusApellido,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.025),
                      ),
                      hintText: 'Apellido',
                    ),
                  ),
                  SizedBox(height: paddingVertical),
                  const Text('Monitor:'),
                  SizedBox(height: paddingVertical),
                  StreamBuilder<QuerySnapshot>(
                    stream: _usuariosStream,
                    builder: (context, usuarios) {
                      if (usuarios.hasError || usuarios.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final data = usuarios.data!;
                      List<String> monitores = [];
                      for (int i = 0; i < data.docs.length; i++) {
                        if (data.docs[i]['rol'] == 'Estandard') {
                          monitores.add(data.docs[i]['nombre'] + ' ' + data.docs[i]['apellido']);
                        }
                      }
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
                            child: Text(value),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: paddingVertical),
                  const Text('Edad:'),
                  SizedBox(height: paddingVertical),
                  DropdownButton<int>(
                    value: _edad,
                    onChanged: (int? newValue) {
                      setState(() {
                        _edad = newValue!;
                      });
                    },
                    items: edades.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                    hint: const Text('Edad'),
                  ),
                  SizedBox(height: paddingVertical),
                  _processing
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () async {
                      String nombre = _nameFieldController.text;
                      String apellido = _apellidoFieldController.text;
                      String? monitor = _selectedMonitor;

                      setState(() {
                        _processing = true;
                        _statusMessage = "";
                      });

                      if(!SummerCamperViewModel.validateFields(nombre,apellido,monitor)) {
                        setState(() {
                          _statusMessage=  SummerCamperViewModel.statusMessage;
                          _processing = false;
                        });
                        return;
                      }else {
                        setState(() {
                          _processing = true;
                          _statusMessage = "";
                        });

                        bool studentExists = await SummerCamperViewModel.isDuplicateSummerCamper(
                            _nameFieldController.text,
                            _apellidoFieldController.text,
                            _edad);

                        if (studentExists) {
                          setState(() {
                            _statusMessage = "El estudiante ya está registrado.";
                            _processing = false;
                          });
                        } else {
                          await FirebaseFirestore.instance.collection('estudiantes').add({
                            'nombre': _nameFieldController.text,
                            'apellido': _apellidoFieldController.text,
                            'monitor': _selectedMonitor,
                            'edad': _edad,
                          });

                          setState(() {
                            _statusMessage = "Estudiante registrado correctamente.";
                            _processing = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.025),
                      ),
                    ),
                    child: Text(
                      'Registrar Alumno',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                  SizedBox(height: paddingVertical),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage == "Estudiante registrado correctamente."
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}