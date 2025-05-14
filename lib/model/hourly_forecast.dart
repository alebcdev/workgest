// lib/model/hourly_forecast.dart

import 'weather_data.dart'; // Import Weather and Main

class HourlyForecast {
  final int dt;
  final Main main; // Reuse Main for temperature/humidity at the hour
  final List<Weather> weather; // Assuming hourly items also have weather descriptions

  HourlyForecast({
    required this.dt,
    required this.main,
    required this.weather,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      dt: json['dt'] as int,
      main: Main.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((i) => Weather.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
