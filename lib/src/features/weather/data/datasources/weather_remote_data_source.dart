import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/models/weather_model.dart';
import '../../domain/models/forecast_model.dart';
import '../../../../core/infrastructure/api_client.dart';
import '../../../../core/infrastructure/logger_service.dart';
import '../../../../core/services/location_service.dart';
import 'weather_local_data_source.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> fetchCurrentWeather({String? city});
  Future<ForecastModel> fetchForecast({double? lat, double? lon});
  Future<List<String>> searchCitySuggestions(String query);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  WeatherRemoteDataSourceImpl(
    this._apiClient,
    this._locationService,
    this._logger,
    this._localDataSource,
  );

  final AppApiClient _apiClient;
  final LocationService _locationService;
  final AppLogger _logger;
  final WeatherLocalDataSource _localDataSource;

  @override
  Future<WeatherModel> fetchCurrentWeather({String? city}) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    
    // If a city is explicitly passed, use it. Otherwise, use device location or fallback.
    final deviceCity = await _locationService.getDeviceCity();
    final envCity = dotenv.env['WEATHER_CITY'];
    final finalCity = city ?? deviceCity ?? (envCity != null && envCity.isNotEmpty ? envCity : 'San Francisco');
    
    // Only use current coordinates if no explicit city was requested
    final coordinates = city == null ? await _locationService.getCurrentCoordinates() : null;

    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_openweather_api_key_here') {
      _logger.warning('OPENWEATHER_API_KEY not set or is placeholder, returning mock weather.');
      return WeatherModel(
        city: finalCity,
        description: 'Clear sky',
        temperature: 22.4,
        feelsLike: 22.0,
        iconCode: '01d',
        humidity: 64,
        pressure: 1013,
        visibility: 10000,
        windSpeed: 12,
        uvIndex: 4.5,
        airQuality: 'Good',
      );
    }

    final Map<String, dynamic> queryParams = {'units': 'metric', 'appid': apiKey};
    if (coordinates != null) {
      queryParams['lat'] = coordinates['lat'];
      queryParams['lon'] = coordinates['lon'];
    } else {
      queryParams['q'] = finalCity;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: queryParams,
    );

    if (response.statusCode != 200 || response.data == null) {
      throw DioException(
        requestOptions: RequestOptions(
          path: 'https://api.openweathermap.org/data/2.5/weather',
        ),
        message: 'Weather service unavailable',
      );
    }

    final basicWeather = WeatherModel.fromJson(response.data!);
    
    Map<String, dynamic>? resolvedCoords = coordinates;
    if (resolvedCoords == null && response.data!['coord'] != null) {
      resolvedCoords = {
        'lat': (response.data!['coord']['lat'] as num).toDouble(),
        'lon': (response.data!['coord']['lon'] as num).toDouble(),
      };
    }

    final airQuality = await _fetchAirQuality(resolvedCoords, apiKey);
    final uvIndex = await _fetchUvIndex(resolvedCoords, apiKey);

    _logger.info('Weather loaded for $city');
    return WeatherModel(
      city: basicWeather.city,
      description: basicWeather.description,
      temperature: basicWeather.temperature,
      feelsLike: basicWeather.feelsLike,
      iconCode: basicWeather.iconCode,
      humidity: basicWeather.humidity,
      pressure: basicWeather.pressure,
      visibility: basicWeather.visibility,
      windSpeed: basicWeather.windSpeed,
      cloudCoverage: basicWeather.cloudCoverage,
      rainProbability: basicWeather.rainProbability,
      uvIndex: uvIndex,
      airQuality: airQuality,
      country: basicWeather.country,
      timestamp: basicWeather.timestamp,
    );
  }

  @override
  Future<ForecastModel> fetchForecast({double? lat, double? lon}) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];

    Map<String, dynamic>? coords;
    if (lat != null && lon != null) {
      coords = {'lat': lat, 'lon': lon};
    } else {
      coords = await _locationService.getCurrentCoordinates();
    }
    
    if (coords == null) {
      _logger.warning('Location unavailable for forecast, throwing.');
      throw DioException(
        requestOptions: RequestOptions(path: 'onecall'),
        message: 'Location unavailable',
      );
    }

    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_openweather_api_key_here') {
      _logger.warning('OPENWEATHER_API_KEY not set or is placeholder, returning empty forecast.');
      return ForecastModel(hourly: const [], daily: const []);
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      'https://api.openweathermap.org/data/2.5/forecast',
      queryParameters: {
        'lat': coords['lat'],
        'lon': coords['lon'],
        'units': 'metric',
        'appid': apiKey,
      },
    );

    if (response.statusCode != 200 || response.data == null) {
      throw DioException(
        requestOptions: RequestOptions(path: 'forecast'),
        message: 'Forecast service unavailable',
      );
    }

    _logger.info('Forecast loaded');
    try {
      final raw = jsonEncode(response.data);
      await _localDataSource.cacheForecastJson(raw);
    } catch (_) {
      // ignore cache write errors
    }

    return ForecastModel.fromForecastJson(response.data!);
  }

  @override
  Future<List<String>> searchCitySuggestions(String query) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (query.trim().isEmpty) return const [];

    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_openweather_api_key_here') {
      return const [];
    }

    final response = await _apiClient.get<List<dynamic>>(
      'https://api.openweathermap.org/geo/1.0/direct',
      queryParameters: {'q': query, 'limit': 6, 'appid': apiKey},
    );

    if (response.statusCode != 200 || response.data == null) {
      return const [];
    }

    final results = response.data!;
    final list = <String>[];
    for (final item in results) {
      try {
        final name = item['name'] as String? ?? '';
        final country = item['country'] as String? ?? '';
        final state = item['state'] as String?;
        final display = state != null && state.isNotEmpty
            ? '$name, $state, $country'
            : '$name, $country';
        if (display.isNotEmpty) list.add(display);
      } catch (_) {
        // ignore malformed entries
      }
    }

    return list;
  }

  Future<String> _fetchAirQuality(Map<String, dynamic>? coords, String apiKey) async {
    if (coords == null) return 'Unknown';
    final response = await _apiClient.get<Map<String, dynamic>>(
      'https://api.openweathermap.org/data/2.5/air_pollution',
      queryParameters: {
        'lat': coords['lat'],
        'lon': coords['lon'],
        'appid': apiKey,
      },
    );

    if (response.statusCode != 200 || response.data == null) {
      return 'Unknown';
    }

    final aqi = (response.data?['list'] as List<dynamic>?)?.isNotEmpty == true
        ? (response.data!['list'][0]['main']?['aqi'] as num?)?.toInt() ?? 0
        : 0;
    return _mapAqiToLabel(aqi);
  }

  Future<double> _fetchUvIndex(Map<String, dynamic>? coords, String apiKey) async {
    if (coords == null) return 0.0;
    final response = await _apiClient.get<Map<String, dynamic>>(
      'https://api.openweathermap.org/data/2.5/onecall',
      queryParameters: {
        'lat': coords['lat'],
        'lon': coords['lon'],
        'exclude': 'minutely,hourly,daily,alerts',
        'units': 'metric',
        'appid': apiKey,
      },
    );

    if (response.statusCode != 200 || response.data == null) {
      return 0.0;
    }

    return ((response.data?['current']?['uvi'] as num?) ?? 0).toDouble();
  }

  String _mapAqiToLabel(int aqi) {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }
}
