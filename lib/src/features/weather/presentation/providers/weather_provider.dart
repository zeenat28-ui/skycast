import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../application/weather_notifier.dart';
import '../../application/weather_state.dart';

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
      final repository = ref.read(weatherRepositoryProvider);
      return WeatherNotifier(repository);
    });
