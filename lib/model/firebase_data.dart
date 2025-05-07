import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseData{

  static Stream<QuerySnapshot> getStreamUsuarios() =>
      FirebaseFirestore.instance
          .collection('usuarios')
          .orderBy('rol')
          .snapshots();

  static Stream<QuerySnapshot> getStreamAlumnos() =>
      FirebaseFirestore.instance.
      collection('estudiantes')
          .orderBy('edad')
          .snapshots();

  static Stream<QuerySnapshot> getStreamMaterial() =>
      FirebaseFirestore.instance
          .collection('material')
          .snapshots();

  static getAsistenciaByEstudianteAndDay(estudianteId, today) => FirebaseFirestore.instance
      .collection('asistencias')
      .where('estudianteId', isEqualTo: estudianteId)
      .where('fecha', isEqualTo: Timestamp.fromDate(today))
      .get();

  static Future<QuerySnapshot<Map<String, dynamic>>> getAsistenciaByDate(DateTime date) async {
    // Fetch the snapshot from Firestore based on the date
    return await FirebaseFirestore.instance
        .collection('asistencias')
        .where('fecha', isEqualTo: date)
        .get();
  }

  static getCSV() => FirebaseFirestore.instance.collection('settings').doc('csv_filepath').get();
}