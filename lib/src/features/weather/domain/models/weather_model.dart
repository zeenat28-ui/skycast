class WeatherModel {
  WeatherModel({
    required this.city,
    required this.description,
    required this.temperature,
    required this.feelsLike,
    required this.iconCode,
    this.humidity = 0,
    this.pressure = 0,
    this.visibility = 0,
    this.windSpeed = 0,
    this.cloudCoverage = 0,
    this.rainProbability = 0,
    this.uvIndex = 0,
    this.sunrise = '',
    this.sunset = '',
    this.airQuality = 'Unknown',
    this.country = '',
    this.timestamp = 0,
    this.lat = 0.0,
    this.lon = 0.0,
  });

  final String city;
  final String description;
  final double temperature;
  final double feelsLike;
  final String iconCode;
  final int humidity;
  final int pressure;
  final int visibility;
  final double windSpeed;
  final int cloudCoverage;
  final int rainProbability;
  final double uvIndex;
  final String sunrise;
  final String sunset;
  final String airQuality;
  final String country;
  final int timestamp;
  final double lat;
  final double lon;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'] as String? ?? 'Unknown',
      country: json['sys']?['country'] as String? ?? '',
      description: (json['weather'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['weather'][0]['description'] as String? ?? 'N/A')
          : 'N/A',
      temperature: ((json['main']?['temp'] as num?) ?? 0).toDouble(),
      feelsLike: ((json['main']?['feels_like'] as num?) ?? 0).toDouble(),
      iconCode: (json['weather'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['weather'][0]['icon'] as String? ?? '01d')
          : '01d',
      humidity: (json['main']?['humidity'] as num?)?.toInt() ?? 0,
      pressure: (json['main']?['pressure'] as num?)?.toInt() ?? 0,
      visibility: (json['visibility'] as num?)?.toInt() ?? 0,
      windSpeed: ((json['wind']?['speed'] as num?) ?? 0).toDouble(),
      cloudCoverage: (json['clouds']?['all'] as num?)?.toInt() ?? 0,
      rainProbability: ((json['rain']?['1h'] as num?) ?? 0).toInt(),
      uvIndex: ((json['uvi'] as num?) ?? 0).toDouble(),
      sunrise: json['sys']?['sunrise']?.toString() ?? '',
      sunset: json['sys']?['sunset']?.toString() ?? '',
      airQuality: json['air_quality'] as String? ?? 'Unknown',
      timestamp: (json['dt'] as num?)?.toInt() ?? 0,
      lat: ((json['coord']?['lat'] as num?) ?? json['lat'] as num? ?? 0).toDouble(),
      lon: ((json['coord']?['lon'] as num?) ?? json['lon'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': city,
      'sys': {'country': country, 'sunrise': sunrise, 'sunset': sunset},
      'weather': [
        {'description': description, 'icon': iconCode},
      ],
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
      },
      'visibility': visibility,
      'wind': {'speed': windSpeed},
      'clouds': {'all': cloudCoverage},
      'dt': timestamp,
      'rain': {'1h': rainProbability},
      'uvi': uvIndex,
      'air_quality': airQuality,
      'coord': {'lat': lat, 'lon': lon},
    };
  }
}
