import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/firebase_data.dart';

class UserViewModel {
  static String _statusMessage = "";

  static String get statusMessage => _statusMessage;

  static Future<String?> getUserRole(User user) async {
    String? userRol;
    await for (var snapshot in FirebaseData.getStreamUsuarios()) {
      for (var doc in snapshot.docs) {
        if (doc['correo'] == user.email) {
          userRol = doc['rol'];
          return userRol;
        }
      }
    }
    return userRol;
  }

  static Future<bool> isEmailAlreadyRegistered(String email) async {
    final result = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('correo', isEqualTo: email)
        .get();
    return result.docs.isNotEmpty;
  }

  static Future<void> updateData({
    required String nombre,
    required String apellido,
    required String correo,
    required String rol,
    required String oldMonitorName,
    required String newMonitorName,
    required DocumentReference snapshotReference,
  }) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(snapshotReference, {
          "nombre": nombre,
          "apellido": apellido,
          "correo": correo,
          "rol": rol,
        });
      });

      final estudiantesSnapshot = await FirebaseFirestore.instance
          .collection('estudiantes')
          .where('monitor', isEqualTo: oldMonitorName)
          .get();

      for (var doc in estudiantesSnapshot.docs) {
        await doc.reference.update({
          "monitor": newMonitorName,
        });
      }
    } catch (e) {
      print("Error updating data: $e");
      throw e;
    }
  }

  static Future<void> deleteUser(DocumentSnapshot snapshot, BuildContext context) async {
    try {
      QuerySnapshot adminsSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('rol', isEqualTo: 'Administrador')
          .get();

      if (adminsSnapshot.docs.length == 1 && adminsSnapshot.docs.first.id == snapshot.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se puede borrar. Eres el último administrador.")),
        );
      } else {
        String? rol = snapshot['rol'];

        if (rol == 'Estandard') {
          await _deleteStudentsByMonitor('${snapshot['nombre']} ${snapshot['apellido']}');
        }

        await FirebaseFirestore.instance.collection('usuarios').doc(snapshot.id).delete();

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.delete();
        }

        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error eliminando el usuario")),
      );
    }
  }

  static Future<void> _deleteStudentsByMonitor(String monitorName) async {
    QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance
        .collection('estudiantes')
        .where('monitor', isEqualTo: monitorName)
        .get();

    for (QueryDocumentSnapshot studentSnapshot in studentsSnapshot.docs) {
      await studentSnapshot.reference.delete();
    }
  }

  static bool validateFields(String nombre, String apellido, String email, String? password) {
    if (nombre.isEmpty || apellido.isEmpty || email.isEmpty) {
      _statusMessage = "Todos los campos son obligatorios.";
      return false;
    }

    if (!isValidEmail(email)) {
      _statusMessage = "El correo electrónico no tiene un formato válido.";
      return false;
    }

    if (password != null && password.isNotEmpty) {
      if (password.length < 10 ||
          !password.contains(RegExp(r'[A-Z]')) ||
          !password.contains(RegExp(r'[0-9]'))) {
        _statusMessage = "La contraseña debe tener al menos 10 caracteres, incluyendo mayúsculas, minúsculas y números.";
        return false;
      }
    }

    _statusMessage = "";
    return true;
  }

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

}