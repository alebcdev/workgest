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

  /// Obtiene todos los campers y los mapea a SummerCamper
  Future<List<SummerCamper>> getAllSummerCampers() async {
    try {
      // Servicio devuelve List<Map<String,dynamic>>
      final List<Map<String, dynamic>> rawList = await _service.getAllSummerCampers();
      return rawList.map((data) => SummerCamper.fromMap(data)).toList();
    } catch (e, stack) {
      _logError(e, stack);
      return [];
    }
  }

  /// Obtiene un camper por su ID
  Future<SummerCamper?> getSummerCamperById(String id) async {
    try {
      // Servicio devuelve Map<String,dynamic>?
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

  /// Crea un nuevo camper (mapa + group)
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
      }, monitor /* group */);
    } catch (e, stack) {
      _logError(e, stack);
    }
  }

  /// Actualiza un camper existente (id + mapa + group)
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

  /// Borra un camper por su ID
  Future<void> deleteSummerCamper(
      String id,
      BuildContext context,
      ) async {
    try {
      await _service.deleteSummerCamper(id);
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

  /// Actualiza asistencia de un alumno
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
    } catch (e, stack) {
      statusMessage = "Error al actualizar asistencia: $e";
      _logError(e, stack);
    }
  }

  /// Stream de monitores (texto)
  Stream<List<String>> getMonitorsStream() {
    return FirebaseService
        .getStreamUsuarios() // Stream<QuerySnapshot>
        .map((snapshot) => snapshot.docs
        .where((doc) => doc['rol'] == 'Estandard')
        .map((doc) => '${doc['nombre']} ${doc['apellido']}')
        .toList());
  }

  /// Stream de campers usando la colección 'estudiantes'
  Stream<List<SummerCamper>> getSummerCampersStream() {
    return FirebaseService
        .getStreamAlumnos() // Stream<QuerySnapshot>
        .map((snapshot) => snapshot.docs
        .map((doc) => SummerCamper.fromDocument(doc))
        .toList());
  }

  /// Obtiene el monitor asignado a un camper
  Future<String?> getMonitorForSummerCamper(String id) async {
    try {
      final data = await _service.getSummerCamper(id);
      return data?['monitor'] as String?;
    } catch (e, stack) {
      _logError(e, stack);
      return null;
    }
  }

  /// Consulta duplicados
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

  /// Logueo interno en debug
  void _logError(dynamic e, [StackTrace? stack]) {
    if (kDebugMode) {
      print('SummerCamperManager Error: $e\nStack trace: $stack');
    }
  }
}
