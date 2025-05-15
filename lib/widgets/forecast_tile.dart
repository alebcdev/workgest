import 'package:flutter/material.dart';
import '../model/daily_forecast.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class ForecastTile extends StatelessWidget {
  final DailyForecast dailyForecast; // Expect a DailyForecast object

  const ForecastTile({super.key, required this.dailyForecast});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('EEE').format(DateTime.fromMillisecondsSinceEpoch(dailyForecast.dt * 1000)),
              // dailyForecast.dayOfWeek ?? 'N/A', // Assuming dayOfWeek property exists
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              getWeatherIcon(dailyForecast.weather.isNotEmpty ? dailyForecast.weather[0].icon : ''), // Get the weather icon
              color: colorScheme.primary,
              semanticLabel: dailyForecast.weather.isNotEmpty ? dailyForecast.weather[0].description : 'Weather icon',
              // semanticLabel: dailyForecast.description ?? 'Weather icon', // Assuming description property exists
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${dailyForecast.temp.min.toStringAsFixed(0)}° / ${dailyForecast.temp.max.toStringAsFixed(0)}°',
              style: textTheme.bodyLarge?.copyWith(
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to map OpenWeatherMap icon codes to Flutter IconData
  // You'll need to expand this to cover all possible icon codes.
  IconData getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': return Icons.wb_sunny; // clear sky day
      case '01n': return Icons.nightlight_round; // clear sky night
      case '02d': case '02n': return Icons.cloud; // few clouds
    // Add more cases for other icon codes as needed
      default: return Icons.cloud; // default to cloud icon
    }
  }
}