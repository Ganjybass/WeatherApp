
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weather/config/api_config.dart';


void main() {
  runApp(WeatherApp());
}


class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
  
}





class _WeatherScreenState extends State<WeatherScreen> {
  String _cityName = 'Москва';
  double _temperature = 20.0;
  String _weatherDescription = 'Солнечно';
  int _humidity = 65;
  double _windSpeed = 3.2;
  String _weatherIcon = '☀️';
  bool _isLoading = false;

  final TextEditingController _cityController = TextEditingController();
  

  // Метод для поиска погоды
  Future<void> _searchWeather() async {
    final newCity = _cityController.text.trim();
    final cityToSearch = newCity.isEmpty ? _cityName : newCity;

    print("🔄 Начинаем поиск погоды для: '$cityToSearch'");
    
   //if (newCity.isEmpty) return; 

    setState(() {
      _isLoading = true;
    });

    try {
      final coordinates = await _getCityCoordinatesSimple(cityToSearch);
      // final lat = coordinates[0];
      // final lon = coordinates[1];
      // print("📍 Координаты: $lat, $lon");
      
      print("🌤️ Шаг 2: Запрашиваем погоду по координатам");
      final response = await http.get(
        Uri.parse('${ApiConfig.weatherBaseUrl}/forecast?latitude=${coordinates[0]}&longitude=${coordinates[1]}&current_weather=true&timezone=auto'),
      ).timeout(ApiConfig.receiveTimeout);

       print("📡 Статус ответа: ${response.statusCode}");
       print("📡 Тело ответа: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final currentWeather = jsonData['current_weather'];

        print("✅ Данные получены: $currentWeather");

        setState(() {
          _cityName = newCity;
          _temperature = currentWeather['temperature'];
          _windSpeed = currentWeather['windspeed'] /3.6; 
          _weatherDescription = _getWeatherDescription(currentWeather['weathercode']);
          _weatherIcon = _getWeatherIcon(currentWeather['weathercode']);
          _humidity = 50 + (newCity.length % 50);
          _isLoading = false;
        });
print("🧪 ТЕСТ ДАННЫХ:");
print("🧪 Город: $_cityName");
print("🧪 Температура: $_temperature");
print("🧪 Ветер: $_windSpeed м/с");
print("🧪 Описание: $_weatherDescription");
print("🧪 Иконка: $_weatherIcon");

        print("✅ Реальная погода обновлена!");
      } else {
        print("❌ Ошибка API: ${response.statusCode}");
        throw Exception('Ошибка API: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Ошибка: $e");
      setState(() {
        _isLoading = false;
      });
      _showError('Не удалось получить погоду: $e');
    }
      // Очищаем поле ввода только если был поиск по новому городу
  if (newCity.isNotEmpty) {
    _cityController.clear();
   }
   
  }

  // Временный метод для тестирования - использует фиксированные координаты
Future<List<double>> _getCityCoordinatesSimple(String city) async {
  final cityCoordinates = {
    'москва': [55.7558, 37.6176],
    'санкт-петербург': [59.9343, 30.3351],
    'казань': [55.7961, 49.1064],
    'новосибирск': [55.0084, 82.9357],
    'сочи': [43.5855, 39.7231],
    'лондон': [51.5074, -0.1278],
    'париж': [48.8566, 2.3522],
    'челябинск': [55.1644, 61.4368],
    'екатеринбург': [56.8386, 60.6055],
    'миасс': [55.050432, 60.109599],
  };
  
  final lowerCity = city.toLowerCase();
  if (cityCoordinates.containsKey(lowerCity)) {
    print("📍 Используем фиксированные координаты для: $city");
    return cityCoordinates[lowerCity]!;
  }
  
  // Если города нет в списке, используем реальный геокодер
  return await _getCityCoordinates(city);
}

  // Получаем координаты города
  Future<List<double>> _getCityCoordinates(String city) async {
  try {
    print("🗺️ Запрос к геокодеру для: '$city'");
    final response = await http.get(
      Uri.parse('${ApiConfig.geocoderBaseUrl}/search?format=json&q=$city&limit=1'),

      headers: ApiConfig.geocoderHeaders, // добавляем заголовки
    ).timeout(ApiConfig.connectTimeout); //добавили таймаут

    

    print("🗺️ Статус геокодера: ${response.statusCode}");
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("🗺️ Данные геокодера: $data");
      
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        print("✅ Координаты найдены: $lat, $lon");
        return [lat, lon];
      } else {
        print("❌ Геокодер вернул пустой результат");
        throw Exception('Город "$city" не найден');
      }
    } else {
      print("❌ Ошибка геокодера: ${response.statusCode}");
      throw Exception('Ошибка геокодера: ${response.statusCode}');
    }
  } catch (e) {
    print("💥 Ошибка в геокодере: $e");
    rethrow;
  }
}

