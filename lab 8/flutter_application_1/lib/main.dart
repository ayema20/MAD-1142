import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// WEATHER MODEL
class Weather {
  final String cityName;
  final double temperature;
  final String description;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? 'No description',
    );
  }
}

// WEATHER SERVICE
class WeatherService {
  static const String _apiKey = '00338fb10e29a4d8143c5cdbef9276be';

  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception(
        'API Key is not active yet. Please wait 1-2 hours after creation.',
      );
    } else {
      throw Exception('Failed to load weather: ${response.statusCode}');
    }
  }
}

// MAIN APP
void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',

      theme: ThemeData(primarySwatch: Colors.blue),

      home: const WeatherScreen(),
    );
  }
}

// WEATHER SCREEN
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();

  final TextEditingController _latController = TextEditingController(
    text: "51.5074",
  );

  final TextEditingController _lonController = TextEditingController(
    text: "-0.1278",
  );

  Weather? _weather;

  bool _isLoading = false;

  String _errorMessage = '';

  void _getWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      double lat = double.tryParse(_latController.text) ?? 0.0;

      double lon = double.tryParse(_lonController.text) ?? 0.0;

      final weather = await _weatherService.fetchWeather(lat, lon);

      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Lab - Dynamic"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // LATITUDE
            TextField(
              controller: _latController,

              decoration: const InputDecoration(
                labelText: "Enter Latitude",
                hintText: "e.g. 51.5074",
                border: OutlineInputBorder(),
              ),

              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 15),

            // LONGITUDE
            TextField(
              controller: _lonController,

              decoration: const InputDecoration(
                labelText: "Enter Longitude",
                hintText: "e.g. -0.1278",
                border: OutlineInputBorder(),
              ),

              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // BUTTON
            ElevatedButton(
              onPressed: _getWeather,

              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),

              child: const Text("Get Current Weather"),
            ),

            const Divider(height: 50),

            // RESULT
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,

                style: const TextStyle(color: Colors.red),

                textAlign: TextAlign.center,
              )
            else if (_weather != null)
              Column(
                children: [
                  Text(
                    _weather!.cityName,

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "${_weather!.temperature}°C",

                    style: const TextStyle(fontSize: 40),
                  ),

                  Text(
                    _weather!.description.toUpperCase(),

                    style: const TextStyle(letterSpacing: 2),
                  ),
                ],
              )
            else
              const Text("Enter coordinates and tap search"),
          ],
        ),
      ),
    );
  }
}
