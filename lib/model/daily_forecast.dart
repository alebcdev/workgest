// lib/model/daily_forecast.dart

import 'weather_data.dart'; // Import Weather for forecast weather description

class DailyForecast {
  final int dt;
  final Temp temp;
  final List<Weather> weather; // Assuming daily forecast has weather descriptions

  DailyForecast({
    required this.dt,
    required this.temp,
    required this.weather,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      dt: json['dt'] as int,
      temp: Temp.fromJson(json['temp'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((i) => Weather.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Temp {
  final double day;
  final double min;
  final double max;
  // Add other temperature properties if they exist in the daily forecast API response

  Temp({
    required this.day,
    required this.min,
    required this.max,
  });

  factory Temp.fromJson(Map<String, dynamic> json) {
    return Temp(
      day: (json['day'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );
  }
}
