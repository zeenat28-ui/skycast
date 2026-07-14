import '../models/weather_model.dart';
import '../models/forecast_model.dart';

abstract class WeatherRepository {
  Future<WeatherModel> fetchCurrentWeather({String? city});
  Future<WeatherModel?> fetchCachedWeather();
  Future<ForecastModel> fetchForecast({double? lat, double? lon});
  Future<ForecastModel?> fetchCachedForecast();
}
