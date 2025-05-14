
// lib/model/weather_data.dart

class WeatherData {
  final String cityName;
  final Main main;
  final List<Weather> weather;
  final Wind wind;
  // Removed daily and hourly lists as this model is for current weather


  WeatherData({
    required this.cityName,
    required this.main,
    required this.weather,
    required this.wind,
  });


  factory WeatherData.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('name')) {
      throw const FormatException('Invalid JSON format for current weather data.');
    }
    return WeatherData(
      cityName: json['name'] as String,
      main: Main.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((i) => Weather.fromJson(i as Map<String, dynamic>))
          .toList(),
      wind: Wind.fromJson(json['wind'] as Map<String, dynamic>),
    );
  }
}

// Reused helper models for current weather
class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'] as int,
      main: json['main'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }
}

class Main {
  final double temp;
  final double feelsLike;
  final int humidity;
  // Added other common main properties
  final double tempMin;
  final double tempMax;
  final int pressure;

  Main({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
  });

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: (json['temp'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      humidity: json['humidity'] as int,
      tempMin: (json['temp_min'] as num).toDouble(),
      tempMax: (json['temp_max'] as num).toDouble(),
      pressure: json['pressure'] as int,
    );
  }
}

class Wind {
  final double speed;
  // Added other common wind properties
  final int deg;

  Wind({required this.speed, required this.deg});

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: (json['speed'] as num).toDouble(),
      deg: json['deg'] as int,
    );
  }
}
