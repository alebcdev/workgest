class ScheduleItem {
  String id;
  String monitorId;
  String activityId;
  DateTime startTime;
  DateTime endTime;
  String group;              // ← nuevo campo

  ScheduleItem({
    required this.id,
    required this.monitorId,
    required this.activityId,
    required this.startTime,
    required this.endTime,
    required this.group,      // ← lo recibimos en el constructor
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as String,
      monitorId: json['monitor_id'] as String,
      activityId: json['activity_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      group: json['group'] as String? ?? '',  // ← lo parseamos (puede venir nulo)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monitor_id': monitorId,
      'activity_id': activityId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'group': group,                       // ← lo incluimos en el JSON
    };
  }
}
