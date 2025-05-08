import 'package:weather/weather.dart';

class WeatherViewModel {
  final WeatherFactory _weatherFactory;
  Future<List<Weather>>? weatherFuture;
  String city = 'Santa Pola';

  WeatherViewModel(this._weatherFactory) {
    fetchWeather();
  }

  void fetchWeather() {
    weatherFuture = _weatherFactory.fiveDayForecastByCityName(city);
  }

  void setCity(String newCity) {
    city = newCity;
    fetchWeather();
  }
}