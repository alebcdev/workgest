import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/hourly_forecast.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> hourlyData;

  const HourlyForecastList({
    super.key,
    required this.hourlyData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (hourlyData.isEmpty) {
      return const Center(
        child: Text('No hourly forecast data available.'),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyData.length,
        itemBuilder: (context, index) {
          final forecastItem = hourlyData[index];

          // Convert timestamp to DateTime and format the time
          final DateTime forecastTime =
          DateTime.fromMillisecondsSinceEpoch(forecastItem.dt * 1000);
          final String formattedTime =
          DateFormat('h a').format(forecastTime); // e.g., 10 AM, 1 PM

          // Get the weather icon (placeholder used here)
          IconData weatherIcon = Icons.cloud;
          if (forecastItem.weather.isNotEmpty) {
            // TODO: Implement a function to map OpenWeatherMap icon codes to Flutter IconData
            // weatherIcon = getWeatherIcon(forecastItem.weather[0].icon);
          }

          return Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              color: theme.cardColor,
              elevation: 2.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedTime,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  Icon(
                    weatherIcon,
                    color: theme.iconTheme.color,
                  ),
                  Text(
                    '${forecastItem.main.temp}°C',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
