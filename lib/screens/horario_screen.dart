import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workgest/managers/schedule_manager.dart';

class HorarioScreen extends StatefulWidget {
  final User user;

  const HorarioScreen(this.user, {super.key});

  @override
  _HorarioScreenState createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  List<dynamic> _data = [];
  late String userRol = '';
  final TextEditingController _groupController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _loadSchedules();
    ScheduleManager().getUserRole(widget.user).then((role) {
      if (mounted) {
        setState(() {
          userRol = role ?? '';
          if (userRol == 'Administrador') {
            _loadCSVFilePath();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _groupController.dispose();
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
        body: Column(children: [
          userRol == 'Administrador'
              ? Padding(
                  padding: EdgeInsets.all(screenHeight * 0.01),
                  child: ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.025),
                      ),
                    ),
                    child: Text(
                      'Subir CSV',
                      style: TextStyle(color: Colors.white, fontSize: fontSize),
                    ),
                  ),
                )
              : const SizedBox(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (_, index) {
                      return Card(
                          margin: EdgeInsets.all(screenHeight * 0.01),
                          child: ListTile(
                            title: Text(
                              'Activity: ${_data[index]['activityName']}, Monitor: ${_data[index]['monitorName']}',
                              style: TextStyle(fontSize: fontSize),
                            ),
                            subtitle: Text(
                              'Start: ${_data[index]['startTime']}, End: ${_data[index]['endTime']}',
                              style: TextStyle(fontSize: fontSize * 0.8),
                            ),
                          ));
                    },
                  ),
                ),
        ]));
  }

  void _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });
    List<dynamic> schedules = await ScheduleManager().getAllSchedules();
    setState(() {
      _data = schedules;
      _isLoading = false;
    });
  }

  void _pickFile() async {
    // This functionality will be implemented later
    print("Pick file for schedule");
  }

  Future<void> _loadCSVFilePath() async {
    // This functionality will be implemented later
    print("Load CSV file path");
  }

  Future<void> _loadCSV(String url) async {
    // This functionality will be implemented later
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadFilepath() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot doc =
        await firestore.collection('settings').doc('csv_filepath').get();
    if (doc.exists) {
      String? downloadURL = doc['url'];
      if (downloadURL != null) {
        _loadCSV(downloadURL);
      }
    }
  }
}
