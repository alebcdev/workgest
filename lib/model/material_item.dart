import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialItem {
  String id;
  String name;
  String description;
  int quantity;

  MaterialItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
  });

  /// Crea un MaterialItem a partir de un DocumentSnapshot de Firestore
  factory MaterialItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MaterialItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      quantity: (data['quantity'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
    };
  }
}
