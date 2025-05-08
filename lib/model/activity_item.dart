class ActivityItem {
  String id;
  String name;
  String description;

  ActivityItem({
    required this.id,
    required this.name,
    required this.description,
  });

  // Factory constructor to create an ActivityItem from JSON
  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  // Method to convert an ActivityItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }


}
