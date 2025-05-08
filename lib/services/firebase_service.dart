import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign In
  static Future<User?> signInUsingEmailAndPass({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Usuario no encontrado');
      } else if (e.code == 'wrong-password') {
        print('Contraseña incorrecta');
      }
      return null;
    }
  }

  // Sign Up
  static Future<User?> signUpUsingEmailAndPass({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        return _auth.currentUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Warning: Weak password');
      } else if (e.code == 'email-already-in-use') {
        print('Email already in use');
      }
      return null;
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Streams
  static Stream<QuerySnapshot> getStreamUsuarios() =>
      FirebaseFirestore.instance.collection('usuarios').orderBy('rol').snapshots();

  static Stream<QuerySnapshot> getStreamAlumnos() =>
      FirebaseFirestore.instance.collection('estudiantes').orderBy('edad').snapshots();

  static Stream<QuerySnapshot> getStreamMaterial() =>
      FirebaseFirestore.instance.collection('material').snapshots();

  // Attendance queries
  static Future<QuerySnapshot> getAsistenciaByEstudianteAndDay(
      String estudianteId, DateTime today) =>
      FirebaseFirestore.instance
          .collection('asistencias')
          .where('estudianteId', isEqualTo: estudianteId)
          .where('fecha', isEqualTo: Timestamp.fromDate(today))
          .get();

  static Future<QuerySnapshot<Map<String, dynamic>>> getAsistenciaByDate(
      DateTime date) {
    final startOfDay =
    Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final endOfDay = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59));

    return FirebaseFirestore.instance
        .collection('asistencias')
        .where('fecha', isGreaterThanOrEqualTo: startOfDay)
        .where('fecha', isLessThanOrEqualTo: endOfDay)
        .get();
  }

  static Future<void> updateAttendanceRecord(String docId, bool asistio) async {
    await FirebaseFirestore.instance
        .collection('asistencias')
        .doc(docId)
        .update({'asistio': asistio});
  }

  static Future<void> addAttendanceRecord(
      String estudianteId,
      String nombre,
      String apellido,
      Timestamp fecha,
      bool asistio,
      ) async {
    await FirebaseFirestore.instance.collection('asistencias').add({
      'estudianteId': estudianteId,
      'nombre': nombre,
      'apellido': apellido,
      'fecha': fecha,
      'asistio': asistio,
    });
  }

  // Material update
  static Future<void> updateMaterialAvailability(
      String id, int newAvailability) async {
    await FirebaseFirestore.instance.collection('material').doc(id).update({
      'available': newAvailability,
    });
  }

  // User role
  static Future<String?> getUserRoleByEmail(String userEmail) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('correo', isEqualTo: userEmail)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first['rol'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role by email: $e');
      return null;
    }
  }

  // File upload
  static Future<String> uploadFileToStorage(
      List<int> fileBytes, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putData(Uint8List.fromList(fileBytes));
    final snapshot = await uploadTask.whenComplete(() {});
    return snapshot.ref.getDownloadURL();
  }

  // CSV config
  static Future<void> saveCsvFileUrl(String url) async {
    await FirebaseFirestore.instance.collection('config').doc('schedule').set({'url': url});
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getCsvFileUrl() async {
    return FirebaseFirestore.instance.collection('config').doc('schedule').get();
  }

  // Summer camper CRUD
  static Future<void> addSummerCamper(
      String nombre, String apellido, int edad, String monitor) async {
    await FirebaseFirestore.instance.collection('estudiantes').add({
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'monitor': monitor,
    });
  }

  static Future<void> updateSummerCamper(
      String id, String nombre, String apellido, int edad, String monitor) async {
    await FirebaseFirestore.instance.collection('estudiantes').doc(id).update({
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'monitor': monitor,
    });
  }

  static Future<void> deleteSummerCamper(DocumentReference ref) async {
    await ref.delete();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getSummerCamper(
      String summerCamperId) async {
    return FirebaseFirestore.instance.collection('estudiantes').doc(summerCamperId).get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getStudentByInfo(
      String nombre, String apellido, int edad) async {
    return FirebaseFirestore.instance
        .collection('estudiantes')
        .where('nombre', isEqualTo: nombre)
        .where('apellido', isEqualTo: apellido)
        .where('edad', isEqualTo: edad)
        .limit(1)
        .get();
  }

  static Future<void> deleteSummerCamperData(DocumentReference ref) async {
    await ref.delete();
  }

  static Stream<List<String>> getMonitorsStream() {
    return FirebaseFirestore.instance.collection('usuarios').snapshots().map((snapshot) =>
        snapshot.docs
            .where((doc) => doc['rol'] == 'Estandard')
            .map((doc) => '${doc['nombre']} ${doc['apellido']}')
            .toList());
  }

  // User CRUD
  static Future<void> addUserData(Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance.collection('usuarios').add(userData);
  }

  static Future<void> updateUserData(
      DocumentReference userRef, Map<String, dynamic> userData) async {
    await userRef.update(userData);
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAdminUsers() async {
    return FirebaseFirestore.instance
        .collection('usuarios')
        .where('rol', isEqualTo: 'Admin')
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getStudentsByMonitor(
      String monitorName) async {
    return FirebaseFirestore.instance
        .collection('estudiantes')
        .where('monitor', isEqualTo: monitorName)
        .get();
  }

  static Future<void> updateSummerCamperMonitor(
      DocumentReference summerCamperRef, String newMonitorName) async {
    await FirebaseFirestore.instance
        .collection('estudiantes')
        .doc(summerCamperRef.id)
        .update({'monitor': newMonitorName});
  }

  static Future<void> deleteUserData(DocumentReference userRef) async {
    await FirebaseFirestore.instance.collection('usuarios').doc(userRef.id).delete();
  }

  // Modern email protection: avoid fetchSignInMethodsForEmail
  // Instead, check existence via Firestore
  static Future<bool> isEmailInUsuariosCollection(String email) async {
    final result = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('correo', isEqualTo: email)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  static Future<bool> isEmailRegistered(String email) async {
    // Alias for isEmailInUsuariosCollection
    return isEmailInUsuariosCollection(email);
  }

  // Try sign in for security-safe check (no enumeration)
  static Future<bool> trySignInToCheckEmail(
      String email, String dummyPassword) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: dummyPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return false;
      }
      rethrow;
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
