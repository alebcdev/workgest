import 'package:flutter/foundation.dart';
import 'package:workgest/model/weather_item.dart';

class WeatherProvider with ChangeNotifier {
  WeatherItem? currentWeather;

  void updateWeather(WeatherItem weather) {
    currentWeather = weather;
    notifyListeners();
  }
}