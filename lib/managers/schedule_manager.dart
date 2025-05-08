import 'package:workgest/services/firebase_service.dart';
import 'package:workgest/model/schedule_item.dart';

/// Manager class for handling schedule related operations.
/// This class interacts with the FirebaseService to perform CRUD operations on schedules.
class ScheduleManager {

  ScheduleManager();
  /// Retrieves all schedules from Firebase.
  Future<List<Map<String, dynamic>>> getAllSchedules() async {
    try {
      return await FirebaseService.getAllSchedules();
    } catch (e) {
      _logError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Retrieves a specific schedule by its ID from Firebase.
  Future<ScheduleItem?> getScheduleById(String id) async {
    try {
      return await FirebaseService.getScheduleById(id);
    } catch (e) {
      _logError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Creates a new schedule in Firebase.
  Future<void> createSchedule(ScheduleItem schedule) async {
    try {
      await FirebaseService.createSchedule(schedule);
    } catch (e) {
      _logError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Updates an existing schedule in Firebase.
  Future<void> updateSchedule(ScheduleItem schedule) async {
    try {
      await FirebaseService.updateSchedule(schedule);
    } catch (e) {
      _logError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Deletes a schedule by its ID from Firebase.
  Future<void> deleteSchedule(String id) async {
    try {
      await FirebaseService.deleteSchedule(id);
    } catch (e) {
      _logError(e, StackTrace.current);
      rethrow;
    }
  }
}
