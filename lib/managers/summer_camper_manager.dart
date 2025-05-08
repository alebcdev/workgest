import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:workgest/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/summercamper_item.dart';

class SummerCamperManager {
  static String statusMessage = "";

  static bool validateFields(String nombre, String apellido, String? monitor) {
    if (nombre.isEmpty || apellido.isEmpty || monitor == null || monitor.isEmpty) {
      statusMessage = "Todos los campos son obligatorios.";
      return false;
    }
    return true;
  }

  static Future<List<SummerCamper>> getAllSummerCampers() async {
    try {
      final snapshot = await FirebaseService.getAllSummerCampers();
      return snapshot.docs.map((doc) => SummerCamper.fromDocument(doc)).toList();
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
      return [];
    }
  }

  static Future<SummerCamper?> getSummerCamperById(String id) async {
    try {
      final snapshot = await FirebaseService.getSummerCamperById(id);
      if (snapshot.exists) {
        return SummerCamper.fromDocument(snapshot);
      }
      return null;
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
      return null;
    }
  }

  static Future<void> createSummerCamper(
      String nombre, String apellido, int edad, String monitor) async {
    try {
      await FirebaseService.createSummerCamper({
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'monitor': monitor,
      });
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
    }
  }

  static Future<void> updateSummerCamper(
      String id, String nombre, String apellido, int edad, String monitor) async {
    try {
      await FirebaseService.updateSummerCamper(id, {
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'monitor': monitor,
      });
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
      rethrow;
    }
  }

  static void _logError(dynamic e, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('SummerCamperManager Error: $e\nStack trace: $stackTrace');
    }
  }

  static Future<void> deleteSummerCamper(
      DocumentSnapshot snapshot, BuildContext context) async {
    try {
      await FirebaseService.deleteSummerCamper(snapshot.reference);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alumno borrado correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al borrar el alumno.')),
      );
      _logError(e);
    }
  }

  static Future<void> updateAttendance(
      String estudianteId,
      String nombre,
      String apellido,
      bool asistio,
      DateTime selectedDate,
      ) async {
    try {
      final today = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final snapshot =
      await FirebaseService.getAsistenciaByEstudianteAndDay(estudianteId, today);

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
    } catch (e, stackTrace) {
      statusMessage = "Error al actualizar asistencia: $e";
      _logError(e, stackTrace);
    }
  }

  static Future<String?> getMonitor(User user) async {
    try {
      final role = await FirebaseService.getUserRoleByEmail(user.email ?? '');
      if (role == 'Estandard') {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('correo', isEqualTo: user.email)
            .limit(1)
            .get();
        if (userSnapshot.docs.isNotEmpty) {
          final data = userSnapshot.docs.first.data();
          return '${data['nombre']} ${data['apellido']}';
        }
      }
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
    }
    return null;
  }

  static Stream<List<String>> getMonitorsStream() {
    return FirebaseService.getStreamUsuarios().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc['rol'] == 'Estandard')
          .map((doc) => '${doc['nombre']} ${doc['apellido']}')
          .toList();
    });
  }

  static Future<String?> getMonitorForSummerCamper(String summerCamperId) async {
    try {
      final snapshot = await FirebaseService.getSummerCamper(summerCamperId);
      if (snapshot?.exists == true) {
        return snapshot?.data()?['monitor'] as String?;
      }
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
    }
    return null;
  }

  static Future<bool> isDuplicateSummerCamper(
      String nombre, String apellido, int edad) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('estudiantes')
          .where('nombre', isEqualTo: nombre)
          .where('apellido', isEqualTo: apellido)
          .where('edad', isEqualTo: edad)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e, stackTrace) {
      _logError(e, stackTrace);
      return false;
    }
  }

  static Stream<List<SummerCamper>> getSummerCampersStream() {
    return FirebaseService.getSummerCampersStream().map((snapshot) =>
        snapshot.docs.map((doc) => SummerCamper.fromDocument(doc)).toList());
  }

  static Stream<QuerySnapshot> getUsersStream() {
    return FirebaseService.getStreamUsuarios();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAttendanceByDate(DateTime date) {
    return FirebaseService.getAsistenciaByDate(date);
  }
}