  // Описание погоды по коду
  String _getWeatherDescription(int weatherCode) { 
    final descriptions = {
        // Ясная погода
    0: 'Ясно',
    1: 'Преимущественно ясно', 
    2: 'Переменная облачность',
    3: 'Пасмурно',
    
    // Туман
    45: 'Туман',
    48: 'Туман с инеем',
    
    // Морось
    51: 'Легкая морось',
    53: 'Умеренная морось', 
    55: 'Сильная морось',
    
    // Дождь
    61: 'Небольшой дождь',
    63: 'Умеренный дождь',
    65: 'Сильный дождь',
    
    // Ливень
    80: 'Небольшой ливень',
    81: 'Умеренный ливень',
    82: 'Сильный ливень',
    
    // Снег
    71: 'Небольшой снег',
    73: 'Умеренный снег', 
    75: 'Сильный снег',
    
    // Град
    87: 'Небольшой град',
    88: 'Умеренный град',
    89: 'Сильный град',
    
    // Гроза
    95: 'Гроза',
    96: 'Гроза с небольшим градом',
    99: 'Гроза с сильным градом',
    };

  print("🌈 Код погоды для Миасса: $weatherCode");
  final description = descriptions[weatherCode] ?? 'Неизвестно ($weatherCode)';
  print("🌈 Описание: $description");
  return description;
    
  }

  String _getWeatherIcon(int weatherCode) {
    final icons = {
       // Ясная погода
    0: '☀️',
    1: '☀️', 
    2: '⛅',
    3: '☁️',

    // Туман
    45: '🌫️',
    48: '🌫️',
    
    // Морось и дождь
    51: '🌧️',
    53: '🌧️',
    55: '🌧️',
    61: '🌧️', 
    63: '🌧️',
    65: '🌧️',
    
    // Ливень
    80: '⛈️',
    81: '⛈️',
    82: '⛈️',
    
    // Снег
    71: '❄️',
    73: '❄️',
    75: '❄️',
    
    // Град
    87: '🌨️',
    88: '🌨️', 
    89: '🌨️',
    
    // Гроза
    95: '⛈️',
    96: '⛈️',
    99: '⛈️',
    };
    final icon = icons[weatherCode] ?? '❓';
    print("🎨 Иконка: $icon");
    return icon;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_temperature > 25) {
      return Colors.orange;
    } else if (_temperature > 15) {
      return Colors.yellow[700]!;
    } else if (_temperature > 5) {
      return Colors.blue;
    } else {
      return Colors.blue[900]!;
    }
  }

  @override
  void initState() {
  super.initState();
  //_searchWeather(); // Загружаем погоду при запуске приложения
  
}
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Загружаем погоду...', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Заголовок с городом
                      Text(
                        _cityName,
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      // Иконка погоды
                      Text(
                        _weatherIcon,
                        style: TextStyle(fontSize: 80),
                      ),
                      SizedBox(height: 10),
                      // Температура
                      Text(
                        '${_temperature.round()}°', //  знак градуса
                        style: TextStyle(
                          fontSize: 64,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      // Описание погоды
                      Text(
                        _weatherDescription,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 40),
                      // Дополнительная информация
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2), 
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Влажность
                            Column(
                              children: [
                                Text('💧', style: TextStyle(fontSize: 24)),
                                SizedBox(height: 5),
                                Text('Влажность', style: TextStyle(color: Colors.white)), 
                                Text('$_humidity%', style: TextStyle(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                            // Ветер
                            Column(
                              children: [
                                Text('💨', style: TextStyle(fontSize: 24)),
                                SizedBox(height: 5),
                                Text('Ветер', style: TextStyle(color: Colors.white)), 
                                Text('${_windSpeed.toStringAsFixed(1)} м/с', 
                                     style: TextStyle(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                 
                SizedBox(height: 10,),

              // Поисковая строка
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2), 
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Введите город...',
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onSubmitted: (_) => _searchWeather(),
                      ),
                    ),
                    IconButton(
                      onPressed: _searchWeather,
                      icon: Icon(Icons.search, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}