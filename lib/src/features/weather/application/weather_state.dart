import '../domain/models/weather_model.dart';
import '../domain/models/forecast_model.dart';

enum WeatherStatus { initial, loading, success, failure }

class WeatherState {
  final WeatherStatus status;
  final WeatherModel? weather;
  final ForecastModel? forecast;
  final String? errorMessage;

  const WeatherState({required this.status, this.weather, this.forecast, this.errorMessage});

  factory WeatherState.initial() {
    return const WeatherState(status: WeatherStatus.initial, forecast: null);
  }

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherModel? weather,
    ForecastModel? forecast,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
