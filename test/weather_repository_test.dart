import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:skycast/src/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:skycast/src/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:skycast/src/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:skycast/src/features/weather/domain/models/weather_model.dart';
import 'package:skycast/src/features/weather/domain/models/forecast_model.dart';

class _FakeRemote implements WeatherRemoteDataSource {
  _FakeRemote({this.weather, this.forecastJson, this.throwOnWeather = false, this.throwOnForecast = false});

  final WeatherModel? weather;
  final Map<String, dynamic>? forecastJson;
  final bool throwOnWeather;
  final bool throwOnForecast;

  @override
  Future<WeatherModel> fetchCurrentWeather({String? city}) async {
    if (throwOnWeather) throw Exception('remote error');
    return weather!;
  }

  @override
  Future<ForecastModel> fetchForecast({double? lat, double? lon}) async {
    if (throwOnForecast) throw Exception('forecast error');
    return ForecastModel.fromForecastJson(forecastJson ?? {});
  }

  @override
  Future<List<String>> searchCitySuggestions(String query) async {
    return const [];
  }
}

class _FakeLocal implements WeatherLocalDataSource {
  WeatherModel? cachedWeather;
  String? cachedForecastJson;

  _FakeLocal({WeatherModel? cachedWeatherInit, String? cachedForecastJsonInit}) {
    cachedWeather = cachedWeatherInit;
    cachedForecastJson = cachedForecastJsonInit;
  }

  @override
  Future<WeatherModel?> fetchCachedWeather() async => cachedWeather;

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    cachedWeather = weather;
  }

  @override
  Future<void> cacheForecastJson(String json) async {
    cachedForecastJson = json;
  }

  @override
  Future<String?> fetchCachedForecastJson() async => cachedForecastJson;
}

void main() {
  test('fetchCurrentWeather returns remote and caches local', () async {
    final remote = _FakeRemote(
      weather: WeatherModel(
        city: 'A',
        description: 'd',
        temperature: 10,
        feelsLike: 9,
        iconCode: '01d',
      ),
      forecastJson: {'hourly': [], 'daily': []},
    );

    final local = _FakeLocal();
    final repo = WeatherRepositoryImpl(remote, local);

    final w = await repo.fetchCurrentWeather();
    expect(w.city, 'A');
    expect(local.cachedWeather, isNotNull);
  });

  test('fetchCurrentWeather falls back to cached when remote fails', () async {
    final remote = _FakeRemote(throwOnWeather: true);
    final cached = WeatherModel(
      city: 'Cached',
      description: 'cached',
      temperature: 5,
      feelsLike: 5,
      iconCode: '01d',
    );
    final local = _FakeLocal(cachedWeatherInit: cached);
    final repo = WeatherRepositoryImpl(remote, local);

    final w = await repo.fetchCurrentWeather();
    expect(w.city, 'Cached');
  });

  test('fetchForecast returns cached parsed forecast when remote fails', () async {
    final remote = _FakeRemote(throwOnForecast: true);
    final json = jsonEncode({'list': [{'dt': 1, 'dt_txt': '2020-01-01 12:00:00', 'main': {'temp': 1}, 'weather': [{'icon': '01d','description':'x'}]}]});
    final local = _FakeLocal(cachedForecastJsonInit: json);
    final repo = WeatherRepositoryImpl(remote, local);

    final f = await repo.fetchForecast();
    expect(f.hourly.isNotEmpty, true);
  });
}
