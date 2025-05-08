import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/weather_item.dart';
import '../providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Aquí puedes añadir controladores si decides implementarlos en el futuro.
  // final TextEditingController _ciudadFieldController = TextEditingController();
  // final FocusNode _focusCiudad = FocusNode();

  @override
  void dispose() {
    // _ciudadFieldController.dispose();
    // _focusCiudad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeLarge = screenHeight * 0.05;
    double fontSizeMedium = screenHeight * 0.03;
    double paddingSize = screenWidth * 0.02;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Weather',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingSize),
        child: Column(
          children: [
            Expanded(
              child: Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  WeatherItem? weather = weatherProvider.currentWeather;

                  if (weather == null) {
                    return const Center(
                      child: Text('Loading weather data...'),
                    );
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'City: ${weather.city}',
                        style: TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: paddingSize),
                      Text(
                        'Temperature: ${weather.temperature}°C',
                        style: TextStyle(
                          fontSize: fontSizeMedium,
                        ),
                      ),
                      SizedBox(height: paddingSize),
                      Text(
                        'Description: ${weather.description}',
                        style: TextStyle(
                          fontSize: fontSizeMedium,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: paddingSize),
            Expanded(
              child: Center(
                child: Text(
                  'Additional weather details can be displayed here.',
                  style: TextStyle(fontSize: fontSizeMedium),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
