import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class WeatherService {
  static const String _apiKey = 'e8a68e1d6717afd2f5488aa02398d77a';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> fetchWeather({
    double lat = 51.5074,
    double lon = -0.1278,
  }) async {
    // Using Uri.https is cleaner and handles encoding for you
    final url = Uri.parse(
      '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Weather.fromJson(jsonResponse);
      } else {
        // Provide more context in your error
        throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // Handle network errors or parsing issues
      throw Exception('Failed to connect to the weather service: $e');
    }
  }
}
