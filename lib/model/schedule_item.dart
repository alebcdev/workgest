class ScheduleItem {
  String id;
  String monitorId;
  String activityId;
  DateTime startTime;
  DateTime endTime;

  ScheduleItem({
    required this.id,
    required this.monitorId,
    required this.activityId,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'],
      monitorId: json['monitor_id'],
      activityId: json['activity_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monitor_id': monitorId,
      'activity_id': activityId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };
  }
}
