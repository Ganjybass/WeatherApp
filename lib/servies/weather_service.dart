import 'package:http/http.dart' as http;
import 'package:weather/models/weather_model.dart';
import 'dart:convert';
import '../config/api_config.dart';


class WeatherService {
  static Future<WeatherData> getWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.weatherBaseUrl}/forecast?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto'),
    ).timeout(ApiConfig.receiveTimeout);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather: ${response.statusCode}');
    }
  }
}