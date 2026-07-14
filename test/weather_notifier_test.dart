import 'package:flutter_test/flutter_test.dart';
import 'package:skycast/src/features/weather/application/weather_notifier.dart';
import 'package:skycast/src/features/weather/application/weather_state.dart';
import 'package:skycast/src/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:skycast/src/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:skycast/src/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:skycast/src/features/weather/domain/models/forecast_model.dart';
import 'package:skycast/src/features/weather/domain/models/weather_model.dart';

class _RemoteStub implements WeatherRemoteDataSource {
  _RemoteStub({this.weather, this.forecast});
  final WeatherModel? weather;
  final ForecastModel? forecast;

  @override
  Future<WeatherModel> fetchCurrentWeather({String? city}) async => weather!;

  @override
  Future<List<String>> searchCitySuggestions(String query) async => <String>[];

  @override
  Future<WeatherModel?> fetchCachedWeather() async => null;

  @override
  Future<ForecastModel> fetchForecast({double? lat, double? lon}) async => forecast!;

  @override
  Future<ForecastModel?> fetchCachedForecast() async => null;
}

class _LocalStub implements WeatherLocalDataSource {
  WeatherModel? cached;
  @override
  Future<void> cacheForecastJson(String json) async {}

  @override
  Future<void> cacheWeather(WeatherModel weather) async => cached = weather;

  @override
  Future<WeatherModel?> fetchCachedWeather() async => cached;

  @override
  Future<String?> fetchCachedForecastJson() async => null;
}

void main() {
  test('WeatherNotifier loadWeather sets success on valid remote', () async {
    final remote = _RemoteStub(
      weather: WeatherModel(city: 'X', description: 'd', temperature: 1, feelsLike: 1, iconCode: '01d'),
    );
    final local = _LocalStub();
    final repo = WeatherRepositoryImpl(remote, local);
    final notifier = WeatherNotifier(repo);

    await notifier.loadWeather();
    final state = notifier.state;
    expect(state.status, WeatherStatus.success);
    expect(state.weather?.city, 'X');
  });
}
