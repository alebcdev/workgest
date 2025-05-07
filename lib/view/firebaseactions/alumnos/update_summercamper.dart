import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/firebase_data.dart';
import 'package:workgest/model/summercamper_item.dart';
import 'package:workgest/viewmodel/summercamper_viewmodel.dart';

import 'delete_summercamper.dart';

class UpdateSummerCamper extends StatefulWidget {
  final SummerCamper summerCamper;
  final QueryDocumentSnapshot snapshot;

  UpdateSummerCamper(this.summerCamper, {required this.snapshot});

  @override
  _UpdateSummerCamperState createState() => _UpdateSummerCamperState();
}

class _UpdateSummerCamperState extends State<UpdateSummerCamper> {

  late final TextEditingController _nameFieldController;
  late final TextEditingController _apellidoFieldController;
  String? _selectedMonitor;
  late int _edad;

  final FocusNode _focusName = FocusNode();
  final FocusNode _focusApellido = FocusNode();

  late QueryDocumentSnapshot _snapshot;

  late Stream<QuerySnapshot> _usuariosStream;
  late Stream<QuerySnapshot> _estudiantesStream;

  List<int> edades = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
  bool _processing = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _nameFieldController = TextEditingController(text: widget.summerCamper.nombre);
    _apellidoFieldController = TextEditingController(text: widget.summerCamper.apellido);
    _selectedMonitor = widget.summerCamper.monitor;
    _usuariosStream = FirebaseData.getStreamUsuarios();
    _estudiantesStream = FirebaseData.getStreamAlumnos();
    _edad = widget.summerCamper.edad;
  }

  @override
  void dispose() {
    _nameFieldController.dispose();
    _apellidoFieldController.dispose();
    _focusName.dispose();
    _focusApellido.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingVertical = MediaQuery.of(context).size.width * 0.04;
    double paddingHorizontal = MediaQuery.of(context).size.width * 0.05;
    double fontSize = MediaQuery.of(context).size.width * 0.04;
    double iconSize = screenHeight * 0.04;

    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusApellido.unfocus();
      },
      child: AlertDialog(
        title: const Text('Edita el alumno'),
        contentPadding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteSummerCamper(snapshot: widget.snapshot);
                    });
              },
              icon: Icon(
                Icons.delete,
                size: iconSize,
              )),
          TextButton(
              onPressed: () async {
                String nombre = _nameFieldController.text;
                String apellido = _apellidoFieldController.text;
                String? monitor = _selectedMonitor;

                setState(() {
                  _processing = true;
                  _statusMessage = "";
                });

                if (!SummerCamperViewModel.validateFields(nombre,apellido,monitor)) {
                  setState(() {
                    _statusMessage=  SummerCamperViewModel.statusMessage;
                    _processing = false;
                  });
                  return;
                }

                bool isDuplicate = await SummerCamperViewModel.isDuplicateSummerCamper(
                    _nameFieldController.text,
                    _apellidoFieldController.text,
                    _edad
                );
                if (isDuplicate) {
                  setState(() {
                    _statusMessage = "El estudiante con el mismo nombre, apellido y edad ya está registrado.";
                  });
                  return;
                }

                FirebaseFirestore.instance.runTransaction((transaction) async {
                  transaction.update(widget.snapshot.reference, {
                    "nombre": _nameFieldController.text,
                    "apellido": _apellidoFieldController.text,
                    "monitor": _selectedMonitor,
                    "edad": _edad
                  });
                });

                Navigator.of(context).pop();
              },
              child: Text(
                'Editar',
                style: TextStyle(fontSize: fontSize),
              )),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(fontSize: fontSize),
              )),
        ],
        content: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameFieldController,
                  focusNode: _focusName,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.025)),
                  ),
                ),
                SizedBox(height: paddingVertical),
                TextField(
                  controller: _apellidoFieldController,
                  focusNode: _focusApellido,
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.025)),
                  ),
                ),
                SizedBox(height: paddingVertical),
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
                      hint: const Text('Todos'),
                    );
                  },
                ),
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
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage == "Usuario actualizado correctamente."
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}