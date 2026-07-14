# OpenWeatherMap API Setup Guide

## Overview

SkyCast Pro uses the OpenWeatherMap API to fetch real-time weather data. This guide explains how to get an API key and configure it.

## Getting an API Key

### Step 1: Create Account
1. Go to [OpenWeatherMap.org](https://openweathermap.org)
2. Click **Sign Up**
3. Fill in your details (email, username, password)
4. Verify your email
5. Accept terms and complete registration

### Step 2: Generate API Key
1. Log in to your OpenWeatherMap account
2. Go to **API Keys** tab
3. You'll see a default **API Key**
4. Copy this key (it will look like: `abc123def456ghi789jkl`)

## Configuration

### Method 1: Environment Variable (.env)

1. Create `.env` file in project root:
```bash
cd skycast
touch .env
```

2. Add your API key:
```env
OPENWEATHER_API_KEY=your_api_key_here
WEATHER_CITY=San Francisco
APP_NAME=SkyCast Pro
```

3. Save file and rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

### Method 2: Android Configuration

Add to `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        ...
        manifestPlaceholders = [
            OPEN_WEATHER_API_KEY: "your_api_key_here"
        ]
    }
}
```

### Method 3: iOS Configuration

Add to `ios/Runner/Info.plist`:
```xml
<dict>
    ...
    <key>OPEN_WEATHER_API_KEY</key>
    <string>your_api_key_here</string>
</dict>
```

## API Endpoints Used

### 1. Current Weather API
**Endpoint**: `https://api.openweathermap.org/data/2.5/weather`

**Parameters**:
- `q`: City name (e.g., "San Francisco")
- `units`: Temperature unit ("metric" = Celsius, "imperial" = Fahrenheit)
- `appid`: Your API key

**Example**:
```
https://api.openweathermap.org/data/2.5/weather?q=San Francisco&units=metric&appid=YOUR_API_KEY
```

**Response**:
```json
{
  "name": "San Francisco",
  "sys": {
    "country": "US",
    "sunrise": 1657100000,
    "sunset": 1657156000
  },
  "main": {
    "temp": 22.4,
    "feels_like": 22.0,
    "humidity": 64,
    "pressure": 1013
  },
  "weather": [
    {
      "description": "clear sky",
      "icon": "01d"
    }
  ],
  "wind": {
    "speed": 12
  },
  "clouds": {
    "all": 20
  },
  "visibility": 10000,
  "dt": 1657120000
}
```

### 2. 5-Day Forecast API
**Endpoint**: `https://api.openweathermap.org/data/2.5/forecast`

**Parameters**: Same as current weather

**Frequency**: Returns forecasts every 3 hours for 5 days

### 3. Geocoding API
**Endpoint**: `https://api.openweathermap.org/geo/1.0/direct`

**Parameters**:
- `q`: City name
- `limit`: Number of results (default: 5)
- `appid`: Your API key

**Use Case**: Get coordinates from city name for reverse geocoding

## API Limits

### Free Tier (Standard)
- **Calls/minute**: 60
- **Calls/month**: Unlimited
- **Forecast**: 5 days
- **History**: None
- **Alerts**: Basic

### Pricing
- Free tier is sufficient for this application
- Premium plans available for advanced features

## Testing the API

### Using cURL
```bash
curl "https://api.openweathermap.org/data/2.5/weather?q=London&units=metric&appid=YOUR_API_KEY"
```

### Using Postman
1. Create new request
2. Method: GET
3. URL: `https://api.openweathermap.org/data/2.5/weather`
4. Params:
   - `q`: London
   - `units`: metric
   - `appid`: YOUR_API_KEY
5. Send

### In App (Debug)
Enable logging in `core/infrastructure/api_client.dart`:
```dart
// Add interceptor logging
dio.interceptors.add(LoggingInterceptor());
```

## Troubleshooting

### "Invalid API Key"
- Verify key is correct (copy-paste from account page)
- Ensure key is in `.env` file
- Rebuild app: `flutter clean && flutter run`

### "City Not Found"
- Use standard city names (e.g., "New York" not "NYC")
- Check spelling
- Use city + country code (e.g., "London,UK")

### "Rate Limit Exceeded"
- Free tier allows 60 calls/minute
- Implement request debouncing
- Cache results locally

### "Connection Timeout"
- Check internet connection
- API might be temporarily down (rare)
- Implement retry logic (already built-in)

## Security Best Practices

### ✅ DO
- Store API key in `.env` file (never commit to git)
- Use environment variables
- Implement request validation
- Cache responses locally
- Implement rate limiting

### ❌ DON'T
- Hardcode API key in source code
- Commit `.env` file to version control
- Expose API key in client logs
- Use API key in frontend directly (use backend proxy for production)

## Production Setup

For production apps, consider:

1. **Backend Proxy**: Route API calls through your server
   - Protects API key
   - Enables rate limiting
   - Adds caching layer

2. **API Gateway**: Use AWS API Gateway, Firebase Functions, etc.

3. **Monitoring**: Track API usage and costs

## Example Implementation

```dart
// In weather_remote_data_source.dart
Future<WeatherModel> fetchCurrentWeather() async {
  final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
  
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('API key not configured');
  }

  final response = await _apiClient.get<Map<String, dynamic>>(
    'https://api.openweathermap.org/data/2.5/weather',
    queryParameters: {
      'q': city,
      'units': 'metric',
      'appid': apiKey,
    },
  );

  if (response.statusCode != 200) {
    throw DioException(
      message: 'Failed to fetch weather',
      requestOptions: response.requestOptions,
    );
  }

  return WeatherModel.fromJson(response.data!);
}
```

## Support

- [OpenWeatherMap API Docs](https://openweathermap.org/api)
- [OpenWeatherMap FAQ](https://openweathermap.org/faq)
- [OpenWeatherMap Support](https://openweathermap.org/find-help)

---

**Last Updated**: July 2026  
**Version**: 1.0.0
