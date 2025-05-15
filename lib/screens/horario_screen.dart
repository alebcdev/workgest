import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workgest/managers/schedule_manager.dart';
import 'package:http/http.dart' as http;
import 'package:workgest/services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class HorarioScreen extends StatefulWidget with WidgetsBindingObserver {
  final User? user;

  const HorarioScreen(this.user, {super.key});

  @override
  HorarioScreenState createState() => HorarioScreenState();
}

class HorarioScreenState extends State<HorarioScreen> {
  List<dynamic> _data = [];
  String userRol = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _loadSchedules();

    final currentUser = widget.user ?? FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      ScheduleManager.getUserRole(currentUser).then((role) {
        if (mounted && role != null) {
          setState(() {
            userRol = role;
          });
          if (userRol == 'Administrador') {
            _loadCSVFilePath();
          }
        }
      });
    } else {
      if (kDebugMode) {
        print("No authenticated user found for HorarioScreen.");
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    final schedules = await ScheduleManager().getAllSchedules();
    if (!mounted) return;
    setState(() {
      _data = schedules.map((s) => {
        'activityName': s.activityId,
        'monitorName': s.monitorId,
        'startTime': DateFormat('HH:mm').format(s.startTime),
        'endTime': DateFormat('HH:mm').format(s.endTime),
      }).toList();
      _data.sort((a, b) {
        final startTimeA = DateFormat('HH:mm').parse(a['startTime']);
        final startTimeB = DateFormat('HH:mm').parse(b['startTime']);
        return startTimeA.compareTo(startTimeB);
      });
    });
  }

  Future<void> _pickFile() async {
    final messenger = ScaffoldMessenger.of(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.bytes != null) {
        try {
          String downloadUrl = await FirebaseService.uploadFile(
            file.bytes!,
            'schedules.csv',
            'schedules/',
          );
          await FirebaseService.saveCsvFileUrl(downloadUrl);
          if (!mounted) return;
          messenger.showSnackBar(
            const SnackBar(content: Text('CSV uploaded successfully')),
          );
        } catch (e) {
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(content: Text('Error uploading CSV: $e')),
          );
        }
      }
    }
  }

  Future<void> _loadCSVFilePath() async {
    setState(() => _isLoading = true);
    try {
      String? csvUrl = (await FirebaseService.getCsvFileUrl()) as String?;
      if (csvUrl != null) {
        await _loadAndParseCSV(csvUrl);
      }
    } catch (e) {
      if (kDebugMode) print('Error loading CSV file path: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAndParseCSV(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final csvContent = response.body;
        final lines = csvContent
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();
        lines.map((line) => line.split(',').map((cell) => cell.trim()).toList()).toList();
      } else {
        if (kDebugMode) {
          print('Failed to load CSV file: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading and parsing CSV: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerFontSize = MediaQuery.of(context).size.width * 0.03;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = MediaQuery.of(context).size.width * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: Text('Horario', style: TextStyle(fontSize: headerFontSize)),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          if (userRol == 'Administrador') ...[
            Padding(
              padding: EdgeInsets.all(screenHeight * 0.02),
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
                        'Activity: ${row['activityName']}',
                        style: TextStyle(fontSize: headerFontSize * 0.8),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monitor: ${row['monitorName']}', style: TextStyle(fontSize: headerFontSize * 0.7)),
                          Text('Time: ${row['startTime']} - ${row['endTime']}', style: TextStyle(fontSize: headerFontSize * 0.7)),
                        ],
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
