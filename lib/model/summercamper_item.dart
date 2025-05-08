import 'package:cloud_firestore/cloud_firestore.dart';

class SummerCamper {
  final String id;
  final String nombre;
  final String apellido;
  final int edad;
  final String monitor;

  SummerCamper({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.edad,
    required this.monitor,
  });

  factory SummerCamper.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SummerCamper(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      edad: data['edad'] ?? 0,
      monitor: data['monitor'] ?? '',
    );
  }
}
