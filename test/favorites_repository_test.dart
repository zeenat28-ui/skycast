import 'package:flutter_test/flutter_test.dart';
import 'package:skycast/src/features/weather/data/datasources/weather_local_data_source.dart';
// removed unused repo import
import 'package:skycast/src/features/weather/domain/models/weather_model.dart';

class _InMemoryLocal implements WeatherLocalDataSource {
  WeatherModel? _cached;
  final List<String> favorites = [];

  _InMemoryLocal({WeatherModel? initial}) : _cached = initial;

  @override
  Future<void> cacheForecastJson(String json) async {}

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    _cached = weather;
  }

  @override
  Future<WeatherModel?> fetchCachedWeather() async => _cached;

  @override
  Future<String?> fetchCachedForecastJson() async => null;
}

void main() {
  test('local cache stores and returns weather', () async {
    final local = _InMemoryLocal();
    expect(await local.fetchCachedWeather(), isNull);

    final w = WeatherModel(city: 'T', description: 'd', temperature: 1, feelsLike: 1, iconCode: '01d');
    await local.cacheWeather(w);
    final got = await local.fetchCachedWeather();
    expect(got?.city, 'T');
  });
}
