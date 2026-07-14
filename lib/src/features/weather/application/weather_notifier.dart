import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';

import '../domain/repositories/weather_repository.dart';
import '../domain/models/forecast_model.dart';
import 'weather_state.dart';

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this._weatherRepository) : super(WeatherState.initial());

  final WeatherRepository _weatherRepository;

  Future<void> loadWeather([String? city]) async {
    // If we have no weather loaded yet (app start), try to load cached data instantly
    if (state.weather == null) {
      final cachedWeather = await _weatherRepository.fetchCachedWeather();
      final cachedForecast = await _weatherRepository.fetchCachedForecast();
      if (cachedWeather != null) {
        state = state.copyWith(
          weather: cachedWeather,
          forecast: cachedForecast,
        );
      }
    }

    state = state.copyWith(status: WeatherStatus.loading, clearError: true);
    
    try {
      final weather = await _weatherRepository.fetchCurrentWeather(city: city);
      ForecastModel? forecast;
      try {
        forecast = await _weatherRepository.fetchForecast(lat: weather.lat, lon: weather.lon);
      } catch (_) {
        forecast = state.forecast; // keep old forecast if fetch fails
      }

      state = state.copyWith(
        status: WeatherStatus.success,
        weather: weather,
        forecast: forecast,
        clearError: true,
      );
    } catch (error) {
      String message = 'Unexpected error';
      try {
        if (error is DioException) {
          final status = error.response?.statusCode ?? 0;
          if (status == 401) {
            message = 'Authentication failed';
          } else if (status == 404) {
            message = 'Data not found';
          } else if (status == 429) {
            message = 'Rate limit reached, please try later';
          } else if (status >= 500) {
            message = 'Server unavailable, try again later';
          } else if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            message = 'Request timed out, check your connection';
          } else {
            message = error.message ?? 'Network error';
          }
        } else {
          message = error.toString();
        }
      } catch (_) {
        message = error.toString();
      }

      state = state.copyWith(
        status: WeatherStatus.failure,
        errorMessage: message,
      );
    }
  }
}
