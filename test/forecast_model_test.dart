import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:skycast/src/features/weather/domain/models/forecast_model.dart';

void main() {
  test('ForecastModel fromOneCallJson parses hourly and daily', () {
    final json = jsonDecode('''
    {
      "list": [
        {
          "dt": 1600000000,
          "dt_txt": "2020-09-13 12:00:00",
          "main": {"temp": 25.0},
          "weather": [{"icon": "01d", "description": "clear sky"}]
        }
      ]
    }
    ''') as Map<String, dynamic>;

    final f = ForecastModel.fromForecastJson(json);
    expect(f.hourly.length, 1);
    expect(f.daily.length, 1);
    expect(f.hourly.first.iconCode, '01d');
    expect(f.daily.first.iconCode, '01d');
  });
}
