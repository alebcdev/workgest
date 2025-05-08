class MonitorItem {
  String id;
  String name;
  String userId;
  String group;

  MonitorItem({
    required this.id,
    required this.name,
    required this.userId,
    required this.group, // Añadido
  });

  factory MonitorItem.fromJson(Map<String, dynamic> json) {
    return MonitorItem(
      id: json['id'],
      name: json['name'],
      userId: json['userId'],
      group: json['group'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'group': group,
    };
  }
}
