import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workgest/services/firebase_service.dart';

class MaterialManager {
  static Stream<QuerySnapshot> getMaterialStream() {
    return FirebaseService.getStreamMaterial();
  }

  static Future<void> updateMaterialAvailability(String id, int newAvailability) {
    return FirebaseService.updateMaterialAvailability(id, newAvailability);
  }
}