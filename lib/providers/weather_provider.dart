
// lib/providers/weather_provider.dart

import 'package:flutter/foundation.dart';
import 'package:workgest/model/weather_data.dart';
import 'package:workgest/model/daily_forecast.dart';
import 'package:workgest/model/hourly_forecast.dart';
import 'package:workgest/services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherData? _currentWeather;
  List<DailyForecast>? _dailyForecasts; // Correct type for daily forecast list
  List<HourlyForecast>? _hourlyForecasts; // State for hourly forecast list

  bool _isLoading = false;
  String? _errorMessage;

  WeatherData? get currentWeather => _currentWeather;
  List<DailyForecast>? get dailyForecasts => _dailyForecasts; // Getter for daily
  List<HourlyForecast>? get hourlyForecasts => _hourlyForecasts; // Getter for hourly

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch weather data by city name
  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    // Optionally clear previous data when fetching new data
    _currentWeather = null;
    _dailyForecasts = null;
    _hourlyForecasts = null;
    notifyListeners();

    try {
      final weatherData = await _weatherService.fetchWeatherByCity(city);

      if (weatherData != null) {
        // Safely cast the fetched data to the correct types
        _currentWeather = weatherData['current'] as WeatherData?;
        _hourlyForecasts = weatherData['hourly'] as List<HourlyForecast>?;
        _dailyForecasts = weatherData['daily'] as List<DailyForecast>?;

        _errorMessage = null; // Clear error on successful fetch
      } else {
        // Set state to null and show error if no data is returned
        _currentWeather = null;
        _hourlyForecasts = null;
        _dailyForecasts = null;
        _errorMessage = 'Could not fetch weather data for $city';
      }

      // Additional check to show a message if no data at all is available
      if (_currentWeather == null && (_dailyForecasts == null || _dailyForecasts!.isEmpty) && (_hourlyForecasts == null || _hourlyForecasts!.isEmpty)) {
        _errorMessage = 'No weather data found for $city';
      }


    } catch (e) {
      // Catch any errors during the process
      _currentWeather = null;
      _hourlyForecasts = null;
      _dailyForecasts = null;
      _errorMessage = 'Failed to fetch weather data: ${e.toString()}';
      if (kDebugMode) {
        print('Error fetching weather: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners when loading is complete or state changes
    }
  }

// You could add fetchWeatherByCoords here if you implement the onecall endpoint
}
