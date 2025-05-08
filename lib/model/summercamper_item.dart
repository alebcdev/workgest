import 'package:cloud_firestore/cloud_firestore.dart';

class SummerCamper {
  final String id;
  final String nombre;
  final int edad;
  final String group;

  SummerCamper({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.group, // Este campo se añadió como requerido
  });

  factory SummerCamper.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SummerCamper(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      edad: data['edad'] ?? 0,
      group: data['group'] ?? '', // Asegura valor por defecto
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'edad': edad,
      'group': group,
    };
  }
}
