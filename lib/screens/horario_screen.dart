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
  String userRol = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Forzamos landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _loadSchedules();
    // Ahora existe getUserRole
    ScheduleManager.getUserRole(widget.user).then((role) {
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
    // Volvemos a portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    final schedules = await ScheduleManager().getAllSchedules();
    setState(() {
      _data = schedules.map((s) => {
        'activityName': s.activityId,
        'monitorName': s.monitorId,
        'startTime': s.startTime.toIso8601String(),
        'endTime': s.endTime.toIso8601String(),
      }).toList();
      _isLoading = false;
    });
  }

  void _pickFile() {
    // Implementar subida de CSV
  }

  Future<void> _loadCSVFilePath() async {
    // Implementar carga de URL de CSV
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = MediaQuery.of(context).size.width * 0.02;
    final headerFontSize = MediaQuery.of(context).size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text('Horario', style: TextStyle(fontSize: headerFontSize)),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          if (userRol == 'Administrador') ...[
            Padding(
              padding: EdgeInsets.all(screenHeight * 0.01),
              child: ElevatedButton(
                onPressed: _pickFile,
                child: Text('Subir CSV', style: TextStyle(fontSize: fontSize)),
              ),
            ),
          ],
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (_, i) {
                  final row = _data[i];
                  return Card(
                    margin: EdgeInsets.all(screenHeight * 0.01),
                    child: ListTile(
                      title: Text(
                        'Activity: ${row['activityName']}, Monitor: ${row['monitorName']}',
                        style: TextStyle(fontSize: fontSize),
                      ),
                      subtitle: Text(
                        'Start: ${row['startTime']}, End: ${row['endTime']}',
                        style: TextStyle(fontSize: fontSize * 0.8),
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
}
