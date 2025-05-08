import 'package:firebase_auth/firebase_auth.dart';
import 'package:workgest/model/user_item.dart';
import 'package:workgest/services/firebase_service.dart';
import 'package:flutter/material.dart';

class UserManager {
  final FirebaseService _firebaseService = FirebaseService();
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
          'name': name,
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

  Future<void> updateUser(
      UserItem user, {
        required String oldMonitorName,
        required String newMonitorName,
        User? firebaseUser,
      }) async {
    try {
      await _firebaseService.updateUserData(user.id, {
        'name': user.name,
        'email': user.email,
        'type': user.type,
      });

      if (firebaseUser != null && firebaseUser.email != user.email) {
        try {
          await firebaseUser.verifyBeforeUpdateEmail(user.email);
        } catch (e) {
          statusMessage = "Error updating email: $e";
          rethrow;
        }
      }

      if (oldMonitorName != newMonitorName) {
        final students = await FirebaseService.getStudentsByMonitor(oldMonitorName);
        for (var doc in students.docs) {
          await FirebaseService.updateSummerCamperMonitor(doc.reference, newMonitorName);
        }
      }
    } catch (e) {
      statusMessage = "Error updating user: $e";
      rethrow;
    }
  }

  Future<void> deleteUser(UserItem user, BuildContext context) async {
    try {
      final adminsSnapshot = await FirebaseService.getAdminUsers();

      if (adminsSnapshot.docs.length == 1 && adminsSnapshot.docs.first.id == user.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se puede borrar. Eres el último administrador.")),
        );
        return;
      }

      final String? rol = user.type;

      if (rol == 'Estandard') {
        final snapshot = await _firebaseService.getUserById(user.id);
        await _deleteStudentsByMonitor('${snapshot['nombre']} ${snapshot['apellido']}');
      }

      await _firebaseService.deleteUserData(user.id);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error eliminando el usuario")),
      );
      _logError(e, StackTrace.current);
    }
  }

  static Future<void> _deleteStudentsByMonitor(String monitorName) async {
    final studentsSnapshot = await FirebaseService.getStudentsByMonitor(monitorName);
    for (final studentSnapshot in studentsSnapshot.docs) {
      await UserManager()._firebaseService.deleteSummerCamperData(studentSnapshot.reference);
    }
  }

  Future<List<UserItem>> getAllUsers() async {
    final snapshot = await _firebaseService.getAllUsers();
    return snapshot.docs.map((doc) => UserItem.fromSnapshot(doc)).toList();
  }

  Future<UserItem?> getUserById(String id) async {
    final snapshot = await _firebaseService.getUserById(id);
    if (snapshot.exists) {
      return UserItem.fromSnapshot(snapshot);
    } else {
      statusMessage = "User not found";
      _logError("User with ID $id not found", StackTrace.current);
      return null;
    }
  }

  static Future<String?> getUserRole(User user) async {
    return await FirebaseService.getUserRoleByEmail(user.email!);
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<UserItem?> findUserByEmail(String email) async {
    final snapshot = await _firebaseService.findUserByEmail(email);
    if (snapshot.docs.isNotEmpty) {
      return UserItem.fromSnapshot(snapshot.docs.first);
    } else {
      statusMessage = "User with email $email not found";
      _logError("User with email $email not found", StackTrace.current);
      return null;
    }
  }

  static void _logError(dynamic e, [StackTrace? stackTrace]) {
    print('UserManager Error: $e\nStack trace: $stackTrace');
  }
}
