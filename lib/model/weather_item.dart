class WeatherItem {
  final String id;
  final String city;
  final double temperature;
  final String description;

  WeatherItem({
    required this.id,
    required this.city,
    required this.temperature,
    required this.description,
  });

  // Factory constructor to create a WeatherItem from JSON
  factory WeatherItem.fromJson(Map<String, dynamic> json) {
    return WeatherItem(
      id: json['id'],
      city: json['city'],
      temperature: json['temperature'].toDouble(),
      description: json['description'],
    );
  }

  // Method to serialize WeatherItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'temperature': temperature,
      'description': description,
    };
  }
}
