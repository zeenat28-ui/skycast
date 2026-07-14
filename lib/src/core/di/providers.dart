import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/infrastructure/api_client.dart';
import '../../core/infrastructure/logger_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/storage_service.dart';
import '../../features/weather/data/datasources/weather_local_data_source.dart';
import '../../features/weather/data/datasources/weather_remote_data_source.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';

final apiClientProvider = Provider<AppApiClient>((ref) => AppApiClient());

final loggerProvider = Provider<AppLogger>((ref) => AppLogger());

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>(
  (ref) => WeatherLocalDataSourceImpl(ref.read(storageServiceProvider)),
);

final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>(
  (ref) => WeatherRemoteDataSourceImpl(
    ref.read(apiClientProvider),
    ref.read(locationServiceProvider),
    ref.read(loggerProvider),
    ref.read(weatherLocalDataSourceProvider),
  ),
);

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepositoryImpl(
    ref.read(weatherRemoteDataSourceProvider),
    ref.read(weatherLocalDataSourceProvider),
  ),
);
