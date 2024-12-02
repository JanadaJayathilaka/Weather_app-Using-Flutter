import 'dart:convert';
//import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London';
      String apiKey =
          'd7e2f1459af554e75970779b05299b93'; // Replace with your OpenWeatherMap API key
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName,uk&APPID=$apiKey'));

      final data = jsonDecode(response.body);
      if (data['cod'] != 200) {
        throw 'AN unexpected error occured';
        // Example usage of API data
      }
      return data;
      // data['main']['temp'];
    } catch (e) {
      throw e.toString(); // Handle the error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;

          final currentTemp = data['main']['temp'];
          final currentSky =
              data['weather'][0]['main']; //because weather is a list

          final currentPressure = data['main']['pressure'];
          final currentWind = data['wind']['speed'];
          final currentHumidity = data['main']['humidity'];
          final hourlyForecastTime = data['dt'];
          // final hourlySky = data['weather'][0]['description'];
          final hourlyTime =
              DateTime.fromMillisecondsSinceEpoch(hourlyForecastTime);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp °K',
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const Icon(
                                Icons.cloud,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                currentSky,
                                style: const TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Weather Forecast',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      HourlyForecastItem(
                        time: '$hourlyTime',
                        icon: Icons.broken_image,
                        value: '301.22',
                      ),
                      const HourlyForecastItem(
                        time: '03:00',
                        icon: Icons.sunny,
                        value: '300.52',
                      ),
                      const HourlyForecastItem(
                        time: '06:00',
                        icon: Icons.cloud,
                        value: '301.22',
                      ),
                      const HourlyForecastItem(
                        time: '09:00',
                        icon: Icons.sunny,
                        value: '303.22',
                      ),
                      const HourlyForecastItem(
                        time: '12:00',
                        icon: Icons.cloud,
                        value: '304.22',
                      ),
                    ],
                  ),
                ),
                // ListView.builder(
                //   itemCount: 5,
                //   itemBuilder: (context,index){
                //     final HourlyForecastItem=data;
                //     return HourlyForecastItem(
                //       time: HourlyForecastItem['dt'],
                //       icon: ,
                //       value: value)
                //   }),
                const SizedBox(
                  height: 20,
                ),
                //additional card
                const Text(
                  'Additional Infromation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround, //space arounding
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humdity',
                      value: '$currentHumidity',
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '$currentWind',
                    ),
                    AdditionalInfoItem(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: '$currentPressure',
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
