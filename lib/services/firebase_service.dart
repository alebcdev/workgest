import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  // --------------------- Auth ---------------------
  static Future<User> signInUsingEmailAndPass({
    required String email,
    required String password,
  }) async {
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw Exception("No se pudo iniciar sesión. Usuario no encontrado.");
      }

      final userDocRef = firestore.collection('usuarios').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        await userDocRef.set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': user.uid,
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuario no encontrado');
        case 'wrong-password':
          throw Exception('Contraseña incorrecta');
        case 'invalid-email':
          throw Exception('Correo inválido');
        default:
          throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }


  static Future<User?> signUpUsingEmailAndPass({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final _auth = FirebaseAuth.instance;
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();

        // Crear perfil del usuario en Firestore
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'name': name,
          'email': email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return _auth.currentUser;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Contraseña débil');
      } else if (e.code == 'email-already-in-use') {
        print('El correo ya está en uso');
      } else {
        print('Auth error: ${e.message}');
      }
      return null;
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // --------------------- Streams ---------------------
  static Stream<QuerySnapshot> getStreamUsuarios() =>
      FirebaseFirestore.instance.collection('usuarios').orderBy('rol').snapshots();

  static Stream<QuerySnapshot> getStreamAlumnos() =>
      FirebaseFirestore.instance.collection('estudiantes').orderBy('edad').snapshots();

  static Stream<QuerySnapshot> getStreamMaterial() =>
      FirebaseFirestore.instance.collection('material').snapshots();

  // --------------------- Asistencia ---------------------
  static Future<void> updateAttendanceRecord(String docId, bool asistio) async {
    await FirebaseFirestore.instance.collection('asistencias').doc(docId).update({'asistio': asistio});
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

  static Future<QuerySnapshot> getAsistenciaByEstudianteAndDay(String estudianteId, DateTime today) {
    return FirebaseFirestore.instance
        .collection('asistencias')
        .where('estudianteId', isEqualTo: estudianteId)
        .where('fecha', isEqualTo: Timestamp.fromDate(today))
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAsistenciaByDate(DateTime date) {
    return FirebaseFirestore.instance
        .collection('asistencias')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59)))
        .get();
  }

  // --------------------- Material ---------------------
  static Future<void> updateMaterialAvailability(String id, int newAvailability) async {
    await FirebaseFirestore.instance.collection('material').doc(id).update({
      'available': newAvailability,
    });
  }

  // --------------------- Usuarios ---------------------
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

  // --------------------- Upload CSV / Files ---------------------
  static Future<String> uploadFileToStorage(List<int> fileBytes, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putData(Uint8List.fromList(fileBytes));
    final snapshot = await uploadTask.whenComplete(() {});
    return snapshot.ref.getDownloadURL();
  }

  static Future<void> saveCsvFileUrl(String url) async {
    await FirebaseFirestore.instance.collection('config').doc('schedule').set({'url': url});
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getCsvFileUrl() async {
    return FirebaseFirestore.instance.collection('config').doc('schedule').get();
  }

  // --------------------- Estudiantes ---------------------
  static Future<void> addSummerCamper(String nombre, String apellido, int edad, String monitor) async {
    await FirebaseFirestore.instance.collection('estudiantes').add({
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'monitor': monitor,
    });
  }

  Future<void> createSummerCamper(Map<String, dynamic> summerCamperData, String group) async {
    await FirebaseFirestore.instance.collection('estudiantes').add({
      ...summerCamperData,
      'group': group,
    });
  }

  Future<Map<String, dynamic>?> getSummerCamper(String id) async {
    final doc = await FirebaseFirestore.instance.collection('estudiantes').doc(id).get();
    return doc.data();
  }

  Future<void> updateSummerCamper(String id, Map<String, dynamic> data, String group) async {
    await FirebaseFirestore.instance.collection('estudiantes').doc(id).update({
      ...data,
      'group': group,
    });
  }

  Future<void> deleteSummerCamper(String id) async {
    await FirebaseFirestore.instance.collection('estudiantes').doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getAllSummerCampers() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('estudiantes').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getStudentsByMonitor(String monitorName) async {
    return FirebaseFirestore.instance.collection('estudiantes').where('monitor', isEqualTo: monitorName).get();
  }

  static Future<void> updateSummerCamperMonitor(DocumentReference ref, String newMonitor) async {
    await ref.update({'monitor': newMonitor});
  }

  // --------------------- Schedule ---------------------
  Future<void> createSchedule(Map<String, dynamic> data, String group) async {
    await FirebaseFirestore.instance.collection('schedules').add({
      ...data,
      'group': group,
    });
  }

  Future<void> updateSchedule(String id, Map<String, dynamic> data, String group) async {
    await FirebaseFirestore.instance.collection('schedules').doc(id).update({
      ...data,
      'group': group,
    });
  }

  Future<void> deleteSchedule(String id) async {
    await FirebaseFirestore.instance.collection('schedules').doc(id).delete();
  }

  Future<Map<String, dynamic>?> getSchedule(String id) async {
    final doc = await FirebaseFirestore.instance.collection('schedules').doc(id).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getAllSchedules() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('schedules').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  static Stream<List<String>> getMonitorsStream() {
    return FirebaseFirestore.instance.collection('usuarios').snapshots().map((snapshot) =>
        snapshot.docs.where((doc) => doc['rol'] == 'Estandard').map((doc) => '${doc['nombre']} ${doc['apellido']}').toList());
  }

  // --------------------- Usuarios ---------------------
  Future<void> createUser(Map<String, dynamic> data, String group) async {
    await FirebaseFirestore.instance.collection('usuarios').add({
      ...data,
      'group': group,
    });
  }

  Future<void> updateUser(String id, Map<String, dynamic> data, String group) async {
    await FirebaseFirestore.instance.collection('usuarios').doc(id).update({
      ...data,
      'group': group,
    });
  }

  Future<void> deleteUser(String id) async {
    await FirebaseFirestore.instance.collection('usuarios').doc(id).delete();
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(id).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('usuarios').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAdminUsers() async {
    return FirebaseFirestore.instance.collection('usuarios').where('rol', isEqualTo: 'Admin').get();
  }

  static Future<bool> isEmailInUsuariosCollection(String email) async {
    final result = await FirebaseFirestore.instance.collection('usuarios').where('correo', isEqualTo: email).limit(1).get();
    return result.docs.isNotEmpty;
  }

  static Future<bool> isEmailRegistered(String email) async {
    return isEmailInUsuariosCollection(email);
  }

  static Future<bool> trySignInToCheckEmail(String email, String dummyPassword) async {
    final _auth = FirebaseAuth.instance;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: dummyPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return false;
      }
      rethrow;
    }
  }

  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  // MATERIAL CRUD

  /// Obtiene todos los materiales
  Future<QuerySnapshot> getAllMaterials() {
    return firestore.collection('material').get();
  }

  /// Obtiene un material por su ID
  Future<DocumentSnapshot> getMaterialById(String id) {
    return firestore.collection('material').doc(id).get();
  }

  /// Crea un nuevo material
  Future<void> createMaterial(Map<String, dynamic> data) {
    return firestore.collection('material').add(data);
  }

  /// Actualiza un material existente
  Future<void> updateMaterial(String id, Map<String, dynamic> data) {
    return firestore.collection('material').doc(id).update(data);
  }

  /// Elimina un material
  Future<void> deleteMaterial(String id) {
    return firestore.collection('material').doc(id).delete();
  }

  // ——— Usuarios CRUD ———

  /// Añade un nuevo usuario (usa el mismo método que createUser si quieres)
  Future<void> addUserData(Map<String, dynamic> data) {
    return firestore.collection('usuarios').add(data);
  }

  /// Actualiza datos de un usuario por su ID
  Future<void> updateUserData(String id, Map<String, dynamic> data) {
    return firestore.collection('usuarios').doc(id).update(data);
  }

  /// Obtiene el documento de un usuario por su ID
  Future<DocumentSnapshot> getUserById(String id) {
    return firestore.collection('usuarios').doc(id).get();
  }

  /// Elimina un usuario por su ID
  Future<void> deleteUserData(String id) {
    return firestore.collection('usuarios').doc(id).delete();
  }

  /// Busca usuarios por correo (retorna QuerySnapshot)
  Future<QuerySnapshot> findUserByEmail(String email) {
    return firestore
        .collection('usuarios')
        .where('correo', isEqualTo: email)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getStudentsWithoutMonitor() async {
    return FirebaseFirestore.instance
        .collection('estudiantes')
        .where('monitor', isEqualTo: '')
        .get();
  }

}
