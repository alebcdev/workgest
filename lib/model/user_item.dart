import 'package:cloud_firestore/cloud_firestore.dart';

class UserItem {
  String id;
  String name;
  String email;
  String type;

  UserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
  });

  /// Crea un UserItem a partir de un DocumentSnapshot de Firestore
  factory UserItem.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return UserItem(
      id: snap.id,
      name: data['name'] ?? '',
      email: data['correo'] ?? '',
      type: data['rol'] ?? data['type'] ?? '',
    );
  }

  /// Crea un UserItem a partir de un Map (por ejemplo, en listados)
  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'correo': email,
      'rol': type,
    };
  }
}
