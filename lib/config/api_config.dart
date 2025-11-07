
class ApiConfig {
  static const String geocoderBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';

    // Таймауты для запросов
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Заголовки для геокодера (требует User-Agent)
  static const Map<String, String> geocoderHeaders = {
    'User-Agent': 'WeatherApp/1.0 (your-email@example.com)',
  };

}