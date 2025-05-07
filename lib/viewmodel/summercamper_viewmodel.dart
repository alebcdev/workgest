import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workgest/model/firebase_data.dart';
import 'package:flutter/material.dart';

class SummerCamperViewModel{

  static String _statusMessage = "";

  static String get statusMessage => _statusMessage;

  Future<List<String>> getMonitoresList() async {
    try {
      var data;
      final usuarios = await FirebaseData.getStreamUsuarios();
      usuarios.forEach((usuario) {
        data= usuario.docs;
      });

      List<String> monitores = [];
      for (var doc in data) {
        if (doc['rol'] == 'Estandard') {
          monitores.add('${doc['nombre']} ${doc['apellido']}');
        }
      }

      return monitores;
    } catch (e) {
      print('Error obteniendo la lista de monitores: $e');
      return [];
    }
  }

  static Future<String?> getMonitor(User user) async {
    String? monitor;
    await for (var snapshot in FirebaseData.getStreamUsuarios()) {
      for (var doc in snapshot.docs) {
        if (doc['correo'] == user.email) {
          monitor = doc['nombre']+' '+doc['apellido'];
          return monitor;
        }
      }
    }
    return monitor;
  }

  static Future<bool> isDuplicateSummerCamper(String nombre, String apellido, int edad) async {
    final result = await FirebaseFirestore.instance
        .collection('estudiantes')
        .where('nombre', isEqualTo: nombre)
        .where('apellido', isEqualTo: apellido)
        .where('edad', isEqualTo: edad)
        .get();

    return result.docs.isNotEmpty;
  }

  static bool validateFields(String nombre, String apellido, String? monitor) {
    if (nombre.isEmpty || apellido.isEmpty || monitor == null) {
      _statusMessage = "Todos los campos son obligatorios.";
      return false;
    }

    _statusMessage = "";
    return true;
  }

  static Future<void> deleteStudent(DocumentSnapshot snapshot, BuildContext context) async {
    FirebaseFirestore.instance.collection('estudiantes').doc(snapshot.id).delete().then((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alumno borrado correctamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al borrar el alumno.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}