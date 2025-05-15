import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workgest/services/firebase_service.dart';
import 'package:workgest/managers/summer_camper_manager.dart';
import 'package:workgest/managers/user_manager.dart';

class AttendanceListScreen extends StatefulWidget {
  final User user;

  const AttendanceListScreen(this.user, {super.key});

  @override
  AttendanceListScreenState createState() => AttendanceListScreenState();
}

class AttendanceListScreenState extends State<AttendanceListScreen> {
  late Stream<QuerySnapshot> _estudiantesStream;
  String userRol = '';
  String monitorActual = '';
  DateTime _selectedDate = DateTime.now();
  Map<String, bool> attendanceStatus = {};

  final _camperManager = SummerCamperManager();

  @override
  void initState() {
    super.initState();
    _estudiantesStream = FirebaseService.getStreamAlumnos();
    _loadAttendanceStatus();
    _getUserRoleAndMonitor();
  }

  Future<void> _getUserRoleAndMonitor() async {
    final role = await UserManager.getUserRole(widget.user);
    final monitor = await _camperManager.getMonitorForSummerCamper(widget.user.uid);
    if (!mounted) return;
    setState(() {
      if (role != null) userRol = role;
      if (monitor != null) monitorActual = monitor;
    });
  }

  Future<void> _loadAttendanceStatus() async {
    final date = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final snapshot = await FirebaseService.getAsistenciaByDate(date);
    final status = <String, bool>{};
    for (var doc in snapshot.docs) {
      status[doc['estudianteId']] = doc['asistio'] as bool? ?? false;
    }
    if (!mounted) return;
    setState(() => attendanceStatus = status);
  }

  void _toggleAttendance(String studentId) {
    setState(() {
      attendanceStatus[studentId] = !(attendanceStatus[studentId] ?? false);
    });
  }

  Future<void> _saveAttendance(String studentId, String nombre, String apellido) async {
    final asistio = attendanceStatus[studentId] ?? false;
    final messenger = ScaffoldMessenger.of(context);
    await _camperManager.updateAttendance(
      studentId,
      nombre,
      apellido,
      asistio,
      _selectedDate,
    );
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text("Asistencia guardada")),
    );
  }

  Widget _buildStudentTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final studentId = doc.id;
    final asistio = attendanceStatus[studentId] ?? false;
    final monitor = data['monitor'] as String? ?? '';

    if (userRol == 'Estandard' && monitor != monitorActual) {
      return const SizedBox.shrink();
    }

    return ListTile(
      title: Text('${data['nombre']} ${data['apellido']}'),
      subtitle: Text('Edad: ${data['edad']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: asistio,
            onChanged: (_) => _toggleAttendance(studentId),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveAttendance(
              studentId,
              data['nombre'] as String,
              data['apellido'] as String,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Fecha:'),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              if (!mounted) return;
              setState(() => _selectedDate = pickedDate);
              await _loadAttendanceStatus();
            }
          },
          child: Text(
            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Asistencia'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildDateSelector(),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _estudiantesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay estudiantes.'));
                }
                return ListView(
                  children: snapshot.data!.docs.map(_buildStudentTile).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
