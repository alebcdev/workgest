
class UserItem{

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type,
    };
  }

}