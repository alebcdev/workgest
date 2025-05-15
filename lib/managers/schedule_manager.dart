import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:workgest/services/firebase_service.dart';
import 'package:workgest/model/schedule_item.dart';

/// Manager class for handling schedule related operations.
/// This class interacts with the FirebaseService to perform CRUD operations on schedules.
/// Manager class for handling schedule related operations.
class ScheduleManager {
  final FirebaseService _service = FirebaseService();

  void _logError(dynamic e, StackTrace stack) {
    if (kDebugMode) {
      print('ScheduleManager Error: $e\nStack: $stack');
    }
  }

  /// Retrieves the role of a given Firebase user.
  static Future<String?> getUserRole(User user) {
    return FirebaseService.getUserRoleByEmail(user.email!);
  }

  Future<List<ScheduleItem>> getAllSchedules() async {
    try {
      final List<Map<String, dynamic>> rawList = await _service.getAllSchedules();
      return rawList.map((json) => ScheduleItem.fromJson(json)).toList();
    } catch (e, stack) {
      _logError(e, stack);
      rethrow;
    }
  }

  /// Retrieves a specific schedule by its ID from Firebase.
  Future<ScheduleItem?> getScheduleById(String id) async {
    try {
      // getSchedule(String) devuelve un Map<String, dynamic>?
      final Map<String, dynamic>? json = await _service.getSchedule(id);
      if (json != null) {
        return ScheduleItem.fromJson(json);
      }
      return null;
    } catch (e, stack) {
      _logError(e, stack);
      rethrow;
    }
  }

  /// Creates a new schedule in Firebase.
  Future<void> createSchedule(ScheduleItem schedule) async {
    try {
      // createSchedule(Map, String) espera dos parámetros
      await _service.createSchedule(schedule.toJson(), schedule.group);
    } catch (e, stack) {
      _logError(e, stack);
      rethrow;
    }
  }

  /// Updates an existing schedule in Firebase.
  Future<void> updateSchedule(ScheduleItem schedule) async {
    try {
      // updateSchedule(String id, Map, String group)
      await _service.updateSchedule(
        schedule.id,
        schedule.toJson(),
        schedule.group,
      );
    } catch (e, stack) {
      _logError(e, stack);
      rethrow;
    }
  }

  /// Deletes a schedule by its ID from Firebase.
  Future<void> deleteSchedule(String id) async {
    try {
      await _service.deleteSchedule(id);
    } catch (e, stack) {
      _logError(e, stack);
      rethrow;
    }
  }
}
