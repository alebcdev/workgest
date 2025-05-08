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

  static Future<void> addSummerCamper(String nombre, String apellido, int edad, String monitor) async {
    await FirebaseFirestore.instance.collection('summercampers').add({
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'monitor': monitor,
    });
  }

  static Future<void> updateSummerCamper(String id, String nombre, String apellido, int edad, String monitor) async {
    await FirebaseFirestore.instance.collection('summercampers').doc(id).update({
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'monitor': monitor,
    });
  }

  static void _logError(dynamic e, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('SummerCamperManager Error: $e\nStack trace: $stackTrace');
    }
  }

  static Future<void> deleteStudent(DocumentSnapshot snapshot, BuildContext context) async {
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
      final snapshot = await FirebaseService.getAsistenciaByEstudianteAndDay(estudianteId, today);

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await FirebaseService.updateAttendanceRecord(docId, asistio);
      } else {
        await FirebaseService.addAttendanceRecord(estudianteId, nombre, apellido, Timestamp.fromDate(today), asistio);
      }
      statusMessage = "Asistencia actualizada correctamente.";
    } catch (e) {
      statusMessage = "Error al actualizar asistencia: $e";
      _logError(e);
    }
  }

  static Future<String?> getMonitor(User user) async {
    try {
      final role = await FirebaseService.getUserRoleByEmail(user.email ?? '');
      if (role != null && role == 'Estandard') {
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
    } catch (e) {
      _logError(e);
    }
    return null;
  }

  static Stream<List<String>> getMonitorsStream() {
    return FirebaseService.getStreamUsuarios().map((snapshot) {
      List<String> monitores = [];
      for (var doc in snapshot.docs) {
        if (doc['rol'] == 'Estandard') {
          monitores.add('${doc['nombre']} ${doc['apellido']}');
        }
      }
      return monitores;
    });
  }

  static Future<String?> getMonitorForSummerCamper(String summerCamperId) async {
    try {
      final snapshot = await FirebaseService.getSummerCamper(summerCamperId);
      if (snapshot.exists) {
        return snapshot.data()?['monitor'] as String?;
      }
      return null;
    } catch (e) {
      _logError(e);
      return null;
    }
  }

  static Future<bool> isDuplicateSummerCamper(String nombre, String apellido, int edad) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('estudiantes')
          .where('nombre', isEqualTo: nombre)
          .where('apellido', isEqualTo: apellido)
          .where('edad', isEqualTo: edad)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      _logError(e);
      return false;
    }
  }

  static Stream<List<SummerCamper>> getSummerCampersStream() {
    return FirebaseFirestore.instance
        .collection('estudiantes')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => SummerCamper.fromDocument(doc))
        .toList()
    );
  }

  static Stream<QuerySnapshot> getUsersStream() {
    return FirebaseService.getStreamUsuarios();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAttendanceByDate(DateTime date) {
    return FirebaseService.getAsistenciaByDate(date);
  }
}
