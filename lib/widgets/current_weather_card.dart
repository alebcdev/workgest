import 'package:flutter/material.dart';
import '../model/weather_data.dart'; // Import the correct model

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.weather,
  });
  // Change the type from WeatherItem to WeatherData
  final WeatherData weather;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // Use cityName from WeatherData
              weather.cityName,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder for weather icon (replace with actual icon implementation)
                // Wrap Icon with Semantics for accessibility
                Semantics(
                  label: weather.weather.isNotEmpty ? weather.weather.first.description : 'Weather icon', // Use description from the first Weather object for semantic label
                  child: Icon(
                    // TODO: Implement a function to map OpenWeatherMap icon codes to Flutter IconData
                    Icons.cloud, // Use a placeholder icon for now
                    size: screenWidth * 0.15,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.main.temp.round()}°C', // Use temp from Main
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      // Use description from the first Weather object
                      weather.weather.isNotEmpty ? weather.weather.first.description : 'N/A', // Use description from the first Weather object
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}