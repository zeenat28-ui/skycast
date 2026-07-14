import 'forecast_entry.dart';

class ForecastModel {
  ForecastModel({required this.hourly, required this.daily});

  final List<ForecastEntry> hourly;
  final List<ForecastEntry> daily;

  factory ForecastModel.fromForecastJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>? ?? <dynamic>[];

    final hourly = list.take(8).map((e) {
      final dt = e['dt'] as int? ?? 0;
      final temp = ((e['main']?['temp'] as num?) ?? 0).toDouble();
      final icon = (e['weather'] as List<dynamic>?)?.isNotEmpty == true
          ? e['weather'][0]['icon'] as String? ?? '01d'
          : '01d';
      final desc = (e['weather'] as List<dynamic>?)?.isNotEmpty == true
          ? e['weather'][0]['description'] as String? ?? ''
          : '';
      return ForecastEntry(
        timeLabel: dt.toString(),
        temperature: temp,
        iconCode: icon,
        description: desc,
      );
    }).toList();

    // Group by day to get daily forecast (take one reading per day, usually mid-day)
    final dailyMap = <String, ForecastEntry>{};
    for (final e in list) {
      final dtText = e['dt_txt'] as String? ?? '';
      if (dtText.isEmpty) continue;
      final date = dtText.split(' ').first; // YYYY-MM-DD
      
      // Prefer mid-day forecast (around 12:00:00) or just the first one of the day
      if (!dailyMap.containsKey(date) || dtText.contains('12:00:00')) {
        final dt = e['dt'] as int? ?? 0;
        final temp = ((e['main']?['temp'] as num?) ?? 0).toDouble();
        final icon = (e['weather'] as List<dynamic>?)?.isNotEmpty == true
            ? e['weather'][0]['icon'] as String? ?? '01d'
            : '01d';
        final desc = (e['weather'] as List<dynamic>?)?.isNotEmpty == true
            ? e['weather'][0]['description'] as String? ?? ''
            : '';
        dailyMap[date] = ForecastEntry(
          timeLabel: dt.toString(),
          temperature: temp,
          iconCode: icon,
          description: desc,
        );
      }
    }

    return ForecastModel(
      hourly: hourly,
      daily: dailyMap.values.take(7).toList(),
    );
  }
}
