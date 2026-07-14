import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/providers/app_settings_provider.dart';
import '../../../../core/presentation/providers/location_permission_provider.dart';
import '../../../../core/presentation/widgets/offline_banner.dart';
import '../../application/weather_state.dart';
import '../providers/weather_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherNotifierProvider);
    final settings = ref.watch(appSettingsProvider);

    if (state.status == WeatherStatus.initial) {
      final perm = ref.watch(locationPermissionProvider);
      perm.when(
        data: (p) {
          if (p == LocationPermission.deniedForever) {
            // do not auto-load; UI will show error and settings button
          } else {
            Future.microtask(
              () => ref.read(weatherNotifierProvider.notifier).loadWeather(),
            );
          }
        },
        loading: () => Future.microtask(() {}),
        error: (_, _) => Future.microtask(
          () => ref.read(weatherNotifierProvider.notifier).loadWeather(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07111F), Color(0xFF122B4F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      ref.read(weatherNotifierProvider.notifier).loadWeather(),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 120,
                        floating: true,
                        pinned: false,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          titlePadding: const EdgeInsets.only(
                            left: 16,
                            bottom: 14,
                          ),
                          title: Text(
                            'SkyCast Pro',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        actions: [
                          IconButton(
                            tooltip: 'Settings',
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () => context.push('/settings'),
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                          child: _buildContent(context, state, ref, settings),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WeatherState state,
    WidgetRef ref,
    AppSettingsState settings,
  ) {
    if (state.status == WeatherStatus.loading && state.weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == WeatherStatus.failure && state.weather == null) {
      final perm = ref.watch(locationPermissionProvider);
      return perm.when(
        data: (p) {
          if (p == LocationPermission.deniedForever) {
            return _PermissionDeniedCard(
              message: 'Location permission denied permanently.',
              onOpenSettings: () => Geolocator.openAppSettings(),
            );
          }
          return _ErrorCard(
            message: state.errorMessage ?? 'Unable to load weather',
            onRetry: () => ref.read(weatherNotifierProvider.notifier).loadWeather(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ErrorCard(
          message: state.errorMessage ?? 'Unable to load weather',
          onRetry: () => ref.read(weatherNotifierProvider.notifier).loadWeather(),
        ),
      );
    }

    if (state.weather == null) {
      return const SizedBox.shrink();
    }

    final weather = state.weather!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WeatherHeroCard(
          weather: weather,
          settings: settings,
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
        const SizedBox(height: 16),
        _WeatherSummaryGrid(weather: weather, settings: settings),
        const SizedBox(height: 16),
        _AirQualityBanner(quality: weather.airQuality),
        const SizedBox(height: 16),
        _QuickActionsCard(
          weather: weather,
          settings: settings,
          onFavorite: () => ref
              .read(appSettingsProvider.notifier)
              .toggleFavorite(weather.city),
          onForecast: () => context.push('/forecast'),
        ),
      ],
    );
  }
}

class _WeatherHeroCard extends StatelessWidget {
  const _WeatherHeroCard({required this.weather, required this.settings});

  final dynamic weather;
  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    final tempUnit = settings.temperatureUnit;
    final temp = tempUnit == '°F'
        ? ((weather.temperature * 9 / 5) + 32)
        : weather.temperature;
    final feelsLike = tempUnit == '°F'
        ? ((weather.feelsLike * 9 / 5) + 32)
        : weather.feelsLike;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('Tap to refresh', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${temp.toStringAsFixed(0)}$tempUnit',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Feels like ${feelsLike.toStringAsFixed(0)}$tempUnit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          'AQI: ${weather.airQuality ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          'UV ${weather.uvIndex?.toStringAsFixed(1) ?? '0.0'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Image.network(
              'https://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
              width: 110,
              height: 110,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
      ),
    ),
    );
  }
}

class _WeatherSummaryGrid extends StatelessWidget {
  const _WeatherSummaryGrid({required this.weather, required this.settings});

  final dynamic weather;
  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetricItem(
        label: 'Air Quality',
        value: weather.airQuality ?? 'Unknown',
        icon: Icons.health_and_safety_outlined,
      ),
      _MetricItem(
        label: 'Humidity',
        value: '${weather.humidity ?? 64}%',
        icon: Icons.water_drop_outlined,
      ),
      _MetricItem(
        label: 'Wind',
        value: '${(weather.windSpeed ?? 12).toStringAsFixed(1)} ${settings.windUnit}',
        icon: Icons.air_outlined,
      ),
      _MetricItem(
        label: 'Pressure',
        value: '${weather.pressure ?? 1013} hPa',
        icon: Icons.speed_outlined,
      ),
      _MetricItem(
        label: 'Visibility',
        value: '${((weather.visibility ?? 10000) / 1000).toStringAsFixed(1)} km',
        icon: Icons.visibility_outlined,
      ),
      _MetricItem(
        label: 'UV Index',
        value: '${(weather.uvIndex ?? 0).toStringAsFixed(1)}',
        icon: Icons.wb_sunny_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (_, index) => items[index],
    );
  }
}

class _AirQualityBanner extends StatelessWidget {
  const _AirQualityBanner({required this.quality});

  final String quality;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
        children: [
          const Icon(Icons.cloud_queue_outlined, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Air Quality',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  quality,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white.withValues(alpha: 0.11),
          child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      ),
    ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.weather,
    required this.settings,
    required this.onFavorite,
    required this.onForecast,
  });

  final dynamic weather;
  final AppSettingsState settings;
  final VoidCallback onFavorite;
  final VoidCallback onForecast;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white.withValues(alpha: 0.12),
          child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Quick access',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onFavorite,
                  icon: const Icon(Icons.favorite_border),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Current city: ${weather.city}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Units: ${settings.temperatureUnit} • ${settings.windUnit}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onForecast,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: const Text('Forecast'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _PermissionDeniedCard extends StatelessWidget {
  const _PermissionDeniedCard({required this.message, required this.onOpenSettings});

  final String message;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onOpenSettings, child: const Text('Open Settings')),
          ],
        ),
      ),
    );
  }
}
