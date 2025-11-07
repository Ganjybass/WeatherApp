class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final String icon;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

    factory WeatherData.fromJson(Map<String, dynamic> json) {
    final fact = json['fact'];
    final info = json['info'];
    
    return WeatherData(
      cityName: info['name'] ?? 'Неизвестно',
      temperature: (fact['temp'] ?? 0).toDouble(),
      description: _getDescription(fact['condition']),
      humidity: fact['humidity'] ?? 0,
      windSpeed: (fact['wind_speed'] ?? 0).toDouble(),
      icon: fact['icon'] ?? '',
    );
  }

  static String _getDescription(String condition) {
    final conditions = {
      'clear': 'Ясно',
      'partly-cloudy': 'Малооблачно',
      'cloudy': 'Облачно с прояснениями',
      'overcast': 'Пасмурно',
      'drizzle': 'Морось',
      'light-rain': 'Небольшой дождь',
      'rain': 'Дождь',
      'moderate-rain': 'Умеренно сильный дождь',
      'heavy-rain': 'Сильный дождь',
      'continuous-heavy-rain': 'Длительный сильный дождь',
      'showers': 'Ливень',
      'wet-snow': 'Дождь со снегом',
      'light-snow': 'Небольшой снег',
      'snow': 'Снег',
      'snow-showers': 'Снегопад',
      'hail': 'Град',
      'thunderstorm': 'Гроза',
      'thunderstorm-with-rain': 'Дождь с грозой',
      'thunderstorm-with-hail': 'Гроза с градом',
    };
    return conditions[condition] ?? condition;
  }
}
