// lib/screens/weather_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:workgest/providers/weather_provider.dart';
import 'package:workgest/model/weather_data.dart';
import 'package:workgest/model/daily_forecast.dart';
import 'package:workgest/model/hourly_forecast.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _fetchWeather() {
    if (_cityController.text.isNotEmpty) {
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeather(_cityController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter City',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _fetchWeather(),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchWeather,
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  if (weatherProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (weatherProvider.errorMessage != null) {
                    return Center(
                      child: Text(
                        'Error: ${weatherProvider.errorMessage}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  } else if (weatherProvider.currentWeather != null ||
                      (weatherProvider.dailyForecasts != null &&
                          weatherProvider.dailyForecasts!.isNotEmpty) ||
                      (weatherProvider.hourlyForecasts != null &&
                          weatherProvider.hourlyForecasts!.isNotEmpty)) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Weather
                          if (weatherProvider.currentWeather != null)
                            CurrentWeatherCard(weather: weatherProvider.currentWeather!)
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: Text('No current weather data available.')),
                            ),
                          const SizedBox(height: 20),

                          // Hourly Forecast
                          if (weatherProvider.hourlyForecasts != null &&
                              weatherProvider.hourlyForecasts!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hourly Forecast:',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                HourlyForecastList(
                                  hourlyData: weatherProvider.hourlyForecasts!,
                                ),
                              ],
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: Text('No hourly forecast data available.')),
                            ),
                          const SizedBox(height: 20),

                          // Daily Forecast
                          if (weatherProvider.dailyForecasts != null &&
                              weatherProvider.dailyForecasts!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Forecast:',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: weatherProvider.dailyForecasts!.length,
                                  itemBuilder: (context, index) {
                                    final forecast = weatherProvider.dailyForecasts![index];
                                    final date = DateTime.fromMillisecondsSinceEpoch(forecast.dt * 1000).toLocal();
                                    final formattedDate = DateFormat('EEE, MMM d').format(date);

                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                                      elevation: 1.0,
                                      child: ListTile(
                                        leading: forecast.weather.isNotEmpty
                                            ? Image.network('http://openweathermap.org/img/w/${forecast.weather.first.icon}.png')
                                            : null,
                                        title: Text(formattedDate),
                                        subtitle: Text(
                                          'Min: ${forecast.temp.min.round()}°C, Max: ${forecast.temp.max.round()}°C',
                                        ),
                                        trailing: forecast.weather.isNotEmpty
                                            ? Text(forecast.weather.first.main)
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: Text('No daily forecast data available.')),
                            ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('Enter a city to get weather data.'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================
// Reusable Widget: Current Weather
// ==========================
class CurrentWeatherCard extends StatelessWidget {
  final WeatherData weather;

  const CurrentWeatherCard({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Weather in ${weather.cityName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Temperature: ${weather.main.temp.round()}°C'),
            if (weather.weather.isNotEmpty)
              Text('Conditions: ${weather.weather.first.description}'),
            const SizedBox(height: 8),
            Text('Humidity: ${weather.main.humidity}%'),
            Text('Wind Speed: ${weather.wind.speed.round()} m/s'),
          ],
        ),
      ),
    );
  }
}

// ==========================
// Reusable Widget: Hourly Forecast List
// ==========================
class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> hourlyData;

  const HourlyForecastList({Key? key, required this.hourlyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyData.length,
        itemBuilder: (context, index) {
          final forecast = hourlyData[index];
          final time = DateTime.fromMillisecondsSinceEpoch(forecast.dt * 1000).toLocal();
          final formattedTime = DateFormat('h a').format(time);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            elevation: 1.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(formattedTime),
                  const SizedBox(height: 4),
                  if (forecast.weather.isNotEmpty)
                    Image.network(
                      'http://openweathermap.org/img/w/${forecast.weather.first.icon}.png',
                      height: 30,
                    ),
                  const SizedBox(height: 4),
                  Text('${forecast.main.temp.round()}°C'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
