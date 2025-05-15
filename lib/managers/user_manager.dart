import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workgest/model/user_item.dart';
import 'package:workgest/services/firebase_service.dart';

class UserManager {
  static String statusMessage = "";
  final FirebaseService _firebaseService = FirebaseService();

  static bool validateFields(String name, String apellido, String email, String? password) {
    if (name.isEmpty || apellido.isEmpty || email.isEmpty) return false;
    if (password != null && password.length < 6) return false;
    if (!isValidEmail(email)) return false;
    return true;
  }

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w.%+-]+@[\w.-]+\.[A-Za-z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      return await FirebaseService.isEmailRegistered(email);
    } catch (e) {
      _logError(e, StackTrace.current);
      return true;
    }
  }

  Future<User?> signIn({ required String email, required String password }) {
    return FirebaseService.signInUsingEmailAndPass(
        email: email, password: password);
  }

  Future<User?> registerUser({
    required String name,
    required String apellido,
    required String email,
    required String password,
    required String rol,
  }) async {
    try {
      final user = await FirebaseService.signUpUsingEmailAndPass(
          name: name, email: email, password: password);
      if (user != null) {
        await _firebaseService.addUserData({
          'name': name,
          'apellido': apellido,
          'correo': email,
          'rol': rol,
        });
      }
      return user;
    } catch (e) {
      _logError(e, StackTrace.current);
      return null;
    }
  }

  Future<void> _assignNewMonitorToStudents(String monitorName) async {
    final studentsSnapshot = await FirebaseService.getStudentsWithoutMonitor();
    for (final doc in studentsSnapshot.docs) {
      await FirebaseService.updateSummerCamperMonitor(doc.reference, monitorName);
    }
  }

  Future<void> updateUser(
      UserItem user, {
        required String oldMonitorName,
        required String newMonitorName,
        User? firebaseUser,
      }) async {
    // Actualiza los datos del usuario
    await _firebaseService.updateUserData(user.id, user.toJson());

    // Si el tipo de monitor cambió, actualizar estudiantes
    if (oldMonitorName != newMonitorName) {
      await _deleteStudentsByMonitor(oldMonitorName);
      await _assignNewMonitorToStudents(newMonitorName);
    }
  }

  Future<void> deleteUserById(String userId, BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final user = await getUserById(userId);

      if (user == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Usuario no encontrado.')),
        );
        return;
      }

      await _firebaseService.deleteUserData(user.id);

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Usuario eliminado exitosamente.')),
      );

      navigator.pop(); // cerrar el diálogo si es llamado desde uno
    } catch (e) {
      _logError(e);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Error al eliminar el usuario.')),
      );
    }
  }



  Future<List<UserItem>> getAllUsers() async {
    // obtiene List<Map> de tu servicio
    final list = await _firebaseService.getAllUsers();
    return list.map((m) => UserItem.fromJson(m)).toList();
  }

  Future<UserItem?> getUserById(String id) async {
    final snap = await _firebaseService.getUserById(id);
    return snap.exists ? UserItem.fromSnapshot(snap) : null;
  }

  Future<UserItem?> findUserByEmail(String email) async {
    final snap = await _firebaseService.findUserByEmail(email);
    return snap.docs.isNotEmpty
        ? UserItem.fromSnapshot(snap.docs.first)
        : null;
  }

  static Future<void> _deleteStudentsByMonitor(String monitorName) async {
    final studentsSnapshot = await FirebaseService.getStudentsByMonitor(monitorName);
    for (final doc in studentsSnapshot.docs) {
      await FirebaseService.updateSummerCamperMonitor(doc.reference, ''); // o nuevo monitor
    }
  }


  static Future<String?> getUserRole(User user) async {
    return await FirebaseService.getUserRoleByEmail(user.email!);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static void _logError(dynamic e, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('UserManager Error: $e\nStack trace: $stackTrace');
    }
  }


}
