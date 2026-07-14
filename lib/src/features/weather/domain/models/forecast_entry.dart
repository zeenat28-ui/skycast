class ForecastEntry {
  const ForecastEntry({
    required this.timeLabel,
    required this.temperature,
    required this.iconCode,
    required this.description,
  });

  final String timeLabel;
  final double temperature;
  final String iconCode;
  final String description;
}
