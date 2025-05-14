import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:workgest/model/weather_data.dart';
import 'package:workgest/model/daily_forecast.dart';
import 'package:workgest/model/hourly_forecast.dart';

class WeatherService {
  final String _apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Fetches current weather data by city name
  Future<WeatherData?> getCurrentWeather(String city) async {
    if (_apiKey.isEmpty) {
      print('OpenWeatherMap API key not found in environment variables.');
      return null;
    }

    final url =
        Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        print('Failed to load current weather data: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching current weather: $e');
      return null;
    }
  }

  // Fetches 5-day / 3-hour forecast data (using 'forecast' endpoint)
  Future<List<HourlyForecast>> getHourlyForecast(String city) async {
    if (_apiKey.isEmpty) {
      print('OpenWeatherMap API key not found in environment variables.');
      return [];
    }

    final url =
        Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> forecastList = data['list'];
        return forecastList
            .map(
                (item) => HourlyForecast.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('Failed to load hourly forecast data: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching hourly forecast: $e');
      return [];
    }
  }

  // Processes a list of hourly forecasts to create a list of daily forecasts
  List<DailyForecast> processHourlyToDaily(List<HourlyForecast> hourlyData) {
    if (hourlyData.isEmpty) return [];

    Map<String, List<HourlyForecast>> groupedByDay = {};
    for (var item in hourlyData) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(item.dt * 1000).toLocal();
      final dateKey = "${date.year}-${date.month}-${date.day}";
      groupedByDay.putIfAbsent(dateKey, () => []).add(item);
    }

    List<DailyForecast> dailyForecasts = [];
    groupedByDay.forEach((dateKey, hourlies) {
      if (hourlies.isNotEmpty) {
        // Simple aggregation: find min/max temp and use a representative timestamp/weather
        final firstHour = hourlies.first;
        double minTemp =
            hourlies.map((h) => h.main.tempMin).reduce((a, b) => a < b ? a : b);
        double maxTemp =
            hourlies.map((h) => h.main.tempMax).reduce((a, b) => a > b ? a : b);

        // Taking the weather from the first entry of the day for simplicity
        List<Weather> dailyWeather = firstHour.weather;

        dailyForecasts.add(DailyForecast(
            dt: firstHour.dt,
            // Use first hour's timestamp for the day
            temp: Temp(day: firstHour.main.temp, min: minTemp, max: maxTemp),
            // Use first hour's temp for 'day' field, and calculated min/max
            weather: dailyWeather));
      }
    });

    dailyForecasts.sort((a, b) => a.dt.compareTo(b.dt)); // Sort by date
    return dailyForecasts;
  }

  // A combined fetch function using city name
  Future<Map<String, dynamic>?> fetchWeatherByCity(String city) async {
    WeatherData? current = await getCurrentWeather(city);
    List<HourlyForecast> hourly = await getHourlyForecast(city);

    if (current == null && hourly.isEmpty) return null;

    // Process hourly data into daily forecasts
    List<DailyForecast> daily = processHourlyToDaily(hourly);

    // Return a map containing all fetched data types
    return {
      'current': current,
      'hourly': hourly,
      'daily': daily,
    };
  }

// You could add a similar function using the 'onecall' endpoint if you have lat/lon
// Future<Map<String, dynamic>?> fetchWeatherByCoords(double lat, double lon) async { ... }
}
