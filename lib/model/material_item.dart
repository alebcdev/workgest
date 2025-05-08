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

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
    };
  }
}
