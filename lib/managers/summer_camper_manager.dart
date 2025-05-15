import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workgest/services/firebase_service.dart';
import '../model/summercamper_item.dart';

class SummerCamperManager {
  static String statusMessage = "";
  final FirebaseService _service = FirebaseService();

  bool validateFields(String nombre, String apellido, String? monitor) {
    if (nombre.isEmpty || apellido.isEmpty || monitor == null || monitor.isEmpty) {
      statusMessage = "Todos los campos son obligatorios.";
      return false;
    }
    return true;
  }

  Future<List<SummerCamper>> getAllSummerCampers() async {
    try {
      final List<Map<String, dynamic>> rawList = await _service.getAllSummerCampers();
      return rawList.map((data) => SummerCamper.fromMap(data)).toList();
    } catch (e, stack) {
      _logError(e, stack);
      return [];
    }
  }

  Future<SummerCamper?> getSummerCamperById(String id) async {
    try {
      final data = await _service.getSummerCamper(id);
      if (data != null) {
        return SummerCamper.fromMap(data);
      }
      return null;
    } catch (e, stack) {
      _logError(e, stack);
      return null;
    }
  }

  Future<void> createSummerCamper(
      String nombre,
      String apellido,
      int edad,
      String monitor,
      ) async {
    try {
      await _service.createSummerCamper({
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'monitor': monitor,
      }, monitor);
    } catch (e, stack) {
      _logError(e, stack);
    }
  }

  Future<void> updateSummerCamper(
      String id,
      String nombre,
      String apellido,
      int edad,
      String monitor,
      ) async {
    try {
      await _service.updateSummerCamper(
        id,
        {
          'nombre': nombre,
          'apellido': apellido,
          'edad': edad,
          'monitor': monitor,
        },
        monitor,
      );
    } catch (e, stack) {
      _logError(e, stack);
      rethrow;
    }
  }

  Future<void> deleteSummerCamper(
      String id,
      BuildContext context,
      ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await _service.deleteSummerCamper(id);
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Alumno borrado correctamente.')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Error al borrar el alumno.')),
      );
      _logError(e);
    }
  }

  Future<void> updateAttendance(
      String estudianteId,
      String nombre,
      String apellido,
      bool asistio,
      DateTime selectedDate,
      ) async {
    try {
      final today = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final snapshot = await FirebaseService.getAsistenciaByEstudianteAndDay(estudianteId, today);

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await FirebaseService.updateAttendanceRecord(docId, asistio);
      } else {
        await FirebaseService.addAttendanceRecord(
          estudianteId,
          nombre,
          apellido,
          Timestamp.fromDate(today),
          asistio,
        );
      }
      statusMessage = "Asistencia actualizada correctamente.";
    } catch (e, stack) {
      statusMessage = "Error al actualizar asistencia: $e";
      _logError(e, stack);
    }
  }

  Stream<List<String>> getMonitorsStream() {
    return FirebaseService.getStreamUsuarios().map((snapshot) => snapshot.docs
        .where((doc) => doc['rol'] == 'Estandard')
        .map((doc) => '${doc['nombre']} ${doc['apellido']}')
        .toList());
  }

  Stream<List<SummerCamper>> getSummerCampersStream() {
    return FirebaseService.getStreamAlumnos().map(
            (snapshot) => snapshot.docs.map((doc) => SummerCamper.fromDocument(doc)).toList());
  }

  Future<String?> getMonitorForSummerCamper(String id) async {
    try {
      final data = await _service.getSummerCamper(id);
      return data?['monitor'] as String?;
    } catch (e, stack) {
      _logError(e, stack);
      return null;
    }
  }

  Future<bool> isDuplicateSummerCamper(
      String nombre,
      String apellido,
      int edad,
      ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('estudiantes')
          .where('nombre', isEqualTo: nombre)
          .where('apellido', isEqualTo: apellido)
          .where('edad', isEqualTo: edad)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e, stack) {
      _logError(e, stack);
      return false;
    }
  }

  void _logError(dynamic e, [StackTrace? stack]) {
    if (kDebugMode) {
      print('SummerCamperManager Error: $e\nStack trace: $stack');
    }
  }
}
