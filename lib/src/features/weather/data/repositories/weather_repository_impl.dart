import 'dart:convert';

import '../../domain/models/weather_model.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_data_source.dart';
import '../datasources/weather_remote_data_source.dart';
import '../../domain/models/forecast_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final WeatherRemoteDataSource _remoteDataSource;
  final WeatherLocalDataSource _localDataSource;

  @override
  Future<WeatherModel> fetchCurrentWeather({String? city}) async {
    try {
      final weather = await _remoteDataSource.fetchCurrentWeather(city: city);
      await _localDataSource.cacheWeather(weather);
      return weather;
    } catch (e) {
      final cached = await _localDataSource.fetchCachedWeather();
      if (cached != null) {
        return cached;
      }
      throw e;
    }
  }

  @override
  Future<WeatherModel?> fetchCachedWeather() async {
    return await _localDataSource.fetchCachedWeather();
  }

  @override
  Future<ForecastModel> fetchForecast({double? lat, double? lon}) async {
    try {
      final forecast = await _remoteDataSource.fetchForecast(lat: lat, lon: lon);
      // cache raw onecall json via local data source if available
      // The remote data source currently does not expose raw json, so
      // caching of forecast will be handled inside remote/local separately in future.
      return forecast;
    } catch (_) {
      final cached = await fetchCachedForecast();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<ForecastModel?> fetchCachedForecast() async {
    final cachedJson = await _localDataSource.fetchCachedForecastJson();
    if (cachedJson != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(cachedJson) as Map<String, dynamic>;
        return ForecastModel.fromForecastJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
