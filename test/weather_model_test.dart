import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:skycast/src/features/weather/domain/models/weather_model.dart';

void main() {
  test('WeatherModel fromJson parses basic response', () {
    final json = jsonDecode('''
    {
      "name": "Testville",
      "sys": {"country": "TV", "sunrise": "1620000000", "sunset": "1620040000"},
      "weather": [{"description": "clear sky", "icon": "01d"}],
      "main": {"temp": 20.5, "feels_like": 19.8, "humidity": 50, "pressure": 1012},
      "visibility": 10000,
      "wind": {"speed": 5.2},
      "clouds": {"all": 0},
      "dt": 1620012345
    }
    ''') as Map<String, dynamic>;

    final w = WeatherModel.fromJson(json);
    expect(w.city, 'Testville');
    expect(w.country, 'TV');
    expect(w.description, 'clear sky');
    expect(w.temperature, 20.5);
    expect(w.iconCode, '01d');
    expect(w.humidity, 50);
  });
}
