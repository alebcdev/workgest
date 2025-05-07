import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import '../../viewmodel/weather_viewmodel.dart';

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final _ciudadFieldController = TextEditingController();
  final _focusCiudad = FocusNode();
  late WeatherViewModel _weatherViewModel;

  @override
  void initState() {
    super.initState();
    _weatherViewModel = WeatherViewModel(WeatherFactory("2fde5dc70e99b88cae3a442e661f90a9"));
  }

  @override
  void dispose() {
    _ciudadFieldController.dispose();
    _focusCiudad.dispose();
    super.dispose();
  }

  void _fetchWeather() {
    setState(() {
      _weatherViewModel.setCity(_ciudadFieldController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeLarge = screenHeight * 0.05;
    double fontSizeMedium = screenHeight * 0.03;
    double fontSizeSmall = screenHeight * 0.015;
    double iconSizeLarge = screenHeight * 0.06;
    double iconSizeMedium = screenHeight * 0.04;
    double iconSizeSmall = screenHeight * 0.03;
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ciudadFieldController,
                    focusNode: _focusCiudad,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      hintText: 'Ciudad',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _focusCiudad.unfocus();
                    _fetchWeather();
                  },
                  icon: Icon(
                    Icons.search,
                    size: iconSizeMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: paddingSize),
            Expanded(
              child: FutureBuilder<List<Weather>>(
                future: _weatherViewModel.weatherFuture,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error: La ciudad no existe o está mal escrita'));
                      } else {
                        List<Weather> weatherData = snapshot.data!;
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            double itemWidth = screenWidth / 4;
                            double itemHeight = screenHeight / 5;

                            return Column(
                              children: [
                                // Current Weather
                                Card(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                      color: Colors.blueAccent[100],
                                    ),
                                    width: double.infinity,
                                    padding: EdgeInsets.all(paddingSize),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${weatherData[0].temperature?.celsius?.toInt()}ºC',
                                                      style: TextStyle(
                                                        fontSize: fontSizeLarge,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.thermostat,
                                                      size: iconSizeLarge,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${(weatherData[0].windSpeed! * 3.6).toInt()}km/h',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: fontSizeMedium,
                                                      ),
                                                    ),
                                                    Icon(
                                                      _windIconDirection(weatherData[0].windDegree),
                                                      color: Colors.white,
                                                      size: iconSizeMedium,
                                                    ),
                                                    Icon(
                                                      WeatherIcons.windy,
                                                      color: Colors.white,
                                                      size: iconSizeMedium,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Image(
                                              image: NetworkImage(
                                                "http://openweathermap.org/img/wn/${weatherData[0].weatherIcon}@4x.png",
                                              ),
                                              width: itemWidth,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: paddingSize),
                                        SizedBox(
                                          height: itemHeight,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: 8,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.all(paddingSize * 0.1),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: screenWidth * 0.001,
                                                    ),
                                                  ),
                                                  width: itemWidth,
                                                  height: itemHeight,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image(
                                                        image: NetworkImage(
                                                          "http://openweathermap.org/img/wn/${weatherData[0].weatherIcon}@2x.png",
                                                        ),
                                                        width: itemWidth * 0.5,
                                                      ),
                                                      Text(
                                                        '${weatherData[index].temperature?.celsius?.toInt()}º',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: fontSizeSmall,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${(weatherData[index].windSpeed! * 3.6).toInt()}km/h',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: fontSizeSmall,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${weatherData[index].date?.hour}:${weatherData[index].date?.minute.toString().padLeft(2,'0')}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: fontSizeSmall,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Daily Weather
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: weatherData.length,
                                    itemBuilder: (context, index) {
                                      if (index % 7 == 0 && index != 0) {
                                        return ListTile(
                                          tileColor: Colors.lightBlue[300],
                                          title: Text(
                                            '${weatherData[index].date?.day}/${weatherData[index].date?.month}/${weatherData[index].date?.year}',
                                            style: TextStyle(color: Colors.white, fontSize: fontSizeMedium),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Text(
                                                '${weatherData[index].temperature?.celsius?.toInt()}º',
                                                style: TextStyle(color: Colors.white, fontSize: fontSizeSmall),
                                              ),
                                              Icon(
                                                Icons.thermostat,
                                                color: Colors.white,
                                                size: iconSizeSmall,
                                              ),
                                              Text(
                                                '${(weatherData[index].windSpeed! * 3.6).toInt()}km/h',
                                                style: TextStyle(color: Colors.white, fontSize: fontSizeSmall),
                                              ),
                                              Icon(
                                                _windIconDirection(weatherData[index].windDegree),
                                                color: Colors.white,
                                                size: iconSizeSmall,
                                              ),
                                              Icon(
                                                WeatherIcons.windy,
                                                color: Colors.white,
                                                size: iconSizeSmall,
                                              ),
                                            ],
                                          ),
                                          trailing: Image(
                                            image: NetworkImage(
                                              "http://openweathermap.org/img/wn/${weatherData[index].weatherIcon}@4x.png",
                                            ),
                                            width: itemWidth * 0.8,
                                          ),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  IconData? _windIconDirection(grado){
    if(grado >= 22.5 && grado < 45){
      return WeatherIcons.wind_deg_45;
    }else if(grado >= 45 && grado < 67.5){
      return WeatherIcons.wind_deg_45;
    }else if(grado >= 67.5 && grado < 90){
      return WeatherIcons.wind_deg_90;
    }else if(grado >= 90 && grado < 112.5){
      return WeatherIcons.wind_deg_90;
    }else if(grado >= 112.5 && grado < 135){
      return WeatherIcons.wind_deg_135;
    }else if(grado >= 135 && grado < 157.5){
      return WeatherIcons.wind_deg_135;
    }else if(grado >= 157.5 && grado < 180){
      return WeatherIcons.wind_deg_180;
    }else if(grado >= 180 && grado < 202.5){
      return WeatherIcons.wind_deg_180;
    }else if(grado >= 202.5 && grado < 225){
      return WeatherIcons.wind_deg_225;
    }else if(grado >= 225 && grado < 237.5){
      return WeatherIcons.wind_deg_225;
    }else if(grado >= 237.5 && grado < 270){
      return WeatherIcons.wind_deg_270;
    }else if(grado >= 270 && grado < 292.5){
      return WeatherIcons.wind_deg_270;
    }else if(grado >= 292.5 && grado < 315){
      return WeatherIcons.wind_deg_315;
    }else if(grado >= 315 && grado < 337.5){
      return WeatherIcons.wind_deg_315;
    }else{
      return WeatherIcons.wind_deg_0;
    }
  }
}