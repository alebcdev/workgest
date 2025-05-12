import 'package:cloud_firestore/cloud_firestore.dart';

class SummerCamper {
  final String id;
  final String nombre;
  final String apellido;   // ← added
  final int edad;
  final String monitor;    // ← added
  final String group;

  SummerCamper({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.edad,
    required this.monitor,
    required this.group,
  });

  factory SummerCamper.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SummerCamper(
      id: doc.id,
      nombre: data['nombre']  ?? '',
      apellido: data['apellido'] ?? '',
      edad: data['edad']      ?? 0,
      monitor: data['monitor']?? '',
      group: data['group']    ?? '',
    );
  }

  factory SummerCamper.fromMap(Map<String, dynamic> m) {
    return SummerCamper(
      id: m['id'] as String? ?? '',
      nombre: m['nombre'] as String? ?? '',
      apellido: m['apellido'] as String? ?? '',
      edad: m['edad'] as int? ?? 0,
      monitor: m['monitor'] as String? ?? '',
      group: m['group'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'monitor': monitor,
      'group': group,
    };
  }
}
