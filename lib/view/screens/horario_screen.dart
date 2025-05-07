import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class HorarioScreen extends StatefulWidget {
  late final User user;

  HorarioScreen(this.user);

  @override
  _HorarioScreenState createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  List<List<dynamic>> _data = [];
  String? filepath;
  List<Color> _colorPalette = [];
  late String userRol = '';
  bool _isLoading = true;

  static Stream<QuerySnapshot> getUsuarios() => FirebaseFirestore.instance.collection('usuarios').orderBy('rol').snapshots();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _generateColorPalette();
    _loadFilepath();
    getUsuarios().listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['correo'] == widget.user.email) {
          setState(() {
            userRol = doc['rol'];
          });
          break;
        }
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = MediaQuery.of(context).size.width * 0.02;
    double headerFontSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Horario',
          style: TextStyle(color: Colors.white, fontSize: headerFontSize),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          userRol == 'Administrador'
              ? Padding(
            padding: EdgeInsets.all(screenHeight * 0.01),
            child: ElevatedButton(
              onPressed: () {
                _pickFile();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.025),
                  )),
              child: Text(
                'Subir CSV',
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              ),
            ),
          )
              : const SizedBox(),
          _isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: _data.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                Color backgroundColor;
                if (index == 0) {
                  backgroundColor = Colors.greenAccent;
                } else {
                  backgroundColor = _colorPalette[((index - 1) ~/ 2) % _colorPalette.length];
                }
                return Card(
                  margin: EdgeInsets.all(screenHeight * 0.01),
                  color: backgroundColor,
                  child: ListTile(
                    title: Row(
                      children: _data[index].map<Widget>((item) {
                        return Expanded(
                          child: Text(
                            item.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: index == 0 ? headerFontSize : fontSize,
                              fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;

    final filePath = result.files.first.path;
    if (filePath == null) return;

    File file = File(filePath);
    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = result.files.first.name;
    TaskSnapshot uploadTask = await storage.ref('uploads/$fileName').putFile(file);

    String downloadURL = await uploadTask.ref.getDownloadURL();

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('settings').doc('csv_filepath').set({
      'url': downloadURL,
    });

    setState(() {
      filepath = filePath;
    });

    _loadCSV(downloadURL);
  }

  void _generateColorPalette() {
    _colorPalette = [
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
    ];
  }

  Future<void> _loadFilepath() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot doc = await firestore.collection('settings').doc('csv_filepath').get();
    if (doc.exists) {
      String? downloadURL = doc['url'];
      if (downloadURL != null) {
        _loadCSV(downloadURL);
      }
    }
  }

  Future<void> _loadCSV(String url) async {
    final response = await http.get(Uri.parse(url));
    final fields = const CsvToListConverter().convert(utf8.decode(response.bodyBytes));

    setState(() {
      _data = fields;
      _isLoading = false;
    });
  }
}