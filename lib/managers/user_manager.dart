import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workgest/services/firebase_service.dart';
import 'package:flutter/material.dart';

class UserManager {
  static String statusMessage = "";

  static bool validateFields(String name, String apellido, String email, String? password) {
    if (name.isEmpty || apellido.isEmpty || email.isEmpty) {
      return false;
    }

    if (password != null && password.length < 6) {
      return false;
    }

    if (!isValidEmail(email)) {
      return false;
    }
    return true;
  }

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  static Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      return await FirebaseService.isEmailRegistered(email);
    } catch (e) {
      _logError(e, StackTrace.current);
      return true;
    }
  }

  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await FirebaseService.signInUsingEmailAndPass(
        email: email,
        password: password,
      );
    } catch (e) {
      _logError(e, StackTrace.current);
      return null;
    }
  }

  static Future<User?> registerUser({
    required String name,
    required String apellido,
    required String email,
    required String password,
    required String rol,
  }) async {
    try {
      User? user = await FirebaseService.signUpUsingEmailAndPass(
        name: name,
        email: email,
        password: password,
      );

      if (user != null) {
        await FirebaseService.addUserData({
          'nombre': name,
          'apellido': apellido,
          'correo': email,
          'rol': rol,
        });
        return user;
      }
      return null;
    } catch (e) {
      _logError(e, StackTrace.current);
      return null;
    }
  }

  static Future<void> updateUserData({
    required String docId,
    required String nombre,
    required String apellido,
    required String correo,
    required String rol,
    required String oldMonitorName,
    required String newMonitorName,
    required DocumentReference snapshotReference,
    String? newPassword,
    User? firebaseUser,
  }) async {
    try {
      await FirebaseService.updateUserData(snapshotReference, {
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'rol': rol,
      });

      if (firebaseUser != null && firebaseUser.email != correo) {
        await firebaseUser.verifyBeforeUpdateEmail(correo);
      }

      if (firebaseUser != null && newPassword != null && newPassword.isNotEmpty) {
        await firebaseUser.updatePassword(newPassword);
      }

      if (oldMonitorName != newMonitorName) {
        final students = await FirebaseService.getStudentsByMonitor(oldMonitorName);
        for (var doc in students.docs) {
          await FirebaseService.updateSummerCamperMonitor(doc.reference, newMonitorName);
        }
      }
    } catch (e) {
      statusMessage = "Error al actualizar usuario: $e";
      rethrow;
    }
  }

  static Future<void> deleteUser(DocumentSnapshot snapshot, BuildContext context) async {
    try {
      final adminsSnapshot = await FirebaseService.getAdminUsers();

      if (adminsSnapshot.docs.length == 1 && adminsSnapshot.docs.first.id == snapshot.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se puede borrar. Eres el último administrador.")),
        );
        return;
      }

      final String? rol = snapshot['rol'];

      if (rol == 'Estandard') {
        await _deleteStudentsByMonitor('${snapshot['nombre']} ${snapshot['apellido']}');
      }

      await FirebaseService.deleteUserData(snapshot.reference);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error eliminando el usuario")),
      );
      statusMessage = "Error deleting user: $e";
    }
  }

  static Future<void> _deleteStudentsByMonitor(String monitorName) async {
    final studentsSnapshot = await FirebaseService.getStudentsByMonitor(monitorName);
    for (final studentSnapshot in studentsSnapshot.docs) {
      await FirebaseService.deleteSummerCamperData(studentSnapshot.reference);
    }
  }

  static Future<String?> getUserRole(User user) async {
    return await FirebaseService.getUserRoleByEmail(user.email!);
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static void _logError(dynamic e, [StackTrace? stackTrace]) {
    print('UserManager Error: $e\nStack trace: $stackTrace');
  }
}
