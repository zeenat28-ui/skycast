import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/weather_provider.dart';
import '../../domain/models/forecast_entry.dart';

class ForecastPage extends ConsumerWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherNotifierProvider);
    final forecast = state.forecast;

    final hourly = forecast?.hourly ?? <ForecastEntry>[];
    final daily = forecast?.daily ?? <ForecastEntry>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Forecast')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '24-hour forecast',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: hourly.isEmpty
                ? const Center(child: Text('No hourly data'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: hourly.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final e = hourly[index];
                      return _ForecastCard(
                        time: _formatHourLabel(e.timeLabel),
                        temp: '${e.temperature.round()}°',
                        icon: _mapIcon(e.iconCode),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
          Text('7-day forecast', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (daily.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('No daily data'),
            )
          else ...daily.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ForecastCard(
                  time: _formatDayLabel(e.timeLabel),
                  temp: '${e.temperature.round()}°',
                  icon: _mapIcon(e.iconCode),
                ),
              )),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({
    required this.time,
    required this.temp,
    required this.icon,
  });

  final String time;
  final String temp;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 110,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(time, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Icon(icon, size: 30),
              const SizedBox(height: 8),
              Text(temp, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatHourLabel(String ts) {
  try {
    final epoch = int.parse(ts) * 1000;
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch);
    return '${dt.hour}:00';
  } catch (_) {
    return ts;
  }
}

String _formatDayLabel(String ts) {
  try {
    final epoch = int.parse(ts) * 1000;
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch);
    return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][dt.weekday % 7];
  } catch (_) {
    return ts;
  }
}

IconData _mapIcon(String code) {
  if (code.startsWith('01')) return Icons.wb_sunny_outlined;
  if (code.startsWith('02') || code.startsWith('03') || code.startsWith('04')) return Icons.cloud_outlined;
  if (code.startsWith('09') || code.startsWith('10')) return Icons.grain_outlined;
  if (code.startsWith('11')) return Icons.thunderstorm_outlined;
  if (code.startsWith('13')) return Icons.ac_unit;
  return Icons.wb_cloudy_outlined;
}
