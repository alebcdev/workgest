import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workgest/services/firebase_service.dart';
import 'package:workgest/model/material_item.dart';

class MaterialManager {
  static Stream<QuerySnapshot> getMaterialStream() {
    return FirebaseService.getStreamMaterial();
  }

  static Future<List<MaterialItem>> getAllMaterials() async {
    QuerySnapshot snapshot = await FirebaseService().getAllMaterials();
    return snapshot.docs.map((doc) => MaterialItem.fromDocument(doc)).toList();
  }

  static Future<MaterialItem?> getMaterialById(String id) async {
    DocumentSnapshot doc = await FirebaseService().getMaterialById(id);
    return doc.exists ? MaterialItem.fromDocument(doc) : null;
  }

  static Future<void> createMaterial(MaterialItem material) {
    return FirebaseService().createMaterial(material.toJson());
  }

  static Future<void> updateMaterial(MaterialItem material) {
    return FirebaseService().updateMaterial(material.id, material.toJson());
  }

  static Future<void> deleteMaterial(String id) {
    return FirebaseService().deleteMaterial(id);
  }

  static Future<void> updateMaterialAvailability(String id, int newAvailability){
    return FirebaseService.updateMaterialAvailability(id, newAvailability);
  }

  static Future<void> addOrUpdateMaterial(String? id, String name, String description, int quantity) {
    final material = MaterialItem(
      id: id ?? '', // Provide an empty string if id is null
      name: name,
      description: description,
      quantity: quantity,
    );
    if (id == null) {
      return FirebaseService().createMaterial(material.toJson());
    } else {
      return FirebaseService().updateMaterial(id, material.toJson());
    }
  }
}