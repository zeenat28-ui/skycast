import 'dart:convert';

import '../../domain/models/weather_model.dart';
import '../../../../core/services/storage_service.dart';

abstract class WeatherLocalDataSource {
  Future<WeatherModel?> fetchCachedWeather();
  Future<void> cacheWeather(WeatherModel weather);
  Future<String?> fetchCachedForecastJson();
  Future<void> cacheForecastJson(String json);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  WeatherLocalDataSourceImpl(this._storageService);

  final StorageService _storageService;
  static const String _weatherCacheKey = 'cached_weather';
  static const String _forecastCacheKey = 'cached_forecast';

  @override
  Future<WeatherModel?> fetchCachedWeather() async {
    final json = await _storageService.getString(_weatherCacheKey);
    if (json == null || json.isEmpty) {
      return null;
    }

    try {
      return WeatherModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    final json = jsonEncode(weather.toJson());
    await _storageService.saveString(_weatherCacheKey, json);
  }

  @override
  Future<String?> fetchCachedForecastJson() async {
    final json = await _storageService.getString(_forecastCacheKey);
    if (json == null || json.isEmpty) return null;
    return json;
  }

  @override
  Future<void> cacheForecastJson(String json) async {
    await _storageService.saveString(_forecastCacheKey, json);
  }
}
